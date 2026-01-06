# this provides an standard cli interface for ContextBundler

using ArgParse

function parse_commandline()
    # Remove default values for all arguments
    s = ArgParseSettings(
        description="ContextBundler: Toolkit for gathering context for AI assistants",
        version="0.0.1",
        add_help=true
    )

    @add_arg_table! s begin
        "--config", "-c"
        help = "Path to configuration file (default: auto-discover)"
        arg_type = String
        default = nothing
        "--output", "-o"
        help = "Output file path (overrides config)"
        arg_type = String
        default = nothing
        "--mode", "-m"
        help = "Output mode: file, clipboard-text, clipboard-file, terminal"
        arg_type = String
        default = nothing
        "--base", "-b"
        help = "Base directory for relative paths (default: pwd)"
        arg_type = String
        default = nothing
        "--verbose", "-v"
        help = "Enable verbose logging"
        arg_type = Integer
        default = nothing
        "--dry-run"
        help = "Print to terminal without writing/copying"
        arg_type = Integer
        default = nothing
        "--list-files"
        help = "List matching files and exit"
        arg_type = Integer
        default = nothing
        "--project-name", "-p"
        help = "Project name"
        arg_type = String
        default = nothing
    end

    return parse_args(s)
end


