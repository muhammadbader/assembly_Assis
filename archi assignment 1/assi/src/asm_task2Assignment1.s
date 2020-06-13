section    .rodata            ; we define (global) read-only variables in .rodata section
    format_string: db "%s", 0x0a, 0    ; format string
section .bss            ; we define (global) uninitialized variables in .bss section
    an: resb 12        ; enough to store integer in [-2,147,483,648 (-2^31) : 2,147,483,647 (2^31-1)]
    curr: resb 12
section .data
    number: dd 0
    tmp: dd 0
    mod: dd 0
    len: dd 0
section .text
    global convertor
    extern printf

convertor:
    push ebp
    mov ebp, esp
    pushad
    mov ecx, dword [ebp+8]    ; get function argument (pointer to string)
    ; your code comes here...
    cmp byte[ecx],'q'
    je break
    mov eax,an
INITan:
    cmp dword[len],0
    je LOOP
    mov dword[eax],0
    inc eax
    sub dword[len],1
    jmp INITan

LOOP:; loop to calculate the number in decimal
    cmp byte[ecx],0;; null terminated string
    je toHex
    cmp byte[ecx],0x0a;; new line
    je toHex
    mov bl,byte [ecx]
    sub bl,'0'
        ;multiple by 10
    mov eax,10
    mul dword [number]
    add al,bl
    mov [number],eax
    inc ecx
    jmp LOOP
toHex:      
    mov eax,[number]
    mov ebx,an 
LoopHex:; calculate the number in HEX
    mov edx,0;; for safe div in unsigned number;; cdq for safe signed IDIV
    mov ecx,16; to divide with
    DIV ecx; deal with the edx -> dl
    add dword[len],1
    cmp edx,10
    jge AF;;great equal to 10 -> A-F
    add edx,'0'
    mov dword[tmp],edx
    mov dword[number],eax
    jmp shift   
AF:
    add edx,'A'
    sub edx,10
    mov dword[tmp],edx;;to the number to be added
    mov dword[number],eax;;the rest of the input
    jmp shift

check:
    mov eax,dword[number]
    cmp eax,0
    jg LoopHex
    jmp print

shift:; dont touch tmp ecx
    mov ebx,an
    mov edx,curr
    mov ah,0

copy: ;;copy the current ans
    mov al,byte[ebx]
    mov byte[edx],al
    inc ebx
    inc edx
    inc ah
    cmp byte[len],ah
    jne copy
    mov al,byte[tmp] ;insert the new digit
    mov byte[an],al

    ;;restore the ans
    mov ebx,an
    mov edx,curr
    inc ebx
    mov ah,0
copy2:
    mov al,byte[edx]
    mov byte[ebx],al
    inc ebx
    inc edx
    inc ah
    cmp byte[len],ah
    jne copy2
    jmp check

print:
    push an            ; call printf with 2 arguments -
    push format_string    ; pointer to str and pointer to format string
    call printf
    add esp, 8        ; clean up stack after call
 break:
    popad
    mov esp, ebp
    pop ebp
    ret