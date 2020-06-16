
global startCo
global Randomxy
global resume
global k;; for the scheduler
global N;; for the scheduler
global R
global d
global createNewTarget
global firstDrone
global lastDrone
global x_target
global y_target
global lfsr
global initState
global curr_cor
global endCo
global droneCor

extern scheduler ;; the main function for the scheduler
extern drones ;; the main function for the drones
extern printer ;; the main function in the printer
extern createTarget


section .data
    droneID: db 0
    index: dd 0
    ;; here the drone struct is represented as a linked list = 39 bytes
    struc drone
        id: resb 1 
        x: resw 4 ;; 1
        y: resw 4 ;; 9
        alpha: resw 4 ;; 17
        targets_Hit: resb 1 ;;25
        next: resb 4  ;;26
        dead: resb 1  ;; 30
        speed: resd 2 ;;31
    endstruc

    here: db "here",10,0
    lfsr: dd 0
    initState: dw 0
    counter: dd 0
    x_target: dq 0
    y_target: dq 0
    tmp87: dq 0
    targetFormat: db "%.2f, %.2f",10,0
    
section	.rodata
    align 16 
    
    errorIn: db "Invalid intput parameters, should be 6 but recieved:-> %d",10,0
    sscanfRead: db "%d" ,0
    msg: db "%s",10,0
    nums: db "%d",10,0
    dmsg: db "here : %d",10,0
    dfmsg: db "here : %.2f",10,0

section .bss
    N: resd 1
    tmpN: resd 1
    R: resd 1
    k: resd 1
    d: resd 1
    seed: resd 1
    mainSP: resd 1
    curr_cor: resd 1
    stcksz: equ 16*1024
    droneCor: resd 1
    cors: resd 10000 ;; an array of co-routines top
    stacks: resb 10000 * stcksz
    stateNumber: resb 16
    mulNumber: resb 4
    firstDrone: resb 4
    lastDrone: resb 4 

section .text
    align 16
    global main
    extern malloc
    extern calloc
    extern free
    extern printf
    extern sscanf
    extern sscanf

%macro debug 1
    pushad
    push %1
    push dmsg
    call printf
    add esp,8
    popad
%endmacro

%macro fdebug 2
    pushad
    push %2
    push %1
    push dfmsg
    call printf
    add esp,12
    popad
%endmacro

%macro finish 0
    mov eax,1
    mov ebx,0
    int 0x80
%endmacro

%macro instanciateCor 0
    push edx ;; here the edx is the retun address like scheduler and printer ...
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

;;16, 14 ,13, 11
    xor bx,cx
    xor bx,dx
    xor bx,ax
    and bx,1

    mov ax,0
    mov ax,[lfsr]
    shr ax,1
    shl bx,15
    or ax,bx
    mov [lfsr],ax
%endmacro

%macro addDrone 0
    ; mov ebx, [firstDrone]
    cmp dword[firstDrone],-1 ;;the first drone
    je %%_firstDrone
    mov ebx, [lastDrone]
    mov [ebx + 26],eax
    mov [lastDrone], eax
    jmp %%end
    %%_firstDrone:
        mov [firstDrone], eax
        mov [lastDrone], eax
    %%end:
%endmacro

%macro freeDrones 0
    mov ebx,[firstDrone]
    %%loopFree:
        mov eax,[ebx+26]
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
            ;; cors
        ;; scheduler = 0
        ;; printer = 1
        ;; target = 2
main:
    mov eax,[esp+4] ;; argc
    cmp eax,6
    jne errorInput
    mov esi,[esp+8] ;; argv**
    mov dword[index], 1 ;; the argv[1] is ./ass3

    ; pushad
    ; push ecx
    ; push nums
    ; call printf
    ; add esp,8
    ; popad
    mov ecx,dword[index]
    mov eax, [esi+ 4*ecx]
    push N
    sscanfCall

    
    ; pushad
    ; push dword[index]
    ; push nums
    ; call printf
    ; add esp,8
    ; popad

    inc dword[index]
    mov ecx,dword[index]
    mov eax, [esi+ 4*ecx]
    push R
    sscanfCall

    

    ; pushad
    ; push dword[index]
    ; push nums
    ; call printf
    ; add esp,8
    ; popad

    inc dword[index]
    mov ecx,dword[index]
    mov eax, [esi+ 4*ecx]
    push k
    sscanfCall

    ; pushad 
    ; push dword[k]
    ; push nums
    ; call printf
    ; add esp,8
    ; popad

    ; pushad
    ; push dword[esi+ 4*ecx]
    ; push msg
    ; call printf
    ; add esp,8
    ; popad


    inc dword[index]
    mov ecx,dword[index]
    mov eax, [esi+ 4*ecx]
    push d
    sscanfCall

    ; pushad 
    ; push dword[d]
    ; push nums
    ; call printf
    ; add esp,8
    ; popad
    
    inc dword[index]
    mov ecx,dword[index]
    mov eax, [esi+ 4*ecx]
    push seed
    sscanfCall
    mov ax,word[seed]
    mov word[initState],ax


    ; pushad 
    ; push dword[seed]
    ; push nums
    ; call printf
    ; add esp,8
    ; popad

    ; pushad
    ; mov ecx,dword[index]
    ; push dword[esi+ 4*ecx]
    ; push msg
    ; call printf
    ; add esp,8
    ; popad

    mov ebx,0 ;; we consider the scheduler as co-routine 0 so we need to instantiate it by calling the initCo from the prac session
    push ebx
    mov edx, scheduler
    call initCo ;;which is a func
    pop ebx

    inc ebx ;; this co_routine is for the printer = 1
    mov edx,printer
    push ebx
    call initCo
    pop ebx

    inc ebx ;; and finally we will amke the target as co_routine 2
    push ebx
    mov edx, createTarget
    call initCo
    pop ebx
    
    finit       ;;initialize the x87 thing
    mov dword[stateNumber],65535
    mov dword[mulNumber],100
    mov dword[firstDrone],-1
    ; mov ebx,[firstDrone]
    ; mov byte[ebx], -1
    mov dword[lastDrone],0
    call createNewTarget

    ; push dword[x_target+4] ;; push a qword
    ; push dword[x_target]
    ; push dword[y_target+4] ;; push a qword
    ; push dword[y_target]
    ; push targetFormat
    ; call printf
    ; add esp,20

    call createTheDrones

