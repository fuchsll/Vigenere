# Vigenere

A small Julia package that encrypts and decrypts text with the
[Vigenère cipher](https://en.wikipedia.org/wiki/Vigen%C3%A8re_cipher),
using only Julia Base.

- Capitalization is preserved.
- Characters that are not letters A-Z/a-z (spaces, digits, punctuation,
  umlauts) stay unchanged and do not advance the key.

## Installation

```
git clone https://github.com/fuchsll/Vigenere.git
cd Vigenere
julia --project=.
```

## Usage

```julia
using Vigenere

encrypt("ATTACK AT DAWN", "LEMON")      # "LXFOPV EF RNHR"
decrypt("LXFOPV EF RNHR", "LEMON")      # "ATTACK AT DAWN"
encrypt("Hello, World!", "key")         # "Rijvs, Uyvjn!"
```

Show the working as a table:

```julia
show_process("ATTACK AT DAWN", "LEMON")
```
```
Message: ATTACK AT DAWN
Key:     LEMONL EM ONLE
Result:  LXFOPV EF RNHR
```

## Interactive script

```
julia --project=. scripts/run.jl
```

## Tests

```julia
using Pkg
Pkg.test()
```

## Design

Encrypting and decrypting differ only in the sign of the shift. This is
implemented with multiple dispatch on the marker types `Encrypt` and
`Decrypt`, so the core code contains no `if` for the direction.