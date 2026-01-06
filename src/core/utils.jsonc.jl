function _remove_trailing_commas(text::AbstractString)
    out = IOBuffer()
    in_string = false
    escape = false
    stack = Char[]   # track brackets just for context
    
    i = firstindex(text)
    n = lastindex(text)
    while i <= n
        c = text[i]
        
        if in_string
            write(out, c)
            if escape
                escape = false
            elseif c == '\\'
                escape = true
            elseif c == '"'
                in_string = false
            end
        else
            if c == '"'
                in_string = true
                write(out, c)
            elseif c in ('[', '{')
                push!(stack, c)
                write(out, c)
            elseif c in (']', '}')
                # before writing closing bracket, check if there is a trailing comma
                pos = position(out)
                if pos > 1
                    data = String(take!(out))
                    # remove a comma followed only by spaces/tabs/newlines before the closing bracket
                    data = replace(data, r",([\s\r\n]*)$" => s"\1")
                    write(out, data)
                end
                if !isempty(stack)
                    pop!(stack)
                end
                write(out, c)
            else
                write(out, c)
            end
        end
        i = nextind(text, i)
    end
    
    return String(take!(out))
end

# Keep only non-comment lines from an iterator of lines.
# - Full-line comments are those matching ^\s*//
# - Inline comments are NOT handled (intentionally ignored)
# - On the first line, strip UTF-8 BOM if present; skip shebangs (#!)
function _read_non_commented_lines(lines)
    out = String[]
    first_line = true
    for line in lines
        if first_line
            first_line = false

            # Strip UTF-8 BOM (U+FEFF) if present
            # IGNORED BY NOW
            # if !isempty(line) && first(line) == '\ufeff'
            #     line = line[2:end]
            # end

            # Skip shebang as a full-line “meta” comment
            if occursin(r"^\s*#!", line)
                continue
            end
        end

        # Skip full-line // comments (with optional leading whitespace)
        if occursin(r"^\s*//", line)
            continue
        end

        push!(out, line)
    end
    return out
end


function _read_json_with_comments!(
        _cfg::Dict{String,Any}, 
        path::AbstractString
    )

    # I only accept single line comments
    lines_iter = eachline(path; keep=false)
    _lines = _read_non_commented_lines(lines_iter)

    # remove trailing commans
    _text = join(_lines, "\n")
    _text = _remove_trailing_commas(_text)
    
    _raw = JSON3.read(_text, Dict{String, Any})
    for (k, v) in _raw
        _cfg[string(k)] = v
    end
    return _cfg
end