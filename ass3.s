STKSZ equ 16396
droneSPP equ 20
targetSPP equ 12
SPP	equ	8
  global DronesArray
  global numberOfDrones
  global target_x
  global target_y
  global maxDistance
  global seed
  global numOfCycles
  global stepsToPrint
  global GRandomFlaot
  global IDOfDrone
section	.rodata ; const data
format_string1: db "%d" , 0 
format_string12: db "%s" , 0 
format_string2: db "%d" ,10, 0 
format_string3: db "%f",10 , 0
format_string4: db "%.1f" ,10 , 0
format_string6: db "%f" ,10 , 0
MAXINT: dw 0xFFFF
var50: dq 50.0
var2: dq 2.0
var360: dq 360.0
%xdefine droneSize 20
;%xdefine MAXINT 65535


section	.bss  ;lo m2ot7al
    CURR:	resd	1
    stackHeadP: resd 1
    SPMAIN:	resd	1
        DronesArray: resd 1

section .data ; mshtanem
    numberOfDrones: dd 0
    numOfCycles: dd 0
    stepsToPrint: dd 0
    maxDistance: dd 0
    seed: dd 0
    tempDronearray: dd 0
    stackP: dd 0
    tmpStackP: dd 0
    RandomFlaot: dd 0
    GRandomFlaot: dd 0 ; global
    printThread: dd 0
    targetThread: dd 0
    schedulerThread: dd 0
    target_x: dd 0
    target_y: dd 0
    IDOfDrone: dd 0
    counter: dd 1
    


section .text
  align 16


  global main

  extern printFunc
  extern SchFunc
  extern funcDrone
  extern targetFunc
  extern createTarget1
  extern printf
  extern fprintf 
  extern malloc 
  extern free 
  extern sscanf


  global resumeSCH
  global SchFunc
  global end_co
  global scalingProc
  global resumeTarget
  global resumePrinter
  global resumeDrone
  global LFSR
  global scalingAngle



main:
    push ebp
    mov ebp ,esp 
    pushad

    mov esi , [ebp+12]; **argv
    mov ebx , 0 ; counter
loop:
    inc ebx 
    mov eax, [esi +ebx *4]
    test eax, eax  ;check if null
    je initDrone
    cmp ebx , 1 
    je arg1
    cmp ebx , 2
    je arg2
    cmp ebx , 3
    je arg3
    cmp ebx , 4 
    je arg4
    cmp ebx , 5
    je arg5
    jmp loop
arg1:
    push dword numberOfDrones
    push format_string1
    push  eax 
    call sscanf
    add esp , 12
    jmp loop
arg2:
    push dword numOfCycles
    push format_string1
    push  eax 
    call sscanf
    add esp , 12
    jmp loop
arg3:
    push dword stepsToPrint
    push format_string1
    push  eax 
    call sscanf
    add esp , 12
    jmp loop

arg4:
    push dword maxDistance
    push format_string3
    push  eax 
    call sscanf
    add esp , 12
    ;mov  eax , maxDistance
    ;fld dword [eax]
    ;sub esp ,8
    ;fstp qword [esp]                         ;push dword [maxDistance]
    ;push format_string4
    ;call printf
    ;add esp , 12
    jmp loop
arg5:
    push dword seed
    push format_string1
    push  eax 
    call sscanf
    add esp , 12
    jmp loop 
initDrone:
    call createTarget1
    mov dword ebx , [numberOfDrones] ; intialize the drones
    mov eax , 20
    mul ebx;push ebx
    push eax
    call malloc
    add esp , 8
    mov [DronesArray] , eax 
    popad
    ;mov dword [tempDronearray],eax
     ;for here init done without stack for drones
     mov ebx, [DronesArray]
     mov  ecx, 0
fillDrones:;here fill x,y,a,s
    mov eax ,20
    mul ecx 
    add ebx ,eax
    call LFSR
    call scalingProc ; x
    fld dword [GRandomFlaot]
    fstp dword [ebx]
    pushad
    fld dword [ebx]
    sub esp,8
    fstp qword [esp]
    push format_string6
    call printf
    add esp,12
    popad
    call LFSR
    call scalingProc ; y

    fld dword [GRandomFlaot]
    fstp dword [ebx+4]
    call LFSR
    call scalingAngle ; angle
  
    fld dword [GRandomFlaot]
    fstp dword [ebx+8]
    call LFSR
    call scalingProc ; speed
 
    fld dword [GRandomFlaot]
    fstp dword [ebx+12]
    mov dword [ebx+16] , 0 ;destroyed targets
    inc ecx
    cmp dword ecx , [numberOfDrones]
    jl fillDrones
    jmp initStack
;--;-------------------------------------------------------------------------------------- hereeee 
LFSR:
   push ebp
    mov ebp , esp
   pushad
   ;xor esi,esi
   mov esi,1
lfsrloop:
    pushfd
    inc esi
    mov eax, [seed]
    mov ebx ,[seed]
    mov ecx ,[seed]
    mov edx ,[seed]
    shr ax , 0
    shr bx , 2
    xor ax , bx
    shr cx , 3
    shr dx , 5
    xor ax , cx
    xor ax , dx 
    mov ecx , [seed]
    shl ax ,15
    shr cx , 1
    or ax , cx
    mov [seed],ax
    popfd
    cmp dword esi , 16
    jle lfsrloop

    popad 
    mov esp , ebp  ; error
    pop ebp
    ret
