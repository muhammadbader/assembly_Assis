section .bss
    input: resd 80 ;;read the input form the user
    msg: resb 20
    an: resd 1; to save the hex value of the new number
    stack: resd 1
    thenum: resd 80

section .rodata
    one_string: db "%s",0 ;debug
    two_string: db "%X",0x0a,0 ;debug
    numprint: db "%X",0
    newL: db 0x0a,0
    calc: db "calc: ", 0
    error: db "Error: Operand stack Overflow",0x0a,0
    error2: db "Error: Operand stack Empty",0x0a,0
    error3: db "Error: Insifficient stack items",0x0a,0
    error4: db "Error: Unknown symbol",0x0a,0
    ; debug: db "debug",0x0a,0

section .data
    newNumber: dd 0
    oldNumber: dd 0 
    len: dd 0
    odd: db 0
    counter: db 0
    pointer: dd 0
    pointer2: dd 0
    MstackItems: dd 0 ;;saves the items in stack
    maxCapacity: dd 0
    OpNum: dd 0
    carry: dd 0
    debugging: db 0
    todelte: db 0

section .text
    align 16
    global main
    extern printf
    extern fprintf 
    extern fflush
    extern malloc 
    extern calloc 
    extern free 
    ; extern gets 
    extern getchar 
    extern fgets 
    extern stdin

%macro printone 1
    push eax
    push ebx
    push ecx
    push edx
    push %1
    push one_string
    call printf
    add esp, 8
    pop edx
    pop ecx
    pop ebx
    pop eax
%endmacro

%macro printtwo 1
    push eax
    push ebx
    push ecx
    push edx
    push %1
    push two_string
    call printf
    add esp, 8
    pop edx
    pop ecx
    pop ebx
    pop eax
%endmacro

 %macro popPrint 1
    push eax
    push ebx
    push ecx
    push edx
    push %1
    push numprint
    call printf
    add esp,8
    pop edx
    pop ecx
    pop ebx
    pop eax
 %endmacro

 %macro newLine 0
    push eax
    push ebx
    push ecx
    push edx
    push newL
    call printf
    add esp,4
    pop edx
    pop ecx
    pop ebx
    pop eax
%endmacro

%macro reading 0
    push dword[stdin]            ;fgets need 3 param
    push dword 80                   ;max lenght
    push dword input               ;input buffer
    call fgets
    add esp, 12
%endmacro

%macro finish 0
    mov eax,1
    mov ebx,0
    int 0x80
%endmacro

%macro Allocate 1
    push ebx
    push ecx
    push edx
    push %1              ; push amount of bytes malloc should allocate    
    call malloc           ; call malloc
    add esp,4
    test eax, eax          ; check if the malloc failed
    jnz   %%success        ; 
    mov dword[msg],"fail"
    mov dword[msg+4], " all"
    mov dword[msg+8], "ocat"
    mov word[msg+12],"e"
    mov word[msg+14],0x0a
    mov word[msg+16],0
    printone msg
   %%success:
    pop edx
    pop ecx
    pop ebx     
%endmacro

%macro setNext 2 ;; takes the pointer to two params
    mov eax,%1
    mov ecx,%2
    mov dword[eax+1],ecx
%endmacro

%macro freeNode 1 ;; when using give the address of the allocated memory
    push %1
    call free
    add esp,4
%endmacro

%macro freeNumber 1
    push eax
    push ebx
    push ecx
    push edx

    mov eax,%1
%%anotherone:
    mov ebx,dword[eax+1]
    freeNode eax
    mov eax,ebx
    cmp ebx,0
    jne %%anotherone

    pop edx
    pop ecx
    pop ebx
    pop eax
%endmacro

%macro freeStack 0
  %%EmpStack:
    cmp dword[MstackItems],0
    je %%stackF
    MyPop
    freeNumber dword[oldNumber]
    jmp %%EmpStack
  %%stackF:
    freeNode dword[stack]
%endmacro

%macro calculator 0
    push calc
    call printf
    add esp,4
%endmacro

%macro MyPush 1
    inc dword[MstackItems]
    mov eax,dword[stack]
    mov ebx,%1
    mov dword[eax],ebx
%endmacro

