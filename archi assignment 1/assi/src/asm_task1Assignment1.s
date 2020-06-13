section .data
    ans:dd 0
    x: dd 12
    y: dd 12
section .rodata
    format: dd "%d", 0x0a, 0 ; the answer to print
section .text
    global assFunc
    extern c_checkValidity ;global c_checkValidity
    extern printf

assFunc:  ; wirte the assignment here
 
    push ebp
    mov ebp,esp
    pushad
    mov dl,'1'
    mov ebx,dword [ebp+8]
    mov [x],ebx
    mov ebx,dword [ebp+12]
    mov [y],ebx
    push dword [y] ;;mov ecx, dword[ebp+8]   ; the x 
    push dword [x] ;;mov ebx, dword[ebp+12]  ; the y
    call c_checkValidity
    mov [ans],eax; the returned answer is stored in eax
    add esp,8
    cmp byte[ans],dl
    jne addxy

    mov ebx,[x]
    sub ebx,[y]
    mov [ans],ebx
    jmp end_

addxy:
    mov ebx,[x]
    add ebx,[y]
    mov [ans],ebx
end_:
    push dword [ans]
    push format;; calling printf with arguements
    call printf
    add esp,8

    mov eax,0;; for return
    popad
    mov esp,ebp
    pop ebp
    ret
