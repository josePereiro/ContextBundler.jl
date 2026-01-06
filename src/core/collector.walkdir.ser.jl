"""
    walkdir_serial(root::AbstractString;
                   ondir::Function = _ -> true,
                   onfile::Function = _ -> true,
                   verbose::Bool = false)

Traverse a directory tree rooted at `root` **serially** (non-threaded).

Callbacks:
- `ondir(dir)` may return `:skip` to skip descending into `dir`, or `:stop` to stop globally.
- `onfile(path)` may return `:stop` to stop globally.

Behavior:
- Directories that cannot be read are skipped with a warning.
- Traversal is "mostly DFS": for each directory, it descends into one subdir immediately
  and defers remaining subdirs onto a work list.
- No values are collected; use callbacks for side effects.

Returns `nothing`.
"""
function walkdir_ser(root::AbstractString;
    ondir::Function=_ -> true,
    onfile::Function=_ -> true,
    verbose::Bool=false,
)
    work = String[]           # deferred sibling directories (LIFO)
    stop = Ref(false)         # mutable stop flag shared across recursion

    function visit(dir::String)
        stop[] && return

        verbose && @info "[serial] visiting dir: $dir"

        # Directory callback
        ret = ondir(dir)
        if ret === :skip
            verbose && @info "[serial] skipping dir $dir as per ondir callback"
            return
        elseif ret === :stop
            verbose && @info "[serial] stopping as per ondir callback"
            stop[] = true
            return
        end

        # Read directory entries
        entries = try
            readdir(dir; join=true)
        catch err
            @warn "[serial] Failed to read dir $dir: $err"
            return
        end

        subdirs = String[]

        for p in entries
            stop[] && return

            if isdir(p)
                push!(subdirs, p)
            else
                verbose && @info "[serial] visiting file: $p"
                fret = onfile(p)
                if fret === :stop
                    verbose && @info "[serial] stopping as per onfile callback"
                    stop[] = true
                    return
                end
            end
        end

        isempty(subdirs) && return

        # "Mostly DFS":
        # recurse immediately into the first subdir,
        # defer the rest onto the work stack
        dir0 = first(subdirs)
        i0 = firstindex(subdirs)
        for i in eachindex(subdirs)
            i == i0 && continue
            push!(work, subdirs[i])
        end

        visit(dir0)
    end

    # Seed with root
    push!(work, root)

    # Process deferred work until exhausted or stopped
    while !stop[] && !isempty(work)
        dir = pop!(work)
        visit(dir)
    end

    return nothing
end
