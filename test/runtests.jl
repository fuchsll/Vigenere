using Test
using Vigenere

@testset "Vigenere" begin

    @testset "known examples" begin
        @test encrypt("ATTACKATDAWN", "LEMON") == "LXFOPVEFRNHR"
        @test decrypt("LXFOPVEFRNHR", "LEMON") == "ATTACKATDAWN"
        @test encrypt("Hello, World!", "key") == "Rijvs, Uyvjn!"
    end

    @testset "round trip" begin
        for (msg, key) in [("Hello, World!", "key"),
                           ("ATTACK AT DAWN", "LEMON"),
                           ("zzz ZZZ", "b"),
                           ("a", "verylongkeyword")]
            @test decrypt(encrypt(msg, key), key) == msg
        end
    end

    @testset "capitalization and non-letters" begin
        @test encrypt("aBc", "b") == "bCd"          # case kept
        @test encrypt("1, 2; 3!", "abc") == "1, 2; 3!"  # nothing to shift
        @test encrypt("äöü ß", "abc") == "äöü ß"    # umlauts unchanged
        # non-letters do not advance the key:
        @test encrypt("a b", "bc") == "b d"
    end

    @testset "key handling" begin
        @test encrypt("abc", "BBB") == encrypt("abc", "bbb")   # key case irrelevant
        @test encrypt("abc", "b-b 1") == encrypt("abc", "bb")  # junk in key ignored
        @test_throws ArgumentError encrypt("abc", "")
        @test_throws ArgumentError encrypt("abc", "123")
    end

    @testset "helpers" begin
        @test Vigenere.shift_char('Z', 'B', Encrypt()) == 'A'  # wrap forward
        @test Vigenere.shift_char('A', 'B', Decrypt()) == 'Z'  # wrap backward
        @test !Vigenere.is_ascii_letter('ä')
        @test !Vigenere.is_ascii_letter('\u212A')              # Kelvin sign
    end

    @testset "process_rows / show_process" begin
        rows = process_rows("ATTACK AT DAWN", "LEMON")
        @test rows.key == "LEMONL EM ONLE"
        @test rows.result == "LXFOPV EF RNHR"
        @test length(rows.message) == length(rows.key) == length(rows.result)

        io = IOBuffer()
        show_process(io, "AB", "B")
        @test String(take!(io)) == "Message: AB\nKey:     BB\nResult:  BC\n"
    end
end