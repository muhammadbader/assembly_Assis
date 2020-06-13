#format is target-name: target dependencies
#{-tab-}actions

# All Targets
all: ass3

# Tool invocations
# Executable "hello" depends on the files hello.o and run.o.
ass3: ass3.o drone.o scheduler.o printer.o target.o
	gcc -m32 -g -Wall -o ass3 ass3.o drone.o scheduler.o printer.o target.o

ass3.o: ass3.s
	nasm -g -f elf -w+all -o ass3.o ass3.s

drone.o: drone.s
	nasm -g -f elf -w+all -o drone.o drone.s

scheduler.o: scheduler.s
	nasm -g -f elf -w+all -o scheduler.o scheduler.s

printer.o: printer.s
	nasm -g -f elf -w+all -o printer.o printer.s

target.o: target.s
	nasm -g -f elf -w+all -o target.o target.s


#tell make that "clean" is not a file name!
.PHONY: clean

#Clean the build directory
clean: 
	rm -f *.o ass3
