"""
    clipboard_file(path::AbstractString)

Copy a *file reference* for `path` to the system clipboard.

macOS  : uses AppleScript (osascript)
Windows: uses PowerShell + System.Windows.Forms Clipboard (STA)
Linux  : uses `wl-copy` or `xclip` with GNOME-compatible MIME;
         falls back to text/uri-list if needed.
"""
function clipboard_file(path::AbstractString; 
        log::Bool=true
    )
    try
        if Sys.isapple()
            _clipboard_file_macos(path)
        elseif Sys.iswindows()
            _clipboard_file_windows(path)
        else
            _clipboard_file_linux(path)
        end
        log && @info "Copied file reference to clipboard." path=abspath(path)
        return
    catch err
        log && @error "Failed to copy file reference to clipboard." path=abspath(path) exception=(err, catch_backtrace())
        rethrow()
    end
end


# ---------------- macOS ----------------

function _clipboard_file_macos(path::AbstractString)
    # Escape embedded double-quotes for AppleScript
    p = replace(abspath(path), "\"" => "\\\"")
    cmd = `osascript -e "set the clipboard to POSIX file \"$(p)\""`
    # For some reason this command fail to do anything...
    # just repeating it a few times
    for _ in 1:3
        run(cmd)
    end
end

# ---------------- Windows ----------------

function _clipboard_file_windows(path::AbstractString)
    # PowerShell single-quoted strings escape single quotes by doubling them
    p = replace(abspath(path), "'" => "''")
    ps = """
    $ErrorActionPreference='Stop';
    Add-Type -AssemblyName System.Windows.Forms;
    $files = New-Object System.Collections.Specialized.StringCollection;
    $null = $files.Add('$p');
    [System.Windows.Forms.Clipboard]::SetFileDropList($files);
    """
    # Use -STA for Clipboard APIs
    run(`powershell -NoProfile -STA -Command $ps`)
end

# ---------------- Linux / *nix ----------------

# Minimal percent-encoding for URIs (spaces are the common culprit).
# This keeps it simple and dependency-free.
function _to_file_uri(p::AbstractString)
    # RFC 8089 style "file://<abs path>"; do a light encode of spaces and `#`/`%`
    q = replace(p, "%" => "%25", " " => "%20", "#" => "%23")
    return "file://$q"
end

function _have(cmd::AbstractString)
    return Sys.which(cmd) !== nothing
end

function _clipboard_file_linux(path::AbstractString)
    abs = abspath(path)
    uri = _to_file_uri(abs)

    # GNOME (and many others) recognize "x-special/gnome-copied-files"
    # with a header line "copy" followed by file:// URIs (one per line).
    gnome_payload = "copy\n$uri\n"
    uri_list      = "$uri\n"

    if _have("wl-copy")
        # Prefer Wayland clip. Try GNOME-specific type first; fall back to text/uri-list.
        try
            open(`wl-copy --type x-special/gnome-copied-files`, "w") do io
                write(io, gnome_payload)
            end
            return
        catch
            open(`wl-copy --type text/uri-list`, "w") do io
                write(io, uri_list)
            end
            return
        end
    elseif _have("xclip")
        # X11 clip. Same strategy: GNOME type, then text/uri-list.
        try
            open(`xclip -selection clipboard -t x-special/gnome-copied-files`, "w") do io
                write(io, gnome_payload)
            end
            return
        catch
            open(`xclip -selection clipboard -t text/uri-list`, "w") do io
                write(io, uri_list)
            end
            return
        end
    else
        error("Need `wl-copy` (Wayland) or `xclip` (X11) to copy file references on Linux.")
    end
end
