all: calc

calc: calc.o
	gcc -m32 -Wall -g calc.o -o calc

calc.o: calc.s
	nasm -f elf calc.s -o calc.o

.PHONY: clean
clean:
	rm -f *.o calc

#   nasm -f elf test.s -o test.o && gcc -m32 -g test.o -o test
#	nasm -f elf test.s -l test.lst && gcc -m32 -g test.o -o test