%macro MyPop 0
    mov eax,dword[stack]
    mov ebx,dword[eax]
    mov dword[oldNumber],ebx
    dec dword[MstackItems]
    cmp dword[MstackItems],0
    je %%end
    sub dword[stack],4
   %%end:
%endmacro
    
%macro MyPeek 0
    mov eax,dword[stack]
    mov ebx,dword[eax]
    mov dword[pointer],ebx
%endmacro
;;malloc goes like this:

; Allocate
; mov [newNumber],eax;;move the adress to newNumber (4 bytes)
; mov ebx, dword[newNumber];;make ebx point to the first byte in the allocated memory
; mov dword[ebx+1],"muha"
; mov dword[ebx],"muha"
; printone dword[newNumber]
; printone dword[newNumber]
; freeIt dword[newNumber]

main:
    
    mov dword[len],5
    mov ecx,[esp+4]
    cmp ecx,2
    jl default5
    ; printtwo eax
    cmp ecx,3
    je debug
    cmp ecx,2
    je debug2
    mov ecx,[esp+8]
    mov ecx,dword[ecx+4]
    
createNum:
    mov dword[len],0
HEX:
    cmp byte[ecx],0
    je default5 ;; allocate the stack and start the program
    mov eax,dword[len]
    mov ebx,0x10
    mul ebx
    mov dword[len],eax
    cmp byte[ecx],'A'
    jge hexR
    mov edx,0
    mov dl,byte[ecx]
    sub dl,'0'
    add dword[len],edx
    inc ecx
    jmp HEX
hexR:
    mov edx,0
    mov dl,byte[ecx]
    sub dl,'A'
    add dl,10
    add dword[len],edx
    inc ecx
    jmp HEX

default5:
 
    mov eax,dword[len]
    mov ebx,4
    mul ebx
    Allocate eax
    mov dword[stack],eax
    mov eax,dword[len]
    mov dword[maxCapacity],eax   ;; initialization
    mov dword[MstackItems],0           ;;initialization
    
nextRead:   
    mov byte[todelte],0
    calculator
    reading ;; change to check input species
    cmp byte[input],0x0a
    je nextRead
    cmp byte[input],'q'
    je fin
    cmp byte[input],'p'
    je ThePop
    cmp byte[input],'d'
    je duplicate
    cmp byte[input],'&'
    je ANDTWO
    cmp byte[input],'|'
    je ORTWO
    cmp byte[input],'n'
    je HexDigits
    cmp byte[input],'+' ;; problem with the F ==> carry and move on
    je plusOp
    cmp byte[input],'*' ;; problem with the F ==> carry and move on
    je mulOp
    ;;push a number
    mov ecx,dword[maxCapacity]
    cmp dword[MstackItems],ecx   ;;full stack
    jz MstackOverFlow
    cmp byte[debugging],1
    je debugpri
    jmp to_hex
debugpri:
    printone input
    jmp to_hex
    
fin:

end_program:
    freeStack
    printtwo dword[OpNum]
    finish
    nop

debug:
    mov ecx,[esp+8]
    mov ecx,dword[ecx+4]
    ; mov [input],ecx
    cmp byte[ecx],'-'
    je dmode1

    ; printone ecx
    mov ecx,[esp+8]
    mov ecx,dword[ecx+8]
    cmp byte[ecx],'-'
    je dmode2
    ; printone ecx
    jmp createNum
dmode1:
    ; printone eax
    mov byte[debugging],1
    mov ecx,[esp+8]
    mov ecx,dword[ecx+8]
    jmp createNum
dmode2:
    ; printone 0
    mov byte[debugging],1
    mov ecx,[esp+8]
    mov ecx,dword[ecx+4]
    jmp createNum

debug2:
    mov ecx,[esp+8]
    mov ecx,dword[ecx+4]
    ; mov [input],ecx
    cmp byte[ecx],'-'
    jne createNum
    mov byte[debugging],1
    jmp createNum
;;stack Impl
ThePush:
    mov ecx,dword[maxCapacity]
    cmp dword[MstackItems],ecx   ;;full stack
    jz MstackOverFlow
    cmp dword[MstackItems],0     ;;empty stack
    jz FPUSH
    add dword[stack],4
    MyPush dword[oldNumber]
    cmp byte[debugging],1
    je debugpush
    jmp nextRead

FPUSH:
    MyPush dword[oldNumber]
    cmp byte[debugging],1
    je debugpush
    jmp nextRead

