CC		:=	gcc -m32
CC_FLAGS	:=	-Wall -g
ASM		:=	nasm
ASM_FLAGS	:=	-f elf -g
LINK		:=	ld

SRC_DIR		:=	src
OBJ_DIR		:=	obj
LIST_DIR	:=	list
BIN_DIR		:=	bin

all: task1  task2

 #.c/.s compile rules
$(OBJ_DIR)/main_task1Assignment1.o : $(SRC_DIR)/main_task1Assignment1.c
	$(CC) -c $(CC_FLAGS) $(SRC_DIR)/main_task1Assignment1.c -o $(OBJ_DIR)/main_task1Assignment1.o

$(OBJ_DIR)/asm_task1Assignment1.o : $(SRC_DIR)/asm_task1Assignment1.s
	$(ASM) $(ASM_FLAGS) $(SRC_DIR)/asm_task1Assignment1.s -o $(OBJ_DIR)/asm_task1Assignment1.o 


	#task2
$(OBJ_DIR)/main_task2Assignment1.o : $(SRC_DIR)/main_task2Assignment1.c
	$(CC) -c $(CC_FLAGS) $(SRC_DIR)/main_task2Assignment1.c -o $(OBJ_DIR)/main_task2Assignment1.o 

$(OBJ_DIR)/asm_task2Assignment1.o : $(SRC_DIR)/asm_task2Assignment1.s
	$(ASM) $(ASM_FLAGS) $(SRC_DIR)/asm_task2Assignment1.s -o $(OBJ_DIR)/asm_task2Assignment1.o 


task1: $(OBJ_DIR)/asm_task1Assignment1.o $(OBJ_DIR)/main_task1Assignment1.o
	$(CC) -o $(BIN_DIR)/task1 $(OBJ_DIR)/asm_task1Assignment1.o $(OBJ_DIR)/main_task1Assignment1.o


 task2: $(OBJ_DIR)/main_task2Assignment1.o $(OBJ_DIR)/asm_task2Assignment1.o
 #add your makefile code here...
 #uncomment task2 in section 'all'
	$(CC) -o $(BIN_DIR)/task2 $(OBJ_DIR)/main_task2Assignment1.o $(OBJ_DIR)/asm_task2Assignment1.o
	

clean:
	rm $(BIN_DIR)/* $(OBJ_DIR)/*.o 