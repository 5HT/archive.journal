
       global _main
       default  rel
       section .text

%define syscall_exit    0x2000001
%define syscall_write   0x2000004
%define syscall_open    0x2000005
%define syscall_close   0x2000006

_main: xor rdx, rdx
       mov rax, 2
       call print_hex
       sub qword [machine.ptr], 2
       mov rbx, [machine.ptr]
       mov dl, byte [rbx]
       inc qword [machine.ptr]
       mov rbx, rdx
       shl rbx, 4
       mov rsi, opcodes
       mov rdx, [rsi+rbx+8]
       mov rdi, [rsi+rbx]
line:  push rsi
       push rdi
       push rdx
       mov al, [rdi+8] ; call rope chain
       call [rdi]
       pop rdx
       pop rdi
       pop rsi
       add rdi, 16
       dec rdx
       jnz line
       call println
       dec qword [display.ptr]
       jnz _main
       mov rax, 0x2000001 ; exit
       xor rdi, rdi
       syscall
       ret

parse_mod_rm:
       xor rax, rax
       mov al, [machine.ptr] ; SI=src
       xor rcx, rcx
       mov cl, 3
       mov rbx, rax
       mov rdx, rax
       shr rbx, cl
       add rcx, rcx
       shr rax, cl   ; AX=mod
       inc rcx
       and rbx, rcx  ; BX=reg
       and rcx, rdx  ; CX=r/m
       mov [inst0_1], rcx
       mov [inst0_2], rbx
       mov qword [inst0_3], 2 ;rdx
       inc qword [machine.ptr]
       ret

write:
       mov rax, syscall_write ; print ]
       mov rdi, 1
       syscall
       ret

closesq:
       mov rsi, rmter
       mov rdx, rmter.len
       call write
       ret

comma:
       mov rsi, com
       mov rdx, com.len
       call write
       ret

println:
       mov rsi, linefeed
       mov rdx, linefeed.len
       call write
       ret

print_rm:
       mov rdi, rax
       shl rdi, 3
       mov rbx, rm
       mov rsi, [rbx+rdi]
       mov rbx, rd
       mov rdx, [rbx+rdi]
       call write
       ret

print_reg:
       mov rsi, regb
       shl rax, 1
       add rsi, rax
       mov rdx, 2
       call write
       ret

print_add:
       mov rsi, add
       mov rdx, add.len
       call write
       ret

print_hex:
       xor rdx, rdx
       push rax
       mov rdx, rax
       mov rdi, hex
       mov rsi, [machine.ptr]
       mov rbp, hexout
       mov rax, rdx
       shl rax, 1
       inc rax
       inc rax
       inc rax
       mov qword [hexout.len], rax
       dec rax
       add rbp, rax
pair:  mov bl, [rsi]
       and rbx, 15
       mov al, [rbx+rdi]
       mov [rbp], al
       dec rbp
       mov bl, [rsi]
       shr rbx, 4
       and rbx, 15
       mov al, [rbx+rdi]
       mov [rbp], al
       dec rbp
       inc rsi
       dec rdx
       jne pair
       pop rdx
       add qword [machine.ptr], rdx
       mov rdx, qword [hexout.len]
       mov rax, syscall_write ; print hex
       mov rsi, hexout
       mov rdi, 1
       syscall
       ret

       section .data

machine: db 0x00, 0x81, 0x18, 0x19
         db 0x01, 0x83, 0x14, 0x20
         db 0x02, 0x83, 0x66, 0x65
.ptr:    dq machine

hexout: db '+0x01234567890123456789012345678901'
.len: dq 35

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
com: db ','
.len: equ $-com
linefeed: db 10
.len: equ $-linefeed

rm: dq rm000,     rm001,     rm010,     rm011,     rm100,     rm101,     rm101,     rm110,     rm111
rd: dq rm000.len, rm001.len, rm010.len, rm011.len, rm100.len, rm101.len, rm101.len, rm110.len, rm111.len

inst3:
inst2:
inst1:
inst0:    dq parse_mod_rm
inst0_4:  dq 0
          dq print_add
          dq 0
          dq print_rm
inst0_1:  dq 0
          dq print_hex
inst0_3:  dq 0
          dq closesq
          dq 0
          dq comma
          dq 0
          dq print_reg
inst0_2:  dq 0
          dq println
          dq 0

inst4:    dq println
          dq 0

inst5:    dq println
          dq 0

inst6:    dq println
          dq 0

inst7:    dq println
          dq 0

display: db 0
.ptr: dq 3

opcodes: dq inst0
         dq 7
         dq inst1
         dq 6
         dq inst2
         dq 5
         dq inst3
         dq 4
         dq inst4
         dq 3
         dq inst5
         dq 2
         dq inst6
         dq 1
         dq inst7
         dq 0

mov: db ' MOV '
.len: equ $-mov

add: db ' ADD '
.len: equ $-add

adc: db ' ADC '
.len: equ $-adc

pointer:   db 'Pointer: '
hex_emiter:  db 0, 10
.len:  equ $-pointer