debugpush:
    mov byte[todelte],1
    jmp printNumber

MstackOverFlow:
    printone error
    jmp nextRead

ThePop:
    inc dword[OpNum]
    cmp dword[MstackItems],0
    je EmptyMstackError  ;; Empty stack
    MyPop
    jmp printNumber

EmptyMstackError:
    printone error2
    jmp nextRead
Insufficient:
    printone error3
    jmp nextRead

printNumber:
    mov ebx,dword[oldNumber]
    mov dword[pointer],ebx
    mov dword[len],0
    .nextNum:
        mov edx,0
        mov ecx,dword[pointer]
        mov dl, byte[ecx]
        cmp dword[ecx+1],0
        jz .Finaladd
        jmp .addMe
    .nextLink:
        mov eax,dword[ecx+1]
        mov dword[pointer],eax
        jmp .nextNum

    .addMe:
        mov ebx,dword[len]
        mov byte[thenum+ebx],dl
        inc dword[len]
        jmp .nextLink
    .Finaladd:
        mov ebx,dword[len]
        mov byte[thenum+ebx],dl
        mov dx,0
        inc dword[len]
        mov ax,word[len]
        mov bl,4
        div bl
        mov ebx,0
        mov bl,al
        mov byte[len],bl ;; now len stores the bumber of bytes of the number that we need to print
        cmp dword[len],0
        je .conZero1
    .thePrint:
        cmp dword[thenum+4*ebx],0
        je .zeroes
        cmp dword[thenum+4*ebx],0x10
        jl .oneZ
        cmp dword[thenum+4*ebx],0x100
        jl .twoZ
        cmp dword[thenum+4*ebx],0x1000
        jl .threeZ
        cmp dword[thenum+4*ebx],0x10000
        jl .fourZ
        cmp dword[thenum+4*ebx],0x100000
        jl .fiveZ
        cmp dword[thenum+4*ebx],0x1000000
        jl .sixZ
        cmp dword[thenum+4*ebx],0x10000000
        jl .sevenZ
    .conZero1:
        popPrint dword[thenum+4*ebx]
        ; popPrint ebx
    .conZero:
        dec ebx
        cmp ebx,0
        jge .thePrint
        newLine
        mov ebx,0
        mov bl,byte[len]

    .zeroTheNum:
        mov dword[thenum+4*ebx],0
        dec ebx
        cmp ebx,0
        jge .zeroTheNum
        cmp byte[todelte],1
        je nextRead
        freeNumber dword[oldNumber]
        jmp nextRead
        
    .zeroes:
        cmp ebx,0
        jl .conZero
        popPrint 0
        popPrint 0
        popPrint 0
        popPrint 0
        popPrint 0
        popPrint 0
        popPrint 0
        jmp .conZero
    .Zone:
        cmp dword[len],0
        je .conZero1
        cmp ebx,1
        je .conZero1
        popPrint 0
    .Ztwo:
        cmp dword[len],0
        je .conZero1
        cmp ebx,1
        je .conZero1
        popPrint 0
    .Zthree:
        cmp dword[len],0
        je .conZero1
        cmp ebx,1
        je .conZero1
        popPrint 0
    .Zfour:
        cmp dword[len],0
        je .conZero1
        cmp ebx,1
        je .conZero1
        popPrint 0
    .Zfive:
        cmp dword[len],0
        je .conZero1
        cmp ebx,1
        je .conZero1
        popPrint 0
    .Zsix:
        cmp dword[len],0
        je .conZero1
        cmp ebx,1
        je .conZero1
        popPrint 0
    .Zseven:
        cmp dword[len],0
        je .conZero1
        cmp ebx,1
        je .conZero1
        popPrint 0
        cmp dword[thenum+4*ebx],0
        je .conZero
        jmp .conZero1
    .oneZ:
        cmp ebx,0
        jl .conZero
        jmp .Zone
    .twoZ:
        cmp ebx,0
        jl .conZero
        jmp .Ztwo
    .threeZ:
        cmp ebx,0
        jl .conZero
        jmp .Zthree
    .fourZ:
        cmp ebx,0
        jl .conZero
        jmp .Zfour
    .fiveZ:
        cmp ebx,0
        jl .conZero
        jmp .Zfive
    .sixZ:
        cmp ebx,0
        jl .conZero
        jmp .Zsix
    .sevenZ:
        cmp ebx,0
        jl .conZero
        jmp .Zseven

        
