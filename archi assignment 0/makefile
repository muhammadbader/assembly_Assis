all: exec

libs: asm-lib

asm-lib: do_Str.s
	# flags meanings:
	# -g = debug symbolx
	# -f elf = output format (ELF 32 bit)
	# -o do_Str.o = write assembled file to do_Str.o
	nasm -g -f elf32 -o do_Str.o do_Str.s


exec: main.c libs
	gcc -g -m32 -c -o main.o main.c
	gcc -g -m32  main.o do_Str.o  -o main
	rm main.o do_Str.o 

.PHONY: clean
clean:
	rm -rf ./*.o main