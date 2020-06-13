global init_co, start_co, end_co, resume,getRandom,start_state,lfsr,curr,head,x_target_scaled,y_target_scaled,beta,d_maxdistance,t,resume,generate_the_target,k,n,num2,num3
extern _drone,generate_delta_alpha,scheduler,printer,_target


maxcors:        equ 100*100+2            ; maximum number of co-routines
stacksz:        equ 16*1024              ; per-co-routine stack size




section	.rodata
    align 16                            ; we define (global) read-only variables in .rodata section
    mess: db "%s fuck of", 10,0
    format_string: db "%s \n", 10,0      ; format string
    format_stringdebug: db "%s", 10,0
    format_stringcalc: db "itsok: ", 0   ; format string
    format_2x: db "%02X" , 0, 0
    format_x: db "%X" , 0, 0
    format_int: db "%d" , 10, 0
    format_float: db "The result is %f", 10, 0
    sscanf_format: db "%d" , 10 ,0
    sscanf_float: db "%f" , 10 ,0
    argcstr:     db `argc = %d\n\0`      ; backquotes for C-escapes
global	numco





section .data
counter: dd 0
forRandom: dd 16
saveax: dd 0
pi: dd 0
n: dd 0
saveN: dd 0
t: dd 0                                  ; Number of targets to destroy to win the game
k: dd 0                                  ; steps tp activate the print
beta: dd 0                               ; angle of drones filed of view
d_maxdistance:dd 0                       ; max distance to destroy target
seed: dd 0                               ; intialize LFSR shift register
;head: dd 4
start_state: dw 0
lfsr: dw 0
bit: dw 0
period: dd 0
x_scaled: dq 0
y_scaled: dq 0
alpha_scaled: dq 0
numOfTargets: dd 0
drone_id: dd 0
x_target_scaled: dq 0
y_target_scaled: dq 0
size_i:
struc drone
     id: resb 1 
     x: resw 1 
     y: resw 1
     alpha: resw 1
     targets: resb 1
     next: resb 4
  endstruc
len: equ $ - size_i

section .bss
stacks: resb maxcors * stacksz           ; co-routine stacks
cors:   resd maxcors                     ; simply an array with co-routine stack tops
curr:   resd 1                           ; current co-routine
origsp: resd 1                           ; original stack top
tmp:    resd 1                           ; temporary value
num2: resb 12
num3: resb 4
head: resb 12





section .text
    align 16
    global main
    extern puts
    extern printf
    extern putchar
    extern sscanf
    extern malloc
    extern calloc
    extern free
    extern fprintf