createNewTarget:
    call Randomxy
    mov ax,[lfsr] ;; save the new random number
    mov [initState],ax

    ; push dword[mulNumber]
    ; push nums
    ; call printf
    ; add esp,8

    ; push dword[stateNumber]
    ; push nums
    ; call printf
    ; add esp,8

    ;;the x coordinate of the target
    basicx87
    fstp qword[x_target]

    ;; now we will do the same thing for the y coordinate
    call Randomxy
    mov ax,[lfsr] ;; save the new random number
    mov [initState],ax

    basicx87
    fstp qword[y_target]
    ret

createTheDrones:

    ;;struct size is 17 bytes == 68 bits
    mov byte[droneID],1
    mov eax,dword[N]
    mov dword[tmpN],eax
    .droneloop:
        ; push here
        ; call printf
        ; add esp,4

        cmp dword[tmpN],0
        je initRoutine

        push 39
        call malloc
        add esp,4
        mov cl,byte[droneID]
        mov byte[eax],cl ;; the first byte in the struct is the id
        mov byte[eax + 25],0 ;;the hit targets
        mov dword[eax + 26],0 ;; this drone is the last drone in the current list
        mov dword[eax + 30],1 ;; the drone is not dead yet
        mov dword[eax + 31],0 ;; initial speed
        mov dword[eax + 35],0
        inc byte[droneID]
        ; debug eax

            ;;calc the initial x coordinate of the drone
        push eax
        call Randomxy
        ; mov ax,[lfsr] ;; save the new random number
        ; mov [initState],ax
        
        basicx87
        fstp qword[tmp87] ;; fstp return qword
            ; fdebug dword[tmp87],dword[tmp87 + 4]
        mov ebx,dword[tmp87]
        pop eax
        mov dword[eax + 1],ebx
        mov ebx,dword[tmp87+4]
        mov dword[eax + 5],ebx

        ; debug eax
        ;;calc the initial y coordinate of the drone
        push eax
        call Randomxy
        ; mov ax,[lfsr] ;; save the new random number
        ; mov [initState],ax
        pop eax
        
        basicx87
        fstp qword[tmp87] ;; fstp return qword
        mov ebx,dword[tmp87]
        mov dword[eax + 9],ebx        
        mov ebx,dword[tmp87+4]
        mov dword[eax + 13],ebx
            ; fdebug dword[tmp87],dword[tmp87 + 4]

        ;;calc the initial alpha of the drone
        push eax
        call Randomxy
        ; mov ax,[lfsr] ;; save the new random number
        ; mov [initState],ax
        pop eax
        mov dword[mulNumber],360 ;;for the alpha --> radian
        basicx87
        mov dword[mulNumber],100
        fstp qword[tmp87] ;; fstp return qword
        mov ebx,dword[tmp87]
        mov dword[eax + 17],ebx
        mov ebx,dword[tmp87+4]
        mov dword[eax+21],ebx

            ; fdebug dword[tmp87],dword[tmp87 + 4]

        addDrone
        dec dword[tmpN]
        jmp .droneloop

Randomxy:
    push ebp
    pushad
    pushf
    mov ebp,esp

    mov dword[counter],2
    mov eax,0
    mov ax,word[initState]
    mov [lfsr],ax

    .lfsrloop:
        lfsrloop

            ; push dword[lfsr]
            ; push nums
            ; call printf
            ; add esp,8

        dec dword[counter]
        cmp dword[counter],0
        jne .lfsrloop

    mov ax,[lfsr]
    mov [initState],ax
    popf
    popad
    pop ebp
    ret

initCo:
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
    
resume: ;; ebx holds the next Cor
    pushfd
    pushad

        ; debug ebx

    mov edx,[curr_cor]
    mov [droneCor],edx
    mov [cors+4*edx],esp ;; save the stack top of the last used one
    .do_resume:
        mov esp,[cors + ebx*4]
        mov [curr_cor],ebx

        ; pushad
        ; push ebx
        ; push nums
        ; call printf
        ; add esp,8
        ; popad

        popad
        popfd
        ret
    
initRoutine:
    
    mov esi,0
    mov eax,dword[N]
    mov dword[tmpN],eax
    
    .cores:
        cmp dword[tmpN],0
        je .finishDrones ;; here we need to exit totally
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
        ; debug ebx
    freeDrones
        ; debug ebx
    finish
    nop