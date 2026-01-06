
# Main function to collect paths based on settings rules
# User is responsable for updating the CBX before calling this function
function foreach_matched_paths(
    root::String;
    onskip::Function=_do_nothing,
    oninclude::Function=_do_nothing,
    rules=parsed_rules()
)
    walkdir_ser(root;
        ondir=function (dir)
            # ignore root
            dir == root && return
            # check rules
            stack = matchlast_rule(dir, rules)
            matchtype(stack) == "exclude" || return
            # 
            onskip(dir)
            return :skip
        end,
        onfile=function (file)

            stack = matchlast_rule(file, rules)
            matchtype(stack) == "include" || return

            oninclude(file)
            return
        end,
        verbose=false
    )
end

function collect_paths_lazy(
    roots::Vector;
    onskip::Function=_do_nothing,
    oninclude::Function=_do_nothing,
    rules=parsed_rules()
)
    return Channel{String}() do ch
        for root in roots
            foreach_matched_paths(
                root;
                onskip=onskip,
                oninclude=(path) -> begin
                    put!(ch, path)
                    oninclude(path)
                end,
                rules=rules
            )
        end
    end

end

function collect_paths(
    roots::Vector{String};
    onskip::Function=_do_nothing,
    oninclude::Function=_do_nothing,
    rules=parsed_rules()
)::Vector{String}
    return collect(
        collect_paths_lazy(
            roots;
            onskip=onskip,
            oninclude=oninclude,
            rules=rules
        )
    )
end