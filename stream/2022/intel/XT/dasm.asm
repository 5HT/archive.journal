
       global _main
       default  rel
       section .text

%define syscall_exit    0x2000001
%define syscall_write   0x2000004
%define syscall_open    0x2000005
%define syscall_close   0x2000006

_main: mov qword [machine.ptr], 1
       call show_pointer
       call parse_mod_rm
       mov rsi, inst0
       mov rcx, 7
loop1: mov rax, [rsi+8]
       push rsi
       push rcx
       call [rsi]
       pop rcx
       pop rsi
       mov al, 16
       add rsi, rax
       dec ecx
       jnz loop1

;       hand made fold
;
;       call show_pointer
;       mov qword [machine.ptr], 2
;       mov qword [inst0_3], 1
;       call print_mov
;       mov rax, [inst0_1]
;       call print_rm                ; [ ADDR
;       mov rax, [inst0_3]
;       call print_hex_string
;       call closesq
;       call printcomma
;       mov rax, [inst0_2]
;       call print_reg               ; print REG
;       call println

       mov rax, 0x2000001 ; exit
       xor rdi, rdi
       syscall
       ret

closesq:
       mov rsi, rmter
       mov rdx, rmter.len
       mov rax, syscall_write ; print ]
       mov rdi, 1
       syscall
       ret

printcomma:
       mov rsi, comma
       mov rdx, comma.len
       mov rax, syscall_write ; print ,
       mov rdi, 1
       syscall
       ret


println:
       mov rsi, linefeed
       mov rdx, linefeed.len
       mov rax, syscall_write ; print \n
       mov rdi, 1
       syscall
       ret

print_rm:
       mov rdi, rax
       shl rdi, 3
       mov rbx, rm
       mov rsi, [rbx+rdi]
       mov rbx, rd
       mov rdx, [rbx+rdi]
       mov rax, syscall_write ; print addr
       mov rdi, 1
       syscall
       ret

show_pointer:
       mov rsi, hex_emiter
       mov rbx, hex
       xor rax, rax
       mov al, byte [machine.ptr]
       and rax, 15
       xlat
       mov [rsi], al
       mov rax, syscall_write ; print int
       mov rsi, pointer
       mov rdx, hex_emiter.len
       mov rdi, 1
       syscall
       ret

print_reg:
       mov rsi, regb
       shl rax, 1
       add rsi, rax
       mov rdx, 2
       mov rax, syscall_write ; print register
       mov rdi, 1
       syscall
       ret

print_mov:
       mov rsi, mov
       mov rdx, mov.len
       mov rax, syscall_write ; print MOV
       mov rdi, 1
       syscall
       ret

parse_mod_rm:
       xor eax, eax
       mov al, [machine.ptr] ; SI=src
       xor ecx, ecx
       mov cl, 3
       mov ebx, eax
       mov edx, eax
       shr ebx, cl
       add ecx, ecx
       shr eax, cl   ; AX=mod
       inc ecx
       and ebx, ecx  ; BX=reg
       and ecx, edx  ; CX=r/m
       mov [inst0_1], cl
       mov [inst0_2], bl
       inc qword [machine.ptr]
       ret

print_hex_string:
       xor edx, edx
       push rax
       mov edx, eax
       mov rdi, hex
       mov rsi, machine
       add rsi, [machine.ptr]
       mov rbp, hexwout
       mov eax, edx
       shl eax, 1
       inc eax
       inc eax
       inc eax
       mov dword [hexwout.len], eax
       dec eax
       add rbp, rax
loop:  mov bl, [rsi]
       and ebx, 15
       mov al, [rbx+rdi]
       mov [rbp], al
       dec rbp
       mov bl, [rsi]
       shr ebx, 4
       and ebx, 15
       mov al, [rbx+rdi]
       mov [rbp], al
       dec rbp
       inc rsi
       dec edx
       jne loop
       pop rdx
       add qword [machine.ptr], rdx
       mov rdx, qword [hexwout.len]
       mov rax, syscall_write ; print hex
       mov rsi, hexwout
       mov rdi, 1
       syscall
       ret

       section .data
hexbout: db '+0xXX'
.len: equ $-hexbout
hexwout: db '+0xXXXXZZYYDDDFFFFFFFFFFFFF'
.len: dq 4
regb:  db "ALCLDLBLAHCHDHBH"
regw:  db "AXCXDXBXSPBPSIDI"
hex:   db '01234567890ABCDEF'
rm000: db '[BX+SI'
.len: equ $-rm000
rm001: db '[BX+DI'
.len: equ $-rm001
rm010: db '[BP+SI'
.len: equ $-rm010
rm011: db '[BP+DI'
.len: equ $-rm011
rm100: db '[SI'
.len: equ $-rm100
rm101: db '[DI'
.len: equ $-rm101
rm110: db '[BP'
.len: equ $-rm110
rm111: db '[BX'
.len: equ $-rm111
rmter: db ']'
.len: equ $-rmter
comma: db ','
.len: equ $-comma
linefeed: db 10
.len: equ $-linefeed
inst0:    dq print_mov
          dq 0
          dq print_rm
inst0_1:  dq 0
          dq print_hex_string
inst0_3:  dq 2
          dq closesq
          dq 0
          dq printcomma
          dq 0
          dq print_reg
inst0_2:  dq 0
          dq println
          dq 0
inst0_p:  dq 0

rm:    dq rm000,     rm001,     rm010,     rm011,     rm100,     rm101,     rm101,     rm110,     rm111
rd:    dq rm000.len, rm001.len, rm010.len, rm011.len, rm100.len, rm101.len, rm101.len, rm110.len, rm111.len
machine: db 0x00, 0b10111111, 0x13, 0x90, 0x91
.ptr: dq 0
mov: db 'MOV '
.len: equ $-mov
pointer:   db 'Pointer: '
hex_emiter:  db 0, 10
.len:  equ $-pointer
str:   db "SYNRC DASM",10
.len:  equ $-str
