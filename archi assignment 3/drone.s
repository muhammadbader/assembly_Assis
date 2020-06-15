extern createTarget
extern x_target
extern y_target
extern Randomxy
extern lfsr
extern initState
extern resume
extern curr_cor
extern firstDrone
extern printf
extern d

global drones
; align 16

section .bss
    stateNumber: resb 16
    mulNumber: resb 4
    currDrone: resd 1
    oldAlpha: resq 1
    oldSpd: resd 1
    crdnt: resq 1
    rad: resq 1
    clamp: resd 1

section .data
    delta_alpha: dq 0
    newSpeed: dq 0
    bias: dd 0
    tmp87: dq 0
    drn: dd 0

section .rodata
    error: db "Drone not found",10,0
    here: db "here: %d",10,0
    dfor: db "%d",10,0

section .text

%macro calcBounds 0

    mov dword[clamp],100 ;;the board limits
    fld dword[clamp]
    fcomi st0, st1 ;; st0 = 100 and st1 = new X
    ja %%dontWrapandChecklessThanZero
    fsubp
    fstp qword[tmp87]
    mov ax,word[tmp87]
    mov word[crdnt], ax
    jmp %%end
%%dontWrapandChecklessThanZero:
    fstp qword[tmp87];; pop the 100
    mov dword[clamp],0
    fld dword[clamp]
    fcomi
    jb %%dontWrap
    faddp
    mov dword[clamp],100
    fld dword[clamp]
    faddp
    fst qword[tmp87]
    fstp qword[crdnt]
    ; mov ax,word[tmp87]
    ; mov word[crdnt], ax
    jmp %%end
%%dontWrap:
   
    fstp qword[tmp87];; take out the o we pushed in
    mov eax,dword[tmp87]
    mov dword[clamp], eax

    fstp qword[tmp87];; save the new X coordinate
    mov ax,word[tmp87]
    mov word[crdnt], ax
%%end:
%endmacro

%macro debug 1
    pushad
    push %1
    push here
    call printf
    add esp,8
    popad
%endmacro

%macro droneID 0
    push eax
    mov eax,0
    mov al,byte[ebx]
        debug eax
    pop eax
%endmacro


drones:
    finit

        ; debug dword[curr_cor]
    
    mov eax,0
    mov ebx, [firstDrone]
    mov al,byte[ebx]
    add eax,2

    cmp eax,dword[curr_cor]
    je foundHim
nextDrone:
    mov ebx,dword[ebx+26] ;; next drone
    cmp ebx,0
    je errorSearch
    mov eax,0
    mov al,byte[ebx]
    add eax,2
    cmp eax,dword[curr_cor]
    je foundHim
    jmp nextDrone
foundHim:
    mov dword[drn],ebx ;; drn point to the drone for further use

        ; droneID
    
    call randomAlpha
    call speedChange
    call newPos
    call mayDestroy

    

randomAlpha:
    push ebp
    mov ebp,esp

    call Randomxy
    mov ax,word[lfsr]
    mov word[initState],ax
    mov dword[stateNumber],65535
    mov dword[mulNumber],120
    fld dword[lfsr]
    fidiv dword[stateNumber]
    fimul dword[mulNumber]
    mov dword[bias],60
    fisub dword[bias]
    fstp qword[delta_alpha]

    mov esp,ebp
    pop ebp
    ret

speedChange:
    push ebp
    mov ebp,esp

    call Randomxy
    mov ax,word[lfsr]
    mov word[initState],ax
    mov dword[stateNumber],65535
    mov dword[mulNumber],20
    fld dword[lfsr]
    fidiv dword[stateNumber]
    fimul dword[mulNumber]
    mov dword[bias],10
    fisub dword[bias]
    fstp qword[newSpeed]

    mov esp,ebp
    pop ebp
    ret

newPos:
    push ebp
    mov ebp,esp

;     mov eax,0
;     mov ebx, [firstDrone]
;     mov al,byte[ebx]
;     add eax,2
;     cmp eax,dword[curr_cor]
;     je foundHim
; nextDrone:
;     mov ebx,dword[ebx+26] ;; next drone
;     cmp ebx,0
;     je errorSearch
;     mov eax,0
;     mov al,byte[ebx]
;     cmp eax,dword[curr_cor]
;     je foundHim
;     jmp nextDrone
; foundHim:;;ebx points to the right drone

    
    mov eax, dword[ebx+17]
    mov dword[oldAlpha],eax
    mov eax,dword[ebx+21]
    mov dword[oldAlpha+4],eax
    mov eax,dword[ebx+13]
    mov dword[oldSpd],eax

calcX:
    fld qword[oldAlpha]
    fldpi
    fmul
    mov dword[mulNumber],180
    fidiv dword[mulNumber] ;; fidiv replaces the st0
    fstp qword[rad]
    fld qword[rad]
    fcos
    fmul dword[oldSpd]
    fld qword[ebx+1] ;; load the x location of the drone
    faddp
    calcBounds
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
    mov eax, dword[crdnt]
    mov dword[ebx+1],eax
    mov eax,dword[crdnt+4]
    mov dword[ebx+5],eax
