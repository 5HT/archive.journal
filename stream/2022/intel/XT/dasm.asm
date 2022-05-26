
                global _main
                default  rel
                section .text

%define syscall_exit    0x2000001
%define syscall_write   0x2000004
%define syscall_open    0x2000005
%define syscall_close   0x2000006

_main:          mov rax, 2
                call print_hex
                sub qword [machine.ptr], 2
                mov rsi, [machine.ptr]
                xor rdx, rdx
                xor rbx, rbx
                inc qword [machine.ptr]
                mov bl, [rsi]
                shl rbx, 4
                mov rsi, opcodes
                mov rdx, [rsi+rbx+8]
                mov rdi, [rsi+rbx]
line:           push rsi
                push rdi
                push rdx
                push rbx
                mov rax, [rdi+8] ; call rope chain
                call [rdi]
                pop rbx
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

parse_mod_rm:   mov rsi, [machine.ptr]
                xor rax, rax
                mov al, [rsi]
                xor rcx, rcx
                mov cl, 3
                mov rbx, rax
                mov rdx, rax
                shr rbx, cl
                add rcx, rcx
                shr rax, cl
                inc rcx
                and rbx, rcx
                and rcx, rdx
                mov qword [inst0_3], rax ; mod
                mov qword [inst0_1], rcx ; r/m
                mov qword [inst0_2], rbx ; reg
                mov qword [inst1_5], rax ; mod
                mov qword [inst1_1], rbx ; reg
                mov qword [inst1_2], rcx ; r/m
                inc qword [machine.ptr]
                ret

write:          mov rax, syscall_write ; print ]
                mov rdi, 1
                syscall
                ret

close:          mov rsi, rmter
                mov rdx, rmter.len
                call write
                ret

comma:          mov rsi, com
                mov rdx, com.len
                call write
                ret

println:        mov rsi, linefeed
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
                push rax
                cmp rax, 0
                jz empty
                xor edx, edx
                mov edx, eax
                mov rdi, hex
                mov rsi, [machine.ptr]
                mov rbp, hexout
                mov eax, edx
                shl eax, 1
                inc eax
                inc eax
                inc eax
                mov qword [hexout.len], rax
                dec eax
                add rbp, rax
pair:           mov bl, [rsi]
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
                jne pair
                mov rdx, qword [hexout.len]
                mov rax, syscall_write ; print hex
                mov rsi, hexout
                mov rdi, 1
                syscall
empty:          pop rdx
                add qword [machine.ptr], rdx
                ret

show_pointer:   mov rsi, hex_emiter
                mov rbx, hex
                and al, 15
                add al, 0x30
                mov [rsi], al
                mov rsi, pointer
                mov rdx, hex_emiter.len
                call write
                ret

       section .data

machine: db 0x00, 0b00100101
         db 0x01, 0b10010011, 0x26, 0x25
         db 0x02, 0b01001110, 0x34
         db 0x03, 0b11101110, 0x76, 0x75, 0x77
         db 0x03, 0b10111111, 0x66, 0x65
         db 0x03, 0b11011101, 0x86, 0x85, 0x88
.ptr: dq machine

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

inst2:
inst0:
          dq parse_mod_rm  ; 0
inst0_0:  dq 0             ; +8
          dq print_add     ; 16
inst0_1:  dq 0             ; 24
          dq print_rm      ; 32
inst0_2:  dq 0             ; +40
          dq print_hex     ; 48
inst0_3:  dq 0             ; +56
          dq close         ; 64
inst0_4:  dq 0             ; 72
          dq comma         ; 80
inst0_5:  dq 0             ; 88
          dq print_reg     ; 96
inst0_6:  dq 0             ; +104
          dq println       ; 112
inst0_7:  dq 0             ; 120

inst3:
inst1:
          dq parse_mod_rm
inst1_0:  dq 0
          dq print_add
inst1_1:  dq 0
          dq print_reg
inst1_2:  dq 0
          dq comma
inst1_3:  dq 0
          dq print_rm
inst1_4:  dq 0
          dq print_hex
inst1_5:  dq 0
          dq close
inst1_6:  dq 0
          dq println
inst1_7:  dq 0

inst4:    dq println
          dq 0

inst5:    dq println
          dq 0

inst6:    dq println
          dq 0

inst7:    dq println
          dq 0

display: db 0
.ptr: dq 6

opcodes: dq inst0
         dq 7
         dq inst1
         dq 7
         dq inst2
         dq 7
         dq inst3
         dq 7
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

pointer:   db ' Pointer: '
hex_emiter:  db 0, 10
.len:  equ $-pointer

