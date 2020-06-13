global main
extern add_print

section .text
main:
    ; int eax = add_print(1, 2); // => 3
    push dword 2
    push dword 1
    call add_print
    add esp, 8

    ; add_print(2, eax); // => 5
    push dword eax
    push dword 1
    call add_print
    add esp, 8

    ; return 0;
    mov eax, 0
    ret
