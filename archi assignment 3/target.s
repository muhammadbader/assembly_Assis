extern resume
extern createNewTarget
extern printf

global createTarget

section .data
    dfor: dd "%d",10,0

section .text

;; the createTarget is not a regular function we should be wary of the return address that is added to the drones after calling it because we won't use it 
;; and before calling it we should save the id of the caller drone in th ebx
createTarget:
    
    pushad 
    push ebx
    push dfor
    call printf
    add esp,8
    popad

    push ebx
    call createNewTarget
    pop ebx
    call resume
    jmp createTarget