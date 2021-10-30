    global SchFunc 
section .rodata 
    format_string2: db "The winner is: %d" ,10 , 0
    format_string: db "counter: %d ,counterPrint: %d, counterRound: %d" ,10 , 0
     msg: db "schfile",10,0
section .text
    align 16
    extern resumeSCH
    extern DronesArray
    extern numberOfDrones
    extern numOfCycles
    extern scalingProc
    extern GRandomFlaot
    extern resumeTarget
    extern resumePrinter
    extern resumeDrone
    extern stepsToPrint
    extern IDOfDrone
    
    extern end_co
    extern printf

section .data
    helper: dd 0
    howmanylost: dd 0
    min: dd 0
    IDlost: dd -1
    counterPrint: dd 0
    counter: dd 0
    counterRound: dd 0
SchFunc:
    mov dword [counter] , 0 ; i counter
    mov dword [counterPrint] , -1 ; counter to prints
    mov dword [counterRound],0 ; counter to rounds
schFunc1:
    push ebp
    mov ebp ,esp
    pushad
    inc dword [counterPrint]
    mov dword ebx , [DronesArray] ; drones array
    mov ecx, [counter] ;; counter
    mov dword eax ,20
    mul ecx ; eax has the current id drone
    add ebx,eax ; ebx now point to the current dorne 
    cmp dword [ebx], -101  ;if x =-1
    je continue
    mov dword edx,[counter]
    mov dword [IDOfDrone],edx ;idof drone has the active drone id
    call resumeDrone

    ; ***
continue:
    mov dword ecx,[stepsToPrint]
    dec ecx
    cmp dword ecx,[counterPrint]
    jne continue2
    call resumePrinter
    mov dword [counterPrint],-1
continue2:
    mov dword ecx,[counter] ; ecx has drone counter
    inc ecx
    cmp ecx,[numberOfDrones]
    jne continue3
    mov dword [counter],-1
    inc dword [counterRound]
    mov dword ecx, [counterRound]
    cmp ecx, [numOfCycles]
    jne continue3
    mov dword [counterRound],0
    call turnoff
continue3:
    inc dword [counter]
    mov dword edx, [howmanylost]
    mov dword ecx, [numberOfDrones]
    inc edx
    cmp edx,ecx
    jne schFunc1
    call printthewinner
    call end_co
turnoff:
    push ebp
    mov ebp ,esp
    pushad
    mov  ecx  , 0 ; i counter
looop:
    mov eax,[DronesArray]
    mov ebx,[eax+16] ;ebx has num of targets
    cmp dword ebx, [min]
    jnb cont
    mov dword [min],ebx
    mov dword [IDlost],ecx
cont:
    inc ecx
    add eax,20
    cmp dword ecx, [numberOfDrones]
    jl looop

    mov ebx,[IDlost]
    mov ecx, [DronesArray]
    mov eax, 20
    mul ebx
    add ecx,eax
    mov dword [ecx],-101
    inc dword [howmanylost]
    popad
    mov esp ,ebp 
    pop ebp
    ret

printthewinner:
 push ebp
    mov ebp ,esp
    pushad
    mov ebx,0
lop:
    mov ecx,[DronesArray]
    mov dword eax,20
    mul ebx ; eax has 20*i
    add ecx,eax
    cmp dword [ecx],-101
    jne print
    inc ebx
    jmp lop
print:
    inc ebx
    push ebx
    push format_string2
    call printf
    add esp,8
    mov esp ,ebp 
    pop ebp
    ret
