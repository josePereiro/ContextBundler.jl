# Mapping of canonical settings keys to their aliases
const CXB_SETTINGS_REGISTRY = Dict{String,Dict{String,Any}}()

function _populate_settings_registry()
    empty!(CXB_SETTINGS_REGISTRY)
    _reg = Dict{String,Dict{String,Any}}()

    _reg["use.gitignore"] = Dict(
        "default" => true,
        "aliases" => [
            "use_gitignore",
            "CTXBUNDLER_USE_GITIGNORE"
        ]
    )

    _reg["project.name"] = Dict(
        "default" => nothing,
        "aliases" => [
            "project_name",
            "CTXBUNDLER_PROJECT_NAME"
        ]
    )

    _reg["config.file"] = Dict(
        "default" => nothing,
        "aliases" => [
            "config_file",
            "CTXBUNDLER_CONFIG_FILE"
        ]
    )

    _reg["md.output.file"] = Dict(
        "default" => nothing,
        "aliases" => [
            "md_output_file",
            "CTXBUNDLER_MD_OUTPUT_FILE"
        ]
    )

    _reg["md.output.mode"] = Dict(
        "default" => nothing,
        "aliases" => [
            "md_output_mode",
            "CTXBUNDLER_MD_OUTPUT_MODE"
        ]
    )

    _reg["io.verbose"] = Dict(
        "default" => nothing,
        "aliases" => [
            "verbose",
            "CTXBUNDLER_VERBOSE"
        ]
    )

    _reg["io.dry.run"] = Dict(
        "default" => nothing,
        "aliases" => [
            "dry_run",
            "CTXBUNDLER_DRY_RUN"
        ]
    )

    _reg["list.files"] = Dict(
        "default" => nothing,
        "aliases" => [
            "list_files",
            "CTXBUNDLER_LIST_FILES"
        ]
    )

    _reg["base.dir"] = Dict(
        "default" => nothing,
        "aliases" => [
            "base_dir",
            "CTXBUNDLER_BASE_DIR"
        ]
    )

    _reg["depot.root"] = Dict(
        "default" => nothing,
        "aliases" => [
            "depot_root",
            "CTXBUNDLER_DEPOT_ROOT"
        ]
    )

    _reg["collector.rules"] = Dict(
        "default" => nothing,
        "aliases" => []
    )

    _reg["collector.root.paths"] = Dict(
        "default" => nothing,
        "aliases" => [
            "collector_root_paths",
            "CTXBUNDLER_COLLECTOR_ROOT_PATHS"
        ]
    )

    _reg["md.output.path"] = Dict(
        "default" => nothing,
        "aliases" => [
            "md_output_path",
            "CTXBUNDLER_MD_OUTPUT_PATH"
        ]
    )

    _reg["md.template.file"] = Dict(
        "default" => nothing,
        "aliases" => [
            "md_template_file",
            "CTXBUNDLER_MD_TEMPLATE_FILE"
        ]
    )

    _reg["zip.output.path"] = Dict(
        "default" => nothing,
        "aliases" => [
            "zip_output_path",
            "CTXBUNDLER_ZIP_OUTPUT_PATH"
        ]
    )

    _reg["zip.output.mode"] = Dict(
        "default" => nothing,
        "aliases" => [
            "zip_output_mode",
            "CTXBUNDLER_ZIP_OUTPUT_MODE"
        ]
    )

    merge!(CXB_SETTINGS_REGISTRY, _reg)
end

const CXB_SETTINGS_KEY_MAP = Dict{String,String}()
function _expand_settings_key_map()
    empty!(CXB_SETTINGS_KEY_MAP)
    m = Dict{String,String}()
    for (k, setting) in CXB_SETTINGS_REGISTRY
        m[k] = k
        for alias in setting["aliases"]
            m[alias] = k
        end
    end
    merge!(CXB_SETTINGS_KEY_MAP, m)
end

function initialize_settings_registry()
    _populate_settings_registry()
    _expand_settings_key_map()
end

_has_canonical_key(key::String) = haskey(CXB_SETTINGS_KEY_MAP, key)
_canonical_key(key::String) = getindex(CXB_SETTINGS_KEY_MAP, key)

function _warn_unregistered_key(key::AbstractString)
    if !haskey(CXB_SETTINGS_REGISTRY, key)
        @warn("Setting key '$key' is not registered in CXB_SETTINGS_REGISTRY")
    end
end