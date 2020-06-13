align 16
global startCo
global Randomxy
global resume
global k;; for the scheduler
global N;; for the scheduler
global R
global createNewTarget
global firstDrone
global lastDrone
global x_target
global y_target
global lfsr
global initState
global curr_cor

extern scheduler ;; the main function for the scheduler
extern drones ;; the main function for the drones
extern printer ;; the main function in the printer
extern createTarget

section .data
    droneID: db 0

    ;; here the drone struct is represented as a linked list
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
    
    lfsr: dd 0
    initState: dw 0
    counter: dd 0
    x_target: dq 0
    y_target: dq 0
    
section	.rodata
    align 16 
    N: resd 1
    tmpN: resd 1
    R: resd 1
    k: resd 1
    d: resd 1
    seed: resd 1
    errorIn: db "Invalid intput parameters, should be 6 but recieved:-> %d",10,0
    sscanfRead: db "%d" ,0

section .bss
    mainSP: resd 1
    curr_cor: resd 1
    stcksz: equ 16*1024
    maxCors: 100*100 ;; not sure about the number, but we need this to instantiate the cors array
    cors: resd maxCors ;; an array of co-routines top
    stacks: resb maxCors * stcksz
    stateNumber: resb 16
    mulNumber: resb 4
    firstDrone: resb 17
    lastDrone: resb 17 

section .text
    align 16
    global main
    extern malloc
    extern calloc
    extern free
    extern printf
    extern sscanf
    extern sscanf

%macro finish 0
    mov eax,1
    mov ebx,0
    int 0x80
%endmacro

%macro instanciateCor 0
    ;;ebx is the core ID
    mov edx,0
    mov eax, stcksz
    mul ebx
    pop edx ;; restore the retun address afher the mul
    add eax, stacks + stcksz ;; here after we got the eaxt to points to the statr of the wanted stack, we move it to the end of it so that he would be ready for use as a regualr stack
    mov [cors + 4*ebx],eax;; save the top of the stack in it's array
    mov dword[mainSP],esp
    mov esp,eax
    push edx;; the return address
    pushf
    pushad
    mov [cors +ebx*4],esp ;;update the cor esp
    mov esp,dword[mainSP]
%endmacro

%macro sscanfCall 0
    push sscanfRead
    push eax
    call sscanf
    add esp,12
%endmacro

%macro basicx87 0
    fild dword[lfsr]
    fidiv dword[stateNumber]
    fimul dword[mulNumber]
%endmacro

%macro lfsrloop 0
    mov eax,0
    mov ebx,0
    mov ax,[lfsr]
    mov bx,[lfsr]
    shr ax,2
    mov ecx,0
    mov cx,ax
    mov ax,[lfsr]
    shr ax,3
    mov edx,0
    mov dx,ax
    mov ax,[lfsr]
    shr ax,5

    xor bx,cx
    xor bx,dx
    xor bx,ax

    mov ax,[lfsr]
    shr ax,1
    shr bx,15
    or ax,bx
%endmacro

%macro addDrone 0
    mov ebx, firstDrone
    cmp byte[ebx + 32],-1 ;;the first drone
    je %%_firstDrone
    mov ebx, lastDrone
    mov [ebx + 32],eax
    mov lastDrone, eax
    jmp %%end
    %%_firstDrone:
        mov firstDrone, eax
        mov lastDrone, eax
    %%end:
%endmacro

%macro freeDrones 0
    mov ebx,firstDrone
    %%loopFree:
        mov eax,[ebx+32]
        mov dword[lastDrone],eax
        push ebx
        call free
        add esp,4
        cmp dword[lastDrone],0
        je %%end
        mov ebx,dword[lastDrone]
        jmp %%loopFree
    %%end:
%endmacro

errorInput:
    push eax
    push errorIn
    call printf
    finish
    nop