;;LinkedList c'tor

errorInput:
    printone error4 ;;delete memory
    jmp nextRead

inputLen:
    cmp byte[ebx],0
    jz finLen
    inc eax
    inc ebx
    jmp inputLen

startZero:
    cmp byte[ebx],'0'
    jnz conti
    cmp byte[ebx],'0'
    jl errorInput
    cmp byte[ebx],'F'
    jg errorInput
    inc ebx
    jmp startZero
to_hex:
    mov ebx,input
    mov eax,0
    jmp inputLen
finLen:
    mov ebx,input;; first of alll we need to know the length of the input
    cmp eax,2
    jle conti
    jmp startZero
conti:
    mov esi,ebx
    cmp byte[ebx],0x0a
    je end_program
    mov dword[len],0
loopS:
    cmp byte[ebx],0x0a
    je isOdd
    inc ebx
    inc dword[len]
    jmp loopS
    
isOdd:
    mov edx,0 ;; for safe division
    mov eax,dword[len]
    mov ecx,2
    DIV ecx
    mov byte[odd],dl;;tells if the length of the numebr is odd or not
    ; cmp byte[odd],1

    mov ebx,esi
    cmp byte[odd],1
    je convertOne
    jmp convertTwo
    ;;if the numebr is odd we will put two numbers in the old number
Sconv:
    mov byte[counter],0
    mov al,0
conv: ;; every new node value is saved in al
    cmp byte[counter],2
    je add_Node
    cmp byte[ebx],0x0a;;new line
    je ThePush  ;;temp jmp--> check first if al==0
    mov dh,16
    mul dh
    cmp byte[ebx],'A'
    jge conv2
    cmp byte[ebx],'9'
    jg errorInput
    mov dl,byte[ebx]
    sub dl,'0'
    add al,dl
    inc ebx
    inc byte[counter]
    ;;multiply by 16
    jmp conv
conv2:
    cmp byte[ebx],'F'
    jg errorInput
    mov dl,byte[ebx]
    sub dl,'A'
    add dl,10
    add al,dl
    inc ebx
    inc byte[counter]
    jmp conv

convertTwo:;;this is hard coded, we can optimize
        mov byte[counter],0
        mov ah,0
        mov al,0;;primary number
    .fir:
        cmp byte[counter],2
        je create_First
        mov dh,16
        mul dh
        cmp byte[ebx],'A'
        jge .hec
        mov dl,byte[ebx]
        sub dl,'0'
        add al,dl
        add ebx,1
        inc byte[counter]
        ;;multiply by 16;; check assigment 1
        jmp .fir
    .hec:
        mov dl,byte[ebx]
        sub dl,'A'
        add dl,10
        add al,dl
        add ebx,1
        inc byte[counter]
        jmp .fir

convertOne:
    mov al,byte[ebx]
    inc ebx
    cmp al, 'A'
    jge HEXone
    sub al,'0'
    ; mov byte[an],dl
    jmp create_First
HEXone:
    sub al,'A'
    add al,10
    ; mov byte[an],dl
    jmp create_First

create_First:
    mov byte[an],al

    Allocate 5
    mov dword[oldNumber],eax ;;give the adress to oldnumber
    mov dl,byte[an]
    mov byte[eax],dl
    mov dword[eax+1],0;; null pointer
    jmp Sconv;;change to Sconv

;;problem: it calls add_Node depending on the input value not on it's length
add_Node: 
    mov byte[an],al
    Allocate 5
    mov dword[newNumber],eax ;;give the adress to newNumber
    setNext dword[newNumber],dword[oldNumber]
    mov ecx,dword[newNumber]
    mov dword[oldNumber],ecx    ;;change the head
    mov dl,byte[an]
    mov byte[ecx],dl
    mov dword[pointer],ecx
    jmp Sconv
    

