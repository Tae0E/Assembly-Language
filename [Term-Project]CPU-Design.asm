;------------------------------------------------
;PROGRAM NAME : CPUDesign.asm
;PURPOSE? :To design an internal structure of a processor and elevate assembly programming skill
;
; USED PROCEDURES
;	* M_RETURN_MICRO : 마이크로모드에서 excution할 때 decode하는 함수
;	* M_RETURN : INTTRUPT상태에서 원래상태로 돌아가는 함수
;	* MD_MICRO : 마이크로 모드 셋팅 함수
;	* CMD_MACRO : 매크로 모드 셋팅 함수
;	* CMD_EXECUTE : 매크로 모드 c 명령어 처리 함수
;	* CMD_MEMORY : 메모리 입력을 위한 m명령어 처리 함수
;	* CMD_DISPLAY : 현재 Register의 값과 pc의 값을 출력하는 함수
;	* CHECK_HEX : 메모리, 주소 입력시 16진수값 파싱 함수
;	* CMD_PC : PC 입력 함수
;	* EXIT : 프로그램 종료 함수
;	* PUTC : 케릭터 단위 출력 함수
;	* NEWLINE : CRLF 출력 함수
;	* GETC : 케릭터 단위 입력 함수
;	* PUTS : 문자열 단위 출력 함수
;	* PHEX : 헥스 출력 함수
;	* DISPLAY : 레지스터 출력 함수
;	* D_OUTPUT : 메모리의 주소와 명령어 출력 함수
;	* M_JMP : JMP 명령어를 구현
;	* M_JA : JA 명령어를 구현
;	* M_JB : JB 명령어를 구현
;	* M_JE : JE 명령어를 구현
;	* M_SUB : SUB 명령어를 구현
;	* M_MOV : MOV 명령어를 구현
;	* M_ADD : ADD 명령어를 구현
;	* M_CMP : CMP 명령어를  구현
;	* M_OR : OR 명령어를 구현
;	* M_HALT : HALT 명령어를 구현
;	* M_NOT : NOT 명령어를 구현
;	* M_AND : AND 명령어를 구현
;	* M_MUL : MUL 명령어를 구현
;	* M_SHIFT : SHIFT 명령어를 구현
;	* M_DIV : DIV 명령어를 구현
;PROGRAMED BY SEOK SEUNGWOOK WITH MASM 5.0
;
;PROGRAM VERSION
;   Creation Date :Nov 23,2016
;   Last Modified On Dec 18,2016
;------------------------------------------------
MAIN SEGMENT
ASSUME CS:MAIN, DS:DATA
   MOV AX,DATA
   MOV DS,AX
;------------------------------------------
 print macro argument                   ; 문자열 출력 매크로
 mov ah, 09
 mov dx, offset argument
 int 21h
 endm
   MOV MODE, 01h                         ; 기본 모드는 macro
   MOV INTERRUPT_SWITCH,0				;인터럽트상황인지 아닌지 판단
START_GETCMD:
   MOV BX, OFFSET CMDLINE
   MOV CX, 40

   MOV DL, '>'
   CALL PUTC
   MOV DL, ' '
   CALL PUTC
START_READCMD_LOOP:
   CALL GETC				;문자를 입력받는다.
   CMP AL, 0DH				;---------------
   JE START_SWITCH			;a:macro mode
   MOV [BX], AL				;u:micromode
   INC BX					;---------------
   LOOP START_READCMD_LOOP	
   CMP CX, 0				
   JNE START_SWITCH			
   CALL NEWLINE				
START_SWITCH:				
   MOV BX, OFFSET CMDLINE	
   CMP CX, 39				
   MOV AL, [BX]				
   JNE CMP_EXIT				

   CMP AL, 'a'			
   JNE CMP_MICRO				
   CALL CMD_MACRO		;입력받은 값이 'a'이면 macro mode로 이동	
   JE MACRO_GETCMD		
   CMP_MICRO:			
   CMP AL, 'u'					
   JNE CMP_EXIT				
   CALL CMD_MICRO		;입력받은 값이 'u'이면micro mode로 이동
   JE MICRO_GETCMD1		
   CMP_EXIT:			
START_WRONG_CMD:				
   MOV DX, OFFSET STR_WRONGCMD	
   CALL PUTS					
   CALL NEWLINE					
   JMP START_CLEARCMD			
START_CLEARCMD:					;입력받은값이 'a','u'가 아니면 입력받은값을
   MOV BX, OFFSET CMDLINE		;초기화 시켜주고 문자 입력받는곳으로 이동
   MOV CX, 40					
START_CLEARCMD_LOOP:			
   XOR AX, AX					
   MOV [BX], AL					
   INC BX						
   LOOP START_CLEARCMD_LOOP		
   JMP START_GETCMD				




MACRO_GETCMD:					;----marco mode로 진입----
   MOV BX, OFFSET CMDLINE		
   MOV CX, 40					

   MOV DL, '>'
   CALL PUTC
   MOV DL, ' '
   CALL PUTC

MACRO_READCMD_LOOP:				
   CALL GETC					;문자를 입력받는다 
   CMP AL, 0DH					;----------------
   JE MACRO_SWITCH				;pc #:program counter값입력
   MOV [BX], AL					;m[#1] #2:메모리 #1(memory)에 #2(value)저장
   INC BX						;u:micro mode로 변경
   LOOP MACRO_READCMD_LOOP		;e:프로그램 종료
   CMP CX, 0					;d:display
   JNE MACRO_SWITCH				;c:excute
   CALL NEWLINE					;---------------
MACRO_SWITCH:					
   MOV BX, OFFSET CMDLINE		
   CMP CX, 39					
   MOV AL, [BX]					
   JNE CASE_PC					


   CMP AL, 'u'					;입력받은 값이 'u'이면 micro mode로 변경
   JE CASE_MICRO				
   CMP AL, 'e'					;입력받은 값이 'e'이면 프로그램 종료
   JE MACRO_CASE_EXIT			
   CMP AL, 'd'					;입력받은 값이 'd'이면 register,pc 출력
   JNE MACRO_CASE_C				
   CALL D_OUTPUT				
   JE CASE_DISPLAY				
   MACRO_CASE_C:				;입력받은 값이 'c'이면 현재 pc에있는 명령어excute
   CMP AL, 'c'					
   JE MACRO_CASE_CONTINUE		
   JNE MACRO_CMP_EXIT			
MACRO_CASE_CONTINUE:			
   CALL CMD_EXECUTE				;'c'를 입력받으면 현재 pc의 있는 값 decode
   JMP MACRO_CLEARCMD	
   MICRO_GETCMD1:							;징검다리
   JMP MICRO_GETCMD							;징검다리
CASE_DISPLAY:
   CALL CMD_DISPLAY				;'d'를 입력받으면 CMD_DISPLAY함수(상태 출력)를 호출 
   JMP MACRO_CLEARCMD
CASE_MICRO:
   CALL CMD_MICRO						;'u'를 입력받으면 micro mode로
   MOV BX, OFFSET CMDLINE				;이동하기 전에 사용하지 않는 변수들을
   MOV CX, 40							;초기화시켜주고
MACRO_CLEARCMD_LOOP_To_MICRO:			;micro mode(JMP MICRO_GETCMD)로 이동한다
   XOR AX, AX							
   MOV [BX], AL							
   INC BX								
   LOOP MACRO_CLEARCMD_LOOP_To_MICRO	
   MOV BX,PC							
   MOV MAR,BX				; 마이크로 모드로 가기전 PC값을 MAR에 저장해둔다
   JMP MICRO_GETCMD						
MACRO_CASE_EXIT:
   CALL EXIT

CASE_PC:					
   CMP AL, 'p'				;'pc #' 을 입력 받으면
   JNE CASE_MEMORY			;pc값을 #으로 초기화 시켜준다
   MOV AL, [BX+1]			
   CMP AL, 'c'				
   JNE MACRO_WRONG_CMD		
   MOV AL, [BX+2]			
   CMP AL, ' '				
   JNE MACRO_WRONG_CMD		
   CALL CMD_PC				
   JMP MACRO_CLEARCMD		
CASE_MEMORY:				
   CMP AL, 'm'				;'m[#1] #2'을 입력 받으면 
   JNE MACRO_WRONG_CMD		;메모리 #1(memory)에 #2(value)을 저장한다
   MOV AL, [BX+1]			
   CMP AL, '['				
   JNE MACRO_WRONG_CMD		
   CALL CMD_MEMORY			

   JMP MACRO_CLEARCMD
   MACRO_CMP_EXIT:
MACRO_WRONG_CMD:				;메뉴얼에 없는 값을 입력받으면
   MOV DX, OFFSET STR_WRONGCMD	;오류 메세지를 출력한다
   CALL PUTS					
   CALL NEWLINE					
   JMP MACRO_CLEARCMD			

MACRO_CLEARCMD:					;명령어 처리가 끝나고
   MOV BX, OFFSET CMDLINE		;macro mode 처음으로 이동하기전
   MOV CX, 40					;사용했던 변수들을
MACRO_CLEARCMD_LOOP:			;초기화 시켜준다
   XOR AX, AX					
   MOV [BX], AL					
   INC BX						
   LOOP MACRO_CLEARCMD_LOOP		
   JMP MACRO_GETCMD				

MICRO_GETCMD:					;----micro mode로 진입----
   MOV BX, OFFSET CMDLINE
   MOV CX, 40

   MOV DL, '>'
   CALL PUTC
   MOV DL, ' '
   CALL PUTC
MICRO_READCMD_LOOP:				
   CALL GETC					;문자를 입력받는다
   CMP AL, 0DH					;------------------
   JE MICRO_SWITCH				;a:Micro mode로 변경
   MOV [BX], AL					;c:Continue excution
   INC BX						;e:프로그램 종료
   LOOP MICRO_READCMD_LOOP		;i:Interrupt
   CMP CX, 0					;r:return from the last interrupt
   JNE MICRO_SWITCH				;------------------
   CALL NEWLINE					
MICRO_SWITCH:					
   MOV BX, OFFSET CMDLINE		
   CMP CX, 39					
   MOV AL, [BX]					
   JNE MICRO_CMP_EXIT		
   	

   
   CMP INTERRUPT_SWITCH,1		;'r'을 입력받으면 
   JNE NOT_INTERRUPT			;│return from the last interrupt
   CMP AL,'r'					
   JE CMP_CIN_R					
   JMP MICRO_CLEARCMD			
  CMP_CIN_R:					
  MOV INTERRUPT_SWITCH,0		
   JE MICRO_RETURN				
NOT_INTERRUPT:

   CMP AL, 'a'					;'a'를 입력받으면 macro mode로 ㅂㄴ경
   JE CASE_MACRO
   CMP AL, 'e'					;'e'를 입력받으면 프로그램 종료
   JE MICRO_CASE_EXIT
   CMP AL, 'i'					;'i'를 입력받으면 interrupt를 걸어주고
   JE MICRO_INTERRUPT			;stack에 값을 출력해준다
   CMP AL, 'c'					;'c'를 입력받으면 현재 pc에있는 명령어excute
   JE MICRO_CASE_CONTINUE
   JNE MICRO_CMP_EXIT

MICRO_CASE_CONTINUE:			;'c'를 입력받은 경우 excutiont단계를
   CALL M_CONTINUE				;3단계로 나누어 실행하기위한 함수 호출
   JMP MICRO_CLEARCMD
MICRO_INTERRUPT:
	CMP CNT_C,3					; 인터럽트 되기전에 C명령어가 3번 실행됐는지 확인
	JNE MICRO_CLEARCMD
	CALL M_INTERRUPT
	JMP MICRO_CLEARCMD
MICRO_RETURN:
	CALL M_RETURN				;decode하는 함수로 실제 명령어가 실행
	JMP MICRO_CLEARCMD
CASE_MACRO:
   CALL CMD_MACRO
   MOV BX, OFFSET CMDLINE
   MOV CX, 40
MICRO_CLEARCMD_LOOP_TO_MACRO:
   XOR AX, AX
   MOV [BX], AL
   INC BX
   LOOP MICRO_CLEARCMD_LOOP_TO_MACRO

   JMP MACRO_GETCMD
MICRO_CASE_EXIT:
   CALL EXIT
MICRO_CMP_EXIT:
MICRO_WRONG_CMD:				;메뉴얼에 없는 값을 입력받으면
   MOV DX, OFFSET STR_WRONGCMD	;오류메세지를 출력한다
   CALL PUTS					
   CALL NEWLINE					
   JMP MICRO_CLEARCMD			
MICRO_CLEARCMD:					
   MOV BX, OFFSET CMDLINE		;명령어 처리가 끝나고
   MOV CX, 40					;micro mode의 처음으로 이동하기전
MICRO_CLEARCMD_LOOP:			;사용했던 변수들을
   XOR AX, AX					;초기화 시켜준다
   MOV [BX], AL					
   INC BX						
   LOOP MICRO_CLEARCMD_LOOP		
   JMP MICRO_GETCMD				

M_CONTINUE PROC
	
	CMP CNT_C,00b
	JE CNT_C_0
	CMP CNT_C,01b
	JE CNT_C_1
	CMP CNT_C,10b
	JE CNT_C_2

CNT_C_0:					; MICRO 모드에서 C명령어가 처음으로 실행됬을 때
	MOV AX,PC
	MOV MAR,AX				; MAR에 현재 PC값을 저장
	ADD AX,4
	MOV PC, AX				; PC에 PC+4 값을 저장
	CALL M_RETURN_MICRO
	
	PRINT STR_CNT_C_MAR		; 'MAR <-' 출력
	MOV BX,MAR
	MOV TEMP_RG,BX
	CALL PHEX					; MAR 출력 
	CALL NEWLINE
	PRINT STR_CNT_C_PC
	MOV BX,PC
	MOV TEMP_RG,BX
	CALL PHEX					; PC 출력
	MOV CNT_C,01b				;CNT_C의 값의 01b로 설정한다.
	CALL NEWLINE
	JMP END_M_CONTINUE

CNT_C_1:					; MICRO 모드에서 C명령어가 두번째로 실행됬을 때
	MOV SI,MAR
	MOV AX,M[SI]
	MOV IR,AX
	PRINT STR_CNT_C_IR
	MOV BX,IR
	MOV TEMP_RG,BX
	CALL PHEX				; M[MAR]에 있는 앞4BIT 출력

	MOV SI,MAR
	MOV AX,M[SI+2]
	MOV IR,AX
	MOV TEMP_RG,AX
	CALL PHEX					; M[MAR+2]에 있는 뒤 4BIT 출력
	MOV CNT_C,10b				;CNT_C의 값의 10b로 설정한다.
	CALL NEWLINE
	JMP END_M_CONTINUE

CNT_C_2:					; MICRO 모드에서 C명령어가 세번째로 실행됬을 때

	MOV AX,MAR
	ADD AX,4
	MOV PROGRAM_RG,AX		; MAR의 주소를 PROGRAM_RG에 저장
	
	PRINT STR_CNT_C_MAR

	CMP VDECODE[0],0000b
	JE END_N_CONTINUE2
	CMP VDECODE[0],1110b	; OPERAND1이 존재하지 않는 HALT명령어이면 명령어를 실행한다.
	JE END_M_REST
	CMP VDECODE[0],1111b		; OPERAND1이 주소값인 MOV명령인지 확인한다.
	JE MOV_IMME_Q
	JNE MOV_MICRO_REGI

END_N_CONTINUE2:
	CALL NEWLINE
	MOV CNT_C,11b
	JMP END_M_CONTINUE

MOV_IMME_Q:
	CMP VDECODE[6],00b
	JE MOV_MICRO_REGI
	CMP VDECODE[6],01b
	JE MOV_MICRO_IMME

MOV_MICRO_IMME:
	MOV BX,VDECODE[10]
	MOV TEMP_RG,BX
	CALL PHEX
	JMP END_CNT_C_2

MOV_MICRO_REGI:
	MOV AX,VDECODE[4]		; OPERAND1의 값을 확인한다.
	CMP AX,1000b
	JE PRINT_A
	CMP AX,1001b
	JE PRINT_B
	CMP AX,1010b
	JE PRINT_C
	CMP AX,1011b
	JE PRINT_D
	CMP AX,1100b
	JE PRINT_E
	CMP AX,1101b
	JE PRINT_F
	CMP AX,1110b
	JE PRINT_X
	CMP AX,1111b
	JE PRINT_Y

END_M_REST:
	JMP END_M_CONTINUE

PRINT_A:
	PRINT STR_REGI_A
	JMP END_CNT_C_2
PRINT_B:
	PRINT STR_REGI_B
	JMP END_CNT_C_2
PRINT_C:
	PRINT STR_REGI_C
	JMP END_CNT_C_2
PRINT_D:
	PRINT STR_REGI_D
	JMP END_CNT_C_2
PRINT_E:
	PRINT STR_REGI_E
	JMP END_CNT_C_2
PRINT_F:
	PRINT STR_REGI_F
	JMP END_CNT_C_2
PRINT_X:
	PRINT STR_REGI_X
	JMP END_CNT_C_2
PRINT_Y:
	PRINT STR_REGI_Y
	JMP END_CNT_C_2

END_CNT_C_2:
	CALL NEWLINE
	PRINT STR_CNT_C_MBR	

	CMP VDECODE[0],0001b
	JE DOUBLE_OPERAND
	CMP VDECODE[0],0110b
	JE DOUBLE_OPERAND
	CMP VDECODE[0],0111b
	JE DOUBLE_OPERAND
	CMP VDECODE[0],1000b
	JE DOUBLE_OPERAND
	CMP VDECODE[0],1001b
	JE DOUBLE_OPERAND
	CMP VDECODE[0],1011b
	JE DOUBLE_OPERAND
	CMP VDECODE[0],1100b
	JE DOUBLE_OPERAND
	CMP VDECODE[0],1111b
	JE DOUBLE_OPERAND

	JMP SINGLE_OPERAND

DOUBLE_OPERAND:
	CMP VDECODE[2],00b
	JE MOV_TO_VDECODE_8
	CMP VDECODE[2],10b
	JE MOV_TO_VDECODE_8
	CMP VDECODE[2],01b
	JE MOV_TO_VDECODE_10_REST
	CMP VDECODE[2],11b
	JE MOV_TO_VDECODE_10_REST

MOV_TO_VDECODE_8:
	MOV AX,VDECODE[8]

	CMP AX,1000b
	JE PRINT_A_OP2
	CMP AX,1001b
	JE PRINT_B_OP2
	CMP AX,1010b
	JE PRINT_C_OP2
	CMP AX,1011b
	JE PRINT_D_OP2
	CMP AX,1100b
	JE PRINT_E_OP2
	CMP AX,1101b
	JE PRINT_F_OP2
	CMP AX,1110b
	JE PRINT_X_OP2
	CMP AX,1111b
	JE PRINT_Y_OP2

MOV_TO_VDECODE_10_REST:
	JMP MOV_TO_VDECODE_10 

PRINT_A_OP2:
	PRINT STR_REGI_A
	JMP CONTINUE_END
PRINT_B_OP2:
	PRINT STR_REGI_B
	JMP CONTINUE_END
PRINT_C_OP2:
	PRINT STR_REGI_C
	JMP CONTINUE_END
PRINT_D_OP2:
	PRINT STR_REGI_D
	JMP CONTINUE_END
PRINT_E_OP2:
	PRINT STR_REGI_E
	JMP CONTINUE_END
PRINT_F_OP2:
	PRINT STR_REGI_F
	JMP CONTINUE_END
PRINT_X_OP2:
	PRINT STR_REGI_X
	JMP CONTINUE_END
PRINT_Y_OP2:
	PRINT STR_REGI_Y
	JMP CONTINUE_END

MOV_TO_VDECODE_10:
	MOV AX,VDECODE[10]
	MOV TEMP_RG,AX
	CALL PHEX
	JMP CONTINUE_END

SINGLE_OPERAND:
	PRINT STR_NULL

CONTINUE_END:
	MOV CNT_C,11b				;CNT_C의 값의 11b로 설정한다.
	CALL NEWLINE

	MOV AX,PROGRAM_RG
	MOV MAR,AX				; MAR값을 PROGRAM_RG값으로 변경한다.

   CMP VDECODE[0], 0001b
   JE EXE_CMP_MICRO
   CMP VDECODE[0], 0010b
   JE EXE_JMP_MICRO
   CMP VDECODE[0], 0011b
   JE EXE_JE_MICRO
   CMP VDECODE[0], 0100b
   JE EXE_JA_MICRO
   CMP VDECODE[0], 0101b
   JE EXE_JB_MICRO
   CMP VDECODE[0], 0110b
   JE EXE_ADD_MICRO
   CMP VDECODE[0], 0111b
   JE EXE_SUB_MICRO
   CMP VDECODE[0], 1000b
   JE EXE_MUL_MICRO
   CMP VDECODE[0], 1001b
   JE EXE_DIV_MICRO
   CMP VDECODE[0], 1010b
   JE EXE_SFT_MICRO
   CMP VDECODE[0], 1011b
   JE EXE_AND_MICRO
   CMP VDECODE[0], 1100b
   JE EXE_OR_MICRO
   CMP VDECODE[0], 1101b
   JE EXE_NOT_MICRO
   CMP VDECODE[0], 1110b
   JE EXE_HALT_MICRO
   CMP VDECODE[0], 1111b
   JE EXE_MOV_MICRO

EXE_NEXT_MICRO:
   CALL NEWLINE
   RET
                                          ; 명령어 분기
EXE_CMP_MICRO:
   CALL M_CMP
   JMP EXE_NEXT_MICRO
EXE_JMP_MICRO:
   CALL M_JMP
   JMP EXE_NEXT_MICRO
EXE_JE_MICRO:
   CALL M_JE
   JMP EXE_NEXT_MICRO
EXE_JA_MICRO:
   CALL M_JA
   JMP EXE_NEXT_MICRO
EXE_JB_MICRO:
   CALL M_JB
   JMP EXE_NEXT_MICRO
EXE_ADD_MICRO:
	CALL M_ADD
   JMP EXE_NEXT_MICRO
EXE_SUB_MICRO:
   CALL M_SUB
   JMP EXE_NEXT_MICRO
EXE_MUL_MICRO:
	CALL M_MUL
   JMP EXE_NEXT_MICRO
EXE_DIV_MICRO:
	CALL M_DIV
   JMP EXE_NEXT_MICRO
EXE_SFT_MICRO:
	CALL M_SHIFT
   JMP EXE_NEXT_MICRO
EXE_AND_MICRO:
	CALL M_AND
   JMP EXE_NEXT_MICRO
EXE_OR_MICRO:
	CALL M_OR
   JMP EXE_NEXT_MICRO
EXE_NOT_MICRO:
	CALL M_NOT
   JMP EXE_NEXT_MICRO
EXE_HALT_MICRO:
	CALL M_HALT
   JMP EXE_NEXT_MICRO
EXE_MOV_MICRO:
   CALL M_MOV
   JMP EXE_NEXT_MICRO

END_M_CONTINUE:
	RET
M_CONTINUE ENDP
;------------------------------------------
;Procedure Name : M_INTERRUPT
;Function : Micro Mode에서 Interrupt 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Dec 5,2016
;   Last Modified On Dec 5,2016
;------------------------------------------
M_INTERRUPT PROC
	MOV INTERRUPT_SWITCH,1
	MOV CNT_C,00b			; CNT_C의 값을 0으로 초기화시켜준다

	MOV SI,STACK_RG
	MOV AX,A
	MOV IST[SI], AX			; IST에 레지스터 A 값을 저장해둔다.
	PRINT STR_ITR_A
	CALL NEWLINE

	ADD STACK_RG,2			; STACK_RG의 값을 2 더해준다.
	MOV SI,STACK_RG
	MOV AX,B
	MOV IST[SI], AX			; IST에 레지스터 B 값을 저장해둔다.
	PRINT STR_ITR_B
	CALL NEWLINE

	ADD STACK_RG,2			; STACK_RG의 값을 2 더해준다.
	MOV SI,STACK_RG
	MOV AX,C
	MOV IST[SI], AX			; IST에 레지스터 C 값을 저장해둔다.
	PRINT STR_ITR_C
	CALL NEWLINE

	ADD STACK_RG,2			; STACK_RG의 값을 2 더해준다.
	MOV SI,STACK_RG
	MOV AX,D
	MOV IST[SI], AX			; IST에 레지스터 D 값을 저장해둔다.
	PRINT STR_ITR_D
	CALL NEWLINE

	ADD STACK_RG,2			; STACK_RG의 값을 2 더해준다.
	MOV SI,STACK_RG
	MOV AX,E
	MOV IST[SI], AX			; IST에 레지스터 E 값을 저장해둔다.
	PRINT STR_ITR_E
	CALL NEWLINE

	ADD STACK_RG,2			; STACK_RG의 값을 2 더해준다.
	MOV SI,STACK_RG
	MOV AX,F
	MOV IST[SI], AX			; IST에 레지스터 F 값을 저장해둔다.
	PRINT STR_ITR_F
	CALL NEWLINE

	ADD STACK_RG,2			; STACK_RG의 값을 2 더해준다.
	MOV SI,STACK_RG
	MOV AX,X
	MOV IST[SI], AX			; IST에 레지스터 X 값을 저장해둔다.
	PRINT STR_ITR_X
	CALL NEWLINE

	ADD STACK_RG,2			; STACK_RG의 값을 2 더해준다.
	MOV SI,STACK_RG
	MOV AX,Y
	MOV IST[SI], AX			; IST에 레지스터 Y 값을 저장해둔다.
	PRINT STR_ITR_Y
	CALL NEWLINE

	ADD STACK_RG,2			; STACK_RG의 값을 2 더해준다.
	MOV SI,STACK_RG
	MOV AX,PROGRAM_RG
	MOV IST[SI], AX			; IST에 PROGRAM_RG 값을 저장해둔다.
	PRINT STR_ITR_PROGRAM
	CALL NEWLINE

	ADD STACK_RG,2			; STACK_RG의 값을 2 더해준다.
	MOV SI,STACK_RG
	MOV AX,STATUS_RG
	MOV IST[SI], AX			; IST에 STATUS_RG값을 저장해둔다.
	PRINT STR_ITR_STATUS
	CALL NEWLINE

	ADD STACK_RG,2			; STACK_RG의 값을 2 더해준다.
	MOV SI,STACK_RG
	MOV AX,INSTRUCTION_RG
	MOV IST[SI], AX			; IST에 INSTRUCTION_RG값을 저장해둔다.
	PRINT STR_ITR_INSTRUCTION
	CALL NEWLINE

	ADD STACK_RG,2			; STACK_RG의 값을 2 더해준다.
	MOV SI,STACK_RG
	MOV AX, TEMP_RG
	MOV IST[SI], AX			; IST에 TEMP_RG값을 저장해둔다.
	PRINT STR_ITR_TEMP
	CALL NEWLINE

	ADD STACK_RG,2			; STACK_RG의 값을 2 더해준다.
	MOV SI,STACK_RG
	MOV AX,PC
	MOV IST[SI], AX			; IST에 PC_RG값을 저장해둔다.
	PRINT STR_ITR_PC
	CALL NEWLINE

	MOV BX,STACK_RG
	MOV TEMP_RG,BX
	CALL PHEX				;STACK_RG의 값을 16진수로 출력.
	CALL NEWLINE

	RET
M_INTERRUPT ENDP

;------------------------------------------------
;Procedure Name : M_RETURN_MICRO PROC
;Function : 마이크로모드에서 excution할 때 decode하는 함수
;PROGRAMED BY 석승욱
;PROGRAM VERSION
;   Creation Date :Dec 5,2016
;   Last Modified On Dec 6,2016
;------------------------------------------------
M_RETURN_MICRO PROC			; 마이크로모드에서 명령어를 VDECODE에 나눠넣는다.
   MOV VDECODE[0], 0000h	;VDECODE변수를 초기화시켜준다
   MOV VDECODE[2], 0000h
   MOV VDECODE[4], 0000h
   MOV VDECODE[6], 0000h
   MOV VDECODE[8], 0000h
   MOV VDECODE[10], 0000h
   MOV SI,0
   MOV DI,0

   MOV SI, MAR				;현재 MAR의 값을 SI로 전달
   MOV AX, M[SI]			;SI번지 MEMORY의 명령어 값을AX로 전달
   XOR BX, BX				
   XOR CX, CX				

   MOV BX, AX				
   AND BX, 1111000000000000b;명령어 상위1~4비트를
   MOV CL, 12				;VDECODE[0]에 넣는다
   SHR BX, CL				
   MOV VDECODE[0], BX		

   MOV BX, AX				
   AND BX, 0000110000000000b;명령어 상위5,6번째비트를
   MOV CL, 10				;VDECODE[2]에 넣는다
   SHR BX, CL				
   MOV VDECODE[2], BX		

   MOV BX, AX				
   AND BX, 0000001111000000b;명령어 상위7~10비트를
   MOV CL, 6				;VDECODE[4]에 넣는다
   SHR BX, CL				
   MOV VDECODE[4], BX		

   MOV BX, AX				
   AND BX, 0000000000110000b;명령어 상위11,12번째 비트를
   MOV CL, 4				;VDECODE[6]에 넣는다
   SHR BX, CL				
   MOV VDECODE[6], BX		

   MOV BX, AX				
   AND BX, 0000000000001111b;명령어 13~16비트를
   MOV VDECODE[8], BX		;VDECODE[8]에 넣는다

   MOV AX, M[SI+2]			;SI값을 2증가시킨후 immediate값을
   MOV VDECODE[10], AX		;VDECODE[10]에 넣는다
   RET
M_RETURN_MICRO ENDP
;------------------------------------------------
;Procedure Name : M_RETURN
;Function : INTTRUPT상태에서 원래상태로 돌아가는 함수
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Dec 5,2016
;   Last Modified On Dec 5,2016
;------------------------------------------------
M_RETURN PROC

	MOV SI,STACK_RG
	MOV AX,IST[SI]
	MOV PC,AX				; PC에 IST에 저장해둔 PC값을 저장한다.
	SUB STACK_RG,2			; STACK_RG의 값을 2 빼준다.

	MOV SI,STACK_RG
	MOV AX,IST[SI]
	MOV TEMP_RG,AX				; TEMP_RG에 IST에 저장해둔 TEMP_RG값을 저장한다.
	SUB STACK_RG,2				; STACK_RG의 값을 2 빼준다.

	MOV SI,STACK_RG
	MOV AX,IST[SI]
	MOV INSTRUCTION_RG,AX		; INSTRUCTION_RG에 IST에 저장해둔 INSTRUCTION_RG값을 저장한다.
	SUB STACK_RG,2				; STACK_RG의 값을 2 빼준다.

	MOV SI,STACK_RG
	MOV AX,IST[SI]
	MOV STATUS_RG,AX			; STATUS_RG에 IST에 저장해둔 STATUS_RG값을 저장한다.
	SUB STACK_RG,2				; STACK_RG의 값을 2 빼준다.

	MOV SI,STACK_RG
	MOV AX,IST[SI]
	MOV PROGRAM_RG,AX			; PROGRAM_RG에 IST에 저장해둔 PROGRAM_RG값을 저장한다.
	SUB STACK_RG,2				; STACK_RG의 값을 2 빼준다.

	MOV SI,STACK_RG
	MOV AX,IST[SI]
	MOV Y,AX				; Y에 IST에 저장해둔 Y값을 저장한다.
	SUB STACK_RG,2			; STACK_RG의 값을 2 빼준다.

	MOV SI,STACK_RG
	MOV AX,IST[SI]
	MOV X,AX				; X에 IST에 저장해둔 X값을 저장한다.
	SUB STACK_RG,2			; STACK_RG의 값을 2 빼준다.

	MOV SI,STACK_RG
	MOV AX,IST[SI]
	MOV F,AX				; F에 IST에 저장해둔 F값을 저장한다.
	SUB STACK_RG,2			; STACK_RG의 값을 2 빼준다.

	MOV SI,STACK_RG
	MOV AX,IST[SI]
	MOV E,AX				; E에 IST에 저장해둔 E값을 저장한다.
	SUB STACK_RG,2			; STACK_RG의 값을 2 빼준다.

	MOV SI,STACK_RG
	MOV AX,IST[SI]
	MOV D,AX				; D에 IST에 저장해둔 D값을 저장한다.
	SUB STACK_RG,2			; STACK_RG의 값을 2 빼준다.

	MOV SI,STACK_RG
	MOV AX,IST[SI]
	MOV C,AX				; C에 IST에 저장해둔 C값을 저장한다.
	SUB STACK_RG,2			; STACK_RG의 값을 2 빼준다.

	MOV SI,STACK_RG
	MOV AX,IST[SI]
	MOV B,AX				; B에 IST에 저장해둔 B값을 저장한다.
	SUB STACK_RG,2			; STACK_RG의 값을 2 빼준다.

	MOV SI,STACK_RG
	MOV AX,IST[SI]
	MOV A,AX				; A에 IST에 저장해둔 A값을 저장한다.

	PRINT STR_CNT_C_MAR
	MOV BX,MAR
	MOV TEMP_RG,BX
	CALL PHEX				;PROGRAM_RG의 값을 16진수로 출력.
	CALL NEWLINE

	PRINT STR_CNT_C_PC
	MOV BX,PC
	MOV TEMP_RG,BX
	CALL PHEX				; PC의 값을 16진수로 출력.
	CALL NEWLINE
	RET
M_RETURN ENDP

;------------------------------------------------
;Procedure Name : CMD_MICRO
;Function : 마이크로 모드 셋팅 함수
;PROGRAMED BY 정재훈
;PROGRAM VERSION
;   Creation Date :Dec 1,2016
;   Last Modified On Dec 1,2016
;------------------------------------------------
CMD_MICRO PROC				;마이크로 모드 셋팅
   MOV MODE, 00h			;마이크로 모드일 경우 MODE=00h
   MOV DX, OFFSET STR_MICRO
   CALL PUTS				;모드 문자열 출력
   CALL NEWLINE
   RET
CMD_MICRO ENDP

;------------------------------------------------
;Procedure Name : CMD_MACRO
;Function : 매크로 모드 셋팅 함수
;PROGRAMED BY 정재훈
;PROGRAM VERSION
;   Creation Date :Dec 1,2016
;   Last Modified On Dec 1,2016
;------------------------------------------------
CMD_MACRO PROC				; 매크로 모드 셋팅
   MOV MODE, 01h			; 매크로 모드일 경우 MODE = 01h
   MOV DX, OFFSET STR_MACRO
   CALL PUTS				; 모드 문자열 출력
   CALL NEWLINE
   RET
CMD_MACRO ENDP

;------------------------------------------------
;Procedure Name : CMD_EXECUTE
;Function : 매크로 모드 c 명령어 처리 함수
;PROGRAMED BY 석승욱
;PROGRAM VERSION
;   Creation Date :Nov 23,2016
;   Last Modified On Nov 28,2016
;------------------------------------------------
CMD_EXECUTE PROC				; 매크로 모드 c 명령어
   MOV VDECODE[0], 0000h		; VDECODE 초기화
   MOV VDECODE[2], 0000h
   MOV VDECODE[4], 0000h
   MOV VDECODE[6], 0000h
   MOV VDECODE[8], 0000h
   MOV VDECODE[10], 0000h
   MOV SI,0
   MOV DI,0
   MOV SI, PC
   ADD PC, 4					; PC값 증가
   MOV MAR, SI					; MAR에 PC저장

   CMP MODE, 01h
   JE CMD_EXE_L1

   MOV DX,OFFSET STR_MAR
   MOV AX,MAR
   MOV TEMP_RG,AX
   CALL DISPLAY
   MOV DL,  ' '
   CALL PUTC
   MOV DX,OFFSET STR_PC			; 현재 PC를 출력함
   MOV AX,PC
   MOV TEMP_RG,AX
   CALL DISPLAY
   CALL NEWLINE

   MOV SI, MAR
CMD_EXE_L1:						; PC가 메모리 지정범위가 아닐경우 에러 출력
   CMP SI, 0
   JAE CMD_EXE_L2
   JMP EXE_WRONG_PC
CMD_EXE_L2:
   CMP SI, 1000h
   JB CMD_EXE_L3
   JMP EXE_WRONG_PC
CMD_EXE_L3:
   MOV DL, ' '
   CALL PUTC
   MOV AX, M[SI]				; 현재 PC가 가리키는 메모리에 어떤값이 있는지 출력
   MOV TEMP_RG, AX
   CALL PHEX
   MOV SI, MAR
   MOV AX, M[SI+2]                        
   MOV TEMP_RG, AX
   CALL PHEX
   CALL NEWLINE

   MOV SI, MAR
   MOV AX, M[SI]				; 명령어 앞 16비트를 읽어온다
   XOR BX, BX
   XOR CX, CX

   MOV BX, AX					; opcode 부분
   AND BX, 1111000000000000b
   MOV CL, 12
   SHR BX, CL
   MOV VDECODE[0], BX			; opcode를 vdecode[0]에 저장

   MOV BX, AX					; addressing mode 부분
   AND BX, 0000110000000000b
   MOV CL, 10
   SHR BX, CL
   MOV VDECODE[2], BX			; mode를 vdecode[2]에 저장

   MOV BX, AX					; 첫번째 operand 부분
   AND BX, 0000001111000000b
   MOV CL, 6
   SHR BX, CL
   MOV VDECODE[4], BX			; 첫번째 오퍼랜드를 vdecode[4]에 저장

   MOV BX, AX					; 보조 addressing mode 부분
   AND BX, 0000000000110000b
   MOV CL, 4
   SHR BX, CL
   MOV VDECODE[6], BX			; 모드를 vdecode[6]에 저장

   MOV BX, AX				
   AND BX, 0000000000001111b	; 두번째 operand 부분
   MOV VDECODE[8], BX			; 두번째 오퍼랜드를 vdecode[8]에 저장
	
   MOV AX, M[SI+2]				; 명령어의 나머지 16비트를 읽어온다
   MOV VDECODE[10], AX			; Immediate값을 vdecode[10]에 저장
								; opcode에 따라서 명령어 분기
   CMP VDECODE[0], 0001b
   JE EXE_CMP
   CMP VDECODE[0], 0010b
   JE EXE_JMP
   CMP VDECODE[0], 0011b
   JE EXE_JE
   CMP VDECODE[0], 0100b
   JE EXE_JA
   CMP VDECODE[0], 0101b
   JE EXE_JB
   CMP VDECODE[0], 0110b
   JE EXE_ADD
   CMP VDECODE[0], 0111b
   JE EXE_SUB
   CMP VDECODE[0], 1000b
   JE EXE_MUL
   CMP VDECODE[0], 1001b
   JE EXE_DIV
   CMP VDECODE[0], 1010b
   JE EXE_SFT
   CMP VDECODE[0], 1011b
   JE EXE_AND
   CMP VDECODE[0], 1100b
   JE EXE_OR
   CMP VDECODE[0], 1101b
   JE EXE_NOT
   CMP VDECODE[0], 1110b
   JE EXE_HALT
   CMP VDECODE[0], 1111b
   JE EXE_MOV
EXE_NEXT:						; 명령어 실행되고 나서 레지스터 출력
   CALL NEWLINE
   CALL CMD_DISPLAY
   RET
EXE_WRONG_PC:					; 잘못된 PC 범위 일경우 에러 메시지 출력
   MOV DX, OFFSET STR_WRONGPCADDR
   CALL PUTS
   CALL NEWLINE
   RET
								; 명령어 분기된거 처리부분 해당되는 명령어를 실행함
EXE_CMP:
   CALL M_CMP
   JMP EXE_NEXT
EXE_JMP:
   CALL M_JMP
   JMP EXE_NEXT
EXE_JE:
   CALL M_JE
   JMP EXE_NEXT
EXE_JA:
   CALL M_JA
   JMP EXE_NEXT
EXE_JB:
   CALL M_JB
   JMP EXE_NEXT
EXE_ADD:
	CALL M_ADD
   JMP EXE_NEXT
EXE_SUB:
   CALL M_SUB
   JMP EXE_NEXT
EXE_MUL:
	CALL M_MUL
   JMP EXE_NEXT
EXE_DIV:
	CALL M_DIV
   JMP EXE_NEXT
EXE_SFT:
	CALL M_SHIFT
   JMP EXE_NEXT
EXE_AND:
	CALL M_AND
   JMP EXE_NEXT
EXE_OR:
	CALL M_OR
   JMP EXE_NEXT
EXE_NOT:
	CALL M_NOT
   JMP EXE_NEXT
EXE_HALT:
	CALL M_HALT
   JMP EXE_NEXT
EXE_MOV:
   CALL M_MOV
   JMP EXE_NEXT
CMD_EXECUTE ENDP

;------------------------------------------------
;Procedure Name : CMD_MEMORY
;Function : 메모리 입력을 위한 m명령어 처리 함수
;PROGRAMED BY 정재훈
;PROGRAM VERSION
;   Creation Date :Nov 26,2016
;   Last Modified On Nov 30,2016
;------------------------------------------------
CMD_MEMORY PROC
   MOV CMD_MEM_LEN, 00h			; 사용되는 변수 초기화
   MOV CMD_MEM_ADDR, 0000h
   MOV CMD_MEM_VAL1, 0000h
   MOV CH, CL					; cx에서 40을 빼서 실제 입력된 명령어의 길이를 구함
   MOV CL, 40
   SUB CL, CH
   MOV CH, 0
   MOV CMD_MEM_LEN, CL			; 명령어 길이 저장
   SUB CX, 2
MEM_PARSE1:
   MOV DL, [BX + 2]				; 메모리 오프셋 파싱하는 부분
   CMP DL, ']'
   JE PARSE_MEM_OFF
   INC BX
   LOOP MEM_PARSE1
   JMP MEM_WRONGADDR			; 파싱 실패시 에러 출력
PARSE_MEM_OFF:
   MOV AX, BX
   ADD BX, 2
   SUB AX, OFFSET CMDLINE
   CMP AX, 4
   JB CMD_MEM_L1
CMD_MEM_L1:
   CMP AX, 0
   JNE CMD_MEM_L2
   JMP MEM_WRONGADDR
CMD_MEM_L2:
   MOV BX, OFFSET CMDLINE		; 명령어 버퍼를 새로 읽어온다
   MOV SI, AX
   MOV DL, [BX + 3 + SI]
   CMP DL, ' '
   JE CMD_MEM_L3
   JMP MEM_WRONG_FMT
CMD_MEM_L3:						; 메모리 주소 처리 시작
   MOV DI, AX
   XOR DX, DX
   MOV SI, 0
   MOV AL, [BX + 2 + SI]
   CALL CHECK_HEX				; valid한 값인지 체크
   CMP AL, 0FFH
   JNE CMD_MEM_L4
   JMP WRONG_MEM_RANGE
CMD_MEM_L4:
   MOV DL, AL
   SUB DI, 1
READ_MEM_ADDR:					; 한자리 이상일경우 루프돌면서 처리
   CMP SI, DI
   JE PARSE_MEM_VAL
   INC SI
   MOV AL, [BX + 2 + SI]
   CALL CHECK_HEX
   CMP AL, 0FFH
   JNE CMD_MEM_L5
   JMP WRONG_MEM_RANGE
CMD_MEM_L5:						; 쉬프트연산을 하면서 입력받는 자리수대로 밀어넣는 형식
   MOV CL, 4
   SHL DX, CL
   OR DL, AL
   LOOP READ_MEM_ADDR
PARSE_MEM_VAL:
   CMP DX, 1000h
   JBE CMD_MEM_L6
   JMP MEM_WRONGADDR
CMD_MEM_L6:
   MOV CMD_MEM_ADDR, DX			; 읽은 메모리주소 변수에 저장함
   
   MOV SAVE_DI[0],DI
   MOV DI,0
   MOV DI,SAVE_CNT[0]			; 메모리에 저장된값 다 꺼내오기위해서
   MOV SAVE_M[DI],DX
   MOV DI,SAVE_DI[0]

   XOR CX, CX					; 메모리에 저장될 값 파싱하기 위해서 길이 계산
   MOV CL, CMD_MEM_LEN
   MOV BX, OFFSET CMDLINE
   ADD BX, 5
   ADD BX, DI
   SUB CX, 5
   SUB CX, DI
   CMP CX, 8
   JBE CMD_MEM_L7
   JMP WRONG_VAL				; 길이 계산에 실패한경우 파싱 에러
CMD_MEM_L7:
   CMP CX, 0
   JNE CMD_MEM_L8
   JMP WRONG_VAL				; 길이가 0인경우에도 파싱 에러
CMD_MEM_L8:
   CMP CX, 4
   JA MEM_INPUT_DOUBLE			; 길이가 4자리인 경우 4자리 입력모드로
   MOV DI, CX
   XOR DX, DX
   MOV SI, 0
   MOV AL, [BX + SI]
   CALL CHECK_HEX
   CMP AL, 0FFH					; 16진수 검사
   JNE CMD_MEM_L9
   JMP WRONG_MEM_RANGE
CMD_MEM_L9: 
   MOV DL, AL
   SUB DI, 1
READ_VAL1:
   CMP SI, DI
   JE MEM_SETVAL1
   INC SI
   MOV AL, [BX + SI]		
   CALL CHECK_HEX				; 똑같이 루프돌면서 숫자를 밀어넣는다
   CMP AL, 0FFH
   JNE CMD_MEM_L10
   JMP WRONG_MEM_RANGE
CMD_MEM_L10:
   MOV CL, 4
   SHL DX, CL
   OR DL, AL
   LOOP READ_VAL1
MEM_SETVAL1:
   MOV CMD_MEM_VAL1, DX			; 파싱된 결과를 임시 변수에 저장
   MOV SI, CMD_MEM_ADDR
   MOV M[SI], DX				; 실제 메모리 오프셋에 해당 값 입력
   XOR DI, DI
   JMP MEM_PRINT_RESULT			; 결과 출력 부분으로 점프
MEM_INPUT_DOUBLE:
   MOV DI, CX
   SUB DI, 4
   XOR DX, DX
   MOV SI, 0
   MOV AL, [BX + SI]
   CALL CHECK_HEX				; 16진수 값 검사
   CMP AL, 0FFH
   JNE CMD_MEM_L11
   JMP WRONG_MEM_RANGE
CMD_MEM_L11:
   MOV DL, AL
   SUB DI, 1
READ_VAL2:						; 같은 방식으로 두번씩 입력받음
   CMP SI, DI
   JE MEM_SETVAL2
   INC SI
   MOV AL, [BX + SI]
   CALL CHECK_HEX
   CMP AL, 0FFH
   JNE CMD_MEM_L12
   JMP WRONG_MEM_RANGE
CMD_MEM_L12:					
   MOV CL, 4
   SHL DX, CL
   OR DL, AL
   LOOP READ_VAL2
MEM_SETVAL2:					; 앞부분 임시 버퍼에 저장
   MOV CMD_MEM_VAL1, DX
   INC SI
   MOV DI, SI
   ADD DI, 3
   XOR DX, DX
   MOV AL, [BX + SI]
   CALL CHECK_HEX
   CMP AL, 0FFH
   JE WRONG_MEM_RANGE
   MOV DL, AL
READ_VAL3:
   CMP SI, DI					
   JE MEM_SETVAL3
   INC SI
   MOV AL, [BX + SI]
   CALL CHECK_HEX
   CMP AL, 0FFH
   JE WRONG_MEM_RANGE
   MOV CL, 4
   SHL DX, CL
   OR DL, AL
   LOOP READ_VAL3
MEM_SETVAL3:					; 주소를 다시 꺼내온다
   MOV SI, CMD_MEM_ADDR			; 뒷부분도 임시 버퍼에 저장
   MOV CMD_MEM_VAL2, DX			; 실제 메모리에 입력
   MOV M[SI+2], DX
   MOV DX, CMD_MEM_VAL1
   MOV M[SI], DX
   MOV DI, 8
MEM_PRINT_RESULT:				; 메모리 값 변경하고 난 후 결과 출력 부분
   MOV DL, 'm'
   CALL PUTC
   MOV DL, '['
   CALL PUTC
   MOV AX, CMD_MEM_ADDR
   MOV TEMP_RG, AX
   CALL PHEX
   MOV DL, ']'
   CALL PUTC
   MOV DL, '='
   CALL PUTC
   MOV AX, CMD_MEM_VAL1
   MOV TEMP_RG, AX
   CALL PHEX
   CMP DI, 8
   JNE CMD_MEM_L13
   MOV AX, CMD_MEM_VAL2
   MOV TEMP_RG, AX
   ADD SAVE_CNT[0],2
   CALL PHEX
CMD_MEM_L13:
   CALL NEWLINE
   RET
WRONG_VAL:						; 잘못된 값인 경우에 에러 출력	
   MOV DX, OFFSET STR_WRONGMEMVAL
   CALL PUTS
   CALL NEWLINE
   RET
WRONG_MEM_RANGE:				; 잘못된 범위일 경우 에러 출력
   MOV DX, OFFSET STR_WRONGHEX
   CALL PUTS
   CALL NEWLINE
   RET
MEM_WRONG_FMT:					; 잘못된 명령어 포맷일 경우 에러 출력
   MOV DX, OFFSET STR_WRONGMEM
   CALL PUTS
   CALL NEWLINE
   RET
MEM_WRONGADDR:					; 잘못된 주소일 경우 에러 출력
   MOV DX, OFFSET STR_WRONGMEMADDR
   CALL PUTS
   CALL NEWLINE
   RET
CMD_MEMORY ENDP
;------------------------------------------------
;Procedure Name : CMD_DISPLAY
;Function : 현재 Register의 값과 pc의 값을 출력하는 함수
;PROGRAMED BY 석승욱
;PROGRAM VERSION
;   Creation Date :Nov 23,2016
;   Last Modified On Nov 24,2016
;------------------------------------------------
CMD_DISPLAY PROC
   MOV DX,OFFSET STR_A      ;'A'출력
   MOV AX,A					;Register A에 있는 값을 출력
   MOV TEMP_RG,AX			
   CALL DISPLAY			
   MOV DX,OFFSET STR_B		;B출력
   MOV AX,B					;Register B에 있는 값을 출력
   MOV TEMP_RG,AX			
   CALL DISPLAY				
   MOV DX,OFFSET STR_C		;C출력
   MOV AX,C					;Register C에 있는 값을 출력
   MOV TEMP_RG,AX			
   CALL DISPLAY				
   MOV DX,OFFSET STR_D		;D출력
   MOV AX,D					;Register D에 있는 값을 출력
   MOV TEMP_RG,AX			
   CALL DISPLAY				
   MOV DX,OFFSET STR_E		;E출력
   MOV AX,E					;Register E에 있는 값을 출력
   MOV TEMP_RG,AX			
   CALL DISPLAY				
   MOV DX,OFFSET STR_F		;F출력
   MOV AX,F					;Register F에 있는 값을 출력
   MOV TEMP_RG,AX			
   CALL DISPLAY				
   MOV DX,OFFSET STR_X		;X출력
   MOV AX,X					;Register X에 있는 값을 출력
   MOV TEMP_RG,AX			
   CALL DISPLAY				
   MOV DX,OFFSET STR_Y		;Y출력
   MOV AX,Y					;Register Y에 있는 값을 출력
   MOV TEMP_RG,AX			
   CALL DISPLAY				
   CALL NEWLINE				
   MOV DX,OFFSET STR_PC		;PC출력
   MOV AX,PC				;PC에 있는 값을 출력
   MOV TEMP_RG,AX			
   CALL DISPLAY				
   CALL NEWLINE				

   CALL NEWLINE
   RET
CMD_DISPLAY ENDP

;------------------------------------------------
;Procedure Name : CHECK_HEX
;Function : 메모리, 주소 입력시 16진수값 파싱 함수
;PROGRAMED BY 정재훈
;PROGRAM VERSION
;   Creation Date :Nov 28,2016
;   Last Modified On Nov 29,2016
;------------------------------------------------
CHECK_HEX PROC
   CMP AL, 'f'				; 입력된 값범위 검사
   JA CHECK_HEX_FALSE
   CMP AL, '0'
   JB CHECK_HEX_FALSE
   CMP AL, '9'
   JA CHECK_HEX_UPPER
   SUB AL, 30H				; 숫자 범위일 경우
   RET
CHECK_HEX_UPPER:
   CMP AL, 'F'
   JA CHECK_HEX_LOWER
   CMP AL, 'A'
   JB CHECK_HEX_FALSE
   SUB AL, 37H				; 대문자일 경우
   RET
CHECK_HEX_LOWER:
   CMP AL, 'a'
   JB CHECK_HEX_FALSE
   SUB AL, 57H				; 소문자일 경우
   RET
CHECK_HEX_FALSE:
   MOV AL, 0FFH             ; FF가 리턴되면 범위밖의 값
   RET
CHECK_HEX ENDP

;------------------------------------------------
;Procedure Name : CMD_PC
;Function : PC 입력 함수
;PROGRAMED BY 정재훈
;PROGRAM VERSION
;   Creation Date :Nov 24,2016
;   Last Modified On Nov 30,2016
;------------------------------------------------
CMD_PC PROC
   MOV CH, CL				; 입력된 PC 명령어 길이를 계산
   MOV CL, 40
   SUB CL, CH
   MOV CH, 0
   SUB CX, 3
   XOR DX, DX
   CMP CX, 4
   JA WRONG_PC_FMT			; 입력된 주소가 4자리 이상일 경우 포맷 에러 출력
   MOV SI, 0
   MOV AL, [BX + 3 + SI]
   CALL CHECK_HEX			; 16진수 값 검사
   CMP AL, 0FFH
   JE WRONG_PC_RANGE
   MOV DL, AL
   MOV DI, CX
   SUB DI, 1
READ_PC:					; 주소가 한자리 이상일 경우 루프 돌며서 처리
   CMP SI, DI
   JE SET_PC
   INC SI
   MOV AL, [BX + 3 + SI]
   CALL CHECK_HEX
   CMP AL, 0FFH
   JE WRONG_PC_RANGE
   MOV CL, 4
   SHL DX, CL
   OR DL, AL
   LOOP READ_PC
SET_PC:
   MOV PC, DX

   MOV DX,OFFSET STR_PC		; PC 레지스터 출력
   MOV AX, PC
   MOV TEMP_RG, AX
   CALL DISPLAY

   CALL NEWLINE
   RET
WRONG_PC_FMT:				; 포맷 에러 출력
   MOV DX, OFFSET STR_WRONGPC
   CALL PUTS
   CALL NEWLINE
   RET
WRONG_PC_RANGE:				; 숫자 범위 에러 출력
   MOV DX, OFFSET STR_WRONGHEX
   CALL PUTS
   CALL NEWLINE
   RET
CMD_PC ENDP

;------------------------------------------------
;Procedure Name : EXIT
;Function : 프로그램 종료 함수
;PROGRAMED BY 정재훈
;PROGRAM VERSION
;   Creation Date :Nov 26,2016
;   Last Modified On Nov 26,2016
;------------------------------------------------
EXIT PROC
   MOV AH, 4CH
   INT 21H
EXIT ENDP

;------------------------------------------------
;Procedure Name : PUTC
;Function : 케릭터 단위 출력 함수
;PROGRAMED BY 정재훈
;PROGRAM VERSION
;   Creation Date :Nov 26,2016
;   Last Modified On Nov 26,2016
;------------------------------------------------
PUTC PROC
   MOV AH, 2H
   INT 21H
   RET
PUTC ENDP

;------------------------------------------------
;Procedure Name : NEWLINE
;Function : CRLF 출력 함수
;PROGRAMED BY 석승욱
;PROGRAM VERSION
;   Creation Date :Nov 23,2016
;   Last Modified On Nov 23,2016
;------------------------------------------------
NEWLINE PROC
   MOV DL, 0DH		; Carrige Return
   CALL PUTC
   MOV DL, 0AH		; Line Feed
   CALL PUTC
   RET
NEWLINE ENDP

;------------------------------------------------
;Procedure Name : GETC
;Function : 케릭터 단위 입력 함수
;PROGRAMED BY 정재훈
;PROGRAM VERSION
;   Creation Date :Nov 26,2016
;   Last Modified On Nov 26,2016
;------------------------------------------------
GETC PROC
   MOV AH, 1H
   INT 21H  
   RET
GETC ENDP

;------------------------------------------------
;Procedure Name : PUTS
;Function : 문자열 단위 출력 함수
;PROGRAMED BY 정재훈
;PROGRAM VERSION
;   Creation Date :Nov 26,2016
;   Last Modified On Nov 26,2016
;------------------------------------------------
PUTS PROC
   MOV AH, 09H
   INT 21H
   RET
PUTS ENDP

;------------------------------------------------
;Procedure Name : PHEX
;Function : 헥스 출력 함수
;PROGRAMED BY 석승욱
;PROGRAM VERSION
;   Creation Date :Nov 23,2016
;   Last Modified On Nov 25,2016
;------------------------------------------------
PHEX PROC					
   MOV SI,0					
   MOV CX, TEMP_RG			;상위1번째 비트를 출력
   AND CH,0F0h				
   PRINT_A1_ROOP:			
   CMP SI,4					;SHR,4를 해주는 과정
   JE PRINT_A1_ROOP_EXIT	;CH의 상위 4비트를 하위 4비트로
   SHR CH,1					;옮기는 작업
   INC SI					
   JNE PRINT_A1_ROOP		
   PRINT_A1_ROOP_EXIT:		
   CMP CH,10				
   JB PRINT_A1_DEC			
   ADD CH,55				;10이상일경우 알파벳으로 출력
   JAE PRINT_A1_EXIT		;9이하일경우 숫자로 출력
   PRINT_A1_DEC:			
   ADD CH,48				
   PRINT_A1_EXIT:			
   MOV DL,CH				
   MOV AH,02H				
   INT 21H					
   MOV CX,TEMP_RG			;상위2번째 비트를출력
   AND CH,00Fh				
   CMP CH,10				
   JB PRINT_A2_DEC			;10이상일 경우 알파벳으로 출력
   ADD CH,55				;9이하일 경우 숫자로 출력
   JAE PRINT_A2_EXIT		
   PRINT_A2_DEC:			
   ADD CH,48				
   PRINT_A2_EXIT:			
   MOV DL,CH				
   MOV AH,02H				
   INT 21H					
   MOV SI,0					
   MOV CX,TEMP_RG			;상위3번째 비트를 출력
   AND CL,0F0h				
   PRINT_A3_ROOP:			
   CMP SI,4					;SHR,4를 해주는 과정
   JE PRINT_A3_ROOP_EXIT	;CL의 상위 4비트를 하위 4비트로
   SHR CL,1					;옮기는 작업
   INC SI					
   JNE PRINT_A3_ROOP		
   PRINT_A3_ROOP_EXIT:		
   CMP CL,10				
   JB PRINT_A3_DEC			;10이상일경우 알파벳으로 출력
   ADD CL,55				;9이하일경우 숫자로 출력
   JAE PRINT_A3_EXIT		
   PRINT_A3_DEC:			
   ADD CL,48				
   PRINT_A3_EXIT:			
   MOV DL,CL				
   MOV AH,02H				
   INT 21H					
   MOV CX,TEMP_RG			;상위4번째비트를 출력
   AND CL,00001111b			
   CMP CL,10			
   JB PRINT_A4_DEC			
   ADD CL,55				;10이상일 경우 알파벳으로 출력
   JAE PRINT_A4_EXIT		;9이하일경우 숫자로 출력
   PRINT_A4_DEC:			
   ADD CL,48				
   PRINT_A4_EXIT:			
   MOV DL,CL				
   MOV AH,02H				
   INT 21H					
   RET
PHEX ENDP

;------------------------------------------------
;Procedure Name : DISPLAY
;Function : 레지스터 출력 함수
;PROGRAMED BY 석승욱
;PROGRAM VERSION
;   Creation Date :Nov 24,2016
;   Last Modified On Nov 28,2016
;------------------------------------------------
DISPLAY PROC
   MOV AH,09H         ;STR_??를 출력
   INT 21H
   CALL PHEX
   RET
DISPLAY ENDP

;------------------------------------------------
;Procedure Name : D_OUTPUT
;Function : 메모리의 주소와 명령어 출력 함수
;PROGRAMED BY 정재훈
;PROGRAM VERSION
;   Creation Date :Nov 26,2016
;   Last Modified On Nov 29,2016
;------------------------------------------------
D_OUTPUT PROC
						
   MOV DI,0				
   MOV SAVE_DI2[0],DI	
   M_OUTPUT:			;"m[#]= "을 출력 
   MOV DI,SAVE_DI2[0]	
   CMP SAVE_CNT[0],DI	
   JE D_OUTPUT_EXIT		
   MOV DL,'m'			
   MOV AH,02h			
   INT 21H				
   MOV DL,'['			
   INT 21H				
   MOV BX,SAVE_M[DI]	
   MOV TEMP_RG,BX		
   CALL PHEX			
   MOV DL,']'			
   MOV AH,02h			
   INT 21H				
   MOV DL,'='			
   INT 21H				
   MOV DL,' '			
   INT 21H				

   MOV SAVE_DI2[0],DI	;DI를 임시로 저장
   MOV SI,SAVE_M[DI]	;현재 PC값을 SI로 전달
   MOV BX,M[SI]			;Memory가 가지고있는 명령어를 출력
   MOV TEMP_RG,BX		
   CALL PHEX			
   MOV SI,SAVE_M[DI]	
   ADD SI,2				
   MOV BX,M[SI]			
   MOV TEMP_RG,BX		

   CALL PHEX			

   CALL NEWLINE			
   MOV DI,SAVE_DI2[0]	;임시로 저장해둔 DI를 꺼내온다
   INC DI
   INC DI
   MOV SAVE_DI2[0],DI
   JNE M_OUTPUT
   D_OUTPUT_EXIT:

	RET
D_OUTPUT ENDP


;------------------------------------------------
;Procedure Name : M_JMP
;Function : JMP 명령어를 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 25,2016
;   Last Modified On Nov 25,2016
;------------------------------------------------
M_JMP PROC        ; JMP 명령어
   MOV AX,VDECODE[10]
   CMP AX, 1000h
   JA M_JMP_L1
   MOV PC,AX
   RET
M_JMP_L1:
   MOV DX, OFFSET STR_WRONGMEMADDR
   CALL PUTS
   CALL NEWLINE
   RET
M_JMP ENDP

;------------------------------------------------
;Procedure Name : M_JA
;Function : JA 명령어를 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 25,2016
;   Last Modified On Nov 25,2016
;------------------------------------------------
M_JA PROC         ; JA(크다) 명령어
   MOV DX,STATUS_RG		; STATUS_RG의 값을 확인하여 COMPARE한 결과를 확인
   AND DX,11b
   CMP DX,01b			; 01b 라면(비교한 값이 클 경우) VDECODE[10]값을 PC에 저장, 아닐경우 함수 종료
   JNE END_M_JA
   MOV AX,VDECODE[10]
   CMP AX, 1000h
   JA M_JA_L1
   MOV PC,AX
END_M_JA:
   RET
M_JA_L1:
   MOV DX, OFFSET STR_WRONGMEMADDR
   CALL PUTS
   CALL NEWLINE
   RET
M_JA ENDP

;------------------------------------------------
;Procedure Name : M_JB
;Function : JB 명령어를 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 25,2016
;   Last Modified On Nov 25,2016
;------------------------------------------------
M_JB PROC         ; JB(작다) 명령어
   MOV DX,STATUS_RG		; STATUS_RG의 값을 확인하여 COMPARE한 결과를 확인
   AND DX,11b
   CMP DX,10b		; 10b 라면(비교한 값이 작을 경우) VDECODE[10]값을 PC에 저장, 아닐경우 함수 종료
   JNE END_M_JB
   MOV AX,VDECODE[10]
   CMP AX, 1000h
   JA M_JB_L1
   MOV PC,AX
END_M_JB:
   RET
M_JB_L1:
   MOV DX, OFFSET STR_WRONGMEMADDR
   CALL PUTS
   CALL NEWLINE
   RET
M_JB ENDP

;------------------------------------------------
;Procedure Name : M_JE
;Function : JE 명령어를 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 25,2016
;   Last Modified On Nov 25,2016
;------------------------------------------------
M_JE PROC         ; JE(같다) 명령어
   MOV DX,STATUS_RG		; STATUS_RG의 값을 확인하여 COMPARE한 결과를 확인
   AND DX,11b
   CMP DX,00b			; 00b 라면(비교한 값이 같을 경우) VDECODE[10]값을 PC에 저장, 아닐경우 함수 종료
   JNE END_M_JE
   MOV AX,VDECODE[10]
   CMP AX, 1000h
   JA M_JE_L1
   MOV PC,AX
END_M_JE:
   RET
M_JE_L1:
   MOV DX, OFFSET STR_WRONGMEMADDR
   CALL PUTS
   CALL NEWLINE
   RET
M_JE ENDP

;------------------------------------------------
;Procedure Name : M_SUB
;Function : SUB 명령어를 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27,2016
;------------------------------------------------
M_SUB PROC
   MOV DX,VDECODE[4]
   AND VDECODE[2],11b

   CMP VDECODE[2],00b
   JE SUB_REGI			; REGISTER 모드 SUB
   CMP VDECODE[2],01b
   JE REST_SUB1         ; IMMEDIATE 모드 SUB
   CMP VDECODE[2],10b
   JE REST_SUB1         ; REGISTER_INDIRECT 모드 SUB
   CMP VDECODE[2],11b
   JE REST_SUB1         ; DIRECT 모드 SUB
   PRINT ERR

SUB_REGI:				; 레지스터 모드 SUB  
   MOV VDECODE[4],DX	; OPERAND1의 값이 A

   CMP VDECODE[4],1000b		;OPERAND1의 값이 A
   JE SUB_A
   CMP VDECODE[4],1001b		;OPERAND1의 값이 B
   JE SUB_B
   CMP VDECODE[4],1010b		;OPERAND1의 값이 C
   JE SUB_C
   CMP VDECODE[4],1011b		;OPERAND1의 값이 D
   JE SUB_D
   CMP VDECODE[4],1100b		;OPERAND1의 값이 E
   JE SUB_E
   CMP VDECODE[4],1101b		;OPERAND1의 값이 F
   JE SUB_F
   CMP VDECODE[4],1110b		;OPERAND1의 값이 X
   JE SUB_X
   CMP VDECODE[4],1111b		;OPERAND1의 값이 Y
   JE SUB_Y

   PRINT ERR
   JMP END_M_SUB

REST_SUB1:
   CMP VDECODE[2],01b
   JE REST_SUB2         ; IMMEDIATE 모드 SUB
   CMP VDECODE[2],10b
   JE REST_SUB2         ; REGISTER_INDIRECT 모드 SUB
   CMP VDECODE[2],11b
   JE REST_SUB2         ; DIRECT 모드 SUB

SUB_A:
   CALL SUB_A_P			;SUB_A_P를 CALL
   JMP END_M_SUB
SUB_B:
   CALL SUB_B_P			;SUB_A_P를 CALL
   JMP END_M_SUB
SUB_C:             
   CALL SUB_C_P			;SUB_A_P를 CALL
   JMP END_M_SUB
SUB_D:             
   CALL SUB_D_P			;SUB_A_P를 CALL
   JMP END_M_SUB
SUB_E:             
   CALL SUB_E_P			;SUB_A_P를 CALL
   JMP END_M_SUB
SUB_F:              
   CALL SUB_F_P			;SUB_A_P를 CALL
   JMP END_M_SUB
SUB_X:             
   CALL SUB_X_P			;SUB_A_P를 CALL
   JMP END_M_SUB
SUB_Y:             
   CALL SUB_Y_P			;SUB_A_P를 CALL
   JMP END_M_SUB

   PRINT ERR
   JMP END_M_SUB

REST_SUB2:
   CMP VDECODE[2],01b
   JE SUB_IMME       ; IMMEDIATE 모드 SUB
   CMP VDECODE[2],10b
   JE REST_SUB3         ; REGISTER_INDIRECT 모드 SUB
   CMP VDECODE[2],11b
   JE REST_SUB3         ; DIRECT 모드 SUB

SUB_IMME:				; IMMEDIATE 모드 SUB	
   MOV VDECODE[4],DX

   CMP VDECODE[4],1000b		;OPERAND1의 값이 A
   JE SUB_A_IMME
   CMP VDECODE[4],1001b		;OPERAND1의 값이 B
   JE SUB_B_IMME
   CMP VDECODE[4],1010b		;OPERAND1의 값이 C
   JE SUB_C_IMME
   CMP VDECODE[4],1011b		;OPERAND1의 값이 D
   JE SUB_D_IMME
   CMP VDECODE[4],1100b		;OPERAND1의 값이 E
   JE SUB_E_IMME
   CMP VDECODE[4],1101b		;OPERAND1의 값이 F
   JE SUB_F_IMME
   CMP VDECODE[4],1110b		;OPERAND1의 값이 X
   JE SUB_X_IMME
   CMP VDECODE[4],1111b		;OPERAND1의 값이 Y
   JE SUB_Y_IMME

   PRINT ERR
   JMP END_M_SUB

REST_SUB3:
   CMP VDECODE[2],10b
   JE SUB_REGI_INDIRECT    ; REGISTER_INDIRECT 모드 SUB
   CMP VDECODE[2],11b
   JE  REST_SUB4        ; DIRECT 모드 SUB

SUB_A_IMME:
   CALL SUB_A_IMME_P	; SUB_A_IMME_P 프로시져 호출
   JMP END_M_SUB
SUB_B_IMME:
   CALL SUB_B_IMME_P	; SUB_B_IMME_P 프로시져 호출
   JMP END_M_SUB
SUB_C_IMME:
   CALL SUB_C_IMME_P	; SUB_C_IMME_P 프로시져 호출
   JMP END_M_SUB
SUB_D_IMME:
   CALL SUB_D_IMME_P	; SUB_D_IMME_P 프로시져 호출
   JMP END_M_SUB
SUB_E_IMME:
   CALL SUB_E_IMME_P	; SUB_E_IMME_P 프로시져 호출
   JMP END_M_SUB
SUB_F_IMME:
   CALL SUB_F_IMME_P	; SUB_F_IMME_P 프로시져 호출
   JMP END_M_SUB
SUB_X_IMME:
   CALL SUB_X_IMME_P	; SUB_X_IMME_P 프로시져 호출
   JMP END_M_SUB
SUB_Y_IMME:
   CALL SUB_Y_IMME_P	; SUB_Y_IMME_P 프로시져 호출
   JMP END_M_SUB
   
   PRINT ERR
   JMP END_M_SUB

REST_SUB4:
   CMP VDECODE[2],11b
   JE  SUB_DIRECT          ; DIRECT 모드 SUB

SUB_REGI_INDIRECT:         ; REGISTER-INDIRECT 모드 SUB
   MOV VDECODE[4],DX

   CMP VDECODE[4],1000b		;OPERAND1의 값이 A
   JE SUB_A_REIN
   CMP VDECODE[4],1001b		;OPERAND1의 값이 B
   JE SUB_B_REIN
   CMP VDECODE[4],1010b		;OPERAND1의 값이 C
   JE SUB_C_REIN
   CMP VDECODE[4],1011b		;OPERAND1의 값이 D
   JE SUB_D_REIN
   CMP VDECODE[4],1100b		;OPERAND1의 값이 E
   JE SUB_E_REIN
   CMP VDECODE[4],1101b		;OPERAND1의 값이 F
   JE SUB_F_REIN
   CMP VDECODE[4],1110b		;OPERAND1의 값이 X
   JE SUB_X_REIN
   CMP VDECODE[4],1111b		;OPERAND1의 값이 Y
   JE SUB_Y_REIN

   PRINT ERR
   JMP END_M_SUB  

SUB_A_REIN:  
   CALL SUB_A_REIN_P		; SUB_A_REIN_P 프로시져 호출
   JMP END_M_SUB
SUB_B_REIN:            
   CALL SUB_B_REIN_P		; SUB_B_REIN_P 프로시져 호출
   JMP END_M_SUB
SUB_C_REIN:            
   CALL SUB_C_REIN_P		; SUB_C_REIN_P 프로시져 호출
   JMP END_M_SUB
SUB_D_REIN:           
   CALL SUB_D_REIN_P		; SUB_D_REIN_P 프로시져 호출
   JMP END_M_SUB
SUB_E_REIN:             
   CALL SUB_E_REIN_P		; SUB_E_REIN_P 프로시져 호출
   JMP END_M_SUB
SUB_F_REIN:            
   CALL SUB_F_REIN_P		; SUB_F_REIN_P 프로시져 호출
   JMP END_M_SUB
SUB_X_REIN:            
   CALL SUB_X_REIN_P		; SUB_X_REIN_P 프로시져 호출
   JMP END_M_SUB
SUB_Y_REIN:           
   CALL SUB_Y_REIN_P		; SUB_Y_REIN_P 프로시져 호출
   JMP END_M_SUB


SUB_DIRECT:					; DIRECT 모드 SUB
   MOV VDECODE[4],DX

   CMP VDECODE[4],1000b		;OPERAND1의 값이 A
   JE SUB_A_DI
   CMP VDECODE[4],1001b		;OPERAND1의 값이 B
   JE SUB_B_DI
   CMP VDECODE[4],1010b		;OPERAND1의 값이 C
   JE SUB_C_DI
   CMP VDECODE[4],1011b		;OPERAND1의 값이 D
   JE SUB_D_DI
   CMP VDECODE[4],1100b		;OPERAND1의 값이 E
   JE SUB_E_DI
   CMP VDECODE[4],1101b		;OPERAND1의 값이 F
   JE SUB_F_DI
   CMP VDECODE[4],1110b		;OPERAND1의 값이 X
   JE SUB_X_DI
   CMP VDECODE[4],1111b		;OPERAND1의 값이 Y
   JE SUB_Y_DI

   PRINT ERR
   JMP END_M_SUB  

SUB_A_DI:
   CALL SUB_A_DI_P			; SUB_A_DI_P 프로시져 호출
   JMP END_M_SUB
SUB_B_DI:
   CALL SUB_B_DI_P			; SUB_B_DI_P 프로시져 호출
   JMP END_M_SUB
SUB_C_DI:
   CALL SUB_C_DI_P			; SUB_C_DI_P 프로시져 호출
   JMP END_M_SUB
SUB_D_DI:
   CALL SUB_D_DI_P			; SUB_D_DI_P 프로시져 호출
   JMP END_M_SUB
SUB_E_DI:
   CALL SUB_E_DI_P			; SUB_E_DI_P 프로시져 호출
   JMP END_M_SUB
SUB_F_DI:
   CALL SUB_F_DI_P			; SUB_F_DI_P 프로시져 호출
   JMP END_M_SUB
SUB_X_DI:
   CALL SUB_X_DI_P			; SUB_X_DI_P 프로시져 호출
   JMP END_M_SUB
SUB_Y_DI:
   CALL SUB_Y_DI_P			; SUB_Y_DI_P 프로시져 호출
   JMP END_M_SUB

END_M_SUB:  
   RET
M_SUB ENDP

;------------------------------------------------
;Procedure Name : SUB_A_P
;Function : SUB A, 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27,2016
;------------------------------------------------
SUB_A_P PROC            ; SUB A,REGISTER

   CMP VDECODE[8],1000b		; OPERAND2 값이 A
   JE SUB_A_A
   CMP VDECODE[8],1001b		; OPERAND2 값이 B
   JE SUB_A_B
   CMP VDECODE[8],1010b		; OPERAND2 값이 C
   JE SUB_A_C
   CMP VDECODE[8],1011b		; OPERAND2 값이 D
   JE SUB_A_D
   CMP VDECODE[8],1100b		; OPERAND2 값이 E
   JE SUB_A_E
   CMP VDECODE[8],1101b		; OPERAND2 값이 F
   JE SUB_A_F
   CMP VDECODE[8],1110b		; OPERAND2 값이 X
   JE SUB_A_X
   CMP VDECODE[8],1111b		; OPERAND2 값이 Y
   JE SUB_A_Y

SUB_A_A:          ; SUB A,A 연산
   MOV DX,A
   SUB A,DX
   JMP END_M_SUB_A_P
SUB_A_B:          ; SUB A,B 연산
   MOV DX,B
   SUB A,DX
   JMP END_M_SUB_A_P
SUB_A_C:          ; SUB A,C 연산
   MOV DX,C
   SUB A,DX
   JMP END_M_SUB_A_P
SUB_A_D:          ; SUB A,D 연산
   MOV DX,D
   SUB A,DX
   JMP END_M_SUB_A_P
SUB_A_E:          ; SUB A,E 연산
   MOV DX,E
   SUB A,DX
   JMP END_M_SUB_A_P
SUB_A_F:          ; SUB A,F 연산
   MOV DX,F
   SUB A,DX
   JMP END_M_SUB_A_P
SUB_A_X:          ; SUB A,X 연산
   MOV DX,X
   SUB A,DX
   JMP END_M_SUB_A_P
SUB_A_Y:          ; SUB A,Y 연산
   MOV DX,Y
   SUB A,DX
   JMP END_M_SUB_A_P

   PRINT ERR         ; 에러 출력

END_M_SUB_A_P:
   RET
SUB_A_P ENDP

;------------------------------------------------
;Procedure Name : SUB_B_P
;Function : SUB B, 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27,2016
;------------------------------------------------
SUB_B_P PROC            ; SUB B,REGISTER

   CMP VDECODE[8],1000b		; OPERAND2 값이 A
   JE SUB_B_A
   CMP VDECODE[8],1001b		; OPERAND2 값이 B
   JE SUB_B_B
   CMP VDECODE[8],1010b		; OPERAND2 값이 C
   JE SUB_B_C
   CMP VDECODE[8],1011b		; OPERAND2 값이 D
   JE SUB_B_D
   CMP VDECODE[8],1100b		; OPERAND2 값이 E
   JE SUB_B_E
   CMP VDECODE[8],1101b		; OPERAND2 값이 F
   JE SUB_B_F
   CMP VDECODE[8],1110b		; OPERAND2 값이 X
   JE SUB_B_X
   CMP VDECODE[8],1111b		; OPERAND2 값이 Y
   JE SUB_B_Y

SUB_B_A:          ; SUB B,A 연산
   MOV DX,A
   SUB B,DX
   JMP END_M_SUB_B_P
SUB_B_B:          ; SUB B,B 연산
   MOV DX,B
   SUB B,DX
   JMP END_M_SUB_B_P
SUB_B_C:          ; SUB B,C 연산
   MOV DX,C
   SUB B,DX
   JMP END_M_SUB_B_P
SUB_B_D:          ; SUB B,D 연산
   MOV DX,D
   SUB B,DX
   JMP END_M_SUB_B_P
SUB_B_E:          ; SUB B,E 연산
   MOV DX,E
   SUB B,DX
   JMP END_M_SUB_B_P
SUB_B_F:          ; SUB B,F 연산
   MOV DX,F
   SUB B,DX
   JMP END_M_SUB_B_P
SUB_B_X:          ; SUB B,X 연산
   MOV DX,X
   SUB B,DX
   JMP END_M_SUB_B_P
SUB_B_Y:          ; SUB B,Y연산
   MOV DX,Y
   SUB B,DX
   JMP END_M_SUB_B_P

   PRINT ERR

END_M_SUB_B_P:
   RET
SUB_B_P ENDP

;------------------------------------------------
;Procedure Name : SUB_C_P
;Function : SUB C, 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27,2016
;------------------------------------------------
SUB_C_P PROC            ; SUB C,REGISTER

   CMP VDECODE[8],1000b		; OPERAND2 값이 A
   JE SUB_C_A
   CMP VDECODE[8],1001b		; OPERAND2 값이 B
   JE SUB_C_B
   CMP VDECODE[8],1010b		; OPERAND2 값이 C
   JE SUB_C_C
   CMP VDECODE[8],1011b		; OPERAND2 값이 D
   JE SUB_C_D
   CMP VDECODE[8],1100b		; OPERAND2 값이 E
   JE SUB_C_E
   CMP VDECODE[8],1101b		; OPERAND2 값이 F
   JE SUB_C_F
   CMP VDECODE[8],1110b		; OPERAND2 값이 X
   JE SUB_C_X
   CMP VDECODE[8],1111b		; OPERAND2 값이 Y
   JE SUB_C_Y

SUB_C_A:          ; SUB C,A 연산
   MOV DX,A
   SUB C,DX
   JMP END_M_SUB_C_P
SUB_C_B:          ; SUB C,B 연산
   MOV DX,B
   SUB C,DX
   JMP END_M_SUB_C_P
SUB_C_C:          ; SUB C,C 연산
   MOV DX,C
   SUB C,DX
   JMP END_M_SUB_C_P
SUB_C_D:          ; SUB C,D 연산
   MOV DX,D
   SUB C,DX
   JMP END_M_SUB_C_P
SUB_C_E:          ; SUB C,E 연산
   MOV DX,E
   SUB C,DX
   JMP END_M_SUB_C_P
SUB_C_F:          ; SUB C,F 연산
   MOV DX,F
   SUB C,DX
   JMP END_M_SUB_C_P
SUB_C_X:          ; SUB C,X 연산
   MOV DX,X
   SUB C,DX
   JMP END_M_SUB_C_P
SUB_C_Y:          ; SUB C,Y연산
   MOV DX,Y
   SUB C,DX
   JMP END_M_SUB_C_P

   PRINT ERR

END_M_SUB_C_P:
   RET
SUB_C_P ENDP

;------------------------------------------------
;Procedure Name : SUB_D_P
;Function : SUB D, 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27,2016
;------------------------------------------------
SUB_D_P PROC            ; SUB D,REGISTER

   CMP VDECODE[8],1000b		; OPERAND2 값이 A
   JE SUB_D_A
   CMP VDECODE[8],1001b		; OPERAND2 값이 B
   JE SUB_D_B
   CMP VDECODE[8],1010b		; OPERAND2 값이 C
   JE SUB_D_C
   CMP VDECODE[8],1011b		; OPERAND2 값이 D
   JE SUB_D_D
   CMP VDECODE[8],1100b		; OPERAND2 값이 E
   JE SUB_D_E
   CMP VDECODE[8],1101b		; OPERAND2 값이 F
   JE SUB_D_F
   CMP VDECODE[8],1110b		; OPERAND2 값이 X
   JE SUB_D_X
   CMP VDECODE[8],1111b		; OPERAND2 값이 Y
   JE SUB_D_Y

SUB_D_A:          ; SUB D,A 연산
   MOV DX,A
   SUB D,DX
   JMP END_M_SUB_D_P
SUB_D_B:          ; SUB D,B 연산
   MOV DX,B
   SUB C,DX
   JMP END_M_SUB_D_P
SUB_D_C:          ; SUB D,C 연산
   MOV DX,C
   SUB C,DX
   JMP END_M_SUB_D_P
SUB_D_D:          ; SUB D,D 연산
   MOV DX,D
   SUB C,DX
   JMP END_M_SUB_D_P
SUB_D_E:          ; SUB D,E 연산
   MOV DX,E
   SUB C,DX
   JMP END_M_SUB_D_P
SUB_D_F:          ; SUB D,F 연산
   MOV DX,F
   SUB C,DX
   JMP END_M_SUB_D_P
SUB_D_X:          ; SUB D,X 연산
   MOV DX,X
   SUB C,DX
   JMP END_M_SUB_D_P
SUB_D_Y:          ; SUB D,Y연산
   MOV DX,Y
   SUB C,DX
   JMP END_M_SUB_D_P

   PRINT ERR

END_M_SUB_D_P:
   RET
SUB_D_P ENDP

;------------------------------------------------
;Procedure Name : SUB_E_P
;Function : SUB E, 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27,2016
;------------------------------------------------
SUB_E_P PROC            ; SUB E,REGISTER

   CMP VDECODE[8],1000b		; OPERAND2 값이 A
   JE SUB_E_A
   CMP VDECODE[8],1001b		; OPERAND2 값이 B
   JE SUB_E_B
   CMP VDECODE[8],1010b		; OPERAND2 값이 C
   JE SUB_E_C
   CMP VDECODE[8],1011b		; OPERAND2 값이 D
   JE SUB_E_D
   CMP VDECODE[8],1100b		; OPERAND2 값이 E
   JE SUB_E_E
   CMP VDECODE[8],1101b		; OPERAND2 값이 F
   JE SUB_E_F
   CMP VDECODE[8],1110b		; OPERAND2 값이 X
   JE SUB_E_X
   CMP VDECODE[8],1111b		; OPERAND2 값이 Y
   JE SUB_E_Y

SUB_E_A:          ; SUB E,A 연산
   MOV DX,A
   SUB E,DX
   JMP END_M_SUB_E_P
SUB_E_B:          ; SUB E,B 연산
   MOV DX,B
   SUB E,DX
   JMP END_M_SUB_E_P
SUB_E_C:          ; SUB E,C 연산
   MOV DX,C
   SUB E,DX
   JMP END_M_SUB_E_P
SUB_E_D:          ; SUB E,D 연산
   MOV DX,D
   SUB E,DX
   JMP END_M_SUB_E_P
SUB_E_E:          ; SUB E,E 연산
   MOV DX,E
   SUB E,DX
   JMP END_M_SUB_E_P
SUB_E_F:          ; SUB E,F 연산
   MOV DX,F
   SUB E,DX
   JMP END_M_SUB_E_P
SUB_E_X:          ; SUB E,X 연산
   MOV DX,X
   SUB E,DX
   JMP END_M_SUB_E_P
SUB_E_Y:          ; SUB E,Y연산
   MOV DX,Y
   SUB E,DX
   JMP END_M_SUB_D_P

   PRINT ERR

END_M_SUB_E_P:
   RET
SUB_E_P ENDP

;------------------------------------------------
;Procedure Name : SUB_F_P
;Function : SUB F, 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27,2016
;------------------------------------------------
SUB_F_P PROC            ; SUB F,REGISTER

   CMP VDECODE[8],1000b		; OPERAND2 값이 A
   JE SUB_F_A
   CMP VDECODE[8],1001b		; OPERAND2 값이 B
   JE SUB_F_B
   CMP VDECODE[8],1010b		; OPERAND2 값이 C
   JE SUB_F_C
   CMP VDECODE[8],1011b		; OPERAND2 값이 D
   JE SUB_F_D
   CMP VDECODE[8],1100b		; OPERAND2 값이 E
   JE SUB_F_E
   CMP VDECODE[8],1101b		; OPERAND2 값이 F
   JE SUB_F_F
   CMP VDECODE[8],1110b		; OPERAND2 값이 X
   JE SUB_F_X
   CMP VDECODE[8],1111b		; OPERAND2 값이 Y
   JE SUB_F_Y

SUB_F_A:          ; SUB F,A 연산
   MOV DX,A
   SUB F,DX
   JMP END_M_SUB_F_P
SUB_F_B:          ; SUB F,B 연산
   MOV DX,B
   SUB F,DX
   JMP END_M_SUB_F_P
SUB_F_C:          ; SUB F,C 연산
   MOV DX,C
   SUB F,DX
   JMP END_M_SUB_F_P
SUB_F_D:          ; SUB F,D 연산
   MOV DX,D
   SUB F,DX
   JMP END_M_SUB_F_P
SUB_F_E:          ; SUB F,E 연산
   MOV DX,E
   SUB F,DX
   JMP END_M_SUB_F_P
SUB_F_F:          ; SUB F,F 연산
   MOV DX,F
   SUB F,DX
   JMP END_M_SUB_F_P
SUB_F_X:          ; SUB F,X 연산
   MOV DX,X
   SUB F,DX
   JMP END_M_SUB_F_P
SUB_F_Y:          ; SUB F,Y연산
   MOV DX,Y
   SUB F,DX
   JMP END_M_SUB_F_P

   PRINT ERR

END_M_SUB_F_P:
   RET
SUB_F_P ENDP

;------------------------------------------------
;Procedure Name : SUB_X_P
;Function : SUB X, 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27,2016
;------------------------------------------------
SUB_X_P PROC            ; SUB X,REGISTER

   CMP VDECODE[8],1000b		; OPERAND2 값이 A
   JE SUB_X_A
   CMP VDECODE[8],1001b		; OPERAND2 값이 B
   JE SUB_X_B
   CMP VDECODE[8],1010b		; OPERAND2 값이 C
   JE SUB_X_C
   CMP VDECODE[8],1011b		; OPERAND2 값이 D
   JE SUB_X_D
   CMP VDECODE[8],1100b		; OPERAND2 값이 E
   JE SUB_X_E
   CMP VDECODE[8],1101b		; OPERAND2 값이 F
   JE SUB_X_F
   CMP VDECODE[8],1110b		; OPERAND2 값이 X
   JE SUB_X_X
   CMP VDECODE[8],1111b		; OPERAND2 값이 Y
   JE SUB_X_Y

SUB_X_A:          ; SUB X,A 연산
   MOV DX,A
   SUB X,DX
   JMP END_M_SUB_X_P
SUB_X_B:          ; SUB X,B 연산
   MOV DX,B
   SUB X,DX
   JMP END_M_SUB_X_P
SUB_X_C:          ; SUB X,C 연산
   MOV DX,C
   SUB X,DX
   JMP END_M_SUB_X_P
SUB_X_D:          ; SUB X,D 연산
   MOV DX,D
   SUB X,DX
   JMP END_M_SUB_X_P
SUB_X_E:          ; SUB X,E 연산
   MOV DX,E
   SUB X,DX
   JMP END_M_SUB_X_P
SUB_X_F:          ; SUB X,F 연산
   MOV DX,F
   SUB X,DX
   JMP END_M_SUB_X_P
SUB_X_X:          ; SUB X,X 연산
   MOV DX,X
   SUB X,DX
   JMP END_M_SUB_X_P
SUB_X_Y:          ; SUB X,Y연산
   MOV DX,Y
   SUB X,DX
   JMP END_M_SUB_X_P

   PRINT ERR

END_M_SUB_X_P:
   RET
SUB_X_P ENDP

;------------------------------------------------
;Procedure Name : SUB_Y_P
;Function : SUB Y, 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27,2016
;------------------------------------------------
SUB_Y_P PROC            ; SUB Y,REGISTER

   CMP VDECODE[8],1000b		; OPERAND2 값이 A
   JE SUB_Y_A
   CMP VDECODE[8],1001b		; OPERAND2 값이 B
   JE SUB_Y_B
   CMP VDECODE[8],1010b		; OPERAND2 값이 C
   JE SUB_Y_C
   CMP VDECODE[8],1011b		; OPERAND2 값이 D
   JE SUB_Y_D
   CMP VDECODE[8],1100b		; OPERAND2 값이 E
   JE SUB_Y_E
   CMP VDECODE[8],1101b		; OPERAND2 값이 F
   JE SUB_Y_F
   CMP VDECODE[8],1110b		; OPERAND2 값이 X
   JE SUB_Y_X
   CMP VDECODE[8],1111b		; OPERAND2 값이 Y
   JE SUB_Y_Y

SUB_Y_A:          ; SUB Y,A 연산
   MOV DX,A
   SUB Y,DX
   JMP END_M_SUB_Y_P
SUB_Y_B:          ; SUB Y,B 연산
   MOV DX,B
   SUB Y,DX
   JMP END_M_SUB_Y_P
SUB_Y_C:          ; SUB Y,C 연산
   MOV DX,C
   SUB Y,DX
   JMP END_M_SUB_Y_P
SUB_Y_D:          ; SUB Y,D 연산
   MOV DX,D
   SUB Y,DX
   JMP END_M_SUB_Y_P
SUB_Y_E:          ; SUB Y,E 연산
   MOV DX,E
   SUB Y,DX
   JMP END_M_SUB_Y_P
SUB_Y_F:          ; SUB Y,F 연산
   MOV DX,F
   SUB Y,DX
   JMP END_M_SUB_Y_P
SUB_Y_X:          ; SUB Y,X 연산
   MOV DX,X
   SUB Y,DX
   JMP END_M_SUB_Y_P
SUB_Y_Y:          ; SUB Y,Y연산
   MOV DX,Y
   SUB Y,DX
   JMP END_M_SUB_Y_P

   PRINT ERR

END_M_SUB_Y_P:
   RET
SUB_Y_P ENDP

;------------------------------------------------
;Procedure Name : SUB_A_IMME_P
;Function : SUB A,IMMEDIATE 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27,2016
;------------------------------------------------
SUB_A_IMME_P PROC       ; SUB A,IMMEDIATE

   MOV BX,VDECODE[10]	; IMMEDIATE값이 저장되어있는 VDECODE[10]값을 A와 SUB연산
   SUB A,BX
   RET
SUB_A_IMME_P ENDP

;------------------------------------------------
;Procedure Name : SUB_B_IMME_P
;Function : SUB B,IMMEDIATE 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27,2016
;------------------------------------------------
SUB_B_IMME_P PROC       ; SUB B,IMMEDIATE

   MOV BX,VDECODE[10]	; IMMEDIATE값이 저장되어있는 VDECODE[10]값을 B와 SUB연산
   SUB B,BX
   RET
SUB_B_IMME_P ENDP

;------------------------------------------------
;Procedure Name : SUB_C_IMME_P
;Function : SUB C,IMMEDIATE 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27,2016
;------------------------------------------------
SUB_C_IMME_P PROC       ; SUB C,IMMEDIATE

   MOV BX,VDECODE[10]	; IMMEDIATE값이 저장되어있는 VDECODE[10]값을 C와 SUB연산
   SUB C,BX
   RET
SUB_C_IMME_P ENDP

;------------------------------------------------
;Procedure Name : SUB_D_IMME_P
;Function : SUB D,IMMEDIATE 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27,2016
;------------------------------------------------
SUB_D_IMME_P PROC       ; SUB D,IMMEDIATE

   MOV BX,VDECODE[10]	; IMMEDIATE값이 저장되어있는 VDECODE[10]값을 D와 SUB연산
   SUB D,BX
   RET
SUB_D_IMME_P ENDP

;------------------------------------------------
;Procedure Name : SUB_E_IMME_P
;Function : SUB E,IMMEDIATE 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27,2016
;------------------------------------------------
SUB_E_IMME_P PROC       ; SUB E,IMMEDIATE

   MOV BX,VDECODE[10]	; IMMEDIATE값이 저장되어있는 VDECODE[10]값을 E와 SUB연산
   SUB E,BX
   RET
SUB_E_IMME_P ENDP

;------------------------------------------------
;Procedure Name : SUB_F_IMME_P
;Function : SUB F,IMMEDIATE 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27,2016
;------------------------------------------------
SUB_F_IMME_P PROC       ; SUB F,IMMEDIATE

   MOV BX,VDECODE[10]	; IMMEDIATE값이 저장되어있는 VDECODE[10]값을 F와 SUB연산
   SUB F,BX
   RET
SUB_F_IMME_P ENDP

;------------------------------------------------
;Procedure Name : SUB_X_IMME_P
;Function : SUB X,IMMEDIATE 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27,2016
;------------------------------------------------
SUB_X_IMME_P PROC       ; SUB X,IMMEDIATE

   MOV BX,VDECODE[10]	; IMMEDIATE값이 저장되어있는 VDECODE[10]값을 X와 SUB연산
   SUB X,BX
   RET
SUB_X_IMME_P ENDP

;------------------------------------------------
;Procedure Name : SUB_Y_IMME_P
;Function : SUB Y,IMMEDIATE 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27,2016
;------------------------------------------------
SUB_Y_IMME_P PROC       ; SUB Y,IMMEDIATE

   MOV BX,VDECODE[10]	; IMMEDIATE값이 저장되어있는 VDECODE[10]값을 Y와 SUB연산
   SUB Y,BX
   RET
SUB_Y_IMME_P ENDP

;------------------------------------------------
;Procedure Name : SUB_A_REIN_P
;Function : SUB A, REGISTER-INDIRECT 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27,2016
;------------------------------------------------
SUB_A_REIN_P PROC       ; SUB A,[] 프로시져
   CMP VDECODE[8],1110b		; OPERAND2 가 X
   JE SUB_A_REIN_X
   CMP VDECODE[8],1111b		; OPERAND2 가 Y
   JE SUB_A_REIN_Y
   
   PRINT ERR
   JMP END_M_SUB_A_REIN_P
SUB_A_REIN_X:
   MOV SI,X					; SUB A,[X]
   MOV BX,M[SI]
   SUB A,BX
   JMP END_M_SUB_A_REIN_P
SUB_A_REIN_Y:
   MOV SI,Y					; SUB A,[Y]
   MOV BX,M[SI]
   SUB A,BX
   JMP END_M_SUB_A_REIN_P

END_M_SUB_A_REIN_P:
   RET
SUB_A_REIN_P ENDP

;------------------------------------------------
;Procedure Name : SUB_B_REIN_P
;Function : SUB B, REGISTER-INDIRECT 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27,2016
;------------------------------------------------
SUB_B_REIN_P PROC       ; SUB B,[] 프로시져
   CMP VDECODE[8],1110b	; OPERAND2 가 X
   JE SUB_B_REIN_X
   CMP VDECODE[8],1111b	; OPERAND2 가 Y
   JE SUB_B_REIN_Y
   
   PRINT ERR
   JMP END_M_SUB_B_REIN_P
SUB_B_REIN_X:
   MOV SI,X				; SUB B,[X]
   MOV BX,M[SI]
   SUB B,BX
   JMP END_M_SUB_B_REIN_P
SUB_B_REIN_Y:
   MOV SI,Y				; SUB B,[X]
   MOV BX,M[SI]
   SUB B,BX
   JMP END_M_SUB_B_REIN_P

END_M_SUB_B_REIN_P:
   RET
SUB_B_REIN_P ENDP

;------------------------------------------------
;Procedure Name : SUB_C_REIN_P
;Function : SUB C, REGISTER-INDIRECT 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27,2016
;------------------------------------------------
SUB_C_REIN_P PROC       ; SUB C,[] 프로시져
   CMP VDECODE[8],1110b ; OPERAND2 가 X
   JE SUB_C_REIN_X
   CMP VDECODE[8],1111b ; OPERAND2 가 Y
   JE SUB_C_REIN_Y
   
   PRINT ERR
   JMP END_M_SUB_C_REIN_P
SUB_C_REIN_X:
   MOV SI,X				; SUB C,[X]
   MOV BX,M[SI]
   SUB C,BX
   JMP END_M_SUB_C_REIN_P
SUB_C_REIN_Y:
   MOV SI,Y				; SUB C,[Y]
   MOV BX,M[SI]
   SUB C,BX
   JMP END_M_SUB_C_REIN_P

END_M_SUB_C_REIN_P:
   RET
SUB_C_REIN_P ENDP

;------------------------------------------------
;Procedure Name : SUB_D_REIN_P
;Function : SUB D, REGISTER-INDIRECT 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27,2016
;------------------------------------------------
SUB_D_REIN_P PROC       ; SUB D,[] 프로시져
   CMP VDECODE[8],1110b ; OPERAND2 가 X
   JE SUB_D_REIN_X
   CMP VDECODE[8],1111b ; OPERAND2 가 Y
   JE SUB_D_REIN_Y
   
   PRINT ERR
   JMP END_M_SUB_D_REIN_P
SUB_D_REIN_X:
   MOV SI,X				; SUB D,[X]
   MOV BX,M[SI]
   SUB D,BX
   JMP END_M_SUB_D_REIN_P
SUB_D_REIN_Y:
   MOV SI,Y				; SUB D,[Y]
   MOV BX,M[SI]
   SUB D,BX
   JMP END_M_SUB_D_REIN_P

END_M_SUB_D_REIN_P:
   RET
SUB_D_REIN_P ENDP

;------------------------------------------------
;Procedure Name : SUB_E_REIN_P
;Function : SUB E, REGISTER-INDIRECT 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27,2016
;------------------------------------------------
SUB_E_REIN_P PROC       ; SUB E,[] 프로시져
   CMP VDECODE[8],1110b ; OPERAND2 가 X
   JE SUB_E_REIN_X
   CMP VDECODE[8],1111b ; OPERAND2 가 Y
   JE SUB_E_REIN_Y
   
   PRINT ERR
   JMP END_M_SUB_E_REIN_P
SUB_E_REIN_X:
   MOV SI,X			; SUB E,[X]
   MOV BX,M[SI]
   SUB E,BX
   JMP END_M_SUB_E_REIN_P
SUB_E_REIN_Y:
   MOV SI,Y			; SUB E,[Y]
   MOV BX,M[SI]
   SUB E,BX
   JMP END_M_SUB_B_REIN_P

END_M_SUB_E_REIN_P:
   RET
SUB_E_REIN_P ENDP

;------------------------------------------------
;Procedure Name : SUB_F_REIN_P
;Function : SUB F, REGISTER-INDIRECT 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27,2016
;------------------------------------------------
SUB_F_REIN_P PROC       ; SUB F,[] 프로시져
   CMP VDECODE[8],1110b ; OPERAND2 가 X
   JE SUB_F_REIN_X
   CMP VDECODE[8],1111b ; OPERAND2 가 Y
   JE SUB_F_REIN_Y
   
   PRINT ERR
   JMP END_M_SUB_F_REIN_P
SUB_F_REIN_X:
   MOV SI,X 		; SUB F,[X]
   MOV BX,M[SI]
   SUB F,BX
   JMP END_M_SUB_F_REIN_P
SUB_F_REIN_Y:
   MOV SI,Y 		; SUB F,[Y]
   MOV BX,M[SI]
   SUB F,BX
   JMP END_M_SUB_F_REIN_P

END_M_SUB_F_REIN_P:
   RET
SUB_F_REIN_P ENDP

;------------------------------------------------
;Procedure Name : SUB_X_REIN_P
;Function : SUB X, REGISTER-INDIRECT 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27,2016
;------------------------------------------------
SUB_X_REIN_P PROC       ; SUB X,[] 프로시져
   CMP VDECODE[8],1110b ; OPERAND2 가 X
   JE SUB_X_REIN_X
   CMP VDECODE[8],1111b ; OPERAND2 가 Y
   JE SUB_X_REIN_Y
   
   PRINT ERR
   JMP END_M_SUB_X_REIN_P
SUB_X_REIN_X:
   MOV SI,X		; SUB X,[X]
   MOV BX,M[SI]
   SUB X,BX
   JMP END_M_SUB_X_REIN_P
SUB_X_REIN_Y:
   MOV SI,Y		; SUB X,[Y]
   MOV BX,M[SI]
   SUB X,BX
   JMP END_M_SUB_X_REIN_P

END_M_SUB_X_REIN_P:
   RET
SUB_X_REIN_P ENDP

;------------------------------------------------
;Procedure Name : SUB_Y_REIN_P
;Function : SUB Y, REGISTER-INDIRECT 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27,2016
;------------------------------------------------
SUB_Y_REIN_P PROC       ; SUB Y,[] 프로시져
   CMP VDECODE[8],1110b ; OPERAND2 가 X
   JE SUB_Y_REIN_X
   CMP VDECODE[8],1111b ; OPERAND2 가 Y
   JE SUB_Y_REIN_Y
   
   PRINT ERR
   JMP END_M_SUB_Y_REIN_P
SUB_Y_REIN_X:
   MOV SI,X		; SUB Y,[X]
   MOV BX,M[SI]
   SUB Y,BX
   JMP END_M_SUB_Y_REIN_P
SUB_Y_REIN_Y:
   MOV SI,Y		; SUB Y,[Y]
   MOV BX,M[SI]
   SUB Y,BX
   JMP END_M_SUB_Y_REIN_P

END_M_SUB_Y_REIN_P:
   RET
SUB_Y_REIN_P ENDP

;------------------------------------------------
;Procedure Name : SUB_A_DI_P
;Function : SUB A, DIRCET 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27,2016
;------------------------------------------------
SUB_A_DI_P PROC
   
   MOV SI, VDECODE[10]  ; VDECODE[10]에 저장 되어있는 주소값을 SI에 저장
   MOV BX, m[SI]
   SUB A,BX				; A의 값에 M[SI] 값을 SUB연산 

   RET
SUB_A_DI_P ENDP

;------------------------------------------------
;Procedure Name : SUB_B_DI_P
;Function : SUB B, DIRCET 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27,2016
;------------------------------------------------
SUB_B_DI_P PROC
   
   MOV SI, VDECODE[10]  ; VDECODE[10]에 저장 되어있는 주소값을 SI에 저장  
   MOV BX, m[SI]
   SUB B,BX				; B의 값에 M[SI] 값을 SUB연산 

   RET
SUB_B_DI_P ENDP

;------------------------------------------------
;Procedure Name : SUB_C_DI_P
;Function : SUB C, DIRCET 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27,2016
;------------------------------------------------
SUB_C_DI_P PROC
   
   MOV SI, VDECODE[10]  ; VDECODE[10]에 저장 되어있는 주소값을 SI에 저장  
   MOV BX, m[SI]
   SUB C,BX				; C의 값에 M[SI] 값을 SUB연산

   RET
SUB_C_DI_P ENDP

;------------------------------------------------
;Procedure Name : SUB_D_DI_P
;Function : SUB D, DIRCET 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27,2016
;------------------------------------------------
SUB_D_DI_P PROC
   
   MOV SI, VDECODE[10]    ; VDECODE[10]에 저장 되어있는 주소값을 SI에 저장
   MOV BX, m[SI]
   SUB D,BX			; D의 값에 M[SI] 값을 SUB연산

   RET
SUB_D_DI_P ENDP

;------------------------------------------------
;Procedure Name : SUB_E_DI_P
;Function : SUB E, DIRCET 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27,2016
;------------------------------------------------
SUB_E_DI_P PROC
   
   MOV SI, VDECODE[10]      ; VDECODE[10]에 저장 되어있는 주소값을 SI에 저장
   MOV BX, m[SI]
   SUB E,BX				; E의 값에 M[SI] 값을 SUB연산

   RET
SUB_E_DI_P ENDP

;------------------------------------------------
;Procedure Name : SUB_F_DI_P
;Function : SUB F, DIRCET 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27,2016
;------------------------------------------------
SUB_F_DI_P PROC
   
   MOV SI, VDECODE[10]       ; VDECODE[10]에 저장 되어있는 주소값을 SI에 저장 
   MOV BX, m[SI]
   SUB F,BX			; F의 값에 M[SI] 값을 SUB연산

   RET
SUB_F_DI_P ENDP

;------------------------------------------------
;Procedure Name : SUB_X_DI_P
;Function : SUB X, DIRCET 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27,2016
;------------------------------------------------
SUB_X_DI_P PROC
   
   MOV SI, VDECODE[10]       ; VDECODE[10]에 저장 되어있는 주소값을 SI에 저장 
   MOV BX, m[SI]
   SUB X,BX					; X의 값에 M[SI] 값을 SUB연산

   RET
SUB_X_DI_P ENDP

;------------------------------------------------
;Procedure Name : SUB_Y_DI_P
;Function : SUB Y, DIRCET 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27,2016
;------------------------------------------------
SUB_Y_DI_P PROC
   
   MOV SI, VDECODE[10]         ; VDECODE[10]에 저장 되어있는 주소값을 SI에 저장
   MOV BX, m[SI]
   SUB Y,BX				; Y의 값에 M[SI] 값을 SUB연산

   RET
SUB_Y_DI_P ENDP


;------------------------------------------------
;Procedure Name : M_MOV
;Function : MOV 명령어를 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 26,2016
;   Last Modified On Nov 26,2016
;------------------------------------------------
M_MOV PROC
	CMP VDECODE[4], 0000b	;첫번째 피연산자를 의미하는 VDECODE[4]가 0이면 MOV 주소값,레지스터를 의미
	JE M_MOV_IMMEDIATE_REST
   CMP VDECODE[4],1000b ; OPERAND1이 A일 때
   JE M_MOV_A
   CMP VDECODE[4],1001b ; OPERAND1이 B일 때
   JE M_MOV_B
   CMP VDECODE[4],1010b ; OPERAND1이 C일 때
   JE M_MOV_C           
   CMP VDECODE[4],1011b ; OPERAND1이 D일 때
   JE REST_MOV1
   CMP VDECODE[4],1100b ; OPERAND1이 E일 때
   JE REST_MOV1
   CMP VDECODE[4],1101b ; OPERAND1이 F일 때
   JE REST_MOV1
   CMP VDECODE[4],1110b ; OPERAND1이 X일 때
   JE REST_MOV1
   CMP VDECODE[4],1111b ; OPERAND1이 Y일 때
   JE REST_MOV1

   PRINT ERR
   JMP END_M_MOV

M_MOV_A:											; OPERAND1이 A일 때
   CALL MOV_A_P										; MOV_A_P를 호출
   JMP END_M_MOV

M_MOV_B:											; OPERAND1이 B일 때
   CALL MOV_B_P										; MOV_B_P를 호출
   JMP END_M_MOV

M_MOV_IMMEDIATE_REST:
   JMP M_MOV_IMMEDIATE

M_MOV_C:											; OPERAND1이 C일 때
   CALL MOV_C_P										; MOV_C_P를 호출
   JMP END_M_MOV
   
REST_MOV1:
   CMP VDECODE[4],1011b ; OPERAND1이 D일 때
   JE M_MOV_D
   CMP VDECODE[4],1100b ; OPERAND1이 E일 때
   JE M_MOV_E
   CMP VDECODE[4],1101b ; OPERAND1이 F일 때
   JE M_MOV_F
   CMP VDECODE[4],1110b ; OPERAND1이 X일 때
   JE M_MOV_X
   CMP VDECODE[4],1111b ; OPERAND1이 Y일 때
   JE M_MOV_Y

   PRINT ERR
   JMP END_M_MOV

M_MOV_D:											; OPERAND1이 D일 때
   CALL MOV_D_P										; MOV_D_P를 호출
   JMP END_M_MOV

M_MOV_E:											; OPERAND1이 E일 때
   CALL MOV_E_P										; MOV_E_P를 호출
   JMP END_M_MOV

M_MOV_F:											; OPERAND1이 F일 때
   CALL MOV_F_P										; MOV_F_P를 호출
   JMP END_M_MOV

M_MOV_X:											; OPERAND1이 X일 때
   CALL MOV_X_P										; MOV_X_P를 호출
   JMP END_M_MOV

M_MOV_Y:											; OPERAND1이 Y일 때
   CALL MOV_Y_P										; MOV_Y_P를 호출
   JMP END_M_MOV

M_MOV_IMMEDIATE:											; OPERAND1이 주소값 일 때
	CALL M_MOV_IMMEDIATE_P									; M_MOV_IMMEDIATE_P를 호출
	JMP END_M_MOV
END_M_MOV:
   RET
M_MOV ENDP

;------------------------------------------------
;Procedure Name : M_MOV_IMMEDIATE_P
;Function : MOV 주소값,레지스터 기능을 실행
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 26,2016
;   Last Modified On Nov 26,2016
;------------------------------------------------
M_MOV_IMMEDIATE_P PROC
	CMP VDECODE[8],1000b
	MOV AX,A
	JE M_MOV_IMMDIATE_P_EXIT
	CMP VDECODE[8],1001b
	MOV AX,B
	JE M_MOV_IMMDIATE_P_EXIT
	CMP VDECODE[8],1010b
	MOV AX,C
	JE M_MOV_IMMDIATE_P_EXIT
	CMP VDECODE[8],1011b
	MOV AX,D
	JE M_MOV_IMMDIATE_P_EXIT
	CMP VDECODE[8],1100b
	MOV AX,E
	JE M_MOV_IMMDIATE_P_EXIT
	CMP VDECODE[8],1101b
	MOV AX,F
	JE M_MOV_IMMDIATE_P_EXIT
	CMP VDECODE[8],1110b
	MOV AX,X
	JE M_MOV_IMMDIATE_P_EXIT
	CMP VDECODE[8],1111b
	MOV AX,Y
	JE M_MOV_IMMDIATE_P_EXIT
M_MOV_IMMDIATE_P_EXIT:
	MOV SI,VDECODE[10]
	MOV M[SI],AX
	RET
M_MOV_IMMEDIATE_P ENDP

;------------------------------------------------
;Procedure Name : MOV_A_P
;Function : MOV A, 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 26,2016
;   Last Modified On Nov 26,2016
;------------------------------------------------
MOV_A_P PROC
   MOV AX, VDECODE[2]
   AND AX,11b
   MOV VDECODE[2],AX
								; MOV A,
   CMP VDECODE[2],00b			; VDECODE[2]값을 확인하여 00이면 Register 모드
   JE MOV_A_REGI
   CMP VDECODE[2],01b			; VDECODE[2]값을 확인하여 01이면 Immediate 모드
   JE MOV_A_IMME
   CMP VDECODE[2],10b			; VDECODE[2]값을 확인하여 10이면 Register-Indirect 모드
   JE MOV_A_REGI_IMME
   CMP VDECODE[2],11b			; VDECODE[2]값을 확인하여 11이면 Direct 모드
   JE MOV_A_DI

   PRINT ERR
   JMP END_M_MOV_A_P

MOV_A_REGI:
   CALL MOV_A_REGI_P
   JMP END_M_MOV_A_P
MOV_A_IMME:
   CALL MOV_A_IMME_P
   JMP END_M_MOV_A_P
MOV_A_REGI_IMME:
   CALL MOV_A_REGI_IMME_P
   JMP END_M_MOV_A_P
MOV_A_DI:
   CALL MOV_A_DI_P
   JMP END_M_MOV_A_P

END_M_MOV_A_P:
   RET
MOV_A_P ENDP

;------------------------------------------------
;Procedure Name : MOV_A_REGI_P
;Function : MOV A,REGISTER 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 26,2016
;   Last Modified On Nov 26,2016
;------------------------------------------------
MOV_A_REGI_P PROC
   MOV AX,VDECODE[8]                         ; MOV A,REGISTER
   AND AX,1111b
   MOV VDECODE[8],AX

   CMP VDECODE[8],1000b						; 피연산자2의 값이 저장되어있는 VDECODE[8]이 1000b이면 MOV A,A
   JE MOV_A_A
   CMP VDECODE[8],1001b						; 피연산자2의 값이 저장되어있는 VDECODE[8]이 1001b이면 MOV A,B
   JE MOV_A_B
   CMP VDECODE[8],1010b						; 피연산자2의 값이 저장되어있는 VDECODE[8]이 1010b이면 MOV A,C
   JE MOV_A_C
   CMP VDECODE[8],1011b						; 피연산자2의 값이 저장되어있는 VDECODE[8]이 1011b이면 MOV A,D
   JE MOV_A_D
   CMP VDECODE[8],1100b						; 피연산자2의 값이 저장되어있는 VDECODE[8]이 1100b이면 MOV A,E
   JE MOV_A_E
   CMP VDECODE[8],1101b						; 피연산자2의 값이 저장되어있는 VDECODE[8]이 1101b이면 MOV A,F
   JE MOV_A_F
   CMP VDECODE[8],1110b						; 피연산자2의 값이 저장되어있는 VDECODE[8]이 1110b이면 MOV A,X
   JE MOV_A_X
   CMP VDECODE[8],1111b						; 피연산자2의 값이 저장되어있는 VDECODE[8]이 1111b이면 MOV A,Y
   JE MOV_A_Y

   PRINT ERR
   JMP END_M_MOV_A_REGI_P

MOV_A_A:									; MOV A,A를 진행
   MOV AX,A
   MOV A,AX
   JMP END_M_MOV_A_REGI_P
MOV_A_B:									; MOV A,B를 진행
   MOV AX,B
   MOV A,AX
   JMP END_M_MOV_A_REGI_P
MOV_A_C:									; MOV A,C를 진행
   MOV AX,C
   MOV A,AX
   JMP END_M_MOV_A_REGI_P
MOV_A_D:									; MOV A,D를 진행
   MOV AX,D
   MOV A,AX
   JMP END_M_MOV_A_REGI_P
MOV_A_E:									; MOV A,E를 진행
   MOV AX,E
   MOV A,AX
   JMP END_M_MOV_A_REGI_P
MOV_A_F:									; MOV A,F를 진행
   MOV AX,F
   MOV A,AX
   JMP END_M_MOV_A_REGI_P
MOV_A_X:									; MOV A,X를 진행
   MOV AX,X
   MOV A,AX
   JMP END_M_MOV_A_REGI_P
MOV_A_Y:									; MOV A,Y를 진행
   MOV AX,Y
   MOV A,AX
   JMP END_M_MOV_A_REGI_P
   
   PRINT ERR
   JMP END_M_MOV_A_REGI_P

END_M_MOV_A_REGI_P:
   RET
MOV_A_REGI_P ENDP

;------------------------------------------------
;Procedure Name : MOV_A_IMME_P
;Function : MOV A,IMMEDIATE 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 26,2016
;   Last Modified On Nov 26,2016
;------------------------------------------------
MOV_A_IMME_P PROC                   
   MOV DX,VDECODE[10]					; VDECODE[10]에 저장되어있는 IMMEDIATE값을 레지스터 A에 저장
   MOV A,DX
   RET
MOV_A_IMME_P ENDP

;------------------------------------------------
;Procedure Name : MOV_A_REGI_IMME_P
;Function : MOV 명령어의 REGISTER-INDIRECT 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 26,2016
;   Last Modified On Nov 26,2016
;------------------------------------------------
MOV_A_REGI_IMME_P PROC                 ; MOV A,REGISTER_IMMEDIATE
   CMP VDECODE[8],1110				   ; 피연산자2의 값이 X
   JE MOV_A_R_I_X
   CMP VDECODE[8],1111				   ; 피연산자2의 값이 Y
   JE MOV_A_R_I_Y
   
MOV_A_R_I_X:							; MOV A,[X]
   MOV SI,X
   MOV DX,M[SI]
   MOV A,DX
   JMP END_M_MOV_A_REGI_IMME_P
MOV_A_R_I_Y:							; MOV A,[Y]
   MOV SI,Y
   MOV DX,M[SI]
   MOV A,DX

END_M_MOV_A_REGI_IMME_P:
   RET
MOV_A_REGI_IMME_P ENDP

;------------------------------------------------
;Procedure Name : MOV_A_DI_P
;Function : MOV 명령어의 DIRECT 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 26,2016
;   Last Modified On Nov 26,2016
;------------------------------------------------
MOV_A_DI_P PROC                     ; MOV A,DIRECT
   MOV SI,VDECODE[10]				; VDECODE값에 들어있는 DIRCET주소값을 저장
   MOV DX,M[SI]
   MOV A,DX
   RET
MOV_A_DI_P ENDP

;------------------------------------------------
;Procedure Name : MOV_B_P
;Function : MOV B, 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 26,2016
;   Last Modified On Nov 26,2016
;------------------------------------------------
MOV_B_P PROC
   MOV AX, VDECODE[2]
   AND AX,11b
   MOV VDECODE[2],AX
                              ; MOV B,
   CMP VDECODE[2],00b			; VDECODE[2]값을 확인하여 00이면 Register 모드
   JE MOV_B_REGI
   CMP VDECODE[2],01b			; VDECODE[2]값을 확인하여 01이면 Immediate 모드
   JE MOV_B_IMME
   CMP VDECODE[2],10b			; VDECODE[2]값을 확인하여 10이면 Register-Indirect 모드
   JE MOV_B_REGI_IMME
   CMP VDECODE[2],11b			; VDECODE[2]값을 확인하여 11이면 Direct 모드
   JE MOV_B_DI

   PRINT ERR
   JMP END_M_MOV_B_P

MOV_B_REGI:
   CALL MOV_B_REGI_P
   JMP END_M_MOV_B_P
MOV_B_IMME:
   CALL MOV_B_IMME_P
   JMP END_M_MOV_B_P
MOV_B_REGI_IMME:
   CALL MOV_B_REGI_IMME_P
   JMP END_M_MOV_B_P
MOV_B_DI:
   CALL MOV_B_DI_P
   JMP END_M_MOV_B_P

END_M_MOV_B_P:
   RET
MOV_B_P ENDP

;------------------------------------------------
;Procedure Name : MOV_B_REGI_P
;Function : MOV B,REGISTER 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 26,2016
;   Last Modified On Nov 26,2016
;------------------------------------------------
MOV_B_REGI_P PROC
   MOV AX,VDECODE[8]                         ; MOV B,REGISTER
   AND AX,1111b
   MOV VDECODE[8],AX

   CMP VDECODE[8],1000b						; 피연산자2의 값이 저장되어있는 VDECODE[8]이 1000b이면 MOV B,A
   JE MOV_B_A
   CMP VDECODE[8],1001b						; 피연산자2의 값이 저장되어있는 VDECODE[8]이 1000b이면 MOV B,B
   JE MOV_B_B
   CMP VDECODE[8],1010b						; 피연산자2의 값이 저장되어있는 VDECODE[8]이 1000b이면 MOV B,C
   JE MOV_B_C
   CMP VDECODE[8],1011b						; 피연산자2의 값이 저장되어있는 VDECODE[8]이 1000b이면 MOV B,D
   JE MOV_B_D
   CMP VDECODE[8],1100b						; 피연산자2의 값이 저장되어있는 VDECODE[8]이 1000b이면 MOV B,E
   JE MOV_B_E
   CMP VDECODE[8],1101b						; 피연산자2의 값이 저장되어있는 VDECODE[8]이 1000b이면 MOV B,F
   JE MOV_B_F
   CMP VDECODE[8],1110b						; 피연산자2의 값이 저장되어있는 VDECODE[8]이 1000b이면 MOV B,X
   JE MOV_B_X
   CMP VDECODE[8],1111b						; 피연산자2의 값이 저장되어있는 VDECODE[8]이 1000b이면 MOV B,Y
   JE MOV_B_Y

   PRINT ERR
   JMP END_M_MOV_B_REGI_P

MOV_B_A:									; MOV B,A를 진행
   MOV AX,A
   MOV B,AX
   JMP END_M_MOV_B_REGI_P
MOV_B_B:									; MOV B,B를 진행
   MOV AX,B
   MOV B,AX
   JMP END_M_MOV_B_REGI_P
MOV_B_C:									; MOV B,C를 진행
   MOV AX,C
   MOV B,AX
   JMP END_M_MOV_B_REGI_P
MOV_B_D:									; MOV B,D를 진행
   MOV AX,D
   MOV B,AX
   JMP END_M_MOV_B_REGI_P
MOV_B_E:									; MOV B,E를 진행
   MOV AX,E
   MOV B,AX
   JMP END_M_MOV_B_REGI_P
MOV_B_F:									; MOV B,F를 진행
   MOV AX,F
   MOV B,AX
   JMP END_M_MOV_B_REGI_P
MOV_B_X:									; MOV B,X를 진행
   MOV AX,X
   MOV B,AX
   JMP END_M_MOV_B_REGI_P
MOV_B_Y:									; MOV B,Y를 진행
   MOV AX,Y
   MOV B,AX
   JMP END_M_MOV_B_REGI_P
   
   PRINT ERR
   JMP END_M_MOV_B_REGI_P

END_M_MOV_B_REGI_P:
   RET
MOV_B_REGI_P ENDP

;------------------------------------------------
;Procedure Name : MOV_B_IMME_P
;Function : MOV B,IMMEDIATE 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 26,2016
;   Last Modified On Nov 26,2016
;------------------------------------------------
MOV_B_IMME_P PROC                   ; MOV B,IMMEDIATE
   MOV DX,VDECODE[10]
   MOV B,DX
   RET
MOV_B_IMME_P ENDP

;------------------------------------------------
;Procedure Name : MOV_B_REGI_IMME_P
;Function : MOV 명령어의 REGISTER-INDIRECT 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 26,2016
;   Last Modified On Nov 26,2016
;------------------------------------------------
MOV_B_REGI_IMME_P PROC                 ; MOV B,REGISTER_IMMEDIATE
   CMP VDECODE[8],1110				   ; 피연산자2의 값이 X
   JE MOV_B_R_I_X
   CMP VDECODE[8],1111				   ; 피연산자2의 값이 Y
   JE MOV_B_R_I_Y
   
MOV_B_R_I_X:							; MOV B,[X]
   MOV SI,X
   MOV DX,M[SI]
   MOV B,DX
   JMP END_M_MOV_B_REGI_IMME_P
MOV_B_R_I_Y:							; MOV B,[Y]
   MOV SI,Y
   MOV DX,M[SI]
   MOV B,DX

END_M_MOV_B_REGI_IMME_P:
   RET
MOV_B_REGI_IMME_P ENDP

;------------------------------------------------
;Procedure Name : MOV_B_DI_P
;Function : MOV 명령어의 DIRECT 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 26,2016
;   Last Modified On Nov 26,2016
;------------------------------------------------
MOV_B_DI_P PROC                     ; MOV B,DIRECT
   MOV SI,VDECODE[10]  				; VDECODE값에 들어있는 DIRCET주소값을 저장 
   MOV DX,M[SI]
   MOV B,DX
   RET
MOV_B_DI_P ENDP

;------------------------------------------------
;Procedure Name : MOV_C_P
;Function : MOV C, 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 26,2016
;   Last Modified On Nov 26,2016
;------------------------------------------------
MOV_C_P PROC
   MOV AX, VDECODE[2]
   AND AX,11b
   MOV VDECODE[2],AX
                              ; MOV C,
   CMP VDECODE[2],00b			; VDECODE[2]값을 확인하여 00이면 Register 모드
   JE MOV_C_REGI
   CMP VDECODE[2],01b			; VDECODE[2]값을 확인하여 01이면 Immediate 모드
   JE MOV_C_IMME
   CMP VDECODE[2],10b			; VDECODE[2]값을 확인하여 10이면 Register-Indirect 모드
   JE MOV_C_REGI_IMME
   CMP VDECODE[2],11b			; VDECODE[2]값을 확인하여 11이면 Direct 모드
   JE MOV_C_DI

   PRINT ERR
   JMP END_M_MOV_C_P

MOV_C_REGI:
   CALL MOV_C_REGI_P
   JMP END_M_MOV_C_P
MOV_C_IMME:
   CALL MOV_C_IMME_P
   JMP END_M_MOV_C_P
MOV_C_REGI_IMME:
   CALL MOV_C_REGI_IMME_P
   JMP END_M_MOV_C_P
MOV_C_DI:
   CALL MOV_C_DI_P
   JMP END_M_MOV_C_P

END_M_MOV_C_P:
   RET
MOV_C_P ENDP

;------------------------------------------------
;Procedure Name : MOV_C_REGI_P
;Function : MOV C,REGISTER 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 26,2016
;   Last Modified On Nov 26,2016
;------------------------------------------------
MOV_C_REGI_P PROC
   MOV AX,VDECODE[8]                         ; MOV C,REGISTER
   AND AX,1111b
   MOV VDECODE[8],AX

   CMP VDECODE[8],1000b						; 피연산자2의 값이 저장되어있는 VDECODE[8]이 1000b이면 MOV C,A
   JE MOV_C_A
   CMP VDECODE[8],1001b						; 피연산자2의 값이 저장되어있는 VDECODE[8]이 1000b이면 MOV C,B
   JE MOV_C_B
   CMP VDECODE[8],1010b						; 피연산자2의 값이 저장되어있는 VDECODE[8]이 1000b이면 MOV C,C
   JE MOV_C_C
   CMP VDECODE[8],1011b						; 피연산자2의 값이 저장되어있는 VDECODE[8]이 1000b이면 MOV C,D
   JE MOV_C_D
   CMP VDECODE[8],1100b						; 피연산자2의 값이 저장되어있는 VDECODE[8]이 1000b이면 MOV C,E
   JE MOV_C_E
   CMP VDECODE[8],1101b						; 피연산자2의 값이 저장되어있는 VDECODE[8]이 1000b이면 MOV C,F
   JE MOV_C_F
   CMP VDECODE[8],1110b						; 피연산자2의 값이 저장되어있는 VDECODE[8]이 1000b이면 MOV C,X
   JE MOV_C_X
   CMP VDECODE[8],1111b						; 피연산자2의 값이 저장되어있는 VDECODE[8]이 1000b이면 MOV C,Y
   JE MOV_C_Y

   PRINT ERR
   JMP END_M_MOV_C_REGI_P

MOV_C_A:									; MOV C,A를 진행
   MOV AX,A
   MOV C,AX
   JMP END_M_MOV_C_REGI_P
MOV_C_B:									; MOV C,B를 진행
   MOV AX,B
   MOV C,AX
   JMP END_M_MOV_C_REGI_P
MOV_C_C:									; MOV C,C를 진행
   MOV AX,C
   MOV C,AX
   JMP END_M_MOV_C_REGI_P
MOV_C_D:									; MOV C,D를 진행
   MOV AX,D
   MOV C,AX
   JMP END_M_MOV_C_REGI_P
MOV_C_E:									; MOV C,E를 진행
   MOV AX,E
   MOV C,AX
   JMP END_M_MOV_C_REGI_P
MOV_C_F:									; MOV C,F를 진행
   MOV AX,F
   MOV C,AX
   JMP END_M_MOV_C_REGI_P
MOV_C_X:									; MOV C,X를 진행
   MOV AX,X
   MOV C,AX
   JMP END_M_MOV_C_REGI_P
MOV_C_Y:									; MOV C,Y를 진행
   MOV AX,Y
   MOV C,AX
   JMP END_M_MOV_C_REGI_P
   
   PRINT ERR
   JMP END_M_MOV_C_REGI_P

END_M_MOV_C_REGI_P:
   RET
MOV_C_REGI_P ENDP

;------------------------------------------------
;Procedure Name : MOV_C_IMME_P
;Function : MOV C,IMMEDIATE 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 26,2016
;   Last Modified On Nov 26,2016
;------------------------------------------------
MOV_C_IMME_P PROC                   ; MOV C,IMMEDIATE
   MOV DX,VDECODE[10]					; VDECODE[10]에 저장되어있는 IMMEDIATE값을 레지스터 C에 저장
   MOV C,DX
   RET
MOV_C_IMME_P ENDP

;------------------------------------------------
;Procedure Name : MOV_A_REGI_IMME_P
;Function : MOV 명령어의 REGISTER-INDIRECT 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 26,2016
;   Last Modified On Nov 26,2016
;------------------------------------------------
MOV_C_REGI_IMME_P PROC                 ; MOV C,REGISTER_IMMEDIATE
   CMP VDECODE[8],1110				   ; 피연산자2의 값이 X
   JE MOV_C_R_I_X
   CMP VDECODE[8],1111				   ; 피연산자2의 값이 Y
   JE MOV_C_R_I_Y
   
MOV_C_R_I_X:							; MOV C,[X]
   MOV SI,X
   MOV DX,M[SI]
   MOV C,DX
   JMP END_M_MOV_C_REGI_IMME_P
MOV_C_R_I_Y:							; MOV C,[Y]
   MOV SI,Y
   MOV DX,M[SI]
   MOV C,DX

END_M_MOV_C_REGI_IMME_P:
   RET
MOV_C_REGI_IMME_P ENDP

;------------------------------------------------
;Procedure Name : MOV_C_DI_P
;Function : MOV 명령어의 DIRECT 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 26,2016
;   Last Modified On Nov 26,2016
;------------------------------------------------
MOV_C_DI_P PROC                     ; MOV C,DIRECT
   MOV SI,VDECODE[10]   			; VDECODE[10]값에 들어있는 DIRCET주소값을 저장
   MOV DX,M[SI]
   MOV C,DX
   RET
MOV_C_DI_P ENDP

;------------------------------------------------
;Procedure Name : MOV_D_P
;Function : MOV D, 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 26,2016
;   Last Modified On Nov 26,2016
;------------------------------------------------
MOV_D_P PROC
   MOV AX, VDECODE[2]
   AND AX,11b
   MOV VDECODE[2],AX
                              ; MOV D,
   CMP VDECODE[2],00b			; VDECODE[2]값을 확인하여 00이면 Register 모드
   JE MOV_D_REGI
   CMP VDECODE[2],01b			; VDECODE[2]값을 확인하여 01이면 Immediate 모드
   JE MOV_D_IMME
   CMP VDECODE[2],10b			; VDECODE[2]값을 확인하여 10이면 Register-Indirect 모드
   JE MOV_D_REGI_IMME
   CMP VDECODE[2],11b			; VDECODE[2]값을 확인하여 11이면 Direct 모드
   JE MOV_D_DI

   PRINT ERR
   JMP END_M_MOV_D_P

MOV_D_REGI:
   CALL MOV_D_REGI_P
   JMP END_M_MOV_D_P
MOV_D_IMME:
   CALL MOV_D_IMME_P
   JMP END_M_MOV_D_P
MOV_D_REGI_IMME:
   CALL MOV_D_REGI_IMME_P
   JMP END_M_MOV_D_P
MOV_D_DI:
   CALL MOV_D_DI_P
   JMP END_M_MOV_D_P

END_M_MOV_D_P:
   RET
MOV_D_P ENDP

;------------------------------------------------
;Procedure Name : MOV_D_REGI_P
;Function : MOV A,REGISTER 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 26,2016
;   Last Modified On Nov 26,2016
;------------------------------------------------
MOV_D_REGI_P PROC
   MOV AX,VDECODE[8]                         ; MOV D,REGISTER
   AND AX,1111b
   MOV VDECODE[8],AX

   CMP VDECODE[8],1000b						; 피연산자2의 값이 저장되어있는 VDECODE[8]이 1000b이면 MOV D,A
   JE MOV_D_A
   CMP VDECODE[8],1001b						; 피연산자2의 값이 저장되어있는 VDECODE[8]이 1000b이면 MOV D,B
   JE MOV_D_B
   CMP VDECODE[8],1010b						; 피연산자2의 값이 저장되어있는 VDECODE[8]이 1000b이면 MOV D,C
   JE MOV_D_C
   CMP VDECODE[8],1011b						; 피연산자2의 값이 저장되어있는 VDECODE[8]이 1000b이면 MOV D,D
   JE MOV_D_D
   CMP VDECODE[8],1100b						; 피연산자2의 값이 저장되어있는 VDECODE[8]이 1000b이면 MOV D,E
   JE MOV_D_E
   CMP VDECODE[8],1101b						; 피연산자2의 값이 저장되어있는 VDECODE[8]이 1000b이면 MOV D,F
   JE MOV_D_F
   CMP VDECODE[8],1110b						; 피연산자2의 값이 저장되어있는 VDECODE[8]이 1000b이면 MOV D,X
   JE MOV_D_X
   CMP VDECODE[8],1111b						; 피연산자2의 값이 저장되어있는 VDECODE[8]이 1000b이면 MOV D,Y
   JE MOV_D_Y

   PRINT ERR
   JMP END_M_MOV_D_REGI_P

MOV_D_A:									; MOV D,A를 진행
   MOV AX,A
   MOV D,AX
   JMP END_M_MOV_D_REGI_P
MOV_D_B:									; MOV D,B를 진행
   MOV AX,B
   MOV D,AX
   JMP END_M_MOV_D_REGI_P
MOV_D_C:									; MOV D,C를 진행
   MOV AX,C
   MOV D,AX
   JMP END_M_MOV_D_REGI_P
MOV_D_D:									; MOV D,D를 진행
   MOV AX,D
   MOV D,AX
   JMP END_M_MOV_D_REGI_P
MOV_D_E:									; MOV D,E를 진행
   MOV AX,E
   MOV D,AX
   JMP END_M_MOV_D_REGI_P
MOV_D_F:									; MOV D,F를 진행
   MOV AX,F
   MOV D,AX
   JMP END_M_MOV_D_REGI_P
MOV_D_X:									; MOV D,X를 진행
   MOV AX,X
   MOV D,AX
   JMP END_M_MOV_D_REGI_P
MOV_D_Y:									; MOV D,Y를 진행
   MOV AX,Y
   MOV D,AX
   JMP END_M_MOV_D_REGI_P
   
   PRINT ERR
   JMP END_M_MOV_D_REGI_P

END_M_MOV_D_REGI_P:
   RET
MOV_D_REGI_P ENDP

;------------------------------------------------
;Procedure Name : MOV_D_IMME_P
;Function : MOV D,IMMEDIATE 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 26,2016
;   Last Modified On Nov 26,2016
;------------------------------------------------
MOV_D_IMME_P PROC                   ; MOV D,IMMEDIATE
   MOV DX,VDECODE[10]					; VDECODE[10]에 저장되어있는 IMMEDIATE값을 레지스터 D에 저장
   MOV D,DX
   RET
MOV_D_IMME_P ENDP

;------------------------------------------------
;Procedure Name : MOV_D_REGI_IMME_P
;Function : MOV 명령어의 REGISTER-INDIRECT 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 26,2016
;   Last Modified On Nov 26,2016
;------------------------------------------------
MOV_D_REGI_IMME_P PROC                 ; MOV D,REGISTER_IMMEDIATE
   CMP VDECODE[8],1110				   ; 피연산자2의 값이 X
   JE MOV_D_R_I_X
   CMP VDECODE[8],1111				   ; 피연산자2의 값이 Y
   JE MOV_D_R_I_Y
   
MOV_D_R_I_X:							; MOV D,[X]
   MOV SI,X
   MOV DX,M[SI]
   MOV D,DX
   JMP END_M_MOV_D_REGI_IMME_P
MOV_D_R_I_Y:							; MOV D,[Y]
   MOV SI,Y
   MOV DX,M[SI]
   MOV D,DX

END_M_MOV_D_REGI_IMME_P:
   RET
MOV_D_REGI_IMME_P ENDP

;------------------------------------------------
;Procedure Name : MOV_D_DI_P
;Function : MOV 명령어의 DIRECT 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 26,2016
;   Last Modified On Nov 26,2016
;------------------------------------------------
MOV_D_DI_P PROC                     ; MOV D,DIRECT
   MOV SI,VDECODE[10]				; VDECODE[10]값에 들어있는 DIRCET주소값을 저장   
   MOV DX,M[SI]
   MOV D,DX
   RET
MOV_D_DI_P ENDP

;------------------------------------------------
;Procedure Name : MOV_E_P
;Function : MOV E, 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 26,2016
;   Last Modified On Nov 26,2016
;------------------------------------------------
MOV_E_P PROC
   MOV AX, VDECODE[2]
   AND AX,11b
   MOV VDECODE[2],AX
                              ; MOV E,
   CMP VDECODE[2],00b			; VDECODE[2]값을 확인하여 00이면 Register 모드
   JE MOV_E_REGI
   CMP VDECODE[2],01b			; VDECODE[2]값을 확인하여 01이면 Immediate 모드
   JE MOV_E_IMME
   CMP VDECODE[2],10b			; VDECODE[2]값을 확인하여 10이면 Register-Indirect 모드
   JE MOV_E_REGI_IMME
   CMP VDECODE[2],11b			; VDECODE[2]값을 확인하여 11이면 Direct 모드
   JE MOV_E_DI

   PRINT ERR
   JMP END_M_MOV_E_P

MOV_E_REGI:
   CALL MOV_E_REGI_P
   JMP END_M_MOV_E_P
MOV_E_IMME:
   CALL MOV_E_IMME_P
   JMP END_M_MOV_E_P
MOV_E_REGI_IMME:
   CALL MOV_E_REGI_IMME_P
   JMP END_M_MOV_E_P
MOV_E_DI:
   CALL MOV_E_DI_P
   JMP END_M_MOV_E_P

END_M_MOV_E_P:
   RET
MOV_E_P ENDP

;------------------------------------------------
;Procedure Name : MOV_E_REGI_P
;Function : MOV E,REGISTER 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 26,2016
;   Last Modified On Nov 26,2016
;------------------------------------------------
MOV_E_REGI_P PROC
   MOV AX,VDECODE[8]                         ; MOV E,REGISTER
   AND AX,1111b
   MOV VDECODE[8],AX

   CMP VDECODE[8],1000b					; 피연산자2의 값이 저장되어있는 VDECODE[8]이 1000b이면 MOV E,A
   JE MOV_E_A
   CMP VDECODE[8],1001b					; 피연산자2의 값이 저장되어있는 VDECODE[8]이 1000b이면 MOV E,B
   JE MOV_E_B
   CMP VDECODE[8],1010b					; 피연산자2의 값이 저장되어있는 VDECODE[8]이 1000b이면 MOV E,C
   JE MOV_E_C
   CMP VDECODE[8],1011b					; 피연산자2의 값이 저장되어있는 VDECODE[8]이 1000b이면 MOV E,D
   JE MOV_E_D
   CMP VDECODE[8],1100b					; 피연산자2의 값이 저장되어있는 VDECODE[8]이 1000b이면 MOV E,E
   JE MOV_E_E
   CMP VDECODE[8],1101b					; 피연산자2의 값이 저장되어있는 VDECODE[8]이 1000b이면 MOV E,F
   JE MOV_E_F
   CMP VDECODE[8],1110b					; 피연산자2의 값이 저장되어있는 VDECODE[8]이 1000b이면 MOV E,X
   JE MOV_E_X
   CMP VDECODE[8],1111b					; 피연산자2의 값이 저장되어있는 VDECODE[8]이 1000b이면 MOV E,Y
   JE MOV_E_Y

   PRINT ERR
   JMP END_M_MOV_E_REGI_P

MOV_E_A:									; MOV E,A를 진행
   MOV AX,A
   MOV E,AX
   JMP END_M_MOV_E_REGI_P
MOV_E_B:									; MOV E,B를 진행
   MOV AX,B
   MOV E,AX
   JMP END_M_MOV_E_REGI_P
MOV_E_C:									; MOV E,C를 진행
   MOV AX,C
   MOV E,AX
   JMP END_M_MOV_E_REGI_P
MOV_E_D:									; MOV E,D를 진행
   MOV AX,D
   MOV E,AX
   JMP END_M_MOV_E_REGI_P
MOV_E_E:									; MOV E,E를 진행
   MOV AX,E
   MOV E,AX
   JMP END_M_MOV_E_REGI_P
MOV_E_F:									; MOV E,F를 진행
   MOV AX,F
   MOV E,AX
   JMP END_M_MOV_E_REGI_P
MOV_E_X:									; MOV E,X를 진행
   MOV AX,X
   MOV E,AX
   JMP END_M_MOV_E_REGI_P
MOV_E_Y:									; MOV E,Y를 진행
   MOV AX,Y
   MOV E,AX
   JMP END_M_MOV_E_REGI_P
   
   PRINT ERR
   JMP END_M_MOV_E_REGI_P

END_M_MOV_E_REGI_P:
   RET
MOV_E_REGI_P ENDP

;------------------------------------------------
;Procedure Name : MOV_E_IMME_P
;Function : MOV E,IMMEDIATE 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 26,2016
;   Last Modified On Nov 26,2016
;------------------------------------------------
MOV_E_IMME_P PROC                   ; MOV E,IMMEDIATE
   MOV DX,VDECODE[10]					; VDECODE[10]에 저장되어있는 IMMEDIATE값을 레지스터 E에 저장
   MOV E,DX
   RET
MOV_E_IMME_P ENDP

;------------------------------------------------
;Procedure Name : MOV_E_REGI_IMME_P
;Function : MOV 명령어의 REGISTER-INDIRECT 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 26,2016
;   Last Modified On Nov 26,2016
;------------------------------------------------
MOV_E_REGI_IMME_P PROC                 ; MOV E,REGISTER_IMMEDIATE
   CMP VDECODE[8],1110				   ; 피연산자2의 값이 X
   JE MOV_E_R_I_X
   CMP VDECODE[8],1111				   ; 피연산자2의 값이 Y
   JE MOV_E_R_I_Y
   
MOV_E_R_I_X:							; MOV E,[X]
   MOV SI,X
   MOV DX,M[SI]
   MOV E,DX
   JMP END_M_MOV_E_REGI_IMME_P
MOV_E_R_I_Y:							; MOV E,[Y]
   MOV SI,Y
   MOV DX,M[SI]
   MOV E,DX

END_M_MOV_E_REGI_IMME_P:
   RET
MOV_E_REGI_IMME_P ENDP

;------------------------------------------------
;Procedure Name : MOV_E_DI_P
;Function : MOV 명령어의 DIRECT 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 26,2016
;   Last Modified On Nov 26,2016
;------------------------------------------------
MOV_E_DI_P PROC                     ; MOV E,DIRECT
   MOV SI,VDECODE[10]  				; VDECODE[10]값에 들어있는 DIRCET주소값을 저장 
   MOV DX,M[SI]
   MOV E,DX
   RET
MOV_E_DI_P ENDP

;------------------------------------------------
;Procedure Name : MOV_F_P
;Function : MOV F, 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 26,2016
;   Last Modified On Nov 26,2016
;------------------------------------------------
MOV_F_P PROC
   MOV AX, VDECODE[2]
   AND AX,11b
   MOV VDECODE[2],AX
                              ; MOV F,
   CMP VDECODE[2],00b			; VDECODE[2]값을 확인하여 00이면 Register 모드
   JE MOV_F_REGI
   CMP VDECODE[2],01b			; VDECODE[2]값을 확인하여 01이면 Immediate 모드
   JE MOV_F_IMME
   CMP VDECODE[2],10b			; VDECODE[2]값을 확인하여 10이면 Register-Indirect 모드
   JE MOV_F_REGI_IMME
   CMP VDECODE[2],11b			; VDECODE[2]값을 확인하여 11이면 Direct 모드
   JE MOV_F_DI

   PRINT ERR
   JMP END_M_MOV_F_P

MOV_F_REGI:
   CALL MOV_F_REGI_P
   JMP END_M_MOV_F_P
MOV_F_IMME:
   CALL MOV_F_IMME_P
   JMP END_M_MOV_F_P
MOV_F_REGI_IMME:
   CALL MOV_F_REGI_IMME_P
   JMP END_M_MOV_F_P
MOV_F_DI:
   CALL MOV_F_DI_P
   JMP END_M_MOV_F_P

END_M_MOV_F_P:
   RET
MOV_F_P ENDP

;------------------------------------------------
;Procedure Name : MOV_F_REGI_P
;Function : MOV F,REGISTER 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 26,2016
;   Last Modified On Nov 26,2016
;------------------------------------------------
MOV_F_REGI_P PROC
   MOV AX,VDECODE[8]                         ; MOV F,REGISTER
   AND AX,1111b
   MOV VDECODE[8],AX

   CMP VDECODE[8],1000b						; 피연산자2의 값이 저장되어있는 VDECODE[8]이 1000b이면 MOV F,A
   JE MOV_F_A
   CMP VDECODE[8],1001b						; 피연산자2의 값이 저장되어있는 VDECODE[8]이 1000b이면 MOV F,B
   JE MOV_F_B
   CMP VDECODE[8],1010b						; 피연산자2의 값이 저장되어있는 VDECODE[8]이 1000b이면 MOV F,C
   JE MOV_F_C
   CMP VDECODE[8],1011b						; 피연산자2의 값이 저장되어있는 VDECODE[8]이 1000b이면 MOV F,D
   JE MOV_F_D
   CMP VDECODE[8],1100b						; 피연산자2의 값이 저장되어있는 VDECODE[8]이 1000b이면 MOV F,E
   JE MOV_F_E
   CMP VDECODE[8],1101b						; 피연산자2의 값이 저장되어있는 VDECODE[8]이 1000b이면 MOV F,F
   JE MOV_F_F
   CMP VDECODE[8],1110b						; 피연산자2의 값이 저장되어있는 VDECODE[8]이 1000b이면 MOV F,X
   JE MOV_F_X
   CMP VDECODE[8],1111b						; 피연산자2의 값이 저장되어있는 VDECODE[8]이 1000b이면 MOV F,Y
   JE MOV_F_Y

   PRINT ERR
   JMP END_M_MOV_F_REGI_P

MOV_F_A:									; MOV F,A를 진행
   MOV AX,A
   MOV F,AX
   JMP END_M_MOV_F_REGI_P
MOV_F_B:									; MOV F,B를 진행
   MOV AX,B
   MOV F,AX
   JMP END_M_MOV_F_REGI_P
MOV_F_C:									; MOV F,C를 진행
   MOV AX,C
   MOV F,AX
   JMP END_M_MOV_F_REGI_P
MOV_F_D:									; MOV F,D를 진행
   MOV AX,D
   MOV F,AX
   JMP END_M_MOV_F_REGI_P
MOV_F_E:									; MOV F,E를 진행
   MOV AX,E
   MOV F,AX
   JMP END_M_MOV_F_REGI_P
MOV_F_F:									; MOV F,F를 진행
   MOV AX,F
   MOV F,AX
   JMP END_M_MOV_F_REGI_P
MOV_F_X:									; MOV F,X를 진행
   MOV AX,X
   MOV F,AX
   JMP END_M_MOV_F_REGI_P
MOV_F_Y:									; MOV F,Y를 진행
   MOV AX,Y
   MOV F,AX
   JMP END_M_MOV_F_REGI_P
   
   PRINT ERR
   JMP END_M_MOV_F_REGI_P

END_M_MOV_F_REGI_P:
   RET
MOV_F_REGI_P ENDP

;------------------------------------------------
;Procedure Name : MOV_F_IMME_P
;Function : MOV F,IMMEDIATE 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 26,2016
;   Last Modified On Nov 26,2016
;------------------------------------------------
MOV_F_IMME_P PROC                   ; MOV F,IMMEDIATE
   MOV DX,VDECODE[10]					; VDECODE[10]에 저장되어있는 IMMEDIATE값을 레지스터 F에 저장
   MOV F,DX
   RET
MOV_F_IMME_P ENDP

;------------------------------------------------
;Procedure Name : MOV_F_REGI_IMME_P
;Function : MOV 명령어의 REGISTER-INDIRECT 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 26,2016
;   Last Modified On Nov 26,2016
;------------------------------------------------
MOV_F_REGI_IMME_P PROC                 ; MOV F,REGISTER_IMMEDIATE
   CMP VDECODE[8],1110				   ; 피연산자2의 값이 X
   JE MOV_F_R_I_X
   CMP VDECODE[8],1111				   ; 피연산자2의 값이 Y
   JE MOV_F_R_I_Y
   
MOV_F_R_I_X:							; MOV F,[X]
   MOV SI,X
   MOV DX,M[SI]
   MOV F,DX
   JMP END_M_MOV_F_REGI_IMME_P
MOV_F_R_I_Y:							; MOV F,[Y]
   MOV SI,Y
   MOV DX,M[SI]
   MOV F,DX

END_M_MOV_F_REGI_IMME_P:
   RET
MOV_F_REGI_IMME_P ENDP

;------------------------------------------------
;Procedure Name : MOV_F_DI_P
;Function : MOV 명령어의 DIRECT 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 26,2016
;   Last Modified On Nov 26,2016
;------------------------------------------------
MOV_F_DI_P PROC                     ; MOV F,DIRECT
   MOV SI,VDECODE[10]   
   MOV DX,M[SI]
   MOV F,DX
   RET
MOV_F_DI_P ENDP

;------------------------------------------------
;Procedure Name : MOV_X_P
;Function : MOV X, 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 26,2016
;   Last Modified On Nov 26,2016
;------------------------------------------------
MOV_X_P PROC
   MOV AX, VDECODE[2]
   AND AX,11b
   MOV VDECODE[2],AX
                              ; MOV X,
   CMP VDECODE[2],00b			; VDECODE[2]값을 확인하여 00이면 Register 모드
   JE MOV_X_REGI
   CMP VDECODE[2],01b			; VDECODE[2]값을 확인하여 01이면 Immediate 모드
   JE MOV_X_IMME
   CMP VDECODE[2],10b			; VDECODE[2]값을 확인하여 10이면 Register-Indirect 모드
   JE MOV_X_REGI_IMME
   CMP VDECODE[2],11b			; VDECODE[2]값을 확인하여 11이면 Direct 모드
   JE MOV_X_DI

   PRINT ERR
   JMP END_M_MOV_X_P

MOV_X_REGI:
   CALL MOV_X_REGI_P
   JMP END_M_MOV_X_P
MOV_X_IMME:
   CALL MOV_X_IMME_P
   JMP END_M_MOV_X_P
MOV_X_REGI_IMME:
   CALL MOV_X_REGI_IMME_P
   JMP END_M_MOV_X_P
MOV_X_DI:
   CALL MOV_X_DI_P
   JMP END_M_MOV_X_P

END_M_MOV_X_P:
   RET
MOV_X_P ENDP

;------------------------------------------------
;Procedure Name : MOV_X_REGI_P
;Function : MOV X,REGISTER 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 26,2016
;   Last Modified On Nov 26,2016
;------------------------------------------------
MOV_X_REGI_P PROC
   MOV AX,VDECODE[8]                         ; MOV X,REGISTER
   AND AX,1111b
   MOV VDECODE[8],AX

   CMP VDECODE[8],1000b						; 피연산자2의 값이 저장되어있는 VDECODE[8]이 1000b이면 MOV X,A
   JE MOV_X_A
   CMP VDECODE[8],1001b						; 피연산자2의 값이 저장되어있는 VDECODE[8]이 1000b이면 MOV X,B
   JE MOV_X_B
   CMP VDECODE[8],1010b						; 피연산자2의 값이 저장되어있는 VDECODE[8]이 1000b이면 MOV X,C
   JE MOV_X_C
   CMP VDECODE[8],1011b						; 피연산자2의 값이 저장되어있는 VDECODE[8]이 1000b이면 MOV X,D
   JE MOV_X_D
   CMP VDECODE[8],1100b						; 피연산자2의 값이 저장되어있는 VDECODE[8]이 1000b이면 MOV X,E
   JE MOV_X_E
   CMP VDECODE[8],1101b						; 피연산자2의 값이 저장되어있는 VDECODE[8]이 1000b이면 MOV X,F
   JE MOV_X_F
   CMP VDECODE[8],1110b						; 피연산자2의 값이 저장되어있는 VDECODE[8]이 1000b이면 MOV X,X
   JE MOV_X_X
   CMP VDECODE[8],1111b						; 피연산자2의 값이 저장되어있는 VDECODE[8]이 1000b이면 MOV X,Y
   JE MOV_X_Y

   PRINT ERR
   JMP END_M_MOV_X_REGI_P

MOV_X_A:									; MOV X,A를 진행
   MOV AX,A
   MOV X,AX
   JMP END_M_MOV_X_REGI_P
MOV_X_B:									; MOV X,B를 진행
   MOV AX,B
   MOV X,AX
   JMP END_M_MOV_X_REGI_P
MOV_X_C:									; MOV X,C를 진행
   MOV AX,C
   MOV X,AX
   JMP END_M_MOV_X_REGI_P
MOV_X_D:									; MOV X,D를 진행
   MOV AX,D
   MOV X,AX
   JMP END_M_MOV_X_REGI_P
MOV_X_E:									; MOV X,E를 진행
   MOV AX,E
   MOV X,AX
   JMP END_M_MOV_X_REGI_P
MOV_X_F:									; MOV X,F를 진행
   MOV AX,F
   MOV X,AX
   JMP END_M_MOV_X_REGI_P
MOV_X_X:									; MOV X,X를 진행
   MOV AX,X
   MOV X,AX
   JMP END_M_MOV_X_REGI_P
MOV_X_Y:									; MOV X,Y를 진행
   MOV AX,Y
   MOV X,AX
   JMP END_M_MOV_X_REGI_P
   
   PRINT ERR
   JMP END_M_MOV_X_REGI_P

END_M_MOV_X_REGI_P:
   RET
MOV_X_REGI_P ENDP

;------------------------------------------------
;Procedure Name : MOV_X_IMME_P
;Function : MOV X,IMMEDIATE 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 26,2016
;   Last Modified On Nov 26,2016
;------------------------------------------------
MOV_X_IMME_P PROC                   ; MOV X,IMMEDIATE
   MOV DX,VDECODE[10]					; VDECODE[10]에 저장되어있는 IMMEDIATE값을 레지스터 X에 저장
   MOV X,DX
   RET
MOV_X_IMME_P ENDP

;------------------------------------------------
;Procedure Name : MOV_X_REGI_IMME_P
;Function : MOV 명령어의 REGISTER-INDIRECT 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 26,2016
;   Last Modified On Nov 26,2016
;------------------------------------------------
MOV_X_REGI_IMME_P PROC                 ; MOV X,REGISTER_IMMEDIATE
   CMP VDECODE[8],1110				   ; 피연산자2의 값이 X
   JE MOV_X_R_I_X
   CMP VDECODE[8],1111				   ; 피연산자2의 값이 Y
   JE MOV_X_R_I_Y
   
MOV_X_R_I_X:							; MOV X,[X]
   MOV SI,X
   MOV DX,M[SI]
   MOV X,DX
   JMP END_M_MOV_X_REGI_IMME_P
MOV_X_R_I_Y:							; MOV X,[Y]
   MOV SI,Y
   MOV DX,M[SI]
   MOV X,DX

END_M_MOV_X_REGI_IMME_P:
   RET
MOV_X_REGI_IMME_P ENDP

;------------------------------------------------
;Procedure Name : MOV_X_DI_P
;Function : MOV 명령어의 DIRECT 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 26,2016
;   Last Modified On Nov 26,2016
;------------------------------------------------
MOV_X_DI_P PROC                     ; MOV X,DIRECT
   MOV SI,VDECODE[10]   			; VDECODE[10]값에 들어있는 DIRCET주소값을 저장
   MOV DX,M[SI]
   MOV X,DX
   RET
MOV_X_DI_P ENDP


;------------------------------------------------
;Procedure Name : MOV_Y_P
;Function : MOV Y, 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 26,2016
;   Last Modified On Nov 26,2016
;------------------------------------------------
MOV_Y_P PROC
   MOV AX, VDECODE[2]
   AND AX,11b
   MOV VDECODE[2],AX
                              ; MOV Y,
   CMP VDECODE[2],00b			; VDECODE[2]값을 확인하여 00이면 Register 모드
   JE MOV_Y_REGI
   CMP VDECODE[2],01b			; VDECODE[2]값을 확인하여 01이면 Immediate 모드
   JE MOV_Y_IMME
   CMP VDECODE[2],10b			; VDECODE[2]값을 확인하여 10이면 Register-Indirect 모드
   JE MOV_Y_REGI_IMME
   CMP VDECODE[2],11b			; VDECODE[2]값을 확인하여 11이면 Direct 모드
   JE MOV_Y_DI

   PRINT ERR
   JMP END_M_MOV_Y_P

MOV_Y_REGI:
   CALL MOV_Y_REGI_P
   JMP END_M_MOV_Y_P
MOV_Y_IMME:
   CALL MOV_Y_IMME_P
   JMP END_M_MOV_Y_P
MOV_Y_REGI_IMME:
   CALL MOV_Y_REGI_IMME_P
   JMP END_M_MOV_Y_P
MOV_Y_DI:
   CALL MOV_Y_DI_P
   JMP END_M_MOV_Y_P

END_M_MOV_Y_P:
   RET
MOV_Y_P ENDP

;------------------------------------------------
;Procedure Name : MOV_Y_REGI_P
;Function : MOV Y,REGISTER 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 26,2016
;   Last Modified On Nov 26,2016
;------------------------------------------------
MOV_Y_REGI_P PROC
   MOV AX,VDECODE[8]                         ; MOV Y,REGISTER
   AND AX,1111b
   MOV VDECODE[8],AX

   CMP VDECODE[8],1000b					; 피연산자2의 값이 저장되어있는 VDECODE[8]이 1000b이면 MOV Y,A
   JE MOV_Y_A
   CMP VDECODE[8],1001b					; 피연산자2의 값이 저장되어있는 VDECODE[8]이 1000b이면 MOV Y,B
   JE MOV_Y_B
   CMP VDECODE[8],1010b					; 피연산자2의 값이 저장되어있는 VDECODE[8]이 1000b이면 MOV Y,C
   JE MOV_Y_C
   CMP VDECODE[8],1011b					; 피연산자2의 값이 저장되어있는 VDECODE[8]이 1000b이면 MOV Y,D
   JE MOV_Y_D
   CMP VDECODE[8],1100b					; 피연산자2의 값이 저장되어있는 VDECODE[8]이 1000b이면 MOV Y,E
   JE MOV_Y_E
   CMP VDECODE[8],1101b					; 피연산자2의 값이 저장되어있는 VDECODE[8]이 1000b이면 MOV Y,F
   JE MOV_Y_F
   CMP VDECODE[8],1110b					; 피연산자2의 값이 저장되어있는 VDECODE[8]이 1000b이면 MOV Y,X
   JE MOV_Y_X
   CMP VDECODE[8],1111b					; 피연산자2의 값이 저장되어있는 VDECODE[8]이 1000b이면 MOV Y,Y
   JE MOV_Y_Y

   PRINT ERR
   JMP END_M_MOV_Y_REGI_P

MOV_Y_A:									; MOV Y,A를 진행
   MOV AX,A
   MOV Y,AX
   JMP END_M_MOV_Y_REGI_P
MOV_Y_B:									; MOV Y,A를 진행
   MOV AX,B
   MOV Y,AX
   JMP END_M_MOV_Y_REGI_P
MOV_Y_C:									; MOV Y,A를 진행
   MOV AX,C
   MOV Y,AX
   JMP END_M_MOV_Y_REGI_P
MOV_Y_D:									; MOV Y,A를 진행
   MOV AX,D
   MOV Y,AX
   JMP END_M_MOV_Y_REGI_P
MOV_Y_E:									; MOV Y,A를 진행
   MOV AX,E
   MOV Y,AX
   JMP END_M_MOV_Y_REGI_P
MOV_Y_F:									; MOV Y,A를 진행
   MOV AX,F
   MOV Y,AX
   JMP END_M_MOV_Y_REGI_P
MOV_Y_X:									; MOV Y,A를 진행
   MOV AX,X
   MOV Y,AX
   JMP END_M_MOV_Y_REGI_P
MOV_Y_Y:									; MOV Y,A를 진행
   MOV AX,Y
   MOV Y,AX
   JMP END_M_MOV_Y_REGI_P
   
   PRINT ERR
   JMP END_M_MOV_Y_REGI_P

END_M_MOV_Y_REGI_P:
   RET
MOV_Y_REGI_P ENDP

;------------------------------------------------
;Procedure Name : MOV_Y_IMME_P
;Function : MOV Y,IMMEDIATE 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 26,2016
;   Last Modified On Nov 26,2016
;------------------------------------------------
MOV_Y_IMME_P PROC                   ; MOV Y,IMMEDIATE
   MOV DX,VDECODE[10]					; VDECODE[10]에 저장되어있는 IMMEDIATE값을 레지스터 A에 저장
   MOV Y,DX
   RET
MOV_Y_IMME_P ENDP

;------------------------------------------------
;Procedure Name : MOV_Y_REGI_IMME_P
;Function : MOV 명령어의 REGISTER-INDIRECT 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 26,2016
;   Last Modified On Nov 26,2016
;------------------------------------------------
MOV_Y_REGI_IMME_P PROC                 ; MOV Y,REGISTER_IMMEDIATE
   CMP VDECODE[8],1110				   ; 피연산자2의 값이 X
   JE MOV_Y_R_I_X
   CMP VDECODE[8],1111				   ; 피연산자2의 값이 Y
   JE MOV_Y_R_I_Y
   
MOV_Y_R_I_X:							; MOV Y,[X]
   MOV SI,X
   MOV DX,M[SI]
   MOV Y,DX
   JMP END_M_MOV_Y_REGI_IMME_P
MOV_Y_R_I_Y:							; MOV Y,[Y]
   MOV SI,Y
   MOV DX,M[SI]
   MOV Y,DX

END_M_MOV_Y_REGI_IMME_P:
   RET
MOV_Y_REGI_IMME_P ENDP

;------------------------------------------------
;Procedure Name : MOV_Y_DI_P
;Function : MOV 명령어의 DIRECT 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 26,2016
;   Last Modified On Nov 26,2016
;------------------------------------------------
MOV_Y_DI_P PROC                     ; MOV Y,DIRECT
   MOV SI,VDECODE[10]   			; VDECODE[10]값에 들어있는 DIRCET주소값을 저장
   MOV DX,M[SI]
   MOV Y,DX
   RET
MOV_Y_DI_P ENDP


;------------------------------------------------
;Procedure Name : M_ADD
;Function : ADD 명령어 기능을 구현
;PROGRAMED BY 정태영
;PROGRAM VERSION
;   Creation Date :Nov 26,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
M_ADD PROC
;ADD 명령어 구현
   mov dx, VDECODE[4]
   mov ax, VDECODE[8]
   mov bx, VDECODE[2]
   
   and VDECODE[4], 1111b
   mov VDECODE[4], dx
   
   cmp VDECODE[4], 1000b	;operand1이 A일때
   je M_ADD_A
   cmp VDECODE[4], 1001b	;operand1이 B일때
   je M_ADD_B1
   cmp VDECODE[4], 1010b	;operand1이 C일때
   je M_ADD_C1
   cmp VDECODE[4], 1011b	;operand1이 D일때
   je M_ADD_D1
   cmp VDECODE[4], 1100b	;operand1이 E일때
   je M_ADD_E1
   cmp VDECODE[4], 1101b	;operand1이 F일때
   je M_ADD_F1
   cmp VDECODE[4], 1110b	;operand1이 X일때
   je M_ADD_X1
   cmp VDECODE[4], 1111b	;operand1이 Y일때
   je M_ADD_Y1
   jmp M_ADD_EXIT	;M_ADD 종료
   
M_ADD_A:		;operand1이 A일 때 addressing mode 비교
   and VDECODE[2], 11b
   mov VDECODE[2], bx
   
   cmp VDECODE[2], 00b		;Register 모드
   je M_ADD_A_REG
   cmp VDECODE[2], 01b		;Immediate 모드
   je M_ADD_A_IMME1
   cmp VDECODE[2], 10b		;Indirect 모드
   je M_ADD_A_INDIRECT
   cmp VDECODE[2], 11b		;Direct 모드
   je M_ADD_A_DIRECT
   jmp M_ADD_EXIT			;M_ADD 종료
   
				;M_ADD_B, C, D, E, F, X, Y까지 점프할 때 
				;점프범위 오류해결을 위해 점프 거리를 나눠서 분기
M_ADD_B1:
   jmp M_ADD_B2
M_ADD_C1:
   jmp M_ADD_C2
M_ADD_D1:
   jmp M_ADD_D2
M_ADD_E1:
   jmp M_ADD_E2
M_ADD_F1:
   jmp M_ADD_F2
M_ADD_X1:
   jmp M_ADD_X2
M_ADD_Y1:
   jmp M_ADD_Y2
   
M_ADD_A_INDIRECT:			;operand1이 A이고 INDIRECT모드
   cmp VDECODE[8], 1110b	;operand1이 A이고 operand2이 X일때
   je M_ADD_A_INDIRECT_X
   cmp VDECODE[8], 1111b	;operand1이 A이고 operand2이 Y일때
   je M_ADD_A_INDIRECT_Y
M_ADD_A_INDIRECT_X:			;operand1이 A이고 operand2이 X일때
   mov si, X
   mov bx, m[si]
   call M_ADD_A_REG_SOMETHING	;A와 어떤 것을 연산하는 프로시져 콜
   jmp M_ADD_A_EXIT				;M_ADD 종료
M_ADD_A_INDIRECT_Y:				;operand1이 A이고 operand2이 Y일때
   mov si, Y
   mov bx, m[si]
   call M_ADD_A_REG_SOMETHING
   jmp M_ADD_A_EXIT				;M_ADD 종료
M_ADD_A_DIRECT:					;operand1이 A이고 direct 모드일 때
   mov si, VDECODE[10]
   mov bx, m[si]
   call M_ADD_A_REG_SOMETHING
   jmp M_ADD_A_EXIT				;M_ADD_A 종료

				;점프범위 오류해결을 위해 점프 거리를 나눠서 분기   
M_ADD_A_IMME1:
   jmp M_ADD_A_IMME   
   
M_ADD_A_REG:			;operand1이 A이고 operand2가 레지스터일때
   mov VDECODE[8], ax
   
   cmp VDECODE[8], 1000b		;A
   je M_ADD_A_REG_A
   cmp VDECODE[8], 1001b		;B
   je M_ADD_A_REG_B
   cmp VDECODE[8], 1010b		;C
   je M_ADD_A_REG_C
   cmp VDECODE[8], 1011b		;D
   je M_ADD_A_REG_D
   cmp VDECODE[8], 1100b		;E
   je M_ADD_A_REG_E
   cmp VDECODE[8], 1101b		;F
   je M_ADD_A_REG_F
   cmp VDECODE[8], 1110b		;X
   je M_ADD_A_REG_X
   cmp VDECODE[8], 1111b		;Y
   je M_ADD_A_REG_Y
   jmp M_ADD_A_EXIT				;M_ADD 종료
   
;점프범위 오류해결을 위해 점프 거리를 나눠서 분기 
M_ADD_B2:
   jmp M_ADD_B
   
M_ADD_A_REG_A:					;ADD A, A
   mov bx, A
   call M_ADD_A_REG_SOMETHING
   jmp M_ADD_A_EXIT				;M_ADD 종료
M_ADD_A_REG_B:					;ADD A, B
   mov bx, B
   call M_ADD_A_REG_SOMETHING
   jmp M_ADD_A_EXIT				;M_ADD 종료
M_ADD_A_REG_C:					;ADD A, C
   mov bx, C
   call M_ADD_A_REG_SOMETHING
   jmp M_ADD_A_EXIT				;M_ADD 종료
M_ADD_A_REG_D:					;ADD A, D
   mov bx, D
   call M_ADD_A_REG_SOMETHING
   jmp M_ADD_A_EXIT				;M_ADD 종료
M_ADD_A_REG_E:					;ADD A, E
   mov bx, E
   call M_ADD_A_REG_SOMETHING
   jmp M_ADD_A_EXIT				;M_ADD 종료
M_ADD_A_REG_F:					;ADD A, F
   mov bx, F
   call M_ADD_A_REG_SOMETHING
   jmp M_ADD_A_EXIT				;M_ADD 종료
M_ADD_A_REG_X:					;ADD A, X
   mov bx, X
   call M_ADD_A_REG_SOMETHING
   jmp M_ADD_A_EXIT				;M_ADD 종료
M_ADD_A_REG_Y:					;ADD A, Y
   mov bx, Y
   call M_ADD_A_REG_SOMETHING
   jmp M_ADD_A_EXIT				;M_ADD 종료

M_ADD_A_IMME:					;operand1이 A이고 immediate 모드일 때
   mov ax, A
   mov bx, VDECODE[10]
   add ax, bx
   mov A, ax
   
M_ADD_A_EXIT:					;M_ADD를 종료
   jmp M_ADD_EXIT

M_ADD_B:						;operand1이 B일 때 addressing mode 비교
   cmp VDECODE[2], 00b;Register 모드
   je M_ADD_B_REG
   cmp VDECODE[2], 01b;Immediate 모드
   je M_ADD_B_IMME1
   cmp VDECODE[2], 10b;Indirect 모드
   je M_ADD_B_INDIRECT
   cmp VDECODE[2], 11b;Direct 모드
   je M_ADD_B_DIRECT
   jmp M_ADD_EXIT				;M_ADD를 종료

M_ADD_B_INDIRECT:				;operand1이 B이고 INDIRECT모드
   cmp VDECODE[8], 1110b		;operand1이 B이고 operand2이 X일때
   je M_ADD_B_INDIRECT_X
   cmp VDECODE[8], 1111b		;operand1이 B이고 operand2이 Y일때
   je M_ADD_B_INDIRECT_Y
M_ADD_B_INDIRECT_X:				;operand1이 B이고 operand2이 X일때
   mov si, X
   mov bx, m[si]
   call M_ADD_B_REG_SOMETHING	;B와 어떤 것을 연산하는 프로시져 콜
   jmp M_ADD_B_EXIT				;M_ADD 종료
M_ADD_B_INDIRECT_Y:				;operand1이 B이고 operand2이 Y일때 
   mov si, Y
   mov bx, m[si]
   call M_ADD_B_REG_SOMETHING
   jmp M_ADD_B_EXIT				;M_ADD 종료
M_ADD_B_DIRECT:					;operand1이 B이고 direct 모드일 때
   mov si, VDECODE[10]
   mov bx, m[si]
   call M_ADD_B_REG_SOMETHING
   jmp M_ADD_B_EXIT				;M_ADD 종료
  
				;점프범위 오류해결을 위해 점프 거리를 나눠서 분기   
M_ADD_B_IMME1:
   jmp M_ADD_B_IMME
   
M_ADD_B_REG:				;operand1이 B이고 operand2가 레지스터일때   
   cmp VDECODE[8], 1000b	;A
   je M_ADD_B_REG_A
   cmp VDECODE[8], 1001b	;B
   je M_ADD_B_REG_B
   cmp VDECODE[8], 1010b	;C
   je M_ADD_B_REG_C
   cmp VDECODE[8], 1011b	;D
   je M_ADD_B_REG_D
   cmp VDECODE[8], 1100b	;E
   je M_ADD_B_REG_E
   cmp VDECODE[8], 1101b	;F
   je M_ADD_B_REG_F
   cmp VDECODE[8], 1110b	;X
   je M_ADD_B_REG_X
   cmp VDECODE[8], 1111b	;Y
   je M_ADD_B_REG_Y
   jmp M_ADD_B_EXIT			;M_ADD 종료
   
				;점프범위 오류해결을 위해 점프 거리를 나눠서 분기  
M_ADD_C2:
   jmp M_ADD_C
M_ADD_D2:
   jmp M_ADD_D3
M_ADD_E2:
   jmp M_ADD_E3
M_ADD_F2:
   jmp M_ADD_F3
M_ADD_X2:
   jmp M_ADD_X3
M_ADD_Y2:
   jmp M_ADD_Y3
   
M_ADD_B_REG_A:			;ADD B, A
   mov bx, A
   call M_ADD_B_REG_SOMETHING
   jmp M_ADD_B_EXIT		;M_ADD 종료
M_ADD_B_REG_B:			;ADD B, B
   mov bx, B
   call M_ADD_B_REG_SOMETHING
   jmp M_ADD_B_EXIT		;M_ADD 종료
M_ADD_B_REG_C:			;ADD B, C
   mov bx, C
   call M_ADD_B_REG_SOMETHING
   jmp M_ADD_B_EXIT		;M_ADD 종료
M_ADD_B_REG_D:			;ADD B, D
   mov bx, D
   call M_ADD_B_REG_SOMETHING
   jmp M_ADD_B_EXIT		;M_ADD 종료
M_ADD_B_REG_E:			;ADD B, E
   mov bx, E
   call M_ADD_B_REG_SOMETHING
   jmp M_ADD_B_EXIT		;M_ADD 종료
M_ADD_B_REG_F:			;ADD B, F
   mov bx, F
   call M_ADD_B_REG_SOMETHING
   jmp M_ADD_B_EXIT		;M_ADD 종료
M_ADD_B_REG_X:			;ADD B, X
   mov bx, X
   call M_ADD_B_REG_SOMETHING
   jmp M_ADD_B_EXIT		;M_ADD 종료
M_ADD_B_REG_Y:			;ADD B, Y
   mov bx, Y
   call M_ADD_B_REG_SOMETHING
   jmp M_ADD_B_EXIT		;M_ADD 종료

M_ADD_B_IMME:			;operand1이 B이고 immediate 모드일 때
   mov ax, B
   mov bx, VDECODE[10]
   add ax, bx
   mov B, ax
   
M_ADD_B_EXIT:			;M_ADD 종료
   jmp M_ADD_EXIT

M_ADD_C:		;operand1이 C일 때 addressing mode 비교
   cmp VDECODE[2], 00b		;Register 모드
   je M_ADD_C_REG
   cmp VDECODE[2], 01b		;Immediate 모드
   je M_ADD_C_IMME1
   cmp VDECODE[2], 10b		;Indirect 모드
   je M_ADD_C_INDIRECT
   cmp VDECODE[2], 11b		;Direct 모드
   je M_ADD_C_DIRECT
   jmp M_ADD_EXIT			;M_ADD 종료

M_ADD_C_INDIRECT:			;operand1이 C이고 INDIRECT모드
   cmp VDECODE[8], 1110b	;operand1이 C이고 operand2이 X일때
   je M_ADD_C_INDIRECT_X
   cmp VDECODE[8], 1111b	;operand1이 C이고 operand2이 Y일때
   je M_ADD_C_INDIRECT_Y
M_ADD_C_INDIRECT_X:			;operand1이 C이고 operand2이 X일때
   mov si, X
   mov bx, m[si]
   call M_ADD_C_REG_SOMETHING	;C와 어떤 것을 연산하는 프로시져 콜
   jmp M_ADD_C_EXIT				;M_ADD 종료
M_ADD_C_INDIRECT_Y:				;operand1이 C이고 operand2이 Y일때
   mov si, Y
   mov bx, m[si]
   call M_ADD_C_REG_SOMETHING
   jmp M_ADD_C_EXIT				;M_ADD 종료
M_ADD_C_DIRECT:					;operand1이 C이고 direct 모드일 때
   mov si, VDECODE[10]
   mov bx, m[si]
   call M_ADD_C_REG_SOMETHING
   jmp M_ADD_C_EXIT				;M_ADD 종료
   
					;점프범위 오류해결을 위해 점프 거리를 나눠서 분기 
M_ADD_C_IMME1:
   jmp M_ADD_C_IMME
   
M_ADD_C_REG:					;operand2가 레지스터일때   
   cmp VDECODE[8], 1000b		;A
   je M_ADD_C_REG_A
   cmp VDECODE[8], 1001b		;B
   je M_ADD_C_REG_B
   cmp VDECODE[8], 1010b		;C
   je M_ADD_C_REG_C
   cmp VDECODE[8], 1011b		;D
   je M_ADD_C_REG_D
   cmp VDECODE[8], 1100b		;E
   je M_ADD_C_REG_E
   cmp VDECODE[8], 1101b		;F
   je M_ADD_C_REG_F
   cmp VDECODE[8], 1110b		;X
   je M_ADD_C_REG_X
   cmp VDECODE[8], 1111b		;Y
   je M_ADD_C_REG_Y
   jmp M_ADD_C_EXIT				;M_ADD 종료
   
					;점프범위 오류해결을 위해 점프 거리를 나눠서 분기    
M_ADD_D3:
   jmp M_ADD_D
M_ADD_E3:
   jmp M_ADD_E
M_ADD_F3:
   jmp M_ADD_F4
M_ADD_X3:
   jmp M_ADD_X4
M_ADD_Y3:
   jmp M_ADD_Y4
   
M_ADD_C_REG_A:					;ADD C, A
   mov bx, A
   call M_ADD_C_REG_SOMETHING
   jmp M_ADD_C_EXIT				;M_ADD 종료
M_ADD_C_REG_B:					;ADD C, B
   mov bx, B
   call M_ADD_C_REG_SOMETHING
   jmp M_ADD_C_EXIT				;M_ADD 종료
M_ADD_C_REG_C:					;ADD C, C
   mov bx, C
   call M_ADD_C_REG_SOMETHING
   jmp M_ADD_C_EXIT				;M_ADD 종료
M_ADD_C_REG_D:					;ADD C, D
   mov bx, D
   call M_ADD_C_REG_SOMETHING
   jmp M_ADD_C_EXIT				;M_ADD 종료
M_ADD_C_REG_E:					;ADD C, E
   mov bx, E
   call M_ADD_C_REG_SOMETHING
   jmp M_ADD_C_EXIT				;M_ADD 종료
M_ADD_C_REG_F:					;ADD C, F
   mov bx, F
   call M_ADD_C_REG_SOMETHING
   jmp M_ADD_C_EXIT				;M_ADD 종료
M_ADD_C_REG_X:					;ADD C, X
   mov bx, X
   call M_ADD_C_REG_SOMETHING
   jmp M_ADD_C_EXIT				;M_ADD 종료
M_ADD_C_REG_Y:					;ADD C, Y
   mov bx, Y
   call M_ADD_C_REG_SOMETHING
   jmp M_ADD_C_EXIT				;M_ADD 종료

M_ADD_C_IMME:		;operand1이 C이고 immediate 모드일 때
   mov ax, C
   mov bx, VDECODE[10]
   add ax, bx
   mov C, ax
   
M_ADD_C_EXIT:			;M_ADD 종료
   jmp M_ADD_EXIT
M_ADD_D:				;operand1이 D일 때 addressing mode 비교
   cmp VDECODE[2], 00b	;Register 모드
   je M_ADD_D_REG
   cmp VDECODE[2], 01b	;Immediate 모드
   je M_ADD_D_IMME1
   cmp VDECODE[2], 10b	;Indirect 모드
   je M_ADD_D_INDIRECT
   cmp VDECODE[2], 11b	;Direct 모드
   je M_ADD_D_DIRECT
   jmp M_ADD_EXIT		;M_ADD 종료

M_ADD_D_INDIRECT:			;operand1이 D이고 INDIRECT모드
   cmp VDECODE[8], 1110b	;operand1이 D이고 operand2이 X일때
   je M_ADD_D_INDIRECT_X
   cmp VDECODE[8], 1111b	;operand1이 D이고 operand2이 Y일때
   je M_ADD_D_INDIRECT_Y
M_ADD_D_INDIRECT_X:			;operand1이 D이고 operand2이 X일때
   mov si, X
   mov bx, m[si]
   call M_ADD_D_REG_SOMETHING	;D와 어떤 것을 연산하는 프로시져 콜
   jmp M_ADD_D_EXIT			;M_ADD 종료
M_ADD_D_INDIRECT_Y:			;operand1이 D이고 operand2이 Y일때
   mov si, Y
   mov bx, m[si]
   call M_ADD_D_REG_SOMETHING
   jmp M_ADD_D_EXIT			;M_ADD 종료
M_ADD_D_DIRECT:				;operand1이 D이고 direct 모드일 때
   mov si, VDECODE[10]
   mov bx, m[si]
   call M_ADD_D_REG_SOMETHING
   jmp M_ADD_D_EXIT			;M_ADD 종료
   
			;점프범위 오류해결을 위해 점프 거리를 나눠서 분기    
M_ADD_D_IMME1:
   jmp M_ADD_D_IMME   
   
M_ADD_D_REG:				;operand1이 D이고 operand2가 레지스터일때   
   cmp VDECODE[8], 1000b	;A
   je M_ADD_D_REG_A
   cmp VDECODE[8], 1001b	;B
   je M_ADD_D_REG_B
   cmp VDECODE[8], 1010b	;C
   je M_ADD_D_REG_C
   cmp VDECODE[8], 1011b	;D
   je M_ADD_D_REG_D
   cmp VDECODE[8], 1100b	;E
   je M_ADD_D_REG_E
   cmp VDECODE[8], 1101b	;F
   je M_ADD_D_REG_F
   cmp VDECODE[8], 1110b	;X
   je M_ADD_D_REG_X
   cmp VDECODE[8], 1111b	;Y
   je M_ADD_D_REG_Y
   jmp M_ADD_D_EXIT		;M_ADD 종료
   
			;점프범위 오류해결을 위해 점프 거리를 나눠서 분기    
M_ADD_F4:
   jmp M_ADD_F
M_ADD_X4:
   jmp M_ADD_X
M_ADD_Y4:
   jmp M_ADD_Y
   
M_ADD_D_REG_A:					;ADD D, A
   mov bx, A
   call M_ADD_D_REG_SOMETHING
   jmp M_ADD_D_EXIT				;M_ADD 종료
M_ADD_D_REG_B:					;ADD D, B
   mov bx, B
   call M_ADD_D_REG_SOMETHING
   jmp M_ADD_D_EXIT				;M_ADD 종료
M_ADD_D_REG_C:					;ADD D, C
   mov bx, C
   call M_ADD_D_REG_SOMETHING
   jmp M_ADD_D_EXIT				;M_ADD 종료
M_ADD_D_REG_D:					;ADD D, D
   mov bx, D
   call M_ADD_D_REG_SOMETHING
   jmp M_ADD_D_EXIT				;M_ADD 종료
M_ADD_D_REG_E:					;ADD D, E
   mov bx, E
   call M_ADD_D_REG_SOMETHING
   jmp M_ADD_D_EXIT				;M_ADD 종료
M_ADD_D_REG_F:					;ADD D, F
   mov bx, F
   call M_ADD_D_REG_SOMETHING
   jmp M_ADD_D_EXIT				;M_ADD 종료
M_ADD_D_REG_X:					;ADD D, X
   mov bx, X
   call M_ADD_D_REG_SOMETHING
   jmp M_ADD_D_EXIT				;M_ADD 종료
M_ADD_D_REG_Y:					;ADD D, Y
   mov bx, Y
   call M_ADD_D_REG_SOMETHING
   jmp M_ADD_D_EXIT				;M_ADD 종료

M_ADD_D_IMME:				;operand1이 D이고 immediate 모드일 때
   mov ax, D
   mov bx, VDECODE[10]
   add ax, bx
   mov D, ax
   
M_ADD_D_EXIT:					;M_ADD 종료
   jmp M_ADD_EXIT
   
M_ADD_E:				;operand1이 E일 때 addressing mode 비교
   cmp VDECODE[2], 00b		;Register 모드
   je M_ADD_E_REG
   cmp VDECODE[2], 01b		;Immediate 모드
   je M_ADD_E_IMME1
   cmp VDECODE[2], 10b		;Indirect 모드
   je M_ADD_E_INDIRECT
   cmp VDECODE[2], 11b		;Direct 모드
   je M_ADD_E_DIRECT
   jmp M_ADD_EXIT			;M_ADD 종료

M_ADD_E_INDIRECT:			;operand1이 E이고 INDIRECT모드
   cmp VDECODE[8], 1110b	;operand1이 E이고 operand2이 X일때
   je M_ADD_E_INDIRECT_X
   cmp VDECODE[8], 1111b	;operand1이 E이고 operand2이 Y일때
   je M_ADD_E_INDIRECT_Y
M_ADD_E_INDIRECT_X:			;operand1이 E이고 operand2이 X일때
   mov si, X
   mov bx, m[si]
   call M_ADD_E_REG_SOMETHING	;E와 어떤 것을 연산하는 프로시져 콜
   jmp M_ADD_E_EXIT				;M_ADD 종료
M_ADD_E_INDIRECT_Y:			;operand1이 E이고 operand2이 Y일때
   mov si, Y
   mov bx, m[si]
   call M_ADD_E_REG_SOMETHING
   jmp M_ADD_E_EXIT				;M_ADD 종료
M_ADD_E_DIRECT:
   mov si, VDECODE[10]			;operand1이 E이고 direct 모드일 때
   mov bx, m[si]
   call M_ADD_E_REG_SOMETHING
   jmp M_ADD_E_EXIT				;M_ADD 종료
   
			;점프범위 오류해결을 위해 점프 거리를 나눠서 분기    
M_ADD_E_IMME1:
   jmp M_ADD_E_IMME   
   
M_ADD_E_REG:		;operand1이 E이고 operand2가 레지스터일때   
   cmp VDECODE[8], 1000b		;A
   je M_ADD_E_REG_A
   cmp VDECODE[8], 1001b		;B
   je M_ADD_E_REG_B
   cmp VDECODE[8], 1010b		;C
   je M_ADD_E_REG_C
   cmp VDECODE[8], 1011b		;D
   je M_ADD_E_REG_D
   cmp VDECODE[8], 1100b		;E
   je M_ADD_E_REG_E
   cmp VDECODE[8], 1101b		;F
   je M_ADD_E_REG_F
   cmp VDECODE[8], 1110b		;X
   je M_ADD_E_REG_X
   cmp VDECODE[8], 1111b		;Y
   je M_ADD_E_REG_Y
   jmp M_ADD_E_EXIT				;M_ADD 종료
   
M_ADD_E_REG_A:					;ADD E, A
   mov bx, A
   call M_ADD_E_REG_SOMETHING
   jmp M_ADD_E_EXIT				;M_ADD 종료
M_ADD_E_REG_B:					;ADD E, B
   mov bx, B
   call M_ADD_E_REG_SOMETHING
   jmp M_ADD_E_EXIT				;M_ADD 종료
M_ADD_E_REG_C:					;ADD E, C
   mov bx, C
   call M_ADD_E_REG_SOMETHING
   jmp M_ADD_E_EXIT				;M_ADD 종료
M_ADD_E_REG_D:					;ADD E, D
   mov bx, D
   call M_ADD_E_REG_SOMETHING
   jmp M_ADD_E_EXIT				;M_ADD 종료
M_ADD_E_REG_E:					;ADD E, E
   mov bx, E
   call M_ADD_E_REG_SOMETHING
   jmp M_ADD_E_EXIT				;M_ADD 종료
M_ADD_E_REG_F:					;ADD E, F
   mov bx, F
   call M_ADD_E_REG_SOMETHING
   jmp M_ADD_E_EXIT				;M_ADD 종료
M_ADD_E_REG_X:					;ADD E, X
   mov bx, X
   call M_ADD_E_REG_SOMETHING
   jmp M_ADD_E_EXIT				;M_ADD 종료
M_ADD_E_REG_Y:					;ADD E, Y
   mov bx, Y
   call M_ADD_E_REG_SOMETHING
   jmp M_ADD_E_EXIT				;M_ADD 종료

M_ADD_E_IMME:			;operand1이 E이고 immediate 모드일 때
   mov ax, E
   mov bx, VDECODE[10]
   add ax, bx
   mov E, ax
   
M_ADD_E_EXIT:			;M_ADD 종료
   jmp M_ADD_EXIT
   
M_ADD_F:				;operand1이 F일 때 addressing mode 비교
   cmp VDECODE[2], 00b	;Register 모드
   je M_ADD_F_REG
   cmp VDECODE[2], 01b	;Immediate 모드
   je M_ADD_F_IMME1
   cmp VDECODE[2], 10b	;Indirect 모드
   je M_ADD_F_INDIRECT
   cmp VDECODE[2], 11b	;Direct 모드
   je M_ADD_F_DIRECT
   jmp M_ADD_EXIT		;M_ADD 종료

M_ADD_F_INDIRECT:		;operand1이 F이고 INDIRECT모드
   cmp VDECODE[8], 1110b	;operand1이 F이고 operand2이 X일때
   je M_ADD_F_INDIRECT_X
   cmp VDECODE[8], 1111b	;operand1이 F이고 operand2이 Y일때
   je M_ADD_F_INDIRECT_Y
M_ADD_F_INDIRECT_X:			;operand1이 F이고 operand2이 X일때
   mov si, X
   mov bx, m[si]
   call M_ADD_F_REG_SOMETHING	;F와 어떤 것을 연산하는 프로시져 콜
   jmp M_ADD_F_EXIT				;M_ADD 종료
M_ADD_F_INDIRECT_Y:				;operand1이 F이고 operand2이 Y일때
   mov si, Y
   mov bx, m[si]
   call M_ADD_F_REG_SOMETHING
   jmp M_ADD_F_EXIT				;M_ADD 종료
M_ADD_F_DIRECT:				;operand1이 F이고 direct 모드일 때
   mov si, VDECODE[10]
   mov bx, m[si]
   call M_ADD_F_REG_SOMETHING
   jmp M_ADD_F_EXIT			;M_ADD 종료
   
			;점프범위 오류해결을 위해 점프 거리를 나눠서 분기    
M_ADD_F_IMME1:
   jmp M_ADD_F_IMME   
   
M_ADD_F_REG:			;operand1이 F이고 operand2가 레지스터일때   
   cmp VDECODE[8], 1000b	;A
   je M_ADD_F_REG_A
   cmp VDECODE[8], 1001b	;B
   je M_ADD_F_REG_B
   cmp VDECODE[8], 1010b	;C
   je M_ADD_F_REG_C
   cmp VDECODE[8], 1011b	;D
   je M_ADD_F_REG_D
   cmp VDECODE[8], 1100b	;E
   je M_ADD_F_REG_E
   cmp VDECODE[8], 1101b	;F
   je M_ADD_F_REG_F
   cmp VDECODE[8], 1110b	;X
   je M_ADD_F_REG_X
   cmp VDECODE[8], 1111b	;Y
   je M_ADD_F_REG_Y
   jmp M_ADD_F_EXIT			;M_ADD 종료
   
M_ADD_F_REG_A:				;ADD F, A
   mov bx, A
   call M_ADD_F_REG_SOMETHING
   jmp M_ADD_F_EXIT			;M_ADD 종료
M_ADD_F_REG_B:				;ADD F, B
   mov bx, B
   call M_ADD_F_REG_SOMETHING
   jmp M_ADD_F_EXIT			;M_ADD 종료
M_ADD_F_REG_C:				;ADD F, C
   mov bx, C
   call M_ADD_F_REG_SOMETHING
   jmp M_ADD_F_EXIT			;M_ADD 종료
M_ADD_F_REG_D:				;ADD F, D
   mov bx, D
   call M_ADD_F_REG_SOMETHING
   jmp M_ADD_F_EXIT			;M_ADD 종료
M_ADD_F_REG_E:				;ADD F, E
   mov bx, E
   call M_ADD_F_REG_SOMETHING
   jmp M_ADD_F_EXIT			;M_ADD 종료
M_ADD_F_REG_F:				;ADD F, F
   mov bx, F
   call M_ADD_F_REG_SOMETHING
   jmp M_ADD_F_EXIT			;M_ADD 종료
M_ADD_F_REG_X:				;ADD F, X
   mov bx, X
   call M_ADD_F_REG_SOMETHING
   jmp M_ADD_F_EXIT			;M_ADD 종료
M_ADD_F_REG_Y:				;ADD F, Y
   mov bx, Y
   call M_ADD_F_REG_SOMETHING
   jmp M_ADD_F_EXIT			;M_ADD 종료

M_ADD_F_IMME:				;operand1이 F이고 immediate 모드일 때
   mov ax, F
   mov bx, VDECODE[10]
   add ax, bx
   mov F, ax
   
M_ADD_F_EXIT:					;M_ADD 종료
   jmp M_ADD_EXIT
   
M_ADD_X:				;operand1이 X일 때 addressing mode 비교
   cmp VDECODE[2], 00b	;Register 모드
   je M_ADD_X_REG
   cmp VDECODE[2], 01b	;Immediate 모드
   je M_ADD_X_IMME1
   cmp VDECODE[2], 10b	;Indirect 모드
   je M_ADD_X_INDIRECT
   cmp VDECODE[2], 11b	;Direct 모드
   je M_ADD_X_DIRECT
   jmp M_ADD_EXIT		;M_ADD 종료

M_ADD_X_INDIRECT:			;operand1이 X이고 INDIRECT모드
   cmp VDECODE[8], 1110b	;operand1이 X이고 operand2이 X일때
   je M_ADD_X_INDIRECT_X
   cmp VDECODE[8], 1111b	;operand1이 X이고 operand2이 Y일때
   je M_ADD_X_INDIRECT_Y
M_ADD_X_INDIRECT_X:			;operand1이 X이고 operand2이 X일때
   mov si, X
   mov bx, m[si]
   call M_ADD_X_REG_SOMETHING	;X와 어떤 것을 연산하는 프로시져 콜
   jmp M_ADD_X_EXIT				;M_ADD 종료
M_ADD_X_INDIRECT_Y:				;operand1이 X이고 operand2이 Y일때
   mov si, Y
   mov bx, m[si]
   call M_ADD_X_REG_SOMETHING
   jmp M_ADD_X_EXIT				;M_ADD 종료
M_ADD_X_DIRECT:					;operand1이 X이고 direct 모드일 때
   mov si, VDECODE[10]
   mov bx, m[si]
   call M_ADD_X_REG_SOMETHING
   jmp M_ADD_X_EXIT				;M_ADD 종료
   
				;점프범위 오류해결을 위해 점프 거리를 나눠서 분기    
M_ADD_X_IMME1:   
   jmp M_ADD_X_IMME   
   
M_ADD_X_REG:			;operand1이 X이고 operand2가 레지스터일때   
   cmp VDECODE[8], 1000b	;A
   je M_ADD_X_REG_A
   cmp VDECODE[8], 1001b	;B
   je M_ADD_X_REG_B
   cmp VDECODE[8], 1010b	;C
   je M_ADD_X_REG_C
   cmp VDECODE[8], 1011b	;D
   je M_ADD_X_REG_D
   cmp VDECODE[8], 1100b	;E
   je M_ADD_X_REG_E
   cmp VDECODE[8], 1101b	;F
   je M_ADD_X_REG_F
   cmp VDECODE[8], 1110b	;X
   je M_ADD_X_REG_X
   cmp VDECODE[8], 1111b	;Y
   je M_ADD_X_REG_Y
   jmp M_ADD_X_EXIT			;M_ADD 종료
   
M_ADD_X_REG_A:				;ADD X, A
   mov bx, A
   call M_ADD_X_REG_SOMETHING
   jmp M_ADD_X_EXIT			;M_ADD 종료
M_ADD_X_REG_B:				;ADD X, B
   mov bx, B
   call M_ADD_X_REG_SOMETHING
   jmp M_ADD_X_EXIT			;M_ADD 종료
M_ADD_X_REG_C:				;ADD X, C
   mov bx, C
   call M_ADD_X_REG_SOMETHING
   jmp M_ADD_X_EXIT			;M_ADD 종료
M_ADD_X_REG_D:				;ADD X, D
   mov bx, D
   call M_ADD_X_REG_SOMETHING
   jmp M_ADD_X_EXIT			;M_ADD 종료
M_ADD_X_REG_E:				;ADD X, E
   mov bx, E
   call M_ADD_X_REG_SOMETHING
   jmp M_ADD_X_EXIT			;M_ADD 종료
M_ADD_X_REG_F:				;ADD X, F
   mov bx, F
   call M_ADD_X_REG_SOMETHING
   jmp M_ADD_X_EXIT			;M_ADD 종료
M_ADD_X_REG_X:				;ADD X, X
   mov bx, X
   call M_ADD_X_REG_SOMETHING
   jmp M_ADD_X_EXIT			;M_ADD 종료
M_ADD_X_REG_Y:				;ADD X, Y
   mov bx, Y
   call M_ADD_X_REG_SOMETHING
   jmp M_ADD_X_EXIT			;M_ADD 종료

M_ADD_X_IMME:			;operand1이 X이고 operand2가 immediate일때
   mov ax, X
   mov bx, VDECODE[10]
   add ax, bx
   mov X, ax
   
M_ADD_X_EXIT:				;M_ADD 종료
   jmp M_ADD_EXIT
   
M_ADD_Y:				;operand1이 Y일 때 addressing mode 비교
   cmp VDECODE[2], 00b	;Register 모드
   je M_ADD_Y_REG
   cmp VDECODE[2], 01b	;Immediate 모드
   je M_ADD_Y_IMME1
   cmp VDECODE[2], 10b	;Indirect 모드
   je M_ADD_Y_INDIRECT
   cmp VDECODE[2], 11b	;Direct 모드
   je M_ADD_Y_DIRECT
   jmp M_ADD_EXIT		;M_ADD 종료

M_ADD_Y_INDIRECT:			;operand1이 Y이고 INDIRECT모드
   cmp VDECODE[8], 1110b	;operand1이 Y이고 operand2이 X일때
   je M_ADD_Y_INDIRECT_X
   cmp VDECODE[8], 1111b	;operand1이 Y이고 operand2이 Y일때
   je M_ADD_Y_INDIRECT_Y
M_ADD_Y_INDIRECT_X:			;operand1이 Y이고 operand2이 X일때
   mov si, X
   mov bx, m[si]
   call M_ADD_Y_REG_SOMETHING	;Y와 어떤 것을 연산하는 프로시져 콜
   jmp M_ADD_Y_EXIT				;M_ADD 종료
M_ADD_Y_INDIRECT_Y:				;operand1이 Y이고 operand2이 Y일때
   mov si, Y
   mov bx, m[si]
   call M_ADD_Y_REG_SOMETHING
   jmp M_ADD_Y_EXIT				;M_ADD 종료
M_ADD_Y_DIRECT:					;operand1이 Y이고 direct 모드일 때
   mov si, VDECODE[10]
   mov bx, m[si]
   call M_ADD_Y_REG_SOMETHING
   jmp M_ADD_Y_EXIT				;M_ADD 종료
   
			;점프범위 오류해결을 위해 점프 거리를 나눠서 분기 
M_ADD_Y_IMME1:
   jmp M_ADD_Y_IMME
   
M_ADD_Y_REG:				;operand1이 Y이고 operand2가 레지스터일때   
   cmp VDECODE[8], 1000b	;A
   je M_ADD_Y_REG_A
   cmp VDECODE[8], 1001b	;B
   je M_ADD_Y_REG_B
   cmp VDECODE[8], 1010b	;C
   je M_ADD_Y_REG_C
   cmp VDECODE[8], 1011b	;D
   je M_ADD_Y_REG_D
   cmp VDECODE[8], 1100b	;E
   je M_ADD_Y_REG_E
   cmp VDECODE[8], 1101b	;F
   je M_ADD_Y_REG_F
   cmp VDECODE[8], 1110b	;X
   je M_ADD_Y_REG_X
   cmp VDECODE[8], 1111b	;Y
   je M_ADD_Y_REG_Y
   jmp M_ADD_Y_EXIT			;M_ADD 종료
   
M_ADD_Y_REG_A:			;ADD Y, A
   mov bx, A
   call M_ADD_Y_REG_SOMETHING
   jmp M_ADD_Y_EXIT		;M_ADD 종료
M_ADD_Y_REG_B:			;ADD Y, B
   mov bx, B
   call M_ADD_Y_REG_SOMETHING
   jmp M_ADD_Y_EXIT		;M_ADD 종료
M_ADD_Y_REG_C:			;ADD Y, C
   mov bx, C
   call M_ADD_Y_REG_SOMETHING
   jmp M_ADD_Y_EXIT		;M_ADD 종료
M_ADD_Y_REG_D:			;ADD Y, D
   mov bx, D
   call M_ADD_Y_REG_SOMETHING
   jmp M_ADD_Y_EXIT		;M_ADD 종료
M_ADD_Y_REG_E:			;ADD Y, E
   mov bx, E
   call M_ADD_Y_REG_SOMETHING
   jmp M_ADD_Y_EXIT		;M_ADD 종료
M_ADD_Y_REG_F:			;ADD Y, F
   mov bx, F
   call M_ADD_Y_REG_SOMETHING
   jmp M_ADD_Y_EXIT		;M_ADD 종료
M_ADD_Y_REG_X:			;ADD Y, X
   mov bx, X
   call M_ADD_Y_REG_SOMETHING
   jmp M_ADD_Y_EXIT		;M_ADD 종료
M_ADD_Y_REG_Y:			;ADD Y, Y
   mov bx, Y
   call M_ADD_Y_REG_SOMETHING
   jmp M_ADD_Y_EXIT		;M_ADD 종료

M_ADD_Y_IMME:			;operand1이 Y이고 immediate 모드일 때
   mov ax, Y
   mov bx, VDECODE[10]
   add ax, bx
   mov Y, ax
   
M_ADD_Y_EXIT:				;M_ADD 종료
   jmp M_ADD_EXIT
   
M_ADD_EXIT:					;M_ADD 종료
   RET
M_ADD ENDP

M_ADD_A_REG_SOMETHING PROC		;A와 어떤 것을 ADD연산하는 프로시져
   mov ax, A
   add ax, bx
   mov A, ax
   RET
M_ADD_A_REG_SOMETHING ENDP

M_ADD_B_REG_SOMETHING PROC		;B와 어떤 것을 ADD연산하는 프로시져
   mov ax, B
   add ax, bx
   mov B, ax
   RET
M_ADD_B_REG_SOMETHING ENDP

M_ADD_C_REG_SOMETHING PROC		;C와 어떤 것을 ADD연산하는 프로시져
   mov ax, C
   add ax, bx
   mov C, ax
   RET
M_ADD_C_REG_SOMETHING ENDP

M_ADD_D_REG_SOMETHING PROC		;D와 어떤 것을 ADD연산하는 프로시져
   mov ax, D
   add ax, bx
   mov D, ax
   RET
M_ADD_D_REG_SOMETHING ENDP

M_ADD_E_REG_SOMETHING PROC		;E와 어떤 것을 ADD연산하는 프로시져
   mov ax, E
   add ax, bx
   mov E, ax
   RET
M_ADD_E_REG_SOMETHING ENDP


M_ADD_F_REG_SOMETHING PROC		;F와 어떤 것을 ADD연산하는 프로시져
   mov ax, F
   add ax, bx
   mov F, ax
   RET
M_ADD_F_REG_SOMETHING ENDP

M_ADD_X_REG_SOMETHING PROC		;X와 어떤 것을 ADD연산하는 프로시져
   mov ax, X
   add ax, bx
   mov X, ax
   RET
M_ADD_X_REG_SOMETHING ENDP

M_ADD_Y_REG_SOMETHING PROC		;Y와 어떤 것을 ADD연산하는 프로시져
   mov ax, Y
   add ax, bx
   mov Y, ax
   RET
M_ADD_Y_REG_SOMETHING ENDP

;------------------------------------------------
;Procedure Name : COMPARE_A
;Function : A REGISTER의 CMP 명령어, REGISTER모드기능을 구현
;PROGRAMED BY 하영래
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
COMPARE_A PROC			 ; REGISTER모드일때 A와 비교
   MOV BX, VDECODE[8]
   CMP BX, 1001b
   JE @GO_B1
   CMP BX, 1010b
   JE @GO_C1
   CMP BX, 1011b
   JE @GO_D1
   CMP BX, 1100b
   JE @GO_E1
   CMP BX, 1101b
   JE @GO_F1
   CMP BX, 1110b
   JE @GO_X1
   CMP BX, 1111b
   JE @GO_Y1
   JMP @END

@GO_B1:
   MOV AX, B[0]
   CMP A, AX
   JE @SAME
   JA @ABOVE
   JB @BELOW_1
   JMP @END
@GO_C1:   
   MOV AX, C[0]
   CMP A, AX
   JE @SAME
   JA @ABOVE
   JB @BELOW
   JMP @END
@GO_D1:
   MOV AX, D[0]
   CMP A, AX
   JE @SAME
   JA @ABOVE
   JB @BELOW
   JMP @END
@GO_E1:
   MOV AX, E[0]
   CMP A, AX
   JE @SAME
   JA @ABOVE
   JB @BELOW
   JMP @END
   
@BELOW_1:
   JMP @BELOW
   
@GO_F1:
   MOV AX, F[0]
   CMP A, AX
   JE @SAME
   JA @ABOVE
   JB @BELOW
   JMP @END
@GO_X1:
   MOV AX, X[0]
   CMP A, AX
   JE @SAME
   JA @ABOVE
   JB @BELOW
   JMP @END
@GO_Y1:
   MOV AX, Y[0]
   CMP A, AX
   JE @SAME
   JA @ABOVE
   JB @BELOW
   JMP @END
@SAME:
   MOV BX, STATUS_RG
   AND STATUS_RG, 0000000000000000b
   MOV STATUS_RG[0], 00b
   JMP @END
   
@ABOVE:
   MOV BX, STATUS_RG
   AND STATUS_RG, 0000000000000000b
   MOV STATUS_RG[0], 01b
   JMP @END
   
@BELOW:
   MOV BX, STATUS_RG
   AND STATUS_RG, 0000000000000000b
   MOV STATUS_RG[0], 10b
   JMP @END
   RET
COMPARE_A ENDP
;------------------------------------------------
;Procedure Name : COMPARE_B
;Function : B REGISTER의 CMP 명령어, REGISTER모드기능을 구현
;PROGRAMED BY 하영래
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
COMPARE_B PROC      ; REGISTER모드일때 B와 비교
   MOV BX, VDECODE[8]
   CMP BX, 1000b
   JE @GO_A2
   CMP BX, 1010b
   JE @GO_C2
   CMP BX, 1011b
   JE @GO_D2
   CMP BX, 1100b
   JE @GO_E2
   CMP BX, 1101b
   JE @GO_F2
   CMP BX, 1110b
   JE @GO_X2
   CMP BX, 1111b
   JE @GO_Y2
   JMP @END
   
@GO_A2:
   MOV AX, A[0]
   CMP B, AX
   JE @SAME2
   JA @ABOVE2
   JB @BELOW2_1
   JMP @END
@GO_C2:   
   MOV AX, C[0]
   CMP B, AX
   JE @SAME2
   JA @ABOVE2
   JB @BELOW2
   JMP @END
@GO_D2:
   MOV AX, D[0]
   CMP B, AX
   JE @SAME2
   JA @ABOVE2
   JB @BELOW2
   JMP @END
@GO_E2:
   MOV AX, E[0]
   CMP B, AX
   JE @SAME2
   JA @ABOVE2
   JB @BELOW2
   JMP @END
   
@BELOW2_1:
   JMP @BELOW2
   
@GO_F2:
   MOV AX, F[0]
   CMP B, AX
   JE @SAME2
   JA @ABOVE2
   JB @BELOW2
   JMP @END
@GO_X2:
   MOV AX, X[0]
   CMP B, AX
   JE @SAME2
   JA @ABOVE2
   JMP @END
@GO_Y2:
   MOV AX, Y[0]
   CMP B, AX
   JE @SAME2
   JA @ABOVE2
   JB @BELOW2
   JMP @END
@SAME2:
   MOV BX, STATUS_RG
   AND STATUS_RG, 0000000000000000b
   MOV STATUS_RG[0], 00b
   JMP @END
   
@ABOVE2:
   MOV BX, STATUS_RG
   AND STATUS_RG, 0000000000000000b
   MOV STATUS_RG[0], 01b
   JMP @END
   
@BELOW2:
   MOV BX, STATUS_RG
   AND STATUS_RG, 0000000000000000b
   MOV STATUS_RG[0], 10b
   JMP @END
   RET
COMPARE_B ENDP
;------------------------------------------------
;Procedure Name : COMPARE_C
;Function : C REGISTER의 CMP 명령어, REGISTER모드기능을 구현
;PROGRAMED BY 하영래
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
COMPARE_C PROC      ; REGISTER모드일때 C와 비교
   MOV BX, VDECODE[8]
   CMP BX, 1000b
   JE @GO_A3
   CMP BX, 1001b
   JE @GO_B3
   CMP BX, 1011b
   JE @GO_D3
   CMP BX, 1100b
   JE @GO_E3
   CMP BX, 1101b
   JE @GO_F3
   CMP BX, 1110b
   JE @GO_X3
   CMP BX, 1111b
   JE @GO_Y3
   JMP @END
@GO_A3:
   MOV AX, A[0]
   CMP C, AX
   JE @SAME3
   JA @ABOVE3
   JB @BELOW3_1
   JMP @END
@GO_B3:
   MOV AX, B[0]
   CMP C, AX
   JE @SAME3
   JA @ABOVE3
   JB @BELOW3
   JMP @END
@GO_D3:
   MOV AX, D[0]
   CMP C, AX
   JE @SAME3
   JA @ABOVE3
   JB @BELOW3
   JMP @END
@GO_E3:   
   MOV AX, E[0]
   CMP C, AX
   JE @SAME3
   JA @ABOVE3
   JB @BELOW3
   JMP @END

@BELOW3_1:
   JMP @BELOW3

@GO_F3:
   MOV AX, F[0]
   CMP C, AX
   JE @SAME3
   JA @ABOVE3
   JMP @END
@GO_X3:
   MOV AX, X[0]
   CMP C, AX
   JE @SAME3
   JA @ABOVE3
   JB @BELOW3
   JMP @END
@GO_Y3:
   MOV AX, Y[0]
   CMP C, AX
   JE @SAME3
   JA @ABOVE3
   JB @BELOW3
   JMP @END
   
@SAME3:
   MOV BX, STATUS_RG
   AND STATUS_RG, 0000000000000000b
   MOV STATUS_RG[0], 00b
   JMP @END
   
@ABOVE3:
   MOV BX, STATUS_RG
   AND STATUS_RG, 0000000000000000b
   MOV STATUS_RG[0], 01b
   JMP @END
   
@BELOW3:
   MOV BX, STATUS_RG
   AND STATUS_RG, 0000000000000000b
   MOV STATUS_RG[0], 10b
   JMP @END
   RET
COMPARE_C ENDP
;------------------------------------------------
;Procedure Name : COMPARE_D
;Function : D REGISTER의 CMP 명령어, REGISTER모드기능을 구현
;PROGRAMED BY 하영래
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
COMPARE_D PROC      ; REGISTER모드일때 D와 비교
   MOV BX, VDECODE[8]
   CMP BX, 1000b
   JE @GO_A4
   CMP BX, 1001b
   JE @GO_B4
   CMP BX, 1010b
   JE @GO_C4
   CMP BX, 1100b
   JE @GO_E4
   CMP BX, 1101b
   JE @GO_F4
   CMP BX, 1110b
   JE @GO_X4
   CMP BX, 1111b
   JE @GO_Y4
   JMP @END
@GO_A4:
   MOV AX, A[0]
   CMP D, AX
   JE @SAME4
   JA @ABOVE4
   JB @BELOW4_1
   JMP @END
@GO_B4:
   MOV AX, B[0]
   CMP D, AX
   JE @SAME4
   JA @ABOVE4
   JB @BELOW4
   JMP @END
@GO_C4:   
   MOV AX, C[0]
   CMP D, AX
   JE @SAME4
   JA @ABOVE4
   JB @BELOW4
   JMP @END
@GO_E4:   
   MOV AX, E[0]
   CMP D, AX
   JE @SAME4
   JA @ABOVE4
   JB @BELOW4
   JMP @END
   
@BELOW4_1:
   JMP @BELOW4

@GO_F4:
   MOV AX, F[0]
   CMP D, AX
   JE @SAME4
   JA @ABOVE4
   JB @BELOW4
   JMP @END
@GO_X4:   
   MOV AX, X[0]
   CMP D, AX
   JE @SAME4
   JA @ABOVE4
   JB @BELOW4
   JMP @END
@GO_Y4:   
   MOV AX, Y[0]
   CMP D, AX
   JE @SAME4
   JA @ABOVE4
   JB @BELOW4
   JMP @END
   
@SAME4:
   MOV BX, STATUS_RG
   AND STATUS_RG, 0000000000000000b
   MOV STATUS_RG[0], 00b
   JMP @END
   
@ABOVE4:
   MOV BX, STATUS_RG
   AND STATUS_RG, 0000000000000000b
   MOV STATUS_RG[0], 01b
   JMP @END
   
@BELOW4:
   MOV BX, STATUS_RG
   AND STATUS_RG, 0000000000000000b
   MOV STATUS_RG[0], 10b
   JMP @END
   RET
COMPARE_D ENDP
;------------------------------------------------
;Procedure Name : COMPARE_E
;Function : E REGISTER의 CMP 명령어, REGISTER모드기능을 구현
;PROGRAMED BY 하영래
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
COMPARE_E PROC      ; REGISTER모드일때 E와 비교
   MOV BX, VDECODE[8]
   CMP BX, 1000b
   JE @GO_A5
   CMP BX, 1001b
   JE @GO_B5
   CMP BX, 1010b
   JE @GO_C5
   CMP BX, 1011b
   JE @GO_D5
   CMP BX, 1101b
   JE @GO_F5
   CMP BX, 1110b
   JE @GO_X5
   CMP BX, 1111b
   JE @GO_Y5
   JMP @END
@GO_A5:   
   MOV AX, A[0]
   CMP E, AX
   JE @SAME5
   JA @ABOVE5
   JB @BELOW5_1
   JMP @END
@GO_B5:   
   MOV AX, B[0]
   CMP E, AX
   JE @SAME5
   JA @ABOVE5
   JB @BELOW5
   JMP @END
@GO_C5:   
   MOV AX, C[0]
   CMP E, AX
   JE @SAME5
   JA @ABOVE5
   JB @BELOW5
   JMP @END
@GO_D5:   
   MOV AX, D[0]
   CMP E, AX
   JE @SAME5
   JA @ABOVE5
   JB @BELOW5
   JMP @END
   
@BELOW5_1:
   JMP @BELOW5

@GO_F5:
   MOV AX, F[0]
   CMP E, AX
   JE @SAME5
   JA @ABOVE5
   JB @BELOW5
   JMP @END
@GO_X5:   
   MOV AX, X[0]
   CMP E, AX
   JE @SAME5
   JA @ABOVE5
   JB @BELOW5
   JMP @END
@GO_Y5:   
   MOV AX, Y[0]
   CMP E, AX
   JE @SAME5
   JA @ABOVE5
   JB @BELOW5
   JMP @END
   
@SAME5:
   MOV BX, STATUS_RG
   AND STATUS_RG, 0000000000000000b
   MOV STATUS_RG[0], 00b
   JMP @END
   
@ABOVE5:
   MOV BX, STATUS_RG
   AND STATUS_RG, 0000000000000000b
   MOV STATUS_RG[0], 01b
   JMP @END
   
@BELOW5:
   MOV BX, STATUS_RG
   AND STATUS_RG, 0000000000000000b
   MOV STATUS_RG[0], 10b
   JMP @END
   RET
COMPARE_E ENDP
;------------------------------------------------
;Procedure Name : COMPARE_F
;Function : F REGISTER의 CMP 명령어, REGISTER모드기능을 구현
;PROGRAMED BY 하영래
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
COMPARE_F PROC      ; REGISTER모드일때 F와 비교
   MOV BX, VDECODE[8]
   CMP BX, 1000b
   JE @GO_A6
   CMP BX, 1001b
   JE @GO_B6
   CMP BX, 1010b
   JE @GO_C6
   CMP BX, 1011b
   JE @GO_D6
   CMP BX, 1100b
   JE @GO_E6
   CMP BX, 1110b
   JE @GO_X6
   CMP BX, 1111b
   JE @GO_Y6
   JMP @END
@GO_A6:
   MOV AX, A[0]
   CMP F, AX
   JE @SAME6
   JA @ABOVE6
   JB @BELOW6_1
   JMP @END
@GO_B6:
   MOV AX, B[0]
   CMP F, AX
   JE @SAME6
   JA @ABOVE6
   JB @BELOW6
   JMP @END
@GO_C6:   
   MOV AX, C[0]
   CMP F, AX
   JE @SAME6
   JA @ABOVE6
   JB @BELOW6
   JMP @END
@GO_D6:   
   MOV AX, D[0]
   CMP F, AX
   JE @SAME6
   JA @ABOVE6
   JB @BELOW6
   JMP @END
@GO_E6:   
   MOV AX, E[0]
   CMP F, AX
   JE @SAME6
   JA @ABOVE6
   JB @BELOW6
   JMP @END
   
@BELOW6_1:
   JMP @BELOW6
   
@GO_X6:
   MOV AX, X[0]
   CMP F, AX
   JE @SAME6
   JA @ABOVE6
   JB @BELOW6
   JMP @END
@GO_Y6:
   MOV AX, Y[0]
   CMP F, AX
   JE @SAME6
   JA @ABOVE6
   JB @BELOW6
   JMP @END
   
@SAME6:
   MOV BX, STATUS_RG
   AND STATUS_RG, 0000000000000000b
   MOV STATUS_RG[0], 00b
   JMP @END
   
@ABOVE6:
   MOV BX, STATUS_RG
   AND STATUS_RG, 0000000000000000b
   MOV STATUS_RG[0], 01b
   JMP @END
   
@BELOW6:
   MOV BX, STATUS_RG
   AND STATUS_RG, 0000000000000000b
   MOV STATUS_RG[0], 10b
   JMP @END
   RET
COMPARE_F ENDP
;------------------------------------------------
;Procedure Name : COMPARE_X
;Function : X REGISTER의 CMP 명령어, REGISTER모드기능을 구현
;PROGRAMED BY 하영래
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
COMPARE_X PROC      ; REGISTER모드일때 X와 비교
   MOV BX, VDECODE[8]
   CMP BX, 1000b
   JE @GO_A7
   CMP BX, 1001b
   JE @GO_B7
   CMP BX, 1010b
   JE @GO_C7
   CMP BX, 1011b
   JE @GO_D7
   CMP BX, 1100b
   JE @GO_E7
   CMP BX, 1101b
   JE @GO_F7
   CMP BX, 1111b
   JE @GO_Y7
   JMP @END
@GO_A7:
   MOV AX, A[0]
   CMP X, AX
   JE @SAME7
   JA @ABOVE7
   JB @BELOW7_1
   JMP @END
@GO_B7:
   MOV AX, B[0]
   CMP X, AX
   JE @SAME7
   JA @ABOVE7
   JB @BELOW7
   JMP @END
@GO_C7:
   MOV AX, C[0]
   CMP X, AX
   JE @SAME7
   JA @ABOVE7
   JB @BELOW7
   JMP @END
@GO_D7:
   MOV AX, D[0]
   CMP X, AX
   JE @SAME7
   JA @ABOVE7
   JB @BELOW7
   JMP @END
   
@BELOW7_1:
   JMP @BELOW7
   
@GO_E7:
   MOV AX, E[0]
   CMP X, AX
   JE @SAME7
   JA @ABOVE7
   JB @BELOW7
   JMP @END
@GO_F7:
   MOV AX, F[0]
   CMP X, AX
   JE @SAME7
   JA @ABOVE7
   JB @BELOW7
   JMP @END
@GO_Y7:
   MOV AX, Y[0]
   CMP X, AX
   JE @SAME7
   JA @ABOVE7
   JB @BELOW7
   JMP @END
   
@SAME7:
   MOV BX, STATUS_RG
   AND STATUS_RG, 0000000000000000b
   MOV STATUS_RG[0], 00b
   JMP @END
   
@ABOVE7:
   MOV BX, STATUS_RG
   AND STATUS_RG, 0000000000000000b
   MOV STATUS_RG[0], 01b
   JMP @END
   
@BELOW7:
   MOV BX, STATUS_RG
   AND STATUS_RG, 0000000000000000b
   MOV STATUS_RG[0], 10b
   JMP @END
   RET
COMPARE_X ENDP
;------------------------------------------------
;Procedure Name : COMPARE_Y
;Function : Y REGISTER의 CMP 명령어, REGISTER모드기능을 구현
;PROGRAMED BY 하영래
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
COMPARE_Y PROC      ; REGISTER모드일때 Y와 비교
   MOV BX, VDECODE[8]
   CMP BX, 1000b
   JE @GO_A8
   CMP BX, 1001b
   JE @GO_B8
   CMP BX, 1010b
   JE @GO_C8
   CMP BX, 1011b
   JE @GO_D8
   CMP BX, 1100b
   JE @GO_E8
   CMP BX, 1101b
   JE @GO_F8
   CMP BX, 1110b
   JE @GO_X8
   JMP @END
@GO_A8:
   MOV AX, A[0]
   CMP Y, AX
   JE @SAME8
   JA @ABOVE8
   JB @BELOW8_1
   JMP @END
@GO_B8:
   MOV AX, B[0]
   CMP Y, AX
   JE @SAME8
   JA @ABOVE8
   JB @BELOW8
   JMP @END
@GO_C8:
   MOV AX, C[0]
   CMP Y, AX
   JE @SAME8
   JA @ABOVE8
   JB @BELOW8
   JMP @END
@GO_D8:
   MOV AX, D[0]
   CMP Y, AX
   JE @SAME8
   JA @ABOVE8
   JB @BELOW8
   JMP @END
   
@BELOW8_1:
   JMP @BELOW8

@GO_E8:
   MOV AX, E[0]
   CMP Y, AX
   JE @SAME8
   JA @ABOVE8
   JB @BELOW8
   JMP @END
@GO_F8:
   MOV AX, F[0]
   CMP Y, AX
   JE @SAME8
   JA @ABOVE8
   JB @BELOW8
   JMP @END
@GO_X8:
   MOV AX, X[0]
   CMP Y, AX
   JE @SAME8
   JA @ABOVE8
   JB @BELOW8
   JMP @END
   
@SAME8:
   MOV BX, STATUS_RG
   AND STATUS_RG, 0000000000000000b
   MOV STATUS_RG[0], 00b
   JMP @END
   
@ABOVE8:
   MOV BX, STATUS_RG
   AND STATUS_RG, 0000000000000000b
   MOV STATUS_RG[0], 01b
   JMP @END
   
@BELOW8:
   MOV BX, STATUS_RG
   AND STATUS_RG, 0000000000000000b
   MOV STATUS_RG[0], 10b
   JMP @END
   RET
COMPARE_Y ENDP
;------------------------------------------------
;Procedure Name : IMMEDIATE_A
;Function : A REGISTER의 CMP 명령어, IMMEDIATE모드기능을 구현
;PROGRAMED BY 하영래
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
IMMEDIATE_A PROC   ; IMMEDIATE모드 일때 A와 비교
   MOV AX, VDECODE[10]
   CMP A, AX
   JE @SAME_IMM1
   JA @ABOVE_IMM1
   JB @BELOW_IMM1
   JMP @END
   
@SAME_IMM1:
   MOV BX, STATUS_RG
   AND STATUS_RG, 0000000000000000b
   MOV STATUS_RG[0], 00b
   JMP @END
   
@ABOVE_IMM1:
   MOV BX, STATUS_RG
   AND STATUS_RG, 0000000000000000b
   MOV STATUS_RG[0], 01b
   JMP @END
   
@BELOW_IMM1:
   MOV BX, STATUS_RG
   AND STATUS_RG, 0000000000000000b
   MOV STATUS_RG[0], 10b
   JMP @END
   RET
IMMEDIATE_A ENDP
;------------------------------------------------
;Procedure Name : IMMEDIATE_B
;Function : B REGISTER의 CMP 명령어, IMMEDIATE모드기능을 구현
;PROGRAMED BY 하영래
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
IMMEDIATE_B PROC   ; IMMEDIATE모드 일때 B와 비교
   MOV AX, VDECODE[10]
   CMP B, AX
   JE @SAME_IMM2
   JA @ABOVE_IMM2
   JB @BELOW_IMM2
   JMP @END
   
@SAME_IMM2:
   MOV BX, STATUS_RG
   AND STATUS_RG, 0000000000000000b
   MOV STATUS_RG[0], 00b
   JMP @END
   
@ABOVE_IMM2:
   MOV BX, STATUS_RG
   AND STATUS_RG, 0000000000000000b
   MOV STATUS_RG[0], 01b
   JMP @END
   
@BELOW_IMM2:
   MOV BX, STATUS_RG
   AND STATUS_RG, 0000000000000000b
   MOV STATUS_RG[0], 10b
   JMP @END
   RET
IMMEDIATE_B ENDP
;------------------------------------------------
;Procedure Name : IMMEDIATE_C
;Function : C REGISTER의 CMP 명령어, IMMEDIATE모드기능을 구현
;PROGRAMED BY 하영래
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
IMMEDIATE_C PROC   ; IMMEDIATE모드 일때 C와 비교
   MOV AX, VDECODE[10]
   CMP C, AX
   JE @SAME_IMM3
   JA @ABOVE_IMM3
   JB @BELOW_IMM3
   JMP @END
   
@SAME_IMM3:
   MOV BX, STATUS_RG
   AND STATUS_RG, 0000000000000000b
   MOV STATUS_RG[0], 00b
   JMP @END
   
@ABOVE_IMM3:
   MOV BX, STATUS_RG
   AND STATUS_RG, 0000000000000000b
   MOV STATUS_RG[0], 01b
   JMP @END
   
@BELOW_IMM3:
   MOV BX, STATUS_RG
   AND STATUS_RG, 0000000000000000b
   MOV STATUS_RG[0], 10b
   JMP @END
   RET
IMMEDIATE_C ENDP
;------------------------------------------------
;Procedure Name : IMMEDIATE_D
;Function : D REGISTER의 CMP 명령어, IMMEDIATE모드기능을 구현
;PROGRAMED BY 하영래
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
IMMEDIATE_D PROC   ; IMMEDIATE모드 일때 D와 비교
   MOV AX, VDECODE[10]
   CMP D, AX
   JE @SAME_IMM4
   JA @ABOVE_IMM4
   JB @BELOW_IMM4
   JMP @END
   
@SAME_IMM4:
   MOV BX, STATUS_RG
   AND STATUS_RG, 0000000000000000b
   MOV STATUS_RG[0], 00b
   JMP @END
   
@ABOVE_IMM4:
   MOV BX, STATUS_RG
   AND STATUS_RG, 0000000000000000b
   MOV STATUS_RG[0], 01b
   JMP @END
   
@BELOW_IMM4:
   MOV BX, STATUS_RG
   AND STATUS_RG, 0000000000000000b
   MOV STATUS_RG[0], 10b
   JMP @END
   RET
IMMEDIATE_D ENDP
;------------------------------------------------
;Procedure Name : IMMEDIATE_E
;Function : E REGISTER의 CMP 명령어, IMMEDIATE모드기능을 구현
;PROGRAMED BY 하영래
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
IMMEDIATE_E PROC   ; IMMEDIATE모드 일때 E와 비교
   MOV AX, VDECODE[10]
   CMP E, AX
   JE @SAME_IMM5
   JA @ABOVE_IMM5
   JB @BELOW_IMM5
   JMP @END
   
@SAME_IMM5:
   MOV BX, STATUS_RG
   AND STATUS_RG, 0000000000000000b
   MOV STATUS_RG[0], 00b
   JMP @END
   
@ABOVE_IMM5:
   MOV BX, STATUS_RG
   AND STATUS_RG, 0000000000000000b
   MOV STATUS_RG[0], 01b
   JMP @END
   
@BELOW_IMM5:
   MOV BX, STATUS_RG
   AND STATUS_RG, 0000000000000000b
   MOV STATUS_RG[0], 10b
   JMP @END
   RET
IMMEDIATE_E ENDP
;------------------------------------------------
;Procedure Name : IMMEDIATE_F
;Function : F REGISTER의 CMP 명령어, IMMEDIATE모드기능을 구현
;PROGRAMED BY 하영래
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
IMMEDIATE_F PROC   ; IMMEDIATE모드 일때 F와 비교
   MOV AX, VDECODE[10]
   CMP F, AX
   JE @SAME_IMM6
   JA @ABOVE_IMM6
   JB @BELOW_IMM6
   JMP @END
   
@SAME_IMM6:
   MOV BX, STATUS_RG
   AND STATUS_RG, 0000000000000000b
   MOV STATUS_RG[0], 00b
   JMP @END
   
@ABOVE_IMM6:
   MOV BX, STATUS_RG
   AND STATUS_RG, 0000000000000000b
   MOV STATUS_RG[0], 01b
   JMP @END
   
@BELOW_IMM6:
   MOV BX, STATUS_RG
   AND STATUS_RG, 0000000000000000b
   MOV STATUS_RG[0], 10b
   JMP @END
   RET
IMMEDIATE_F ENDP
;------------------------------------------------
;Procedure Name : IMMEDIATE_X
;Function : X REGISTER의 CMP 명령어, IMMEDIATE모드기능을 구현
;PROGRAMED BY 하영래
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
IMMEDIATE_X PROC   ; IMMEDIATE모드 일때 X와 비교
   MOV AX, VDECODE[10]
   CMP X, AX
   JE @SAME_IMM7
   JA @ABOVE_IMM7
   JB @BELOW_IMM7
   JMP @END
   
@SAME_IMM7:
   MOV BX, STATUS_RG
   AND STATUS_RG, 0000000000000000b
   MOV STATUS_RG[0], 00b
   JMP @END
   
@ABOVE_IMM7:
   MOV BX, STATUS_RG
   AND STATUS_RG, 0000000000000000b
   MOV STATUS_RG[0], 01b
   JMP @END
   
@BELOW_IMM7:
   MOV BX, STATUS_RG
   AND STATUS_RG, 0000000000000000b
   MOV STATUS_RG[0], 10b
   JMP @END
   RET
IMMEDIATE_X ENDP
;------------------------------------------------
;Procedure Name : IMMEDIATE_Y
;Function : Y REGISTER의 CMP 명령어, IMMEDIATE모드기능을 구현
;PROGRAMED BY 하영래
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
IMMEDIATE_Y PROC   ; IMMEDIATE모드 일때 Y와 비교
   MOV AX, VDECODE[10]
   CMP Y, AX
   JE @SAME_IMM8
   JA @ABOVE_IMM8
   JB @BELOW_IMM8
   JMP @END
   
@SAME_IMM8:
   MOV BX, STATUS_RG
   AND STATUS_RG, 0000000000000000b
   MOV STATUS_RG[0], 00b
   JMP @END
   
@ABOVE_IMM8:
   MOV BX, STATUS_RG
   AND STATUS_RG, 0000000000000000b
   MOV STATUS_RG[0], 01b
   JMP @END
   
@BELOW_IMM8:
   MOV BX, STATUS_RG
   AND STATUS_RG, 0000000000000000b
   MOV STATUS_RG[0], 10b
   JMP @END
   RET
IMMEDIATE_Y ENDP

;------------------------------------------------
;Procedure Name : REG_INDIR_A
;Function : A REGISTER의 CMP 명령어, REGSTER INDIRECT모드기능을 구현
;PROGRAMED BY 하영래
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
REG_INDIR_A PROC		; REGSTER INDIRECT모드 일때 A와 비교
   CMP VDECODE[8], 1110b
   JE @SI1
   CMP VDECODE[8], 1111b
   JE @DI1
   JMP @END
@SI1:
   MOV SI, X[0]
   MOV AX, m[SI]
   CMP A, AX
   JE @SAME_INDIR1
   JA @ABOVE_INDIR1
   JB @BELOW_INDIR1
   JMP @END
   
@DI1:
   MOV SI, X[0]
   MOV AX, m[SI]
   CMP A, AX
   JE @SAME_INDIR1
   JA @ABOVE_INDIR1
   JB @BELOW_INDIR1
   JMP @END
   
@SAME_INDIR1:
   MOV BX, STATUS_RG
   AND STATUS_RG, 0000000000000000b
   MOV STATUS_RG[0], 00b
   JMP @END
   
@ABOVE_INDIR1:
   MOV BX, STATUS_RG
   AND STATUS_RG, 0000000000000000b
   MOV STATUS_RG[0], 01b
   JMP @END
   
@BELOW_INDIR1:
   MOV BX, STATUS_RG
   AND STATUS_RG, 0000000000000000b
   MOV STATUS_RG[0], 10b
   JMP @END
   RET
REG_INDIR_A ENDP
;------------------------------------------------
;Procedure Name : REG_INDIR_B
;Function : B REGISTER의 CMP 명령어, REGSTER INDIRECT모드기능을 구현
;PROGRAMED BY 하영래
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
REG_INDIR_B PROC		; REGSTER INDIRECT모드 일때 B와 비교
   CMP VDECODE[8], 1110b
   JE @SI2
   CMP VDECODE[8], 1111b
   JE @DI2
   JMP @END
@SI2:
   MOV SI, X[0]
   MOV AX, m[SI]
   CMP B, AX
   JE @SAME_INDIR2
   JA @ABOVE_INDIR2
   JB @BELOW_INDIR2
   JMP @END
   
@DI2:
   MOV SI, X[0]
   MOV AX, m[SI]
   CMP B, AX
   JE @SAME_INDIR2
   JA @ABOVE_INDIR2
   JB @BELOW_INDIR2
   JMP @END
   
@SAME_INDIR2:
   MOV BX, STATUS_RG
   AND STATUS_RG, 0000000000000000b
   MOV STATUS_RG[0], 00b
   JMP @END
   
@ABOVE_INDIR2:
   MOV BX, STATUS_RG
   AND STATUS_RG, 0000000000000000b
   MOV STATUS_RG[0], 01b
   JMP @END
   
@BELOW_INDIR2:
   MOV BX, STATUS_RG
   AND STATUS_RG, 0000000000000000b
   MOV STATUS_RG[0], 10b
   JMP @END
   RET
REG_INDIR_B ENDP

;------------------------------------------------
;Procedure Name : REG_INDIR_C
;Function : C REGISTER의 CMP 명령어, REGSTER INDIRECT모드기능을 구현
;PROGRAMED BY 하영래
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
REG_INDIR_C PROC			; REGSTER INDIRECT모드 일때 C와 비교
   CMP VDECODE[8], 1110b
   JE @SI3
   CMP VDECODE[8], 1111b
   JE @DI3
   JMP @END
@SI3:
   MOV SI, X
   mov b,si
   add b,'0'
   print b
   add c,'0'
   print c
   MOV AX, m[SI]
   CMP C, AX
   JE @SAME_INDIR3
   JA @ABOVE_INDIR3
   JB @BELOW_INDIR3
   JMP @END
   
@DI3:
   MOV SI, X[0]
   MOV AX, m[SI]
   CMP C, AX
   JE @SAME_INDIR3
   JA @ABOVE_INDIR3
   JB @BELOW_INDIR3
   JMP @END
   
@SAME_INDIR3:
   MOV BX, STATUS_RG
   AND STATUS_RG, 0000000000000000b
   MOV STATUS_RG[0], 00b
   JMP @END
   
@ABOVE_INDIR3:
   MOV BX, STATUS_RG
   AND STATUS_RG, 0000000000000000b
   MOV STATUS_RG[0], 01b
   JMP @END
   
@BELOW_INDIR3:
   MOV BX, STATUS_RG
   AND STATUS_RG, 0000000000000000b
   MOV STATUS_RG[0], 10b
   JMP @END
   RET
REG_INDIR_C ENDP
;------------------------------------------------
;Procedure Name : REG_INDIR_D
;Function : D REGISTER의 CMP 명령어, REGSTER INDIRECT모드기능을 구현
;PROGRAMED BY 하영래
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
REG_INDIR_D PROC		; REGSTER INDIRECT모드 일때 D와 비교
   CMP VDECODE[8], 1110b
   JE @SI4
   CMP VDECODE[8], 1111b
   JE @DI4
   JMP @END
@SI4:
   MOV SI, X[0]
   MOV AX, m[SI]
   CMP D, AX
   JE @SAME_INDIR4
   JA @ABOVE_INDIR4
   JB @BELOW_INDIR4
   JMP @END
   
@DI4:
   MOV SI, X[0]
   MOV AX, m[SI]
   CMP D, AX
   JE @SAME_INDIR4
   JA @ABOVE_INDIR4
   JB @BELOW_INDIR4
   JMP @END
   
@SAME_INDIR4:
   MOV BX, STATUS_RG
   AND STATUS_RG, 0000000000000000b
   MOV STATUS_RG[0], 00b
   JMP @END
   
@ABOVE_INDIR4:
   MOV BX, STATUS_RG
   AND STATUS_RG, 0000000000000000b
   MOV STATUS_RG[0], 01b
   JMP @END
   
@BELOW_INDIR4:
   MOV BX, STATUS_RG
   AND STATUS_RG, 0000000000000000b
   MOV STATUS_RG[0], 10b
   JMP @END
   RET
REG_INDIR_D ENDP
;------------------------------------------------
;Procedure Name : REG_INDIR_E
;Function : E REGISTER의 CMP 명령어, REGSTER INDIRECT모드기능을 구현
;PROGRAMED BY 하영래
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
REG_INDIR_E PROC			; REGSTER INDIRECT모드 일때 E와 비교
   CMP VDECODE[8], 1110b
   JE @SI5
   CMP VDECODE[8], 1111b
   JE @DI5
   JMP @END
@SI5:
   MOV SI, X[0]
   MOV AX, m[SI]
   CMP E, AX
   JE @SAME_INDIR5
   JA @ABOVE_INDIR5
   JB @BELOW_INDIR5
   JMP @END
   
@DI5:
   MOV SI, X[0]
   MOV AX, m[SI]
   CMP E, AX
   JE @SAME_INDIR5
   JA @ABOVE_INDIR5
   JB @BELOW_INDIR5
   JMP @END
   
@SAME_INDIR5:
   MOV BX, STATUS_RG
   AND STATUS_RG, 0000000000000000b
   MOV STATUS_RG[0], 00b
   JMP @END
   
@ABOVE_INDIR5:
   MOV BX, STATUS_RG
   AND STATUS_RG, 0000000000000000b
   MOV STATUS_RG[0], 01b
   JMP @END
   
@BELOW_INDIR5:
   MOV BX, STATUS_RG
   AND STATUS_RG, 0000000000000000b
   MOV STATUS_RG[0], 10b
   JMP @END
   RET
REG_INDIR_E ENDP
;------------------------------------------------
;Procedure Name : REG_INDIR_F
;Function : F REGISTER의 CMP 명령어, REGSTER INDIRECT모드기능을 구현
;PROGRAMED BY 하영래
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
REG_INDIR_F PROC			; REGSTER INDIRECT모드 일때 F와 비교
   CMP VDECODE[8], 1110b
   JE @SI6
   CMP VDECODE[8], 1111b
   JE @DI6
   JMP @END
@SI6:
   MOV SI, X[0]
   MOV AX, m[SI]
   CMP F, AX
   JE @SAME_INDIR6
   JA @ABOVE_INDIR6
   JB @BELOW_INDIR6
   JMP @END
   
@DI6:
   MOV SI, X[0]
   MOV AX, m[SI]
   CMP F, AX
   JE @SAME_INDIR6
   JA @ABOVE_INDIR6
   JB @BELOW_INDIR6
   JMP @END
   
@SAME_INDIR6:
   MOV BX, STATUS_RG
   AND STATUS_RG, 0000000000000000b
   MOV STATUS_RG[0], 00b
   JMP @END
   
@ABOVE_INDIR6:
   MOV BX, STATUS_RG
   AND STATUS_RG, 0000000000000000b
   MOV STATUS_RG[0], 01b
   JMP @END
   
@BELOW_INDIR6:
   MOV BX, STATUS_RG
   AND STATUS_RG, 0000000000000000b
   MOV STATUS_RG[0], 10b
   JMP @END
   RET
REG_INDIR_F ENDP
;------------------------------------------------
;Procedure Name : REG_INDIR_X
;Function : X REGISTER의 CMP 명령어, REGSTER INDIRECT모드기능을 구현
;PROGRAMED BY 하영래
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
REG_INDIR_X PROC			; REGSTER INDIRECT모드 일때 X와 비교
   CMP VDECODE[8], 1110b
   JE @SI7
   CMP VDECODE[8], 1111b
   JE @DI7
   JMP @END
@SI7:
   MOV SI, X[0]
   MOV AX, m[SI]
   CMP X, AX
   JE @SAME_INDIR7
   JA @ABOVE_INDIR7
   JB @BELOW_INDIR7
   JMP @END
   
@DI7:
   MOV SI, X[0]
   MOV AX, m[SI]
   CMP X, AX
   JE @SAME_INDIR7
   JA @ABOVE_INDIR7
   JB @BELOW_INDIR7
   JMP @END
   
@SAME_INDIR7:
   MOV BX, STATUS_RG
   AND STATUS_RG, 0000000000000000b
   MOV STATUS_RG[0], 00b
   JMP @END
   
@ABOVE_INDIR7:
   MOV BX, STATUS_RG
   AND STATUS_RG, 0000000000000000b
   MOV STATUS_RG[0], 01b
   JMP @END
   
@BELOW_INDIR7:
   MOV BX, STATUS_RG
   AND STATUS_RG, 0000000000000000b
   MOV STATUS_RG[0], 10b
   JMP @END
   RET
REG_INDIR_X ENDP
;------------------------------------------------
;Procedure Name : REG_INDIR_Y
;Function : Y REGISTER의 CMP 명령어, REGSTER INDIRECT모드기능을 구현
;PROGRAMED BY 하영래
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
REG_INDIR_Y PROC			; REGSTER INDIRECT모드 일때 Y와 비교
   CMP VDECODE[8], 1110b
   JE @SI8
   CMP VDECODE[8], 1111b
   JE @DI8
   JMP @END
@SI8:
   MOV SI, X[0]
   MOV AX, m[SI]
   CMP Y, AX
   JE @SAME_INDIR8
   JA @ABOVE_INDIR8
   JB @BELOW_INDIR8
   JMP @END
   
@DI8:
   MOV SI, X[0]
   MOV AX, m[SI]
   CMP Y, AX
   JE @SAME_INDIR8
   JA @ABOVE_INDIR8
   JB @BELOW_INDIR8
   JMP @END
   
@SAME_INDIR8:
   MOV BX, STATUS_RG
   AND STATUS_RG, 0000000000000000b
   MOV STATUS_RG[0], 00b
   JMP @END
   
@ABOVE_INDIR8:
   MOV BX, STATUS_RG
   AND STATUS_RG, 0000000000000000b
   MOV STATUS_RG[0], 01b
   JMP @END
   
@BELOW_INDIR8:
   MOV BX, STATUS_RG
   AND STATUS_RG, 0000000000000000b
   MOV STATUS_RG[0], 10b
   JMP @END
   RET
REG_INDIR_Y ENDP

;------------------------------------------------
;Procedure Name : DIR_A
;Function : A REGISTER의 CMP 명령어, DIRECT모드기능을 구현
;PROGRAMED BY 하영래
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
DIR_A PROC				; DIRECT모드 일때 A와 비교
   MOV SI, VDECODE[10]
   MOV AX, m[SI]
   CMP A, AX
   JE @SAME_DIR1
   JA @ABOVE_DIR1
   JB @BELOW_DIR1
   JMP @END
   
@SAME_DIR1:
   MOV BX, STATUS_RG
   AND STATUS_RG, 0000000000000000b
   MOV STATUS_RG[0], 00b
   JMP @END
   
@ABOVE_DIR1:
   MOV BX, STATUS_RG
   AND STATUS_RG, 0000000000000000b
   MOV STATUS_RG[0], 01b
   JMP @END
   
@BELOW_DIR1:
   MOV BX, STATUS_RG
   AND STATUS_RG, 0000000000000000b
   MOV STATUS_RG[0], 10b
   JMP @END
   RET
DIR_A ENDP

;------------------------------------------------
;Procedure Name : DIR_B
;Function : B REGISTER의 CMP 명령어, DIRECT모드기능을 구현
;PROGRAMED BY 하영래
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
DIR_B PROC			; DIRECT모드 일때 B와 비교
   MOV SI, VDECODE[10]
   MOV AX, m[SI]
   CMP B, AX
   JE @SAME_DIR2
   JA @ABOVE_DIR2
   JB @BELOW_DIR2
   JMP @END
   
@SAME_DIR2:
   MOV BX, STATUS_RG
   AND STATUS_RG, 0000000000000000b
   MOV STATUS_RG[0], 00b
   JMP @END
   
@ABOVE_DIR2:
   MOV BX, STATUS_RG
   AND STATUS_RG, 0000000000000000b
   MOV STATUS_RG[0], 01b
   JMP @END
   
@BELOW_DIR2:
   MOV BX, STATUS_RG
   AND STATUS_RG, 0000000000000000b
   MOV STATUS_RG[0], 10b
   JMP @END
   RET
DIR_B ENDP

;------------------------------------------------
;Procedure Name : DIR_C
;Function : C REGISTER의 CMP 명령어, DIRECT모드기능을 구현
;PROGRAMED BY 하영래
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
DIR_C PROC				; DIRECT모드 일때 C와 비교
   MOV SI, VDECODE[10]
   MOV AX, m[SI]
   CMP C, AX
   JE @SAME_DIR3
   JA @ABOVE_DIR3
   JB @BELOW_DIR3
   JMP @END
   
@SAME_DIR3:
   MOV BX, STATUS_RG
   AND STATUS_RG, 0000000000000000b
   MOV STATUS_RG[0], 00b
   JMP @END
   
@ABOVE_DIR3:
   MOV BX, STATUS_RG
   AND STATUS_RG, 0000000000000000b
   MOV STATUS_RG[0], 01b
   JMP @END
   
@BELOW_DIR3:
   MOV BX, STATUS_RG
   AND STATUS_RG, 0000000000000000b
   MOV STATUS_RG[0], 10b
   JMP @END
   RET
DIR_C ENDP

;------------------------------------------------
;Procedure Name : DIR_D
;Function : D REGISTER의 CMP 명령어, DIRECT모드기능을 구현
;PROGRAMED BY 하영래
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
DIR_D PROC				; DIRECT모드 일때 D와 비교
   MOV SI, VDECODE[10]
   MOV AX, m[SI]
   CMP D, AX
   JE @SAME_DIR4
   JA @ABOVE_DIR4
   JB @BELOW_DIR4
   JMP @END
   
@SAME_DIR4:
   MOV BX, STATUS_RG
   AND STATUS_RG, 0000000000000000b
   MOV STATUS_RG[0], 00b
   JMP @END
   
@ABOVE_DIR4:
   MOV BX, STATUS_RG
   AND STATUS_RG, 0000000000000000b
   MOV STATUS_RG[0], 01b
   JMP @END
   
@BELOW_DIR4:
   MOV BX, STATUS_RG
   AND STATUS_RG, 0000000000000000b
   MOV STATUS_RG[0], 10b
   JMP @END
   RET
DIR_D ENDP

;------------------------------------------------
;Procedure Name : DIR_E
;Function : E REGISTER의 CMP 명령어, DIRECT모드기능을 구현
;PROGRAMED BY 하영래
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
DIR_E PROC				; DIRECT모드 일때 E와 비교
   MOV SI, VDECODE[10]
   MOV AX, m[SI]
   CMP E, AX
   JE @SAME_DIR5
   JA @ABOVE_DIR5
   JB @BELOW_DIR5
   JMP @END
   
@SAME_DIR5:
   MOV BX, STATUS_RG
   AND STATUS_RG, 0000000000000000b
   MOV STATUS_RG[0], 00b
   JMP @END
   
@ABOVE_DIR5:
   MOV BX, STATUS_RG
   AND STATUS_RG, 0000000000000000b
   MOV STATUS_RG[0], 01b
   JMP @END
   
@BELOW_DIR5:
   MOV BX, STATUS_RG
   AND STATUS_RG, 0000000000000000b
   MOV STATUS_RG[0], 10b
   JMP @END
   RET
DIR_E ENDP

;------------------------------------------------
;Procedure Name : DIR_F
;Function : F REGISTER의 CMP 명령어, DIRECT모드기능을 구현
;PROGRAMED BY 하영래
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
DIR_F PROC				; DIRECT모드 일때 F와 비교
   MOV SI, VDECODE[10]
   MOV AX, m[SI]
   CMP F, AX
   JE @SAME_DIR6
   JA @ABOVE_DIR6
   JB @BELOW_DIR6
   JMP @END
   
@SAME_DIR6:
   MOV BX, STATUS_RG
   AND STATUS_RG, 0000000000000000b
   MOV STATUS_RG[0], 00b
   JMP @END
   
@ABOVE_DIR6:
   MOV BX, STATUS_RG
   AND STATUS_RG, 0000000000000000b
   MOV STATUS_RG[0], 01b
   JMP @END
   
@BELOW_DIR6:
   MOV BX, STATUS_RG
   AND STATUS_RG, 0000000000000000b
   MOV STATUS_RG[0], 10b
   JMP @END
   RET
DIR_F ENDP

;------------------------------------------------
;Procedure Name : DIR_X
;Function : X REGISTER의 CMP 명령어, DIRECT모드기능을 구현
;PROGRAMED BY 하영래
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
DIR_X PROC				; DIRECT모드 일때 X와 비교
   MOV SI, VDECODE[10]
   MOV AX, m[SI]
   CMP X, AX
   JE @SAME_DIR7
   JA @ABOVE_DIR7
   JB @BELOW_DIR7
   JMP @END
   
@SAME_DIR7:
   MOV BX, STATUS_RG
   AND STATUS_RG, 0000000000000000b
   MOV STATUS_RG[0], 00b
   JMP @END
   
@ABOVE_DIR7:
   MOV BX, STATUS_RG
   AND STATUS_RG, 0000000000000000b
   MOV STATUS_RG[0], 01b
   JMP @END
   
@BELOW_DIR7:
   MOV BX, STATUS_RG
   AND STATUS_RG, 0000000000000000b
   MOV STATUS_RG[0], 10b
   JMP @END
   RET
DIR_X ENDP

;------------------------------------------------
;Procedure Name : DIR_Y
;Function : Y REGISTER의 CMP 명령어, DIRECT모드기능을 구현
;PROGRAMED BY 하영래
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
DIR_Y PROC				; DIRECT모드 일때 Y와 비교
   MOV SI, VDECODE[10]
   MOV AX, m[SI]
   CMP Y, AX
   JE @SAME_DIR8
   JA @ABOVE_DIR8
   JB @BELOW_DIR8
   JMP @END
   
@SAME_DIR8:
   MOV BX, STATUS_RG
   AND STATUS_RG, 0000000000000000b
   MOV STATUS_RG[0], 00b
   JMP @END
   
@ABOVE_DIR8:
   MOV BX, STATUS_RG
   AND STATUS_RG, 0000000000000000b
   MOV STATUS_RG[0], 01b
   JMP @END
   
@BELOW_DIR8:
   MOV BX, STATUS_RG
   AND STATUS_RG, 0000000000000000b
   MOV STATUS_RG[0], 10b
   JMP @END
   RET
DIR_Y ENDP

;------------------------------------------------
;Procedure Name : M_CMP
;Function : CMP 명령어 기능을 구현
;PROGRAMED BY 하영래
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
M_CMP PROC				 ; CMP 프로시저
   MOV DX, VDECODE[4]
   MOV AX, VDECODE[8]
   MOV BX, VDECODE[10]
   AND VDECODE[2],11b
   
   CMP VDECODE[2], 00b	 ;REGISTER 방식
   JE @REGISTER
   CMP VDECODE[2], 01b   ;IMMEDIATE 방식
   JE @IMMEDIATE_1
   CMP VDECODE[2], 10b   ;REGISTER INDIRECT 방식
   JE @REG_INDIRECT_1
   CMP VDECODE[2], 11b   ;DIRECT 방식
   JE @DIRECT_1
   JMP @END
   
@REGISTER:
   MOV VDECODE[4], DX
   AND VDECODE[4], 1111b
   
   CMP VDECODE[4], 1000b	;레지스터A
   JE @REGISTER_COMPARE_A
   CMP VDECODE[4], 1001b	;레지스터B
   JE @REGISTER_COMPARE_B
   CMP VDECODE[4], 1010b	;레지스터C
   JE @REGISTER_COMPARE_C
   CMP VDECODE[4], 1011b	;레지스터D
   JE @REGISTER_COMPARE_D
   CMP VDECODE[4], 1100b	;레지스터E
   JE @REGISTER_COMPARE_E
   CMP VDECODE[4], 1101b	;레지스터F
   JE @REGISTER_COMPARE_F
   CMP VDECODE[4], 1110b	;레지스터X
   JE @REGISTER_COMPARE_X
   CMP VDECODE[4], 1111b	;레지스터Y
   JE @REGISTER_COMPARE_Y
   JMP @END
   
@IMMEDIATE_1:
   JMP @IMMEDIATE
   
@REG_INDIRECT_1:
   JMP @REG_INDIRECT_2
   
@DIRECT_1:
   JMP @DIRECT_2

@REGISTER_COMPARE_A:
   CALL COMPARE_A
   JMP @END

@REGISTER_COMPARE_B:
   CALL COMPARE_B
   JMP @END
   
@REGISTER_COMPARE_C:
   CALL COMPARE_C
   JMP @END

@REGISTER_COMPARE_D:
   CALL COMPARE_D
   JMP @END
   
@REGISTER_COMPARE_E:
   CALL COMPARE_E
   JMP @END
   
@REGISTER_COMPARE_F:
   CALL COMPARE_F
   JMP @END
   
@REGISTER_COMPARE_X:
   CALL COMPARE_X
   JMP @END
   
@REGISTER_COMPARE_Y:
   CALL COMPARE_Y   

@REG_INDIRECT_2:
   JMP @REG_INDIRECT
   
@DIRECT_2:
   JMP @DIRECT_3
   
@IMMEDIATE:					;IMMEDIATE 값 비교
   MOV VDECODE[4], DX
   AND VDECODE[4], 1111b
   
   CMP VDECODE[4], 1000b	;레지스터A
   JE @IMMEDIATE_COMPARE_A
   CMP VDECODE[4], 1001b	;레지스터B
   JE @IMMEDIATE_COMPARE_B
   CMP VDECODE[4], 1010b	;레지스터C
   JE @IMMEDIATE_COMPARE_C
   CMP VDECODE[4], 1011b	;레지스터D
   JE @IMMEDIATE_COMPARE_D
   CMP VDECODE[4], 1100b	;레지스터E
   JE @IMMEDIATE_COMPARE_E
   CMP VDECODE[4], 1101b	;레지스터F
   JE @IMMEDIATE_COMPARE_F
   CMP VDECODE[4], 1110b	;레지스터X
   JE @IMMEDIATE_COMPARE_X
   CMP VDECODE[4], 1111b	;레지스터Y
   JE @IMMEDIATE_COMPARE_Y
   JMP @END
   
@IMMEDIATE_COMPARE_A:
   CALL IMMEDIATE_A
   JMP @END
   
@IMMEDIATE_COMPARE_B:
   CALL IMMEDIATE_B
   JMP @END
   
@IMMEDIATE_COMPARE_C:
   CALL IMMEDIATE_C
   JMP @END
   
@IMMEDIATE_COMPARE_D:
   CALL IMMEDIATE_D
   JMP @END
   
@IMMEDIATE_COMPARE_E:
   CALL IMMEDIATE_E
   JMP @END
   
@IMMEDIATE_COMPARE_F:
   CALL IMMEDIATE_F
   JMP @END
   
@IMMEDIATE_COMPARE_X:
   CALL IMMEDIATE_X
   JMP @END
   
@IMMEDIATE_COMPARE_Y:
   CALL IMMEDIATE_Y
   JMP @END

@DIRECT_3:
   JMP @DIRECT

@REG_INDIRECT:				;INDIRECT 값 비교
   MOV VDECODE[8], AX
   AND VDECODE[8], 1111b
   MOV VDECODE[4], DX
   AND VDECODE[4], 1111b
   
   CMP VDECODE[4], 1000b	;레지스터A
   JE @REG_COMPARE_A
   CMP VDECODE[4], 1001b	;레지스터B
   JE @REG_COMPARE_B
   CMP VDECODE[4], 1010b	;레지스터C
   JE @REG_COMPARE_C
   CMP VDECODE[4], 1011b	;레지스터D
   JE @REG_COMPARE_D
   CMP VDECODE[4], 1100b	;레지스터E
   JE @REG_COMPARE_E
   CMP VDECODE[4], 1101b	;레지스터F
   JE @REG_COMPARE_F
   CMP VDECODE[4], 1110b	;레지스터X
   JE @REG_COMPARE_X
   CMP VDECODE[4], 1111b	;레지스터Y
   JE @REG_COMPARE_Y
   JMP @END

@REG_COMPARE_A:
   CALL REG_INDIR_A
   JMP @END
   
@REG_COMPARE_B:
   CALL REG_INDIR_B
   JMP @END
   
@REG_COMPARE_C:
   CALL REG_INDIR_C
   JMP @END
   
@REG_COMPARE_D:
   CALL REG_INDIR_D
   JMP @END
   
@REG_COMPARE_E:
   CALL REG_INDIR_E
   JMP @END
   
@REG_COMPARE_F:
   CALL REG_INDIR_F
   JMP @END
   
@REG_COMPARE_X:
   CALL REG_INDIR_X
   JMP @END
   
@REG_COMPARE_Y:
   CALL REG_INDIR_Y
   JMP @END

@DIRECT:					;DIRECT 값 비교
   MOV VDECODE[10], BX
   MOV VDECODE[4], DX
   AND VDECODE[4], 1111b
   
   CMP VDECODE[4], 1000b	;레지스터A
   JE @DIR_COMPARE_A
   CMP VDECODE[4], 1001b	;레지스터B
   JE @DIR_COMPARE_B
   CMP VDECODE[4], 1010b	;레지스터C
   JE @DIR_COMPARE_C
   CMP VDECODE[4], 1011b	;레지스터D
   JE @DIR_COMPARE_D
   CMP VDECODE[4], 1100b	;레지스터E
   JE @DIR_COMPARE_E
   CMP VDECODE[4], 1101b	;레지스터F
   JE @DIR_COMPARE_F
   CMP VDECODE[4], 1110b	;레지스터X
   JE @DIR_COMPARE_X
   CMP VDECODE[4], 1111b	;레지스터Y
   JE @DIR_COMPARE_Y
   JMP @END
   
@DIR_COMPARE_A:
   CALL   DIR_A
   JMP @END

@DIR_COMPARE_B:
   CALL DIR_B
   JMP @END

@DIR_COMPARE_C:
   CALL DIR_C
   JMP @END

@DIR_COMPARE_D:
   CALL DIR_D
   JMP @END

@DIR_COMPARE_E:
   CALL DIR_E
   JMP @END

@DIR_COMPARE_F:
   CALL DIR_F
   JMP @END

@DIR_COMPARE_X:
   CALL DIR_X
   JMP @END

@DIR_COMPARE_Y:
   CALL DIR_Y
   JMP @END
@END:
   RET
M_CMP ENDP

;------------------------------------------------
;Procedure Name : M_OR
;Function : OR 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27 ,2016
;------------------------------------------------
M_OR PROC
	CMP VDECODE[4],1000b	; OPERAND1이 A일 때
	JE M_OR_A
	CMP VDECODE[4],1001b	; OPERAND1이 B일 때
	JE M_OR_B
	CMP VDECODE[4],1010b	; OPERAND1이 C일 때
	JE M_OR_C				
	CMP VDECODE[4],1011b	; OPERAND1이 D일 때
	JE M_OR_D
	CMP VDECODE[4],1100b	; OPERAND1이 E일 때
	JE M_OR_E
	CMP VDECODE[4],1101b	; OPERAND1이 F일 때
	JE M_OR_F
	CMP VDECODE[4],1110b	; OPERAND1이 X일 때
	JE M_OR_X
	CMP VDECODE[4],1111b	; OPERAND1이 Y일 때
	JE M_OR_Y

	PRINT ERR
	JMP END_M_OR

M_OR_A:
	CALL OR_A_P				; OR_A_P를 호출한다.
	JMP END_M_OR
M_OR_B:
	CALL OR_B_P				; OR_B_P를 호출한다.
	JMP END_M_OR
M_OR_C:
	CALL OR_C_P				; OR_C_P를 호출한다.
	JMP END_M_OR
M_OR_D:
	CALL OR_D_P				; OR_D_P를 호출한다.
	JMP END_M_OR
M_OR_E:
	CALL OR_E_P				; OR_E_P를 호출한다.
	JMP END_M_OR
M_OR_F:
	CALL OR_F_P				; OR_F_P를 호출한다.
	JMP END_M_OR
M_OR_X:
	CALL OR_X_P				; OR_X_P를 호출한다.
	JMP END_M_OR
M_OR_Y:
	CALL OR_Y_P				; OR_Y_P를 호출한다.
	JMP END_M_OR

END_M_OR:
	RET
M_OR ENDP

;------------------------------------------------
;Procedure Name : OR_A_P
;Function : OR A, 를 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27 ,2016
;------------------------------------------------
OR_A_P PROC
   MOV AX, VDECODE[2]
   AND AX,11b
   MOV VDECODE[2],AX
                              ; OR A,
   CMP VDECODE[2],00b			; REGISTER 모드
   JE OR_A_REGI
   CMP VDECODE[2],01b			; IMMEDIATE 모드
   JE OR_A_IMME
   CMP VDECODE[2],10b			; REGISTER-INDIRECT 모드
   JE OR_A_REGI_IMME
   CMP VDECODE[2],11b			; DIRECT 모드
   JE OR_A_DI

   PRINT ERR
   JMP END_M_OR_A_P

OR_A_REGI:
   CALL OR_A_REGI_P				; OR_A_REGI_P 호출	
   JMP END_M_OR_A_P
OR_A_IMME:
   CALL OR_A_IMME_P				; OR_A_IMME_P 호출	
   JMP END_M_OR_A_P
OR_A_REGI_IMME:
   CALL OR_A_REGI_IMME_P				; OR_A_REGI_IMME_P 호출	
   JMP END_M_OR_A_P
OR_A_DI:
   CALL OR_A_DI_P				; OR_A_DI_P 호출	
   JMP END_M_OR_A_P

END_M_OR_A_P:
   RET
OR_A_P ENDP

;------------------------------------------------
;Procedure Name : OR_A_REGI_P
;Function : OR A, REGISTER 를 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27 ,2016
;------------------------------------------------
OR_A_REGI_P PROC                         ; OR A,REGISTER

   MOV AX,VDECODE[8]
   AND AX,1111b
   MOV VDECODE[8],AX

   CMP VDECODE[8],1000b						; OPERAND2가 A
   JE OR_A_A
   CMP VDECODE[8],1001b						; OPERAND2가 B
   JE OR_A_B
   CMP VDECODE[8],1010b						; OPERAND2가 C
   JE OR_A_C
   CMP VDECODE[8],1011b						; OPERAND2가 D
   JE OR_A_D
   CMP VDECODE[8],1100b						; OPERAND2가 E
   JE OR_A_E
   CMP VDECODE[8],1101b						; OPERAND2가 F
   JE OR_A_F
   CMP VDECODE[8],1110b						; OPERAND2가 X
   JE OR_A_X
   CMP VDECODE[8],1111b						; OPERAND2가 Y
   JE OR_A_Y

   PRINT ERR
   JMP END_M_OR_A_REGI_P

OR_A_A:										; OR A,A
	MOV AX,A
	OR A,AX
   JMP END_M_OR_A_REGI_P
OR_A_B:										; OR A,B
	MOV AX,B
	OR A,AX
   JMP END_M_OR_A_REGI_P
OR_A_C:										; OR A,C
	MOV AX,C
	OR A,AX
   JMP END_M_OR_A_REGI_P
OR_A_D:										; OR A,D
	MOV AX,D
	OR A,AX
   JMP END_M_OR_A_REGI_P
OR_A_E:										; OR A,E
	MOV AX,E
	OR A,AX
   JMP END_M_OR_A_REGI_P
OR_A_F:										; OR A,F
	MOV AX,F
	OR A,AX
   JMP END_M_OR_A_REGI_P
OR_A_X:										; OR A,X
	MOV AX,X
	OR A,AX
   JMP END_M_OR_A_REGI_P
OR_A_Y:										; OR A,Y
	MOV AX,Y
	OR A,AX
   JMP END_M_OR_A_REGI_P

END_M_OR_A_REGI_P:
	RET
OR_A_REGI_P ENDP

;------------------------------------------------
;Procedure Name : OR_A_IMME_P
;Function : OR A, IMMEDIATE 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27 ,2016
;------------------------------------------------
OR_A_IMME_P PROC                   ; OR A,IMMEDIATE
   MOV DX,VDECODE[10]				; A와 VDECODE[10]에 저장되어있는 IMMEDIATE 값을 OR
   OR A,DX
   RET
OR_A_IMME_P ENDP

;------------------------------------------------
;Procedure Name : OR_A_REGI_IMME_P
;Function : OR A, REGISTER-INDIRECT 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27 ,2016
;------------------------------------------------
OR_A_REGI_IMME_P PROC                 ; OR A,REGISTER_IMMEDIATE
   CMP VDECODE[8],1110					; OPERAND2 값이 X
   JE OR_A_R_I_X
   CMP VDECODE[8],1111					; OPERAND2 값이 Y
   JE OR_A_R_I_Y
   
OR_A_R_I_X:
   MOV SI,X								; X의 값을 SI에 저장
   MOV DX,M[SI]							; DX에 M[SI]값 저장
   OR A,DX								; A와 DX값 OR
   JMP END_M_OR_A_REGI_IMME_P
OR_A_R_I_Y:
   MOV SI,Y								; Y의 값을 SI에 저장
   MOV DX,M[SI]							; DX에 M[SI]값 저장
   OR A,DX								; A와 DX값 OR

END_M_OR_A_REGI_IMME_P:
   RET
OR_A_REGI_IMME_P ENDP

;------------------------------------------------
;Procedure Name : OR_A_DI_P
;Function : OR A, DIRECT 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27 ,2016
;------------------------------------------------
OR_A_DI_P PROC                     ; OR A,DIRECT
   MOV SI,VDECODE[10]				; SI에 VDECODE[10]에 저장되어있는 주소값을 저장
   MOV DX,M[SI]						; DX에 M[SI]값 저장
   OR A,DX							; A와 DX를 OR
   RET
OR_A_DI_P ENDP

;------------------------------------------------
;Procedure Name : OR_B_P
;Function : OR B, 를 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27 ,2016
;------------------------------------------------
OR_B_P PROC
   MOV AX, VDECODE[2]
   AND AX,11b
   MOV VDECODE[2],AX
                              ; OR B,
   CMP VDECODE[2],00b			; REGISTER 모드
   JE OR_B_REGI
   CMP VDECODE[2],01b			; IMMEDIATE 모드
   JE OR_B_IMME
   CMP VDECODE[2],10b			; REGISTER-INDIRECT 모드
   JE OR_B_REGI_IMME
   CMP VDECODE[2],11b			; DIRECT 모드
   JE OR_B_DI

   PRINT ERR
   JMP END_M_OR_B_P

OR_B_REGI:
   CALL OR_B_REGI_P				; OR_B_REGI_P 호출	
   JMP END_M_OR_B_P
OR_B_IMME:
   CALL OR_B_IMME_P				; OR_B_IMME_P 호출	
   JMP END_M_OR_B_P
OR_B_REGI_IMME:
   CALL OR_B_REGI_IMME_P		; OR_B_REGI_IMME_P 호출
   JMP END_M_OR_B_P
OR_B_DI:
   CALL OR_B_DI_P				; OR_B_DI_P 호출
   JMP END_M_OR_B_P

END_M_OR_B_P:
   RET
OR_B_P ENDP

;------------------------------------------------
;Procedure Name : OR_B_REGI_P
;Function : OR B, REGISTER 를 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27 ,2016
;------------------------------------------------
OR_B_REGI_P PROC                         ; OR B,REGISTER

   MOV AX,VDECODE[8]
   AND AX,1111b
   MOV VDECODE[8],AX

   CMP VDECODE[8],1000b						; OPERAND2가 A
   JE OR_B_A
   CMP VDECODE[8],1001b						; OPERAND2가 B
   JE OR_B_B
   CMP VDECODE[8],1010b						; OPERAND2가 C
   JE OR_B_C
   CMP VDECODE[8],1011b						; OPERAND2가 D
   JE OR_B_D
   CMP VDECODE[8],1100b						; OPERAND2가 E
   JE OR_B_E
   CMP VDECODE[8],1101b						; OPERAND2가 F
   JE OR_B_F
   CMP VDECODE[8],1110b						; OPERAND2가 X
   JE OR_B_X
   CMP VDECODE[8],1111b						; OPERAND2가 Y
   JE OR_B_Y

   PRINT ERR
   JMP END_M_OR_B_REGI_P

OR_B_A:										; OR B,A
	MOV AX,A
	OR B,AX
   JMP END_M_OR_B_REGI_P
OR_B_B:										; OR B,B
	MOV AX,B
	OR B,AX
   JMP END_M_OR_B_REGI_P
OR_B_C:										; OR B,C
	MOV AX,C
	OR B,AX
   JMP END_M_OR_B_REGI_P
OR_B_D:										; OR B,D
	MOV AX,D
	OR B,AX
   JMP END_M_OR_B_REGI_P
OR_B_E:										; OR B,E
	MOV AX,E
	OR B,AX
   JMP END_M_OR_B_REGI_P
OR_B_F:										; OR B,F
	MOV AX,F
	OR B,AX
   JMP END_M_OR_B_REGI_P
OR_B_X:										; OR B,X
	MOV AX,X
	OR B,AX
   JMP END_M_OR_B_REGI_P
OR_B_Y:										; OR B,Y
	MOV AX,Y
	OR B,AX
   JMP END_M_OR_B_REGI_P

END_M_OR_B_REGI_P:
	RET
OR_B_REGI_P ENDP

;------------------------------------------------
;Procedure Name : OR_B_IMME_P
;Function : OR B, IMMEDIATE 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27 ,2016
;------------------------------------------------
OR_B_IMME_P PROC                   ; OR B,IMMEDIATE
   MOV DX,VDECODE[10]				; B와 VDECODE[10]에 저장되어있는 IMMEDIATE 값을 OR
   OR B,DX
   RET
OR_B_IMME_P ENDP

;------------------------------------------------
;Procedure Name : OR_B_REGI_IMME_P
;Function : OR B, REGISTER-INDIRECT 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27 ,2016
;------------------------------------------------
OR_B_REGI_IMME_P PROC                 ; OR B,REGISTER_IMMEDIATE
   CMP VDECODE[8],1110					; OPERAND2 값이 X
   JE OR_B_R_I_X
   CMP VDECODE[8],1111					; OPERAND2 값이 Y
   JE OR_B_R_I_Y
   
OR_B_R_I_X:
   MOV SI,X								; X의 값을 SI에 저장
   MOV DX,M[SI]							; DX에 M[SI]값 저장
   OR B,DX								; B와 DX값 OR
   JMP END_M_OR_B_REGI_IMME_P
OR_B_R_I_Y:
   MOV SI,Y								; Y의 값을 SI에 저장
   MOV DX,M[SI]							; DX에 M[SI]값 저장
   OR B,DX								; B와 DX값 OR

END_M_OR_B_REGI_IMME_P:
   RET
OR_B_REGI_IMME_P ENDP

;------------------------------------------------
;Procedure Name : OR_B_DI_P
;Function : OR A, DIRECT 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27 ,2016
;------------------------------------------------
OR_B_DI_P PROC                     ; OR B,DIRECT
   MOV SI,VDECODE[10]  				; SI에 VDECODE[10]에 저장되어있는 주소값을 저장 
   MOV DX,M[SI]						; DX에 M[SI]값 저장
   OR B,DX							; B와 DX를 OR
   RET
OR_B_DI_P ENDP

;------------------------------------------------
;Procedure Name : OR_C_P
;Function : OR C, 를 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27 ,2016
;------------------------------------------------
OR_C_P PROC
   MOV AX, VDECODE[2]
   AND AX,11b
   MOV VDECODE[2],AX
                              ; OR C,
   CMP VDECODE[2],00b			; REGISTER 모드
   JE OR_C_REGI
   CMP VDECODE[2],01b			; IMMEDIATE 모드
   JE OR_C_IMME
   CMP VDECODE[2],10b			; REGISTER-INDIRECT 모드
   JE OR_C_REGI_IMME
   CMP VDECODE[2],11b			; DIRECT 모드
   JE OR_C_DI

   PRINT ERR
   JMP END_M_OR_C_P

OR_C_REGI:
   CALL OR_C_REGI_P				; OR_C_REGI_P 호출
   JMP END_M_OR_C_P
OR_C_IMME:
   CALL OR_C_IMME_P				; OR_C_IMME_P 호출
   JMP END_M_OR_C_P
OR_C_REGI_IMME:
   CALL OR_C_REGI_IMME_P		; OR_C_REGI_IMME_P 호출
   JMP END_M_OR_C_P
OR_C_DI:
   CALL OR_C_DI_P				; OR_C_DI_P 호출
   JMP END_M_OR_C_P

END_M_OR_C_P:
   RET
OR_C_P ENDP
;------------------------------------------------
;Procedure Name : OR_C_REGI_P
;Function : OR C, REGISTER 를 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27 ,2016
;------------------------------------------------
OR_C_REGI_P PROC                         ; OR C,REGISTER

   MOV AX,VDECODE[8]
   AND AX,1111b
   MOV VDECODE[8],AX

   CMP VDECODE[8],1000b						; OPERAND2가 A
   JE OR_C_A
   CMP VDECODE[8],1001b						; OPERAND2가 B
   JE OR_C_B
   CMP VDECODE[8],1010b						; OPERAND2가 C
   JE OR_C_C
   CMP VDECODE[8],1011b						; OPERAND2가 D
   JE OR_C_D
   CMP VDECODE[8],1100b						; OPERAND2가 E
   JE OR_C_E
   CMP VDECODE[8],1101b						; OPERAND2가 F
   JE OR_C_F
   CMP VDECODE[8],1110b						; OPERAND2가 X
   JE OR_C_X
   CMP VDECODE[8],1111b						; OPERAND2가 Y
   JE OR_C_Y

   PRINT ERR
   JMP END_M_OR_C_REGI_P

OR_C_A:										; OR C,A
	MOV AX,A
	OR C,AX
   JMP END_M_OR_C_REGI_P
OR_C_B:										; OR C,B
	MOV AX,B
	OR C,AX
   JMP END_M_OR_C_REGI_P
OR_C_C:										; OR C,C
	MOV AX,C
	OR C,AX
   JMP END_M_OR_C_REGI_P
OR_C_D:										; OR C,D
	MOV AX,D
	OR C,AX
   JMP END_M_OR_C_REGI_P
OR_C_E:										; OR C,E
	MOV AX,E
	OR C,AX
   JMP END_M_OR_C_REGI_P
OR_C_F:										; OR C,F
	MOV AX,F
	OR C,AX
   JMP END_M_OR_C_REGI_P
OR_C_X:										; OR C,X
	MOV AX,X
	OR C,AX
   JMP END_M_OR_C_REGI_P
OR_C_Y:										; OR C,Y
	MOV AX,Y
	OR C,AX
   JMP END_M_OR_C_REGI_P

END_M_OR_C_REGI_P:
	RET
OR_C_REGI_P ENDP

;------------------------------------------------
;Procedure Name : OR_C_IMME_P
;Function : OR C, IMMEDIATE 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27 ,2016
;------------------------------------------------
OR_C_IMME_P PROC                   ; OR C,IMMEDIATE
   MOV DX,VDECODE[10]				; C와 VDECODE[10]에 저장되어있는 IMMEDIATE 값을 OR
   OR C,DX
   RET
OR_C_IMME_P ENDP

;------------------------------------------------
;Procedure Name : OR_C_REGI_IMME_P
;Function : OR C, REGISTER-INDIRECT 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27 ,2016
;------------------------------------------------
OR_C_REGI_IMME_P PROC                 ; OR C,REGISTER_IMMEDIATE
   CMP VDECODE[8],1110					; OPERAND2 값이 X
   JE OR_C_R_I_X
   CMP VDECODE[8],1111					; OPERAND2 값이 Y
   JE OR_C_R_I_Y
   
OR_C_R_I_X:
   MOV SI,X								; X의 값을 SI에 저장
   MOV DX,M[SI]							; DX에 M[SI]값 저장
   OR C,DX								; C와 DX값 OR
   JMP END_M_OR_C_REGI_IMME_P
OR_C_R_I_Y:
   MOV SI,Y								; Y의 값을 SI에 저장
   MOV DX,M[SI]							; DX에 M[SI]값 저장
   OR C,DX								; C와 DX값 OR

END_M_OR_C_REGI_IMME_P:
   RET
OR_C_REGI_IMME_P ENDP

;------------------------------------------------
;Procedure Name : OR_C_DI_P
;Function : OR C, DIRECT 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27 ,2016
;------------------------------------------------
OR_C_DI_P PROC                     ; OR C,DIRECT
   MOV SI,VDECODE[10]   			; SI에 VDECODE[10]에 저장되어있는 주소값을 저장  
   MOV DX,M[SI]						; DX에 M[SI]값 저장
   OR C,DX							; C와 DX를 OR
   RET
OR_C_DI_P ENDP

;------------------------------------------------
;Procedure Name : OR_D_P
;Function : OR D, 를 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27 ,2016
;------------------------------------------------
OR_D_P PROC
   MOV AX, VDECODE[2]
   AND AX,11b
   MOV VDECODE[2],AX
                              ; OR D,
   CMP VDECODE[2],00b			; REGISTER 모드
   JE OR_D_REGI
   CMP VDECODE[2],01b			; IMMEDIATE 모드
   JE OR_D_IMME
   CMP VDECODE[2],10b			; REGISTER-INDIRECT 모드
   JE OR_D_REGI_IMME
   CMP VDECODE[2],11b			; DIRECT 모드
   JE OR_D_DI

   PRINT ERR
   JMP END_M_OR_D_P

OR_D_REGI:
   CALL OR_D_REGI_P				; OR_D_REGI_P 호출
   JMP END_M_OR_D_P
OR_D_IMME:
   CALL OR_D_IMME_P				; OR_D_IMME_P 호출
   JMP END_M_OR_D_P
OR_D_REGI_IMME:
   CALL OR_D_REGI_IMME_P		; OR_D_REGI_IMME_P 호출
   JMP END_M_OR_D_P
OR_D_DI:
   CALL OR_D_DI_P				; OR_D_DI_P 호출
   JMP END_M_OR_D_P

END_M_OR_D_P:
   RET
OR_D_P ENDP

;------------------------------------------------
;Procedure Name : OR_D_REGI_P
;Function : OR D, REGISTER 를 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27 ,2016
;------------------------------------------------
OR_D_REGI_P PROC                         ; OR D,REGISTER

   MOV AX,VDECODE[8]
   AND AX,1111b
   MOV VDECODE[8],AX

   CMP VDECODE[8],1000b						; OPERAND2가 A
   JE OR_D_A
   CMP VDECODE[8],1001b						; OPERAND2가 B
   JE OR_D_B
   CMP VDECODE[8],1010b						; OPERAND2가 C
   JE OR_D_C
   CMP VDECODE[8],1011b						; OPERAND2가 D
   JE OR_D_D
   CMP VDECODE[8],1100b						; OPERAND2가 E
   JE OR_D_E
   CMP VDECODE[8],1101b						; OPERAND2가 F
   JE OR_D_F
   CMP VDECODE[8],1110b						; OPERAND2가 X
   JE OR_D_X
   CMP VDECODE[8],1111b						; OPERAND2가 Y
   JE OR_D_Y

   PRINT ERR
   JMP END_M_OR_D_REGI_P

OR_D_A:										; OR D,A
	MOV AX,A
	OR D,AX
   JMP END_M_OR_D_REGI_P
OR_D_B:										; OR D,B
	MOV AX,B
	OR D,AX
   JMP END_M_OR_D_REGI_P
OR_D_C:										; OR D,C
	MOV AX,C
	OR D,AX
   JMP END_M_OR_D_REGI_P
OR_D_D:										; OR D,D
	MOV AX,D
	OR D,AX
   JMP END_M_OR_D_REGI_P
OR_D_E:										; OR D,E
	MOV AX,E
	OR D,AX
   JMP END_M_OR_D_REGI_P
OR_D_F:										; OR D,F
	MOV AX,F
	OR D,AX
   JMP END_M_OR_D_REGI_P
OR_D_X:										; OR D,X
	MOV AX,X
	OR D,AX
   JMP END_M_OR_D_REGI_P
OR_D_Y:										; OR D,Y
	MOV AX,Y
	OR D,AX
   JMP END_M_OR_D_REGI_P

END_M_OR_D_REGI_P:
	RET
OR_D_REGI_P ENDP

;------------------------------------------------
;Procedure Name : OR_D_IMME_P
;Function : OR D, IMMEDIATE 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27 ,2016
;------------------------------------------------
OR_D_IMME_P PROC                   ; OR D,IMMEDIATE
   MOV DX,VDECODE[10]				; D와 VDECODE[10]에 저장되어있는 IMMEDIATE 값을 OR
   OR D,DX
   RET
OR_D_IMME_P ENDP

;------------------------------------------------
;Procedure Name : OR_D_REGI_IMME_P
;Function : OR D, REGISTER-INDIRECT 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27 ,2016
;------------------------------------------------
OR_D_REGI_IMME_P PROC                 ; OR D,REGISTER_IMMEDIATE
   CMP VDECODE[8],1110					; OPERAND2 값이 X
   JE OR_D_R_I_X
   CMP VDECODE[8],1111					; OPERAND2 값이 Y
   JE OR_D_R_I_Y
   
OR_D_R_I_X:
   MOV SI,X								; X의 값을 SI에 저장
   MOV DX,M[SI]							; DX에 M[SI]값 저장
   OR D,DX								; D와 DX값 OR
   JMP END_M_OR_D_REGI_IMME_P
OR_D_R_I_Y:
   MOV SI,Y								; Y의 값을 SI에 저장
   MOV DX,M[SI]							; DX에 M[SI]값 저장
   OR D,DX								; D와 DX값 OR

END_M_OR_D_REGI_IMME_P:
   RET
OR_D_REGI_IMME_P ENDP

;------------------------------------------------
;Procedure Name : OR_D_DI_P
;Function : OR D, DIRECT 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27 ,2016
;------------------------------------------------
OR_D_DI_P PROC                     ; OR D,DIRECT
   MOV SI,VDECODE[10]    			; SI에 VDECODE[10]에 저장되어있는 주소값을 저장    
   MOV DX,M[SI]						; DX에 M[SI]값 저장
   OR D,DX							; D와 DX를 OR
   RET
OR_D_DI_P ENDP

;------------------------------------------------
;Procedure Name : OR_E_P
;Function : OR E, 를 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27 ,2016
;------------------------------------------------
OR_E_P PROC
   MOV AX, VDECODE[2]
   AND AX,11b
   MOV VDECODE[2],AX
                              ; OR E,
   CMP VDECODE[2],00b			; REGISTER 모드
   JE OR_E_REGI
   CMP VDECODE[2],01b			; IMMEDIATE 모드
   JE OR_E_IMME
   CMP VDECODE[2],10b			; REGISTER-INDIRECT 모드
   JE OR_E_REGI_IMME
   CMP VDECODE[2],11b			; DIRECT 모드
   JE OR_E_DI

   PRINT ERR
   JMP END_M_OR_E_P

OR_E_REGI:
   CALL OR_E_REGI_P				; OR_E_REGI_P 호출
   JMP END_M_OR_E_P
OR_E_IMME:
   CALL OR_E_IMME_P				; OR_E_IMME_P 호출
   JMP END_M_OR_E_P
OR_E_REGI_IMME:
   CALL OR_E_REGI_IMME_P		; OR_E_REGI_IMME_P 호출
   JMP END_M_OR_E_P
OR_E_DI:
   CALL OR_E_DI_P				; OR_E_DI_P 호출
   JMP END_M_OR_E_P

END_M_OR_E_P:
   RET
OR_E_P ENDP

;------------------------------------------------
;Procedure Name : OR_E_REGI_P
;Function : OR E, REGISTER 를 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27 ,2016
;------------------------------------------------
OR_E_REGI_P PROC                         ; OR E,REGISTER

   MOV AX,VDECODE[8]
   AND AX,1111b
   MOV VDECODE[8],AX

   CMP VDECODE[8],1000b						; OPERAND2가 A
   JE OR_E_A
   CMP VDECODE[8],1001b						; OPERAND2가 B
   JE OR_E_B
   CMP VDECODE[8],1010b						; OPERAND2가 C
   JE OR_E_C
   CMP VDECODE[8],1011b						; OPERAND2가 D
   JE OR_E_D
   CMP VDECODE[8],1100b						; OPERAND2가 E
   JE OR_E_E
   CMP VDECODE[8],1101b						; OPERAND2가 F
   JE OR_E_F
   CMP VDECODE[8],1110b						; OPERAND2가 X
   JE OR_E_X
   CMP VDECODE[8],1111b						; OPERAND2가 Y
   JE OR_E_Y

   PRINT ERR
   JMP END_M_OR_E_REGI_P

OR_E_A:										; OR E,A
	MOV AX,A
	OR E,AX
   JMP END_M_OR_E_REGI_P
OR_E_B:										; OR E,B
	MOV AX,B
	OR E,AX
   JMP END_M_OR_E_REGI_P
OR_E_C:										; OR E,C
	MOV AX,C
	OR E,AX
   JMP END_M_OR_E_REGI_P
OR_E_D:										; OR E,D
	MOV AX,D
	OR E,AX
   JMP END_M_OR_E_REGI_P
OR_E_E:										; OR E,E
	MOV AX,E
	OR E,AX
   JMP END_M_OR_E_REGI_P
OR_E_F:										; OR E,F
	MOV AX,F
	OR E,AX
   JMP END_M_OR_E_REGI_P
OR_E_X:										; OR E,X
	MOV AX,X
	OR E,AX
   JMP END_M_OR_E_REGI_P
OR_E_Y:										; OR E,Y
	MOV AX,Y
	OR E,AX
   JMP END_M_OR_E_REGI_P

END_M_OR_E_REGI_P:
	RET
OR_E_REGI_P ENDP

;------------------------------------------------
;Procedure Name : OR_E_IMME_P
;Function : OR E, IMMEDIATE 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27 ,2016
;------------------------------------------------
OR_E_IMME_P PROC                   ; OR E,IMMEDIATE
   MOV DX,VDECODE[10]				; E와 VDECODE[10]에 저장되어있는 IMMEDIATE 값을 OR
   OR D,DX
   RET
OR_E_IMME_P ENDP

;------------------------------------------------
;Procedure Name : OR_E_REGI_IMME_P
;Function : OR E, REGISTER-INDIRECT 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27 ,2016
;------------------------------------------------
OR_E_REGI_IMME_P PROC                 ; OR E,REGISTER_IMMEDIATE
   CMP VDECODE[8],1110					; OPERAND2 값이 X
   JE OR_E_R_I_X
   CMP VDECODE[8],1111					; OPERAND2 값이 Y
   JE OR_E_R_I_Y
   
OR_E_R_I_X:
   MOV SI,X								; X의 값을 SI에 저장
   MOV DX,M[SI]							; DX에 M[SI]값 저장
   OR E,DX								; E와 DX값 OR
   JMP END_M_OR_E_REGI_IMME_P
OR_E_R_I_Y:
   MOV SI,Y								; Y의 값을 SI에 저장
   MOV DX,M[SI]							; DX에 M[SI]값 저장
   OR E,DX								; E와 DX값 OR

END_M_OR_E_REGI_IMME_P:
   RET
OR_E_REGI_IMME_P ENDP

;------------------------------------------------
;Procedure Name : OR_E_DI_P
;Function : OR E, DIRECT 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27 ,2016
;------------------------------------------------
OR_E_DI_P PROC                     ; OR E,DIRECT
   MOV SI,VDECODE[10]    			; SI에 VDECODE[10]에 저장되어있는 주소값을 저장    
   MOV DX,M[SI]						; DX에 M[SI]값 저장
   OR E,DX							; E와 DX를 OR
   RET
OR_E_DI_P ENDP

;------------------------------------------------
;Procedure Name : OR_F_P
;Function : OR F, 를 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27 ,2016
;------------------------------------------------
OR_F_P PROC
   MOV AX, VDECODE[2]
   AND AX,11b
   MOV VDECODE[2],AX
                              ; OR F,
   CMP VDECODE[2],00b			; REGISTER 모드
   JE OR_F_REGI
   CMP VDECODE[2],01b			; IMMEDIATE 모드
   JE OR_F_IMME
   CMP VDECODE[2],10b			; REGISTER-INDIRECT 모드
   JE OR_F_REGI_IMME
   CMP VDECODE[2],11b			; DIRECT 모드
   JE OR_F_DI

   PRINT ERR
   JMP END_M_OR_F_P

OR_F_REGI:
   CALL OR_F_REGI_P				; OR_F_REGI_P 호출
   JMP END_M_OR_F_P
OR_F_IMME:
   CALL OR_F_IMME_P				; OR_F_IMME_P 호출
   JMP END_M_OR_F_P
OR_F_REGI_IMME:
   CALL OR_F_REGI_IMME_P		; OR_F_REGI_IMME_P 호출
   JMP END_M_OR_F_P
OR_F_DI:
   CALL OR_F_DI_P				; OR_F_DI_P 호출
   JMP END_M_OR_F_P

END_M_OR_F_P:
   RET
OR_F_P ENDP

;------------------------------------------------
;Procedure Name : OR_F_REGI_P
;Function : OR F, REGISTER 를 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27 ,2016
;------------------------------------------------
OR_F_REGI_P PROC                         ; OR F,REGISTER

   MOV AX,VDECODE[8]
   AND AX,1111b
   MOV VDECODE[8],AX

   CMP VDECODE[8],1000b						; OPERAND2가 A
   JE OR_F_A
   CMP VDECODE[8],1001b						; OPERAND2가 B
   JE OR_F_B
   CMP VDECODE[8],1010b						; OPERAND2가 C
   JE OR_F_C
   CMP VDECODE[8],1011b						; OPERAND2가 D
   JE OR_F_D
   CMP VDECODE[8],1100b						; OPERAND2가 E
   JE OR_F_E
   CMP VDECODE[8],1101b						; OPERAND2가 F
   JE OR_F_F
   CMP VDECODE[8],1110b						; OPERAND2가 X
   JE OR_F_X
   CMP VDECODE[8],1111b						; OPERAND2가 Y
   JE OR_F_Y

   PRINT ERR
   JMP END_M_OR_F_REGI_P

OR_F_A:										; OR F,A
	MOV AX,A
	OR F,AX
   JMP END_M_OR_F_REGI_P
OR_F_B:										; OR F,B
	MOV AX,B
	OR F,AX
   JMP END_M_OR_F_REGI_P
OR_F_C:										; OR F,C
	MOV AX,C
	OR F,AX
   JMP END_M_OR_F_REGI_P
OR_F_D:										; OR F,D
	MOV AX,D
	OR F,AX
   JMP END_M_OR_F_REGI_P
OR_F_E:										; OR F,E
	MOV AX,E
	OR F,AX
   JMP END_M_OR_F_REGI_P
OR_F_F:										; OR F,F
	MOV AX,F
	OR F,AX
   JMP END_M_OR_F_REGI_P
OR_F_X:										; OR F,X
	MOV AX,X
	OR F,AX
   JMP END_M_OR_F_REGI_P
OR_F_Y:										; OR F,Y
	MOV AX,Y
	OR F,AX
   JMP END_M_OR_F_REGI_P

END_M_OR_F_REGI_P:
	RET
OR_F_REGI_P ENDP


;------------------------------------------------
;Procedure Name : OR_F_IMME_P
;Function : OR F, IMMEDIATE 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27 ,2016
;------------------------------------------------
OR_F_IMME_P PROC                   ; OR F,IMMEDIATE
   MOV DX,VDECODE[10]				; F와 VDECODE[10]에 저장되어있는 IMMEDIATE 값을 OR
   OR F,DX
   RET
OR_F_IMME_P ENDP

;------------------------------------------------
;Procedure Name : OR_F_REGI_IMME_P
;Function : OR F, REGISTER-INDIRECT 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27 ,2016
;------------------------------------------------
OR_F_REGI_IMME_P PROC                 ; OR F,REGISTER_IMMEDIATE
   CMP VDECODE[8],1110					; OPERAND2 값이 X
   JE OR_F_R_I_X
   CMP VDECODE[8],1111					; OPERAND2 값이 Y
   JE OR_F_R_I_Y
   
OR_F_R_I_X:
   MOV SI,X								; X의 값을 SI에 저장
   MOV DX,M[SI]							; DX에 M[SI]값 저장
   OR F,DX								; F와 DX값 OR
   JMP END_M_OR_F_REGI_IMME_P
OR_F_R_I_Y:
   MOV SI,Y								; Y의 값을 SI에 저장
   MOV DX,M[SI]							; DX에 M[SI]값 저장
   OR F,DX								; F와 DX값 OR

END_M_OR_F_REGI_IMME_P:
   RET
OR_F_REGI_IMME_P ENDP

;------------------------------------------------
;Procedure Name : OR_F_DI_P
;Function : OR F, DIRECT 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27 ,2016
;------------------------------------------------
OR_F_DI_P PROC                     ; OR F,DIRECT
   MOV SI,VDECODE[10]    			; SI에 VDECODE[10]에 저장되어있는 주소값을 저장       
   MOV DX,M[SI]						; DX에 M[SI]값 저장
   OR F,DX							; F와 DX를 OR
   RET
OR_F_DI_P ENDP

;------------------------------------------------
;Procedure Name : OR_X_P
;Function : OR X, 를 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27 ,2016
;------------------------------------------------
OR_X_P PROC
   MOV AX, VDECODE[2]
   AND AX,11b
   MOV VDECODE[2],AX
                              ; OR X,
   CMP VDECODE[2],00b			; REGISTER 모드
   JE OR_X_REGI
   CMP VDECODE[2],01b			; IMMEDIATE 모드
   JE OR_X_IMME
   CMP VDECODE[2],10b			; REGISTER-INDIRECT 모드
   JE OR_X_REGI_IMME
   CMP VDECODE[2],11b			; DIRECT 모드
   JE OR_X_DI

   PRINT ERR
   JMP END_M_OR_X_P

OR_X_REGI:
   CALL OR_X_REGI_P				; OR_X_REGI_P 호출
   JMP END_M_OR_X_P
OR_X_IMME:
   CALL OR_X_IMME_P				; OR_X_IMME_P 호출
   JMP END_M_OR_X_P
OR_X_REGI_IMME:
   CALL OR_X_REGI_IMME_P		; OR_X_REGI_IMME_P 호출
   JMP END_M_OR_X_P
OR_X_DI:
   CALL OR_X_DI_P				; OR_X_DI_P 호출
   JMP END_M_OR_X_P

END_M_OR_X_P:
   RET
OR_X_P ENDP

;------------------------------------------------
;Procedure Name : OR_X_REGI_P
;Function : OR X, REGISTER 를 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27 ,2016
;------------------------------------------------
OR_X_REGI_P PROC                         ; OR X,REGISTER

   MOV AX,VDECODE[8]
   AND AX,1111b
   MOV VDECODE[8],AX

   CMP VDECODE[8],1000b						; OPERAND2가 A
   JE OR_X_A
   CMP VDECODE[8],1001b						; OPERAND2가 B
   JE OR_X_B
   CMP VDECODE[8],1010b						; OPERAND2가 C
   JE OR_X_C
   CMP VDECODE[8],1011b						; OPERAND2가 D
   JE OR_X_D
   CMP VDECODE[8],1100b						; OPERAND2가 E
   JE OR_X_E
   CMP VDECODE[8],1101b						; OPERAND2가 F
   JE OR_X_F
   CMP VDECODE[8],1110b						; OPERAND2가 X
   JE OR_X_X
   CMP VDECODE[8],1111b						; OPERAND2가 Y
   JE OR_X_Y

   PRINT ERR
   JMP END_M_OR_X_REGI_P

OR_X_A:										; OR X,A
	MOV AX,A
	OR X,AX
   JMP END_M_OR_X_REGI_P
OR_X_B:										; OR X,B
	MOV AX,B
	OR X,AX
   JMP END_M_OR_X_REGI_P
OR_X_C:										; OR X,C
	MOV AX,C
	OR X,AX
   JMP END_M_OR_X_REGI_P
OR_X_D:										; OR X,D
	MOV AX,D
	OR X,AX
   JMP END_M_OR_X_REGI_P
OR_X_E:										; OR X,E
	MOV AX,E
	OR X,AX
   JMP END_M_OR_X_REGI_P
OR_X_F:										; OR X,F
	MOV AX,F
	OR X,AX
   JMP END_M_OR_X_REGI_P
OR_X_X:										; OR X,X
	MOV AX,X
	OR X,AX
   JMP END_M_OR_X_REGI_P
OR_X_Y:										; OR X,Y
	MOV AX,Y
	OR X,AX
   JMP END_M_OR_X_REGI_P

END_M_OR_X_REGI_P:
	RET
OR_X_REGI_P ENDP

;------------------------------------------------
;Procedure Name : OR_X_IMME_P
;Function : OR X, IMMEDIATE 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27 ,2016
;------------------------------------------------
OR_X_IMME_P PROC                   ; OR X,IMMEDIATE
   MOV DX,VDECODE[10]				; X와 VDECODE[10]에 저장되어있는 IMMEDIATE 값을 OR
   OR X,DX
   RET
OR_X_IMME_P ENDP

;------------------------------------------------
;Procedure Name : OR_X_REGI_IMME_P
;Function : OR X, REGISTER-INDIRECT 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27 ,2016
;------------------------------------------------
OR_X_REGI_IMME_P PROC                 ; OR X,REGISTER_IMMEDIATE
   CMP VDECODE[8],1110					; OPERAND2 값이 X
   JE OR_X_R_I_X
   CMP VDECODE[8],1111					; OPERAND2 값이 Y
   JE OR_X_R_I_Y
   
OR_X_R_I_X:
   MOV SI,X								; X의 값을 SI에 저장
   MOV DX,M[SI]							; DX에 M[SI]값 저장
   OR X,DX								; X와 DX값 OR
   JMP END_M_OR_X_REGI_IMME_P
OR_X_R_I_Y:
   MOV SI,Y								; Y의 값을 SI에 저장
   MOV DX,M[SI]							; DX에 M[SI]값 저장
   OR X,DX								; X와 DX값 OR

END_M_OR_X_REGI_IMME_P:
   RET
OR_X_REGI_IMME_P ENDP

;------------------------------------------------
;Procedure Name : OR_X_DI_P
;Function : OR X, DIRECT 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27 ,2016
;------------------------------------------------
OR_X_DI_P PROC                     ; OR X,DIRECT
   MOV SI,VDECODE[10]     			; SI에 VDECODE[10]에 저장되어있는 주소값을 저장  
   MOV DX,M[SI]						; DX에 M[SI]값 저장
   OR X,DX							; X와 DX를 OR
   RET
OR_X_DI_P ENDP

;------------------------------------------------
;Procedure Name : OR_Y_P
;Function : OR Y, 를 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27 ,2016
;------------------------------------------------
OR_Y_P PROC
   MOV AX, VDECODE[2]
   AND AX,11b
   MOV VDECODE[2],AX
                              ; OR Y,
   CMP VDECODE[2],00b			; REGISTER 모드
   JE OR_Y_REGI
   CMP VDECODE[2],01b			; IMMEDIATE 모드
   JE OR_Y_IMME
   CMP VDECODE[2],10b			; REGISTER-INDIRECT 모드
   JE OR_Y_REGI_IMME
   CMP VDECODE[2],11b			; DIRECT 모드
   JE OR_Y_DI

   PRINT ERR
   JMP END_M_OR_Y_P

OR_Y_REGI:
   CALL OR_Y_REGI_P				; OR_Y_REGI_P 호출
   JMP END_M_OR_Y_P
OR_Y_IMME:
   CALL OR_Y_IMME_P				; OR_Y_IMME_P 호출
   JMP END_M_OR_Y_P
OR_Y_REGI_IMME:
   CALL OR_Y_REGI_IMME_P		; OR_Y_REGI_IMME_P 호출
   JMP END_M_OR_Y_P
OR_Y_DI:
   CALL OR_Y_DI_P				; OR_Y_DI_P 호출
   JMP END_M_OR_Y_P

END_M_OR_Y_P:
   RET
OR_Y_P ENDP

;------------------------------------------------
;Procedure Name : OR__REGI_P
;Function : OR Y, REGISTER 를 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27 ,2016
;------------------------------------------------

OR_Y_REGI_P PROC                         ; OR Y,REGISTER

   MOV AX,VDECODE[8]
   AND AX,1111b
   MOV VDECODE[8],AX

   CMP VDECODE[8],1000b						; OPERAND2가 A
   JE OR_Y_A
   CMP VDECODE[8],1001b						; OPERAND2가 B
   JE OR_Y_B
   CMP VDECODE[8],1010b						; OPERAND2가 C
   JE OR_Y_C
   CMP VDECODE[8],1011b						; OPERAND2가 D
   JE OR_Y_D
   CMP VDECODE[8],1100b						; OPERAND2가 E
   JE OR_Y_E
   CMP VDECODE[8],1101b						; OPERAND2가 F
   JE OR_Y_F
   CMP VDECODE[8],1110b						; OPERAND2가 X
   JE OR_Y_X
   CMP VDECODE[8],1111b						; OPERAND2가 Y
   JE OR_Y_Y

   PRINT ERR
   JMP END_M_OR_Y_REGI_P

OR_Y_A:										; OR Y,A
	MOV AX,A
	OR Y,AX
   JMP END_M_OR_Y_REGI_P
OR_Y_B:										; OR Y,B
	MOV AX,B
	OR Y,AX
   JMP END_M_OR_Y_REGI_P
OR_Y_C:										; OR Y,C
	MOV AX,C
	OR Y,AX
   JMP END_M_OR_Y_REGI_P
OR_Y_D:										; OR Y,D
	MOV AX,D
	OR Y,AX
   JMP END_M_OR_Y_REGI_P
OR_Y_E:										; OR Y,E
	MOV AX,E
	OR Y,AX
   JMP END_M_OR_Y_REGI_P
OR_Y_F:										; OR Y,F
	MOV AX,F
	OR Y,AX
   JMP END_M_OR_Y_REGI_P
OR_Y_X:										; OR Y,X
	MOV AX,X
	OR Y,AX
   JMP END_M_OR_Y_REGI_P
OR_Y_Y:										; OR Y,Y
	MOV AX,Y
	OR Y,AX
   JMP END_M_OR_Y_REGI_P

END_M_OR_Y_REGI_P:
	RET
OR_Y_REGI_P ENDP


;------------------------------------------------
;Procedure Name : OR_Y_IMME_P
;Function : OR Y, IMMEDIATE 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27 ,2016
;------------------------------------------------
OR_Y_IMME_P PROC                   ; OR Y,IMMEDIATE
   MOV DX,VDECODE[10]				; Y와 VDECODE[10]에 저장되어있는 IMMEDIATE 값을 OR
   OR Y,DX
   RET
OR_Y_IMME_P ENDP

;------------------------------------------------
;Procedure Name : OR_Y_REGI_IMME_P
;Function : OR Y, REGISTER-INDIRECT 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27 ,2016
;------------------------------------------------
OR_Y_REGI_IMME_P PROC                 ; OR Y,REGISTER_IMMEDIATE
   CMP VDECODE[8],1110					; OPERAND2 값이 X
   JE OR_Y_R_I_X
   CMP VDECODE[8],1111					; OPERAND2 값이 Y
   JE OR_Y_R_I_Y
   
OR_Y_R_I_X:
   MOV SI,X								; X의 값을 SI에 저장
   MOV DX,M[SI]							; DX에 M[SI]값 저장
   OR Y,DX								; Y와 DX값 OR
   JMP END_M_OR_Y_REGI_IMME_P
OR_Y_R_I_Y:
   MOV SI,Y								; Y의 값을 SI에 저장
   MOV DX,M[SI]							; DX에 M[SI]값 저장
   OR Y,DX								; Y와 DX값 OR

END_M_OR_Y_REGI_IMME_P:
   RET
OR_Y_REGI_IMME_P ENDP

;------------------------------------------------
;Procedure Name : OR_Y_DI_P
;Function : OR Y, DIRECT 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27 ,2016
;------------------------------------------------
OR_Y_DI_P PROC                     ; OR Y,DIRECT
   MOV SI,VDECODE[10]     			; SI에 VDECODE[10]에 저장되어있는 주소값을 저장  
   MOV DX,M[SI]						; DX에 M[SI]값 저장
   OR Y,DX							; Y와 DX를 OR
   RET
OR_Y_DI_P ENDP

;------------------------
;Procedure Name : M_HALT
;Function : HALT 기능을 하는 프로시져
;PROGRAMED BY 하영래
;PROGRAM VERSION
;   Creation Date :Nov 24,2016
;   Last Modified On Nov 25 ,2016
;-----------------------
M_HALT PROC							
@HALT_GO:
   HLT
   JMP @HALT_GO
   RET
M_HALT endp

;------------------------------------------------
;Procedure Name : NOT_R_A
;Function : 레지스터 A를 NOT 하는 프로시져
;PROGRAMED BY 하영래
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
NOT_R_A PROC   ; 레지스터 모드 A
   NOT A
   RET
NOT_R_A ENDP

;------------------------------------------------
;Procedure Name : NOT_R_B
;Function : 레지스터 B를 NOT 하는 프로시져
;PROGRAMED BY 하영래
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
NOT_R_B PROC   ; 레지스터 모드 B
   NOT B
   RET
NOT_R_B ENDP

;------------------------------------------------
;Procedure Name : NOT_R_C
;Function : 레지스터 C를 NOT 하는 프로시져
;PROGRAMED BY 하영래
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
NOT_R_C PROC   ; 레지스터 모드 C
   NOT C
   RET
NOT_R_C ENDP

;------------------------------------------------
;Procedure Name : NOT_R_D
;Function : 레지스터 D를 NOT 하는 프로시져
;PROGRAMED BY 하영래
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
NOT_R_D PROC   ; 레지스터 모드 D
   NOT D
   RET
NOT_R_D ENDP

;------------------------------------------------
;Procedure Name : NOT_R_E
;Function : 레지스터 E를 NOT 하는 프로시져
;PROGRAMED BY 하영래
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
NOT_R_E PROC   ; 레지스터 모드 E
   NOT E
   RET
NOT_R_E ENDP

;------------------------------------------------
;Procedure Name : NOT_R_F
;Function : 레지스터 F를 NOT 하는 프로시져
;PROGRAMED BY 하영래
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
NOT_R_F PROC   ; 레지스터 모드 F
   NOT F
   RET
NOT_R_F ENDP

;------------------------------------------------
;Procedure Name : NOT_R_X
;Function : 레지스터 X를 NOT 하는 프로시져
;PROGRAMED BY 하영래
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
NOT_R_X PROC   ; 레지스터 모드 X
   NOT X
   RET
NOT_R_X ENDP

;------------------------------------------------
;Procedure Name : NOT_R_Y
;Function : 레지스터 Y를 NOT 하는 프로시져
;PROGRAMED BY 하영래
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
NOT_R_Y PROC   ; 레지스터 모드 Y
   NOT Y
   RET
NOT_R_Y ENDP

;------------------------------------------------
;Procedure Name : NOT_I_X
;Function : 레지스터 X가 가리키는 곳의 값을 NOT 하는 프로시져
;PROGRAMED BY 하영래
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
NOT_I_X PROC      ; INDIRECT 모드 X
   MOV SI, X
   MOV AX, m[SI]
   NOT AX
   MOV m[SI], AX
   RET
NOT_I_X ENDP

;------------------------------------------------
;Procedure Name : NOT_I_Y
;Function : 레지스터 Y가 가리키는 곳의 값을 NOT 하는 프로시져
;PROGRAMED BY 하영래
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
NOT_I_Y PROC      ; INDIRECT 모드 Y
   MOV DI, Y
   MOV AX, m[DI]
   NOT AX
   MOV m[DI], AX
   RET
NOT_I_Y ENDP

;------------------------
;Procedure Name : M_NOT
;Function : NOT 기능을 하는 프로시져
;PROGRAMED BY 하영래
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 28 ,2016
;------------------------
M_NOT PROC
   MOV DX, VDECODE[4]
   MOV BX, VDECODE[10]
   AND VDECODE[2],11b
   
   CMP VDECODE[2], 00b   ;REGISTER 방식
   JE @NOT_REGISTER
   CMP VDECODE[2], 01b   ;IMMEDIATE 방식
   JE @NOT_IMMEDIATE_1
   CMP VDECODE[2], 10b   ;REGISTER INDIRECT 방식
   JE @NOT_REG_INDIRECT_1
   CMP VDECODE[2], 11b   ;DIRECT 방식
   JE @NOT_DIRECT_1
   JMP @ENDN
   
@NOT_REGISTER:   ;REGISTER 방식
   MOV VDECODE[4], DX
   AND VDECODE[4], 1111b
   
   CMP VDECODE[4], 1000b ;레지스터A
   JE @REGISTER_NOT_A
   CMP VDECODE[4], 1001b ;레지스터B
   JE @REGISTER_NOT_B
   CMP VDECODE[4], 1010b ;레지스터C
   JE @REGISTER_NOT_C
   CMP VDECODE[4], 1011b ;레지스터D
   JE @REGISTER_NOT_D
   CMP VDECODE[4], 1100b ;레지스터E
   JE @REGISTER_NOT_E
   CMP VDECODE[4], 1101b ;레지스터F
   JE @REGISTER_NOT_F
   CMP VDECODE[4], 1110b ;레지스터X
   JE @REGISTER_NOT_X
   CMP VDECODE[4], 1111b ;레지스터Y
   JE @REGISTER_NOT_Y
   JMP @ENDN
   
@NOT_IMMEDIATE_1:
   JMP @NOT_IMMEDIATE
   
@NOT_REG_INDIRECT_1:
   JMP @NOT_REG_INDIRECT
   
@NOT_DIRECT_1:
   JMP @NOT_DIRECT_2

@REGISTER_NOT_A:
   CALL NOT_R_A					;NOT_R_A 호출
   JMP @ENDN
@REGISTER_NOT_B:
   CALL   NOT_R_B					;NOT_R_B 호출
   JMP @ENDN
@REGISTER_NOT_C:
   CALL   NOT_R_C					;NOT_R_C 호출
   JMP @ENDN
@REGISTER_NOT_D:   
   CALL   NOT_R_D					;NOT_R_D 호출
   JMP @ENDN
@REGISTER_NOT_E:   
   CALL   NOT_R_E					;NOT_R_E 호출
   JMP @ENDN
@REGISTER_NOT_F:
   CALL   NOT_R_F					;NOT_R_F 호출
   JMP @ENDN
@REGISTER_NOT_X:
   CALL   NOT_R_X					;NOT_R_X 호출
   JMP @ENDN
@REGISTER_NOT_Y:
   CALL   NOT_R_Y					;NOT_R_Y 호출
   JMP @ENDN
   
@NOT_IMMEDIATE:   ;IMMEDIATE 방식
   JMP @ENDN

@NOT_DIRECT_2:
   JMP @NOT_DIRECT

@NOT_REG_INDIRECT:   ;REGISTER INDIRECT 방식
   MOV VDECODE[4], DX
   AND VDECODE[4], 1111b

   CMP VDECODE[4], 1110b ;레지스터X
   JE @NOT_INDIRECT_X
   CMP VDECODE[4], 1111b ;레지스터Y
   JE @NOT_INDIRECT_Y
   JMP @ENDN

@NOT_INDIRECT_X:
   CALL NOT_I_X					; NOT_I_X 호출
   
   JMP @ENDN
@NOT_INDIRECT_Y:
   CALL NOT_I_Y					; NOT_I_Y 호출
   JMP @ENDN
   
@NOT_DIRECT:   ;DIRECT 방식
@ENDN:
   RET
M_NOT ENDP

;------------------------------------------------
;Procedure Name : M_AND
;Function : AND 기능을 구현
;PROGRAMED BY 정태영
;PROGRAM VERSION
;   Creation Date :Nov 24,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
M_AND PROC
;AND 명령어
;모드 구별
   cmp VDECODE[2], 00b      ;register 모드
   je M_AND_REGISTER
   cmp VDECODE[2], 01b      ;immediate 모드
   je M_AND_IMMEDIATE1
   cmp VDECODE[2], 10b      ;indirect 모드
   je M_AND_INDIRECT1
   cmp VDECODE[2], 11b      ;direct 모드
   je M_AND_DIRECT1
   jmp M_AND_END         ;M_AND 종료
   
M_AND_REGISTER:            ;register 모드
   cmp VDECODE[4], 1000b      ;operand1이 A
   je M_AND_REGISTER_A
   cmp VDECODE[4], 1001b      ;operand1이 B
   je M_AND_REGISTER_B1
   cmp VDECODE[4], 1010b      ;operand1이 C
   je M_AND_REGISTER_C1
   cmp VDECODE[4], 1011b      ;operand1이 D
   je M_AND_REGISTER_D1
   cmp VDECODE[4], 1100b      ;operand1이 E
   je M_AND_REGISTER_E1
   cmp VDECODE[4], 1101b      ;operand1이 F
   je M_AND_REGISTER_F1
   cmp VDECODE[4], 1110b      ;operand1이 X
   je M_AND_REGISTER_X1
   cmp VDECODE[4], 1111b      ;operand1이 Y
   je M_AND_REGISTER_Y1
   jmp M_AND_END         ;M_AND 종료
   
;Immediate, Indirect, Register모드 분기점으로 점프할 때
;점프범위 오류해결을 위해 점프 거리를 나눠서 분기
M_AND_IMMEDIATE1:
jmp M_AND_IMMEDIATE2   
M_AND_INDIRECT1:
jmp M_AND_INDIRECT2
M_AND_DIRECT1:
jmp M_AND_DIRECT2
M_AND_REGISTER_B1:
jmp M_AND_REGISTER_B
M_AND_REGISTER_C1:
jmp M_AND_REGISTER_C
M_AND_REGISTER_D1:
jmp M_AND_REGISTER_D
M_AND_REGISTER_E1:
jmp M_AND_REGISTER_E
M_AND_REGISTER_F1:
jmp M_AND_REGISTER_F
M_AND_REGISTER_X1:
jmp M_AND_REGISTER_X
M_AND_REGISTER_Y1:
jmp M_AND_REGISTER_Y
   
M_AND_REGISTER_A:         ;register 모드이고 operand1이 A일때
   cmp VDECODE[8], 1000b      ;operand2이 A
   je M_AND_A_A
   cmp VDECODE[8], 1001b      ;operand2이 B
   je M_AND_A_B
   cmp VDECODE[8], 1010b      ;operand2이 C
   je M_AND_A_C
   cmp VDECODE[8], 1011b      ;operand2이 D
   je M_AND_A_D
   cmp VDECODE[8], 1100b      ;operand2이 E
   je M_AND_A_E
   cmp VDECODE[8], 1101b      ;operand2이 F
   je M_AND_A_F
   cmp VDECODE[8], 1110b      ;operand2이 X
   je M_AND_A_X
   cmp VDECODE[8], 1111b      ;operand2이 Y
   je M_AND_A_Y
   jmp M_AND_END         ;M_AND 종료

   
M_AND_A_A:               ;AND A, A
   mov bx, A
   call M_AND_A_AND         ;A와 어떤 것을 AND 연산하는 프로시져 콜
   jmp M_AND_END
M_AND_A_B:               ;AND A, B
   mov bx, B
   call M_AND_A_AND
   jmp M_AND_END
M_AND_A_C:               ;AND A, C
   mov bx, C
   call M_AND_A_AND
   jmp M_AND_END
M_AND_A_D:               ;AND A, D
   mov bx, D
   call M_AND_A_AND
   jmp M_AND_END
M_AND_A_E:               ;AND A, E
   mov bx, E
   call M_AND_A_AND
   jmp M_AND_END
M_AND_A_F:               ;AND A, F
   mov bx, F
   call M_AND_A_AND
   jmp M_AND_END
M_AND_A_X:               ;AND A, X
   mov bx, X
   call M_AND_A_AND
   jmp M_AND_END
M_AND_A_Y:               ;AND A, Y
   mov bx, Y
   call M_AND_A_AND
   jmp M_AND_END
   
   
M_AND_REGISTER_B:         ;register 모드이고 operand1이 B일때
   cmp VDECODE[8], 1000b      ;operand2이 A
   je M_AND_B_A
   cmp VDECODE[8], 1001b      ;operand2이 B
   je M_AND_B_B
   cmp VDECODE[8], 1010b      ;operand2이 C
   je M_AND_B_C
   cmp VDECODE[8], 1011b      ;operand2이 D
   je M_AND_B_D
   cmp VDECODE[8], 1100b      ;operand2이 E
   je M_AND_B_E
   cmp VDECODE[8], 1101b      ;operand2이 F
   je M_AND_B_F
   cmp VDECODE[8], 1110b      ;operand2이 X
   je M_AND_B_X
   cmp VDECODE[8], 1111b      ;operand2이 Y
   je M_AND_B_Y
   jmp M_AND_END         ;M_AND 종료
   
;점프범위 오류해결을 위해 점프 거리를 나눠서 분기  
M_AND_IMMEDIATE2:
jmp M_AND_IMMEDIATE3   
M_AND_INDIRECT2:
jmp M_AND_INDIRECT3
M_AND_DIRECT2:
jmp M_AND_DIRECT3
   
M_AND_B_A:               ;AND B, A
   mov bx, A
   call M_AND_B_AND         ;B와 어떤 것을 AND 연산하는 프로시져 콜
   jmp M_AND_END
M_AND_B_B:               ;AND B, B
   mov bx, B
   call M_AND_B_AND
   jmp M_AND_END
M_AND_B_C:               ;AND B, C
   mov bx, C
   call M_AND_B_AND
   jmp M_AND_END
M_AND_B_D:               ;AND B, D
   mov bx, D
   call M_AND_B_AND
   jmp M_AND_END
M_AND_B_E:               ;AND B, E
   mov bx, E
   call M_AND_B_AND
   jmp M_AND_END
M_AND_B_F:               ;AND B, F
   mov bx, F
   call M_AND_B_AND
   jmp M_AND_END
M_AND_B_X:               ;AND B, X
   mov bx, X
   call M_AND_B_AND
   jmp M_AND_END
M_AND_B_Y:               ;AND B, Y
   mov bx, Y
   call M_AND_B_AND
   jmp M_AND_END
   
M_AND_REGISTER_C:         ;register 모드이고 operand1이 C일때
   cmp VDECODE[8], 1000b      ;operand2이 A
   je M_AND_C_A
   cmp VDECODE[8], 1001b      ;operand2이 B
   je M_AND_C_B
   cmp VDECODE[8], 1010b      ;operand2이 C
   je M_AND_C_C
   cmp VDECODE[8], 1011b      ;operand2이 D
   je M_AND_C_D
   cmp VDECODE[8], 1100b      ;operand2이 E
   je M_AND_C_E
   cmp VDECODE[8], 1101b      ;operand2이 F
   je M_AND_C_F
   cmp VDECODE[8], 1110b      ;operand2이 X
   je M_AND_C_X
   cmp VDECODE[8], 1111b      ;operand2이 Y
   je M_AND_C_Y
   jmp M_AND_END         ;M_AND 종료
   
;점프범위 오류해결을 위해 점프 거리를 나눠서 분기   
M_AND_IMMEDIATE3:
jmp M_AND_IMMEDIATE4
M_AND_INDIRECT3:
jmp M_AND_INDIRECT4
M_AND_DIRECT3:
jmp M_AND_DIRECT4
   
M_AND_C_A:               ;AND C, A
   mov bx, A
   call M_AND_C_AND         ;C와 어떤 것을 AND 연산하는 프로시져 콜
   jmp M_AND_END
M_AND_C_B:               ;AND C, B
   mov bx, B
   call M_AND_C_AND
   jmp M_AND_END
M_AND_C_C:               ;AND C, C
   mov bx, C
   call M_AND_C_AND
   jmp M_AND_END
M_AND_C_D:               ;AND C, D
   mov bx, D
   call M_AND_C_AND
   jmp M_AND_END
M_AND_C_E:               ;AND C, E
   mov bx, E
   call M_AND_C_AND
   jmp M_AND_END
M_AND_C_F:               ;AND C, F
   mov bx, F
   call M_AND_C_AND
   jmp M_AND_END
M_AND_C_X:               ;AND C, X
   mov bx, X
   call M_AND_C_AND
   jmp M_AND_END
M_AND_C_Y:               ;AND C, Y
   mov bx, Y
   call M_AND_C_AND
   jmp M_AND_END
   
M_AND_REGISTER_D:         ;register 모드이고 operand1이 D일때
   cmp VDECODE[8], 1000b      ;operand2이 A
   je M_AND_D_A
   cmp VDECODE[8], 1001b      ;operand2이 B
   je M_AND_D_B
   cmp VDECODE[8], 1010b      ;operand2이 C
   je M_AND_D_C
   cmp VDECODE[8], 1011b      ;operand2이 D
   je M_AND_D_D
   cmp VDECODE[8], 1100b      ;operand2이 E
   je M_AND_D_E
   cmp VDECODE[8], 1101b      ;operand2이 F
   je M_AND_D_F
   cmp VDECODE[8], 1110b      ;operand2이 X
   je M_AND_D_X
   cmp VDECODE[8], 1111b      ;operand2이 Y
   je M_AND_D_Y
   jmp M_AND_END         ;M_AND 종료
   
;점프범위 오류해결을 위해 점프 거리를 나눠서 분기   
M_AND_IMMEDIATE4:
jmp M_AND_IMMEDIATE5   
M_AND_INDIRECT4:
jmp M_AND_INDIRECT5
M_AND_DIRECT4:
jmp M_AND_DIRECT5
   
M_AND_D_A:               ;AND D, A
   mov bx, A
   call M_AND_D_AND         ;D와 어떤 것을 AND 연산하는 프로시져 콜
   jmp M_AND_END
M_AND_D_B:               ;AND D, B
   mov bx, B
   call M_AND_D_AND
   jmp M_AND_END
M_AND_D_C:               ;AND D, C
   mov bx, C
   call M_AND_D_AND
   jmp M_AND_END
M_AND_D_D:               ;AND D, D
   mov bx, D
   call M_AND_D_AND
   jmp M_AND_END
M_AND_D_E:               ;AND D, E
   mov bx, E
   call M_AND_D_AND
   jmp M_AND_END
M_AND_D_F:               ;AND D, F
   mov bx, F
   call M_AND_D_AND
   jmp M_AND_END
M_AND_D_X:               ;AND D, X
   mov bx, X
   call M_AND_D_AND
   jmp M_AND_END
M_AND_D_Y:               ;AND D, Y
   mov bx, Y
   call M_AND_D_AND
   jmp M_AND_END
M_AND_REGISTER_E:         ;register 모드이고 operand1이 E일때
   cmp VDECODE[8], 1000b      ;operand2이 A
   je M_AND_E_A
   cmp VDECODE[8], 1001b      ;operand2이 B
   je M_AND_E_B
   cmp VDECODE[8], 1010b      ;operand2이 C
   je M_AND_E_C
   cmp VDECODE[8], 1011b      ;operand2이 D
   je M_AND_E_D
   cmp VDECODE[8], 1100b      ;operand2이 E
   je M_AND_E_E
   cmp VDECODE[8], 1101b      ;operand2이 F
   je M_AND_E_F
   cmp VDECODE[8], 1110b      ;operand2이 X
   je M_AND_E_X
   cmp VDECODE[8], 1111b      ;operand2이 Y
   je M_AND_E_Y
   jmp M_AND_END         ;M_AND 종료
   
;점프범위 오류해결을 위해 점프 거리를 나눠서 분기   
M_AND_IMMEDIATE5:
jmp M_AND_IMMEDIATE6
M_AND_INDIRECT5:
jmp M_AND_INDIRECT6
M_AND_DIRECT5:
jmp M_AND_DIRECT6

M_AND_E_A:               ;AND E, A
   mov bx, A
   call M_AND_E_AND         ;E와 어떤 것을 AND 연산하는 프로시져 콜
   jmp M_AND_END
M_AND_E_B:               ;AND E, B
   mov bx, B
   call M_AND_E_AND
   jmp M_AND_END
M_AND_E_C:               ;AND E, C
   mov bx, C
   call M_AND_E_AND
   jmp M_AND_END
M_AND_E_D:               ;AND E, D
   mov bx, D
   call M_AND_E_AND
   jmp M_AND_END
M_AND_E_E:               ;AND E, E
   mov bx, E
   call M_AND_E_AND
   jmp M_AND_END
M_AND_E_F:               ;AND E, F
   mov bx, F
   call M_AND_E_AND
   jmp M_AND_END
M_AND_E_X:               ;AND E, X
   mov bx, X
   call M_AND_E_AND
   jmp M_AND_END
M_AND_E_Y:               ;AND E, Y
   mov bx, Y
   call M_AND_E_AND
   jmp M_AND_END
   
M_AND_REGISTER_F:         ;register 모드이고 operand1이 F일때
   cmp VDECODE[8], 1000b      ;operand2이 A
   je M_AND_F_A
   cmp VDECODE[8], 1001b      ;operand2이 B
   je M_AND_F_B
   cmp VDECODE[8], 1010b      ;operand2이 C
   je M_AND_F_C
   cmp VDECODE[8], 1011b      ;operand2이 D
   je M_AND_F_D
   cmp VDECODE[8], 1100b      ;operand2이 E
   je M_AND_F_E
   cmp VDECODE[8], 1101b      ;operand2이 F
   je M_AND_F_F
   cmp VDECODE[8], 1110b      ;operand2이 X
   je M_AND_F_X
   cmp VDECODE[8], 1111b      ;operand2이 Y
   je M_AND_F_Y
   jmp M_AND_END         ;M_AND 종료
   
;점프범위 오류해결을 위해 점프 거리를 나눠서 분기   
M_AND_IMMEDIATE6:
jmp M_AND_IMMEDIATE7
M_AND_INDIRECT6:
jmp M_AND_INDIRECT7   
M_AND_DIRECT6:
jmp M_AND_DIRECT7
   
M_AND_F_A:               ;AND F, A
   mov bx, A
   call M_AND_F_AND         ;F와 어떤 것을 AND 연산하는 프로시져 콜
   jmp M_AND_END
M_AND_F_B:               ;AND F, B
   mov bx, B
   call M_AND_F_AND
   jmp M_AND_END
M_AND_F_C:               ;AND F, C
   mov bx, C
   call M_AND_F_AND
   jmp M_AND_END
M_AND_F_D:               ;AND F, D
   mov bx, D
   call M_AND_F_AND
   jmp M_AND_END
M_AND_F_E:               ;AND F, E
   mov bx, E
   call M_AND_F_AND
   jmp M_AND_END
M_AND_F_F:               ;AND F, F
   mov bx, F
   call M_AND_F_AND
   jmp M_AND_END
M_AND_F_X:               ;AND F, X
   mov bx, X
   call M_AND_F_AND
   jmp M_AND_END
M_AND_F_Y:               ;AND F, Y
   mov bx, Y
   call M_AND_F_AND
   jmp M_AND_END
   
M_AND_REGISTER_X:         ;register 모드이고 operand1이 X일때
   cmp VDECODE[8], 1000b      ;operand2이 A
   je M_AND_X_A
   cmp VDECODE[8], 1001b      ;operand2이 B
   je M_AND_X_B
   cmp VDECODE[8], 1010b      ;operand2이 C
   je M_AND_X_C
   cmp VDECODE[8], 1011b      ;operand2이 D
   je M_AND_X_D
   cmp VDECODE[8], 1100b      ;operand2이 E
   je M_AND_X_E
   cmp VDECODE[8], 1101b      ;operand2이 F
   je M_AND_X_F
   cmp VDECODE[8], 1110b      ;operand2이 X
   je M_AND_X_X
   cmp VDECODE[8], 1111b      ;operand2이 Y
   je M_AND_X_Y
   jmp M_AND_END         ;M_AND 종료
 
;점프범위 오류해결을 위해 점프 거리를 나눠서 분기 
M_AND_IMMEDIATE7:
jmp M_AND_IMMEDIATE8
M_AND_INDIRECT7:
jmp M_AND_INDIRECT8
M_AND_DIRECT7:
jmp M_AND_DIRECT8
   
M_AND_X_A:               ;AND X, A
   mov bx, A
   call M_AND_X_AND         ;X와 어떤 것을 AND 연산하는 프로시져 콜
   jmp M_AND_END
M_AND_X_B:               ;AND X, B
   mov bx, B
   call M_AND_X_AND
   jmp M_AND_END
M_AND_X_C:               ;AND X, C
   mov bx, C
   call M_AND_X_AND
   jmp M_AND_END
M_AND_X_D:               ;AND X, D
   mov bx, D
   call M_AND_X_AND
   jmp M_AND_END
M_AND_X_E:               ;AND X, E
   mov bx, E
   call M_AND_X_AND
   jmp M_AND_END
M_AND_X_F:               ;AND X, F
   mov bx, F
   call M_AND_X_AND
   jmp M_AND_END
M_AND_X_X:               ;AND X, X
   mov bx, X
   call M_AND_X_AND
   jmp M_AND_END
M_AND_X_Y:               ;AND X, Y
   mov bx, Y
   call M_AND_X_AND
   jmp M_AND_END
M_AND_REGISTER_Y:         ;register 모드이고 operand1이 Y일때
   cmp VDECODE[8], 1000b      ;operand2이 A
   je M_AND_Y_A
   cmp VDECODE[8], 1001b      ;operand2이 B
   je M_AND_Y_B
   cmp VDECODE[8], 1010b      ;operand2이 C
   je M_AND_Y_C
   cmp VDECODE[8], 1011b      ;operand2이 D
   je M_AND_Y_D
   cmp VDECODE[8], 1100b      ;operand2이 E
   je M_AND_Y_E
   cmp VDECODE[8], 1101b      ;operand2이 F
   je M_AND_Y_F
   cmp VDECODE[8], 1110b      ;operand2이 X
   je M_AND_Y_X
   cmp VDECODE[8], 1111b      ;operand2이 Y
   je M_AND_Y_Y
   jmp M_AND_END         ;M_AND 종료
   
;점프범위 오류해결을 위해 점프 거리를 나눠서 분기
M_AND_IMMEDIATE8:
jmp M_AND_IMMEDIATE
M_AND_INDIRECT8:
jmp M_AND_INDIRECT
M_AND_DIRECT8:
jmp M_AND_DIRECT
   
M_AND_Y_A:               ;AND Y, A
   mov bx, A
   call M_AND_Y_AND         ;Y와 어떤 것을 AND 연산하는 프로시져 콜
   jmp M_AND_END
M_AND_Y_B:               ;AND Y, B
   mov bx, B
   call M_AND_Y_AND
   jmp M_AND_END
M_AND_Y_C:               ;AND Y, C
   mov bx, C
   call M_AND_Y_AND
   jmp M_AND_END
M_AND_Y_D:               ;AND Y, D
   mov bx, D
   call M_AND_Y_AND
   jmp M_AND_END
M_AND_Y_E:               ;AND Y, E
   mov bx, E
   call M_AND_Y_AND
   jmp M_AND_END
M_AND_Y_F:               ;AND Y, F
   mov bx, F
   call M_AND_Y_AND
   jmp M_AND_END
M_AND_Y_X:               ;AND Y, X
   mov bx, X
   call M_AND_Y_AND
   jmp M_AND_END
M_AND_Y_Y:               ;AND Y, Y
   mov bx, Y
   call M_AND_Y_AND
   jmp M_AND_END
   
M_AND_IMMEDIATE:         ;immediate 모드
   cmp VDECODE[4], 1000b      ;operand1이 A
   je M_AND_IMMEDIATE_A
   cmp VDECODE[4], 1001b      ;operand1이 B
   je M_AND_IMMEDIATE_B
   cmp VDECODE[4], 1010b      ;operand1이 C
   je M_AND_IMMEDIATE_C
   cmp VDECODE[4], 1011b      ;operand1이 D
   je M_AND_IMMEDIATE_D
   cmp VDECODE[4], 1100b      ;operand1이 E
   je M_AND_IMMEDIATE_E
   cmp VDECODE[4], 1101b      ;operand1이 F
   je M_AND_IMMEDIATE_F
   cmp VDECODE[4], 1110b      ;operand1이 X
   je M_AND_IMMEDIATE_X
   cmp VDECODE[4], 1111b      ;operand1이 Y
   je M_AND_IMMEDIATE_Y
   jmp M_AND_END         ;M_AND 종료
   
M_AND_IMMEDIATE_A:         ;immediate 모드이고 operand1이 A일때
   mov bx, VDECODE[10]
   call M_AND_A_AND
   jmp M_AND_END
M_AND_IMMEDIATE_B:         ;immediate 모드이고 operand1이 B일때
   mov bx, VDECODE[10]
   call M_AND_B_AND
   jmp M_AND_END
M_AND_IMMEDIATE_C:         ;immediate 모드이고 operand1이 C일때
   mov bx, VDECODE[10]
   call M_AND_C_AND
   jmp M_AND_END
M_AND_IMMEDIATE_D:         ;immediate 모드이고 operand1이 D일때
   mov bx, VDECODE[10]
   call M_AND_D_AND
   jmp M_AND_END
M_AND_IMMEDIATE_E:         ;immediate 모드이고 operand1이 E일때
   mov bx, VDECODE[10]
   call M_AND_E_AND
   jmp M_AND_END
M_AND_IMMEDIATE_F:         ;immediate 모드이고 operand1이 F일때
   mov bx, VDECODE[10]
   call M_AND_F_AND
   jmp M_AND_END
M_AND_IMMEDIATE_X:         ;immediate 모드이고 operand1이 X일때
   mov bx, VDECODE[10]
   call M_AND_X_AND
   jmp M_AND_END
M_AND_IMMEDIATE_Y:         ;immediate 모드이고 operand1이 Y일때
   mov bx, VDECODE[10]
   call M_AND_Y_AND
   jmp M_AND_END
   

M_AND_INDIRECT:            ;Indirect모드
   cmp VDECODE[4], 1000b      ;operand1이 A
   je M_AND_INDIRECT_A
   cmp VDECODE[4], 1001b      ;operand1이 B
   je M_AND_INDIRECT_B
   cmp VDECODE[4], 1010b      ;operand1이 C
   je M_AND_INDIRECT_C1
   cmp VDECODE[4], 1011b      ;operand1이 D
   je M_AND_INDIRECT_D1
   cmp VDECODE[4], 1100b      ;operand1이 E
   je M_AND_INDIRECT_E1
   cmp VDECODE[4], 1101b      ;operand1이 F
   je M_AND_INDIRECT_F1
   cmp VDECODE[4], 1110b      ;operand1이 X
   je M_AND_INDIRECT_X1
   cmp VDECODE[4], 1111b      ;operand1이 Y
   je M_AND_INDIRECT_Y1
   jmp M_AND_END         ;M_AND 종료
   
;점프범위 오류해결을 위해 점프 거리를 나눠서 분기   
M_AND_INDIRECT_C1:
jmp M_AND_INDIRECT_C   
M_AND_INDIRECT_D1:
jmp M_AND_INDIRECT_D   
M_AND_INDIRECT_E1:
jmp M_AND_INDIRECT_E   
M_AND_INDIRECT_F1:
jmp M_AND_INDIRECT_F
M_AND_INDIRECT_X1:
jmp M_AND_INDIRECT_X
M_AND_INDIRECT_Y1:
jmp M_AND_INDIRECT_Y   
   
M_AND_INDIRECT_A:         ;Indirect모드이고 operand1이 A일때
   cmp VDECODE[8], 1110b
   je M_AND_A_ADX            ;operand2가 X
   cmp VDECODE[8], 1111b
   je M_AND_A_ADY            ;operand2가 Y
   jmp M_AND_END         ;M_AND 종료
   
M_AND_A_ADX:            ;AND A, [X]
   mov dx, X
   mov si, dx
   mov bx, m[si]
   call M_AND_A_AND
   jmp M_AND_END
M_AND_A_ADY:            ;AND A, [Y]
   mov dx, Y
   mov di, dx
   mov bx, m[di]
   call M_AND_A_AND
   jmp M_AND_END
   
M_AND_INDIRECT_B:         ;Indirect모드이고 operand1이 B일때
   cmp VDECODE[8], 1110b
   je M_AND_B_ADX            ;operand2가 X
   cmp VDECODE[8], 1111b
   je M_AND_B_ADY            ;operand2가 Y
   jmp M_AND_END
   
M_AND_B_ADX:            ;AND B, [X]
   mov dx, X
   mov si, dx
   mov bx, m[si]
   call M_AND_B_AND
   jmp M_AND_END
M_AND_B_ADY:            ;AND B, [Y]   
   mov dx, Y
   mov di, dx
   mov bx, m[di]
   call M_AND_B_AND
   jmp M_AND_END
   
M_AND_INDIRECT_C:         ;Indirect모드이고 operand1이 C일때
   cmp VDECODE[8], 1110b
   je M_AND_C_ADX            ;operand2가 X
   cmp VDECODE[8], 1111b
   je M_AND_C_ADY            ;operand2가 Y
   jmp M_AND_END
   
M_AND_C_ADX:            ;AND C, [X]
   mov dx, X
   mov si, dx
   mov bx, m[si]
   call M_AND_C_AND
   jmp M_AND_END
M_AND_C_ADY:            ;AND C, [Y] 
   mov dx, Y
   mov di, dx
   mov bx, m[di]
   call M_AND_C_AND
   jmp M_AND_END
   
M_AND_INDIRECT_D:         ;Indirect모드이고 operand1이 D일때
   cmp VDECODE[8], 1110b
   je M_AND_D_ADX            ;operand2가 X
   cmp VDECODE[8], 1111b
   je M_AND_D_ADY            ;operand2가 Y
   jmp M_AND_END
   
M_AND_D_ADX:            ;AND D, [X]
   mov dx, X
   mov si, dx
   mov bx, m[si]
   call M_AND_D_AND
   jmp M_AND_END
M_AND_D_ADY:            ;AND D, [Y]  
   mov dx, Y
   mov di, dx
   mov bx, m[di]
   call M_AND_D_AND
   jmp M_AND_END
   
M_AND_INDIRECT_E:         ;Indirect모드이고 operand1이 E일때
   cmp VDECODE[8], 1110b
   je M_AND_E_ADX            ;operand2가 X
   cmp VDECODE[8], 1111b
   je M_AND_E_ADY            ;operand2가 X
   jmp M_AND_END
   
M_AND_E_ADX:            ;AND E, [X]
   mov dx, X
   mov si, dx
   mov bx, m[si]
   call M_AND_E_AND
   jmp M_AND_END
M_AND_E_ADY:            ;AND E, [Y] 
   mov dx, Y
   mov di, dx
   mov bx, m[di]
   call M_AND_E_AND
   jmp M_AND_END   
   
M_AND_INDIRECT_F:         ;Indirect모드이고 operand1이 F일때
   cmp VDECODE[8], 1110b
   je M_AND_F_ADX            ;operand2가 X
   cmp VDECODE[8], 1111b
   je M_AND_F_ADY            ;operand2가 Y
   jmp M_AND_END
   
M_AND_F_ADX:            ;AND F, [X]
   mov dx, X
   mov si, dx
   mov bx, m[si]
   call M_AND_F_AND
   jmp M_AND_END
M_AND_F_ADY:            ;AND F, [Y]   
   mov dx, Y
   mov di, dx
   mov bx, m[di]
   call M_AND_F_AND
   jmp M_AND_END
   
M_AND_INDIRECT_X:         ;Indirect모드이고 operand1이 X일때
   cmp VDECODE[8], 1110b
   je M_AND_X_ADX            ;operand2가 X
   cmp VDECODE[8], 1111b
   je M_AND_X_ADY            ;operand2가 Y
   jmp M_AND_END
   
M_AND_X_ADX:            ;AND X, [X]
   mov dx, X
   mov si, dx
   mov bx, m[si]
   call M_AND_X_AND
   jmp M_AND_END
M_AND_X_ADY:            ;AND X, [Y]   
   mov dx, Y
   mov di, dx
   mov bx, m[di]
   call M_AND_X_AND
   jmp M_AND_END   
   
M_AND_INDIRECT_Y:         ;Indirect모드이고 operand1이 Y일때
   cmp VDECODE[8], 1110b
   je M_AND_Y_ADX            ;operand2가 X
   cmp VDECODE[8], 1111b
   je M_AND_Y_ADY            ;operand2가 Y
   jmp M_AND_END
   
M_AND_Y_ADX:            ;AND Y, [X]
   mov dx, X
   mov si, dx
   mov bx, m[si]
   call M_AND_Y_AND
   jmp M_AND_END
M_AND_Y_ADY:            ;AND Y, [Y]     
   mov dx, Y
   mov di, dx
   mov bx, m[di]
   call M_AND_Y_AND
   jmp M_AND_END   

M_AND_DIRECT:            ;Direct모드
   cmp VDECODE[4], 1000b      ;operand1이 A
   je M_AND_DIRECT_A
   cmp VDECODE[4], 1001b      ;operand1이 B
   je M_AND_DIRECT_B
   cmp VDECODE[4], 1010b      ;operand1이 C
   je M_AND_DIRECT_C
   cmp VDECODE[4], 1011b      ;operand1이 D
   je M_AND_DIRECT_D
   cmp VDECODE[4], 1100b      ;operand1이 E
   je M_AND_DIRECT_E
   cmp VDECODE[4], 1101b      ;operand1이 F
   je M_AND_DIRECT_F
   cmp VDECODE[4], 1110b      ;operand1이 X
   je M_AND_DIRECT_X
   cmp VDECODE[4], 1111b      ;operand1이 Y
   je M_AND_DIRECT_Y
   jmp M_AND_END
   
M_AND_DIRECT_A:            ;AND A, value
   mov dx, VDECODE[10]
   mov si, dx
   mov bx, m[si]
   call M_AND_A_AND
   jmp M_AND_END
M_AND_DIRECT_B:            ;AND B, value
   mov dx, VDECODE[10]
   mov si, dx
   mov bx, m[si]
   call M_AND_B_AND
   jmp M_AND_END
M_AND_DIRECT_C:            ;AND C, value
   mov dx, VDECODE[10]
   mov si, dx
   mov bx, m[si]
   call M_AND_C_AND
   jmp M_AND_END
M_AND_DIRECT_D:            ;AND D, value
   mov dx, VDECODE[10]
   mov si, dx
   mov bx, m[si]
   call M_AND_D_AND
   jmp M_AND_END
M_AND_DIRECT_E:            ;AND E, value
   mov dx, VDECODE[10]
   mov si, dx
   mov bx, m[si]
   call M_AND_E_AND
   jmp M_AND_END
M_AND_DIRECT_F:            ;AND F, value
   mov dx, VDECODE[10]
   mov si, dx
   mov bx, m[si]
   call M_AND_F_AND
   jmp M_AND_END
M_AND_DIRECT_X:            ;AND X, value
   mov dx, VDECODE[10]
   mov si, dx
   mov bx, m[si]
   call M_AND_X_AND
   jmp M_AND_END
M_AND_DIRECT_Y:            ;AND Y, value
   mov dx, VDECODE[10]
   mov si, dx
   mov bx, m[si]
   call M_AND_Y_AND
   jmp M_AND_END
   
M_AND_END:
   RET
M_AND ENDP

M_AND_A_AND PROC         ;A와 어떤 것을 AND연산하는 프로시져
   mov ax, A
   and ax, bx
   mov A, ax
   RET
M_AND_A_AND ENDP

M_AND_B_AND PROC         ;B와 어떤 것을 AND연산하는 프로시져
   mov ax, B
   and ax, bx
   mov B, ax
   RET
M_AND_B_AND ENDP

M_AND_C_AND PROC         ;C와 어떤 것을 AND연산하는 프로시져
   mov ax, C
   and ax, bx
   mov C, ax
   RET
M_AND_C_AND ENDP

M_AND_D_AND PROC         ;D와 어떤 것을 AND연산하는 프로시져
   mov ax, D
   and ax, bx
   mov D, ax
   RET
M_AND_D_AND ENDP

M_AND_E_AND PROC         ;E와 어떤 것을 AND연산하는 프로시져
   mov ax, E
   and ax, bx
   mov E, ax
   RET
M_AND_E_AND ENDP

M_AND_F_AND PROC         ;F와 어떤 것을 AND연산하는 프로시져
   mov ax, F
   and ax, bx
   mov F, ax
   RET
M_AND_F_AND ENDP

M_AND_X_AND PROC         ;X와 어떤 것을 AND연산하는 프로시져
   mov ax, X
   and ax, bx
   mov X, ax
   RET
M_AND_X_AND ENDP

M_AND_Y_AND PROC         ;Y와 어떤 것을 AND연산하는 프로시져
   mov ax, Y
   and ax, bx
   mov Y, ax
   RET
M_AND_Y_AND ENDP

;------------------------------------------------
;Procedure Name : M_MUL
;Function : MUL 명령어 기능을 구현
;PROGRAMED BY 정태영, 정재훈
;PROGRAM VERSION
;   Creation Date :Nov 10,2016
;   Last Modified On Dec 16 ,2016
;------------------------------------------------
M_MUL PROC
;MUL 명령어 구현
   mov dx, VDECODE[4]
   mov ax, VDECODE[8]
   mov bx, VDECODE[2]
   
   and VDECODE[4], 1111b
   mov VDECODE[4], dx
   
   cmp VDECODE[4], 1000b   ;operand1이 A일때
   je M_MUL_A
   cmp VDECODE[4], 1001b   ;operand1이 B일때
   je M_MUL_B1
   cmp VDECODE[4], 1010b   ;operand1이 C일때
   je M_MUL_C1
   cmp VDECODE[4], 1011b   ;operand1이 D일때
   je M_MUL_D1
   cmp VDECODE[4], 1100b   ;operand1이 E일때
   je M_MUL_E1
   cmp VDECODE[4], 1101b   ;operand1이 F일때
   je M_MUL_F1
   cmp VDECODE[4], 1110b   ;operand1이 X일때
   je M_MUL_X1
   cmp VDECODE[4], 1111b   ;operand1이 Y일때
   je M_MUL_Y1
   jmp M_MUL_EXIT   ;M_MUL 종료
   
M_MUL_A:      ;operand1이 A일 때 mulressing mode 비교
   and VDECODE[2], 11b
   mov VDECODE[2], bx
   
   cmp VDECODE[2], 00b      ;Register 모드
   je M_MUL_A_REG
   cmp VDECODE[2], 01b      ;Immediate 모드
   je M_MUL_A_IMME1
   cmp VDECODE[2], 10b      ;Indirect 모드
   je M_MUL_A_INDIRECT
   cmp VDECODE[2], 11b      ;Direct 모드
   je M_MUL_A_DIRECT
   jmp M_MUL_EXIT         ;M_MUL 종료
   
            ;M_MUL_B, C, D, E, F, X, Y까지 점프할 때 
            ;점프범위 오류해결을 위해 점프 거리를 나눠서 분기
M_MUL_B1:
   jmp M_MUL_B2
M_MUL_C1:
   jmp M_MUL_C2
M_MUL_D1:
   jmp M_MUL_D2
M_MUL_E1:
   jmp M_MUL_E2
M_MUL_F1:
   jmp M_MUL_F2
M_MUL_X1:
   jmp M_MUL_X2
M_MUL_Y1:
   jmp M_MUL_Y2
   
M_MUL_A_INDIRECT:         ;operand1이 A이고 INDIRECT모드
   cmp VDECODE[8], 1110b   ;operand1이 A이고 operand2이 X일때
   je M_MUL_A_INDIRECT_X
   cmp VDECODE[8], 1111b   ;operand1이 A이고 operand2이 Y일때
   je M_MUL_A_INDIRECT_Y
M_MUL_A_INDIRECT_X:         ;operand1이 A이고 operand2이 X일때
   mov si, X
   mov bx, m[si]
   call M_MUL_A_REG_SOMETHING   ;A와 어떤 것을 연산하는 프로시져 콜
   jmp M_MUL_A_EXIT            ;M_MUL 종료
M_MUL_A_INDIRECT_Y:            ;operand1이 A이고 operand2이 Y일때
   mov si, Y
   mov bx, m[si]
   call M_MUL_A_REG_SOMETHING
   jmp M_MUL_A_EXIT            ;M_MUL 종료
M_MUL_A_DIRECT:               ;operand1이 A이고 direct 모드일 때
   mov si, VDECODE[10]
   mov bx, m[si]
   call M_MUL_A_REG_SOMETHING
   jmp M_MUL_A_EXIT            ;M_MUL_A 종료

            ;점프범위 오류해결을 위해 점프 거리를 나눠서 분기   
M_MUL_A_IMME1:
   jmp M_MUL_A_IMME   
   
M_MUL_A_REG:         ;operand1이 A이고 operand2가 레지스터일때
   mov VDECODE[8], ax
   
   cmp VDECODE[8], 1000b      ;A
   je M_MUL_A_REG_A
   cmp VDECODE[8], 1001b      ;B
   je M_MUL_A_REG_B
   cmp VDECODE[8], 1010b      ;C
   je M_MUL_A_REG_C
   cmp VDECODE[8], 1011b      ;D
   je M_MUL_A_REG_D
   cmp VDECODE[8], 1100b      ;E
   je M_MUL_A_REG_E
   cmp VDECODE[8], 1101b      ;F
   je M_MUL_A_REG_F
   cmp VDECODE[8], 1110b      ;X
   je M_MUL_A_REG_X
   cmp VDECODE[8], 1111b      ;Y
   je M_MUL_A_REG_Y
   jmp M_MUL_A_EXIT            ;M_MUL 종료
   
;점프범위 오류해결을 위해 점프 거리를 나눠서 분기 
M_MUL_B2:
   jmp M_MUL_B
   
M_MUL_A_REG_A:               ;MUL A, A
   mov bx, A
   call M_MUL_A_REG_SOMETHING
   jmp M_MUL_A_EXIT            ;M_MUL 종료
M_MUL_A_REG_B:               ;MUL A, B
   mov bx, B
   call M_MUL_A_REG_SOMETHING
   jmp M_MUL_A_EXIT            ;M_MUL 종료
M_MUL_A_REG_C:               ;MUL A, C
   mov bx, C
   call M_MUL_A_REG_SOMETHING
   jmp M_MUL_A_EXIT            ;M_MUL 종료
M_MUL_A_REG_D:               ;MUL A, D
   mov bx, D
   call M_MUL_A_REG_SOMETHING
   jmp M_MUL_A_EXIT            ;M_MUL 종료
M_MUL_A_REG_E:               ;MUL A, E
   mov bx, E
   call M_MUL_A_REG_SOMETHING
   jmp M_MUL_A_EXIT            ;M_MUL 종료
M_MUL_A_REG_F:               ;MUL A, F
   mov bx, F
   call M_MUL_A_REG_SOMETHING
   jmp M_MUL_A_EXIT            ;M_MUL 종료
M_MUL_A_REG_X:               ;MUL A, X
   mov bx, X
   call M_MUL_A_REG_SOMETHING
   jmp M_MUL_A_EXIT            ;M_MUL 종료
M_MUL_A_REG_Y:               ;MUL A, Y
   mov bx, Y
   call M_MUL_A_REG_SOMETHING
   jmp M_MUL_A_EXIT            ;M_MUL 종료

M_MUL_A_IMME:               ;operand1이 A이고 immediate 모드일 때
   mov ax, A
   mov bx, VDECODE[10]
   mul bx
   mov A, ax
   
M_MUL_A_EXIT:               ;M_MUL를 종료
   jmp M_MUL_EXIT

M_MUL_B:                  ;operand1이 B일 때 mulressing mode 비교
   cmp VDECODE[2], 00b;Register 모드
   je M_MUL_B_REG
   cmp VDECODE[2], 01b;Immediate 모드
   je M_MUL_B_IMME1
   cmp VDECODE[2], 10b;Indirect 모드
   je M_MUL_B_INDIRECT
   cmp VDECODE[2], 11b;Direct 모드
   je M_MUL_B_DIRECT
   jmp M_MUL_EXIT            ;M_MUL를 종료

M_MUL_B_INDIRECT:            ;operand1이 B이고 INDIRECT모드
   cmp VDECODE[8], 1110b      ;operand1이 B이고 operand2이 X일때
   je M_MUL_B_INDIRECT_X
   cmp VDECODE[8], 1111b      ;operand1이 B이고 operand2이 Y일때
   je M_MUL_B_INDIRECT_Y
M_MUL_B_INDIRECT_X:            ;operand1이 B이고 operand2이 X일때
   mov si, X
   mov bx, m[si]
   call M_MUL_B_REG_SOMETHING   ;B와 어떤 것을 연산하는 프로시져 콜
   jmp M_MUL_B_EXIT            ;M_MUL 종료
M_MUL_B_INDIRECT_Y:            ;operand1이 B이고 operand2이 Y일때 
   mov si, Y
   mov bx, m[si]
   call M_MUL_B_REG_SOMETHING
   jmp M_MUL_B_EXIT            ;M_MUL 종료
M_MUL_B_DIRECT:               ;operand1이 B이고 direct 모드일 때
   mov si, VDECODE[10]
   mov bx, m[si]
   call M_MUL_B_REG_SOMETHING
   jmp M_MUL_B_EXIT            ;M_MUL 종료
  
            ;점프범위 오류해결을 위해 점프 거리를 나눠서 분기   
M_MUL_B_IMME1:
   jmp M_MUL_B_IMME
   
M_MUL_B_REG:            ;operand1이 B이고 operand2가 레지스터일때   
   cmp VDECODE[8], 1000b   ;A
   je M_MUL_B_REG_A
   cmp VDECODE[8], 1001b   ;B
   je M_MUL_B_REG_B
   cmp VDECODE[8], 1010b   ;C
   je M_MUL_B_REG_C
   cmp VDECODE[8], 1011b   ;D
   je M_MUL_B_REG_D
   cmp VDECODE[8], 1100b   ;E
   je M_MUL_B_REG_E
   cmp VDECODE[8], 1101b   ;F
   je M_MUL_B_REG_F
   cmp VDECODE[8], 1110b   ;X
   je M_MUL_B_REG_X
   cmp VDECODE[8], 1111b   ;Y
   je M_MUL_B_REG_Y
   jmp M_MUL_B_EXIT         ;M_MUL 종료
   
            ;점프범위 오류해결을 위해 점프 거리를 나눠서 분기  
M_MUL_C2:
   jmp M_MUL_C
M_MUL_D2:
   jmp M_MUL_D3
M_MUL_E2:
   jmp M_MUL_E3
M_MUL_F2:
   jmp M_MUL_F3
M_MUL_X2:
   jmp M_MUL_X3
M_MUL_Y2:
   jmp M_MUL_Y3
   
M_MUL_B_REG_A:         ;MUL B, A
   mov bx, A
   call M_MUL_B_REG_SOMETHING
   jmp M_MUL_B_EXIT      ;M_MUL 종료
M_MUL_B_REG_B:         ;MUL B, B
   mov bx, B
   call M_MUL_B_REG_SOMETHING
   jmp M_MUL_B_EXIT      ;M_MUL 종료
M_MUL_B_REG_C:         ;MUL B, C
   mov bx, C
   call M_MUL_B_REG_SOMETHING
   jmp M_MUL_B_EXIT      ;M_MUL 종료
M_MUL_B_REG_D:         ;MUL B, D
   mov bx, D
   call M_MUL_B_REG_SOMETHING
   jmp M_MUL_B_EXIT      ;M_MUL 종료
M_MUL_B_REG_E:         ;MUL B, E
   mov bx, E
   call M_MUL_B_REG_SOMETHING
   jmp M_MUL_B_EXIT      ;M_MUL 종료
M_MUL_B_REG_F:         ;MUL B, F
   mov bx, F
   call M_MUL_B_REG_SOMETHING
   jmp M_MUL_B_EXIT      ;M_MUL 종료
M_MUL_B_REG_X:         ;MUL B, X
   mov bx, X
   call M_MUL_B_REG_SOMETHING
   jmp M_MUL_B_EXIT      ;M_MUL 종료
M_MUL_B_REG_Y:         ;MUL B, Y
   mov bx, Y
   call M_MUL_B_REG_SOMETHING
   jmp M_MUL_B_EXIT      ;M_MUL 종료

M_MUL_B_IMME:         ;operand1이 B이고 immediate 모드일 때
   mov ax, B
   mov bx, VDECODE[10]
   mul bx
   mov B, ax
   
M_MUL_B_EXIT:         ;M_MUL 종료
   jmp M_MUL_EXIT

M_MUL_C:      ;operand1이 C일 때 mulressing mode 비교
   cmp VDECODE[2], 00b      ;Register 모드
   je M_MUL_C_REG
   cmp VDECODE[2], 01b      ;Immediate 모드
   je M_MUL_C_IMME1
   cmp VDECODE[2], 10b      ;Indirect 모드
   je M_MUL_C_INDIRECT
   cmp VDECODE[2], 11b      ;Direct 모드
   je M_MUL_C_DIRECT
   jmp M_MUL_EXIT         ;M_MUL 종료

M_MUL_C_INDIRECT:         ;operand1이 C이고 INDIRECT모드
   cmp VDECODE[8], 1110b   ;operand1이 C이고 operand2이 X일때
   je M_MUL_C_INDIRECT_X
   cmp VDECODE[8], 1111b   ;operand1이 C이고 operand2이 Y일때
   je M_MUL_C_INDIRECT_Y
M_MUL_C_INDIRECT_X:         ;operand1이 C이고 operand2이 X일때
   mov si, X
   mov bx, m[si]
   call M_MUL_C_REG_SOMETHING   ;C와 어떤 것을 연산하는 프로시져 콜
   jmp M_MUL_C_EXIT            ;M_MUL 종료
M_MUL_C_INDIRECT_Y:            ;operand1이 C이고 operand2이 Y일때
   mov si, Y
   mov bx, m[si]
   call M_MUL_C_REG_SOMETHING
   jmp M_MUL_C_EXIT            ;M_MUL 종료
M_MUL_C_DIRECT:               ;operand1이 C이고 direct 모드일 때
   mov si, VDECODE[10]
   mov bx, m[si]
   call M_MUL_C_REG_SOMETHING
   jmp M_MUL_C_EXIT            ;M_MUL 종료
   
               ;점프범위 오류해결을 위해 점프 거리를 나눠서 분기 
M_MUL_C_IMME1:
   jmp M_MUL_C_IMME
   
M_MUL_C_REG:               ;operand2가 레지스터일때   
   cmp VDECODE[8], 1000b      ;A
   je M_MUL_C_REG_A
   cmp VDECODE[8], 1001b      ;B
   je M_MUL_C_REG_B
   cmp VDECODE[8], 1010b      ;C
   je M_MUL_C_REG_C
   cmp VDECODE[8], 1011b      ;D
   je M_MUL_C_REG_D
   cmp VDECODE[8], 1100b      ;E
   je M_MUL_C_REG_E
   cmp VDECODE[8], 1101b      ;F
   je M_MUL_C_REG_F
   cmp VDECODE[8], 1110b      ;X
   je M_MUL_C_REG_X
   cmp VDECODE[8], 1111b      ;Y
   je M_MUL_C_REG_Y
   jmp M_MUL_C_EXIT            ;M_MUL 종료
   
               ;점프범위 오류해결을 위해 점프 거리를 나눠서 분기    
M_MUL_D3:
   jmp M_MUL_D
M_MUL_E3:
   jmp M_MUL_E
M_MUL_F3:
   jmp M_MUL_F4
M_MUL_X3:
   jmp M_MUL_X4
M_MUL_Y3:
   jmp M_MUL_Y4
   
M_MUL_C_REG_A:               ;MUL C, A
   mov bx, A
   call M_MUL_C_REG_SOMETHING
   jmp M_MUL_C_EXIT            ;M_MUL 종료
M_MUL_C_REG_B:               ;MUL C, B
   mov bx, B
   call M_MUL_C_REG_SOMETHING
   jmp M_MUL_C_EXIT            ;M_MUL 종료
M_MUL_C_REG_C:               ;MUL C, C
   mov bx, C
   call M_MUL_C_REG_SOMETHING
   jmp M_MUL_C_EXIT            ;M_MUL 종료
M_MUL_C_REG_D:               ;MUL C, D
   mov bx, D
   call M_MUL_C_REG_SOMETHING
   jmp M_MUL_C_EXIT            ;M_MUL 종료
M_MUL_C_REG_E:               ;MUL C, E
   mov bx, E
   call M_MUL_C_REG_SOMETHING
   jmp M_MUL_C_EXIT            ;M_MUL 종료
M_MUL_C_REG_F:               ;MUL C, F
   mov bx, F
   call M_MUL_C_REG_SOMETHING
   jmp M_MUL_C_EXIT            ;M_MUL 종료
M_MUL_C_REG_X:               ;MUL C, X
   mov bx, X
   call M_MUL_C_REG_SOMETHING
   jmp M_MUL_C_EXIT            ;M_MUL 종료
M_MUL_C_REG_Y:               ;MUL C, Y
   mov bx, Y
   call M_MUL_C_REG_SOMETHING
   jmp M_MUL_C_EXIT            ;M_MUL 종료

M_MUL_C_IMME:      ;operand1이 C이고 immediate 모드일 때
   mov ax, C
   mov bx, VDECODE[10]
   mul bx
   mov C, ax
   
M_MUL_C_EXIT:         ;M_MUL 종료
   jmp M_MUL_EXIT
M_MUL_D:            ;operand1이 D일 때 mulressing mode 비교
   cmp VDECODE[2], 00b   ;Register 모드
   je M_MUL_D_REG
   cmp VDECODE[2], 01b   ;Immediate 모드
   je M_MUL_D_IMME1
   cmp VDECODE[2], 10b   ;Indirect 모드
   je M_MUL_D_INDIRECT
   cmp VDECODE[2], 11b   ;Direct 모드
   je M_MUL_D_DIRECT
   jmp M_MUL_EXIT      ;M_MUL 종료

M_MUL_D_INDIRECT:         ;operand1이 D이고 INDIRECT모드
   cmp VDECODE[8], 1110b   ;operand1이 D이고 operand2이 X일때
   je M_MUL_D_INDIRECT_X
   cmp VDECODE[8], 1111b   ;operand1이 D이고 operand2이 Y일때
   je M_MUL_D_INDIRECT_Y
M_MUL_D_INDIRECT_X:         ;operand1이 D이고 operand2이 X일때
   mov si, X
   mov bx, m[si]
   call M_MUL_D_REG_SOMETHING   ;D와 어떤 것을 연산하는 프로시져 콜
   jmp M_MUL_D_EXIT         ;M_MUL 종료
M_MUL_D_INDIRECT_Y:         ;operand1이 D이고 operand2이 Y일때
   mov si, Y
   mov bx, m[si]
   call M_MUL_D_REG_SOMETHING
   jmp M_MUL_D_EXIT         ;M_MUL 종료
M_MUL_D_DIRECT:            ;operand1이 D이고 direct 모드일 때
   mov si, VDECODE[10]
   mov bx, m[si]
   call M_MUL_D_REG_SOMETHING
   jmp M_MUL_D_EXIT         ;M_MUL 종료
   
         ;점프범위 오류해결을 위해 점프 거리를 나눠서 분기    
M_MUL_D_IMME1:
   jmp M_MUL_D_IMME   
   
M_MUL_D_REG:            ;operand1이 D이고 operand2가 레지스터일때   
   cmp VDECODE[8], 1000b   ;A
   je M_MUL_D_REG_A
   cmp VDECODE[8], 1001b   ;B
   je M_MUL_D_REG_B
   cmp VDECODE[8], 1010b   ;C
   je M_MUL_D_REG_C
   cmp VDECODE[8], 1011b   ;D
   je M_MUL_D_REG_D
   cmp VDECODE[8], 1100b   ;E
   je M_MUL_D_REG_E
   cmp VDECODE[8], 1101b   ;F
   je M_MUL_D_REG_F
   cmp VDECODE[8], 1110b   ;X
   je M_MUL_D_REG_X
   cmp VDECODE[8], 1111b   ;Y
   je M_MUL_D_REG_Y
   jmp M_MUL_D_EXIT      ;M_MUL 종료
   
         ;점프범위 오류해결을 위해 점프 거리를 나눠서 분기    
M_MUL_F4:
   jmp M_MUL_F
M_MUL_X4:
   jmp M_MUL_X
M_MUL_Y4:
   jmp M_MUL_Y
   
M_MUL_D_REG_A:               ;MUL D, A
   mov bx, A
   call M_MUL_D_REG_SOMETHING
   jmp M_MUL_D_EXIT            ;M_MUL 종료
M_MUL_D_REG_B:               ;MUL D, B
   mov bx, B
   call M_MUL_D_REG_SOMETHING
   jmp M_MUL_D_EXIT            ;M_MUL 종료
M_MUL_D_REG_C:               ;MUL D, C
   mov bx, C
   call M_MUL_D_REG_SOMETHING
   jmp M_MUL_D_EXIT            ;M_MUL 종료
M_MUL_D_REG_D:               ;MUL D, D
   mov bx, D
   call M_MUL_D_REG_SOMETHING
   jmp M_MUL_D_EXIT            ;M_MUL 종료
M_MUL_D_REG_E:               ;MUL D, E
   mov bx, E
   call M_MUL_D_REG_SOMETHING
   jmp M_MUL_D_EXIT            ;M_MUL 종료
M_MUL_D_REG_F:               ;MUL D, F
   mov bx, F
   call M_MUL_D_REG_SOMETHING
   jmp M_MUL_D_EXIT            ;M_MUL 종료
M_MUL_D_REG_X:               ;MUL D, X
   mov bx, X
   call M_MUL_D_REG_SOMETHING
   jmp M_MUL_D_EXIT            ;M_MUL 종료
M_MUL_D_REG_Y:               ;MUL D, Y
   mov bx, Y
   call M_MUL_D_REG_SOMETHING
   jmp M_MUL_D_EXIT            ;M_MUL 종료

M_MUL_D_IMME:            ;operand1이 D이고 immediate 모드일 때
   mov ax, D
   mov bx, VDECODE[10]
   mul bx
   mov D, ax
   
M_MUL_D_EXIT:               ;M_MUL 종료
   jmp M_MUL_EXIT
   
M_MUL_E:            ;operand1이 E일 때 mulressing mode 비교
   cmp VDECODE[2], 00b      ;Register 모드
   je M_MUL_E_REG
   cmp VDECODE[2], 01b      ;Immediate 모드
   je M_MUL_E_IMME1
   cmp VDECODE[2], 10b      ;Indirect 모드
   je M_MUL_E_INDIRECT
   cmp VDECODE[2], 11b      ;Direct 모드
   je M_MUL_E_DIRECT
   jmp M_MUL_EXIT         ;M_MUL 종료

M_MUL_E_INDIRECT:         ;operand1이 E이고 INDIRECT모드
   cmp VDECODE[8], 1110b   ;operand1이 E이고 operand2이 X일때
   je M_MUL_E_INDIRECT_X
   cmp VDECODE[8], 1111b   ;operand1이 E이고 operand2이 Y일때
   je M_MUL_E_INDIRECT_Y
M_MUL_E_INDIRECT_X:         ;operand1이 E이고 operand2이 X일때
   mov si, X
   mov bx, m[si]
   call M_MUL_E_REG_SOMETHING   ;E와 어떤 것을 연산하는 프로시져 콜
   jmp M_MUL_E_EXIT            ;M_MUL 종료
M_MUL_E_INDIRECT_Y:         ;operand1이 E이고 operand2이 Y일때
   mov si, Y
   mov bx, m[si]
   call M_MUL_E_REG_SOMETHING
   jmp M_MUL_E_EXIT            ;M_MUL 종료
M_MUL_E_DIRECT:
   mov si, VDECODE[10]         ;operand1이 E이고 direct 모드일 때
   mov bx, m[si]
   call M_MUL_E_REG_SOMETHING
   jmp M_MUL_E_EXIT            ;M_MUL 종료
   
         ;점프범위 오류해결을 위해 점프 거리를 나눠서 분기    
M_MUL_E_IMME1:
   jmp M_MUL_E_IMME   
   
M_MUL_E_REG:      ;operand1이 E이고 operand2가 레지스터일때   
   cmp VDECODE[8], 1000b      ;A
   je M_MUL_E_REG_A
   cmp VDECODE[8], 1001b      ;B
   je M_MUL_E_REG_B
   cmp VDECODE[8], 1010b      ;C
   je M_MUL_E_REG_C
   cmp VDECODE[8], 1011b      ;D
   je M_MUL_E_REG_D
   cmp VDECODE[8], 1100b      ;E
   je M_MUL_E_REG_E
   cmp VDECODE[8], 1101b      ;F
   je M_MUL_E_REG_F
   cmp VDECODE[8], 1110b      ;X
   je M_MUL_E_REG_X
   cmp VDECODE[8], 1111b      ;Y
   je M_MUL_E_REG_Y
   jmp M_MUL_E_EXIT            ;M_MUL 종료
   
M_MUL_E_REG_A:               ;MUL E, A
   mov bx, A
   call M_MUL_E_REG_SOMETHING
   jmp M_MUL_E_EXIT            ;M_MUL 종료
M_MUL_E_REG_B:               ;MUL E, B
   mov bx, B
   call M_MUL_E_REG_SOMETHING
   jmp M_MUL_E_EXIT            ;M_MUL 종료
M_MUL_E_REG_C:               ;MUL E, C
   mov bx, C
   call M_MUL_E_REG_SOMETHING
   jmp M_MUL_E_EXIT            ;M_MUL 종료
M_MUL_E_REG_D:               ;MUL E, D
   mov bx, D
   call M_MUL_E_REG_SOMETHING
   jmp M_MUL_E_EXIT            ;M_MUL 종료
M_MUL_E_REG_E:               ;MUL E, E
   mov bx, E
   call M_MUL_E_REG_SOMETHING
   jmp M_MUL_E_EXIT            ;M_MUL 종료
M_MUL_E_REG_F:               ;MUL E, F
   mov bx, F
   call M_MUL_E_REG_SOMETHING
   jmp M_MUL_E_EXIT            ;M_MUL 종료
M_MUL_E_REG_X:               ;MUL E, X
   mov bx, X
   call M_MUL_E_REG_SOMETHING
   jmp M_MUL_E_EXIT            ;M_MUL 종료
M_MUL_E_REG_Y:               ;MUL E, Y
   mov bx, Y
   call M_MUL_E_REG_SOMETHING
   jmp M_MUL_E_EXIT            ;M_MUL 종료

M_MUL_E_IMME:         ;operand1이 E이고 immediate 모드일 때
   mov ax, E
   mov bx, VDECODE[10]
   mul bx
   mov E, ax
   
M_MUL_E_EXIT:         ;M_MUL 종료
   jmp M_MUL_EXIT
   
M_MUL_F:            ;operand1이 F일 때 mulressing mode 비교
   cmp VDECODE[2], 00b   ;Register 모드
   je M_MUL_F_REG
   cmp VDECODE[2], 01b   ;Immediate 모드
   je M_MUL_F_IMME1
   cmp VDECODE[2], 10b   ;Indirect 모드
   je M_MUL_F_INDIRECT
   cmp VDECODE[2], 11b   ;Direct 모드
   je M_MUL_F_DIRECT
   jmp M_MUL_EXIT      ;M_MUL 종료

M_MUL_F_INDIRECT:      ;operand1이 F이고 INDIRECT모드
   cmp VDECODE[8], 1110b   ;operand1이 F이고 operand2이 X일때
   je M_MUL_F_INDIRECT_X
   cmp VDECODE[8], 1111b   ;operand1이 F이고 operand2이 Y일때
   je M_MUL_F_INDIRECT_Y
M_MUL_F_INDIRECT_X:         ;operand1이 F이고 operand2이 X일때
   mov si, X
   mov bx, m[si]
   call M_MUL_F_REG_SOMETHING   ;F와 어떤 것을 연산하는 프로시져 콜
   jmp M_MUL_F_EXIT            ;M_MUL 종료
M_MUL_F_INDIRECT_Y:            ;operand1이 F이고 operand2이 Y일때
   mov si, Y
   mov bx, m[si]
   call M_MUL_F_REG_SOMETHING
   jmp M_MUL_F_EXIT            ;M_MUL 종료
M_MUL_F_DIRECT:            ;operand1이 F이고 direct 모드일 때
   mov si, VDECODE[10]
   mov bx, m[si]
   call M_MUL_F_REG_SOMETHING
   jmp M_MUL_F_EXIT         ;M_MUL 종료
   
         ;점프범위 오류해결을 위해 점프 거리를 나눠서 분기    
M_MUL_F_IMME1:
   jmp M_MUL_F_IMME   
   
M_MUL_F_REG:         ;operand1이 F이고 operand2가 레지스터일때   
   cmp VDECODE[8], 1000b   ;A
   je M_MUL_F_REG_A
   cmp VDECODE[8], 1001b   ;B
   je M_MUL_F_REG_B
   cmp VDECODE[8], 1010b   ;C
   je M_MUL_F_REG_C
   cmp VDECODE[8], 1011b   ;D
   je M_MUL_F_REG_D
   cmp VDECODE[8], 1100b   ;E
   je M_MUL_F_REG_E
   cmp VDECODE[8], 1101b   ;F
   je M_MUL_F_REG_F
   cmp VDECODE[8], 1110b   ;X
   je M_MUL_F_REG_X
   cmp VDECODE[8], 1111b   ;Y
   je M_MUL_F_REG_Y
   jmp M_MUL_F_EXIT         ;M_MUL 종료
   
M_MUL_F_REG_A:            ;MUL F, A
   mov bx, A
   call M_MUL_F_REG_SOMETHING
   jmp M_MUL_F_EXIT         ;M_MUL 종료
M_MUL_F_REG_B:            ;MUL F, B
   mov bx, B
   call M_MUL_F_REG_SOMETHING
   jmp M_MUL_F_EXIT         ;M_MUL 종료
M_MUL_F_REG_C:            ;MUL F, C
   mov bx, C
   call M_MUL_F_REG_SOMETHING
   jmp M_MUL_F_EXIT         ;M_MUL 종료
M_MUL_F_REG_D:            ;MUL F, D
   mov bx, D
   call M_MUL_F_REG_SOMETHING
   jmp M_MUL_F_EXIT         ;M_MUL 종료
M_MUL_F_REG_E:            ;MUL F, E
   mov bx, E
   call M_MUL_F_REG_SOMETHING
   jmp M_MUL_F_EXIT         ;M_MUL 종료
M_MUL_F_REG_F:            ;MUL F, F
   mov bx, F
   call M_MUL_F_REG_SOMETHING
   jmp M_MUL_F_EXIT         ;M_MUL 종료
M_MUL_F_REG_X:            ;MUL F, X
   mov bx, X
   call M_MUL_F_REG_SOMETHING
   jmp M_MUL_F_EXIT         ;M_MUL 종료
M_MUL_F_REG_Y:            ;MUL F, Y
   mov bx, Y
   call M_MUL_F_REG_SOMETHING
   jmp M_MUL_F_EXIT         ;M_MUL 종료

M_MUL_F_IMME:            ;operand1이 F이고 immediate 모드일 때
   mov ax, F
   mov bx, VDECODE[10]
   mul bx
   mov F, ax
   
M_MUL_F_EXIT:               ;M_MUL 종료
   jmp M_MUL_EXIT
   
M_MUL_X:            ;operand1이 X일 때 mulressing mode 비교
   cmp VDECODE[2], 00b   ;Register 모드
   je M_MUL_X_REG
   cmp VDECODE[2], 01b   ;Immediate 모드
   je M_MUL_X_IMME1
   cmp VDECODE[2], 10b   ;Indirect 모드
   je M_MUL_X_INDIRECT
   cmp VDECODE[2], 11b   ;Direct 모드
   je M_MUL_X_DIRECT
   jmp M_MUL_EXIT      ;M_MUL 종료

M_MUL_X_INDIRECT:         ;operand1이 X이고 INDIRECT모드
   cmp VDECODE[8], 1110b   ;operand1이 X이고 operand2이 X일때
   je M_MUL_X_INDIRECT_X
   cmp VDECODE[8], 1111b   ;operand1이 X이고 operand2이 Y일때
   je M_MUL_X_INDIRECT_Y
M_MUL_X_INDIRECT_X:         ;operand1이 X이고 operand2이 X일때
   mov si, X
   mov bx, m[si]
   call M_MUL_X_REG_SOMETHING   ;X와 어떤 것을 연산하는 프로시져 콜
   jmp M_MUL_X_EXIT            ;M_MUL 종료
M_MUL_X_INDIRECT_Y:            ;operand1이 X이고 operand2이 Y일때
   mov si, Y
   mov bx, m[si]
   call M_MUL_X_REG_SOMETHING
   jmp M_MUL_X_EXIT            ;M_MUL 종료
M_MUL_X_DIRECT:               ;operand1이 X이고 direct 모드일 때
   mov si, VDECODE[10]
   mov bx, m[si]
   call M_MUL_X_REG_SOMETHING
   jmp M_MUL_X_EXIT            ;M_MUL 종료
   
            ;점프범위 오류해결을 위해 점프 거리를 나눠서 분기    
M_MUL_X_IMME1:   
   jmp M_MUL_X_IMME   
   
M_MUL_X_REG:         ;operand1이 X이고 operand2가 레지스터일때   
   cmp VDECODE[8], 1000b   ;A
   je M_MUL_X_REG_A
   cmp VDECODE[8], 1001b   ;B
   je M_MUL_X_REG_B
   cmp VDECODE[8], 1010b   ;C
   je M_MUL_X_REG_C
   cmp VDECODE[8], 1011b   ;D
   je M_MUL_X_REG_D
   cmp VDECODE[8], 1100b   ;E
   je M_MUL_X_REG_E
   cmp VDECODE[8], 1101b   ;F
   je M_MUL_X_REG_F
   cmp VDECODE[8], 1110b   ;X
   je M_MUL_X_REG_X
   cmp VDECODE[8], 1111b   ;Y
   je M_MUL_X_REG_Y
   jmp M_MUL_X_EXIT         ;M_MUL 종료
   
M_MUL_X_REG_A:            ;MUL X, A
   mov bx, A
   call M_MUL_X_REG_SOMETHING
   jmp M_MUL_X_EXIT         ;M_MUL 종료
M_MUL_X_REG_B:            ;MUL X, B
   mov bx, B
   call M_MUL_X_REG_SOMETHING
   jmp M_MUL_X_EXIT         ;M_MUL 종료
M_MUL_X_REG_C:            ;MUL X, C
   mov bx, C
   call M_MUL_X_REG_SOMETHING
   jmp M_MUL_X_EXIT         ;M_MUL 종료
M_MUL_X_REG_D:            ;MUL X, D
   mov bx, D
   call M_MUL_X_REG_SOMETHING
   jmp M_MUL_X_EXIT         ;M_MUL 종료
M_MUL_X_REG_E:            ;MUL X, E
   mov bx, E
   call M_MUL_X_REG_SOMETHING
   jmp M_MUL_X_EXIT         ;M_MUL 종료
M_MUL_X_REG_F:            ;MUL X, F
   mov bx, F
   call M_MUL_X_REG_SOMETHING
   jmp M_MUL_X_EXIT         ;M_MUL 종료
M_MUL_X_REG_X:            ;MUL X, X
   mov bx, X
   call M_MUL_X_REG_SOMETHING
   jmp M_MUL_X_EXIT         ;M_MUL 종료
M_MUL_X_REG_Y:            ;MUL X, Y
   mov bx, Y
   call M_MUL_X_REG_SOMETHING
   jmp M_MUL_X_EXIT         ;M_MUL 종료

M_MUL_X_IMME:         ;operand1이 X이고 operand2가 immediate일때
   mov ax, X
   mov bx, VDECODE[10]
   mul bx
   mov X, ax
   
M_MUL_X_EXIT:            ;M_MUL 종료
   jmp M_MUL_EXIT
   
M_MUL_Y:            ;operand1이 Y일 때 mulressing mode 비교
   cmp VDECODE[2], 00b   ;Register 모드
   je M_MUL_Y_REG
   cmp VDECODE[2], 01b   ;Immediate 모드
   je M_MUL_Y_IMME1
   cmp VDECODE[2], 10b   ;Indirect 모드
   je M_MUL_Y_INDIRECT
   cmp VDECODE[2], 11b   ;Direct 모드
   je M_MUL_Y_DIRECT
   jmp M_MUL_EXIT      ;M_MUL 종료

M_MUL_Y_INDIRECT:         ;operand1이 Y이고 INDIRECT모드
   cmp VDECODE[8], 1110b   ;operand1이 Y이고 operand2이 X일때
   je M_MUL_Y_INDIRECT_X
   cmp VDECODE[8], 1111b   ;operand1이 Y이고 operand2이 Y일때
   je M_MUL_Y_INDIRECT_Y
M_MUL_Y_INDIRECT_X:         ;operand1이 Y이고 operand2이 X일때
   mov si, X
   mov bx, m[si]
   call M_MUL_Y_REG_SOMETHING   ;Y와 어떤 것을 연산하는 프로시져 콜
   jmp M_MUL_Y_EXIT            ;M_MUL 종료
M_MUL_Y_INDIRECT_Y:            ;operand1이 Y이고 operand2이 Y일때
   mov si, Y
   mov bx, m[si]
   call M_MUL_Y_REG_SOMETHING
   jmp M_MUL_Y_EXIT            ;M_MUL 종료
M_MUL_Y_DIRECT:               ;operand1이 Y이고 direct 모드일 때
   mov si, VDECODE[10]
   mov bx, m[si]
   call M_MUL_Y_REG_SOMETHING
   jmp M_MUL_Y_EXIT            ;M_MUL 종료
   
         ;점프범위 오류해결을 위해 점프 거리를 나눠서 분기 
M_MUL_Y_IMME1:
   jmp M_MUL_Y_IMME
   
M_MUL_Y_REG:            ;operand1이 Y이고 operand2가 레지스터일때   
   cmp VDECODE[8], 1000b   ;A
   je M_MUL_Y_REG_A
   cmp VDECODE[8], 1001b   ;B
   je M_MUL_Y_REG_B
   cmp VDECODE[8], 1010b   ;C
   je M_MUL_Y_REG_C
   cmp VDECODE[8], 1011b   ;D
   je M_MUL_Y_REG_D
   cmp VDECODE[8], 1100b   ;E
   je M_MUL_Y_REG_E
   cmp VDECODE[8], 1101b   ;F
   je M_MUL_Y_REG_F
   cmp VDECODE[8], 1110b   ;X
   je M_MUL_Y_REG_X
   cmp VDECODE[8], 1111b   ;Y
   je M_MUL_Y_REG_Y
   jmp M_MUL_Y_EXIT         ;M_MUL 종료
   
M_MUL_Y_REG_A:         ;MUL Y, A
   mov bx, A
   call M_MUL_Y_REG_SOMETHING
   jmp M_MUL_Y_EXIT      ;M_MUL 종료
M_MUL_Y_REG_B:         ;MUL Y, B
   mov bx, B
   call M_MUL_Y_REG_SOMETHING
   jmp M_MUL_Y_EXIT      ;M_MUL 종료
M_MUL_Y_REG_C:         ;MUL Y, C
   mov bx, C
   call M_MUL_Y_REG_SOMETHING
   jmp M_MUL_Y_EXIT      ;M_MUL 종료
M_MUL_Y_REG_D:         ;MUL Y, D
   mov bx, D
   call M_MUL_Y_REG_SOMETHING
   jmp M_MUL_Y_EXIT      ;M_MUL 종료
M_MUL_Y_REG_E:         ;MUL Y, E
   mov bx, E
   call M_MUL_Y_REG_SOMETHING
   jmp M_MUL_Y_EXIT      ;M_MUL 종료
M_MUL_Y_REG_F:         ;MUL Y, F
   mov bx, F
   call M_MUL_Y_REG_SOMETHING
   jmp M_MUL_Y_EXIT      ;M_MUL 종료
M_MUL_Y_REG_X:         ;MUL Y, X
   mov bx, X
   call M_MUL_Y_REG_SOMETHING
   jmp M_MUL_Y_EXIT      ;M_MUL 종료
M_MUL_Y_REG_Y:         ;MUL Y, Y
   mov bx, Y
   call M_MUL_Y_REG_SOMETHING
   jmp M_MUL_Y_EXIT      ;M_MUL 종료

M_MUL_Y_IMME:         ;operand1이 Y이고 immediate 모드일 때
   mov ax, Y
   mov bx, VDECODE[10]
   mul bx
   mov Y, ax
   
M_MUL_Y_EXIT:            ;M_MUL 종료
   jmp M_MUL_EXIT
   
M_MUL_EXIT:               ;M_MUL 종료
   RET
M_MUL ENDP

M_MUL_A_REG_SOMETHING PROC      ;A와 어떤 것을 MUL연산하는 프로시져
   mov ax, A
   mul bx
   mov A, ax
   RET
M_MUL_A_REG_SOMETHING ENDP

M_MUL_B_REG_SOMETHING PROC      ;B와 어떤 것을 MUL연산하는 프로시져
   mov ax, B
   mul bx
   mov B, ax
   RET
M_MUL_B_REG_SOMETHING ENDP

M_MUL_C_REG_SOMETHING PROC      ;C와 어떤 것을 MUL연산하는 프로시져
   mov ax, C
   mul bx
   mov C, ax
   RET
M_MUL_C_REG_SOMETHING ENDP

M_MUL_D_REG_SOMETHING PROC      ;D와 어떤 것을 MUL연산하는 프로시져
   mov ax, D
   mul bx
   mov D, ax
   RET
M_MUL_D_REG_SOMETHING ENDP

M_MUL_E_REG_SOMETHING PROC      ;E와 어떤 것을 MUL연산하는 프로시져
   mov ax, E
   mul bx
   mov E, ax
   RET
M_MUL_E_REG_SOMETHING ENDP


M_MUL_F_REG_SOMETHING PROC      ;F와 어떤 것을 MUL연산하는 프로시져
   mov ax, F
   mul bx
   mov F, ax
   RET
M_MUL_F_REG_SOMETHING ENDP

M_MUL_X_REG_SOMETHING PROC      ;X와 어떤 것을 MUL연산하는 프로시져
   mov ax, X
   mul bx
   mov X, ax
   RET
M_MUL_X_REG_SOMETHING ENDP

M_MUL_Y_REG_SOMETHING PROC      ;Y와 어떤 것을 MUL연산하는 프로시져
   mov ax, Y
   mul bx
   mov Y, ax
   RET
M_MUL_Y_REG_SOMETHING ENDP



;------------------------------------------------
;Procedure Name : M_SHIFT
;Function : SHIFT 명령어 기능을 구현
;PROGRAMED BY 석승욱
;PROGRAM VERSION
;   Creation Date :Nov 28,2016
;   Last Modified On Nov 29 ,2016
;------------------------------------------------
M_SHIFT PROC
   AND VDECODE[6],11b		;VDECODE[6]는 SHL,SHR를 판단
   AND VDECODE[4],1111b		;VDECODE[4]는 Register를 판단

   CMP VDECODE[6],00b		;VDECODE[6]이 00b인 경우 SHL
   JE M_SHIFT_LEFT			;
   CMP VDECODE[6],01b		;VDECODE[6]이 01b인 경우 SHR
   JE M_SHIFT_RIGHT			
					
	M_SHIFT_ERROR:			;둘다 아니면 잘못된 값 ERROR메세지 출력
	MOV DX, OFFSET STR_WRONGFUNCTION
	CALL PUTS
	CALL NEWLINE
	JMP M_SHIFT_EXIT
   M_SHIFT_LEFT:			;SHL를 구현
   CMP VDECODE[4],1000b		;VDECODE[4]가 1000b인경우
   JNE M_SHIFT_LEFT_B		;Register A의 값을 Shift left
   SHL A,1					
   JE M_SHIFT_EXIT_1	
   M_SHIFT_LEFT_B:		
   CMP VDECODE[4],1001b		;VDECODE[4]가 1001b인경우
   JNE M_SHIFT_LEFT_C		;│Register B의 값을 Shift left
   SHL B,1					
   JE M_SHIFT_EXIT_1		
   M_SHIFT_LEFT_C:			
   CMP VDECODE[4],1010b		;VDECODE[4]가 1010b인경우
   JNE M_SHIFT_LEFT_D		;Register C의 값을 Shift left
   SHL C,1					
   JE M_SHIFT_EXIT_1		
   M_SHIFT_LEFT_D:			
   CMP VDECODE[4],1011b		;VDECODE[4]가 1011b인경우
   JNE M_SHIFT_LEFT_E		;Register D의 값을 Shift left
   SHL D,1					
   JE M_SHIFT_EXIT_1		
   M_SHIFT_LEFT_E:			
   CMP VDECODE[4],1100b		;VDECODE[4]가 1100b인경우
   JNE M_SHIFT_LEFT_F		;Register E의 값을 Shift left
   SHL E,1					
   JE M_SHIFT_EXIT_1		
   M_SHIFT_LEFT_F:			
   CMP VDECODE[4],1101b		;VDECODE[4]가 1101b인경우
   JNE M_SHIFT_LEFT_X		;Register F의 값을 Shift left
   SHL F,1					
   JE M_SHIFT_EXIT_1		
   M_SHIFT_LEFT_X:			
   CMP VDECODE[4],1110b		;VDECODE[4]가 1110b인경우
   JNE M_SHIFT_LEFT_Y		;Register X의 값을 Shift left
   SHL X,1					
   JE M_SHIFT_EXIT_1		
   M_SHIFT_LEFT_Y:			
   CMP VDECODE[4],1111b		;VDECODE[4]가 1111b인경우
   JNE M_SHIFT_EXIT			;Register Y의 값을 Shift left
   SHL Y,1					
   JE M_SHIFT_EXIT_1		
   M_SHIFT_EXIT_1:			
   JMP M_SHIFT_EXIT			

   M_SHIFT_RIGHT:			;SHL를 구현
   CMP VDECODE[4],1000b		;DECODE[4]가 1000b인경우
   JNE M_SHIFT_RIGHT_B		;Register A의 값을 Shift Right
   SHR A,1					
   JE M_SHIFT_EXIT			
   M_SHIFT_RIGHT_B:			
   CMP VDECODE[4],1001b		;VDECODE[4]가 1001b인경우
   JNE M_SHIFT_RIGHT_C		;Register B의 값을 Shift Right
   SHR B,1					
   JE M_SHIFT_EXIT			
   M_SHIFT_RIGHT_C:			
   CMP VDECODE[4],1010b		;VDECODE[4]가 1010b인경우
   JNE M_SHIFT_RIGHT_D		;Register C의 값을 Shift Right
   SHR C,1					
   JE M_SHIFT_EXIT			
   M_SHIFT_RIGHT_D:			
   CMP VDECODE[4],1011b		;VDECODE[4]가 1011b인경우
   JNE M_SHIFT_RIGHT_E		;Register D의 값을 Shift Right
   SHR D,1					
   JE M_SHIFT_EXIT			
   M_SHIFT_RIGHT_E:			
   CMP VDECODE[4],1100b		;VDECODE[4]가 1100b인경우
   JNE M_SHIFT_RIGHT_F		;Register E의 값을 Shift Right
   SHR E,1					
   JE M_SHIFT_EXIT			
   M_SHIFT_RIGHT_F:			
   CMP VDECODE[4],1101b		;VDECODE[4]가 1101b인경우
   JNE M_SHIFT_RIGHT_X		;Register F의 값을 Shift Right
   SHR F,1					
   JE M_SHIFT_EXIT			
   M_SHIFT_RIGHT_X:			
   CMP VDECODE[4],1110b		;VDECODE[4]가 1110b인경우
   JNE M_SHIFT_RIGHT_Y		;Register X의 값을 Shift Right
   SHR X,1					
   JE M_SHIFT_EXIT		
   M_SHIFT_RIGHT_Y:			
   CMP VDECODE[4],1111b		;VDECODE[4]가 1111b인경우
   JNE M_SHIFT_EXIT			;Register Y의 값을 Shift Right
   SHR Y,1				
   JE M_SHIFT_EXIT		

   M_SHIFT_EXIT:			;SHIFT함수 종료
   RET						
M_SHIFT ENDP

;------------------------------------------------
;Procedure Name : M_DIV
;Function : DIV 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 28,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
M_DIV PROC
   CMP VDECODE[4],1000b ; OPERAND1이 A일 때
   JE M_DIV_A
   CMP VDECODE[4],1001b ; OPERAND1이 B일 때
   JE M_DIV_B
   CMP VDECODE[4],1010b ; OPERAND1이 C일 때
   JE M_DIV_C           
   CMP VDECODE[4],1011b ; OPERAND1이 D일 때
   JE M_DIV_D
   CMP VDECODE[4],1100b ; OPERAND1이 E일 때
   JE M_DIV_E
   CMP VDECODE[4],1101b ; OPERAND1이 F일 때
   JE M_DIV_F
   CMP VDECODE[4],1110b ; OPERAND1이 X일 때
   JE M_DIV_X
   CMP VDECODE[4],1111b ; OPERAND1이 Y일 때
   JE M_DIV_Y

   PRINT ERR
   JMP END_M_DIV

M_DIV_A:
   CALL DIV_A_P			; DIV_A_P 호출
   JMP END_M_DIV
M_DIV_B:
   CALL DIV_B_P			; DIV_B_P 호출
   JMP END_M_DIV
M_DIV_C:
   CALL DIV_C_P			; DIV_C_P 호출
   JMP END_M_DIV
M_DIV_D:
   CALL DIV_D_P			; DIV_D_P 호출
   JMP END_M_DIV
M_DIV_E:
   CALL DIV_E_P			; DIV_E_P 호출
   JMP END_M_DIV
M_DIV_F:
   CALL DIV_F_P			; DIV_F_P 호출
   JMP END_M_DIV
M_DIV_X:
   CALL DIV_X_P			; DIV_X_P 호출
   JMP END_M_DIV
M_DIV_Y:
   CALL DIV_Y_P			; DIV_Y_P 호출
   JMP END_M_DIV

END_M_DIV:
   RET
M_DIV ENDP

;------------------------------------------------
;Procedure Name : DIV_A_P
;Function : DIV A, 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 28,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
DIV_A_P PROC

   MOV AX, VDECODE[2]
   AND AX,11b
   MOV VDECODE[2],AX
                              ; DIV A,
   CMP VDECODE[2],00b			; REGISTER 모드
   JE DIV_A_REGI
   CMP VDECODE[2],01b			; IMMEDIATE 모드
   JE DIV_A_IMME
   CMP VDECODE[2],10b			; REGISTER-INDIRECT 모드
   JE DIV_A_REGI_IMME
   CMP VDECODE[2],11b			; DIRECT 모드
   JE DIV_A_DI

   PRINT ERR
   JMP END_M_DIV_A_P

DIV_A_REGI:
   CALL DIV_A_REGI_P		; DIV_A_REGI_P 호출
   JMP END_M_DIV_A_P
DIV_A_IMME:
   CALL DIV_A_IMME_P		; DIV_A_IMME_P 호출
   JMP END_M_DIV_A_P
DIV_A_REGI_IMME:
   CALL DIV_A_REGI_IMME_P		; DIV_A_REGI_IMME_P 호출
   JMP END_M_DIV_A_P
DIV_A_DI:
   CALL DIV_A_DI_P		; DIV_A_DI_P 호출
   JMP END_M_DIV_A_P

END_M_DIV_A_P:
   RET
DIV_A_P ENDP

;------------------------------------------------
;Procedure Name : DIV_A_REGI_P
;Function : DIV A, 레지스터 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 28,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
DIV_A_REGI_P PROC
   MOV AX,VDECODE[8]                         ; DIV A,REGISTER
   AND AX,1111b
   MOV VDECODE[8],AX

   CMP VDECODE[8],1000b		; OPERAND2 가 A
   JE DIV_A_A
   CMP VDECODE[8],1001b		; OPERAND2 가 B
   JE DIV_A_B
   CMP VDECODE[8],1010b		; OPERAND2 가 C
   JE DIV_A_C
   CMP VDECODE[8],1011b		; OPERAND2 가 D
   JE DIV_A_D
   CMP VDECODE[8],1100b		; OPERAND2 가 E
   JE DIV_A_E
   CMP VDECODE[8],1101b		; OPERAND2 가 F
   JE DIV_A_F
   CMP VDECODE[8],1110b		; OPERAND2 가 X
   JE DIV_A_X
   CMP VDECODE[8],1111b		; OPERAND2 가 Y
   JE DIV_A_Y

   PRINT ERR
   JMP END_M_DIV_A_REGI_P

DIV_A_A:
   MOV BX,A					; BX에 A값을 저장
	MOV AX,A				; AX에 A값을 저장
	DIV BL					; BL값으로 A값을 DIV
   CALL SHR_F				; E,F 레지스터에 각각 몫,나머지를 저장
   JMP END_M_DIV_A_REGI_P
DIV_A_B:
	MOV BX,B					; BX에 B값을 저장
	MOV AX,A					; BX에 A값을 저장
	DIV BL					; BL값으로 A값을 DIV
	CALL SHR_F				; E,F 레지스터에 각각 몫,나머지를 저장
   JMP END_M_DIV_A_REGI_P
DIV_A_C:
   MOV BX,C					; BX에 C값을 저장
	MOV AX,A					; BX에 A값을 저장
	DIV BL					; BL값으로 A값을 DIV
   CALL SHR_F				; E,F 레지스터에 각각 몫,나머지를 저장
   JMP END_M_DIV_A_REGI_P
DIV_A_D:
   MOV BX,D					; BX에 D값을 저장
	MOV AX,A					; BX에 A값을 저장
	DIV BL					; BL값으로 A값을 DIV
   CALL SHR_F				; E,F 레지스터에 각각 몫,나머지를 저장
   JMP END_M_DIV_A_REGI_P
DIV_A_E:
   MOV BX,E					; BX에 E값을 저장
	MOV AX,A					; BX에 A값을 저장
	DIV BL					; BL값으로 A값을 DIV
   CALL SHR_F				; E,F 레지스터에 각각 몫,나머지를 저장
   JMP END_M_DIV_A_REGI_P
DIV_A_F:
   MOV BX,F					; BX에 F값을 저장
	MOV AX,A					; BX에 A값을 저장
	DIV BL					; BL값으로 A값을 DIV
   CALL SHR_F				; E,F 레지스터에 각각 몫,나머지를 저장
   JMP END_M_DIV_A_REGI_P
DIV_A_X:
   MOV BX,X					; BX에 X값을 저장
	MOV AX,A					; BX에 A값을 저장
	DIV BL					; BL값으로 A값을 DIV
   CALL SHR_F				; E,F 레지스터에 각각 몫,나머지를 저장
   JMP END_M_DIV_A_REGI_P
DIV_A_Y:
   MOV BX,Y					; BX에 Y값을 저장
	MOV AX,A					; BX에 A값을 저장
	DIV BL					; BL값으로 A값을 DIV
   CALL SHR_F				; E,F 레지스터에 각각 몫,나머지를 저장
   JMP END_M_DIV_A_REGI_P
   
   PRINT ERR
   JMP END_M_DIV_A_REGI_P

END_M_DIV_A_REGI_P:
   RET
DIV_A_REGI_P ENDP

;------------------------------------------------
;Procedure Name : DIV_A_IMME_P
;Function : DIV A, IMMEDIATE 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 28,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
DIV_A_IMME_P PROC                   ; DIV A,IMMEDIATE
   MOV DX,VDECODE[10]				; A의 값을 VDECODE[10]에 저장되어있는 IMMEDIATE값으로 DIV
   MOV AX,A
   DIV DL
   CALL SHR_F						; E,F 레지스터에 각각 몫,나머지를 저장			
   RET
DIV_A_IMME_P ENDP

;------------------------------------------------
;Procedure Name : DIV_A_REGI_IMME_P
;Function : DIV A, REGISTER-IMMEDIATE 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 28,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
DIV_A_REGI_IMME_P PROC                  ; DIV A,REGISTER_IMMEDIATE
   CMP VDECODE[8],1110					; OPERAND2 값이 X
   JE DIV_A_R_I_X
   CMP VDECODE[8],1111					; OPERAND2 값이 Y
   JE DIV_A_R_I_Y
   
DIV_A_R_I_X:
   MOV SI,X								; X의 값을 SI에 저장
   MOV DX,M[SI]							; M[SI]의 값을 DX에 저장
   MOV AX,A								
   DIV DL								; A의 값을 DX값으로 DIV
   CALL SHR_F						; E,F 레지스터에 각각 몫,나머지를 저장
   JMP END_M_DIV_A_REGI_IMME_P
DIV_A_R_I_Y:
   MOV SI,Y								; Y의 값을 SI에 저장
   MOV DX,M[SI]							; M[SI]의 값을 DX에 저장
   MOV AX,A
   DIV DL								; A의 값을 DX값으로 DIV
   CALL SHR_F						; E,F 레지스터에 각각 몫,나머지를 저장

END_M_DIV_A_REGI_IMME_P:
   RET
DIV_A_REGI_IMME_P ENDP

;------------------------------------------------
;Procedure Name : DIV_A_DI_P
;Function : DIV A, DIRECT 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 28,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
DIV_A_DI_P PROC                     ; DIV A,DIRECT
   MOV SI,VDECODE[10]				; VDECODE[10]에 저장되어있는 주소값을 SI에 저장   
   MOV DX,M[SI]						; M[SI]값을 DX에 저장
   MOV AX,A
   DIV DL							; A의 값을 DX로 DIV
   CALL SHR_F						; E,F 레지스터에 각각 몫,나머지를 저장				
   RET
DIV_A_DI_P ENDP

;------------------------------------------------
;Procedure Name : DIV_B_P
;Function : DIV B, 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 28,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
DIV_B_P PROC

   MOV AX, VDECODE[2]
   AND AX,11b
   MOV VDECODE[2],AX
                              ; DIV B,
   CMP VDECODE[2],00b			; REGISTER 모드
   JE DIV_B_REGI
   CMP VDECODE[2],01b			; IMMEDIATE 모드
   JE DIV_B_IMME
   CMP VDECODE[2],10b			; REGISTER-INDIRECT 모드
   JE DIV_B_REGI_IMME
   CMP VDECODE[2],11b			; DIRECT 모드
   JE DIV_B_DI

   PRINT ERR
   JMP END_M_DIV_B_P

DIV_B_REGI:
   CALL DIV_B_REGI_P		; DIV_B_REGI_P 호출
   JMP END_M_DIV_B_P
DIV_B_IMME:
   CALL DIV_B_IMME_P		; DIV_B_IMME_P 호출
   JMP END_M_DIV_B_P
DIV_B_REGI_IMME:
   CALL DIV_B_REGI_IMME_P		; DIV_B_REGI_IMME_P 호출
   JMP END_M_DIV_B_P
DIV_B_DI:
   CALL DIV_B_DI_P		; DIV_B_DI_P 호출
   JMP END_M_DIV_B_P

END_M_DIV_B_P:
   RET
DIV_B_P ENDP

;------------------------------------------------
;Procedure Name : DIV_B_REGI_P
;Function : DIV B, 레지스터 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 28,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
DIV_B_REGI_P PROC
   MOV AX,VDECODE[8]                         ; DIV B,REGISTER
   AND AX,1111b
   MOV VDECODE[8],AX

   CMP VDECODE[8],1000b		; OPERAND2 가 A
   JE DIV_B_A
   CMP VDECODE[8],1001b		; OPERAND2 가 B
   JE DIV_B_B
   CMP VDECODE[8],1010b		; OPERAND2 가 C
   JE DIV_B_C
   CMP VDECODE[8],1011b		; OPERAND2 가 D
   JE DIV_B_D
   CMP VDECODE[8],1100b		; OPERAND2 가 E
   JE DIV_B_E
   CMP VDECODE[8],1101b		; OPERAND2 가 F
   JE DIV_B_F
   CMP VDECODE[8],1110b		; OPERAND2 가 X
   JE DIV_B_X
   CMP VDECODE[8],1111b		; OPERAND2 가 Y
   JE DIV_B_Y

   PRINT ERR
   JMP END_M_DIV_B_REGI_P

DIV_B_A:
	MOV BX,A				; BX에 A값을 저장
	MOV AX,B				; AX에 B값을 저장
	DIV BL					; BL값으로 B값을 DIV
   CALL SHR_F				; E,F 레지스터에 각각 몫,나머지를 저장
   JMP END_M_DIV_B_REGI_P
DIV_B_B:
	MOV BX,B				; BX에 B값을 저장
	MOV AX,B				; AX에 B값을 저장
	DIV BL					; BL값으로 B값을 DIV
	CALL SHR_F				; E,F 레지스터에 각각 몫,나머지를 저장
   JMP END_M_DIV_B_REGI_P
DIV_B_C:
   MOV BX,C					; BX에 C값을 저장
	MOV AX,B				; AX에 B값을 저장
	DIV BL					; BL값으로 B값을 DIV
   CALL SHR_F				; E,F 레지스터에 각각 몫,나머지를 저장
   JMP END_M_DIV_B_REGI_P
DIV_B_D:
   MOV BX,D					; BX에 D값을 저장
	MOV AX,B				; AX에 B값을 저장
	DIV BL					; BL값으로 B값을 DIV
   CALL SHR_F				; E,F 레지스터에 각각 몫,나머지를 저장
   JMP END_M_DIV_B_REGI_P
DIV_B_E:
   MOV BX,E					; BX에 E값을 저장
	MOV AX,B				; AX에 B값을 저장
	DIV BL					; BL값으로 B값을 DIV
   CALL SHR_F				; E,F 레지스터에 각각 몫,나머지를 저장
   JMP END_M_DIV_B_REGI_P
DIV_B_F:
   MOV BX,F					; BX에 F값을 저장
	MOV AX,B				; AX에 B값을 저장
	DIV BL					; BL값으로 B값을 DIV
   CALL SHR_F				; E,F 레지스터에 각각 몫,나머지를 저장
   JMP END_M_DIV_B_REGI_P
DIV_B_X:
   MOV BX,X					; BX에 X값을 저장
	MOV AX,B				; AX에 B값을 저장
	DIV BL					; BL값으로 B값을 DIV
   CALL SHR_F				; E,F 레지스터에 각각 몫,나머지를 저장
   JMP END_M_DIV_B_REGI_P
DIV_B_Y:
   MOV BX,Y					; BX에 X값을 저장
	MOV AX,B				; AX에 B값을 저장
	DIV BL					; BL값으로 B값을 DIV
   CALL SHR_F				; E,F 레지스터에 각각 몫,나머지를 저장
   JMP END_M_DIV_B_REGI_P
   
   PRINT ERR
   JMP END_M_DIV_B_REGI_P

END_M_DIV_B_REGI_P:
   RET
DIV_B_REGI_P ENDP

;------------------------------------------------
;Procedure Name : DIV_B_IMME_P
;Function : DIV B, IMMEDIATE 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 28,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
DIV_B_IMME_P PROC                   ; DIV B,IMMEDIATE
   MOV DX,VDECODE[10]				; D의 값을 VDECODE[10]에 저장되어있는 IMMEDIATE값으로 DIV
   MOV AX,B
   DIV DL
   CALL SHR_F						; E,F 레지스터에 각각 몫,나머지를 저장			
   RET
DIV_B_IMME_P ENDP

;------------------------------------------------
;Procedure Name : DIV_B_REGI_IMME_P
;Function : DIV B, REGISTER-IMMEDIATE 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 28,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
DIV_B_REGI_IMME_P PROC                 ; DIV B,REGISTER_IMMEDIATE
   CMP VDECODE[8],1110					; OPERAND2 값이 X
   JE DIV_B_R_I_X
   CMP VDECODE[8],1111					; OPERAND2 값이 Y
   JE DIV_B_R_I_Y
   
DIV_B_R_I_X:
   MOV SI,X								; X의 값을 SI에 저장
   MOV DX,M[SI]							; M[SI]의 값을 DX에 저장
   MOV AX,B
   DIV DL								; B의 값을 DX값으로 DIV
   CALL SHR_F						; E,F 레지스터에 각각 몫,나머지를 저장
   JMP END_M_DIV_B_REGI_IMME_P
DIV_B_R_I_Y:
   MOV SI,Y								; Y의 값을 SI에 저장
   MOV DX,M[SI]							; M[SI]의 값을 DX에 저장
   MOV AX,B
   DIV DL								; B의 값을 DX값으로 DIV
   CALL SHR_F						; E,F 레지스터에 각각 몫,나머지를 저장

END_M_DIV_B_REGI_IMME_P:
   RET
DIV_B_REGI_IMME_P ENDP

;------------------------------------------------
;Procedure Name : DIV_B_DI_P
;Function : DIV B, DIRECT 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 28,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
DIV_B_DI_P PROC                     ; DIV B,DIRECT
   MOV SI,VDECODE[10]  				; VDECODE[10]에 저장되어있는 주소값을 SI에 저장 
   MOV DX,M[SI]						; M[SI]값을 DX에 저장
   MOV AX,B
   DIV DL							; B의 값을 DX로 DIV
   CALL SHR_F						; E,F 레지스터에 각각 몫,나머지를 저장	
   RET
DIV_B_DI_P ENDP

;------------------------------------------------
;Procedure Name : DIV_C_P
;Function : DIV C, 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 28,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
DIV_C_P PROC

   MOV AX, VDECODE[2]
   AND AX,11b
   MOV VDECODE[2],AX
                              ; DIV C,
   CMP VDECODE[2],00b			; REGISTER 모드
   JE DIV_C_REGI
   CMP VDECODE[2],01b			; IMMEDIATE 모드
   JE DIV_C_IMME
   CMP VDECODE[2],10b			; REGISTER-INDIRECT 모드
   JE DIV_C_REGI_IMME
   CMP VDECODE[2],11b			; DIRECT 모드
   JE DIV_C_DI

   PRINT ERR
   JMP END_M_DIV_C_P

DIV_C_REGI:
   CALL DIV_C_REGI_P		; DIV_C_REGI_P 호출
   JMP END_M_DIV_C_P
DIV_C_IMME:
   CALL DIV_C_IMME_P		; DIV_C_IMME_P 호출
   JMP END_M_DIV_C_P
DIV_C_REGI_IMME:
   CALL DIV_C_REGI_IMME_P		; DIV_C_REGI_IMME_P 호출
   JMP END_M_DIV_C_P
DIV_C_DI:
   CALL DIV_C_DI_P		; DIV_C_DI_P 호출
   JMP END_M_DIV_C_P

END_M_DIV_C_P:
   RET
DIV_C_P ENDP

;------------------------------------------------
;Procedure Name : DIV_C_REGI_P
;Function : DIV C, 레지스터 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 28,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
DIV_C_REGI_P PROC
   MOV AX,VDECODE[8]                         ; DIV C,REGISTER
   AND AX,1111b
   MOV VDECODE[8],AX

   CMP VDECODE[8],1000b		; OPERAND2 가 A
   JE DIV_C_A
   CMP VDECODE[8],1001b		; OPERAND2 가 B
   JE DIV_C_B
   CMP VDECODE[8],1010b		; OPERAND2 가 C
   JE DIV_C_C
   CMP VDECODE[8],1011b		; OPERAND2 가 D
   JE DIV_C_D
   CMP VDECODE[8],1100b		; OPERAND2 가 E
   JE DIV_C_E
   CMP VDECODE[8],1101b		; OPERAND2 가 F
   JE DIV_C_F
   CMP VDECODE[8],1110b		; OPERAND2 가 X
   JE DIV_C_X
   CMP VDECODE[8],1111b		; OPERAND2 가 Y
   JE DIV_C_Y

   PRINT ERR
   JMP END_M_DIV_C_REGI_P

DIV_C_A:
	MOV BX,A				; BX에 A값을 저장
	MOV AX,C				; AX에 C값을 저장
	DIV BL					; BL값으로 C값을 DIV
   CALL SHR_F				; E,F 레지스터에 각각 몫,나머지를 저장
   JMP END_M_DIV_C_REGI_P
DIV_C_B:
	MOV BX,B				; BX에 B값을 저장
	MOV AX,C				; AX에 C값을 저장
	DIV BL					; BL값으로 C값을 DIV
	CALL SHR_F				; E,F 레지스터에 각각 몫,나머지를 저장
   JMP END_M_DIV_C_REGI_P
DIV_C_C:
   MOV BX,C				; BX에 C값을 저장
	MOV AX,C				; AX에 C값을 저장
	DIV BL					; BL값으로 C값을 DIV
   CALL SHR_F				; E,F 레지스터에 각각 몫,나머지를 저장
   JMP END_M_DIV_C_REGI_P
DIV_C_D:
   MOV BX,D				; BX에 D값을 저장
	MOV AX,C				; AX에 C값을 저장
	DIV BL					; BL값으로 C값을 DIV
   CALL SHR_F				; E,F 레지스터에 각각 몫,나머지를 저장
   JMP END_M_DIV_C_REGI_P
DIV_C_E:
   MOV BX,E				; BX에 E값을 저장
	MOV AX,C				; AX에 C값을 저장
	DIV BL					; BL값으로 C값을 DIV
   CALL SHR_F				; E,F 레지스터에 각각 몫,나머지를 저장
   JMP END_M_DIV_C_REGI_P
DIV_C_F:
   MOV BX,F				; BX에 F값을 저장
	MOV AX,C				; AX에 C값을 저장
	DIV BL					; BL값으로 C값을 DIV
   CALL SHR_F				; E,F 레지스터에 각각 몫,나머지를 저장
   JMP END_M_DIV_C_REGI_P
DIV_C_X:
   MOV BX,X				; BX에 X값을 저장
	MOV AX,C				; AX에 C값을 저장
	DIV BL					; BL값으로 C값을 DIV
   CALL SHR_F				; E,F 레지스터에 각각 몫,나머지를 저장
   JMP END_M_DIV_C_REGI_P
DIV_C_Y:
   MOV BX,Y				; BX에 Y값을 저장
	MOV AX,C				; AX에 C값을 저장
	DIV BL					; BL값으로 C값을 DIV
   CALL SHR_F				; E,F 레지스터에 각각 몫,나머지를 저장
   JMP END_M_DIV_C_REGI_P
   
   PRINT ERR
   JMP END_M_DIV_C_REGI_P

END_M_DIV_C_REGI_P:
   RET
DIV_C_REGI_P ENDP

;------------------------------------------------
;Procedure Name : DIV_C_IMME_P
;Function : DIV C, IMMEDIATE 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 28,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
DIV_C_IMME_P PROC                   ; DIV C,IMMEDIATE
   MOV DX,VDECODE[10]				; D의 값을 VDECODE[10]에 저장되어있는 IMMEDIATE값으로 DIV
   MOV AX,C
   DIV DL
   CALL SHR_F						; E,F 레지스터에 각각 몫,나머지를 저장
   RET
DIV_C_IMME_P ENDP

;------------------------------------------------
;Procedure Name : DIV_C_REGI_IMME_P
;Function : DIV C, REGISTER-IMMEDIATE 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 28,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
DIV_C_REGI_IMME_P PROC                 ; DIV C,REGISTER_IMMEDIATE
   CMP VDECODE[8],1110					; OPERAND2 값이 X
   JE DIV_C_R_I_X
   CMP VDECODE[8],1111					; OPERAND2 값이 Y
   JE DIV_C_R_I_Y
   
DIV_C_R_I_X:
   MOV SI,X								; X의 값을 SI에 저장
   MOV DX,M[SI]							; M[SI]의 값을 DX에 저장
   MOV AX,C
   DIV DL								; C의 값을 DX값으로 DIV
   CALL SHR_F						; E,F 레지스터에 각각 몫,나머지를 저장
   JMP END_M_DIV_C_REGI_IMME_P
DIV_C_R_I_Y:
   MOV SI,Y								; Y의 값을 SI에 저장
   MOV DX,M[SI]							; M[SI]의 값을 DX에 저장
   MOV AX,C
   DIV DL								; C의 값을 DX값으로 DIV
   CALL SHR_F						; E,F 레지스터에 각각 몫,나머지를 저장

END_M_DIV_C_REGI_IMME_P:
   RET
DIV_C_REGI_IMME_P ENDP

;------------------------------------------------
;Procedure Name : DIV_C_DI_P
;Function : DIV C, DIRECT 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 28,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
DIV_C_DI_P PROC                     ; DIV C,DIRECT
   MOV SI,VDECODE[10]    			; VDECODE[10]에 저장되어있는 주소값을 SI에 저장  
   MOV DX,M[SI]						; M[SI]값을 DX에 저장
   MOV AX,C
   DIV DL							; C의 값을 DX로 DIV
   CALL SHR_F
   RET
DIV_C_DI_P ENDP

;------------------------------------------------
;Procedure Name : DIV_D_P
;Function : DIV D, 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 28,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
DIV_D_P PROC

   MOV AX, VDECODE[2]
   AND AX,11b
   MOV VDECODE[2],AX
                              ; DIV D,
   CMP VDECODE[2],00b			; REGISTER 모드
   JE DIV_D_REGI
   CMP VDECODE[2],01b			; IMMEDIATE 모드
   JE DIV_D_IMME
   CMP VDECODE[2],10b			; REGISTER-INDIRECT 모드
   JE DIV_D_REGI_IMME
   CMP VDECODE[2],11b			; DIRECT 모드
   JE DIV_D_DI

   PRINT ERR
   JMP END_M_DIV_D_P

DIV_D_REGI:
   CALL DIV_D_REGI_P		; DIV_D_REGI_P 호출
   JMP END_M_DIV_D_P
DIV_D_IMME:
   CALL DIV_D_IMME_P		; DIV_D_IMME_P 호출
   JMP END_M_DIV_D_P
DIV_D_REGI_IMME:
   CALL DIV_D_REGI_IMME_P		; DIV_D_REGI_IMME_P 호출
   JMP END_M_DIV_D_P
DIV_D_DI:
   CALL DIV_D_DI_P		; DIV_D_DI_P 호출
   JMP END_M_DIV_D_P

END_M_DIV_D_P:
   RET
DIV_D_P ENDP


;------------------------------------------------
;Procedure Name : DIV_D_REGI_P
;Function : DIV D, 레지스터 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 28,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
DIV_D_REGI_P PROC
   MOV AX,VDECODE[8]                         ; DIV D,REGISTER
   AND AX,1111b
   MOV VDECODE[8],AX

   CMP VDECODE[8],1000b		; OPERAND2 가 A
   JE DIV_D_A
   CMP VDECODE[8],1001b		; OPERAND2 가 B
   JE DIV_D_B
   CMP VDECODE[8],1010b		; OPERAND2 가 C
   JE DIV_D_C
   CMP VDECODE[8],1011b		; OPERAND2 가 D
   JE DIV_D_D
   CMP VDECODE[8],1100b		; OPERAND2 가 E
   JE DIV_D_E
   CMP VDECODE[8],1101b		; OPERAND2 가 F
   JE DIV_D_F
   CMP VDECODE[8],1110b		; OPERAND2 가 X
   JE DIV_D_X
   CMP VDECODE[8],1111b		; OPERAND2 가 Y
   JE DIV_D_Y

   PRINT ERR
   JMP END_M_DIV_D_REGI_P

DIV_D_A:
	MOV BX,A				; BX에 A값을 저장
	MOV AX,D				; AX에 D값을 저장
	DIV BL					; BL값으로 D값을 DIV
   CALL SHR_F				; E,F 레지스터에 각각 몫,나머지를 저장
   JMP END_M_DIV_D_REGI_P
DIV_D_B:
	MOV BX,B				; BX에 B값을 저장
	MOV AX,D				; AX에 D값을 저장
	DIV BL					; BL값으로 D값을 DIV
	CALL SHR_F				; E,F 레지스터에 각각 몫,나머지를 저장
   JMP END_M_DIV_D_REGI_P
DIV_D_C:
   MOV BX,C				; BX에 C값을 저장
	MOV AX,D				; AX에 D값을 저장
	DIV BL					; BL값으로 D값을 DIV
   CALL SHR_F				; E,F 레지스터에 각각 몫,나머지를 저장
   JMP END_M_DIV_D_REGI_P
DIV_D_D:
   MOV BX,D				; BX에 D값을 저장
	MOV AX,D				; AX에 D값을 저장
	DIV BL					; BL값으로 D값을 DIV
   CALL SHR_F				; E,F 레지스터에 각각 몫,나머지를 저장
   JMP END_M_DIV_D_REGI_P
DIV_D_E:
   MOV BX,E				; BX에 E값을 저장
	MOV AX,D				; AX에 D값을 저장
	DIV BL					; BL값으로 D값을 DIV
   CALL SHR_F				; E,F 레지스터에 각각 몫,나머지를 저장
   JMP END_M_DIV_D_REGI_P
DIV_D_F:
   MOV BX,F				; BX에 F값을 저장
	MOV AX,D				; AX에 D값을 저장
	DIV BL					; BL값으로 D값을 DIV
   CALL SHR_F				; E,F 레지스터에 각각 몫,나머지를 저장
   JMP END_M_DIV_D_REGI_P
DIV_D_X:
   MOV BX,X				; BX에 X값을 저장
	MOV AX,D				; AX에 D값을 저장
	DIV BL					; BL값으로 D값을 DIV
   CALL SHR_F				; E,F 레지스터에 각각 몫,나머지를 저장
   JMP END_M_DIV_D_REGI_P
DIV_D_Y:
   MOV BX,Y				; BX에 Y값을 저장
	MOV AX,D				; AX에 D값을 저장
	DIV BL					; BL값으로 D값을 DIV
   CALL SHR_F				; E,F 레지스터에 각각 몫,나머지를 저장
   JMP END_M_DIV_D_REGI_P
   
   PRINT ERR
   JMP END_M_DIV_D_REGI_P

END_M_DIV_D_REGI_P:
   RET
DIV_D_REGI_P ENDP

;------------------------------------------------
;Procedure Name : DIV_D_IMME_P
;Function : DIV D, IMMEDIATE 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 28,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
DIV_D_IMME_P PROC                   ; DIV D,IMMEDIATE
   MOV DX,VDECODE[10]				; D의 값을 VDECODE[10]에 저장되어있는 IMMEDIATE값으로 DIV
   MOV AX,D
   DIV DL
   CALL SHR_F						; E,F 레지스터에 각각 몫,나머지를 저장
   RET
DIV_D_IMME_P ENDP

;------------------------------------------------
;Procedure Name : DIV_D_REGI_IMME_P
;Function : DIV D, REGISTER-IMMEDIATE 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 28,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
DIV_D_REGI_IMME_P PROC                 ; DIV D,REGISTER_IMMEDIATE
   CMP VDECODE[8],1110					; OPERAND2 값이 X
   JE DIV_D_R_I_X
   CMP VDECODE[8],1111					; OPERAND2 값이 Y
   JE DIV_D_R_I_Y
   
DIV_D_R_I_X:
   MOV SI,X								; X의 값을 SI에 저장
   MOV DX,M[SI]							; M[SI]의 값을 DX에 저장
   MOV AX,D
   DIV DL								; D의 값을 DX값으로 DIV
   CALL SHR_F						; E,F 레지스터에 각각 몫,나머지를 저장
   JMP END_M_DIV_D_REGI_IMME_P
DIV_D_R_I_Y:
   MOV SI,Y								; Y의 값을 SI에 저장
   MOV DX,M[SI]							; M[SI]의 값을 DX에 저장
   MOV AX,D
   DIV DL								; D의 값을 DX값으로 DIV
   CALL SHR_F						; E,F 레지스터에 각각 몫,나머지를 저장

END_M_DIV_D_REGI_IMME_P:
   RET
DIV_D_REGI_IMME_P ENDP

;------------------------------------------------
;Procedure Name : DIV_D_DI_P
;Function : DIV D, DIRECT 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 28,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
DIV_D_DI_P PROC                     ; DIV D,DIRECT
   MOV SI,VDECODE[10]    			; VDECODE[10]에 저장되어있는 주소값을 SI에 저장   
   MOV DX,M[SI]						; M[SI]값을 DX에 저장
   MOV AX,D
   DIV DL							; D의 값을 DX로 DIV
   CALL SHR_F
   RET
DIV_D_DI_P ENDP

;------------------------------------------------
;Procedure Name : DIV_E_P
;Function : DIV E, 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 28,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
DIV_E_P PROC

   MOV AX, VDECODE[2]
   AND AX,11b
   MOV VDECODE[2],AX
                              ; DIV E,
   CMP VDECODE[2],00b			; REGISTER 모드
   JE DIV_E_REGI
   CMP VDECODE[2],01b			; IMMEDIATE 모드
   JE DIV_E_IMME
   CMP VDECODE[2],10b			; REGISTER-INDIRECT 모드
   JE DIV_E_REGI_IMME
   CMP VDECODE[2],11b			; DIRECT 모드
   JE DIV_E_DI

   PRINT ERR
   JMP END_M_DIV_E_P

DIV_E_REGI:
   CALL DIV_E_REGI_P		; DIV_E_REGI_P 호출
   JMP END_M_DIV_E_P
DIV_E_IMME:
   CALL DIV_E_IMME_P		; DIV_E_IMME_P 호출
   JMP END_M_DIV_E_P
DIV_E_REGI_IMME:
   CALL DIV_E_REGI_IMME_P		; DIV_E_REGI_IMME_P 호출
   JMP END_M_DIV_E_P
DIV_E_DI:
   CALL DIV_E_DI_P		; DIV_E_DI_P 호출
   JMP END_M_DIV_E_P

END_M_DIV_E_P:
   RET
DIV_E_P ENDP

;------------------------------------------------
;Procedure Name : DIV_E_REGI_P
;Function : DIV E, 레지스터 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 28,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
DIV_E_REGI_P PROC
   MOV AX,VDECODE[8]                         ; DIV E,REGISTER
   AND AX,1111b
   MOV VDECODE[8],AX

   CMP VDECODE[8],1000b		; OPERAND2 가 A
   JE DIV_E_A
   CMP VDECODE[8],1001b		; OPERAND2 가 B
   JE DIV_E_B
   CMP VDECODE[8],1010b		; OPERAND2 가 C
   JE DIV_E_C
   CMP VDECODE[8],1011b		; OPERAND2 가 D
   JE DIV_E_D
   CMP VDECODE[8],1100b		; OPERAND2 가 E
   JE DIV_E_E
   CMP VDECODE[8],1101b		; OPERAND2 가 F
   JE DIV_E_F
   CMP VDECODE[8],1110b		; OPERAND2 가 X
   JE DIV_E_X
   CMP VDECODE[8],1111b		; OPERAND2 가 Y
   JE DIV_E_Y

   PRINT ERR
   JMP END_M_DIV_E_REGI_P

DIV_E_A:
	MOV BX,A				; BX에 A값을 저장
	MOV AX,E				; AX에 E값을 저장
	DIV BL					; BL값으로 E값을 DIV
   CALL SHR_F				; E,F 레지스터에 각각 몫,나머지를 저장
   JMP END_M_DIV_E_REGI_P
DIV_E_B:
	MOV BX,B				; BX에 B값을 저장
	MOV AX,E				; AX에 E값을 저장
	DIV BL					; BL값으로 E값을 DIV
	CALL SHR_F				; E,F 레지스터에 각각 몫,나머지를 저장
   JMP END_M_DIV_E_REGI_P
DIV_E_C:
   MOV BX,C				; BX에 C값을 저장
	MOV AX,E				; AX에 E값을 저장
	DIV BL					; BL값으로 E값을 DIV
   CALL SHR_F				; E,F 레지스터에 각각 몫,나머지를 저장
   JMP END_M_DIV_E_REGI_P
DIV_E_D:
   MOV BX,D				; BX에 D값을 저장
	MOV AX,E				; AX에 E값을 저장
	DIV BL					; BL값으로 E값을 DIV
   CALL SHR_F				; E,F 레지스터에 각각 몫,나머지를 저장
   JMP END_M_DIV_E_REGI_P
DIV_E_E:
   MOV BX,E				; BX에 E값을 저장
	MOV AX,E				; AX에 E값을 저장
	DIV BL					; BL값으로 E값을 DIV
   CALL SHR_F				; E,F 레지스터에 각각 몫,나머지를 저장
   JMP END_M_DIV_E_REGI_P
DIV_E_F:
   MOV BX,F				; BX에 F값을 저장
	MOV AX,E				; AX에 E값을 저장
	DIV BL					; BL값으로 E값을 DIV
   CALL SHR_F				; E,F 레지스터에 각각 몫,나머지를 저장
   JMP END_M_DIV_E_REGI_P
DIV_E_X:
   MOV BX,X				; BX에 X값을 저장
	MOV AX,E				; AX에 E값을 저장
	DIV BL					; BL값으로 E값을 DIV
   CALL SHR_F				; E,F 레지스터에 각각 몫,나머지를 저장
   JMP END_M_DIV_E_REGI_P
DIV_E_Y:
   MOV BX,Y				; BX에 Y값을 저장
	MOV AX,E				; AX에 E값을 저장
	DIV BL					; BL값으로 E값을 DIV
   CALL SHR_F				; E,F 레지스터에 각각 몫,나머지를 저장
   JMP END_M_DIV_E_REGI_P
   
   PRINT ERR
   JMP END_M_DIV_E_REGI_P

END_M_DIV_E_REGI_P:
   RET
DIV_E_REGI_P ENDP

;------------------------------------------------
;Procedure Name : DIV_E_IMME_P
;Function : DIV E, IMMEDIATE 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 28,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
DIV_E_IMME_P PROC                   ; DIV E,IMMEDIATE
   MOV DX,VDECODE[10]				; E의 값을 VDECODE[10]에 저장되어있는 IMMEDIATE값으로 DIV
   MOV AX,E
   DIV DL
   CALL SHR_F						; E,F 레지스터에 각각 몫,나머지를 저장
   RET
DIV_E_IMME_P ENDP

;------------------------------------------------
;Procedure Name : DIV_E_REGI_IMME_P
;Function : DIV E, REGISTER-IMMEDIATE 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 28,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
DIV_E_REGI_IMME_P PROC                 ; DIV E,REGISTER_IMMEDIATE
   CMP VDECODE[8],1110					; OPERAND2 값이 X
   JE DIV_E_R_I_X
   CMP VDECODE[8],1111					; OPERAND2 값이 Y
   JE DIV_E_R_I_Y
   
DIV_E_R_I_X:
   MOV SI,X								; X의 값을 SI에 저장
   MOV DX,M[SI]							; M[SI]의 값을 DX에 저장
   MOV AX,E
   DIV DL								; E의 값을 DX값으로 DIV
   CALL SHR_F						; E,F 레지스터에 각각 몫,나머지를 저장
   JMP END_M_DIV_E_REGI_IMME_P
DIV_E_R_I_Y:
   MOV SI,Y								; Y의 값을 SI에 저장
   MOV DX,M[SI]							; M[SI]의 값을 DX에 저장
   MOV AX,E
   DIV DL								; E의 값을 DX값으로 DIV
   CALL SHR_F						; E,F 레지스터에 각각 몫,나머지를 저장

END_M_DIV_E_REGI_IMME_P:
   RET
DIV_E_REGI_IMME_P ENDP

;------------------------------------------------
;Procedure Name : DIV_E_DI_P
;Function : DIV E, DIRECT 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 28,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
DIV_E_DI_P PROC                     ; DIV E,DIRECT
   MOV SI,VDECODE[10]    			; VDECODE[10]에 저장되어있는 주소값을 SI에 저장   
   MOV DX,M[SI]						; M[SI]값을 DX에 저장
   MOV AX,E
   DIV DL							; E의 값을 DX로 DIV
   CALL SHR_F
   RET
DIV_E_DI_P ENDP

;------------------------------------------------
;Procedure Name : DIV_F_P
;Function : DIV F, 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 28,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
DIV_F_P PROC

   MOV AX, VDECODE[2]
   AND AX,11b
   MOV VDECODE[2],AX
                              ; DIV F,
   CMP VDECODE[2],00b			; REGISTER 모드
   JE DIV_F_REGI
   CMP VDECODE[2],01b			; IMMEDIATE 모드
   JE DIV_F_IMME
   CMP VDECODE[2],10b			; REGISTER-INDIRECT 모드
   JE DIV_F_REGI_IMME
   CMP VDECODE[2],11b			; DIRECT 모드
   JE DIV_F_DI

   PRINT ERR
   JMP END_M_DIV_F_P

DIV_F_REGI:
   CALL DIV_F_REGI_P		; DIV_F_REGI_P 호출
   JMP END_M_DIV_F_P
DIV_F_IMME:
   CALL DIV_F_IMME_P		; DIV_F_IMME_P 호출
   JMP END_M_DIV_F_P
DIV_F_REGI_IMME:
   CALL DIV_F_REGI_IMME_P		; DIV_F_REGI_IMME_P 호출
   JMP END_M_DIV_F_P
DIV_F_DI:
   CALL DIV_F_DI_P		; DIV_F_DI_P 호출
   JMP END_M_DIV_F_P

END_M_DIV_F_P:
   RET
DIV_F_P ENDP

;------------------------------------------------
;Procedure Name : DIV_F_REGI_P
;Function : DIV F, 레지스터 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 28,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
DIV_F_REGI_P PROC
   MOV AX,VDECODE[8]                         ; DIV F,REGISTER
   AND AX,1111b
   MOV VDECODE[8],AX

   CMP VDECODE[8],1000b		; OPERAND2 가 A
   JE DIV_F_A
   CMP VDECODE[8],1001b		; OPERAND2 가 B
   JE DIV_F_B
   CMP VDECODE[8],1010b		; OPERAND2 가 C
   JE DIV_F_C
   CMP VDECODE[8],1011b		; OPERAND2 가 D
   JE DIV_F_D
   CMP VDECODE[8],1100b		; OPERAND2 가 E
   JE DIV_F_E
   CMP VDECODE[8],1101b		; OPERAND2 가 F
   JE DIV_F_F
   CMP VDECODE[8],1110b		; OPERAND2 가 X
   JE DIV_F_X
   CMP VDECODE[8],1111b		; OPERAND2 가 Y
   JE DIV_F_Y

   PRINT ERR
   JMP END_M_DIV_F_REGI_P

DIV_F_A:
	MOV BX,A				; BX에 A값을 저장
	MOV AX,F				; AX에 F값을 저장
	DIV BL					; BL값으로 F값을 DIV
   CALL SHR_F				; E,F 레지스터에 각각 몫,나머지를 저장
   JMP END_M_DIV_F_REGI_P
DIV_F_B:
	MOV BX,B				; BX에 B값을 저장
	MOV AX,F				; AX에 F값을 저장
	DIV BL					; BL값으로 F값을 DIV
	CALL SHR_F				; E,F 레지스터에 각각 몫,나머지를 저장
   JMP END_M_DIV_F_REGI_P
DIV_F_C:
   MOV BX,C				; BX에 C값을 저장
	MOV AX,F				; AX에 F값을 저장
	DIV BL					; BL값으로 F값을 DIV
   CALL SHR_F				; E,F 레지스터에 각각 몫,나머지를 저장
   JMP END_M_DIV_F_REGI_P
DIV_F_D:
   MOV BX,D				; BX에 D값을 저장
	MOV AX,F				; AX에 F값을 저장
	DIV BL					; BL값으로 F값을 DIV
   CALL SHR_F				; E,F 레지스터에 각각 몫,나머지를 저장
   JMP END_M_DIV_F_REGI_P
DIV_F_E:
   MOV BX,E				; BX에 E값을 저장
	MOV AX,F				; AX에 F값을 저장
	DIV BL					; BL값으로 F값을 DIV
   CALL SHR_F				; E,F 레지스터에 각각 몫,나머지를 저장
   JMP END_M_DIV_F_REGI_P
DIV_F_F:
   MOV BX,F				; BX에 F값을 저장
	MOV AX,F				; AX에 F값을 저장
	DIV BL					; BL값으로 F값을 DIV
   CALL SHR_F				; E,F 레지스터에 각각 몫,나머지를 저장
   JMP END_M_DIV_F_REGI_P
DIV_F_X:
   MOV BX,X				; BX에 X값을 저장
	MOV AX,F				; AX에 F값을 저장
	DIV BL					; BL값으로 F값을 DIV
   CALL SHR_F				; E,F 레지스터에 각각 몫,나머지를 저장
   JMP END_M_DIV_F_REGI_P
DIV_F_Y:
   MOV BX,Y				; BX에 Y값을 저장
	MOV AX,F				; AX에 F값을 저장
	DIV BL					; BL값으로 F값을 DIV
   CALL SHR_F				; E,F 레지스터에 각각 몫,나머지를 저장
   JMP END_M_DIV_F_REGI_P
   
   PRINT ERR
   JMP END_M_DIV_F_REGI_P

END_M_DIV_F_REGI_P:
   RET
DIV_F_REGI_P ENDP

;------------------------------------------------
;Procedure Name : DIV_F_IMME_P
;Function : DIV F, IMMEDIATE 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 28,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
DIV_F_IMME_P PROC                   ; DIV F,IMMEDIATE
   MOV DX,VDECODE[10]				; E의 값을 VDECODE[10]에 저장되어있는 IMMEDIATE값으로 DIV
   MOV AX,F
   DIV DL
   CALL SHR_F						; E,F 레지스터에 각각 몫,나머지를 저장
   RET
DIV_F_IMME_P ENDP

DIV_F_REGI_IMME_P PROC                 ; DIV F,REGISTER_IMMEDIATE
   CMP VDECODE[8],1110					; OPERAND2 값이 X
   JE DIV_F_R_I_X
   CMP VDECODE[8],1111					; OPERAND2 값이 Y
   JE DIV_F_R_I_Y
   
DIV_F_R_I_X:
   MOV SI,X								; X의 값을 SI에 저장
   MOV DX,M[SI]							; M[SI]의 값을 DX에 저장
   MOV AX,F
   DIV DL								; F의 값을 DX값으로 DIV
   CALL SHR_F						; E,F 레지스터에 각각 몫,나머지를 저장
   JMP END_M_DIV_F_REGI_IMME_P
DIV_F_R_I_Y:
   MOV SI,Y								; Y의 값을 SI에 저장
   MOV DX,M[SI]							; M[SI]의 값을 DX에 저장
   MOV AX,F
   DIV DL								; F의 값을 DX값으로 DIV
   CALL SHR_F						; E,F 레지스터에 각각 몫,나머지를 저장

END_M_DIV_F_REGI_IMME_P:
   RET
DIV_F_REGI_IMME_P ENDP

;------------------------------------------------
;Procedure Name : DIV_F_DI_P
;Function : DIV F, DIRECT 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 28,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
DIV_F_DI_P PROC                     ; DIV F,DIRECT
   MOV SI,VDECODE[10]    			; VDECODE[10]에 저장되어있는 주소값을 SI에 저장   
   MOV DX,M[SI]						; M[SI]값을 DX에 저장
   MOV AX,F
   DIV DL							; F의 값을 DX로 DIV
   CALL SHR_F
   RET
DIV_F_DI_P ENDP

;------------------------------------------------
;Procedure Name : DIV_X_P
;Function : DIV X, 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 28,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
DIV_X_P PROC

   MOV AX, VDECODE[2]
   AND AX,11b
   MOV VDECODE[2],AX
                              ; DIV X,
   CMP VDECODE[2],00b			; REGISTER 모드
   JE DIV_X_REGI
   CMP VDECODE[2],01b			; IMMEDIATE 모드
   JE DIV_X_IMME
   CMP VDECODE[2],10b			; REGISTER-INDIRECT 모드
   JE DIV_X_REGI_IMME
   CMP VDECODE[2],11b			; DIRECT 모드
   JE DIV_X_DI

   PRINT ERR
   JMP END_M_DIV_X_P

DIV_X_REGI:
   CALL DIV_X_REGI_P		; DIV_X_REGI_P 호출
   JMP END_M_DIV_X_P
DIV_X_IMME:
   CALL DIV_X_IMME_P		; DIV_X_IMME_P 호출
   JMP END_M_DIV_X_P
DIV_X_REGI_IMME:
   CALL DIV_X_REGI_IMME_P		; DIV_X_REGI_IMME_P 호출
   JMP END_M_DIV_X_P
DIV_X_DI:
   CALL DIV_X_DI_P		; DIV_X_DI_P 호출
   JMP END_M_DIV_X_P

END_M_DIV_X_P:
   RET
DIV_X_P ENDP

;------------------------------------------------
;Procedure Name : DIV_X_REGI_P
;Function : DIV X, 레지스터 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 28,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
DIV_X_REGI_P PROC
   MOV AX,VDECODE[8]                         ; DIV X,REGISTER
   AND AX,1111b
   MOV VDECODE[8],AX

   CMP VDECODE[8],1000b		; OPERAND2 가 A
   JE DIV_X_A
   CMP VDECODE[8],1001b		; OPERAND2 가 B
   JE DIV_X_B
   CMP VDECODE[8],1010b		; OPERAND2 가 C
   JE DIV_X_C
   CMP VDECODE[8],1011b		; OPERAND2 가 D
   JE DIV_X_D
   CMP VDECODE[8],1100b		; OPERAND2 가 E
   JE DIV_X_E
   CMP VDECODE[8],1101b		; OPERAND2 가 F
   JE DIV_X_F
   CMP VDECODE[8],1110b		; OPERAND2 가 X
   JE DIV_X_X
   CMP VDECODE[8],1111b		; OPERAND2 가 Y
   JE DIV_X_Y

   PRINT ERR
   JMP END_M_DIV_X_REGI_P

DIV_X_A:
	MOV BX,A				; BX에 A값을 저장
	MOV AX,X				; AX에 X값을 저장
	DIV BL					; BL값으로 X값을 DIV
   CALL SHR_F				; E,F 레지스터에 각각 몫,나머지를 저장
   JMP END_M_DIV_X_REGI_P
DIV_X_B:
	MOV BX,B				; BX에 B값을 저장
	MOV AX,X				; AX에 X값을 저장
	DIV BL					; BL값으로 X값을 DIV
	CALL SHR_F				; E,F 레지스터에 각각 몫,나머지를 저장
   JMP END_M_DIV_X_REGI_P
DIV_X_C:
   MOV BX,C				; BX에 C값을 저장
	MOV AX,X				; AX에 X값을 저장
	DIV BL					; BL값으로 X값을 DIV
   CALL SHR_F				; E,F 레지스터에 각각 몫,나머지를 저장
   JMP END_M_DIV_X_REGI_P
DIV_X_D:
   MOV BX,D				; BX에 D값을 저장
	MOV AX,X				; AX에 X값을 저장
	DIV BL					; BL값으로 X값을 DIV
   CALL SHR_F				; E,F 레지스터에 각각 몫,나머지를 저장
   JMP END_M_DIV_X_REGI_P
DIV_X_E:
   MOV BX,E				; BX에 E값을 저장
	MOV AX,X				; AX에 X값을 저장
	DIV BL					; BL값으로 X값을 DIV
   CALL SHR_F				; E,F 레지스터에 각각 몫,나머지를 저장
   JMP END_M_DIV_X_REGI_P
DIV_X_F:
   MOV BX,F				; BX에 F값을 저장
	MOV AX,X				; AX에 X값을 저장
	DIV BL					; BL값으로 X값을 DIV
   CALL SHR_F				; E,F 레지스터에 각각 몫,나머지를 저장
   JMP END_M_DIV_X_REGI_P
DIV_X_X:
   MOV BX,X				; BX에 X값을 저장
	MOV AX,X				; AX에 X값을 저장
	DIV BL					; BL값으로 X값을 DIV
   CALL SHR_F				; E,F 레지스터에 각각 몫,나머지를 저장
   JMP END_M_DIV_X_REGI_P
DIV_X_Y:
   MOV BX,Y				; BX에 Y값을 저장
	MOV AX,X				; AX에 X값을 저장
	DIV BL					; BL값으로 X값을 DIV
   CALL SHR_F				; E,F 레지스터에 각각 몫,나머지를 저장
   JMP END_M_DIV_X_REGI_P
   
   PRINT ERR
   JMP END_M_DIV_X_REGI_P

END_M_DIV_X_REGI_P:
   RET
DIV_X_REGI_P ENDP

;------------------------------------------------
;Procedure Name : DIV_X_IMME_P
;Function : DIV X, IMMEDIATE 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 28,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
DIV_X_IMME_P PROC                   ; DIV X,IMMEDIATE
   MOV DX,VDECODE[10]				; E의 값을 VDECODE[10]에 저장되어있는 IMMEDIATE값으로 DIV
   MOV AX,X
   DIV DL
   CALL SHR_F						; E,F 레지스터에 각각 몫,나머지를 저장
   RET
DIV_X_IMME_P ENDP

DIV_X_REGI_IMME_P PROC                 ; DIV X,REGISTER_IMMEDIATE
   CMP VDECODE[8],1110					; OPERAND2 값이 X
   JE DIV_X_R_I_X
   CMP VDECODE[8],1111					; OPERAND2 값이 Y
   JE DIV_X_R_I_Y
   
DIV_X_R_I_X:
   MOV SI,X								; X의 값을 SI에 저장
   MOV DX,M[SI]							; M[SI]의 값을 DX에 저장
   MOV AX,X
   DIV DL								; X의 값을 DX값으로 DIV
   CALL SHR_F						; E,F 레지스터에 각각 몫,나머지를 저장
   JMP END_M_DIV_X_REGI_IMME_P
DIV_X_R_I_Y:
   MOV SI,Y								; Y의 값을 SI에 저장
   MOV DX,M[SI]							; M[SI]의 값을 DX에 저장
   MOV AX,X
   DIV DL								; F의 값을 DX값으로 DIV
   CALL SHR_F						; E,F 레지스터에 각각 몫,나머지를 저장

END_M_DIV_X_REGI_IMME_P:
   RET
DIV_X_REGI_IMME_P ENDP

;------------------------------------------------
;Procedure Name : DIV_X_DI_P
;Function : DIV X, DIRECT 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 28,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
DIV_X_DI_P PROC                     ; DIV X,DIRECT
   MOV SI,VDECODE[10]    			; VDECODE[10]에 저장되어있는 주소값을 SI에 저장   
   MOV DX,M[SI]						; M[SI]값을 DX에 저장
   MOV AX,X
   DIV DL							; X의 값을 DX로 DIV
   CALL SHR_F
   RET
DIV_X_DI_P ENDP

;------------------------------------------------
;Procedure Name : DIV_Y_P
;Function : DIV Y, 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 28,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
DIV_Y_P PROC

   MOV AX, VDECODE[2]
   AND AX,11b
   MOV VDECODE[2],AX
                              ; DIV Y,
   CMP VDECODE[2],00b			; REGISTER 모드
   JE DIV_Y_REGI
   CMP VDECODE[2],01b			; IMMEDIATE 모드
   JE DIV_Y_IMME
   CMP VDECODE[2],10b			; REGISTER-INDIRECT 모드
   JE DIV_Y_REGI_IMME
   CMP VDECODE[2],11b			; DIRECT 모드
   JE DIV_Y_DI

   PRINT ERR
   JMP END_M_DIV_Y_P

DIV_Y_REGI:
   CALL DIV_Y_REGI_P		; DIV_Y_REGI_P 호출
   JMP END_M_DIV_Y_P
DIV_Y_IMME:
   CALL DIV_Y_IMME_P		; DIV_Y_IMME_P 호출
   JMP END_M_DIV_Y_P
DIV_Y_REGI_IMME:
   CALL DIV_Y_REGI_IMME_P		; DIV_Y_REGI_IMME_P 호출
   JMP END_M_DIV_Y_P
DIV_Y_DI:
   CALL DIV_Y_DI_P		; DIV_Y_DI_P 호출
   JMP END_M_DIV_Y_P

END_M_DIV_Y_P:
   RET
DIV_Y_P ENDP

;------------------------------------------------
;Procedure Name : DIV_Y_REGI_P
;Function : DIV Y, 레지스터 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 28,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
DIV_Y_REGI_P PROC
   MOV AX,VDECODE[8]                         ; DIV Y,REGISTER
   AND AX,1111b
   MOV VDECODE[8],AX

   CMP VDECODE[8],1000b		; OPERAND2 가 A
   JE DIV_Y_A
   CMP VDECODE[8],1001b		; OPERAND2 가 B
   JE DIV_Y_B
   CMP VDECODE[8],1010b		; OPERAND2 가 C
   JE DIV_Y_C
   CMP VDECODE[8],1011b		; OPERAND2 가 D
   JE DIV_Y_D
   CMP VDECODE[8],1100b		; OPERAND2 가 E
   JE DIV_Y_E
   CMP VDECODE[8],1101b		; OPERAND2 가 F
   JE DIV_Y_F
   CMP VDECODE[8],1110b		; OPERAND2 가 X
   JE DIV_Y_X
   CMP VDECODE[8],1111b		; OPERAND2 가 Y
   JE DIV_Y_Y

   PRINT ERR
   JMP END_M_DIV_Y_REGI_P

DIV_Y_A:
	MOV BX,A				; BX에 A값을 저장
	MOV AX,Y				; AX에 Y값을 저장
	DIV BL					; BL값으로 Y값을 DIV
   CALL SHR_F				; E,F 레지스터에 각각 몫,나머지를 저장
   JMP END_M_DIV_Y_REGI_P
DIV_Y_B:
	MOV BX,B				; BX에 B값을 저장
	MOV AX,Y				; AX에 Y값을 저장
	DIV BL					; BL값으로 Y값을 DIV
	CALL SHR_F				; E,F 레지스터에 각각 몫,나머지를 저장
   JMP END_M_DIV_Y_REGI_P
DIV_Y_C:
    MOV BX,C				; BX에 C값을 저장
	MOV AX,Y				; AX에 Y값을 저장
	DIV BL					; BL값으로 Y값을 DIV
   CALL SHR_F				; E,F 레지스터에 각각 몫,나머지를 저장
   JMP END_M_DIV_Y_REGI_P
DIV_Y_D:
   MOV BX,D				; BX에 D값을 저장
	MOV AX,Y				; AX에 Y값을 저장
	DIV BL					; BL값으로 Y값을 DIV
   CALL SHR_F				; E,F 레지스터에 각각 몫,나머지를 저장
   JMP END_M_DIV_Y_REGI_P
DIV_Y_E:
   MOV BX,E				; BX에 E값을 저장
	MOV AX,Y				; AX에 Y값을 저장
	DIV BL					; BL값으로 Y값을 DIV
   CALL SHR_F				; E,F 레지스터에 각각 몫,나머지를 저장
   JMP END_M_DIV_Y_REGI_P
DIV_Y_F:
   MOV BX,F				; BX에 F값을 저장
	MOV AX,Y				; AX에 Y값을 저장
	DIV BL					; BL값으로 Y값을 DIV
   CALL SHR_F				; E,F 레지스터에 각각 몫,나머지를 저장
   JMP END_M_DIV_Y_REGI_P
DIV_Y_X:
   MOV BX,X				; BX에 X값을 저장
	MOV AX,Y				; AX에 Y값을 저장
	DIV BL					; BL값으로 Y값을 DIV
   CALL SHR_F				; E,F 레지스터에 각각 몫,나머지를 저장
   JMP END_M_DIV_Y_REGI_P
DIV_Y_Y:
   MOV BX,Y				; BX에 Y값을 저장
	MOV AX,Y				; AX에 Y값을 저장
	DIV BL					; BL값으로 Y값을 DIV
   CALL SHR_F				; E,F 레지스터에 각각 몫,나머지를 저장
   JMP END_M_DIV_Y_REGI_P
   
   PRINT ERR
   JMP END_M_DIV_Y_REGI_P

END_M_DIV_Y_REGI_P:
   RET
DIV_Y_REGI_P ENDP

;------------------------------------------------
;Procedure Name : DIV_Y_IMME_P
;Function : DIV Y, IMMEDIATE 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 28,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
DIV_Y_IMME_P PROC                   ; DIV Y,IMMEDIATE
   MOV DX,VDECODE[10]				; E의 값을 VDECODE[10]에 저장되어있는 IMMEDIATE값으로 DIV
   MOV AX,Y
   DIV DL
   CALL SHR_F						; E,F 레지스터에 각각 몫,나머지를 저장
   RET
DIV_Y_IMME_P ENDP

DIV_Y_REGI_IMME_P PROC                 ; DIV Y,REGISTER_IMMEDIATE
   CMP VDECODE[8],1110					; OPERAND2 값이 X
   JE DIV_Y_R_I_X
   CMP VDECODE[8],1111					; OPERAND2 값이 Y
   JE DIV_Y_R_I_Y
   
DIV_Y_R_I_X:
   MOV SI,X								; X의 값을 SI에 저장
   MOV DX,M[SI]							; M[SI]의 값을 DX에 저장
   MOV AX,Y
   DIV DL								; Y의 값을 DX값으로 DIV
   CALL SHR_F						; E,F 레지스터에 각각 몫,나머지를 저장
   JMP END_M_DIV_Y_REGI_IMME_P
DIV_Y_R_I_Y:
   MOV SI,Y								; Y의 값을 SI에 저장
   MOV DX,M[SI]							; M[SI]의 값을 DX에 저장
   MOV AX,Y
   DIV DL								; Y의 값을 DX값으로 DIV
   CALL SHR_F						; E,F 레지스터에 각각 몫,나머지를 저장

END_M_DIV_Y_REGI_IMME_P:
   RET
DIV_Y_REGI_IMME_P ENDP

;------------------------------------------------
;Procedure Name : DIV_Y_DI_P
;Function : DIV Y, DIRECT 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 28,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
DIV_Y_DI_P PROC                     ; DIV Y,DIRECT
   MOV SI,VDECODE[10]      			; VDECODE[10]에 저장되어있는 주소값을 SI에 저장 
   MOV DX,M[SI]						; M[SI]값을 DX에 저장
   MOV AX,Y
   DIV DL							; Y의 값을 DX로 DIV
   CALL SHR_F
   RET
DIV_Y_DI_P ENDP

;------------------------------------------------
;Procedure Name : SHR_F
;Function : AX의 값을 DX로 나눠서 E,F에 몫, 나머지를 저장해주는 기능을 구현
;PROGRAMED BY 장재훈
;PROGRAM VERSION
;   Creation Date :Nov 28,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
SHR_F PROC							; E, F에 몫, 나머지 저장해주는 PROC
   MOV E,AX						; E에 몫 저장
   AND E,0000000011111111b
   MOV F,AX						; F에 나머지 저장
   AND F,1111111100000000b

	MOV CX,8
LL1:													; F의 값을 SHR 8칸 해준다
	CMP CX,0
	JE END_P_SHR_F
	SHR F,1
	DEC CX
	JMP LL1
END_P_SHR_F:
	RET
SHR_F ENDP

MAIN ENDS

DATA SEGMENT
   MODE DB 01h
   A DW 0000h
   B DW 0000h
   C DW 0000h
   D DW 0000h
   E DW 0000h
   F DW 0000h
   X DW 0000h
   Y DW 0000h
   PC DW 0000h,'$'
   MAR DW 00h,'$'
   MBR DW 00h,'$'
   IR DW 00h,'$'
   STACK_RG DW 00h,'$'
   PROGRAM_RG DW 00h,'$'
   STATUS_RG DW 0000h,'$'
   INSTRUCTION_RG DW 00h,'$'
   TEMP_RG DW (?),'$'
   M DW 4096 dup(0)
   IST DW 30  dup('$')
   SAVE_M DW 4096 dup('$')
   SAVE_CNT DW 2 dup(0)
   SAVE_DI DW 2 dup('$')
   SAVE_DI2 DW 2 dup('$')
   INTERRUPT_SWITCH DB ('$')
   GET_NUM DB 4 dup(0)
   STR_A DB ' A : $'
   STR_B DB ' B : $'
   STR_C DB ' C : $'
   STR_D DB ' D : $'
   STR_E DB ' E : $'
   STR_F DB ' F : $'
   STR_X DB ' X : $'
   STR_Y DB ' Y : $'
   STR_PC DB ' PC : $'
   STR_MAR DB ' MAR : $'
   STR_INPUT DB '>$'
   STR_REG DB 'register>>$'
   STR_MICRO DB ' micro$'
   STR_MACRO DB ' macro$'
   STR_WRONGHEX DB '[-] Invalid hex$'
   STR_WRONGCMD DB '[-] wrong cmd$'
   STR_WRONGPC DB '[-] pc command error$'
   STR_WRONGMEM DB '[-] m command error$'
   STR_WRONGPCADDR DB '[-] wrong pc addr$'
   STR_WRONGMEMADDR DB '[-] wrong memory addr$'
   STR_WRONGMEMVAL DB '[-] wrong value$'
   STR_WRONGFUNCTION DB '[-] wrong function bit$'
   CMDLINE db 40 dup(0) ; 명령어 저장
   CMD_MEM_LEN DB 00h ; 임시 메모리 명령어 길이
   CMD_MEM_ADDR DW 0000h ; 임시 메모리 파싱 주소 
   CMD_MEM_VAL1 DW 0000h ; 임시 메모리 파싱 값
   CMD_MEM_VAL2 DW 0000h ; 임시 메모리 파싱 값

   DCD DB 4 dup('?')   ;decode를 하기위해 배열 선언
   VDECODE DW 12 dup(?)   ;opcode,operand 구분 하는 배열
   EDECODE DW 12 dup(?)   ;실행할때 opcode,operand를 구분
   ERR  DB  'ERROR $'
   STR_ITR_A DB 'IST <- A$'
   STR_ITR_B DB 'IST <- B$'
   STR_ITR_C DB 'IST <- C$'
   STR_ITR_D DB 'IST <- D$'
   STR_ITR_E DB 'IST <- E$'
   STR_ITR_F DB 'IST <- F$'
   STR_ITR_X DB 'IST <- X$'
   STR_ITR_Y DB 'IST <- Y$'
   STR_ITR_STACK DB 'IST <- STACK_RG$'
   STR_ITR_PROGRAM DB 'IST <- PROGRAM_RG$'
   STR_ITR_STATUS DB 'IST <- STATUS_RG$'
   STR_ITR_INSTRUCTION DB 'IST <- INSTRUCTION_RG$'
   STR_ITR_TEMP DB 'IST <- TEMP_RG$'
   STR_ITR_PC DB 'IST <- PC$'
   
   STR_CNT_C_MAR DB 'MAR <-$'
   STR_CNT_C_PC DB 'PC <-$'
   STR_CNT_C_IR DB 'IR <-$'
   STR_CNT_C_MBR DB 'MBR <-$'
   CNT_C DB 00h,'$'

   STR_REGI_A DB 'A$'
   STR_REGI_B DB 'B$'
   STR_REGI_C DB 'C$'
   STR_REGI_D DB 'D$'
   STR_REGI_E DB 'E$'
   STR_REGI_F DB 'F$'
   STR_REGI_X DB 'X$'
   STR_REGI_Y DB 'Y$'
   STR_NULL DB 'NULL$'

DATA ENDS

END