main:
    mov eax,[esp+4] ;; argc
    cmp eax,6
    jne errorInput
    mov esi,[esp+8] ;; argv**
    mov ecx, 1 ;; the argv[1] is ./ass3
    mov eax, [esi+ 4*ecx]
    push N
    sscanfCall

    inc ecx
    mov eax, [esi+ 4*ecx]
    push R
    sscanfCall

    inc ecx
    mov eax, [esi+ 4*ecx]
    push k
    sscanfCall

    inc ecx
    mov eax, [esi+ 4*ecx]
    mov dword[d],eax

    inc ecx
    mov eax, [esi+ 4*ecx]
    push seed
    sscanfCall
    mov ax,word[seed]
    mov word[initState],ax

    mov ebx,0 ;; we consider the scheduler as co-routine 0 so we need to instantiate it by calling the initCo from the prac session
    mov edx, scheduler
    call initCo ;;which is a func
    inc ebx ;; this co_routine is for the printer
    mov edx,printer
    call initCo
    inc ebx ;; and finally we will amke the target as co_routine 3
    mov edx, createTarget
    call initCo

    finit       ;;initialize the x87 thing
    mov dword[stateNumber],65535
    mov dword[mulNumber],100
    mov tword[firstDrone],0
    mov ebx,firstDrone
    mov byte[ebx+32], -1
    mov tword[lastDrone],0
    call createNewTarget
    call createTheDrones

createNewTarget:
    call Randomxy
    mov ax,[lfsr] ;; save the new random number
    mov [initState],ax

    ;;the x coordinate of the target
    basicx87
    fstp dword[x_target]

    ;; now we will do the same thing for the y coordinate
    call Randomxy
    mov ax,[lfsr] ;; save the new random number
    mov [initState],ax

    basicx87
    fstp dword[y_target]
    ret

createTheDrones:

    ;;struct size is 17 bytes == 68 bits
    mov byte[droneID],1
    mov eax,dword[N]
    mov dword[tmpN],eax
    .droneloop:
        push 68
        call malloc
        add esp,4
        mov cl,byte[droneID]
        mov byte[eax],cl ;; the first byte in the struct is the id
        mov byte[eax + 28],0 ;;the hit targets
        mov dword[eax + 32],0 ;; this drone is the last drone in the current list
        mov dword[eax + 48],1 ;; the drone is not dead yet
        mov dword[eax + 52],0 ;; initial speed
        cmp dword[tmpN],0
        je initRoutine

        ;;calc the initial x coordinate of the drone
        push eax
        call Randomxy
        mov ax,[lfsr] ;; save the new random number
        mov [initState],ax
        pop eax
        basicx87
        fstp word[eax + 4]

        ;;calc the initial y coordinate of the drone
        push eax
        call Randomxy
        mov ax,[lfsr] ;; save the new random number
        mov [initState],ax
        pop eax
        basicx87
        fstp word[eax + 12]

        ;;calc the initial alpha of the drone
        push eax
        call Randomxy
        mov ax,[lfsr] ;; save the new random number
        mov [initState],ax
        pop eax
        mov dword[mulNumber],360 ;;for the alpha --> radian
        basicx87
        mov dword[mulNumber],100
        fstp word[eax + 20]

        addDrone
        dec dword[tmpN]
        jmp .droneloop

Randomxy:
    push ebp
    pushad
    pushf
    mov ebp,esp

    mov [counter],16
    mov eax,0
    mov ax,word[initState]
    mov [lfsr],ax

    .lfsrloop:
        lfsrloop

        mov [lfsr],ax
        dec [counter]
        cmp [counter],0
        jne .lfsrloop

    popf
    popad
    pop ebp
    ret

initCo:
    push edx ;; here the edx is the retun address like scheduler and printer ...
    instanciateCor
    ret

startCo:
    pushad 
    mov [mainSP],esp
    mov [curr_cor],ebx ;;store the current co-routine
    jmp resume.do_resume
endCo:
    mov esp,[mainSP]
    popad 
    ret
    
resume:;; ebx holds the next Cor
    pushfd
    pushad
    mov edx,[curr_cor]
    mov [cors+4*edx],esp ;; save the stack top of the last used one
    .do_resume:
        mov esp,[cors+ebx*4]
        popad
        popfd
        ret
    
initRoutine:
    mov esi,0
    mov eax,dword[N]
    mov dword[tmpN],eax
    
    .cores:
        cmp dword[tmpN],0
        je finishDrones ;; here we need to exit totally
    .initDrones:
        mov edx, drones
        mov ebx,3 ;; because the first thre co-routines are the schedulet, printer nad target
        add ebx,esi ;; esi iterates through all the drones 
        call initCo
        inc esi
        dec dword[tmpN]
        jmp .cores

    .finishDrones:
        ; popad ;; not sure if needed
        mov ebx,0 ;; after creating everything start the scheduler
        call startCo

end_program:
    ;;free the drones --> done
    freeDrones
    finish
    nop