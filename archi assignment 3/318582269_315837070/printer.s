        global printer
        extern resume,head,x_target_scaled,y_target_scaled 
section .bss
        align 16 
        temp:		resb 1
        
section .rodata
    format_string: db "%s", 10,0	; format string
    format_int: db "%u,", 0,0	; format string
    format_int2: db "%u", 0,0	; format string
    format_float: db "%.2f,", 0, 0
    format_float2: db "%.2f", 0, 0
        
section .data
savebx: dd 0
x1: dq 0
a1: dq 1
a2: dq 2
a3: dq 3
a4: dq 4



section .text
extern printf
extern putchar
printer:
    push ebx
    mov ebx, head                        ; Address of the first element
    push eax
    pop eax
    push dword[x_target_scaled+4]
    push dword[x_target_scaled]
    push format_float
    call printf
    push dword[y_target_scaled+4]
    push dword[y_target_scaled]
    push format_float2
    call printf
    push dword 10
    call putchar
   next_char:
    mov dword[savebx],ebx
    mov edx,dword [ebx]
    fstp qword[x1]
    cmp edx, 0
    je hoon
    push dword [ebx]
    push format_int
    call printf
    mov ebx,dword[savebx]

    fld qword [ebx + 4]
    sub esp,8
    fstp qword[esp]
    push format_float
    call printf
     
     
    add esp,8
    mov ebx,dword[savebx]
    fld qword [ebx + 12]
    sub esp,8
    fstp qword[esp]
    push format_float
    call printf
    add esp,8

    mov ebx,dword[savebx]
    fld qword [ebx + 20]
    sub esp,8
    fstp qword[esp]
    push format_float
    call printf
    

    add esp,8
    mov ebx,dword[savebx]
    push dword [ebx + 28]
    push format_int2
    call printf
    push dword 10
    call putchar
    hoon:
    mov ebx,dword[savebx]
    mov ebx, [ebx + 32]
    cmp ebx, 0
    jne next_char

        p9:
        xor ebx,ebx
        call resume             ; resume scheduler

        jmp printer