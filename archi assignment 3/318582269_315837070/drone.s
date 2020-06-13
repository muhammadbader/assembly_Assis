global _drone,generate_delta_alpha
extern getRandom,start_state,lfsr,curr,head,x_target_scaled,y_target_scaled,beta,d_maxdistance,t,resume


section	.rodata
format_float: db "The result is %f", 10, 0
format_string: db "%s \n", 10,0      ; format string
format_int: db "inte: %u", 10,0	; format string
winerMessage: db "Drone id %d: I am a winner", 10,0	; format string
section .data
winMessage: db   'Drone id %s: I am a winner',0
delta_alpha_scaled: dq 0
delta_d_scaled: dq 0
num4: dd 0
pi: dd 0
radian: dq 0
new_x: dq 0
new_y: dq 0
gama: dq 0
y1y2: dq 0
x1x2: dq 0
xx: dq 0
curr_id: db 0
curr_alpha: dq 0
curr_targets: db 0
minus: dq 0


section .bss
num2: resb 12
num3: resb 4
section .text
    extern printf

_drone:
    FINIT
    call generate_delta_alpha
    call generate_delta_d
    jmp loop_drone
    contAfterLoop:
    jmp mayDestroy
     



generate_delta_alpha:
  push ebp
  mov ebp,esp
  mov dword[num2],65535
  mov dword[num3],120
  call getRandom
  mov bx,word[lfsr]
  mov word[start_state],bx
  mov dword[lfsr],ebx
  p18:
  fild dword[lfsr]
  fidiv dword[num2]
  fimul dword[num3]
  mov dword[num4],60
  fisub  dword[num4]
  fstp qword [delta_alpha_scaled]
  mov esp,ebp
  pop ebp
  ret 



generate_delta_d:
  push ebp
  mov ebp,esp
  mov dword[num2],65535
  mov dword[num3],50
  call getRandom
  mov bx,word[lfsr]
  mov word[start_state],bx
  mov dword[lfsr],ebx
  p19:
  fild dword[lfsr]
  fidiv dword[num2]
  fimul dword[num3]
  fstp qword [delta_d_scaled]
  mov esp,ebp
  pop ebp
  ret 



loop_drone:
   push ebx
   mov ebx, head                        ; Address of the first element
   push eax
   pop eax
   mov edx,dword [ebx]
   cmp edx,dword[curr]
   je p1
   next_drone:
   mov ebx, [ebx + 32]
   mov edx,dword [ebx]
   add edx,2
   cmp edx,dword[curr]
   jne next_drone
   p1:
   fld qword [ebx + 20]
   fld qword[delta_alpha_scaled]
   fadd
   p3:
   mov dword[num4],360
   fild dword[num4]
   fcomi st0,st1      ;compare ST(0) to the integer value on the stack
   ;fwait             ;insure the previous instruction is completed
   ja isLessThanZeroAlpha
   fsubp st1,st0
   fst qword[curr_alpha]
   fst qword[ebx + 20]
   jmp convertToRadians
   isLessThanZeroAlpha:
   fstp dword[xx]
   mov dword[num4],0
   fild dword[num4]
   fcomi st0,st1      ;compare ST(0) to the integer value on the stack
   ;fwait             ;insure the previous instruction is completed
   jb dontwraparoundalpha
   fstp qword[xx]
   mov dword[num4],360
   fild dword[num4]
   fadd 
   fst qword[curr_alpha]
   fstp qword[ebx + 20]
   jmp convertToRadians
   dontwraparoundalpha:
   fstp qword[xx]
   fst qword[curr_alpha]
   fstp qword[ebx + 20]
   
   convertToRadians:
   mov dword[num2],65535
   mov dword[num3],180
   fldpi
   fld qword[ebx + 20]
   fmul 
   fidiv dword[num3]
   fstp qword[radian]
   fld qword[radian]
   fcos
   fmul qword[delta_d_scaled]
   fld qword [ebx + 4]
   fadd
   mov dword[num4],100
   fild dword[num4]
   fcomi st0,st1
   fwait
   ja isLessThanZero
   fsubp st1,st0
   fst qword[new_x]
   fstp qword[ebx+4]
   jmp p4
   isLessThanZero:
   fstp qword[xx]
   mov dword[num4],0
   fild dword[num4]
   fcomi st0,st1
   fwait
   jb dontwraparoundx
   mov dword[num4],100
   fstp qword[xx]
   fild dword[num4]
   fadd
   fst qword[new_x]
   fstp qword[ebx+4]
   jmp p4
   dontwraparoundx:
   fstp qword[xx]
   fst qword[new_x]
   fstp qword[ebx+4]
   p4:
   fld qword[radian]
   fsin
   fmul qword[delta_d_scaled]
   fld qword [ebx + 12]
   fadd
   mov dword[num4],100
   fild dword[num4]
   fcomi st0,st1
   fwait
   ja isLessThanZero1
   fsubp st1,st0
   fst qword[new_y]
   fstp qword[ebx+12]
   jmp done2
   isLessThanZero1:
   fstp qword[xx]
   mov dword[num4],0
   fild dword[num4]
   fcomi st0,st1
   fwait
   jb dontwraparoundy
   mov dword[num4],100
   fstp qword[xx]
   fild dword[num4]
   fadd
   fst qword[new_y]
   fstp qword[ebx+12]
   jmp done2
   dontwraparoundy:
   fstp qword[xx]
   fst qword[new_y]
   fstp qword [ebx + 12]

  done2:

    pop ebx
    jmp contAfterLoop

