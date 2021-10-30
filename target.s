section	.rodata ; const data
format_string2: db "%d" ,10, 0 
section .text
    align 16
    global targetFunc
    global createTarget1
    extern resumeSCH
    extern printf
    extern fprintf 
    extern DronesArray
    extern numberOfDrones
    extern target_x
    extern target_y
    extern LFSR
    extern scalingProc
    extern GRandomFlaot
    extern resumeDrone
    extern IDOfDrone
targetFunc:
    push ebp
    mov ebp , esp
    pushad
    call createTarget1
    call resumeDrone
    popad
    mov esp ,ebp
    pop ebp
    jmp targetFunc
createTarget1:
    push ebp
    mov ebp , esp
    pushad
    call LFSR
    call scalingProc
    fld dword [GRandomFlaot]
    fstp dword [target_x]
    call LFSR
    call scalingProc
    fld dword [GRandomFlaot]
    fstp dword [target_y]

    popad
    mov esp ,ebp
    pop ebp
    ret