duplicate:
    inc dword[OpNum]
    cmp dword[MstackItems],0
    je EmptyMstackError  ;; Empty stack
    mov ecx,dword[maxCapacity]
    cmp dword[MstackItems],ecx   ;;full stack
    jz MstackOverFlow
    MyPeek      ;; pointer points to the top of the stack
    Allocate 5
    mov dword[oldNumber],eax ;; the new duplicated number
    mov dword[newNumber],eax
    .dup:       ;; inffinte loop
        mov eax,0
        mov ebx,dword[pointer]
        mov al,byte[ebx]
        mov ebx,dword[newNumber]
        mov byte[ebx],al
        mov eax,dword[pointer]
        cmp dword[eax+1],0
        je .finDup
        Allocate 5
        mov ebx,dword[newNumber]
        mov dword[ebx+1],eax
        mov dword[newNumber],eax
        mov eax,dword[pointer]
        mov ebx,dword[eax+1]
        mov dword[pointer],ebx
        jmp .dup
    .finDup:
        mov eax,dword[newNumber]
        mov dword[eax+1],0
        jmp ThePush     ;;final step => push the duplicated number

ANDTWO:
    inc dword[OpNum]
    cmp dword[MstackItems],2
    jl Insufficient
    MyPop
    mov eax,dword[oldNumber]
    mov dword[newNumber],eax    ;;first link
    push eax         ;;dump variable to free memory
    MyPop                       ;;second link
    mov eax,dword[oldNumber]
    push eax        ;;dump variable to free memory
    Allocate 5
    mov dword[an],eax;;push this
    mov dword[pointer],eax      ;; toAdd link

    .ANDop:
        mov ecx,0
        mov ebx,dword[oldNumber]
        mov cl,byte[ebx]
        mov ebx,dword[newNumber]
        and cl,byte[ebx]
        mov ebx,dword[pointer]
        mov byte[ebx],cl
        mov ebx,dword[oldNumber]
        cmp dword[ebx+1],0
        je .fin
        mov ebx,dword[newNumber]
        cmp dword[ebx+1],0
        je .fin
        Allocate 5
        mov ebx,dword[pointer]
        mov dword[ebx+1],eax
        mov dword[pointer],eax
        mov ebx,dword[newNumber]
        mov ecx,dword[ebx+1]
        mov dword[newNumber],ecx
        mov ebx,dword[oldNumber]
        mov ecx,dword[ebx+1]
        mov dword[oldNumber],ecx
        jmp .ANDop
    .fin:
        mov eax,dword[pointer]
        mov dword[eax+1],0
        mov eax,dword[an]
        mov dword[oldNumber],eax
        pop eax       ;;free before leaving
        freeNumber eax
        pop eax       ;;free before leaving
        freeNumber eax
        jmp ThePush     

ORTWO:
    inc dword[OpNum]
    cmp dword[MstackItems],2
    jl Insufficient
    MyPop
    mov eax,dword[oldNumber]
    mov dword[newNumber],eax
    push eax        ;;dump variable to free memory
    MyPop
    mov eax,dword[oldNumber]
    push eax          ;;dump variable to free memory
    Allocate 5
    mov dword[an],eax;;push this
    mov dword[pointer],eax
    mov dword[carry],"here"

    .ORop:
        mov ecx,0
        mov ebx,dword[oldNumber]
        mov cl,byte[ebx]
        mov ebx,dword[newNumber]
        or cl,byte[ebx]
        mov ebx,dword[pointer]
        mov byte[ebx],cl
        mov ebx,dword[oldNumber]
        cmp dword[ebx+1],0
        je .compNew
        mov ebx,dword[newNumber]
        cmp dword[ebx+1],0
        je .compOld
        Allocate 5
        mov ebx,dword[pointer]
        mov dword[ebx+1],eax
        mov dword[pointer],eax
        mov ebx,dword[newNumber]
        mov ecx,dword[ebx+1]
        mov dword[newNumber],ecx
        mov ebx,dword[oldNumber]
        mov ecx,dword[ebx+1]
        mov dword[oldNumber],ecx
        jmp .ORop
    .compNew:
        mov ebx,dword[newNumber]
        cmp dword[ebx+1],0
        je .fin
        Allocate 5
        mov ebx,dword[pointer]
        mov dword[ebx],eax
        mov dword[pointer],eax
        mov ebx,dword[newNumber]
        mov cl,byte[ebx]
        mov byte[pointer],cl
        jmp .compNew
    .compOld:
        mov ebx,dword[oldNumber]
        cmp dword[ebx+1],0
        je .fin
        Allocate 5
        mov ebx,dword[pointer]
        mov dword[ebx],eax
        mov dword[pointer],eax
        mov ebx,dword[oldNumber]
        mov cl,byte[ebx]
        mov byte[pointer],cl
        jmp .compOld
    .fin:
        mov eax,dword[pointer]
        mov dword[eax+1],0
        mov eax,dword[an]
        mov dword[oldNumber],eax
        pop ebx       ;;free before leaving
        freeNumber ebx
        pop ebx       ;;free before leaving
        freeNumber ebx
        jmp ThePush

