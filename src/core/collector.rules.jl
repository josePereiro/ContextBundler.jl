struct Rule
    id::String
    type::String
    cargo::Dict{String,Any}
end

struct MatchStack
    path::String
    matches::Vector{Bool}
    rules::Vector{Rule}
    comments::Vector{String}
end


#=
Example rule definition:
```json
{
    "id": "skip.folders.1",
    "type": "exclude",
    "asserts": {
        "isdir": true
    },
    "path.patterns": {
        "globs": [
            "dev",
            "**/dev",
            ".git",
            "**/.git",
            "_DEPRECATED",
            "**/_DEPRECATED",
            ".vscode",
            "**/.vscode"
        ]
    }
}
```
=#

function parse_rule(raw::Dict)

    # meta
    id = get(raw, "id", "")
    rtype = getindex(raw, "type")
    
    # cargo
    cargo = get(raw, "cargo", Dict{String,Any}())

    asserts = get(raw, "asserts", Dict{String,Any}())
    cargo["asserts.isdir"] = get(asserts, "isdir", false)
    cargo["asserts.isfile"] = get(asserts, "isfile", false)
    cargo["asserts.islink"] = get(asserts, "islink", false)
    cargo["asserts.exists"] = get(asserts, "exists", false)
    
    path_patterns = get(raw, "path.patterns", Dict{String,Any}())
    raw_globs = get(path_patterns, "globs", String[])
    cargo["path.patterns.globs"] = raw_globs
    cargo["path.patterns.globs.parsed"] = [Glob.FilenameMatch(g) for g in raw_globs]

    # construct rule
    return Rule(id, rtype, cargo)
end

function parsed_rules(rules::Vector)
    parsed = Vector{Rule}()
    for rule in rules
        rule = parse_rule(rule)
        push!(parsed, rule)
    end
    return parsed
end

function parsed_rules()
    raw_rules = get(CXB_SETTINGS, "collector.rules", [])
    return parsed_rules(raw_rules)
end

# 
function match_rules(path::String, rules::Vector{Rule}; 
        idxs = eachindex(rules), 
        match_target = -1
    )
    # TODO: we know the final size of the vectors (lenght[rules])
    _matches = Vector{Bool}()
    _rules = Vector{Rule}()
    _comments = Vector{String}()

    for idx in idxs
        
        matched = false
        rule = rules[idx]
        cmt = "unmatched"

        # check asserts
        if get(rule.cargo, "asserts.isdir", false)
            if !isdir(path)
                cmt = "failed asserts.isdir"
                @goto DONE
            end
        end
        if get(rule.cargo, "asserts.isfile", false)
            if !isfile(path)
                cmt = "failed asserts.isfile"
                @goto DONE
            end
        end
        if get(rule.cargo, "asserts.islink", false)
            if !islink(path)
                cmt = "failed asserts.islink"
                @goto DONE
            end
        end

        if get(rule.cargo, "asserts.exists", false)
            if !islink(path)
                cmt = "failed asserts.ispath"
                @goto DONE
            end
        end
        

        # check globs
        globs = get(rule.cargo, "path.patterns.globs.parsed", [])
        for glob in globs
            Glob.ismatch(glob, path) || continue
            matched = true
            cmt = "matched path.patterns.glob '$(glob.pattern)'"
            @goto DONE
        end

        # check name regex
        # TODO: implement

        # check content regex
        # TODO: implement
        
        # -- . -. - -. -. .. .. -.- 
        @label DONE

        push!(_matches, matched)
        push!(_rules, rule)
        push!(_comments, cmt)

        sum(_matches) == match_target && break
    end
    return MatchStack(path, _matches, _rules, _comments)
end

function matchlast_rule(path::String, rules::Vector{Rule})
    return match_rules(path, rules; 
        idxs = reverse(eachindex(rules)), 
        match_target = 1
    )
end


function matchtype(stack::MatchStack)
    isempty(stack.rules) && return
    idx = findlast(stack.matches)
    isnothing(idx) && return
    return stack.rules[idx].type
end

import Base.show
function Base.show(io::IO, stack::MatchStack)
    println(io, "MatchStack(")
    println(io, "  path: $(stack.path)")
    for (i, rule) in enumerate(stack.rules)
        status = stack.matches[i] ? "Matched  " : "UnMatched"
        line = "  [$i] $status | rule.id=$(rule.id), rule.type=$(rule.type), stack.comment=$(stack.comments[i])"
        println(io, line)
    end
    println(io, ")")
end

# function Base.show(io::IO, rule::Rule) 
#     # TODO
#     # print as a JSON
# end