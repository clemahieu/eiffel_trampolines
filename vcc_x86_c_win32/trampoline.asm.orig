use32

mov eax, esp
push eax
mov eax, 0xffffffff ; Object pointer
mov eax, [eax]
push eax
mov eax, 0xeeeeeeee ; Function pointer
call eax
add esp, 0x8
ret