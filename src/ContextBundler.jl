module ContextBundler

using JSON3
using Glob
using Dates
using Printf
using InteractiveUtils
using Unicode
using ZipFile

#! include core
include("core/collector.collect.paths.jl")
include("core/collector.rules.jl")
include("core/collector.walkdir.ser.jl")
include("core/collector.walkdir.th.jl")
include("core/configfile.jl")
include("core/utils.base.jl")
include("core/utils.clipboard.file.jl")
include("core/utils.gitignore.jl")
include("core/utils.jsonc.jl")
include("core/utils.lang.map.jl")

#! include cli
include("cli/cli.base.jl")
include("cli/cli.zipfile.jl")
include("cli/md.bundle.jl")
include("cli/md.concat.lines.jl")
include("cli/settings.base.jl")
include("cli/settings.registry.jl")
include("cli/userdir.jl")
include("cli/utils.config.example.jl")
include("cli/utils.config.validate.jl")


function __init__()
    # initialize settings registry
    initialize_settings_registry()
end


end