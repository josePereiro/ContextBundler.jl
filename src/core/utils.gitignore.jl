"""
    load_gitignore(base::AbstractString = pwd(); log::Bool = true)
        -> Vector{Glob.FilenameMatch}

Read a `.gitignore` file from `base` and return a vector of `Glob.FilenameMatch`
patterns suitable for use in exclusion filtering.
"""
function load_gitignore(base::AbstractString = pwd(); log::Bool = true)
    path = joinpath(base, ".gitignore")
    isfile(path) || return nothing

    fmts = Glob.FilenameMatch[]
    for (i, line) in enumerate(eachline(path))
        glob = strip(line)
        isempty(glob) && continue
        startswith(glob, '#') && continue  # comment line

        try
            fm = Glob.FilenameMatch(glob)
            push!(fmts, fm)
        catch err
            log && @warn "Invalid .gitignore pattern skipped." pattern=glob line=i base=base error=err
            continue
        end
    end

    return fmts
end
