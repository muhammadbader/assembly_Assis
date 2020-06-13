global scheduler

extern startCo
extern endCo
extern resume
extern k
extern N
extern R
extern printf
extern firstDrone
extern lastDrone

section .data
    activeDrones: dd 0
    minKills: dd 0
section .rodata
    winner: db "The Winner is drone: %d",10,0
    noWinner: db "error we could not find a winner !!!",10,0
section .text
    mov ecx,dword[N]
    mov [activeDrones],ecx
    mov ecx,0 ;; counter for the k
    mov edx,0 ;; counter for the R
    mov ebx,2
scheduler:
    inc ebx
    inc ecx
    inc edx
    call resume
    inc ecx
    cmp ecx,dword[k]
    jb noPrint
    push ebx
    mov ebx,2 ;;printed cor
    call resume
    pop ebx
    mov ecx,0
noPrint:
        ;;if (i/N)%R == 0 && i%(N-1) == 0 //R rounds have passed
        ;; edx deals with the Round Robih
    pushad
    mov esi,edx ;; esi = i
    mov ecx,edx
    mov eax,[N]
    div ecx     ;; eax = i/N
    mov ebx,eax
    mov eax,[R]
    div ebx     ;; (i/N) % R = edx
    cmp edx,0
    jne noElimination
    mov eax,esi ;; eax=i
    mov ecx,[N]
    dec ecx
    div ecx
    cmp edx,0 ;; edx = i % (N-1)
    jne noElimination
    popad 
    mov edx,0 ;; start another round
    ;; here call the func to eliminate one of the drones
    call eliminateOne
    dec dword[activeDrones]
noElimination:
    popad
    inc edx
    cmp dword[activeDrones],1
    je theWinner
    cmp ebx,[N]
    je here
    jmp scheduler
here:
    mov ebx,2
    jmp scheduler

theWinner:  ;; byte 48 indicated dead or alive ;; byte 32 gives the next
    mov ebx,firstDrone
    .winLoop:
        cmp byte[ebx+48],0 ;; 0 indicated is the drone is dead
        jne weHaveAWinner
        cmp dword[ebx+32],0
        je errorNoWinner
        mov ebx,[ebx+32]
    jmp .winLoop
weHaveAWinner:
    mov eax,0
    mov al,byte[ebx]
    push eax
    push winner
    call printf
    add esp,8
    call endCo

errorNoWinner:
    push noWinner
    call printf
    add esp,4
    call endCo

eliminateOne:

    push ebp
    mov esp,ebp
    pushad

    mov ebx,firstDrone
    mov [lastDrone],ebx
        ;; hits = byte 28 in struct
searchFristAlive:
    cmp byte[ebx+48],1
    je .foundOne
    mov ebx,[ebx+32];; if this drone is dead move to the next one
    jmp searchFristAlive
    .foundOne:
        mov eax,0
        mov al,byte[ebx+28]
        mov dword[minKills],eax ;; the starting point 
        mov [lastDrone],ebx ;; lastDrone holds the drone to be destroyed
        mov ebx,[ebx+32]
    .searchMin:
        cmp byte[ebx+48],1 
        je .cmpMin  ;; if this drone is not dead
    .contSeach:
        cmp dword[ebx+32],0
        je .finishSearchMin ;; we got to the end of the drones list
        mov ebx,[ebx+32] ;; move next
        jmp .searchMin

    .cmpMin: 
        mov eax,0
        mov al,byte[ebx+28]
        cmp eax,dword[minKills]
        ja .contSeach
        mov dword[minKills],eax
        mov [lastDrone],ebx
        jmp .contSeach

    .finishSearchMin: 
        mov ebx,lastDrone
        mov byte[ebx+48],0
        
    popad
    pop ebp
    ret