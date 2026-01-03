## ..- . -- -.- .- -. - --. .-. -. .- -
# util for mathing many globs to a single path
function _match_anyglob(path::String, fms::Vector{<:Glob.FilenameMatch})
    for fm in fms
        ismatch(fm, path) && return true
    end
    return false
end

function _canonicalize(path; base=pwd())
    p = expanduser(path)
    p = isabspath(p) ? p : abspath(base, p)
    p = normpath(p)  # tidy but don't require existence
    return p
end

function clipboard_text(text::AbstractString;
    limit::Int=200_000, log::Bool=true
)
    n = ncodeunits(text)
    if n > limit
        log && @warn "String too long; not copying to clipboard." bytes = n limit = limit
        return false
    else
        clipboard(text)
        log && @info "Copied text to clipboard." bytes = n
        return true
    end
end

function write_output(
    path::AbstractString,
    lines::Vector{<:AbstractString};
    log::Bool=true
)
    try
        mkpath(dirname(path))
        open(path, "w") do io
            for line in lines
                println(io, line)
            end
        end
        sz = filesize(path)
        log && @info "Wrote output file." path = abspath(path) lines = length(lines) bytes = sz
        return path
    catch err
        log && @error "Failed to write output file." path = abspath(path) exception = (err, catch_backtrace())
        rethrow()
    end
end


function common_prefix(paths::Vector{<:AbstractString})
    isempty(paths) && return ""
    parts = splitpath.(paths)
    minlen = minimum(length, parts)
    prefix = String[]
    for i in 1:minlen
        segment = parts[1][i]
        all(p -> p[i] == segment, parts) || break
        push!(prefix, segment)
    end
    return joinpath(prefix...)
end

"""
    walk_parents(start=pwd(); on_dir, stop_when)

Walk `start` and all its parent directories up to the filesystem root.

Callbacks:
- `on_dir(dir)::Bool` is called for each directory.
  - return `true` to continue
  - return `false` to stop
- `stop_when(dir)::Bool` (optional) stops BEFORE calling `on_dir`

Returns the last visited directory.
"""
function walk_parents(;
    start::AbstractString=pwd(),
    on_dir::Function,
    stop_when::Function=_ -> false,
)
    dir = abspath(start)

    while true
        stop_when(dir) && break

        continue_walk = on_dir(dir)
        continue_walk === false && break

        parent = dirname(dir)
        parent == dir && break   # reached filesystem root
        dir = parent
    end

    return dir
end
