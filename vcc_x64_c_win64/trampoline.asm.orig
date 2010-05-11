use64

sub rsp, 0x48
mov [rsp], rcx
mov [rsp + 0x8], rdx
mov [rsp + 0x10], r8
mov [rsp + 0x18], r9
movsd [rsp + 0x20], xmm0
movsd [rsp + 0x28], xmm1
movsd [rsp + 0x30], xmm2
movsd [rsp + 0x38], xmm3
mov rdx, rsp
mov rcx, qword 0xffffffffffffffff ; Object pointer
mov rcx, [rcx]
sub rsp, 0x20
mov rax, qword 0xeeeeeeeeeeeeeeee ; Function pointer
call rax
add rsp, 0x68
ret