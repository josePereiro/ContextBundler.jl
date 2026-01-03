function _validate_config(cfg; log::Bool=true)
    has_error = false

    base = get(cfg, "__config.base", pwd())
    roots = get(cfg, "root.paths", String[])
    roots = _canonicalize.(roots; base)
    include_globs = get(cfg, "include.files", String[])
    exclude_globs = get(cfg, "exclude.files", String[])

    # --- base ---
    if !(base isa AbstractString)
        log && @error "__config.base must be a string path."
        has_error = true
    elseif !isdir(base)
        log && @error "Base directory does not exist." base=base
        has_error = true
    end

    # --- roots ---
    if isempty(roots)
        log && @error "root.paths is empty — no directories to scan."
        has_error = true
    end

    # Check for glob validity
    try
        Glob.FilenameMatch.(include_globs)
    catch err
        log && @error "Invalid glob(s) in include.files." error=err
        has_error = true
    end
    try
        Glob.FilenameMatch.(exclude_globs)
    catch err
        log && @error "Invalid glob(s) in exclude.files." error=err
        has_error = true
    end

    # --- path existence ---
    for r in roots
        isdir(r) && continue
        log && @warn "Root path does not exist." root=r base=base
    end

    # --- sanity warnings ---
    if isempty(include_globs) && isempty(exclude_globs)
        log && @warn "Both include.files and exclude.files are empty — all files will be included."
    end
    if length(unique(roots)) != length(roots)
        log && @warn "Duplicate entries found in root.paths config."
    end

    if log
        if has_error
            @error "Configuration validation failed — aborting."
        else
            @info "Configuration validation passed."
        end
    end

    return !has_error
end