;;n operand
HexDigits:
    inc dword[OpNum]
    MyPop
    mov eax,dword[oldNumber]
    push eax      ;;dump variable to free memory
    mov dword[an],0         ;; dword should be enough for a Number Length = 0xFFFFFFFF = 4294967295
    .count:
        mov eax,dword[oldNumber]
        cmp dword[eax+1],0
        je .checkLast
        add dword[an],2
        mov ebx,dword[eax+1]
        mov dword[oldNumber],ebx
        jmp .count
    .checkLast: 
        
        cmp byte[eax],0x10
        jb .one ;; jb = jump if below to perform unsigned comparison
        inc dword[an]
    .one:       
        inc dword[an]
        Allocate 5
        mov dword[newNumber],eax
        mov ebx,eax
        mov eax,dword[an]
        jmp .firstLen
    .innerLength:
        Allocate 5
        mov dword[ebx+1],eax
        mov ebx,eax
        mov eax,dword[an]
    .firstLen:
        mov byte[ebx],al
        mov edx,0
        mov ecx,0x100
        div ecx
        mov dword[an],eax
        cmp eax,0
        jne .innerLength
        mov dword[ebx+1],0
        mov eax,dword[newNumber]
        mov dword[oldNumber],eax
        pop eax
        freeNumber eax       ;;free memory before leaving
        jmp ThePush
        ; jmp nextRead 

plusOp:
    inc dword[OpNum]
    cmp dword[MstackItems],1
    jle EmptyMstackError 
    MyPop;;oldNumber
    MyPeek;; pointer
    mov eax, dword[oldNumber]
    mov dword[len],eax        ;;dump variable to free memory
    mov word[carry],0
    .addByte:
        mov eax,dword[oldNumber]
        cmp dword[eax+1],0
        je .cmp
        mov ebx,dword[pointer]
        cmp dword[ebx+1],0
        je .cmp
        mov cx,0
        mov dx,0
        mov cl,byte[eax]
        mov dl,byte[ebx]
        add cx,dx
        add cx,word[carry]
        mov byte[ebx],cl
        mov byte[carry],ch
        mov ebx,dword[ebx+1];; move next
        mov dword[pointer],ebx
        mov eax,dword[eax+1];;move next
        mov dword[oldNumber],eax
        jmp .addByte

    .cmp:
        mov eax,dword[pointer]
        mov ebx,0
        mov ecx,0
        mov bl,byte[eax]
        mov eax,dword[oldNumber]
        mov cl,byte[eax]
        add bx,cx
        add bx,word[carry]
        mov eax,dword[pointer]
        mov byte[eax],bl
        mov byte[carry],bh
        mov ecx,dword[oldNumber]
        cmp dword[ecx+1],0 ;; next!=null
        jnz .cmpOld
        mov eax,dword[pointer]
        cmp dword[eax+1],0
        je .sameLen
        mov eax,dword[eax+1]

    .updateLink:
        cmp dword[eax+1],0
        je .addLastP
        mov ebx,0
        mov bl,byte[eax]
        add bx,word[carry]
        mov byte[eax],bl
        mov byte[carry],bh
        mov eax,dword[eax+1]    ;; move to the next link
        jmp .updateLink

    .addLastP:
        mov bx,0
        mov bl,byte[eax]
        add bx,word[carry]
        mov byte[eax],bl
        mov byte[carry],bh
    .sameLen:
        cmp byte[carry],0
        je nextRead
        mov ebx,eax
        Allocate 5
        mov dword[ebx+1],eax
        mov cl,byte[carry]
        mov byte[eax],cl
        mov dword[eax+1],0
        freeNumber dword[len]
        jmp nextRead

    .cmpOld:
        mov eax,dword[oldNumber]
        mov ebx,dword[pointer]
        mov ecx,dword[eax+1]
        mov dword[ebx+1],ecx
        mov dword[eax+1],0
        mov eax,dword[ebx+1]
        jmp .updateLink

