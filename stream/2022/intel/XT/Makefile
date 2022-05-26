default: build+run

build+run: build run

build:
	nasm -f macho64 -o dasm.o dasm.asm
	gcc -fno-pie -o dasm dasm.o

run:
	./dasm

show:
	objdump ./dasm --disassemble-all --x86-asm-syntax=intel
