global scheduler
global activeDrones


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
    here2: db "here: %d",10,0
section .text
    
%macro debug 1
    pushad
    push %1
    push here2
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

%macro LifeDrone 0
    push eax
    mov eax,0
    mov al,byte[ebx+30]
        debug eax
    pop eax
%endmacro

scheduler:

    mov ecx,dword[N]
    mov [activeDrones],ecx

    mov ecx,0 ;; counter for the k
    mov edx,0 ;; counter for the R
    mov ebx,2
_scheduler:

    inc ebx
    inc ecx
    inc edx

        ; debug ebx
        ; debug edx

    call resume

        ; debug ebx
        ; debug dword[N]

    cmp ecx,dword[k]
    jb noPrint
    push ebx
        ; debug ebx
    mov ebx,1 ;;printed cor
    call resume
    pop ebx
    mov ecx,0
noPrint:
        ;;if (i/N)%R == 0 && i%(N-1) == 0 //R rounds have passed
        ;; edx deals with the Round Robih
    ; debug ebx
    
    mov esi,edx ;; esi = i
    pushad
    mov eax,edx ;; ecx = i
    mov ecx,[N]
        ; debug ecx
        ; debug eax
    mov edx,0 
    div ecx     ;; eax = i/N
        ; debug eax
        ; debug edx
    ; mov ebx,eax
        ; debug ebx
    cmp eax,0
    je nextCheck ;; if (i/N) = 0 ,no need to check the i/N % R because it is always  = 0
    mov edx,0
    mov ebx,[R]
    div ebx     ;; (i/N) % R = edx
        ; debug edx
        ; debug esi
    cmp edx,0
    jne noElimination
nextCheck:
    mov eax,esi ;; eax = i
        ; debug esi
    mov ecx,[N]
    mov edx,0
    div ecx
        ; debug edx
    cmp edx,0 ;; edx = i % (N)
    jne noElimination
        ; debug esi
    popad 
        ; debug esi
    mov edx,0 ;; start another round
    pushad
            ;; here call the func to eliminate one of the drones
        
        ; debug esi

    call eliminateOne
    dec dword[activeDrones]
noElimination:
    popad

        ; debug ebx

    cmp dword[activeDrones],1
    je theWinner
    mov eax,ebx
    sub eax,2

        ; debug eax
    
    cmp eax,[N]
    je here
    jmp _scheduler
here:
    ; debug ebx
    mov ebx,2
    jmp _scheduler

theWinner:  ;; byte 48 indicated dead or alive ;; byte 32 gives the next
    mov ebx,[firstDrone]
        
    .winLoop:
            ; droneID
            ; LifeDrone
        cmp byte[ebx+30],0 ;; 0 indicated is the drone is dead
        jne weHaveAWinner
        cmp dword[ebx+26],0
        je errorNoWinner
        mov ebx,[ebx+26]
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
        ; debug ebx
    push ebp
        ; debug ebx
    mov ebp,esp
        ; debug ebx
    pushad
        ; debug ebx
    mov ebx,[firstDrone]
    mov [lastDrone],ebx
        ;; hits = byte 25 in struct

        ; droneID

searchFristAlive:
    cmp byte[ebx+30],1
    je .foundOne
        ; droneID
    mov ebx,[ebx+26];; if this drone is dead move to the next one
    jmp searchFristAlive
    .foundOne:
            ; debug dword[activeDrones]
            ; debug esi
        mov eax,0
        mov al,byte[ebx+25]
        mov dword[minKills],eax ;; the starting point 
        mov [lastDrone],ebx ;; lastDrone holds the drone to be destroyed
        mov ebx,[ebx+26]
    .searchMin:
        cmp byte[ebx+30],1 
        je .cmpMin  ;; if this drone is not dead
    .contSeach:
        cmp dword[ebx+26],0
        je .finishSearchMin ;; we got to the end of the drones list
        mov ebx,[ebx+26] ;; move next
        jmp .searchMin

    .cmpMin: 
        mov eax,0
        mov al,byte[ebx+25] ;; check if we have a new min
        cmp eax,dword[minKills]
        ja .contSeach
        mov dword[minKills],eax
        mov [lastDrone],ebx
        jmp .contSeach

    .finishSearchMin: 
        mov ebx,[lastDrone]
        mov byte[ebx+30],0 ;; kill the drone
        
    popad
    pop ebp
    ret