
                global _main
                default  rel
                section .text

_main:          mov rsi, [machine.ptr]
                xor rbx, rbx
                inc qword [machine.ptr]
                mov bl, [rsi]
                shl rbx, 4
                mov rsi, opcodes
                mov rdx, [rsi+rbx+8]
                mov rdi, [rsi+rbx]
line:           push rdi
                push rdx
                xor rbx, rbx
                mov bl, [rdi]
                shl bl, 3
                mov rsi, ropes
                mov al, [rdi+1]
                call [rsi+rbx]
                pop rdx
                pop rdi
                add rdi, rax
                shr rax, 1
                sub rdx, rax
                jnz line
                call eol
                dec qword [display.ptr]
                jnz _main
                mov rax, 0x2000001
                xor rdi, rdi
                syscall
                ret
; rope 0
parse_mod_rm:   mov rsi, [machine.ptr]
                mov rdi, opcodes
                mov al, [rsi]
                mov ah, [rsi-1]
                mov bl, ah
                mov cl, 4
                shl ah, cl
                shl bl, cl
                mov rdi, [rdi+rbx]
                dec cl
                mov bl, al
                mov dl, al
                shr bl, cl
                add cl, cl
                shr al, cl
                inc cl
                and bl, cl
                and dl, cl
                or bl, ah
                inc cl
                add cl, cl
                ;
mem:            test bl, cl
                jnz odd
                call from_reg
                jmp quit_rm
odd:            call to_reg
quit_rm:        inc qword [machine.ptr]
                mov rax, 2
                ret
; rope 1
print_add:
                mov rsi, add
                mov dl, 4
                call write
                mov rax, 2
                ret
; rope 2
print_rm:       and rax, 255
                mov rdi, rax
                shl rdi, 3
                mov rbx, rm
                mov rsi, [rbx+rdi]
                mov rbx, rd
                mov dl, [rbx+rdi]
                call write
                mov rax, 2
                ret
; rope 3
print_hex:      push rax
                cmp rax, 0
                jz empty
                xor edx, edx
                mov edx, eax
                mov rdi, hex
                mov rsi, [machine.ptr]
                mov rbp, hexout
                mov eax, edx
                shl eax, 1
                add al, 3
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
                mov rax, syscall_write
                mov rsi, hexout
                mov rdi, 1
                syscall
empty:          pop rdx
                add qword [machine.ptr], rdx
                mov rax, 2
                ret
; rope 4
brace:          mov rsi, rmter
                mov dl, 1
                call write
                mov rax, 2
                ret
; rope 5
comma:          mov rsi, com
                mov dl, 1
                call write
                mov rax, 2
                ret
; rope 6
print_reg:      test al, 16
                jnz w
                mov rsi, regb
                jmp e
w:              mov rsi, regw
e:              and al, 15
                shl al, 1
                add rsi, rax
                mov dl, 2
                call write
                mov rax, 2
                ret
; rope 7
eol:            mov rsi, linefeed
                mov dl, 1
                call write
                mov rax, 2
                ret
; rope 8
from_reg:       mov [rdi+7], al   ; mod
                mov [rdi+13], bl  ; reg
                mov [rdi+5], dl   ; r/m
                ret
; rope 9
to_reg:         mov [rdi+11], al  ; mod
                mov [rdi+5], bl   ; reg
                mov [rdi+9], dl   ; r/m
                ret

show_pointer:   push rax
                mov rsi, hex_emiter
                mov rbx, hex
                and al, 15
                add al, 0x30
                mov [rsi], al
                mov rsi, pointer
                mov rdx, hex_emiter.len
                call write
                pop rax
                ret

dump:           push rax
                push rdi
                call print_hex
                pop rdi
                pop rax
                sub qword [machine.ptr], rax
                ret

write:          mov rax, syscall_write
                mov rdi, 1
                syscall
                ret

                xacquire xacquire lock lock lock cmpxchg BYTE [rdi], cl
                xacquire lock add qword [ss:rsp+0x12345678], 0x12345678
                xacquire lock lwpins rax,[fs:rax+rbx+0x12345678],0x12345678

                section .data

machine:        db 0x00, 0b00100101
                db 0x01, 0b10010011, 0x26, 0x25
                db 0x02, 0b01001110, 0x34
                db 0x03, 0b11101110, 0x76, 0x75, 0x77
                db 0x02, 0b10111111, 0x66, 0x65
                db 0x03, 0b11011101, 0x86, 0x85, 0x88
.ptr:           dq machine

ropes:          dq parse_mod_rm
                dq print_add
                dq print_rm
                dq print_hex
                dq brace
                dq comma
                dq print_reg
                dq eol

opcodes:        dq inst0, 7, inst1, 7, inst2, 7, inst3, 7,
                dq inst4, 7, inst5, 7, inst6, 7, inst7, 7

inst0:          db 0, 0, 1, 0, 2, 0, 3, 0, 4, 0, 5, 0, 6, 0, 7, 0
inst1:          db 0, 0, 1, 0, 6, 0, 5, 0, 2, 0, 3, 0, 4, 0, 7, 0
inst4:          db 7, 0
inst5:          db 7, 0
inst6:          db 7, 0
inst7:          db 7, 0

display:        db '+0x01234567890123456789012345678901'
.ptr:           dq 6

hexout:         db '+0x01234567890123456789012345678901'
.len:           dq 35

regb:           db "ALCLDLBLAHCHDHBH"
regw:           db "AXCXDXBXSPBPSIDI"
hex:            db '01234567890ABCDEF'

rm:             dq rm000, rm001, rm010, rm011, rm100, rm101, rm101, rm110, rm111
rd:             dq rl000, rl001, rl010, rl011, rl100, rl101, rl101, rl110, rl111

rm000:          db '[BX+SI'
rm001:          db '[BX+DI'
rm010:          db '[BP+SI'
rm011:          db '[BP+DI'
rm100:          db '[SI'
rm101:          db '[DI'
rm110:          db '[BP'
rm111:          db '[BX'
rmter:          db ']'
com:            db ','
linefeed:       db 0xa

mov:            db 'MOV '
add:            db 'ADD '
adc:            db 'ADC '

pointer:        db ' Pointer: '
hex_emiter:     db 0, 10
.len:           equ $-pointer

rl000:          equ rm001-rm000
rl001:          equ rm010-rm001
rl010:          equ rm011-rm010
rl011:          equ rm100-rm011
rl100:          equ rm101-rm100
rl101:          equ rm110-rm101
rl110:          equ rm111-rm110
rl111:          equ rmter-rm110

inst2           equ inst0
inst3           equ inst1

syscall_exit    equ 0x2000001
syscall_write   equ 0x2000004
syscall_open    equ 0x2000005
syscall_close   equ 0x2000006

