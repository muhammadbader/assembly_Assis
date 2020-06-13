        global _target
        extern generate_the_target,resume,printf,getRandom,lfsr,start_state,num2,num3,x_target_scaled,y_target_scaled
section .rodata:
format_string: db "%s", 10,0	; format string
format_float: db "new target:  %.2f", 10,0	; format string

section .data:

hit: db   'hit the target',0
section .text

extern printf
_target:
generate_the_target1:
  call getRandom
  mov bx,word[lfsr]
  mov word[start_state],bx
  mov dword[lfsr],ebx
  p11:
  fild dword[lfsr]
  fidiv dword[num2]
  fimul dword[num3]
  fstp qword [x_target_scaled]
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
  
    xor ebx,ebx
    call resume             ; resume scheduler
   
    jmp _target