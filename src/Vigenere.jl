"""
    Vigenere

Encrypt and decrypt text with the Vigenère cipher.

Capitalization is preserved. Characters that are not letters A-Z/a-z (spaces,
digits, punctuation, umlauts) stay unchanged and do not advance the key.

# Main functions
- [`encrypt`](@ref), [`decrypt`](@ref): transform a message with a key word.
- [`process_rows`](@ref), [`show_process`](@ref): show the working as a textbook table.
"""
module Vigenere

export encrypt, decrypt, process_rows, show_process
export Direction, Encrypt, Decrypt

# ---------------------------------------------------------------- types

"""
    Direction

Abstract supertype of the two cipher directions [`Encrypt`](@ref) and
[`Decrypt`](@ref). Functions dispatch on its subtypes.
"""
abstract type Direction end

"""
    Encrypt()

Marker type: shift letters forward by the key letter.
"""
struct Encrypt <: Direction end

"""
    Decrypt()

Marker type: shift letters backward by the key letter.
"""
struct Decrypt <: Direction end

# ------------------------------------------------------------- helpers

"""
    apply_shift(dir::Direction, pos::Int, shift::Int) -> Int

Combine a letter position `pos` (0-25) with a key shift. Adds the shift for
[`Encrypt`](@ref) and subtracts it for [`Decrypt`](@ref). The result is not
yet wrapped into 0-25.

# Examples
```jldoctest; setup = :(using Vigenere)
julia> Vigenere.apply_shift(Encrypt(), 24, 5)
29

julia> Vigenere.apply_shift(Decrypt(), 24, 5)
19
```
"""
apply_shift(::Encrypt, pos::Int, shift::Int) = pos + shift
apply_shift(::Decrypt, pos::Int, shift::Int) = pos - shift

"""
    is_ascii_letter(c::Char) -> Bool

Return `true` if `c` is one of the letters A-Z or a-z. Letters like ä, ö, ü
or ß are not treated as letters and therefore remain unchanged.

# Examples
```jldoctest; setup = :(using Vigenere)
julia> Vigenere.is_ascii_letter('q')
true

julia> Vigenere.is_ascii_letter('ä')
false
```
"""
is_ascii_letter(c::Char) = ('a' <= c <= 'z') || ('A' <= c <= 'Z')

"""
    clean_key(key::AbstractString) -> Vector{Char}

Return the letters of `key`, dropping everything that is not A-Z/a-z.
Throws an `ArgumentError` if no letter is left.

# Examples
```jldoctest; setup = :(using Vigenere)
julia> String(Vigenere.clean_key("le-mon 2"))
"lemon"
```
"""
function clean_key(key::AbstractString)
    keychars = filter(is_ascii_letter, collect(key))
    isempty(keychars) &&
        throw(ArgumentError("the key must contain at least one letter (A-Z, a-z)"))
    return keychars
end

"""
    shift_char(c::Char, k::Char, dir::Direction) -> Char

Shift the letter `c` by the alphabet position of the key letter `k`, forward
for [`Encrypt`](@ref) and backward for [`Decrypt`](@ref). The capitalization
of `c` is preserved; the case of `k` is irrelevant.

# Examples
```jldoctest; setup = :(using Vigenere)
julia> Vigenere.shift_char('a', 'B', Encrypt()) == 'b'
true

julia> Vigenere.shift_char('Z', 'B', Encrypt()) == 'A'   # wraps around
true

julia> Vigenere.shift_char('A', 'B', Decrypt()) == 'Z'
true
```
"""
function shift_char(c::Char, k::Char, dir::Direction)
    base = isuppercase(c) ? 'A' : 'a'
    shift = lowercase(k) - 'a'
    return base + mod(apply_shift(dir, c - base, shift), 26)
end

# ----------------------------------------------------------- the table

"""
    process_rows(message, key, dir::Direction = Encrypt()) -> NamedTuple

Run the cipher and return the working as three equally long strings
(`message`, `key`, `result`), like a textbook table. The `key` row shows the
repeated key letter under every letter of the message; under characters that
are not letters it holds a space.

# Examples
```jldoctest; setup = :(using Vigenere)
julia> rows = process_rows("ATTACK AT DAWN", "LEMON");

julia> rows.message
"ATTACK AT DAWN"

julia> rows.key
"LEMONL EM ONLE"

julia> rows.result
"LXFOPV EF RNHR"
```
"""
function process_rows(message::AbstractString, key::AbstractString,
                      dir::Direction = Encrypt())
    keychars = clean_key(key)
    keyrow = Char[]
    result = Char[]
    j = 0                                   # 0-based position in the key
    for c in message
        if is_ascii_letter(c)
            k = keychars[j + 1]
            push!(keyrow, k)
            push!(result, shift_char(c, k, dir))
            j = mod(j + 1, length(keychars))
        else
            push!(keyrow, ' ')
            push!(result, c)
        end
    end
    return (message = String(message), key = String(keyrow), result = String(result))
end

"""
    show_process([io::IO,] message, key, dir::Direction = Encrypt())

Print the three rows of [`process_rows`](@ref) with labels to `io`
(default `stdout`). Returns `nothing`.

# Examples
```jldoctest; setup = :(using Vigenere)
julia> show_process("ATTACK AT DAWN", "LEMON")
Message: ATTACK AT DAWN
Key:     LEMONL EM ONLE
Result:  LXFOPV EF RNHR
```
"""
function show_process(io::IO, message::AbstractString, key::AbstractString,
                      dir::Direction = Encrypt())
    rows = process_rows(message, key, dir)
    println(io, "Message: ", rows.message)
    println(io, "Key:     ", rows.key)
    println(io, "Result:  ", rows.result)
    return nothing
end

show_process(message::AbstractString, key::AbstractString, dir::Direction = Encrypt()) =
    show_process(stdout, message, key, dir)

# ------------------------------------------------------------ public API

"""
    encrypt(message, key) -> String

Encrypt `message` with the Vigenère cipher using the key word `key`.
Capitalization is kept; non-letters are left unchanged.

# Examples
```jldoctest; setup = :(using Vigenere)
julia> encrypt("ATTACK AT DAWN", "LEMON")
"LXFOPV EF RNHR"

julia> encrypt("Hello, World!", "key")
"Rijvs, Uyvjn!"
```
"""
encrypt(message::AbstractString, key::AbstractString) =
    process_rows(message, key, Encrypt()).result

"""
    decrypt(message, key) -> String

Decrypt a Vigenère-encrypted `message` using the key word `key`. This is the
inverse of [`encrypt`](@ref).

# Examples
```jldoctest; setup = :(using Vigenere)
julia> decrypt("LXFOPV EF RNHR", "LEMON")
"ATTACK AT DAWN"

julia> decrypt(encrypt("Hello, World!", "key"), "key")
"Hello, World!"
```
"""
decrypt(message::AbstractString, key::AbstractString) =
    process_rows(message, key, Decrypt()).result

end # module