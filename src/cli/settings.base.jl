# CXB_SETTINGS contains the state of the environment for ContextBundler
# User is responsable to set presedence/absence of keys
# e.g., via merge_base_env! and merge_cli_args!
# or directly manipulating
# funtions use as CXB_SETTINGS as extra configuration source

struct CXBSettings
    settings::Dict{String,Any}
end

# TODO/TAI think about default system
set_defaults!() = begin
    # Set default for all register keys if not set
    #     haskey(CXB_SETTINGS, k) && continue
    #     if k == "io.verbose"
    #         setindex!(CXB_SETTINGS, 0, k)
    #     elseif k == "base.dir"
    #         setindex!(CXB_SETTINGS, pwd(), k)
    #     elseif k == "config.file"
    #         setindex!(CXB_SETTINGS, nothing, k)
    #     elseif k == "io.dry.run"
    #         setindex!(CXB_SETTINGS, 0, k)
    #     elseif k == "md.output.file"
    #         setindex!(CXB_SETTINGS, joinpath(user_dir(), "context.md"), k)
    #     elseif k == "md.output.mode"
    #         setindex!(CXB_SETTINGS, "clipboard-file", k)
    #     elseif k == "list.files"
    #         setindex!(CXB_SETTINGS, 0, k)
    #     elseif k == "project.name"
    #         setindex!(CXB_SETTINGS, "default", k)
    #     elseif k == "collector.root.paths"
    #         setindex!(CXB_SETTINGS, [pwd()], k)
    #     elseif k == "depot.root"
    #         setindex!(CXB_SETTINGS, joinpath(homedir()), k)
    #     else
    #         setindex!(CXB_SETTINGS, nothing, k)
    #     end
    # end
    # ckeck tha all keys are set
    # Only during development
    # for (k, _) in CXB_SETTINGS_REGISTRY
    #     !haskey(CXB_SETTINGS, k) && error("Setting key '$k' was not set in set_defaults!")
    # end
    # return nothing
end


const CXB_SETTINGS = CXBSettings(Dict{String,Any}())

import Base.getindex
function getindex(s::CXBSettings, key::AbstractString)
    _warn_unregistered_key(key)
    return getindex(s.settings, _canonical_key(key))
end

import Base.setindex!
function setindex!(s::CXBSettings, value, key::AbstractString)
    isnothing(value) && return nothing
    _warn_unregistered_key(key)
    setindex!(s.settings, value, _canonical_key(key))
end

import Base.haskey
function haskey(s::CXBSettings, key::AbstractString)
    _has_canonical_key(key) || return false
    return haskey(s.settings, _canonical_key(key))
end

import Base.get
function get(s::CXBSettings, key::AbstractString, default)
    return get(s.settings, key, default)
end

function clear_settings!()
    empty!(CXB_SETTINGS.settings)
    return nothing
end

function get_settings(key)
    return getindex(CXB_SETTINGS, key)
end
function get_settings(key, default)
    return get(CXB_SETTINGS, key, default)
end

# Merge ENV into CXB_SETTINGS
# Ignores unregistered keys
function merge_env(
    env=Base.ENV
)
    for (k, v) in env
        _has_canonical_key(k) || continue
        setindex!(CXB_SETTINGS, v, k)
    end
    return nothing
end

# Merge CLI args into CXB_SETTINGS
# Uses parse_commandline from base.cli.jl
function merge_cli_args(
    args=parse_commandline()
)
    for (k, v) in args
        # only merge registered keys
        setindex!(CXB_SETTINGS, v, k)
    end
    return nothing
end

function merge_config_file(
    config=read_config()
)
    for (k, v) in config
        setindex!(CXB_SETTINGS, v, k)
    end
    return nothing
end

function resolve_settings()
    merge_env()
    merge_config_file()
    merge_cli_args()
    set_defaults!()
    return nothing
end