main:
    push ebp                               ; Prolog
    mov ebp, esp
    push ebx                             ; Callee saved registers
    push esi

    xor ebx, ebx            ; scheduler is co-routine 0
    mov edx, scheduler    
    call init_co            ; initialize scheduler state

    inc ebx                 ; printer i co-routine 1
    mov edx, printer
    call init_co            ; initialize printer state
    
    inc ebx                 ; the target is co-routine 2
    mov edx,_target         ; should make this function
    call init_co            ; init target state



    pusha                   ; push old state
        
    mov edx,ebp             ; move ebp to edx
    add edx,8


    FINIT                                 ;;inital the x87 stack
    mov dword[num2],65535
    mov dword[num3],100
    mov dword[head],0
    mov ebx,dword[head]
    
    mov eax, [ebp + 8]                   ; argc
    push eax
    push argcstr
    call printf                          ; Call libc
    add esp, (2*4)                       ; Adjust stack by 2 arguments

    mov esi, [ebp + 12]                  ; **argv
    mov ebx, 0                           ; Index of argv
    argumentfuncname:
    mov eax, [esi + ebx * 4]            ; *argv[ebx]
    test eax, eax                       ; Null pointer?
    je done                             ; Yes -> end of loop
    push eax                            ; Pointer to string
    push format_string                  ; Pointer to format string
    call printf                         ; Call libc
    add esp, (3*4)                      ; Adjust stack by 3 arguments
    inc ebx
    argument1:
    mov eax, [esi + ebx * 4]            ; *argv[ebx]
    test eax, eax                       ; Null pointer?
    je done                             ; Yes -> end of loop
    push n
    push sscanf_format
    push eax                            ; Pointer to string
    call sscanf
    push dword[n]
    push format_int                     ; Pointer to format string
    call printf                         ; Call libc

    add esp, (3*4)                      ; Adjust stack by 3 arguments
    inc ebx
    argument2:
    mov eax, [esi + ebx * 4]            ; *argv[ebx]
    test eax, eax                       ; Null pointer?
    je done                             ; Yes -> end of loop
    push t
    push sscanf_format
    push eax                            ; Pointer to string
    call sscanf
    push dword[t]
    push format_int                     ; Pointer to format string
    call printf                         ; Call libc
    add esp, (3*4)                      ; Adjust stack by 3 arguments
    inc ebx
    argument3:
    mov eax, [esi + ebx * 4]            ; *argv[ebx]
    test eax, eax                       ; Null pointer?
    je done                             ; Yes -> end of loop
    push k
    push sscanf_format
    push eax                            ; Pointer to string
    call sscanf
    push dword[k]
    push format_int                     ; Pointer to format string
    call printf                         ; Call libc
    add esp, (3*4)                      ; Adjust stack by 3 arguments
    inc ebx
    argument4:
    mov eax, [esi + ebx * 4]            ; *argv[ebx]
    test eax, eax                       ; Null pointer?
    je done                             ; Yes -> end of loop
    push beta
    push sscanf_float
    push eax                            ; Pointer to string
    call sscanf
    add esp, (3*4)                      ; Adjust stack by 3 arguments
    inc ebx
    argument5:
    mov eax, [esi + ebx * 4]            ; *argv[ebx]
    test eax, eax                       ; Null pointer?
    je done                             ; Yes -> end of loop
    push d_maxdistance
    push sscanf_float
    push eax                            ; Pointer to string
    call sscanf
    ; push dword[d_maxdistance]
    ; push format_int                     ; Pointer to format string
    ; call printf                         ; Call libc
    add esp, (3*4)                      ; Adjust stack by 3 arguments
    inc ebx
    argument6:
    mov eax, [esi + ebx * 4]            ; *argv[ebx]
    test eax, eax                       ; Null pointer?
    je done                             ; Yes -> end of loop
    push seed
    push sscanf_format
    push eax                            ; Pointer to string
    call sscanf
    mov eax,dword[seed]
    mov word[start_state],ax
    push dword[seed]
    push format_int                     ; Pointer to format string
    call printf                         ; Call libc
    add esp, (3*4)                      ; Adjust stack by 3 arguments
    inc ebx




  todone:
    mov eax, [esi + ebx * 4]            ; *argv[ebx]
    test eax, eax                       ; Null pointer?
    je done                             ; Yes -> end of loop
    push eax                            ; Pointer to string
    push format_string                  ; Pointer to format string
    call printf                         ; Call libc
    add esp, (3*4)                      ; Adjust stack by 3 arguments
    inc ebx

  done:
    xor eax, eax                         ; Returncode = return(0)
    pop esi                              ; Epilog
    pop ebx
;jmp exit
    
    
  mov dword[drone_id],1
  jmp generate_the_target
  backFromGenerateTheTarget:
  mov edx,dword[n]
  jmp creatingthearray



generate_the_target:
  call getRandom
  mov bx,word[lfsr]
  mov word[start_state],bx
  mov dword[lfsr],ebx
  p11:
  fild dword[lfsr]
  fidiv dword[num2]
  fimul dword[num3]
  fstp qword [x_target_scaled]
  push dword[x_target_scaled+4]
  push dword[x_target_scaled]
  push format_float
  call printf
  call getRandom
  mov bx,word[lfsr]
  mov word[start_state],bx
  mov dword[lfsr],ebx
  p12:
  fild dword[lfsr]
  fidiv dword[num2]
  fimul dword[num3]
  fstp qword [y_target_scaled]
  push dword[y_target_scaled+4]
  mov edx,dword[y_target_scaled]
  point2:
  push dword[y_target_scaled]
  push format_float
  call printf
  jmp backFromGenerateTheTarget

    



