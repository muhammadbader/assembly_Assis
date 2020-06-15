section .data
    rad: dq 2.34
    area: dq 0.0
    pi: dq 2.0
    num: dd 123
    counter: dd 0
    format: db "%.2f - %.2f",10,0
    floating: db "%.2f",10,0
    Dfor: db "%d",10,0
    lfsr: dd 0
    initState: dw 15019
    here: db "here",10,0

    struc drone
        id: resb 1 
        x: resw 1 
        y: resw 1
        alpha: resw 1
        targets_Hit: resb 1 ;;32 bits
        next: resb 4 ;;48 bits
        dead: resb 1 ;; 52 bits
        speed: resd 1
    endstruc

section .bss
    firstDrone: resb 4
    lastDrone: resb 4


extern printf
extern malloc
section .text
    global main

%macro lfsrloop 0
    mov ax,word[lfsr]
    shr ax,0
    mov bx,ax

    mov ax,word[lfsr]
    shr ax,2
    mov cx,ax

    mov ax,word[lfsr]
    shr ax,3
    mov dx,ax
    
    mov ax,word[lfsr]
    shr ax,5


    xor bx,cx
    xor bx,dx
    xor bx,ax
    and bx,1

    mov ax,0
    mov ax,word[lfsr]
;;16, 14 ,13, 11
    shr ax,1
    shl bx,15
    or ax,bx

    mov [lfsr],ax
    ; push eax
    ; push Dfor
    ; call printf
    ; add esp,8

%endmacro

%macro addDrone 0
    cmp dword[firstDrone],-1 ;;the first drone
    je %%_firstDrone
    mov ebx, [lastDrone]
    mov [ebx + 8],eax
    mov [lastDrone], eax
    ; push here
    ;     call printf
    ;     add esp,4
    jmp %%end
    %%_firstDrone:
        ; push here
        ; call printf
        ; add esp,4

        mov [firstDrone], eax
        mov [lastDrone], eax
    %%end:
%endmacro


main:

    ; call Randomxy
    ; call Randomxy
    ; mov dword[firstDrone],-1
    ; mov dword[lastDrone],0    

    ; push 68
    ; call malloc
    ; add esp,4
    ; mov cl,1
    ; mov byte[eax],cl ;; the first byte in the struct is the id
    ; mov byte[eax + 7],10 ;;the hit targets
    ; mov dword[eax + 8],0 ;; this drone is the last drone in the current list
    ; mov dword[eax + 12],1 ;; the drone is not dead yet
    ; mov dword[eax + 13],0 ;; initial speed
    ; push eax
    ; addDrone

    ; mov dword[firstDrone],eax

    ; push 68
    ; call malloc
    ; add esp,4
    ; mov cl,30
    ; mov byte[eax],cl ;; the first byte in the struct is the id
    ; mov byte[eax + 7],4 ;;the hit targets
    ; mov dword[eax + 8],0 ;; this drone is the last drone in the current list
    ; mov dword[eax + 12],1 ;; the drone is not dead yet
    ; mov dword[eax + 13],0 ;; initial speed
    ; addDrone

    ; pop eax
    ; mov ecx,0
    ; mov ebx,[firstDrone]
    ; mov ebx,[ebx+8]
    ; mov cl,byte[ebx]
    ; push ecx
    ; push Dfor
    ; call printf
    ; add esp,8

    finit
    fld qword[rad]
    sub esp,8
    fstp qword[esp]
    push floating
    call printf
    add esp,12
    ; fld qword[rad]

    ; fst st1
    ; fmulp
    ; fldpi
    ; fmulp
    ; fsqrt
    ; fild dword[num]
    ; fcomi st0, st1
    ; ja end ;; jmp id st0 = num > st1 = sqrt
    ; fstp qword[area]
    ; fstp qword[rad]

        ; mov edx,0
        ; mov eax,1
        ; mov ebx,0
        ; div ebx
        ; fidiv dword[num]

        ; fstp qword[area]
        ; fstp qword[rad]
        ; push dword[area+4]
        ; push dword[area]
        ; push dword[rad+4]
        ; push dword[rad]
        ; push format
        ; call printf
        ; add esp,20
        

    ; call Randomxy
    ; mov ax,[lfsr] ;; save the new random number
    ; mov [initState],ax
    ; push eax
    ; push Dfor
    ; call printf
    ; add esp,8

    ; call Randomxy
    ; mov ax,[lfsr] ;; save the new random number
    ; mov [initState],ax
    ; push eax
    ; push Dfor
    ; call printf
    ; add esp,8

    



end:

    mov eax,1
    mov ebx,0
    int 0x80


Randomxy:
    push ebp
    pushad
    pushf
    mov ebp,esp

    mov dword[counter],0x10
    mov eax,0
    mov ax,word[initState]
    mov [lfsr],ax

    .lfsrloop1:
        lfsrloop

        ; mov [lfsr],ax
        push dword[lfsr]
        push Dfor
        call printf
        add esp,8

        dec dword[counter]
        cmp dword[counter],0
        jne .lfsrloop1
    mov ax,[lfsr]
    mov [initState],ax
    popf
    popad
    pop ebp
    ret