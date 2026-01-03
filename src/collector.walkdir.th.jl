using Base.Threads

"""
    walk_parallel(root::AbstractString;
                  N::Int = Threads.nthreads(),
                  ondir::Function = _ -> true,
                  onfile::Function = _ -> true,
                  verbose::Bool = false)

Traverse a directory tree rooted at `root` using `N` worker threads, visiting
directories and files in parallel.

The traversal is **mostly depth-first per worker**, with excess subdirectories
handed off to a shared work queue to enable load balancing across threads.

# Callbacks

- `ondir(dir)`: called when a directory `dir` is visited.
- `onfile(path)`: called for each non-directory entry `path`.

Both callbacks may return:
- `:skip` (only for `ondir`): skip descending into this directory.
- `:stop`: request a global early stop of the traversal.
- anything else: continue normally.

Callbacks are executed concurrently on multiple threads and must therefore
be thread-safe.

# Behavior

- Directories that cannot be read (e.g. due to permissions) are skipped with a warning.
- Once `:stop` is returned by any callback, all workers terminate as soon as possible.
- The function blocks until all workers have exited.
- No values are collected; side effects must be implemented inside callbacks.

# Keyword Arguments

- `N`: number of worker tasks to spawn (default: `Threads.nthreads()`).
- `ondir`: directory callback (see above).
- `onfile`: file callback (see above).
- `verbose`: if `true`, emit informational logging from workers.
- `queue_lim`: maximum length of the shared work queue (default: `100_000`).
- If the queue length exceeds this limit, workers attempting to add new directories
  will wait until space is available.
- `idle_tout`: maximum number of seconds without activity before stopping the traversal (default: `30.0`).

# Returns

`nothing`.

# Notes

- Traversal order is not deterministic.
- Symbolic links are treated according to `isdir`; non-directories are passed to `onfile`.
- This function is intended for side-effectful directory walks (indexing, scanning, etc.),
  not for producing ordered results.
"""
function walkdir_th(root::AbstractString;
    N::Int=Threads.nthreads(),
    ondir::Function=_ -> true,
    onfile::Function=_ -> true,
    verbose::Bool=false,
    queue_lim::Int=100_000,
    idle_tout::Float64=30.0
)

    # Shared work queue of directories to process
    q = Channel{String}(Inf)
    put!(q, String(root))

    # Global stop flag
    stop = Threads.Atomic{Bool}(false)

    # Count of "directories currently being processed" across all workers
    inflight = Threads.Atomic{Int}(0)

    last_activity = Threads.Atomic{Float64}(time())

    function worker()

        th = Threads.threadid()

        verbose && @info "[worker $(th)] started"

        local_stack = String[]  # DFS stack local to this worker

        while true
            if stop[]
                verbose && @info "[worker $(th)] stopping early as requested"
                return
            end

            verbose && @info "[worker $(th)] inflight: $(inflight[]), queue length: $(Base.n_avail(q)), local stack length: $(length(local_stack))"

            # Get more work if local stack is empty
            if isempty(local_stack)
                # If channel gets closed, take! throws -> exit worker
                dir = try
                    take!(q)
                catch err
                    if err isa InterruptException
                        verbose && @info "[worker $(th)] exiting due to closed channel"
                        stop[] = true
                    end
                    return
                end
                verbose && @info "[worker $(th)] got work: $dir"
                push!(local_stack, dir)
            end


            dir = pop!(local_stack)
            Threads.atomic_add!(inflight, 1)
            last_activity[] = time()
            try
                # Visit directory
                verbose && @info "[worker $(th)] visiting dir: $dir"
                ret = ondir(dir)
                if ret === :skip
                    verbose && @info "[worker $(th)] skipping dir $dir as per ondir callback"
                    continue
                end
                if ret === :stop
                    verbose && @info "[worker $(th)] requesting stop as per ondir callback"
                    stop[] = true
                    return
                end

                # List entries
                entries = try
                    readdir(dir; join=true)
                catch err
                    if err isa InterruptException
                        verbose && @info "[worker $(th)] exiting due to closed channel"
                        stop[] = true
                        rethrow(err)
                    end
                    # permissions / broken links / etc. -> just skip
                    @warn "[worker $(th)] Failed to read dir $dir: $err"
                    continue
                end
                verbose && @info "[worker $(th)] entries in $dir: $(length(entries))"

                # Split dirs/files
                subdirs = String[]
                for p in entries

                    # TODO: maybe stop only on next iteration?
                    if stop[]
                        verbose && @info "[worker $(th)] stopping early as requested"
                        return
                    end

                    # Directory -> queue for later
                    if isdir(p)
                        push!(subdirs, p)
                        continue
                    end

                    # Treat everything else as a file-like leaf
                    ret = onfile(p)
                    verbose && @info "[worker $(th)] visiting file: $p"
                    if ret === :stop
                        verbose && @info "[worker $(th)] requesting stop as per onfile callback"
                        stop[] = true
                        return
                    end
                end

                # "Mostly DFS": go deep on ONE subdir locally; push the rest to the shared queue
                if !isempty(subdirs)
                    # Optional: a deterministic-ish order; remove if you don’t care
                    # sort!(subdirs)

                    # Keep first for local DFS
                    push!(local_stack, first(subdirs))

                    # Hand remaining subdirs to other workers
                    for i in eachindex(subdirs)
                        i == firstindex(subdirs) && continue
                        
                        if stop[]
                            verbose && @info "[worker $(th)] stopping early as requested"
                            return
                        end

                        # wait for space in queue
                        while true
                            if stop[]
                                verbose && @info "[worker $(th)] stopping early as requested"
                                return
                            end

                            if Base.n_avail(q) < queue_lim
                                break
                            end
                            @info "[worker $(th)] queue full (length=$(Base.n_avail(q))), waiting to add dir: $(subdirs[i]), last activity=$(time() - last_activity[])s ago"
                            sleep(0.5)
                        end

                        put!(q, subdirs[i])
                    end
                end
            catch err
                if err isa InterruptException
                    verbose && @info "[worker $(th)] exiting due to closed channel"
                    stop[] = true
                    rethrow(err)
                end
                # permissions / broken links / etc. -> just skip
                @warn "[worker $(th)] Failed to read dir $dir: $err"
            finally
                Threads.atomic_add!(inflight, -1)
            end
        end
    end

    # Spawn exactly N workers (no more spawning later)
    tasks = [Threads.@spawn worker() for _ in 1:N]

    # Close the channel when work is done (or stop requested)
    while true
        if stop[]
            close(q)
            break
        end
        # Done when no one is processing a dir and queue is empty
        if inflight[] == 0 && !isready(q)
            stop[] = true
            close(q)
            break
        end

        if time() - last_activity[] > idle_tout
            @warn "No activity detected for $(idle_tout) seconds, stopping walkdir_parallel"
            stop[] = true
            close(q)
            break
        end

        th = Threads.threadid()
        @info "[worker $(th)] waiting for work to complete: inflight=$(inflight[]), queue length=$(Base.n_avail(q)), last activity=$(time() - last_activity[])s ago"

        sleep(0.1)
    end

    # Ensure workers exit
    foreach(wait, tasks)
    return nothing
end
