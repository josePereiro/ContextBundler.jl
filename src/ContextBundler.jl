module ContextBundler

using JSON3
using Glob
using Dates
using Printf
using InteractiveUtils
using Unicode
using ZipFile

#! include .
include("base.cli.jl")
include("base.configfile.jl")
include("base.settings.jl")
include("base.settings.registry.jl")
include("base.userdir.jl")
include("collector.collect.paths.jl")
include("collector.rules.jl")
include("collector.walkdir.ser.jl")
include("collector.walkdir.th.jl")
include("md.bundle.jl")
include("md.concat.lines.jl")
include("utils.clipboard.file.jl")
include("utils.config.example.jl")
include("utils.config.validate.jl")
include("utils.gitignore.jl")
include("utils.jl")
include("utils.jsonc.jl")
include("utils.lang.map.jl")
include("zipfile.bundle.jl")

function __init__()
    # initialize settings registry
    initialize_settings_registry()
end


end