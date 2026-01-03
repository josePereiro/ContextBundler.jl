# -------------------------------------------
# Public API
# -------------------------------------------

CONFIG_FILE_NAMES = [
    "ContextBundler.jsonc",
    "ContextBundler.json",
]

function _walkup_config_file(;
    stop_when::Function=dir -> homedir() == dir
)

    config_file = nothing
    walk_parents(;
        start = get(CXB_SETTINGS, "base.dir", pwd()),
        on_dir=dir -> begin
            #find a config file
            for name in CONFIG_FILE_NAMES
                path = joinpath(dir, name)
                if isfile(path)
                    config_file = path
                    return false
                end
            end
            return true
        end,
        stop_when=stop_when,
    )
    return config_file
end


function _userdir_config_file(
    project_name::AbstractString="default";
)
    return joinpath(
        user_configdir(), project_name
    )

end

function resolve_config_file()
    
    # 1. Look for config file settings
    cfg_file = get(CXB_SETTINGS, "config.file", "")
    if isfile(cfg_file)
        return cfg_file
    end

    # 2. Look for config file in current dir or parents
    cfg_file = _walkup_config_file()
    if !isnothing(cfg_file)
        CXB_SETTINGS["config.file"] = cfg_file
        return cfg_file
    end

    # 3. Look for user dir config file
    proj_name = get(CXB_SETTINGS, "project.name", "default")
    user_cfg_file = _userdir_config_file(proj_name)
    if isfile(user_cfg_file)
        CXB_SETTINGS["config.file"] = user_cfg_file
        return user_cfg_file
    end

    return nothing
end

function read_config()
    path = resolve_config_file()
    isnothing(path) && return Dict{String,Any}()
    isfile(path) || return Dict{String,Any}()
    _cfg = Dict{String,Any}()
    _read_json_with_comments!(_cfg, path)
    return _cfg
end