;     mov dword[clamp],100 ;;the board limits
;     fld dword[clamp]
;     fcomi st0, st1 ;; st0 = 100 and st1 = new X
;     ja dontWrapandChecklessThanZero
;     fsubp
;     fstp word[ebx+4]
;     jmp %%end
; dontWrapandChecklessThanZero:
;     fstp dword[clamp];; pop the 100
;     mov dword[clamp],0
;     fld dword[clamp]
;     fcomi
;     jb dontWrap
;     faddp
;     mov dword[clamp],100
;     fld dword[clamp]
;     faddp
;     fstp word[ebx+4]
;     jmp %%end
; dontWrap:
;     fstp dword[clamp];; take out the o we pushed in
;     fstp word[ebx+4] ;; save the new X coordinate
    
calcY:
    fld qword[rad]
    fsin
    fmul dword[oldSpd]
    fld qword[ebx+9]
    faddp        ;; calc the new y position
    calcBounds
    mov eax, dword[crdnt]
    mov dword[ebx+9],eax
    mov eax,dword[crdnt+4]
    mov dword[ebx+13],eax


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
saveNewAlpha:
    fld qword[oldAlpha]
    fadd qword[delta_alpha]
    mov dword[clamp],360
    fld dword[clamp]
    fcomi st0, st1
    ja checkAlphaLessThatZero
    fsubp
    fst qword[tmp87]
    fstp qword[ebx+17]
    jmp changeSpeed
checkAlphaLessThatZero:
    fsub dword[clamp];; make st0 = 0
    fcomi st0, st1
    jb dontDoAThing
    fadd dword[clamp]
    faddp
    fst qword[tmp87]
    fstp qword[ebx+17] ;; new alpha
    jmp changeSpeed
dontDoAThing:
    faddp
    fst qword[tmp87]
    fstp qword[ebx+17]
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

changeSpeed:
    fld qword[newSpeed]
    fadd qword[ebx+31]
    mov dword[clamp],100
    fld dword[clamp]
    fcomi st0, st1
    ja dontCutYet
    fst qword[tmp87] ;; speed = 100
    fstp qword[ebx+31]
    jmp newPosend
dontCutYet:
    fsub dword[clamp]
    fcomi st0, st1
    jb newSpeedy
    fst qword[tmp87] ;; the speed is Zero
    fstp qword[ebx+31]
    fstp qword[tmp87] ;; clear the x87 stack
    jmp newPosend
newSpeedy:
    faddp
    fst qword[tmp87] ;; save the new speed
    fstp qword[ebx+31]
newPosend:
    mov esp,ebp
    pop ebp
    ret

; (*) Do forever
mayDestroy:
    mov ebx,dword[drn]
    ;;todo --> done: check if the drone can destroy the target

        ; droneID

    call canDestroy
    call randomAlpha
    call speedChange
    mov ebx,dword[drn]

        ; droneID

    ; pushad 
    ; push ebx
    ; push dfor
    ; call printf
    ; add esp,8
    ; popad

    ;; in case returned true
   
    
    
    ;     (*) if mayDestroy(…) (check if a drone may destroy the target)
    ;         (*) destroy the target	
    ;         (*) resume target co-routine 
    call newPos ;; done
;     (*) Generate random angle ∆α       ; generate a random number in range [-60,60] degrees, with 16 bit resolution --> done
;     (*) Generate random speed change ∆a    ; generate random number in range [-10,10], with 16 bit resolution       --> done
;     (*) Compute a new drone position as follows:
;         (*) first, move speed units at the direction defined by the current angle, wrapping around the torus if needed. --> done
;         (*) then change the new current angle to be α + ∆α, keeping the angle between [0, 360] by wraparound if needed   --> done
;         (*) then change the new current speed to be speed + ∆a, keeping the speed between [0, 100] by cutoff if needed    --> done

    ; push eax
    ; mov eax,0
    ; mov al,byte[ebx]
    ;     debug eax
    ; pop eax

        ; droneID

    mov ebx,0
    call resume
    jmp mayDestroy
;     (*) resume scheduler co-routine by calling resume(scheduler)	
; (*) end do


errorSearch:
    push error
    call printf
    add esp,4

    mov eax,0
    mov ebx,1
    int 0x80

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
canDestroy:
    fld qword[x_target]
    fld qword[ebx+1]
    fsubp ;; x_target - x_drone
    fst st1
    fmulp ;; (x_target - x_drone)^2
    fld qword[y_target]
    fld qword[ebx+9]
    fsubp  ;; y_target - y_drone
    fst st1
    fmulp ;; (y_target - y_drone)^2
    faddp ;; (y_target - y_drone)^2 + (x_target - x_drone)^2
    fsqrt ;; fsqrt does the pop
        ;; ((y_target - y_drone)^2 + (x_target - x_drone)^2 )^ 0.5
    fild dword[d]
    fcomi st0,st1 ;; check if d > ((y_target - y_drone)^2 + (x_target - x_drone)^2 )^ 0.5
    ja DontDestroy
    inc byte[ebx+25] ;; Hit the target
        ;;create new target
    mov ebx,2 ;; resume the target co-routine
    call resume
    ret
DontDestroy:
   ret