creatingthearray:
    mov dword[saveN],edx
    push 36
    call malloc
    mov ecx, dword[drone_id]
    mov dword[eax],ecx
    mov edx,dword[saveN]
    mov dword[numOfTargets],0
    mov ecx,dword[numOfTargets]
    mov dword[eax+28],ecx
    inc dword[drone_id]
    mov ebx,0
    cmp edx,0
    je s_cos

    push_x:
    mov dword[saveax],eax
    call getRandom
    mov bx,word[lfsr]
    mov word[start_state],bx
    mov dword[lfsr],ebx
    p13:
    fild dword[lfsr]
    fidiv dword[num2]
    fimul dword[num3]
    fstp qword [eax+4]
    
    
    push_y:
    mov eax,dword[saveax]
    call getRandom
    mov bx,word[lfsr]
    mov word[start_state],bx
    mov dword[lfsr],ebx
    p14:
    fild dword[lfsr]
    fidiv dword[num2]
    fimul dword[num3]
    fstp qword [eax+12]
   
   
   
   
    push_alpha:
    mov eax,dword[saveax]
    call getRandom
    mov dword[num2],65535
    mov dword[num3],360
    mov bx,word[lfsr]
    mov word[start_state],bx
    mov dword[lfsr],ebx
    p15:
    fild dword[lfsr]
    fidiv dword[num2]
    fimul dword[num3]
    fstp qword [eax+20]


    mov eax,dword[saveax]
    jmp append
    
    cont:
    mov edx,dword[saveN]
    dec edx
    mov dword[num2],65535
    mov dword[num3],100
    jmp creatingthearray
    

    


append:
  mov dword[eax+32],0

  mov ebx,head
  next_element:
  cmp dword[ebx+32],0
  je found_last
  mov ebx,[ebx+32]
  jmp next_element


  found_last:
  mov [ebx +32],eax
  jmp cont



getRandom:
    push ebp            ; Save the stack
    mov ebp, esp
    push eax
    mov eax,0
    mov ebx,0
    mov ecx,0
    mov edx,0
    mov word[period],0

   mov dword[counter],0
    mov ax,word[start_state]
    mov word[lfsr],ax
    mov word[period],0
 lfsr1:
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

    mov ax,0
    mov ax,word[lfsr]

    mov word[bit],bx

    shr ax,1
    shl bx,15
    or ax,bx

    mov word[lfsr],ax
    inc dword[period]
    inc dword[counter]
    cmp dword[counter],16
    jne lfsr1
    pop eax
    mov esp, ebp
    pop ebp
    ret 



s_cos:
xor esi,esi
mov eax,dword[n]
.loop:
  
  cmp eax, 0
  je .endloop    ;the problem is here
        
.init_coroutine:
  mov     ebx, 3
  add     ebx, esi
  mov     edx, _drone
  call init_co
  inc esi
  dec eax
  .p1:
  jmp .loop
        
.endloop:  ;dprintf printString,Board
  popa                    ; reset old state
        
  xor ebx, ebx            ; starting co-routine = scheduler
  call start_co           ; start co-routines


 init_co:
        push eax                  ; save eax (on caller's stack)
        push edx
        mov edx,0
        mov eax,stacksz
        imul ebx                  ; eax = co-routine's stack offset in stacks
        pop edx
        add eax, stacks + stacksz ; eax = top of (empty) co-routine's stack
        mov [cors + ebx*4], eax   ; store co-routine's stack top
        pop eax                   ; restore eax (from caller's stack)

        mov [tmp], esp            ; save caller's stack top
        mov esp, [cors + ebx*4]   ; esp = co-routine's stack top

        push edx                  ; save return address to co-routine stack
        pushf                     ; save flags
        pusha                     ; save all registers
        mov [cors + ebx*4], esp   ; update co-routine's stack top

        mov esp, [tmp]            ; restore caller's stack top
        ret                       ; return to caller

                                         ; ; ebx = co-routine index to start
start_co:
        pusha                            ; save all registers (restored in "end_co")
        mov [origsp], esp                ; save caller's stack top
        mov [curr], ebx                  ; store current co-routine index
        jmp resume.cont                  ; perform state-restoring part of "resume"

                                         ; ; can be called or jumped to
end_co:
        mov esp, [origsp]                ; restore stack top of whoever called "start_co"
        popa                             ; restore all registers
        ret                              ; return to caller of "start_co"

                                         ; ebx = co-routine index to switch to
resume:                                  ; "call resume" pushed return address
        pushf                            ; save flags to source co-routine stack
        pusha                            ; save all registers
        xchg ebx, [curr]                 ; ebx = current co-routine index
        mov [cors + ebx*4], esp          ; update current co-routine's stack top
        mov ebx, [curr]                  ; ebx = destination co-routine index
.cont:
        mov esp, [cors + ebx*4]          ; get destination co-routine's stack top
        popa                             ; restore all registers
        popf                             ; restore flags
        ret                              ; jump to saved return address
exit:
    leave
    ret