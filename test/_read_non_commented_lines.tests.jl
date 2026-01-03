# Helper: build a line iterator from a runtime string (no filesystem I/O)
_make_iter(s::AbstractString) = eachline(IOBuffer(s); keep=false)

function _compressed_lines(lines)
    _text0 = join(lines)
    _text0 = replace(_text0, r"\s" => "")
    return _text0
end


@testset "_read_non_commented_lines (iterator-only, no files)" begin
    # 1) No comments → preserve lines exactly (including leading/trailing blanks)
    content0 = """
    {
      "a": 1,
      "b": 2
    }
    """
    _lines1 = ContextBundler._read_non_commented_lines(_make_iter(content0)) 
    _text1 = _compressed_lines(_lines1)
    _lines0 = split(content0)
    _text0 = _compressed_lines(_lines0)
    @test _text0 == _text1

    # 2) Full-line comments (with/without leading spaces) are dropped
    content0 = """
    // top comment
      // indented comment
    {
      "x": 10
    }
    // trailing comment
    """
    _lines1 = ContextBundler._read_non_commented_lines(_make_iter(content0)) 
    _text1 = _compressed_lines(_lines1)
    _lines0 = ["{", "  \"x\": 10", "}"]
    _text0 = _compressed_lines(_lines0)
    @test _text0 == _text1

    # # 3) Lines with URLs and // inside strings are kept (we ignore inline)
    content0 = """
    {
      "url": "http://example.com",
      "note": "has // but not a comment"
    }
    """
    _lines1 = ContextBundler._read_non_commented_lines(_make_iter(content0))
    _text1 = _compressed_lines(_lines1)
    _lines0 = ["", "{", "  \"url\": \"http://example.com\",", "  \"note\": \"has // but not a comment\"", "}", ""]
    _text0 = _compressed_lines(_lines0)
    @test _text0 == _text1

    # # 4) CRLF + tabs; comments still recognized as full-line and removed
    content0 = join([
        "// comment",
        "{",
        "\t\"k\": 1,",
        "}",
        "// end"
    ], "\r\n")
    _lines1 = ContextBundler._read_non_commented_lines(_make_iter(content0))
    _text1 = _compressed_lines(_lines1)
    _lines0 = ["{", "\t\"k\": 1,", "}"]
    _text0 = _compressed_lines(_lines0)
    @test _text0 == _text1
    
    # 5) Only comments and blanks → only non-comment blanks remain
    content0 = """
    // only comment
    // another
    """
    _lines1 = ContextBundler._read_non_commented_lines(_make_iter(content0))
    _text1 = _compressed_lines(_lines1)
    _lines0 = ["", ""]
    _text0 = _compressed_lines(_lines0)
    @test _text0 == _text1
    
end

