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
    oldAlpha: resw 1
    oldSpd: resd 1
    crdnt: resw 1
    rad: resq 1
    clamp: resd 1

section .data
    delta_alpha: dq 0
    newSpeed: dq 0
    bias: dd 0
    tmp87: dq 0

section .rodata
    error: db "Drone not found",10,0
    here: db "here",10,0
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
    fstp qword[tmp87]
    mov ax,word[tmp87]
    mov word[crdnt], ax
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

drones:
    finit
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

    mov eax,0
    mov ebx, [firstDrone]
    mov al,byte[ebx]
    add eax,2
    cmp eax,dword[curr_cor]
    je foundHim
nextDrone:
    mov ebx,dword[ebx+8]
    cmp ebx,0
    je errorSearch
    mov eax,0
    mov al,byte[ebx]
    cmp eax,dword[curr_cor]
    je foundHim
    jmp nextDrone
foundHim:;;ebx points to the right drone

    mov ax, word[ebx+5]
    mov word[oldAlpha],ax
    mov eax,dword[ebx+13]
    mov dword[oldSpd],eax

calcX:
    fild word[oldAlpha]
    fldpi
    fmul
    mov dword[mulNumber],180
    fidiv dword[mulNumber]
    fstp qword[rad]
    fld qword[rad]
    fcos
    fmul dword[oldSpd]
    fld dword[ebx+1] ;; load the x location of the drone
    faddp
    calcBounds
    mov ax, word[crdnt]
    mov word[ebx+1],ax
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
    fild dword[ebx+3]
    faddp        ;; calc the new y position
    calcBounds
    mov ax, word[crdnt]
    mov word[ebx+3],ax



saveNewAlpha:
    fild word[oldAlpha]
    fadd qword[delta_alpha]
    mov dword[clamp],360
    fld dword[clamp]
    fcomi st0, st1
    ja checkAlphaLessThatZero
    fsubp
    fstp qword[tmp87]
    mov ax,word[tmp87]
    mov word[ebx+5],ax
    jmp changeSpeed
checkAlphaLessThatZero:
    fsub dword[clamp];; make st0 = 0
    fcomi st0, st1
    jb dontDoAThing
    fadd dword[clamp]
    faddp
    fstp qword[tmp87]
    mov ax,word[tmp87]
    mov word[ebx+5],ax
    jmp changeSpeed
dontDoAThing:
    faddp
    fstp qword[tmp87]
    mov ax,word[tmp87]
    mov word[ebx+5],ax

changeSpeed:
    fild word[newSpeed]
    fadd dword[ebx+13]
    mov dword[clamp],100
    fld dword[clamp]
    fcomi st0, st1
    ja dontCutYet
    fstp qword[tmp87] ;; speed = 100
    mov eax,dword[tmp87]
    mov dword[ebx+13],eax
    jmp newPosend
dontCutYet:
    fsub dword[clamp]
    fcomi st0, st1
    jb newSpeedy
    fstp qword[tmp87] ;; the speed is Zero
    mov eax,dword[tmp87]
    mov dword[ebx+13],eax
    fstp qword[tmp87] ;; clear the x87 stack
newSpeedy:
    faddp
    fstp qword[tmp87] ;; save the new speed
    mov eax,dword[tmp87]
    mov dword[ebx+13],eax
newPosend:
    mov esp,ebp
    pop ebp
    ret

; (*) Do forever
mayDestroy:
    ;;todo: check if the drone can destroy the target --> ask forum
    call randomAlpha
    call speedChange
    call createTarget

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