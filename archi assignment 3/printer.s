extern printf
extern resume
extern firstDrone
extern x_target
extern y_target
extern activeDrones
extern N

global printer

section .rodata
    ; align 16
    targetFormat: db "%.2f, %.2f",10,0
    Droneformat: db "%d, %.2f, %.2f, %.2f, %d",10,0
    numFormat: db "we got to: %d and c = %d",10,0
section .data
    tmp: dd 0
    c: dd 0
section .text
    ;;same case as the target
printer:
    push dword[c]
    push dword[activeDrones]
    push numFormat
    call printf
    add esp,8
    inc dword[c]
    cmp dword[activeDrones],0
    je eend

    push dword[x_target+4] ;; push a qword
    push dword[x_target]
    push dword[y_target+4] ;; push a qword
    push dword[y_target]
    push targetFormat
    call printf
    add esp,20

    ; mov ebx,0
    ; mov eax,1
    ; int 0x80


    mov ebx,[firstDrone]

    ; mov eax,0
    ; mov al,byte[ebx]
    ; push eax ;; ID
    ; push numFormat
    ; call printf
    ; add esp,8

    finit
printDrones:
    push ebx
    cmp ebx,0 ;; finish
    je stopPrinting
    pop ebx
    mov eax,0
    mov al,byte[ebx+7] ;;targets hit
    push eax 

    fild word[ebx+5];;th alpha drone
    sub esp,8
    fstp qword[esp]

    fild word[ebx+3];;th y drone
    sub esp,8
    fstp qword[esp]

    fild word[ebx+1];; the x drone
    sub esp,8
    fstp qword[esp]

    mov eax,0
    mov al,byte[ebx]
    push eax ;; ID
    
    mov dword[tmp],ebx
    push Droneformat
    call printf

    add esp, (4*9)

    mov ebx,dword[tmp]
    mov ebx,[ebx+8]
    jmp printDrones


stopPrinting:
    mov ebx,0 ;; scheduler is cor 0
    call resume
    jmp printer

;; not tested yet
eend:
    mov ebx,0
    mov eax,1
    int 0x80