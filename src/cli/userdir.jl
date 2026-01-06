function user_dir()
    root = get(CXB_SETTINGS, "depot.root", homedir())
    joinpath(root, ".ctxbundler")
end

function user_configdir()
    joinpath(user_dir(), "config")
end