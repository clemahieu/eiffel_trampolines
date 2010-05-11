use64

sub rsp, 0x60
mov [rsp], rdi
mov [rsp + 0x8], rsi
mov [rsp + 0x10], rdx
mov [rsp + 0x18], rcx
mov [rsp + 0x20], r8
mov [rsp + 0x28], r9
movsd [rsp + 0x30], xmm2
movsd [rsp + 0x38], xmm3
movsd [rsp + 0x40], xmm4
movsd [rsp + 0x48], xmm5
movsd [rsp + 0x50], xmm6
movsd [rsp + 0x58], xmm7
mov rdi, rdi; Object pointer to first parameter
mov rsi, qword 0xdddddddddddddddd ; ivar
mov rax, qword 0xcccccccccccccccc ; object_getIvar
call rax
mov rdi, rax
mov rsi, rsp
mov rdi, [rdi]
mov rax, qword 0xeeeeeeeeeeeeeeee ; Function pointer
call rax
add rsp, 0x60
ret