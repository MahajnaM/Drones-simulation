STKSZ equ 16*1024 +12
droneSPP equ 20
targetSPP equ 12
SPP	equ	8
section	.bss  ;lo m2ot7al
    CURR:	resd	1
    stackHeadP: resd 1
    SPMAIN:	resd	1

section .data ; mshtanem
    heaDrone: dd 0
    cur_x: dd 0
    cur_y: dd 0
    cur_speed: dd 0
    cur_angle: dd 0
    new_x: dd 0
    new_y: dd 0
    new_speed: dd 0
    new_angle: dd 0
    helper1: dd 0
    helper2: dd 0
    flag: dd 0
    radian: dd 180
    distance22: dd 0
    length_x: dd 0
    length_y: dd 0
    point_distance: dd 0


section	.rodata ; const data
format_string2: db "%d" ,10, 0 
format_string3: db "%f",10 , 0
format_string4: db "drone_id: %d, curr_x: %f , cur_y: %f, cur_angle:%f, cur_speed: %f",10,10,0
format_string5: db  "drone_id: %d, new_x: %f , new_y: %f, new_angle:%f, new_speed:%f",10,10,0
format_string6: db  "target_x: %f, target_y: %f",10,10,0

section .text
  align 16
  extern DronesArray
  extern numberOfDrones
  extern numOfCycles
  global funcDrone
  extern IDOfDrone
  extern scalingProc
  extern seed
  extern GRandomFlaot
  extern resumeTarget
  extern resumeDrone
  extern IDOfDrone
  extern LFSR
  extern resumeSCH
  extern target_x
  extern target_y
  extern maxDistance
  extern createTarget1
  extern printf
  extern calloc 
  extern free 

  funcDrone:
    push ebp 
    mov    ebp , esp 
    pushad
    mov  eax ,[IDOfDrone]
    mov ebx, droneSPP
    mul ebx 
    mov ecx ,[DronesArray]
    add ecx , eax ; ecx point to the curr drone 

    mov [heaDrone] , ecx ; save the drone 

continue:
    fld dword [ecx] ; old x
    fstp dword [cur_x]
    fld dword [ecx+4] ; old y
    fstp dword [cur_y]
    fld dword [ecx+8] ; old angle
    fstp dword [cur_angle]
    fld dword [ecx+12] ; old speed
    fstp dword [cur_speed]
    ;------------------------------
    call generateAngle
    call generateSpeed
    call ComputePosition
while:
    call mayDestroy
    cmp dword [flag] , 1 
    jne notDestroyed
    jmp while
notDestroyed:
    call generateAngle
    call generateSpeed
    call ComputePosition
    call resumeSCH
    jmp while

mayDestroy:
    push ebp 
    mov ebp , esp
    pushad
    fld dword [maxDistance]
    fmul dword [maxDistance]
    fstp dword [distance22] ; stor distance^2
    
    fld dword [new_x]
    fsub dword [target_x]
    fstp dword [length_x]; x1-x2

    fld dword [new_y]
    fsub dword [target_y]
    fstp dword [length_y] ; y1-y2

    fld dword [length_x]
    fmul dword [length_x]
    fstp dword [length_x] ; (x1-x2)^2
    

    fld dword [length_y]
    fmul dword [length_y]
    fstp dword [length_y] ; (y1-y2)^2

    fld dword [length_x]
    fadd dword [length_y]
    fstp dword [point_distance] 
  
    fld dword [distance22]
    fld dword [point_distance]
    fcomi
    ja missHit  ; the distance betweeen the cordination is bigger than the maxDistance
    mov dword [flag] , 1
    jmp targetDestroyed
missHit:
    mov dword [flag] , 0
targetDestroyed:
    mov  eax , [heaDrone]
    inc dword [eax+16]  ; inc the num of destroyed targets
    call resumeTarget
    popad
    mov esp ,ebp
    pop ebp
    ret


