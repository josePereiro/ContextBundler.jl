

function zipfile_bundle(paths::Vector{String},
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