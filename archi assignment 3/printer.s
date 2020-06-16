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
    Droneformat: db "%d, %.2f, %.2f, %.2f, %.2f, %d",10,0 ;; id, x, y, alpha, speed, hits
    numFormat: db "we got to: %d and c = %d",10,0
section .data
    tmp: dd 0
    c: dd 0
    x: dd 0
section .text

%macro debug 0
    pushad
    push dword[c]
    push dword[activeDrones]
    push numFormat
    call printf
    add esp,8
    inc dword[c]
    popad
%endmacro

    ;;same case as the target
printer:
    
        ; debug
        ; cmp dword[x],0
        ; je stopPrinting
    dec dword[x]
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

    ; struc drone
    ;     id: resb 1 
    ;     x: resw 4 ;; 1
    ;     y: resw 4 ;; 9
    ;     alpha: resw 4 ;; 17
    ;     targets_Hit: resb 1 ;;25
    ;     next: resb 4  ;;26
    ;     dead: resb 1  ;; 30
    ;     speed: resd 1 ;;31
    ; endstruc
    push ebx
    cmp ebx,0 ;; finish
    je stopPrinting
    pop ebx
    mov eax,0
    mov al,byte[ebx+25] ;;targets hit
    push eax 

    fld qword[ebx+31]
    sub esp,8
    fstp qword[esp]

    fld qword[ebx+17];;the alpha drone
    sub esp,8
    fstp qword[esp]

    fld qword[ebx+9];;the y drone
    sub esp,8
    fstp qword[esp]

    fld qword[ebx+1];; the x drone
    sub esp,8
    fstp qword[esp]

    mov eax,0
    mov al,byte[ebx]
    push eax ;; ID
    
    mov dword[tmp],ebx
    push Droneformat
    call printf

    add esp, (4*11)

    mov ebx,dword[tmp]
    mov ebx,[ebx+26]
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