mayDestroy:
p2:
    
    fld qword[y_target_scaled]     ;dont change in the original code make it qword
    fld qword[new_y]
    fsub 
    fstp qword[y1y2]
    
    fld qword[x_target_scaled]    ;dont change in the original code make it qword
    fld qword[new_x]
    fsub
    fstp qword[x1x2]


    fld qword[y1y2]
    fld qword[x1x2]
    fpatan                            ;if the difference in angles is greater than pi, add 2*pi to the smaller angle before doing the subtraction
    fldpi
    mov dword[num4],2
    fidiv dword[num4]
    fcomi st0,st1
    ja dontwraparoundpatan
    fstp qword[xx]
    fldpi
    fsub
    jmp cont3
    dontwraparoundpatan:
    fstp qword[xx]
    cont3:
    fst qword[gama]
    mov dword[num3],180
    fimul dword[num3]
    fldpi
    fdiv
    mov dword[num4],360
    fild dword[num4]
    fcomi st0,st1      ;compare ST(0) to the integer value on the stack
    fwait             ;insure the previous instruction is completed
    ja dontwraparoundg
    fsubp st1,st0
    fst qword[gama]
    dontwraparoundg:
    fstp qword[xx]
    fst qword[gama]
    fld qword[curr_alpha]
    p20:
    fsub 
    fabs 
    mov dword[num3],180
    fild dword[num3]
    fcomi st0,st1
    ja dontwraparoundgama
    fstp qword[xx]
    fstp qword[xx]
    fld qword[gama]
    fld qword[curr_alpha]
    p21:
    fcomi st0,st1
    jb add2pitocurr_alpha
    fstp qword[xx]
    fstp qword[gama]
    mov dword[num4],360
    ;fldpi
    ;fimul dword[num4]
    fild dword[num4]
    fld qword[gama]
    fadd
    fld qword[curr_alpha]
    fsub
    fst qword[minus]
    fld qword[minus]
    jmp dontwraparoundgama
    add2pitocurr_alpha:
    fstp qword[xx]
    fstp qword[curr_alpha]
    mov dword[num4],360
    fld qword[curr_alpha]
    fild dword[num4]
    fadd
    fld qword[gama]
    fsub
    fst qword[minus]
    fld qword[minus]
    dontwraparoundgama:
    fstp qword[xx]
    fabs
    fld dword[beta]
    fstp qword[xx]
    fld qword[xx]
    p22:
    fcomi st0,st1 
    ja cont1
    jmp done_check
    cont1:
    fld qword[y1y2]
    fld qword[y1y2]
    fmul
    fld qword[x1x2]
    fld qword[x1x2]
    fmul
    fadd 
    fsqrt
    fld dword[d_maxdistance]
    fcomi st0,st1
    ja cont2
    jmp done_check
    cont2:
    mov ebx, head 
    mov edx,dword [ebx]
    cmp edx,dword[curr]
    je p5
   next_drone1:
   mov ebx, [ebx + 32]
   mov edx,dword [ebx]
   add edx,2
   cmp edx,dword[curr]
   jne next_drone1
   p5:
    

    mov ecx,dword[ebx+28]
    inc ecx
    mov dword[ebx+28],ecx
    cmp ecx, dword[t]
    je end_game
    mov ebx,2     ;;target co-routine
    jmp callres
    end_game:
    mov ecx,dword[ebx]
    mov dword[curr_id],ecx
    push dword[curr_id]
    push winerMessage
    call printf
    mov ebx,0
    mov eax,1
    int 0x80

    done_check:
    mov ebx,0    ;;scheduler co-routine
    callres:
    call resume
    jmp _drone
