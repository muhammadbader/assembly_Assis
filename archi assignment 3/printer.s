extern printf
extern resume
extern firstDrone
extern x_target
extern y_target

global printer

section .rodata
    align 16
    targetFormat: db "%.2f, %.2f",10,0
    Droneformat: db "%d, %.2f, %.2f, %.2f, %d",10,0

section .text
    ;;same case as the target
printer:
    push x_target
    push y_target
    push targetFormat
    call printf
    add esp,12

    mov ebx,firstDrone
    finit
printDrones:
    push ebx
    mov eax,dword[ebx]
    cmp eax,0 ;; finish
    je stopPrinting
    pop ebx
    mov eax,0
    mov al,byte[ebx]
    push eax ;; ID
    fild word[ebx+4];; the x drone
    sub esp,8
    fstp qword[esp]

    fild word[ebx+12];;th y drone
    sub esp,8
    fstp qword[esp]

    fild word[ebx+20];;th alpha drone
    sub esp,8
    fstp qword[esp]

    mov eax,0
    mov al,byte[ebx+28] ;;targets hit
    push eax 

    push Droneformat
    call printf
    add esp, (4*9)

    mov ebx,dword[ebx+32]
    jmp printDrones


stopPrinting:
    mov ebx,0 ;; scheduler is cor 0
    call resume
    jmp printer

;; not tested yet