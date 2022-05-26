
                global _main
                default  rel
                section .text

%define syscall_exit    0x2000001
%define syscall_write   0x2000004
%define syscall_open    0x2000005
%define syscall_close   0x2000006

_main:          mov rsi, [machine.ptr]
                xor rdx, rdx
                xor rbx, rbx
                inc qword [machine.ptr]
                mov bl, [rsi]
                shl rbx, 4
                mov rsi, opcodes
                mov rdx, [rsi+rbx+8]
                mov rdi, [rsi+rbx] ; instx: 0,0,1,0,2,0,..
line:           push rsi
                push rdi
                push rdx
                xor rbx, rbx
                mov bl, byte [rdi]
                shl bl, 3
                mov rsi, ropes
                mov al, [rdi+1] ; rope args
                add rsi, rbx    ; rope arrd
                call [rsi]
                pop rdx
                pop rdi
                pop rsi
                add rdi, 2
                dec rdx
                jnz line
                call eol
                dec qword [display.ptr]
                jnz _main
                mov rax, 0x2000001 ; exit
                xor rdi, rdi
                syscall
                ret

; rope 0
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
                push rdi
                push rsi
                mov rsi, inst0
                mov rdi, inst1
;                     0     1     2     3     4     5     6     7
                ;  0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15
;inst0:         db 0, 0, 1, 0, 2, 0, 3, 0, 4, 2, 5, 0, 6, 0, 7, 0
;inst1:         db 0, 0, 1, 0, 6, 0, 5, 0, 2, 0, 3, 2, 4, 0, 7, 0
                mov [rsi+7], al   ; inst0_3], rax ; mod
                mov [rsi+5], cl   ; inst0_1], rcx ; r/m
                mov [rsi+13], bl  ; inst0_2], rbx ; reg
                mov [rdi+11], al  ; inst1_5], rax ; mod
                mov [rdi+9], cl   ; inst1_2], rcx ; r/m
                mov [rdi+5], bl   ; inst1_1], rbx ; reg
                pop rsi
                pop rdi
                inc qword [machine.ptr]
                ret
; rope 1
print_add:
                mov rsi, add
                mov rdx, 4
                call write
                ret
; rope 2
print_rm:
                mov rdi, rax
                shl rdi, 3
                mov rbx, rm
                mov rsi, [rbx+rdi]
                mov rbx, rd
                mov rdx, [rbx+rdi]
                call write
                ret
; rope 3
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
; rope 4
brace:          mov rsi, rmter
                mov rdx, 1
                call write
                ret
; rope 5
comma:          mov rsi, com
                mov rdx, 1
                call write
                ret
; rope 6
print_reg:
                mov rsi, regb
                shl rax, 1
                add rsi, rax
                mov rdx, 2
                call write
                ret
; rope 7
eol:            mov rsi, linefeed
                mov rdx, 1
                call write
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

dump:           push rax
                push rdi
                call print_hex
                pop rdi
                pop rax
                sub qword [machine.ptr], rax
                ret

write:          mov rax, syscall_write ; print ]
                mov rdi, 1
                syscall
                ret

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
inst1:          db 0, 0, 1, 0, 6, 0, 5, 0, 2, 0, 3, 2, 4, 0, 7, 0
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
