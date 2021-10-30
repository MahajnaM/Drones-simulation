section	.rodata			; we define (global) read-only variables in .rodata section
	format_hex: db "%x",10, 0		; format decimal
	global format_decimal
    format_decimal: db "%d",10, 0	; format decimal
	format_string: db "%s",10, 0	; format decimal
	global format_float
    format_float: db "%f",10, 0		; format decimal
	global format_2float
    format_2float: db "%.2f,%.2f",10, 0		; format decimal
	global format_3float
    format_3float: db "%d,%.2f,%.2f,%.2f,%d" , 10, 0		; format decimal
	global var120
    var120: dq 120.0					;
	global var360
    var360: dq 360.0				
	global var100
    var100: dq 100.0				                        ;
	global var60
    var60: dq 60.0				                        ;
	global var50
    var50: dq 50.0				                        ;
	var6: dq 6.0				                        ;
	global var2
    var2: dq 2.0				                        ;
	global one_eighty
    one_eighty: dq 180.0			                        ;
	global format_winner
    format_winner: db "Drone id %d: I am a winner" ,10 ,0;
	global maxint
    maxint: dw 0xFFFF                                      ;
	STKSIZE equ 16*1024

	
section .bss			; we define (global) uninitialized variables in .bss section
    global droneArr
    global numOfDrones
    numOfDrones: resb 4           	; 
    global numOfTargets
    numOfTargets: resb 4           	; 
    global stepBefPrint
    stepBefPrint: resb 4           	; 
    global beta
    beta: resb 8           			; 
    global maxDistance
    maxDistance: resb 8           	; 
    seed: resb 4           			;	 
	global targetX
    targetX: resb 8                 ;
	global targetY
    targetY: resb 8                 ;
	droneArr: resb 4                ;
	global gamma
    gamma: resb 8                	;
	global distance
    distance: resb 8                ;
	indArgv: resb 4                 ;
	indlocalArg: resb 4             ;
	global schedularLoop
    schedularLoop: resb 4			;
	global itersum
    itersum: resb 4					;
	global win
    win: resb 4						;
	global end_co_func
    end_co_func: resb 4				;
	global end_co_func
	global resume

%macro startFunc 1 
      push ebp 
      mov ebp, esp 
      sub esp, %1 
%endmacro  
    
%macro endFunc 0
	mov esp, ebp	
	pop ebp
	ret
%endmacro  

section .text
align 16
    global main 
    extern sscanf 	
    extern printf 
    extern malloc  
    extern free  
    extern SPMAIN
    extern schedularCO
    extern CODEP
    extern SPT
    extern CURR
    extern CorsArray
    extern SPP
    extern drone
    extern printCO
    extern targetCO
    extern schedule
    extern myPrint
    extern makeTarg
    global one_eighty
    global var360
    global var100
    global randAng
    global randDist
    global distance
    global numOfTargets
    global format_winner
    global win
    global targetY
    global targetX
    global gamma
    global beta
    global maxDistance
    global format_2float
    global format_3float
    global numOfDrones
    global var2
    global schedularLoop
    global itersum
    global stepBefPrint
    global end_co
    global format_float
	global format_decimal



; start co-routine mechanism
startCo:
	push ebp
	pushad					;save register of main
	mov [SPMAIN],esp        ;save esp of main
	mov ebx,schedularCO	;get pointer to schedular struct 
	jmp do_resume			;resume a schedular co routine 


; End co-routine mechanism
end_co:
	mov	ESP, [SPMAIN]            ; Restore state of main code
	pop	EBP
	popad
	ret
	
co_init:
	startFunc 0
    mov ebx,[ebp+8]			;get cor struct pointer
    mov eax, [ebx]			;get pointer to Coi function
    mov [SPT], esp 			;save ESP val
    mov esp,[EBX+8] 		;pointer to coi stack
    push eax
    pushfd
    pushad  
    mov [ebx+8], ESP 		;save new SPi val
    mov ESP,[SPT]			;restore esp val
    endFunc
   

    