generateAngle:
    push ebp 
    mov ebp , esp
    pushad
    finit 
    call LFSR
    fld dword [seed]

    mov dword [helper1] , 65535
    fidiv dword [helper1]
    mov dword[helper1] , 120
    fimul dword [helper1]
    mov dword [helper1] ,60 
    fisub dword [helper1]
    fadd dword [cur_angle]
    fstp dword [new_angle]
    mov dword [helper1] ,360 
    fild dword [helper1]
    fld dword [new_angle]
    fcomi 
    ffreep
    ja outOfBound ; newAngel > 360
    fld dword [new_angle]
    fldz 
    fcomi
    ffreep
    ja minBound
endAngle:
    popad
    mov esp ,ebp
    pop ebp
    ret

minBound:
    finit
    mov dword [helper1] ,360
    fld dword [new_angle]
    fiadd dword [helper1]
    fstp dword [new_angle] ;
    jmp endAngle
outOfBound:
    mov dword [helper1] ,360
    fld dword [new_angle]
    fisub dword [helper1]
    fstp dword [new_angle] 
    jmp endAngle
;--------------------------------
generateSpeed:
    push ebp 
    mov ebp , esp
    pushad

    finit 
    call LFSR
    fld dword [seed]
    mov dword [helper1] , 65535
    fidiv dword [helper1]
    mov dword[helper1] , 20
    fimul dword [helper1]
    mov dword [helper1] ,10 
    fisub dword [helper1]
    fadd dword [cur_speed]
    fstp dword [new_speed]
    mov dword [helper1] ,100 
    fild dword [helper1]
    fld dword [new_speed]
    fcomi 
    ffreep
    ja maxSpeed ; new > 100
    fld dword [new_speed]
    fldz 
    fcomi
    ffreep
    ja minSpeed
endspeed:
    popad
    mov esp ,ebp
    pop ebp
    ret
minSpeed:
    finit
    mov dword [helper1] ,0
    fild dword [helper1]
    fstp dword [new_speed] ;
    jmp endspeed
maxSpeed:
    finit
    mov dword [helper1] ,100
    fild dword [helper1]
    fstp dword [new_speed] 
    jmp endspeed



;----------------------------------
ComputePosition:
    push ebp 
    mov ebp , esp
    pushad

    finit 
    fldpi
    fmul dword[cur_angle]
    fidiv dword [radian] ; the radian value of current angle in the top of the stack 
    fcos
    fmul dword [cur_speed] ; speed * cos(angel)
    fadd dword [cur_x]
    fstp dword [new_x]
    
    fldpi
    fmul dword[cur_angle]
    fidiv dword [radian] ; the radian value of current angle in the top of the stack 
    fsin
    fmul dword [cur_speed] ; speed * sin(angel)
    fadd dword [cur_y]
    fstp dword [new_y]

;----------check game bounds---------------

    mov dword [helper2] ,100
    fild dword [helper2]
    fld dword [new_x]
    fcomi 
    ffreep
    ja rightBound
    fldz
    fld dword [new_x]
    fcomi
    ffreep
    jb leftBound

upSideDown:
    mov dword [helper2] ,100
    fild dword [helper2]
    fld dword [new_y]
    fcomi 
    ffreep
    ja UpBound
    fldz
    fld dword [new_y]
    fcomi
    ffreep
    jb downBound

UpBound:
    mov dword [helper2] ,100 
    fld dword [new_y]
    fisub dword [helper2]
    fstp dword [new_y]
    jmp finish

downBound:
    mov dword [helper2] ,100 
    fld dword [new_y]
    fiadd dword [helper2]
    fstp dword [new_y]
    jmp finish

rightBound:
    mov dword [helper2] ,100 
    fld dword [new_x]
    fisub dword [helper2]
    fstp dword [new_x]
    jmp upSideDown
leftBound:
    mov dword [helper2] ,100 
    fld dword [new_x]
    fiadd dword [helper2]
    fstp dword [new_x]
    jmp upSideDown

finish:
    mov ecx ,[heaDrone]
    finit
    fld dword [new_x]
    fstp dword [ecx]

    fld dword [new_y]
    fabs
    fstp dword [new_y]
    fld dword [new_y]
    fstp dword [ecx+4]

    fld dword [new_angle]
    fstp dword[ecx+8]

    fld dword [new_speed]
    fstp dword [ecx+12]
    ffreep
    popad
    mov esp ,ebp
    pop ebp
    ret    

    ;------------------------------
