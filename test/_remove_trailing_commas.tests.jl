@testset "ContextBundler._remove_trailing_commas" begin
    # Main example with nested arrays/objects and commas in strings
    input = """
    {
    "a": 1,
    "b": [1,2,3,],
    "c": {
        "x": 1,
        "y": 2,
    },
    "d": ["string,with,commas", "ok"],
    "e": [ {"z": 9,}, ],
    "f": {"nested": [1,2,],},
    }
    """

    expected = """
    {
    "a": 1,
    "b": [1,2,3],
    "c": {
        "x": 1,
        "y": 2
    },
    "d": ["string,with,commas", "ok"],
    "e": [ {"z": 9} ],
    "f": {"nested": [1,2]}
    }
    """

    output = ContextBundler._remove_trailing_commas(input)
    @test strip(output) == strip(expected)

    # Should not modify commas inside strings
    s1 = """{"msg": "Hello, world!", "list": [1,2,3,],}"""
    cleaned1 = ContextBundler._remove_trailing_commas(s1)
    @test occursin("Hello, world!", cleaned1)
    @test !occursin(",]", cleaned1)
    @test !occursin(",}", cleaned1)

    # Handles nested empty arrays/objects
    s2 = """{"a": [[],[],], "b": { "c": {}, },}"""
    cleaned2 = ContextBundler._remove_trailing_commas(s2)
    @test !occursin(",]", cleaned2)
    @test !occursin(",}", cleaned2)

    # Should leave plain text unchanged
    s3 = """nothing to change here"""
    @test ContextBundler._remove_trailing_commas(s3) == s3

    # Should handle escaped quotes inside strings
    s4 = """{"path": "C:\\\\Users\\\\", "arr": [1,2,],}"""
    cleaned4 = ContextBundler._remove_trailing_commas(s4)
    @test occursin("C:\\\\Users\\\\", cleaned4)
    @test !occursin(",]", cleaned4)
    @test !occursin(",}", cleaned4)

    # Single-element array/object with trailing commas
    s_min_arr = "[1,]"
    @test ContextBundler._remove_trailing_commas(s_min_arr) == "[1]"

    s_min_obj = """{"a":1,}"""
    @test ContextBundler._remove_trailing_commas(s_min_obj) == """{"a":1}"""

    # CRLF and tabs before closing bracket: ",\r\n\t]"
    s_crlf = "[1,2,3,\r\n\t]"
    cleaned_crlf = ContextBundler._remove_trailing_commas(s_crlf)
    @test cleaned_crlf == "[1,2,3\r\n\t]"

    # Strings with escaped quotes and bracket-like chars should be untouched
    s_esc = """{"t":"brace ] comma , quote \\\" end", "arr":[1,2,],}"""
    cleaned_esc = ContextBundler._remove_trailing_commas(s_esc)
    @test occursin("\"brace ] comma , quote \\\" end\"", cleaned_esc)
    @test !occursin(",]", cleaned_esc)
    @test !occursin(",}", cleaned_esc)

end