checkNumbers:
    mov eax,dword[pointer]
    cmp dword[eax+1],0
    je checkZero
secondCheck:
    mov eax,dword[oldNumber]
    cmp dword[eax+1],0
    je checkZero2
    jmp mulByte

checkZero:
    cmp byte[eax],0
    je zero
    jmp secondCheck
checkZero2:
    cmp byte[eax],0
    je zero
    jmp mulByte
zero:
    mov eax,dword[newNumber]
    mov byte[eax],0
    mov dword[eax+1],0
    push eax
    freeNumber eax
    push eax
    freeNumber eax
    jmp nextRead

mulOp:
    inc dword[OpNum]
    cmp dword[MstackItems],1
    jle EmptyMstackError 
    MyPop;;pointer
    mov eax,dword[oldNumber]
    mov dword[pointer],eax;; ref
    mov dword[pointer2],eax
    MyPop;; oldNumber
    push dword[oldNumber] ;; dump variable to memory free
    push dword[pointer]
    Allocate 5
    mov dword[newNumber],eax
    mov dword[eax+1],0
    MyPush dword[newNumber]
    mov ebx,dword[newNumber]
    mov dword[len],ebx ;;ref
    mov dword[ebx+1],0
    mov byte[ebx],0
    mov dword[carry],0
    jmp checkNumbers;; if one of them is ZERO

mulByte:;; pointer2 is the running variable
    mov eax,0
    mov ecx,dword[pointer2]
    mov al,byte[ecx]
    mov ecx,dword[oldNumber]
    mov cl,byte[ecx]
    mul cl
    mov cl,ah
    mov ah,0
    mov ebx,dword[newNumber];; the mul result
    add al,byte[ebx]
    add ax,word[carry]
    mov byte[ebx],al
    mov byte[carry],cl;;the mul carry
    add byte[carry],ah;; the last add carry
    mov ecx,dword[pointer2]
    cmp dword[ecx+1],0
    je finishLine;;move to the next node in oldNumber
    mov ecx,dword[ecx+1];;go to the next node
    mov dword[pointer2],ecx
    cmp dword[ebx+1],0
    je createnewOne
    mov ebx,dword[ebx+1]
    mov dword[newNumber],ebx;;next result node
    jmp mulByte

createnewOne:
    Allocate 5
    mov dword[ebx+1],eax
    mov dword[eax+1],0
    mov ebx,dword[ebx+1]
    mov dword[newNumber],ebx;;next result node
    jmp mulByte

finishLine:;;reached the end of pointer2
    ;;last oldNumber
    mov ecx,dword[oldNumber]
    cmp dword[ecx+1],0
    jne NotFinally
car:
    ; printtwo dword[carry]
    cmp byte[carry],0
    je finally_finally
    
    mov ebx,dword[newNumber]
    
    cmp dword[ebx+1],0
    jne NotanotherNode
    Allocate 5
    mov dword[ebx+1],eax
    mov dword[eax+1],0
    mov bl,byte[carry]
    mov byte[eax],bl
    jmp finally_finally
NotanotherNode:
    mov ebx,[ebx+1]
    mov ax,0
    mov al,byte[ebx]
    add ax,word[carry]
    mov byte[ebx],al
    mov byte[carry],ah
    jmp car

finally_finally:
    pop eax
    freeNumber eax
    pop eax
    freeNumber eax 
    jmp nextRead

NotFinally:;; in case the oldNumber did not finish but the pointer 2 finished
    mov ecx,dword[oldNumber]
    mov ecx,[ecx+1]
    mov dword[oldNumber],ecx
    mov ecx,dword[pointer]
    mov dword[pointer2],ecx
    mov ecx,dword[len];;moving the result one byte
    cmp dword[ecx+1],0
    je newNode
doneNew:
    mov ecx,dword[ecx+1]
    mov dword[len],ecx
    mov dword[newNumber],ecx
    mov dword[carry],0
    jmp mulByte

newNode:
    Allocate 5
    mov dword[ecx+1],eax
    mov dword[eax+1],0
    jmp doneNew

;; hello fuckers
