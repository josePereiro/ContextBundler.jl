# Table of Content
- #Feature
- Add a table of content at the begning of the files
- This might help AI to grasp all present files

# Glob.jl
- Add Posix-compliant file name pattern matching
- Use on config `include`/`exclude` etc...

# Ordering
- Concatenate files in alphabetic order
- Collect all paths and them concatenate

# Dry-run
- Print into console

# Config File
- Must accept conmments

# Dicovery system
Great, now I want you to make the `collect paths` system:
- Assumes that there is a `root.paths` configuration that contain a vector of paths
- It must `walkdir` each root collecting the paths of all matching notes
- A note is a match if
- pass a `name` filter


