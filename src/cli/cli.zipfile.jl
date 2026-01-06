

function _zipfile_bundle(
    paths,
    output_path::String
)

    prefix = ContextBundler.common_prefix(paths)
    writer = ZipFile.Writer(output_path)

    for path in paths
        # Read from original location
        content = read(path)
        # Create entry with custom internal path
        relpath = replace(path, prefix => "")
        f = ZipFile.addfile(writer, relpath)
        write(f, content)
    end

    close(writer)
end

function zipfile_bundle()

    roots = get_settings("collector.root.paths", String[])
    paths = collect(collect_paths_lazy(roots))

    # print paths
    for path in paths
        @info "including path: $path"
    end

    output_path = get_settings(
        "zipfile.output.path",
        joinpath(user_dir(), "context.zip")
    )

    try
        rm(output_path; force=true)
        _mkdirpath(output_path)
        _zipfile_bundle(paths, output_path)
        if isfile(output_path)
            @info "created zipfile at $output_path"
            clipboard_file(output_path; log=true)
        else
            @error "failed to create zipfile at $output_path"
        end
    catch e
        @error "failed to create zipfile at $output_path"
        @error "$e"
        return
    end

end