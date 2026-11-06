using Vigenere

print("Message: ")
message = readline()
print("Key word: ")
key = readline()
print("Encrypt (e) or decrypt (d)? [e] ")
mode = lowercase(strip(readline()))
dir = startswith(mode, "d") ? Decrypt() : Encrypt()

println()
try
    show_process(message, key, dir)
catch err
    err isa ArgumentError || rethrow()
    println("Error: ", err.msg)
end