const EXT_LANG_MAP = Dict(
    # --- Julia family ---
    ".jl"  => "julia",

    # --- Python & scientific ---
    ".py"  => "python",
    ".ipynb" => "json",   # notebooks are JSON, not pure Python
    ".r"   => "r",
    ".rmd" => "r",
    ".m"   => "matlab",   # ambiguous (Octave/Matlab)
    ".nb"  => "mathematica",
    ".wl"  => "wolfram",

    # --- C / C++ / C family ---
    ".c"   => "c",
    ".h"   => "c",
    ".cpp" => "cpp",
    ".hpp" => "cpp",
    ".cc"  => "cpp",
    ".cxx" => "cpp",
    ".hh"  => "cpp",
    ".ino" => "cpp",      # Arduino sketches
    ".cs"  => "csharp",
    ".go"  => "go",
    ".rs"  => "rust",
    ".zig" => "zig",

    # --- Web / frontend ---
    ".html" => "html",
    ".htm"  => "html",
    ".xhtml" => "html",
    ".xml"  => "xml",
    ".css"  => "css",
    ".scss" => "scss",
    ".sass" => "sass",
    ".js"   => "javascript",
    ".mjs"  => "javascript",
    ".cjs"  => "javascript",
    ".ts"   => "typescript",
    ".tsx"  => "tsx",
    ".jsx"  => "jsx",
    ".vue"  => "vue",
    ".svelte" => "svelte",

    # --- Shells & CLI ---
    ".sh"  => "bash",
    ".bash" => "bash",
    ".zsh" => "bash",
    ".fish" => "fish",
    ".bat" => "dos",
    ".cmd" => "dos",
    ".ps1" => "powershell",

    # --- Data & configs ---
    ".json" => "json",
    ".jsonc" => "json",
    ".toml" => "toml",
    ".ini"  => "ini",
    ".cfg"  => "ini",
    ".conf" => "conf",
    ".yaml" => "yaml",
    ".yml"  => "yaml",
    ".csv"  => "csv",
    ".tsv"  => "tsv",
    ".log"  => "text",

    # --- Markup & docs ---
    ".md"   => "markdown",
    ".markdown" => "markdown",
    ".txt"  => "text",
    ".rst"  => "rst",
    ".tex"  => "latex",
    ".bib"  => "bibtex",
    ".org"  => "org",
    ".asciidoc" => "asciidoc",
    ".adoc" => "asciidoc",

    # --- Make / build / CI ---
    ".make" => "makefile",
    ".mk"   => "makefile",
    ".makefile" => "makefile",
    ".dockerfile" => "dockerfile",
    "Dockerfile"  => "dockerfile",
    ".yml"  => "yaml",
    ".nix"  => "nix",

    # --- Lisp / functional ---
    ".clj"  => "clojure",
    ".cljs" => "clojure",
    ".lisp" => "lisp",
    ".el"   => "emacs-lisp",
    ".scm"  => "scheme",
    ".rkt"  => "racket",
    ".hs"   => "haskell",
    ".lhs"  => "haskell",
    ".ml"   => "ocaml",
    ".mli"  => "ocaml",
    ".fs"   => "fsharp",
    ".ex"   => "elixir",
    ".exs"  => "elixir",
    ".erl"  => "erlang",

    # --- JVM languages ---
    ".java" => "java",
    ".kt"   => "kotlin",
    ".kts"  => "kotlin",
    ".groovy" => "groovy",
    ".scala" => "scala",

    # --- Systems / misc ---
    ".swift" => "swift",
    ".dart"  => "dart",
    ".php"   => "php",
    ".perl"  => "perl",
    ".pl"    => "perl",
    ".rb"    => "ruby",
    ".cr"    => "crystal",
    ".lua"   => "lua",

    # --- Hardware / HDL ---
    ".v"    => "verilog",
    ".vh"   => "verilog",
    ".sv"   => "systemverilog",
    ".vhd"  => "vhdl",

    # --- Scripts / configs special cases ---
    ".env"  => "bash",
    ".properties" => "ini",
    ".service" => "ini",
    ".desktop" => "ini",

    # --- Misc data / docs ---
    ".xml" => "xml",
    ".xsd" => "xml",
    ".xsl" => "xml",
    ".xslt" => "xml",
    ".svg" => "xml",
    ".jsonld" => "json",
    ".ndjson" => "json",
    ".geojson" => "json",

    # --- Special project files ---
    "Makefile" => "makefile",
    "CMakeLists.txt" => "cmake",
    "Gemfile" => "ruby",
    "Rakefile" => "ruby",
    "requirements.txt" => "text",
    "package.json" => "json",
    "Cargo.toml" => "toml",
    "Cargo.lock" => "toml",
    "Project.toml" => "toml",
    "Manifest.toml" => "toml",
)

function _getlang(path)
    # test ext
    _, ext = splitext(path)
    lang = get(EXT_LANG_MAP, ext, "")
    isempty(lang) || return lang
    
    # test basename
    name = basename(path)
    lang = get(EXT_LANG_MAP, name, "")
    isempty(lang) || return lang

    return lang
end