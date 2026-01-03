# DEPRECATED
# TODO: Update as necessary or remove
# function md_bundle(;
#         cfg = ContextBundler.load_config(), 
#         log = true
#     )

#     _validate_config(cfg; log) || return
#     paths = collect_paths(;cfg, log)
#     lines = md_concat_lines(paths; cfg, log)
    
#     out_mode = get(cfg, "md.output.mode", "file")
    
#     if out_mode == "terminal"
#         for line in lines
#             println(line)
#         end
#     elseif out_mode == "clipboard-text"
#         text = join(lines, "\n")
#         clipboard_text(text; limit=200_000)
#     elseif out_mode == "clipboard-file"
#         base = get(cfg, "__config.base", pwd())
#         md_output_file = get(cfg, "output.path", "~/Documents/context.md")
#         output_path = _canonicalize(md_output_file; base)
#         write_output(output_path, lines; log)
#         clipboard_file(output_path; log)
#     elseif out_mode == "file"
#         base = get(cfg, "__config.base", pwd())
#         md_output_file = get(cfg, "output.path", "ContextBundler.md")
#         output_path = _canonicalize(md_output_file; base)
#         write_output(output_path, lines; log)
#     else
#         log && @error "Unknown out_mode" out_mode
#     end

#     nlines = get(cfg, "print.head.lines", -1)
#     if nlines > 0
#         println()
#         println("head lines: ")
#         len = length(lines)
#         for li in 1:nlines
#             li > len && break
#             println(lines[li])
#         end
#         if nlines < len
#             println("...")
#             println("remaining $(len - nlines) further lines!!!")
#         end
#     end

# end