all: exec

exec: ass3.o
	gcc -m32 -Wall -g ass3 ass3.o target.o drone.o printer.o scheduler.o

Ass3.o: ass3.s
	nasm -f elf ass3.s -o ass3.o
	nasm -f elf target .s -o target.o
	nasm -f elf -o drone.o drone.s
	nasm -f elf -o printer.o printer.s
	nasm -f elf -o scheduler.o scheduler.s

.PHONY: clean
clean:
	rm -rf *.o ass3
