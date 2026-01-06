function config_example()
    # Build path to the example config shipped with the package
    root = pkgdir(ContextBundler)
    example_path = joinpath(root, "data", "SourceConfig.example.json")

    if !isfile(example_path)
        error("Example config file not found at: $example_path")
    end

    return read(example_path, String)
end
