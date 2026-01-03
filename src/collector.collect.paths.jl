
# Main function to collect paths based on settings rules
# User is responsable for updating the CBX before calling this function
function collect_paths(
    root::String;
    onskip::Function = (path)->nothing,
    oninclude::Function = (path)->nothing, 
    paths_depot::Vector{String}=String[]
)

    # load rules from settings
    rules = parsed_rules()

    walkdir_ser(root;
        ondir=function (dir)

            # ignore root
            dir == root && return
            
            stack = matchlast_rule(dir, rules)
            matchtype(stack) == "exclude" || return

            onskip(dir)
            return :skip
        end,
        onfile=function (file)
            stack = matchlast_rule(file, rules)
            matchtype(stack) == "include" || return

            oninclude(file)
            push!(paths_depot, file)
            return
        end,
        verbose=false
    )

    return paths_depot
end