; EBX is pointer to co-init structure of co-routine to be resumed
; CURR holds a pointer to co-init structure of the curent co-routine
resume:
	pushf			; Save state of caller
	pusha
	mov	EDX, [CURR]
	mov	[EDX+8],ESP	; Save current SP
do_resume:
	mov	ESP, [EBX+8]  ; Load SP for resumed co-routine
	mov	[CURR], EBX	
	popa			; Restore resumed co-routine state
	popf
	ret                     ; "return" to resumed co-routine!


	
	
init:
    startFunc 0
    mov ecx, 0
    mov eax,[numOfDrones]				;get number of drones
    inc eax
    mov ebx,16					
    mul ebx 					;mul eax by 16( four int fields for each drone)
    pushad
    push eax
    call malloc	
    add esp,8
    mov [CorsArray],eax 			;now CorsArray point to the allocated memory on heap
    popad
    mov ecx ,0
	
   
initLoop:
	mov ebx, [CorsArray]		;edx=corsarray[0]->func
	inc ecx
	mov eax, 16					; get curr co-routine
	mul ecx
	add ebx, eax
	mov eax, drone
	mov dword [ebx], eax 		;ebx=corsarray[0]->func
	pushad
    mov eax, STKSIZE			;we going to create stack for cor(i) on the heap
	push eax
    call malloc
    mov [gamma], eax
    add esp,4
    popad
    mov eax , [gamma]
    mov [ebx+4], eax			; get stack
    add eax,STKSIZE				; point to start of stack
    mov dword [ebx+8],eax       ;CorsArray[i]->stack=stack on the heap
    mov eax, 32
    mul ecx
    mov edx,[droneArr]
    add edx,eax 				;drone array start from index 1
    mov [ebx+12], edx
    pushad
    push ebx
    call co_init
    add esp,4
    popad
    
    cmp ecx, [numOfDrones]      ; if we checked all drones
    jne initLoop


    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;init print;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    mov edx, printCO
    mov ebx ,myPrint            ; address of` function print
    mov [edx], ebx
    pushad
    push dword printCO
    call co_init
    add esp,4
    popad


    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;init target;;;;;;;;;;;;;;;;;;;;;;;;
    mov edx ,targetCO		 	;targetCO->func=makeTarget()
    mov ebx ,makeTarg            ; address of` function target
    mov [edx], ebx
    pushad
    push dword targetCO
    call co_init
    add esp,4
    popad

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;scheduler init;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    mov edx ,schedularCO		 ;schedularCo->func=schdule()	
    mov ebx ,schedule            ; address of` function schdule
    mov [edx], ebx			

    pushad
    push dword schedularCO
    call co_init
    add esp,4
    popad
    endFunc



randDist:    ;;;;;;;;; makes random angle
    startFunc 0 
    call rand               ; get a random number
    fild dword [seed]        ;load seed
    fidiv dword [maxint]    ;divide by maxint
    fld qword [var50]
    fmulp st1
    fabs
    endFunc
    
randAng:    ;;;;;;;;; makes random angle
    startFunc 0 
    call rand               ; get a random number
    fild dword [seed]        ;load seed
    fidiv dword [maxint]    ;divide by maxint
    fld qword [var120]
    fmulp st1
	fld qword [var60]
	fsubp st1
    endFunc
    
rand:
    startFunc 0
    mov ecx, 16
randLoop:
    clc                     ; clear carry
    mov eax,0               
    mov al, 0x2D            ; set eax to 101101
    and al, [seed]          ; compute pairty of bits
    jpe noAdd               ;jump if even
    stc                     ;set carry
noAdd:
    rcr word [seed],1       ; shift with carry
    loop randLoop, ecx      ; loop
    endFunc
    
    



print_float:
	startFunc 0
	pushad
	sub esp, 8
;	fstp qword [esp]
	fst qword [esp]
	push format_float
	call printf
	add esp,12
	popad
	endFunc


	
	
main:
	mov eax, 16*1024
	mov eax, STKSIZE
	mov dword [win], 0
	mov dword [indArgv],0		; ind arg from argv
	mov dword [indlocalArg],0	; ind local arg
    mov ebx, [esp+8] 			; save the argv address
inputloop:
	pushad
	mov eax, numOfDrones		;first argument
	add eax, [indlocalArg]		; pointer to which argument we need to change
	push eax					; push the argument which need to be changed
	cmp dword [indArgv], 12		; if beta
	je float_arg
	cmp dword [indArgv], 16		; if distance
	je float_arg
	push format_decimal			; everyone else
	jmp call_sscanf
float_arg:
	add dword [indlocalArg], 4  ; if float, add 4 to index in local vars
	push format_float
call_sscanf:
    mov eax, ebx        
	add eax, 4					; go to argv
	add eax, [indArgv]			; get the arg from argv
	mov eax, [eax]
	push eax
	call sscanf			 		; where sscanf is a pointer to the scanf function
	add esp,12
	popad
	add dword [indArgv], 4
	add dword [indlocalArg], 4
	cmp dword [indArgv], 24	    ; end of loop in 6th argument
	jne inputloop
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;init;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;;;randoms target x
    call randDist               ; random num from 0-50
    fld qword [var2]            ; multipy by 2 (0-100)
    fmulp
    fstp qword [targetX]
    ;;;;;randoms target y
    call randDist               ; random num from 0-50
    fld qword [var2]            ; multipy by 2 (0-100)
    fmulp
    fstp qword [targetY]
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;making drones;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    mov eax, 32                 ; every drone is 32 bytes
    mov ebx, [numOfDrones] 
    inc ebx                     ; drone[0] not exist, we start frome 1
    mul ebx
    pushad
    push eax
    call malloc                 ; make 32* num of drones bytes    ; 0- id 4-t 8-x 16-y 24-alpha
    mov [droneArr], eax
    add esp, 4
    popad
    mov ecx, 0
init_loop:
    inc ecx
    pushad
    mov eax, 32
    mul ecx
    mov edx, [droneArr]         ; get addr of droneArr
    add edx, eax                ; move to current drone
    mov dword [edx], ecx        ; push num of drone
    mov dword [edx+4], 0        ; num of targs destroyed = 0
	;;;;;randoms drone x;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    call randDist               ; random num from 0-50
    fld qword [var2]            ; multipy by 2 (0-100)
    fmulp
    fstp qword [edx+8]
    ;;;;;randoms drone Y;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    call randDist               ; random num from 0-50
    fld qword [var2]            ; multipy by 2 (0-100)
    fmulp
    fstp qword [edx+16]
    ;;;;;randoms drone angle;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	call rand               ; get a random number
    fild dword [seed]        ;load seed
    fidiv dword [maxint]    ;divide by maxint
    fld qword [var360]
    fmulp st1    
	fldpi					; convert head into radians
	fmulp                  	; multiply by pi
	fld qword [one_eighty]
	fdivp	      			; and divide by 180.0
    fstp qword [edx+24]
    popad
    cmp ecx, [numOfDrones]
    jne init_loop
	mov dword [end_co_func], end_co

    call init
    call startCo


freeing:
	push dword [droneArr]
    call free
	add esp,4
    mov ecx, 0


freeStack:
    mov ebx,[CorsArray]
	inc ecx
	mov eax,16			;index of co-routine
	mul ecx				;mul by counter 
	add ebx,eax			;ebx point to curr drone
	;add ebx,4			;point to start of stack of the curr drone		
	pushad
	push dword [ebx+4]
	call free
	add esp,4
	popad
	cmp ecx,[numOfDrones]
	jne freeStack


	push dword [CorsArray]
	call free
	add esp,4
    ret





