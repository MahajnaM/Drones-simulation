
section	.rodata ; const data
    formatsting: db "  %.2f__%.2f__%.2f__%.2f__",0
    formatString2: db "x: %.2f , y: %.2f" , 10 ,0
    format:db  "%d",10,10,10,0
    format2:db  "Id: %d,",0
section .text
    align 16
    global printFunc
    extern resumeSCH
    extern printf
    extern fprintf 
    extern DronesArray
    extern numberOfDrones
    extern target_x
    extern target_y

printFunc:
    push ebp
    mov ebp ,esp 
    pushad
    ;-------print target x y-----------
    pushad
    mov eax,target_y
    fld dword [eax]
    sub esp,8
    fstp qword [esp]
    mov eax,target_x
    fld dword [eax]
    sub esp,8
    fstp qword [esp]
    push formatString2
    call printf 
    add esp,20
    popad
    ;---------print active drones ---------
    mov ebx , [DronesArray]
    mov ecx , 0
    mov esi , 1
    ;-------------------------------
dronellop:
    mov eax , 20 
    mul ecx
    add ebx ,eax 
    ;----print the id -------------------
    pushad ;id
    push esi
    push format2
    call printf
    add esp,8
    popad
    ;------------------------------
    pushad

    fld dword [ebx+12]
    sub esp,8
    fstp qword [esp]

    fld dword [ebx+8]
    sub esp,8
    fstp qword [esp]

    fld dword [ebx+4]
    sub esp,8
    fstp qword [esp]

    fld dword [ebx]
    sub esp,8
    fstp qword [esp]
    push formatsting
    call printf
    add esp,36
    popad
    ;----------------------------------------
    pushad
    push dword [ebx+16]
    push format
    call printf
    add esp,8
    popad
    ;-------------------------------
    inc ecx 
    inc esi
    cmp esi , [numberOfDrones]
    jle dronellop
;;-----------------------------------------
    popad
    mov esp,ebp
    pop ebp
call resumeSCH
jmp printFunc




