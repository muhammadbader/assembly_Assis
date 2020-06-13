
extern resume,k,n,end_co



section	.rodata
    align 16                            ; we define (global) read-only variables in .rodata section
global	numco





section .data
    i: dd 1
    tempk: dd 0
    stdr: dd 3



section .bss




section .text
    align 16
    global main
    extern cors
    global scheduler

scheduler:
        xor esi,esi
        xor edi,edi
        
        ; ;dprintf printString,gen
        ; mov eax, [ebp+4]
        ; mov [generations], eax
        ; mov eax, [ebp+8]
        ; mov [steps], eax
        
        ; mov eax, [WorldLength]	; >
        ; mov ebx, [WorldWidth]		; > calculate the number of cell coroutines
        ; imul eax, ebx			; > save the result in num_co
        ; add eax,2
        
        ; ;dprintf aax,eax
        
        ; push eax
        ; mov ebx,eax
        ; sub ebx,2
        ; mov eax,[Gen]
        ; ;dprintf aax,eax
        ; ;dprintf abx,ebx
        ; imul ebx
        ; mov ebx,2
        ; imul ebx
        ; mov ecx,eax
        
        ; pop eax
        
        ; ;dprintf acx,ecx
        
        ;mov dword[stdr],2      
        mov ebx,2
        ;mov ebx,dword[stdr]
        ;call resume
        inc ebx ;inc dword[stdr]             
        ;mov ebx,dword[stdr]
.next:
        call resume
        
        inc ebx      ;  inc dword[stdr]         ;
        ;mov ebx,dword[stdr]
        .p123:
        inc edi
        
        
.ignorit_1:
        cmp edi,[k]
        jl .ignorit_2
        push ebx
        mov ebx,1
        call resume
        pop ebx
        mov edi,0
.ignorit_2:
        ;mov ebx,dword[stdr]
        mov eax,dword[n]
        add eax,3
        cmp ebx,eax
        jl .ignorit_3
        mov ebx,3
        ;mov dword[stdr],ebx
        ;dprintf printString,gen
.ignorit_3:
        loop .next
        call end_co 