;---------------------------------------------------------------------------------------
scalingProc: ; and speed
    push ebp
    mov ebp , esp
    pushad
    fild dword [seed] ;we used filed not fld to converse from integer to float(example : if we got 2 we want 2.0)
    mov dword eax, [MAXINT]
    mov dword [RandomFlaot] , eax
    fidiv dword [RandomFlaot] ; seed /MaxInt
    mov dword [GRandomFlaot] , 100
    fimul dword [GRandomFlaot]
    fstp dword [GRandomFlaot]
    call LFSR               ; get a random number
    fild dword [seed]        ;load seed
    fidiv dword [MAXINT]    ;divide by maxint
    fld qword [var50]
    fmulp 
    fabs
    fstp dword [GRandomFlaot]
    popad 
    mov esp , ebp  ; error
    pop ebp
    ret
;--------------------------------------------------------------------------------------

scalingAngle:
    push ebp
    mov ebp , esp
    pushad
    fild dword [seed] ;we used filed not fld to converse from integer to float(example : if we got 2 we want 2.0)
    mov dword eax,[MAXINT]
    mov dword [RandomFlaot] ,eax
    fidiv dword [RandomFlaot] ; seed /MaxInt
    mov dword [GRandomFlaot] , 360
  fimul dword [GRandomFlaot]
   fstp dword [GRandomFlaot]

    popad 
    mov esp , ebp  ; error
    pop ebp
    ret
;--------------------------------------------------------------------------------------

initStack:
    mov dword eax , STKSZ
    mov ebx , [numberOfDrones]
    mul ebx 
    push  eax 
    call malloc
    add esp , 4
    mov [stackP] , eax
    mov ecx , 1
initDroneStack:
    mov [tmpStackP],eax 
    mov [eax] ,ecx
    add eax ,4
    mov dword [eax], funcDrone; extern flag
    add eax , 4
    mov ebx , eax
    add ebx,STKSZ
    sub ebx,8
    mov [eax],ebx
    mov [stackHeadP] , ebx
    mov ebx , [tmpStackP]
    mov esi , esp  ; save esp value
    mov esp ,[ebx+8]
    push dword [ebx+4] ; push the func
    pushf
    pusha
    mov [ebx+8] , esp
    mov esp , esi
    mov eax , [stackHeadP]
    inc ecx 
    cmp ecx , [numberOfDrones]
    jng initDroneStack

;--------------------------------------------------------------------------
initPrinter:
    mov  eax , STKSZ
    push eax 
    call malloc
    add esp , 4
    mov [printThread] ,eax
    mov dword [eax] , 1
    add eax , 4
    mov dword [eax] ,printFunc
    add eax ,4 
    mov ecx , eax 
    add ecx , STKSZ
    sub ecx , 8 
    mov [eax] ,ecx
    mov eax , [printThread]
    mov esi , esp  ;esi have the current stack pointer 
    mov esp , [eax+8] ; esp point to the printer stack
    push dword [eax+4]
    pushf
    pusha
    mov [eax+8] ,esp 
    mov esp ,esi

    ;finish the printer
    ;same as printer
initTarget:
    mov  eax , STKSZ
    push  eax 
    call malloc
    add esp , 4
    mov [targetThread] ,eax
    mov dword [eax] , 1
    add eax , 4
    mov dword [eax] ,targetFunc
    add eax ,4 
    mov ecx , eax 
    add ecx , STKSZ
    sub ecx , 8 
    mov [eax] ,ecx
    mov eax , [targetThread]
    mov esi , esp  ;esi have the current stack pointer 
    mov esp , [eax+8] ; esp point to the printer stack
    push dword [eax+4]
    pushf
    pusha
    mov [eax+8] ,esp 
    mov esp ,esi

initScheduler:
    mov  eax ,STKSZ
    push eax
    call malloc
    add esp , 4
    mov [schedulerThread] , eax 
    mov dword [eax] ,1
    add eax , 4
    mov dword [eax] , SchFunc 
    add eax , 4
    mov ecx , eax 
    add ecx , STKSZ
    sub ecx , 8 
    mov [eax] ,ecx
    mov eax , [schedulerThread]
    mov esi , esp  ;esi have the current stack pointer 
    mov esp , [eax+8] ; esp point to the printer stack
    push dword [eax+4]
    pushf
    pusha
    mov [eax+8] ,esp 
    mov esp ,esi
    call start_co_from_c
     mov eax,1
    mov ebx,0
    int 0x80
; C-callable start of the first co-routine
; from the class material ------------------------------
start_co_from_c:
	push	ebp
	mov	ebp, esp
	pusha
	mov	[SPMAIN], esp             ; Save SP of main code
	mov	ebx, [schedulerThread]       ; and pointer to co-routine structure
	jmp	do_resume

resume:
	pushf			; Save state of caller
	pusha
	mov	edx, [CURR]
	mov	[edx+SPP],esp	; Save current SP
do_resume:
	mov	esp, [ebx+SPP]  ; Load SP for resumed co-routine
	mov	[CURR], ebx
	popa			; Restore resumed co-routine state
	popf
	ret             ; "return" to resumed co-routine!	

resumeDrone:
    mov edx,0
    mov eax ,[IDOfDrone] ; extern
    mov ebx , STKSZ
    mul ebx
    add eax ,[stackP]
    mov ebx ,eax
    jmp resume

resumePrinter:
    mov ebx , [printThread]
    jmp resume

resumeTarget:
    mov ebx , [targetThread]
    jmp resume

resumeSCH:
    mov ebx , [schedulerThread]
    jmp resume

end_co:
	mov	esp, [SPMAIN]            ; Restore state of main code
	popa
	ret
;--------------------------------------------------------------------------
    