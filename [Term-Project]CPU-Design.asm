;------------------------------------------------
;PROGRAM NAME : CPUDesign.asm
;PURPOSE? :To design an internal structure of a processor and elevate assembly programming skill
;
; USED PROCEDURES
;	* M_RETURN_MICRO : ����ũ�θ�忡�� excution�� �� decode�ϴ� �Լ�
;	* M_RETURN : INTTRUPT���¿��� �������·� ���ư��� �Լ�
;	* MD_MICRO : ����ũ�� ��� ���� �Լ�
;	* CMD_MACRO : ��ũ�� ��� ���� �Լ�
;	* CMD_EXECUTE : ��ũ�� ��� c ��ɾ� ó�� �Լ�
;	* CMD_MEMORY : �޸� �Է��� ���� m��ɾ� ó�� �Լ�
;	* CMD_DISPLAY : ���� Register�� ���� pc�� ���� ����ϴ� �Լ�
;	* CHECK_HEX : �޸�, �ּ� �Է½� 16������ �Ľ� �Լ�
;	* CMD_PC : PC �Է� �Լ�
;	* EXIT : ���α׷� ���� �Լ�
;	* PUTC : �ɸ��� ���� ��� �Լ�
;	* NEWLINE : CRLF ��� �Լ�
;	* GETC : �ɸ��� ���� �Է� �Լ�
;	* PUTS : ���ڿ� ���� ��� �Լ�
;	* PHEX : �� ��� �Լ�
;	* DISPLAY : �������� ��� �Լ�
;	* D_OUTPUT : �޸��� �ּҿ� ��ɾ� ��� �Լ�
;	* M_JMP : JMP ��ɾ ����
;	* M_JA : JA ��ɾ ����
;	* M_JB : JB ��ɾ ����
;	* M_JE : JE ��ɾ ����
;	* M_SUB : SUB ��ɾ ����
;	* M_MOV : MOV ��ɾ ����
;	* M_ADD : ADD ��ɾ ����
;	* M_CMP : CMP ��ɾ  ����
;	* M_OR : OR ��ɾ ����
;	* M_HALT : HALT ��ɾ ����
;	* M_NOT : NOT ��ɾ ����
;	* M_AND : AND ��ɾ ����
;	* M_MUL : MUL ��ɾ ����
;	* M_SHIFT : SHIFT ��ɾ ����
;	* M_DIV : DIV ��ɾ ����
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
 print macro argument                   ; ���ڿ� ��� ��ũ��
 mov ah, 09
 mov dx, offset argument
 int 21h
 endm
   MOV MODE, 01h                         ; �⺻ ���� macro
   MOV INTERRUPT_SWITCH,0				;���ͷ�Ʈ��Ȳ���� �ƴ��� �Ǵ�
START_GETCMD:
   MOV BX, OFFSET CMDLINE
   MOV CX, 40

   MOV DL, '>'
   CALL PUTC
   MOV DL, ' '
   CALL PUTC
START_READCMD_LOOP:
   CALL GETC				;���ڸ� �Է¹޴´�.
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
   CALL CMD_MACRO		;�Է¹��� ���� 'a'�̸� macro mode�� �̵�	
   JE MACRO_GETCMD		
   CMP_MICRO:			
   CMP AL, 'u'					
   JNE CMP_EXIT				
   CALL CMD_MICRO		;�Է¹��� ���� 'u'�̸�micro mode�� �̵�
   JE MICRO_GETCMD1		
   CMP_EXIT:			
START_WRONG_CMD:				
   MOV DX, OFFSET STR_WRONGCMD	
   CALL PUTS					
   CALL NEWLINE					
   JMP START_CLEARCMD			
START_CLEARCMD:					;�Է¹������� 'a','u'�� �ƴϸ� �Է¹�������
   MOV BX, OFFSET CMDLINE		;�ʱ�ȭ �����ְ� ���� �Է¹޴°����� �̵�
   MOV CX, 40					
START_CLEARCMD_LOOP:			
   XOR AX, AX					
   MOV [BX], AL					
   INC BX						
   LOOP START_CLEARCMD_LOOP		
   JMP START_GETCMD				




MACRO_GETCMD:					;----marco mode�� ����----
   MOV BX, OFFSET CMDLINE		
   MOV CX, 40					

   MOV DL, '>'
   CALL PUTC
   MOV DL, ' '
   CALL PUTC

MACRO_READCMD_LOOP:				
   CALL GETC					;���ڸ� �Է¹޴´� 
   CMP AL, 0DH					;----------------
   JE MACRO_SWITCH				;pc #:program counter���Է�
   MOV [BX], AL					;m[#1] #2:�޸� #1(memory)�� #2(value)����
   INC BX						;u:micro mode�� ����
   LOOP MACRO_READCMD_LOOP		;e:���α׷� ����
   CMP CX, 0					;d:display
   JNE MACRO_SWITCH				;c:excute
   CALL NEWLINE					;---------------
MACRO_SWITCH:					
   MOV BX, OFFSET CMDLINE		
   CMP CX, 39					
   MOV AL, [BX]					
   JNE CASE_PC					


   CMP AL, 'u'					;�Է¹��� ���� 'u'�̸� micro mode�� ����
   JE CASE_MICRO				
   CMP AL, 'e'					;�Է¹��� ���� 'e'�̸� ���α׷� ����
   JE MACRO_CASE_EXIT			
   CMP AL, 'd'					;�Է¹��� ���� 'd'�̸� register,pc ���
   JNE MACRO_CASE_C				
   CALL D_OUTPUT				
   JE CASE_DISPLAY				
   MACRO_CASE_C:				;�Է¹��� ���� 'c'�̸� ���� pc���ִ� ��ɾ�excute
   CMP AL, 'c'					
   JE MACRO_CASE_CONTINUE		
   JNE MACRO_CMP_EXIT			
MACRO_CASE_CONTINUE:			
   CALL CMD_EXECUTE				;'c'�� �Է¹����� ���� pc�� �ִ� �� decode
   JMP MACRO_CLEARCMD	
   MICRO_GETCMD1:							;¡�˴ٸ�
   JMP MICRO_GETCMD							;¡�˴ٸ�
CASE_DISPLAY:
   CALL CMD_DISPLAY				;'d'�� �Է¹����� CMD_DISPLAY�Լ�(���� ���)�� ȣ�� 
   JMP MACRO_CLEARCMD
CASE_MICRO:
   CALL CMD_MICRO						;'u'�� �Է¹����� micro mode��
   MOV BX, OFFSET CMDLINE				;�̵��ϱ� ���� ������� �ʴ� ��������
   MOV CX, 40							;�ʱ�ȭ�����ְ�
MACRO_CLEARCMD_LOOP_To_MICRO:			;micro mode(JMP MICRO_GETCMD)�� �̵��Ѵ�
   XOR AX, AX							
   MOV [BX], AL							
   INC BX								
   LOOP MACRO_CLEARCMD_LOOP_To_MICRO	
   MOV BX,PC							
   MOV MAR,BX				; ����ũ�� ���� ������ PC���� MAR�� �����صд�
   JMP MICRO_GETCMD						
MACRO_CASE_EXIT:
   CALL EXIT

CASE_PC:					
   CMP AL, 'p'				;'pc #' �� �Է� ������
   JNE CASE_MEMORY			;pc���� #���� �ʱ�ȭ �����ش�
   MOV AL, [BX+1]			
   CMP AL, 'c'				
   JNE MACRO_WRONG_CMD		
   MOV AL, [BX+2]			
   CMP AL, ' '				
   JNE MACRO_WRONG_CMD		
   CALL CMD_PC				
   JMP MACRO_CLEARCMD		
CASE_MEMORY:				
   CMP AL, 'm'				;'m[#1] #2'�� �Է� ������ 
   JNE MACRO_WRONG_CMD		;�޸� #1(memory)�� #2(value)�� �����Ѵ�
   MOV AL, [BX+1]			
   CMP AL, '['				
   JNE MACRO_WRONG_CMD		
   CALL CMD_MEMORY			

   JMP MACRO_CLEARCMD
   MACRO_CMP_EXIT:
MACRO_WRONG_CMD:				;�޴��� ���� ���� �Է¹�����
   MOV DX, OFFSET STR_WRONGCMD	;���� �޼����� ����Ѵ�
   CALL PUTS					
   CALL NEWLINE					
   JMP MACRO_CLEARCMD			

MACRO_CLEARCMD:					;��ɾ� ó���� ������
   MOV BX, OFFSET CMDLINE		;macro mode ó������ �̵��ϱ���
   MOV CX, 40					;����ߴ� ��������
MACRO_CLEARCMD_LOOP:			;�ʱ�ȭ �����ش�
   XOR AX, AX					
   MOV [BX], AL					
   INC BX						
   LOOP MACRO_CLEARCMD_LOOP		
   JMP MACRO_GETCMD				

MICRO_GETCMD:					;----micro mode�� ����----
   MOV BX, OFFSET CMDLINE
   MOV CX, 40

   MOV DL, '>'
   CALL PUTC
   MOV DL, ' '
   CALL PUTC
MICRO_READCMD_LOOP:				
   CALL GETC					;���ڸ� �Է¹޴´�
   CMP AL, 0DH					;------------------
   JE MICRO_SWITCH				;a:Micro mode�� ����
   MOV [BX], AL					;c:Continue excution
   INC BX						;e:���α׷� ����
   LOOP MICRO_READCMD_LOOP		;i:Interrupt
   CMP CX, 0					;r:return from the last interrupt
   JNE MICRO_SWITCH				;------------------
   CALL NEWLINE					
MICRO_SWITCH:					
   MOV BX, OFFSET CMDLINE		
   CMP CX, 39					
   MOV AL, [BX]					
   JNE MICRO_CMP_EXIT		
   	

   
   CMP INTERRUPT_SWITCH,1		;'r'�� �Է¹����� 
   JNE NOT_INTERRUPT			;��return from the last interrupt
   CMP AL,'r'					
   JE CMP_CIN_R					
   JMP MICRO_CLEARCMD			
  CMP_CIN_R:					
  MOV INTERRUPT_SWITCH,0		
   JE MICRO_RETURN				
NOT_INTERRUPT:

   CMP AL, 'a'					;'a'�� �Է¹����� macro mode�� ������
   JE CASE_MACRO
   CMP AL, 'e'					;'e'�� �Է¹����� ���α׷� ����
   JE MICRO_CASE_EXIT
   CMP AL, 'i'					;'i'�� �Է¹����� interrupt�� �ɾ��ְ�
   JE MICRO_INTERRUPT			;stack�� ���� ������ش�
   CMP AL, 'c'					;'c'�� �Է¹����� ���� pc���ִ� ��ɾ�excute
   JE MICRO_CASE_CONTINUE
   JNE MICRO_CMP_EXIT

MICRO_CASE_CONTINUE:			;'c'�� �Է¹��� ��� excutiont�ܰ踦
   CALL M_CONTINUE				;3�ܰ�� ������ �����ϱ����� �Լ� ȣ��
   JMP MICRO_CLEARCMD
MICRO_INTERRUPT:
	CMP CNT_C,3					; ���ͷ�Ʈ �Ǳ����� C��ɾ 3�� ����ƴ��� Ȯ��
	JNE MICRO_CLEARCMD
	CALL M_INTERRUPT
	JMP MICRO_CLEARCMD
MICRO_RETURN:
	CALL M_RETURN				;decode�ϴ� �Լ��� ���� ��ɾ ����
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
MICRO_WRONG_CMD:				;�޴��� ���� ���� �Է¹�����
   MOV DX, OFFSET STR_WRONGCMD	;�����޼����� ����Ѵ�
   CALL PUTS					
   CALL NEWLINE					
   JMP MICRO_CLEARCMD			
MICRO_CLEARCMD:					
   MOV BX, OFFSET CMDLINE		;��ɾ� ó���� ������
   MOV CX, 40					;micro mode�� ó������ �̵��ϱ���
MICRO_CLEARCMD_LOOP:			;����ߴ� ��������
   XOR AX, AX					;�ʱ�ȭ �����ش�
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

CNT_C_0:					; MICRO ��忡�� C��ɾ ó������ �������� ��
	MOV AX,PC
	MOV MAR,AX				; MAR�� ���� PC���� ����
	ADD AX,4
	MOV PC, AX				; PC�� PC+4 ���� ����
	CALL M_RETURN_MICRO
	
	PRINT STR_CNT_C_MAR		; 'MAR <-' ���
	MOV BX,MAR
	MOV TEMP_RG,BX
	CALL PHEX					; MAR ��� 
	CALL NEWLINE
	PRINT STR_CNT_C_PC
	MOV BX,PC
	MOV TEMP_RG,BX
	CALL PHEX					; PC ���
	MOV CNT_C,01b				;CNT_C�� ���� 01b�� �����Ѵ�.
	CALL NEWLINE
	JMP END_M_CONTINUE

CNT_C_1:					; MICRO ��忡�� C��ɾ �ι�°�� �������� ��
	MOV SI,MAR
	MOV AX,M[SI]
	MOV IR,AX
	PRINT STR_CNT_C_IR
	MOV BX,IR
	MOV TEMP_RG,BX
	CALL PHEX				; M[MAR]�� �ִ� ��4BIT ���

	MOV SI,MAR
	MOV AX,M[SI+2]
	MOV IR,AX
	MOV TEMP_RG,AX
	CALL PHEX					; M[MAR+2]�� �ִ� �� 4BIT ���
	MOV CNT_C,10b				;CNT_C�� ���� 10b�� �����Ѵ�.
	CALL NEWLINE
	JMP END_M_CONTINUE

CNT_C_2:					; MICRO ��忡�� C��ɾ ����°�� �������� ��

	MOV AX,MAR
	ADD AX,4
	MOV PROGRAM_RG,AX		; MAR�� �ּҸ� PROGRAM_RG�� ����
	
	PRINT STR_CNT_C_MAR

	CMP VDECODE[0],0000b
	JE END_N_CONTINUE2
	CMP VDECODE[0],1110b	; OPERAND1�� �������� �ʴ� HALT��ɾ��̸� ��ɾ �����Ѵ�.
	JE END_M_REST
	CMP VDECODE[0],1111b		; OPERAND1�� �ּҰ��� MOV������� Ȯ���Ѵ�.
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
	MOV AX,VDECODE[4]		; OPERAND1�� ���� Ȯ���Ѵ�.
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
	MOV CNT_C,11b				;CNT_C�� ���� 11b�� �����Ѵ�.
	CALL NEWLINE

	MOV AX,PROGRAM_RG
	MOV MAR,AX				; MAR���� PROGRAM_RG������ �����Ѵ�.

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
                                          ; ��ɾ� �б�
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
;Function : Micro Mode���� Interrupt ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Dec 5,2016
;   Last Modified On Dec 5,2016
;------------------------------------------
M_INTERRUPT PROC
	MOV INTERRUPT_SWITCH,1
	MOV CNT_C,00b			; CNT_C�� ���� 0���� �ʱ�ȭ�����ش�

	MOV SI,STACK_RG
	MOV AX,A
	MOV IST[SI], AX			; IST�� �������� A ���� �����صд�.
	PRINT STR_ITR_A
	CALL NEWLINE

	ADD STACK_RG,2			; STACK_RG�� ���� 2 �����ش�.
	MOV SI,STACK_RG
	MOV AX,B
	MOV IST[SI], AX			; IST�� �������� B ���� �����صд�.
	PRINT STR_ITR_B
	CALL NEWLINE

	ADD STACK_RG,2			; STACK_RG�� ���� 2 �����ش�.
	MOV SI,STACK_RG
	MOV AX,C
	MOV IST[SI], AX			; IST�� �������� C ���� �����صд�.
	PRINT STR_ITR_C
	CALL NEWLINE

	ADD STACK_RG,2			; STACK_RG�� ���� 2 �����ش�.
	MOV SI,STACK_RG
	MOV AX,D
	MOV IST[SI], AX			; IST�� �������� D ���� �����صд�.
	PRINT STR_ITR_D
	CALL NEWLINE

	ADD STACK_RG,2			; STACK_RG�� ���� 2 �����ش�.
	MOV SI,STACK_RG
	MOV AX,E
	MOV IST[SI], AX			; IST�� �������� E ���� �����صд�.
	PRINT STR_ITR_E
	CALL NEWLINE

	ADD STACK_RG,2			; STACK_RG�� ���� 2 �����ش�.
	MOV SI,STACK_RG
	MOV AX,F
	MOV IST[SI], AX			; IST�� �������� F ���� �����صд�.
	PRINT STR_ITR_F
	CALL NEWLINE

	ADD STACK_RG,2			; STACK_RG�� ���� 2 �����ش�.
	MOV SI,STACK_RG
	MOV AX,X
	MOV IST[SI], AX			; IST�� �������� X ���� �����صд�.
	PRINT STR_ITR_X
	CALL NEWLINE

	ADD STACK_RG,2			; STACK_RG�� ���� 2 �����ش�.
	MOV SI,STACK_RG
	MOV AX,Y
	MOV IST[SI], AX			; IST�� �������� Y ���� �����صд�.
	PRINT STR_ITR_Y
	CALL NEWLINE

	ADD STACK_RG,2			; STACK_RG�� ���� 2 �����ش�.
	MOV SI,STACK_RG
	MOV AX,PROGRAM_RG
	MOV IST[SI], AX			; IST�� PROGRAM_RG ���� �����صд�.
	PRINT STR_ITR_PROGRAM
	CALL NEWLINE

	ADD STACK_RG,2			; STACK_RG�� ���� 2 �����ش�.
	MOV SI,STACK_RG
	MOV AX,STATUS_RG
	MOV IST[SI], AX			; IST�� STATUS_RG���� �����صд�.
	PRINT STR_ITR_STATUS
	CALL NEWLINE

	ADD STACK_RG,2			; STACK_RG�� ���� 2 �����ش�.
	MOV SI,STACK_RG
	MOV AX,INSTRUCTION_RG
	MOV IST[SI], AX			; IST�� INSTRUCTION_RG���� �����صд�.
	PRINT STR_ITR_INSTRUCTION
	CALL NEWLINE

	ADD STACK_RG,2			; STACK_RG�� ���� 2 �����ش�.
	MOV SI,STACK_RG
	MOV AX, TEMP_RG
	MOV IST[SI], AX			; IST�� TEMP_RG���� �����صд�.
	PRINT STR_ITR_TEMP
	CALL NEWLINE

	ADD STACK_RG,2			; STACK_RG�� ���� 2 �����ش�.
	MOV SI,STACK_RG
	MOV AX,PC
	MOV IST[SI], AX			; IST�� PC_RG���� �����صд�.
	PRINT STR_ITR_PC
	CALL NEWLINE

	MOV BX,STACK_RG
	MOV TEMP_RG,BX
	CALL PHEX				;STACK_RG�� ���� 16������ ���.
	CALL NEWLINE

	RET
M_INTERRUPT ENDP

;------------------------------------------------
;Procedure Name : M_RETURN_MICRO PROC
;Function : ����ũ�θ�忡�� excution�� �� decode�ϴ� �Լ�
;PROGRAMED BY ���¿�
;PROGRAM VERSION
;   Creation Date :Dec 5,2016
;   Last Modified On Dec 6,2016
;------------------------------------------------
M_RETURN_MICRO PROC			; ����ũ�θ�忡�� ��ɾ VDECODE�� �����ִ´�.
   MOV VDECODE[0], 0000h	;VDECODE������ �ʱ�ȭ�����ش�
   MOV VDECODE[2], 0000h
   MOV VDECODE[4], 0000h
   MOV VDECODE[6], 0000h
   MOV VDECODE[8], 0000h
   MOV VDECODE[10], 0000h
   MOV SI,0
   MOV DI,0

   MOV SI, MAR				;���� MAR�� ���� SI�� ����
   MOV AX, M[SI]			;SI���� MEMORY�� ��ɾ� ����AX�� ����
   XOR BX, BX				
   XOR CX, CX				

   MOV BX, AX				
   AND BX, 1111000000000000b;��ɾ� ����1~4��Ʈ��
   MOV CL, 12				;VDECODE[0]�� �ִ´�
   SHR BX, CL				
   MOV VDECODE[0], BX		

   MOV BX, AX				
   AND BX, 0000110000000000b;��ɾ� ����5,6��°��Ʈ��
   MOV CL, 10				;VDECODE[2]�� �ִ´�
   SHR BX, CL				
   MOV VDECODE[2], BX		

   MOV BX, AX				
   AND BX, 0000001111000000b;��ɾ� ����7~10��Ʈ��
   MOV CL, 6				;VDECODE[4]�� �ִ´�
   SHR BX, CL				
   MOV VDECODE[4], BX		

   MOV BX, AX				
   AND BX, 0000000000110000b;��ɾ� ����11,12��° ��Ʈ��
   MOV CL, 4				;VDECODE[6]�� �ִ´�
   SHR BX, CL				
   MOV VDECODE[6], BX		

   MOV BX, AX				
   AND BX, 0000000000001111b;��ɾ� 13~16��Ʈ��
   MOV VDECODE[8], BX		;VDECODE[8]�� �ִ´�

   MOV AX, M[SI+2]			;SI���� 2������Ų�� immediate����
   MOV VDECODE[10], AX		;VDECODE[10]�� �ִ´�
   RET
M_RETURN_MICRO ENDP
;------------------------------------------------
;Procedure Name : M_RETURN
;Function : INTTRUPT���¿��� �������·� ���ư��� �Լ�
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Dec 5,2016
;   Last Modified On Dec 5,2016
;------------------------------------------------
M_RETURN PROC

	MOV SI,STACK_RG
	MOV AX,IST[SI]
	MOV PC,AX				; PC�� IST�� �����ص� PC���� �����Ѵ�.
	SUB STACK_RG,2			; STACK_RG�� ���� 2 ���ش�.

	MOV SI,STACK_RG
	MOV AX,IST[SI]
	MOV TEMP_RG,AX				; TEMP_RG�� IST�� �����ص� TEMP_RG���� �����Ѵ�.
	SUB STACK_RG,2				; STACK_RG�� ���� 2 ���ش�.

	MOV SI,STACK_RG
	MOV AX,IST[SI]
	MOV INSTRUCTION_RG,AX		; INSTRUCTION_RG�� IST�� �����ص� INSTRUCTION_RG���� �����Ѵ�.
	SUB STACK_RG,2				; STACK_RG�� ���� 2 ���ش�.

	MOV SI,STACK_RG
	MOV AX,IST[SI]
	MOV STATUS_RG,AX			; STATUS_RG�� IST�� �����ص� STATUS_RG���� �����Ѵ�.
	SUB STACK_RG,2				; STACK_RG�� ���� 2 ���ش�.

	MOV SI,STACK_RG
	MOV AX,IST[SI]
	MOV PROGRAM_RG,AX			; PROGRAM_RG�� IST�� �����ص� PROGRAM_RG���� �����Ѵ�.
	SUB STACK_RG,2				; STACK_RG�� ���� 2 ���ش�.

	MOV SI,STACK_RG
	MOV AX,IST[SI]
	MOV Y,AX				; Y�� IST�� �����ص� Y���� �����Ѵ�.
	SUB STACK_RG,2			; STACK_RG�� ���� 2 ���ش�.

	MOV SI,STACK_RG
	MOV AX,IST[SI]
	MOV X,AX				; X�� IST�� �����ص� X���� �����Ѵ�.
	SUB STACK_RG,2			; STACK_RG�� ���� 2 ���ش�.

	MOV SI,STACK_RG
	MOV AX,IST[SI]
	MOV F,AX				; F�� IST�� �����ص� F���� �����Ѵ�.
	SUB STACK_RG,2			; STACK_RG�� ���� 2 ���ش�.

	MOV SI,STACK_RG
	MOV AX,IST[SI]
	MOV E,AX				; E�� IST�� �����ص� E���� �����Ѵ�.
	SUB STACK_RG,2			; STACK_RG�� ���� 2 ���ش�.

	MOV SI,STACK_RG
	MOV AX,IST[SI]
	MOV D,AX				; D�� IST�� �����ص� D���� �����Ѵ�.
	SUB STACK_RG,2			; STACK_RG�� ���� 2 ���ش�.

	MOV SI,STACK_RG
	MOV AX,IST[SI]
	MOV C,AX				; C�� IST�� �����ص� C���� �����Ѵ�.
	SUB STACK_RG,2			; STACK_RG�� ���� 2 ���ش�.

	MOV SI,STACK_RG
	MOV AX,IST[SI]
	MOV B,AX				; B�� IST�� �����ص� B���� �����Ѵ�.
	SUB STACK_RG,2			; STACK_RG�� ���� 2 ���ش�.

	MOV SI,STACK_RG
	MOV AX,IST[SI]
	MOV A,AX				; A�� IST�� �����ص� A���� �����Ѵ�.

	PRINT STR_CNT_C_MAR
	MOV BX,MAR
	MOV TEMP_RG,BX
	CALL PHEX				;PROGRAM_RG�� ���� 16������ ���.
	CALL NEWLINE

	PRINT STR_CNT_C_PC
	MOV BX,PC
	MOV TEMP_RG,BX
	CALL PHEX				; PC�� ���� 16������ ���.
	CALL NEWLINE
	RET
M_RETURN ENDP

;------------------------------------------------
;Procedure Name : CMD_MICRO
;Function : ����ũ�� ��� ���� �Լ�
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Dec 1,2016
;   Last Modified On Dec 1,2016
;------------------------------------------------
CMD_MICRO PROC				;����ũ�� ��� ����
   MOV MODE, 00h			;����ũ�� ����� ��� MODE=00h
   MOV DX, OFFSET STR_MICRO
   CALL PUTS				;��� ���ڿ� ���
   CALL NEWLINE
   RET
CMD_MICRO ENDP

;------------------------------------------------
;Procedure Name : CMD_MACRO
;Function : ��ũ�� ��� ���� �Լ�
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Dec 1,2016
;   Last Modified On Dec 1,2016
;------------------------------------------------
CMD_MACRO PROC				; ��ũ�� ��� ����
   MOV MODE, 01h			; ��ũ�� ����� ��� MODE = 01h
   MOV DX, OFFSET STR_MACRO
   CALL PUTS				; ��� ���ڿ� ���
   CALL NEWLINE
   RET
CMD_MACRO ENDP

;------------------------------------------------
;Procedure Name : CMD_EXECUTE
;Function : ��ũ�� ��� c ��ɾ� ó�� �Լ�
;PROGRAMED BY ���¿�
;PROGRAM VERSION
;   Creation Date :Nov 23,2016
;   Last Modified On Nov 28,2016
;------------------------------------------------
CMD_EXECUTE PROC				; ��ũ�� ��� c ��ɾ�
   MOV VDECODE[0], 0000h		; VDECODE �ʱ�ȭ
   MOV VDECODE[2], 0000h
   MOV VDECODE[4], 0000h
   MOV VDECODE[6], 0000h
   MOV VDECODE[8], 0000h
   MOV VDECODE[10], 0000h
   MOV SI,0
   MOV DI,0
   MOV SI, PC
   ADD PC, 4					; PC�� ����
   MOV MAR, SI					; MAR�� PC����

   CMP MODE, 01h
   JE CMD_EXE_L1

   MOV DX,OFFSET STR_MAR
   MOV AX,MAR
   MOV TEMP_RG,AX
   CALL DISPLAY
   MOV DL,  ' '
   CALL PUTC
   MOV DX,OFFSET STR_PC			; ���� PC�� �����
   MOV AX,PC
   MOV TEMP_RG,AX
   CALL DISPLAY
   CALL NEWLINE

   MOV SI, MAR
CMD_EXE_L1:						; PC�� �޸� ���������� �ƴҰ�� ���� ���
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
   MOV AX, M[SI]				; ���� PC�� ����Ű�� �޸𸮿� ����� �ִ��� ���
   MOV TEMP_RG, AX
   CALL PHEX
   MOV SI, MAR
   MOV AX, M[SI+2]                        
   MOV TEMP_RG, AX
   CALL PHEX
   CALL NEWLINE

   MOV SI, MAR
   MOV AX, M[SI]				; ��ɾ� �� 16��Ʈ�� �о�´�
   XOR BX, BX
   XOR CX, CX

   MOV BX, AX					; opcode �κ�
   AND BX, 1111000000000000b
   MOV CL, 12
   SHR BX, CL
   MOV VDECODE[0], BX			; opcode�� vdecode[0]�� ����

   MOV BX, AX					; addressing mode �κ�
   AND BX, 0000110000000000b
   MOV CL, 10
   SHR BX, CL
   MOV VDECODE[2], BX			; mode�� vdecode[2]�� ����

   MOV BX, AX					; ù��° operand �κ�
   AND BX, 0000001111000000b
   MOV CL, 6
   SHR BX, CL
   MOV VDECODE[4], BX			; ù��° ���۷��带 vdecode[4]�� ����

   MOV BX, AX					; ���� addressing mode �κ�
   AND BX, 0000000000110000b
   MOV CL, 4
   SHR BX, CL
   MOV VDECODE[6], BX			; ��带 vdecode[6]�� ����

   MOV BX, AX				
   AND BX, 0000000000001111b	; �ι�° operand �κ�
   MOV VDECODE[8], BX			; �ι�° ���۷��带 vdecode[8]�� ����
	
   MOV AX, M[SI+2]				; ��ɾ��� ������ 16��Ʈ�� �о�´�
   MOV VDECODE[10], AX			; Immediate���� vdecode[10]�� ����
								; opcode�� ���� ��ɾ� �б�
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
EXE_NEXT:						; ��ɾ� ����ǰ� ���� �������� ���
   CALL NEWLINE
   CALL CMD_DISPLAY
   RET
EXE_WRONG_PC:					; �߸��� PC ���� �ϰ�� ���� �޽��� ���
   MOV DX, OFFSET STR_WRONGPCADDR
   CALL PUTS
   CALL NEWLINE
   RET
								; ��ɾ� �б�Ȱ� ó���κ� �ش�Ǵ� ��ɾ ������
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
;Function : �޸� �Է��� ���� m��ɾ� ó�� �Լ�
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 26,2016
;   Last Modified On Nov 30,2016
;------------------------------------------------
CMD_MEMORY PROC
   MOV CMD_MEM_LEN, 00h			; ���Ǵ� ���� �ʱ�ȭ
   MOV CMD_MEM_ADDR, 0000h
   MOV CMD_MEM_VAL1, 0000h
   MOV CH, CL					; cx���� 40�� ���� ���� �Էµ� ��ɾ��� ���̸� ����
   MOV CL, 40
   SUB CL, CH
   MOV CH, 0
   MOV CMD_MEM_LEN, CL			; ��ɾ� ���� ����
   SUB CX, 2
MEM_PARSE1:
   MOV DL, [BX + 2]				; �޸� ������ �Ľ��ϴ� �κ�
   CMP DL, ']'
   JE PARSE_MEM_OFF
   INC BX
   LOOP MEM_PARSE1
   JMP MEM_WRONGADDR			; �Ľ� ���н� ���� ���
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
   MOV BX, OFFSET CMDLINE		; ��ɾ� ���۸� ���� �о�´�
   MOV SI, AX
   MOV DL, [BX + 3 + SI]
   CMP DL, ' '
   JE CMD_MEM_L3
   JMP MEM_WRONG_FMT
CMD_MEM_L3:						; �޸� �ּ� ó�� ����
   MOV DI, AX
   XOR DX, DX
   MOV SI, 0
   MOV AL, [BX + 2 + SI]
   CALL CHECK_HEX				; valid�� ������ üũ
   CMP AL, 0FFH
   JNE CMD_MEM_L4
   JMP WRONG_MEM_RANGE
CMD_MEM_L4:
   MOV DL, AL
   SUB DI, 1
READ_MEM_ADDR:					; ���ڸ� �̻��ϰ�� �������鼭 ó��
   CMP SI, DI
   JE PARSE_MEM_VAL
   INC SI
   MOV AL, [BX + 2 + SI]
   CALL CHECK_HEX
   CMP AL, 0FFH
   JNE CMD_MEM_L5
   JMP WRONG_MEM_RANGE
CMD_MEM_L5:						; ����Ʈ������ �ϸ鼭 �Է¹޴� �ڸ������ �о�ִ� ����
   MOV CL, 4
   SHL DX, CL
   OR DL, AL
   LOOP READ_MEM_ADDR
PARSE_MEM_VAL:
   CMP DX, 1000h
   JBE CMD_MEM_L6
   JMP MEM_WRONGADDR
CMD_MEM_L6:
   MOV CMD_MEM_ADDR, DX			; ���� �޸��ּ� ������ ������
   
   MOV SAVE_DI[0],DI
   MOV DI,0
   MOV DI,SAVE_CNT[0]			; �޸𸮿� ����Ȱ� �� �����������ؼ�
   MOV SAVE_M[DI],DX
   MOV DI,SAVE_DI[0]

   XOR CX, CX					; �޸𸮿� ����� �� �Ľ��ϱ� ���ؼ� ���� ���
   MOV CL, CMD_MEM_LEN
   MOV BX, OFFSET CMDLINE
   ADD BX, 5
   ADD BX, DI
   SUB CX, 5
   SUB CX, DI
   CMP CX, 8
   JBE CMD_MEM_L7
   JMP WRONG_VAL				; ���� ��꿡 �����Ѱ�� �Ľ� ����
CMD_MEM_L7:
   CMP CX, 0
   JNE CMD_MEM_L8
   JMP WRONG_VAL				; ���̰� 0�ΰ�쿡�� �Ľ� ����
CMD_MEM_L8:
   CMP CX, 4
   JA MEM_INPUT_DOUBLE			; ���̰� 4�ڸ��� ��� 4�ڸ� �Է¸���
   MOV DI, CX
   XOR DX, DX
   MOV SI, 0
   MOV AL, [BX + SI]
   CALL CHECK_HEX
   CMP AL, 0FFH					; 16���� �˻�
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
   CALL CHECK_HEX				; �Ȱ��� �������鼭 ���ڸ� �о�ִ´�
   CMP AL, 0FFH
   JNE CMD_MEM_L10
   JMP WRONG_MEM_RANGE
CMD_MEM_L10:
   MOV CL, 4
   SHL DX, CL
   OR DL, AL
   LOOP READ_VAL1
MEM_SETVAL1:
   MOV CMD_MEM_VAL1, DX			; �Ľ̵� ����� �ӽ� ������ ����
   MOV SI, CMD_MEM_ADDR
   MOV M[SI], DX				; ���� �޸� �����¿� �ش� �� �Է�
   XOR DI, DI
   JMP MEM_PRINT_RESULT			; ��� ��� �κ����� ����
MEM_INPUT_DOUBLE:
   MOV DI, CX
   SUB DI, 4
   XOR DX, DX
   MOV SI, 0
   MOV AL, [BX + SI]
   CALL CHECK_HEX				; 16���� �� �˻�
   CMP AL, 0FFH
   JNE CMD_MEM_L11
   JMP WRONG_MEM_RANGE
CMD_MEM_L11:
   MOV DL, AL
   SUB DI, 1
READ_VAL2:						; ���� ������� �ι��� �Է¹���
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
MEM_SETVAL2:					; �պκ� �ӽ� ���ۿ� ����
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
MEM_SETVAL3:					; �ּҸ� �ٽ� �����´�
   MOV SI, CMD_MEM_ADDR			; �޺κе� �ӽ� ���ۿ� ����
   MOV CMD_MEM_VAL2, DX			; ���� �޸𸮿� �Է�
   MOV M[SI+2], DX
   MOV DX, CMD_MEM_VAL1
   MOV M[SI], DX
   MOV DI, 8
MEM_PRINT_RESULT:				; �޸� �� �����ϰ� �� �� ��� ��� �κ�
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
WRONG_VAL:						; �߸��� ���� ��쿡 ���� ���	
   MOV DX, OFFSET STR_WRONGMEMVAL
   CALL PUTS
   CALL NEWLINE
   RET
WRONG_MEM_RANGE:				; �߸��� ������ ��� ���� ���
   MOV DX, OFFSET STR_WRONGHEX
   CALL PUTS
   CALL NEWLINE
   RET
MEM_WRONG_FMT:					; �߸��� ��ɾ� ������ ��� ���� ���
   MOV DX, OFFSET STR_WRONGMEM
   CALL PUTS
   CALL NEWLINE
   RET
MEM_WRONGADDR:					; �߸��� �ּ��� ��� ���� ���
   MOV DX, OFFSET STR_WRONGMEMADDR
   CALL PUTS
   CALL NEWLINE
   RET
CMD_MEMORY ENDP
;------------------------------------------------
;Procedure Name : CMD_DISPLAY
;Function : ���� Register�� ���� pc�� ���� ����ϴ� �Լ�
;PROGRAMED BY ���¿�
;PROGRAM VERSION
;   Creation Date :Nov 23,2016
;   Last Modified On Nov 24,2016
;------------------------------------------------
CMD_DISPLAY PROC
   MOV DX,OFFSET STR_A      ;'A'���
   MOV AX,A					;Register A�� �ִ� ���� ���
   MOV TEMP_RG,AX			
   CALL DISPLAY			
   MOV DX,OFFSET STR_B		;B���
   MOV AX,B					;Register B�� �ִ� ���� ���
   MOV TEMP_RG,AX			
   CALL DISPLAY				
   MOV DX,OFFSET STR_C		;C���
   MOV AX,C					;Register C�� �ִ� ���� ���
   MOV TEMP_RG,AX			
   CALL DISPLAY				
   MOV DX,OFFSET STR_D		;D���
   MOV AX,D					;Register D�� �ִ� ���� ���
   MOV TEMP_RG,AX			
   CALL DISPLAY				
   MOV DX,OFFSET STR_E		;E���
   MOV AX,E					;Register E�� �ִ� ���� ���
   MOV TEMP_RG,AX			
   CALL DISPLAY				
   MOV DX,OFFSET STR_F		;F���
   MOV AX,F					;Register F�� �ִ� ���� ���
   MOV TEMP_RG,AX			
   CALL DISPLAY				
   MOV DX,OFFSET STR_X		;X���
   MOV AX,X					;Register X�� �ִ� ���� ���
   MOV TEMP_RG,AX			
   CALL DISPLAY				
   MOV DX,OFFSET STR_Y		;Y���
   MOV AX,Y					;Register Y�� �ִ� ���� ���
   MOV TEMP_RG,AX			
   CALL DISPLAY				
   CALL NEWLINE				
   MOV DX,OFFSET STR_PC		;PC���
   MOV AX,PC				;PC�� �ִ� ���� ���
   MOV TEMP_RG,AX			
   CALL DISPLAY				
   CALL NEWLINE				

   CALL NEWLINE
   RET
CMD_DISPLAY ENDP

;------------------------------------------------
;Procedure Name : CHECK_HEX
;Function : �޸�, �ּ� �Է½� 16������ �Ľ� �Լ�
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 28,2016
;   Last Modified On Nov 29,2016
;------------------------------------------------
CHECK_HEX PROC
   CMP AL, 'f'				; �Էµ� ������ �˻�
   JA CHECK_HEX_FALSE
   CMP AL, '0'
   JB CHECK_HEX_FALSE
   CMP AL, '9'
   JA CHECK_HEX_UPPER
   SUB AL, 30H				; ���� ������ ���
   RET
CHECK_HEX_UPPER:
   CMP AL, 'F'
   JA CHECK_HEX_LOWER
   CMP AL, 'A'
   JB CHECK_HEX_FALSE
   SUB AL, 37H				; �빮���� ���
   RET
CHECK_HEX_LOWER:
   CMP AL, 'a'
   JB CHECK_HEX_FALSE
   SUB AL, 57H				; �ҹ����� ���
   RET
CHECK_HEX_FALSE:
   MOV AL, 0FFH             ; FF�� ���ϵǸ� �������� ��
   RET
CHECK_HEX ENDP

;------------------------------------------------
;Procedure Name : CMD_PC
;Function : PC �Է� �Լ�
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 24,2016
;   Last Modified On Nov 30,2016
;------------------------------------------------
CMD_PC PROC
   MOV CH, CL				; �Էµ� PC ��ɾ� ���̸� ���
   MOV CL, 40
   SUB CL, CH
   MOV CH, 0
   SUB CX, 3
   XOR DX, DX
   CMP CX, 4
   JA WRONG_PC_FMT			; �Էµ� �ּҰ� 4�ڸ� �̻��� ��� ���� ���� ���
   MOV SI, 0
   MOV AL, [BX + 3 + SI]
   CALL CHECK_HEX			; 16���� �� �˻�
   CMP AL, 0FFH
   JE WRONG_PC_RANGE
   MOV DL, AL
   MOV DI, CX
   SUB DI, 1
READ_PC:					; �ּҰ� ���ڸ� �̻��� ��� ���� ���缭 ó��
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

   MOV DX,OFFSET STR_PC		; PC �������� ���
   MOV AX, PC
   MOV TEMP_RG, AX
   CALL DISPLAY

   CALL NEWLINE
   RET
WRONG_PC_FMT:				; ���� ���� ���
   MOV DX, OFFSET STR_WRONGPC
   CALL PUTS
   CALL NEWLINE
   RET
WRONG_PC_RANGE:				; ���� ���� ���� ���
   MOV DX, OFFSET STR_WRONGHEX
   CALL PUTS
   CALL NEWLINE
   RET
CMD_PC ENDP

;------------------------------------------------
;Procedure Name : EXIT
;Function : ���α׷� ���� �Լ�
;PROGRAMED BY ������
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
;Function : �ɸ��� ���� ��� �Լ�
;PROGRAMED BY ������
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
;Function : CRLF ��� �Լ�
;PROGRAMED BY ���¿�
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
;Function : �ɸ��� ���� �Է� �Լ�
;PROGRAMED BY ������
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
;Function : ���ڿ� ���� ��� �Լ�
;PROGRAMED BY ������
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
;Function : �� ��� �Լ�
;PROGRAMED BY ���¿�
;PROGRAM VERSION
;   Creation Date :Nov 23,2016
;   Last Modified On Nov 25,2016
;------------------------------------------------
PHEX PROC					
   MOV SI,0					
   MOV CX, TEMP_RG			;����1��° ��Ʈ�� ���
   AND CH,0F0h				
   PRINT_A1_ROOP:			
   CMP SI,4					;SHR,4�� ���ִ� ����
   JE PRINT_A1_ROOP_EXIT	;CH�� ���� 4��Ʈ�� ���� 4��Ʈ��
   SHR CH,1					;�ű�� �۾�
   INC SI					
   JNE PRINT_A1_ROOP		
   PRINT_A1_ROOP_EXIT:		
   CMP CH,10				
   JB PRINT_A1_DEC			
   ADD CH,55				;10�̻��ϰ�� ���ĺ����� ���
   JAE PRINT_A1_EXIT		;9�����ϰ�� ���ڷ� ���
   PRINT_A1_DEC:			
   ADD CH,48				
   PRINT_A1_EXIT:			
   MOV DL,CH				
   MOV AH,02H				
   INT 21H					
   MOV CX,TEMP_RG			;����2��° ��Ʈ�����
   AND CH,00Fh				
   CMP CH,10				
   JB PRINT_A2_DEC			;10�̻��� ��� ���ĺ����� ���
   ADD CH,55				;9������ ��� ���ڷ� ���
   JAE PRINT_A2_EXIT		
   PRINT_A2_DEC:			
   ADD CH,48				
   PRINT_A2_EXIT:			
   MOV DL,CH				
   MOV AH,02H				
   INT 21H					
   MOV SI,0					
   MOV CX,TEMP_RG			;����3��° ��Ʈ�� ���
   AND CL,0F0h				
   PRINT_A3_ROOP:			
   CMP SI,4					;SHR,4�� ���ִ� ����
   JE PRINT_A3_ROOP_EXIT	;CL�� ���� 4��Ʈ�� ���� 4��Ʈ��
   SHR CL,1					;�ű�� �۾�
   INC SI					
   JNE PRINT_A3_ROOP		
   PRINT_A3_ROOP_EXIT:		
   CMP CL,10				
   JB PRINT_A3_DEC			;10�̻��ϰ�� ���ĺ����� ���
   ADD CL,55				;9�����ϰ�� ���ڷ� ���
   JAE PRINT_A3_EXIT		
   PRINT_A3_DEC:			
   ADD CL,48				
   PRINT_A3_EXIT:			
   MOV DL,CL				
   MOV AH,02H				
   INT 21H					
   MOV CX,TEMP_RG			;����4��°��Ʈ�� ���
   AND CL,00001111b			
   CMP CL,10			
   JB PRINT_A4_DEC			
   ADD CL,55				;10�̻��� ��� ���ĺ����� ���
   JAE PRINT_A4_EXIT		;9�����ϰ�� ���ڷ� ���
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
;Function : �������� ��� �Լ�
;PROGRAMED BY ���¿�
;PROGRAM VERSION
;   Creation Date :Nov 24,2016
;   Last Modified On Nov 28,2016
;------------------------------------------------
DISPLAY PROC
   MOV AH,09H         ;STR_??�� ���
   INT 21H
   CALL PHEX
   RET
DISPLAY ENDP

;------------------------------------------------
;Procedure Name : D_OUTPUT
;Function : �޸��� �ּҿ� ��ɾ� ��� �Լ�
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 26,2016
;   Last Modified On Nov 29,2016
;------------------------------------------------
D_OUTPUT PROC
						
   MOV DI,0				
   MOV SAVE_DI2[0],DI	
   M_OUTPUT:			;"m[#]= "�� ��� 
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

   MOV SAVE_DI2[0],DI	;DI�� �ӽ÷� ����
   MOV SI,SAVE_M[DI]	;���� PC���� SI�� ����
   MOV BX,M[SI]			;Memory�� �������ִ� ��ɾ ���
   MOV TEMP_RG,BX		
   CALL PHEX			
   MOV SI,SAVE_M[DI]	
   ADD SI,2				
   MOV BX,M[SI]			
   MOV TEMP_RG,BX		

   CALL PHEX			

   CALL NEWLINE			
   MOV DI,SAVE_DI2[0]	;�ӽ÷� �����ص� DI�� �����´�
   INC DI
   INC DI
   MOV SAVE_DI2[0],DI
   JNE M_OUTPUT
   D_OUTPUT_EXIT:

	RET
D_OUTPUT ENDP


;------------------------------------------------
;Procedure Name : M_JMP
;Function : JMP ��ɾ ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 25,2016
;   Last Modified On Nov 25,2016
;------------------------------------------------
M_JMP PROC        ; JMP ��ɾ�
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
;Function : JA ��ɾ ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 25,2016
;   Last Modified On Nov 25,2016
;------------------------------------------------
M_JA PROC         ; JA(ũ��) ��ɾ�
   MOV DX,STATUS_RG		; STATUS_RG�� ���� Ȯ���Ͽ� COMPARE�� ����� Ȯ��
   AND DX,11b
   CMP DX,01b			; 01b ���(���� ���� Ŭ ���) VDECODE[10]���� PC�� ����, �ƴҰ�� �Լ� ����
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
;Function : JB ��ɾ ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 25,2016
;   Last Modified On Nov 25,2016
;------------------------------------------------
M_JB PROC         ; JB(�۴�) ��ɾ�
   MOV DX,STATUS_RG		; STATUS_RG�� ���� Ȯ���Ͽ� COMPARE�� ����� Ȯ��
   AND DX,11b
   CMP DX,10b		; 10b ���(���� ���� ���� ���) VDECODE[10]���� PC�� ����, �ƴҰ�� �Լ� ����
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
;Function : JE ��ɾ ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 25,2016
;   Last Modified On Nov 25,2016
;------------------------------------------------
M_JE PROC         ; JE(����) ��ɾ�
   MOV DX,STATUS_RG		; STATUS_RG�� ���� Ȯ���Ͽ� COMPARE�� ����� Ȯ��
   AND DX,11b
   CMP DX,00b			; 00b ���(���� ���� ���� ���) VDECODE[10]���� PC�� ����, �ƴҰ�� �Լ� ����
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
;Function : SUB ��ɾ ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27,2016
;------------------------------------------------
M_SUB PROC
   MOV DX,VDECODE[4]
   AND VDECODE[2],11b

   CMP VDECODE[2],00b
   JE SUB_REGI			; REGISTER ��� SUB
   CMP VDECODE[2],01b
   JE REST_SUB1         ; IMMEDIATE ��� SUB
   CMP VDECODE[2],10b
   JE REST_SUB1         ; REGISTER_INDIRECT ��� SUB
   CMP VDECODE[2],11b
   JE REST_SUB1         ; DIRECT ��� SUB
   PRINT ERR

SUB_REGI:				; �������� ��� SUB  
   MOV VDECODE[4],DX	; OPERAND1�� ���� A

   CMP VDECODE[4],1000b		;OPERAND1�� ���� A
   JE SUB_A
   CMP VDECODE[4],1001b		;OPERAND1�� ���� B
   JE SUB_B
   CMP VDECODE[4],1010b		;OPERAND1�� ���� C
   JE SUB_C
   CMP VDECODE[4],1011b		;OPERAND1�� ���� D
   JE SUB_D
   CMP VDECODE[4],1100b		;OPERAND1�� ���� E
   JE SUB_E
   CMP VDECODE[4],1101b		;OPERAND1�� ���� F
   JE SUB_F
   CMP VDECODE[4],1110b		;OPERAND1�� ���� X
   JE SUB_X
   CMP VDECODE[4],1111b		;OPERAND1�� ���� Y
   JE SUB_Y

   PRINT ERR
   JMP END_M_SUB

REST_SUB1:
   CMP VDECODE[2],01b
   JE REST_SUB2         ; IMMEDIATE ��� SUB
   CMP VDECODE[2],10b
   JE REST_SUB2         ; REGISTER_INDIRECT ��� SUB
   CMP VDECODE[2],11b
   JE REST_SUB2         ; DIRECT ��� SUB

SUB_A:
   CALL SUB_A_P			;SUB_A_P�� CALL
   JMP END_M_SUB
SUB_B:
   CALL SUB_B_P			;SUB_A_P�� CALL
   JMP END_M_SUB
SUB_C:             
   CALL SUB_C_P			;SUB_A_P�� CALL
   JMP END_M_SUB
SUB_D:             
   CALL SUB_D_P			;SUB_A_P�� CALL
   JMP END_M_SUB
SUB_E:             
   CALL SUB_E_P			;SUB_A_P�� CALL
   JMP END_M_SUB
SUB_F:              
   CALL SUB_F_P			;SUB_A_P�� CALL
   JMP END_M_SUB
SUB_X:             
   CALL SUB_X_P			;SUB_A_P�� CALL
   JMP END_M_SUB
SUB_Y:             
   CALL SUB_Y_P			;SUB_A_P�� CALL
   JMP END_M_SUB

   PRINT ERR
   JMP END_M_SUB

REST_SUB2:
   CMP VDECODE[2],01b
   JE SUB_IMME       ; IMMEDIATE ��� SUB
   CMP VDECODE[2],10b
   JE REST_SUB3         ; REGISTER_INDIRECT ��� SUB
   CMP VDECODE[2],11b
   JE REST_SUB3         ; DIRECT ��� SUB

SUB_IMME:				; IMMEDIATE ��� SUB	
   MOV VDECODE[4],DX

   CMP VDECODE[4],1000b		;OPERAND1�� ���� A
   JE SUB_A_IMME
   CMP VDECODE[4],1001b		;OPERAND1�� ���� B
   JE SUB_B_IMME
   CMP VDECODE[4],1010b		;OPERAND1�� ���� C
   JE SUB_C_IMME
   CMP VDECODE[4],1011b		;OPERAND1�� ���� D
   JE SUB_D_IMME
   CMP VDECODE[4],1100b		;OPERAND1�� ���� E
   JE SUB_E_IMME
   CMP VDECODE[4],1101b		;OPERAND1�� ���� F
   JE SUB_F_IMME
   CMP VDECODE[4],1110b		;OPERAND1�� ���� X
   JE SUB_X_IMME
   CMP VDECODE[4],1111b		;OPERAND1�� ���� Y
   JE SUB_Y_IMME

   PRINT ERR
   JMP END_M_SUB

REST_SUB3:
   CMP VDECODE[2],10b
   JE SUB_REGI_INDIRECT    ; REGISTER_INDIRECT ��� SUB
   CMP VDECODE[2],11b
   JE  REST_SUB4        ; DIRECT ��� SUB

SUB_A_IMME:
   CALL SUB_A_IMME_P	; SUB_A_IMME_P ���ν��� ȣ��
   JMP END_M_SUB
SUB_B_IMME:
   CALL SUB_B_IMME_P	; SUB_B_IMME_P ���ν��� ȣ��
   JMP END_M_SUB
SUB_C_IMME:
   CALL SUB_C_IMME_P	; SUB_C_IMME_P ���ν��� ȣ��
   JMP END_M_SUB
SUB_D_IMME:
   CALL SUB_D_IMME_P	; SUB_D_IMME_P ���ν��� ȣ��
   JMP END_M_SUB
SUB_E_IMME:
   CALL SUB_E_IMME_P	; SUB_E_IMME_P ���ν��� ȣ��
   JMP END_M_SUB
SUB_F_IMME:
   CALL SUB_F_IMME_P	; SUB_F_IMME_P ���ν��� ȣ��
   JMP END_M_SUB
SUB_X_IMME:
   CALL SUB_X_IMME_P	; SUB_X_IMME_P ���ν��� ȣ��
   JMP END_M_SUB
SUB_Y_IMME:
   CALL SUB_Y_IMME_P	; SUB_Y_IMME_P ���ν��� ȣ��
   JMP END_M_SUB
   
   PRINT ERR
   JMP END_M_SUB

REST_SUB4:
   CMP VDECODE[2],11b
   JE  SUB_DIRECT          ; DIRECT ��� SUB

SUB_REGI_INDIRECT:         ; REGISTER-INDIRECT ��� SUB
   MOV VDECODE[4],DX

   CMP VDECODE[4],1000b		;OPERAND1�� ���� A
   JE SUB_A_REIN
   CMP VDECODE[4],1001b		;OPERAND1�� ���� B
   JE SUB_B_REIN
   CMP VDECODE[4],1010b		;OPERAND1�� ���� C
   JE SUB_C_REIN
   CMP VDECODE[4],1011b		;OPERAND1�� ���� D
   JE SUB_D_REIN
   CMP VDECODE[4],1100b		;OPERAND1�� ���� E
   JE SUB_E_REIN
   CMP VDECODE[4],1101b		;OPERAND1�� ���� F
   JE SUB_F_REIN
   CMP VDECODE[4],1110b		;OPERAND1�� ���� X
   JE SUB_X_REIN
   CMP VDECODE[4],1111b		;OPERAND1�� ���� Y
   JE SUB_Y_REIN

   PRINT ERR
   JMP END_M_SUB  

SUB_A_REIN:  
   CALL SUB_A_REIN_P		; SUB_A_REIN_P ���ν��� ȣ��
   JMP END_M_SUB
SUB_B_REIN:            
   CALL SUB_B_REIN_P		; SUB_B_REIN_P ���ν��� ȣ��
   JMP END_M_SUB
SUB_C_REIN:            
   CALL SUB_C_REIN_P		; SUB_C_REIN_P ���ν��� ȣ��
   JMP END_M_SUB
SUB_D_REIN:           
   CALL SUB_D_REIN_P		; SUB_D_REIN_P ���ν��� ȣ��
   JMP END_M_SUB
SUB_E_REIN:             
   CALL SUB_E_REIN_P		; SUB_E_REIN_P ���ν��� ȣ��
   JMP END_M_SUB
SUB_F_REIN:            
   CALL SUB_F_REIN_P		; SUB_F_REIN_P ���ν��� ȣ��
   JMP END_M_SUB
SUB_X_REIN:            
   CALL SUB_X_REIN_P		; SUB_X_REIN_P ���ν��� ȣ��
   JMP END_M_SUB
SUB_Y_REIN:           
   CALL SUB_Y_REIN_P		; SUB_Y_REIN_P ���ν��� ȣ��
   JMP END_M_SUB


SUB_DIRECT:					; DIRECT ��� SUB
   MOV VDECODE[4],DX

   CMP VDECODE[4],1000b		;OPERAND1�� ���� A
   JE SUB_A_DI
   CMP VDECODE[4],1001b		;OPERAND1�� ���� B
   JE SUB_B_DI
   CMP VDECODE[4],1010b		;OPERAND1�� ���� C
   JE SUB_C_DI
   CMP VDECODE[4],1011b		;OPERAND1�� ���� D
   JE SUB_D_DI
   CMP VDECODE[4],1100b		;OPERAND1�� ���� E
   JE SUB_E_DI
   CMP VDECODE[4],1101b		;OPERAND1�� ���� F
   JE SUB_F_DI
   CMP VDECODE[4],1110b		;OPERAND1�� ���� X
   JE SUB_X_DI
   CMP VDECODE[4],1111b		;OPERAND1�� ���� Y
   JE SUB_Y_DI

   PRINT ERR
   JMP END_M_SUB  

SUB_A_DI:
   CALL SUB_A_DI_P			; SUB_A_DI_P ���ν��� ȣ��
   JMP END_M_SUB
SUB_B_DI:
   CALL SUB_B_DI_P			; SUB_B_DI_P ���ν��� ȣ��
   JMP END_M_SUB
SUB_C_DI:
   CALL SUB_C_DI_P			; SUB_C_DI_P ���ν��� ȣ��
   JMP END_M_SUB
SUB_D_DI:
   CALL SUB_D_DI_P			; SUB_D_DI_P ���ν��� ȣ��
   JMP END_M_SUB
SUB_E_DI:
   CALL SUB_E_DI_P			; SUB_E_DI_P ���ν��� ȣ��
   JMP END_M_SUB
SUB_F_DI:
   CALL SUB_F_DI_P			; SUB_F_DI_P ���ν��� ȣ��
   JMP END_M_SUB
SUB_X_DI:
   CALL SUB_X_DI_P			; SUB_X_DI_P ���ν��� ȣ��
   JMP END_M_SUB
SUB_Y_DI:
   CALL SUB_Y_DI_P			; SUB_Y_DI_P ���ν��� ȣ��
   JMP END_M_SUB

END_M_SUB:  
   RET
M_SUB ENDP

;------------------------------------------------
;Procedure Name : SUB_A_P
;Function : SUB A, ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27,2016
;------------------------------------------------
SUB_A_P PROC            ; SUB A,REGISTER

   CMP VDECODE[8],1000b		; OPERAND2 ���� A
   JE SUB_A_A
   CMP VDECODE[8],1001b		; OPERAND2 ���� B
   JE SUB_A_B
   CMP VDECODE[8],1010b		; OPERAND2 ���� C
   JE SUB_A_C
   CMP VDECODE[8],1011b		; OPERAND2 ���� D
   JE SUB_A_D
   CMP VDECODE[8],1100b		; OPERAND2 ���� E
   JE SUB_A_E
   CMP VDECODE[8],1101b		; OPERAND2 ���� F
   JE SUB_A_F
   CMP VDECODE[8],1110b		; OPERAND2 ���� X
   JE SUB_A_X
   CMP VDECODE[8],1111b		; OPERAND2 ���� Y
   JE SUB_A_Y

SUB_A_A:          ; SUB A,A ����
   MOV DX,A
   SUB A,DX
   JMP END_M_SUB_A_P
SUB_A_B:          ; SUB A,B ����
   MOV DX,B
   SUB A,DX
   JMP END_M_SUB_A_P
SUB_A_C:          ; SUB A,C ����
   MOV DX,C
   SUB A,DX
   JMP END_M_SUB_A_P
SUB_A_D:          ; SUB A,D ����
   MOV DX,D
   SUB A,DX
   JMP END_M_SUB_A_P
SUB_A_E:          ; SUB A,E ����
   MOV DX,E
   SUB A,DX
   JMP END_M_SUB_A_P
SUB_A_F:          ; SUB A,F ����
   MOV DX,F
   SUB A,DX
   JMP END_M_SUB_A_P
SUB_A_X:          ; SUB A,X ����
   MOV DX,X
   SUB A,DX
   JMP END_M_SUB_A_P
SUB_A_Y:          ; SUB A,Y ����
   MOV DX,Y
   SUB A,DX
   JMP END_M_SUB_A_P

   PRINT ERR         ; ���� ���

END_M_SUB_A_P:
   RET
SUB_A_P ENDP

;------------------------------------------------
;Procedure Name : SUB_B_P
;Function : SUB B, ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27,2016
;------------------------------------------------
SUB_B_P PROC            ; SUB B,REGISTER

   CMP VDECODE[8],1000b		; OPERAND2 ���� A
   JE SUB_B_A
   CMP VDECODE[8],1001b		; OPERAND2 ���� B
   JE SUB_B_B
   CMP VDECODE[8],1010b		; OPERAND2 ���� C
   JE SUB_B_C
   CMP VDECODE[8],1011b		; OPERAND2 ���� D
   JE SUB_B_D
   CMP VDECODE[8],1100b		; OPERAND2 ���� E
   JE SUB_B_E
   CMP VDECODE[8],1101b		; OPERAND2 ���� F
   JE SUB_B_F
   CMP VDECODE[8],1110b		; OPERAND2 ���� X
   JE SUB_B_X
   CMP VDECODE[8],1111b		; OPERAND2 ���� Y
   JE SUB_B_Y

SUB_B_A:          ; SUB B,A ����
   MOV DX,A
   SUB B,DX
   JMP END_M_SUB_B_P
SUB_B_B:          ; SUB B,B ����
   MOV DX,B
   SUB B,DX
   JMP END_M_SUB_B_P
SUB_B_C:          ; SUB B,C ����
   MOV DX,C
   SUB B,DX
   JMP END_M_SUB_B_P
SUB_B_D:          ; SUB B,D ����
   MOV DX,D
   SUB B,DX
   JMP END_M_SUB_B_P
SUB_B_E:          ; SUB B,E ����
   MOV DX,E
   SUB B,DX
   JMP END_M_SUB_B_P
SUB_B_F:          ; SUB B,F ����
   MOV DX,F
   SUB B,DX
   JMP END_M_SUB_B_P
SUB_B_X:          ; SUB B,X ����
   MOV DX,X
   SUB B,DX
   JMP END_M_SUB_B_P
SUB_B_Y:          ; SUB B,Y����
   MOV DX,Y
   SUB B,DX
   JMP END_M_SUB_B_P

   PRINT ERR

END_M_SUB_B_P:
   RET
SUB_B_P ENDP

;------------------------------------------------
;Procedure Name : SUB_C_P
;Function : SUB C, ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27,2016
;------------------------------------------------
SUB_C_P PROC            ; SUB C,REGISTER

   CMP VDECODE[8],1000b		; OPERAND2 ���� A
   JE SUB_C_A
   CMP VDECODE[8],1001b		; OPERAND2 ���� B
   JE SUB_C_B
   CMP VDECODE[8],1010b		; OPERAND2 ���� C
   JE SUB_C_C
   CMP VDECODE[8],1011b		; OPERAND2 ���� D
   JE SUB_C_D
   CMP VDECODE[8],1100b		; OPERAND2 ���� E
   JE SUB_C_E
   CMP VDECODE[8],1101b		; OPERAND2 ���� F
   JE SUB_C_F
   CMP VDECODE[8],1110b		; OPERAND2 ���� X
   JE SUB_C_X
   CMP VDECODE[8],1111b		; OPERAND2 ���� Y
   JE SUB_C_Y

SUB_C_A:          ; SUB C,A ����
   MOV DX,A
   SUB C,DX
   JMP END_M_SUB_C_P
SUB_C_B:          ; SUB C,B ����
   MOV DX,B
   SUB C,DX
   JMP END_M_SUB_C_P
SUB_C_C:          ; SUB C,C ����
   MOV DX,C
   SUB C,DX
   JMP END_M_SUB_C_P
SUB_C_D:          ; SUB C,D ����
   MOV DX,D
   SUB C,DX
   JMP END_M_SUB_C_P
SUB_C_E:          ; SUB C,E ����
   MOV DX,E
   SUB C,DX
   JMP END_M_SUB_C_P
SUB_C_F:          ; SUB C,F ����
   MOV DX,F
   SUB C,DX
   JMP END_M_SUB_C_P
SUB_C_X:          ; SUB C,X ����
   MOV DX,X
   SUB C,DX
   JMP END_M_SUB_C_P
SUB_C_Y:          ; SUB C,Y����
   MOV DX,Y
   SUB C,DX
   JMP END_M_SUB_C_P

   PRINT ERR

END_M_SUB_C_P:
   RET
SUB_C_P ENDP

;------------------------------------------------
;Procedure Name : SUB_D_P
;Function : SUB D, ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27,2016
;------------------------------------------------
SUB_D_P PROC            ; SUB D,REGISTER

   CMP VDECODE[8],1000b		; OPERAND2 ���� A
   JE SUB_D_A
   CMP VDECODE[8],1001b		; OPERAND2 ���� B
   JE SUB_D_B
   CMP VDECODE[8],1010b		; OPERAND2 ���� C
   JE SUB_D_C
   CMP VDECODE[8],1011b		; OPERAND2 ���� D
   JE SUB_D_D
   CMP VDECODE[8],1100b		; OPERAND2 ���� E
   JE SUB_D_E
   CMP VDECODE[8],1101b		; OPERAND2 ���� F
   JE SUB_D_F
   CMP VDECODE[8],1110b		; OPERAND2 ���� X
   JE SUB_D_X
   CMP VDECODE[8],1111b		; OPERAND2 ���� Y
   JE SUB_D_Y

SUB_D_A:          ; SUB D,A ����
   MOV DX,A
   SUB D,DX
   JMP END_M_SUB_D_P
SUB_D_B:          ; SUB D,B ����
   MOV DX,B
   SUB C,DX
   JMP END_M_SUB_D_P
SUB_D_C:          ; SUB D,C ����
   MOV DX,C
   SUB C,DX
   JMP END_M_SUB_D_P
SUB_D_D:          ; SUB D,D ����
   MOV DX,D
   SUB C,DX
   JMP END_M_SUB_D_P
SUB_D_E:          ; SUB D,E ����
   MOV DX,E
   SUB C,DX
   JMP END_M_SUB_D_P
SUB_D_F:          ; SUB D,F ����
   MOV DX,F
   SUB C,DX
   JMP END_M_SUB_D_P
SUB_D_X:          ; SUB D,X ����
   MOV DX,X
   SUB C,DX
   JMP END_M_SUB_D_P
SUB_D_Y:          ; SUB D,Y����
   MOV DX,Y
   SUB C,DX
   JMP END_M_SUB_D_P

   PRINT ERR

END_M_SUB_D_P:
   RET
SUB_D_P ENDP

;------------------------------------------------
;Procedure Name : SUB_E_P
;Function : SUB E, ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27,2016
;------------------------------------------------
SUB_E_P PROC            ; SUB E,REGISTER

   CMP VDECODE[8],1000b		; OPERAND2 ���� A
   JE SUB_E_A
   CMP VDECODE[8],1001b		; OPERAND2 ���� B
   JE SUB_E_B
   CMP VDECODE[8],1010b		; OPERAND2 ���� C
   JE SUB_E_C
   CMP VDECODE[8],1011b		; OPERAND2 ���� D
   JE SUB_E_D
   CMP VDECODE[8],1100b		; OPERAND2 ���� E
   JE SUB_E_E
   CMP VDECODE[8],1101b		; OPERAND2 ���� F
   JE SUB_E_F
   CMP VDECODE[8],1110b		; OPERAND2 ���� X
   JE SUB_E_X
   CMP VDECODE[8],1111b		; OPERAND2 ���� Y
   JE SUB_E_Y

SUB_E_A:          ; SUB E,A ����
   MOV DX,A
   SUB E,DX
   JMP END_M_SUB_E_P
SUB_E_B:          ; SUB E,B ����
   MOV DX,B
   SUB E,DX
   JMP END_M_SUB_E_P
SUB_E_C:          ; SUB E,C ����
   MOV DX,C
   SUB E,DX
   JMP END_M_SUB_E_P
SUB_E_D:          ; SUB E,D ����
   MOV DX,D
   SUB E,DX
   JMP END_M_SUB_E_P
SUB_E_E:          ; SUB E,E ����
   MOV DX,E
   SUB E,DX
   JMP END_M_SUB_E_P
SUB_E_F:          ; SUB E,F ����
   MOV DX,F
   SUB E,DX
   JMP END_M_SUB_E_P
SUB_E_X:          ; SUB E,X ����
   MOV DX,X
   SUB E,DX
   JMP END_M_SUB_E_P
SUB_E_Y:          ; SUB E,Y����
   MOV DX,Y
   SUB E,DX
   JMP END_M_SUB_D_P

   PRINT ERR

END_M_SUB_E_P:
   RET
SUB_E_P ENDP

;------------------------------------------------
;Procedure Name : SUB_F_P
;Function : SUB F, ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27,2016
;------------------------------------------------
SUB_F_P PROC            ; SUB F,REGISTER

   CMP VDECODE[8],1000b		; OPERAND2 ���� A
   JE SUB_F_A
   CMP VDECODE[8],1001b		; OPERAND2 ���� B
   JE SUB_F_B
   CMP VDECODE[8],1010b		; OPERAND2 ���� C
   JE SUB_F_C
   CMP VDECODE[8],1011b		; OPERAND2 ���� D
   JE SUB_F_D
   CMP VDECODE[8],1100b		; OPERAND2 ���� E
   JE SUB_F_E
   CMP VDECODE[8],1101b		; OPERAND2 ���� F
   JE SUB_F_F
   CMP VDECODE[8],1110b		; OPERAND2 ���� X
   JE SUB_F_X
   CMP VDECODE[8],1111b		; OPERAND2 ���� Y
   JE SUB_F_Y

SUB_F_A:          ; SUB F,A ����
   MOV DX,A
   SUB F,DX
   JMP END_M_SUB_F_P
SUB_F_B:          ; SUB F,B ����
   MOV DX,B
   SUB F,DX
   JMP END_M_SUB_F_P
SUB_F_C:          ; SUB F,C ����
   MOV DX,C
   SUB F,DX
   JMP END_M_SUB_F_P
SUB_F_D:          ; SUB F,D ����
   MOV DX,D
   SUB F,DX
   JMP END_M_SUB_F_P
SUB_F_E:          ; SUB F,E ����
   MOV DX,E
   SUB F,DX
   JMP END_M_SUB_F_P
SUB_F_F:          ; SUB F,F ����
   MOV DX,F
   SUB F,DX
   JMP END_M_SUB_F_P
SUB_F_X:          ; SUB F,X ����
   MOV DX,X
   SUB F,DX
   JMP END_M_SUB_F_P
SUB_F_Y:          ; SUB F,Y����
   MOV DX,Y
   SUB F,DX
   JMP END_M_SUB_F_P

   PRINT ERR

END_M_SUB_F_P:
   RET
SUB_F_P ENDP

;------------------------------------------------
;Procedure Name : SUB_X_P
;Function : SUB X, ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27,2016
;------------------------------------------------
SUB_X_P PROC            ; SUB X,REGISTER

   CMP VDECODE[8],1000b		; OPERAND2 ���� A
   JE SUB_X_A
   CMP VDECODE[8],1001b		; OPERAND2 ���� B
   JE SUB_X_B
   CMP VDECODE[8],1010b		; OPERAND2 ���� C
   JE SUB_X_C
   CMP VDECODE[8],1011b		; OPERAND2 ���� D
   JE SUB_X_D
   CMP VDECODE[8],1100b		; OPERAND2 ���� E
   JE SUB_X_E
   CMP VDECODE[8],1101b		; OPERAND2 ���� F
   JE SUB_X_F
   CMP VDECODE[8],1110b		; OPERAND2 ���� X
   JE SUB_X_X
   CMP VDECODE[8],1111b		; OPERAND2 ���� Y
   JE SUB_X_Y

SUB_X_A:          ; SUB X,A ����
   MOV DX,A
   SUB X,DX
   JMP END_M_SUB_X_P
SUB_X_B:          ; SUB X,B ����
   MOV DX,B
   SUB X,DX
   JMP END_M_SUB_X_P
SUB_X_C:          ; SUB X,C ����
   MOV DX,C
   SUB X,DX
   JMP END_M_SUB_X_P
SUB_X_D:          ; SUB X,D ����
   MOV DX,D
   SUB X,DX
   JMP END_M_SUB_X_P
SUB_X_E:          ; SUB X,E ����
   MOV DX,E
   SUB X,DX
   JMP END_M_SUB_X_P
SUB_X_F:          ; SUB X,F ����
   MOV DX,F
   SUB X,DX
   JMP END_M_SUB_X_P
SUB_X_X:          ; SUB X,X ����
   MOV DX,X
   SUB X,DX
   JMP END_M_SUB_X_P
SUB_X_Y:          ; SUB X,Y����
   MOV DX,Y
   SUB X,DX
   JMP END_M_SUB_X_P

   PRINT ERR

END_M_SUB_X_P:
   RET
SUB_X_P ENDP

;------------------------------------------------
;Procedure Name : SUB_Y_P
;Function : SUB Y, ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27,2016
;------------------------------------------------
SUB_Y_P PROC            ; SUB Y,REGISTER

   CMP VDECODE[8],1000b		; OPERAND2 ���� A
   JE SUB_Y_A
   CMP VDECODE[8],1001b		; OPERAND2 ���� B
   JE SUB_Y_B
   CMP VDECODE[8],1010b		; OPERAND2 ���� C
   JE SUB_Y_C
   CMP VDECODE[8],1011b		; OPERAND2 ���� D
   JE SUB_Y_D
   CMP VDECODE[8],1100b		; OPERAND2 ���� E
   JE SUB_Y_E
   CMP VDECODE[8],1101b		; OPERAND2 ���� F
   JE SUB_Y_F
   CMP VDECODE[8],1110b		; OPERAND2 ���� X
   JE SUB_Y_X
   CMP VDECODE[8],1111b		; OPERAND2 ���� Y
   JE SUB_Y_Y

SUB_Y_A:          ; SUB Y,A ����
   MOV DX,A
   SUB Y,DX
   JMP END_M_SUB_Y_P
SUB_Y_B:          ; SUB Y,B ����
   MOV DX,B
   SUB Y,DX
   JMP END_M_SUB_Y_P
SUB_Y_C:          ; SUB Y,C ����
   MOV DX,C
   SUB Y,DX
   JMP END_M_SUB_Y_P
SUB_Y_D:          ; SUB Y,D ����
   MOV DX,D
   SUB Y,DX
   JMP END_M_SUB_Y_P
SUB_Y_E:          ; SUB Y,E ����
   MOV DX,E
   SUB Y,DX
   JMP END_M_SUB_Y_P
SUB_Y_F:          ; SUB Y,F ����
   MOV DX,F
   SUB Y,DX
   JMP END_M_SUB_Y_P
SUB_Y_X:          ; SUB Y,X ����
   MOV DX,X
   SUB Y,DX
   JMP END_M_SUB_Y_P
SUB_Y_Y:          ; SUB Y,Y����
   MOV DX,Y
   SUB Y,DX
   JMP END_M_SUB_Y_P

   PRINT ERR

END_M_SUB_Y_P:
   RET
SUB_Y_P ENDP

;------------------------------------------------
;Procedure Name : SUB_A_IMME_P
;Function : SUB A,IMMEDIATE ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27,2016
;------------------------------------------------
SUB_A_IMME_P PROC       ; SUB A,IMMEDIATE

   MOV BX,VDECODE[10]	; IMMEDIATE���� ����Ǿ��ִ� VDECODE[10]���� A�� SUB����
   SUB A,BX
   RET
SUB_A_IMME_P ENDP

;------------------------------------------------
;Procedure Name : SUB_B_IMME_P
;Function : SUB B,IMMEDIATE ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27,2016
;------------------------------------------------
SUB_B_IMME_P PROC       ; SUB B,IMMEDIATE

   MOV BX,VDECODE[10]	; IMMEDIATE���� ����Ǿ��ִ� VDECODE[10]���� B�� SUB����
   SUB B,BX
   RET
SUB_B_IMME_P ENDP

;------------------------------------------------
;Procedure Name : SUB_C_IMME_P
;Function : SUB C,IMMEDIATE ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27,2016
;------------------------------------------------
SUB_C_IMME_P PROC       ; SUB C,IMMEDIATE

   MOV BX,VDECODE[10]	; IMMEDIATE���� ����Ǿ��ִ� VDECODE[10]���� C�� SUB����
   SUB C,BX
   RET
SUB_C_IMME_P ENDP

;------------------------------------------------
;Procedure Name : SUB_D_IMME_P
;Function : SUB D,IMMEDIATE ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27,2016
;------------------------------------------------
SUB_D_IMME_P PROC       ; SUB D,IMMEDIATE

   MOV BX,VDECODE[10]	; IMMEDIATE���� ����Ǿ��ִ� VDECODE[10]���� D�� SUB����
   SUB D,BX
   RET
SUB_D_IMME_P ENDP

;------------------------------------------------
;Procedure Name : SUB_E_IMME_P
;Function : SUB E,IMMEDIATE ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27,2016
;------------------------------------------------
SUB_E_IMME_P PROC       ; SUB E,IMMEDIATE

   MOV BX,VDECODE[10]	; IMMEDIATE���� ����Ǿ��ִ� VDECODE[10]���� E�� SUB����
   SUB E,BX
   RET
SUB_E_IMME_P ENDP

;------------------------------------------------
;Procedure Name : SUB_F_IMME_P
;Function : SUB F,IMMEDIATE ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27,2016
;------------------------------------------------
SUB_F_IMME_P PROC       ; SUB F,IMMEDIATE

   MOV BX,VDECODE[10]	; IMMEDIATE���� ����Ǿ��ִ� VDECODE[10]���� F�� SUB����
   SUB F,BX
   RET
SUB_F_IMME_P ENDP

;------------------------------------------------
;Procedure Name : SUB_X_IMME_P
;Function : SUB X,IMMEDIATE ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27,2016
;------------------------------------------------
SUB_X_IMME_P PROC       ; SUB X,IMMEDIATE

   MOV BX,VDECODE[10]	; IMMEDIATE���� ����Ǿ��ִ� VDECODE[10]���� X�� SUB����
   SUB X,BX
   RET
SUB_X_IMME_P ENDP

;------------------------------------------------
;Procedure Name : SUB_Y_IMME_P
;Function : SUB Y,IMMEDIATE ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27,2016
;------------------------------------------------
SUB_Y_IMME_P PROC       ; SUB Y,IMMEDIATE

   MOV BX,VDECODE[10]	; IMMEDIATE���� ����Ǿ��ִ� VDECODE[10]���� Y�� SUB����
   SUB Y,BX
   RET
SUB_Y_IMME_P ENDP

;------------------------------------------------
;Procedure Name : SUB_A_REIN_P
;Function : SUB A, REGISTER-INDIRECT ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27,2016
;------------------------------------------------
SUB_A_REIN_P PROC       ; SUB A,[] ���ν���
   CMP VDECODE[8],1110b		; OPERAND2 �� X
   JE SUB_A_REIN_X
   CMP VDECODE[8],1111b		; OPERAND2 �� Y
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
;Function : SUB B, REGISTER-INDIRECT ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27,2016
;------------------------------------------------
SUB_B_REIN_P PROC       ; SUB B,[] ���ν���
   CMP VDECODE[8],1110b	; OPERAND2 �� X
   JE SUB_B_REIN_X
   CMP VDECODE[8],1111b	; OPERAND2 �� Y
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
;Function : SUB C, REGISTER-INDIRECT ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27,2016
;------------------------------------------------
SUB_C_REIN_P PROC       ; SUB C,[] ���ν���
   CMP VDECODE[8],1110b ; OPERAND2 �� X
   JE SUB_C_REIN_X
   CMP VDECODE[8],1111b ; OPERAND2 �� Y
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
;Function : SUB D, REGISTER-INDIRECT ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27,2016
;------------------------------------------------
SUB_D_REIN_P PROC       ; SUB D,[] ���ν���
   CMP VDECODE[8],1110b ; OPERAND2 �� X
   JE SUB_D_REIN_X
   CMP VDECODE[8],1111b ; OPERAND2 �� Y
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
;Function : SUB E, REGISTER-INDIRECT ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27,2016
;------------------------------------------------
SUB_E_REIN_P PROC       ; SUB E,[] ���ν���
   CMP VDECODE[8],1110b ; OPERAND2 �� X
   JE SUB_E_REIN_X
   CMP VDECODE[8],1111b ; OPERAND2 �� Y
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
;Function : SUB F, REGISTER-INDIRECT ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27,2016
;------------------------------------------------
SUB_F_REIN_P PROC       ; SUB F,[] ���ν���
   CMP VDECODE[8],1110b ; OPERAND2 �� X
   JE SUB_F_REIN_X
   CMP VDECODE[8],1111b ; OPERAND2 �� Y
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
;Function : SUB X, REGISTER-INDIRECT ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27,2016
;------------------------------------------------
SUB_X_REIN_P PROC       ; SUB X,[] ���ν���
   CMP VDECODE[8],1110b ; OPERAND2 �� X
   JE SUB_X_REIN_X
   CMP VDECODE[8],1111b ; OPERAND2 �� Y
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
;Function : SUB Y, REGISTER-INDIRECT ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27,2016
;------------------------------------------------
SUB_Y_REIN_P PROC       ; SUB Y,[] ���ν���
   CMP VDECODE[8],1110b ; OPERAND2 �� X
   JE SUB_Y_REIN_X
   CMP VDECODE[8],1111b ; OPERAND2 �� Y
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
;Function : SUB A, DIRCET ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27,2016
;------------------------------------------------
SUB_A_DI_P PROC
   
   MOV SI, VDECODE[10]  ; VDECODE[10]�� ���� �Ǿ��ִ� �ּҰ��� SI�� ����
   MOV BX, m[SI]
   SUB A,BX				; A�� ���� M[SI] ���� SUB���� 

   RET
SUB_A_DI_P ENDP

;------------------------------------------------
;Procedure Name : SUB_B_DI_P
;Function : SUB B, DIRCET ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27,2016
;------------------------------------------------
SUB_B_DI_P PROC
   
   MOV SI, VDECODE[10]  ; VDECODE[10]�� ���� �Ǿ��ִ� �ּҰ��� SI�� ����  
   MOV BX, m[SI]
   SUB B,BX				; B�� ���� M[SI] ���� SUB���� 

   RET
SUB_B_DI_P ENDP

;------------------------------------------------
;Procedure Name : SUB_C_DI_P
;Function : SUB C, DIRCET ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27,2016
;------------------------------------------------
SUB_C_DI_P PROC
   
   MOV SI, VDECODE[10]  ; VDECODE[10]�� ���� �Ǿ��ִ� �ּҰ��� SI�� ����  
   MOV BX, m[SI]
   SUB C,BX				; C�� ���� M[SI] ���� SUB����

   RET
SUB_C_DI_P ENDP

;------------------------------------------------
;Procedure Name : SUB_D_DI_P
;Function : SUB D, DIRCET ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27,2016
;------------------------------------------------
SUB_D_DI_P PROC
   
   MOV SI, VDECODE[10]    ; VDECODE[10]�� ���� �Ǿ��ִ� �ּҰ��� SI�� ����
   MOV BX, m[SI]
   SUB D,BX			; D�� ���� M[SI] ���� SUB����

   RET
SUB_D_DI_P ENDP

;------------------------------------------------
;Procedure Name : SUB_E_DI_P
;Function : SUB E, DIRCET ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27,2016
;------------------------------------------------
SUB_E_DI_P PROC
   
   MOV SI, VDECODE[10]      ; VDECODE[10]�� ���� �Ǿ��ִ� �ּҰ��� SI�� ����
   MOV BX, m[SI]
   SUB E,BX				; E�� ���� M[SI] ���� SUB����

   RET
SUB_E_DI_P ENDP

;------------------------------------------------
;Procedure Name : SUB_F_DI_P
;Function : SUB F, DIRCET ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27,2016
;------------------------------------------------
SUB_F_DI_P PROC
   
   MOV SI, VDECODE[10]       ; VDECODE[10]�� ���� �Ǿ��ִ� �ּҰ��� SI�� ���� 
   MOV BX, m[SI]
   SUB F,BX			; F�� ���� M[SI] ���� SUB����

   RET
SUB_F_DI_P ENDP

;------------------------------------------------
;Procedure Name : SUB_X_DI_P
;Function : SUB X, DIRCET ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27,2016
;------------------------------------------------
SUB_X_DI_P PROC
   
   MOV SI, VDECODE[10]       ; VDECODE[10]�� ���� �Ǿ��ִ� �ּҰ��� SI�� ���� 
   MOV BX, m[SI]
   SUB X,BX					; X�� ���� M[SI] ���� SUB����

   RET
SUB_X_DI_P ENDP

;------------------------------------------------
;Procedure Name : SUB_Y_DI_P
;Function : SUB Y, DIRCET ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27,2016
;------------------------------------------------
SUB_Y_DI_P PROC
   
   MOV SI, VDECODE[10]         ; VDECODE[10]�� ���� �Ǿ��ִ� �ּҰ��� SI�� ����
   MOV BX, m[SI]
   SUB Y,BX				; Y�� ���� M[SI] ���� SUB����

   RET
SUB_Y_DI_P ENDP


;------------------------------------------------
;Procedure Name : M_MOV
;Function : MOV ��ɾ ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 26,2016
;   Last Modified On Nov 26,2016
;------------------------------------------------
M_MOV PROC
	CMP VDECODE[4], 0000b	;ù��° �ǿ����ڸ� �ǹ��ϴ� VDECODE[4]�� 0�̸� MOV �ּҰ�,�������͸� �ǹ�
	JE M_MOV_IMMEDIATE_REST
   CMP VDECODE[4],1000b ; OPERAND1�� A�� ��
   JE M_MOV_A
   CMP VDECODE[4],1001b ; OPERAND1�� B�� ��
   JE M_MOV_B
   CMP VDECODE[4],1010b ; OPERAND1�� C�� ��
   JE M_MOV_C           
   CMP VDECODE[4],1011b ; OPERAND1�� D�� ��
   JE REST_MOV1
   CMP VDECODE[4],1100b ; OPERAND1�� E�� ��
   JE REST_MOV1
   CMP VDECODE[4],1101b ; OPERAND1�� F�� ��
   JE REST_MOV1
   CMP VDECODE[4],1110b ; OPERAND1�� X�� ��
   JE REST_MOV1
   CMP VDECODE[4],1111b ; OPERAND1�� Y�� ��
   JE REST_MOV1

   PRINT ERR
   JMP END_M_MOV

M_MOV_A:											; OPERAND1�� A�� ��
   CALL MOV_A_P										; MOV_A_P�� ȣ��
   JMP END_M_MOV

M_MOV_B:											; OPERAND1�� B�� ��
   CALL MOV_B_P										; MOV_B_P�� ȣ��
   JMP END_M_MOV

M_MOV_IMMEDIATE_REST:
   JMP M_MOV_IMMEDIATE

M_MOV_C:											; OPERAND1�� C�� ��
   CALL MOV_C_P										; MOV_C_P�� ȣ��
   JMP END_M_MOV
   
REST_MOV1:
   CMP VDECODE[4],1011b ; OPERAND1�� D�� ��
   JE M_MOV_D
   CMP VDECODE[4],1100b ; OPERAND1�� E�� ��
   JE M_MOV_E
   CMP VDECODE[4],1101b ; OPERAND1�� F�� ��
   JE M_MOV_F
   CMP VDECODE[4],1110b ; OPERAND1�� X�� ��
   JE M_MOV_X
   CMP VDECODE[4],1111b ; OPERAND1�� Y�� ��
   JE M_MOV_Y

   PRINT ERR
   JMP END_M_MOV

M_MOV_D:											; OPERAND1�� D�� ��
   CALL MOV_D_P										; MOV_D_P�� ȣ��
   JMP END_M_MOV

M_MOV_E:											; OPERAND1�� E�� ��
   CALL MOV_E_P										; MOV_E_P�� ȣ��
   JMP END_M_MOV

M_MOV_F:											; OPERAND1�� F�� ��
   CALL MOV_F_P										; MOV_F_P�� ȣ��
   JMP END_M_MOV

M_MOV_X:											; OPERAND1�� X�� ��
   CALL MOV_X_P										; MOV_X_P�� ȣ��
   JMP END_M_MOV

M_MOV_Y:											; OPERAND1�� Y�� ��
   CALL MOV_Y_P										; MOV_Y_P�� ȣ��
   JMP END_M_MOV

M_MOV_IMMEDIATE:											; OPERAND1�� �ּҰ� �� ��
	CALL M_MOV_IMMEDIATE_P									; M_MOV_IMMEDIATE_P�� ȣ��
	JMP END_M_MOV
END_M_MOV:
   RET
M_MOV ENDP

;------------------------------------------------
;Procedure Name : M_MOV_IMMEDIATE_P
;Function : MOV �ּҰ�,�������� ����� ����
;PROGRAMED BY ������
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
;Function : MOV A, ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 26,2016
;   Last Modified On Nov 26,2016
;------------------------------------------------
MOV_A_P PROC
   MOV AX, VDECODE[2]
   AND AX,11b
   MOV VDECODE[2],AX
								; MOV A,
   CMP VDECODE[2],00b			; VDECODE[2]���� Ȯ���Ͽ� 00�̸� Register ���
   JE MOV_A_REGI
   CMP VDECODE[2],01b			; VDECODE[2]���� Ȯ���Ͽ� 01�̸� Immediate ���
   JE MOV_A_IMME
   CMP VDECODE[2],10b			; VDECODE[2]���� Ȯ���Ͽ� 10�̸� Register-Indirect ���
   JE MOV_A_REGI_IMME
   CMP VDECODE[2],11b			; VDECODE[2]���� Ȯ���Ͽ� 11�̸� Direct ���
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
;Function : MOV A,REGISTER ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 26,2016
;   Last Modified On Nov 26,2016
;------------------------------------------------
MOV_A_REGI_P PROC
   MOV AX,VDECODE[8]                         ; MOV A,REGISTER
   AND AX,1111b
   MOV VDECODE[8],AX

   CMP VDECODE[8],1000b						; �ǿ�����2�� ���� ����Ǿ��ִ� VDECODE[8]�� 1000b�̸� MOV A,A
   JE MOV_A_A
   CMP VDECODE[8],1001b						; �ǿ�����2�� ���� ����Ǿ��ִ� VDECODE[8]�� 1001b�̸� MOV A,B
   JE MOV_A_B
   CMP VDECODE[8],1010b						; �ǿ�����2�� ���� ����Ǿ��ִ� VDECODE[8]�� 1010b�̸� MOV A,C
   JE MOV_A_C
   CMP VDECODE[8],1011b						; �ǿ�����2�� ���� ����Ǿ��ִ� VDECODE[8]�� 1011b�̸� MOV A,D
   JE MOV_A_D
   CMP VDECODE[8],1100b						; �ǿ�����2�� ���� ����Ǿ��ִ� VDECODE[8]�� 1100b�̸� MOV A,E
   JE MOV_A_E
   CMP VDECODE[8],1101b						; �ǿ�����2�� ���� ����Ǿ��ִ� VDECODE[8]�� 1101b�̸� MOV A,F
   JE MOV_A_F
   CMP VDECODE[8],1110b						; �ǿ�����2�� ���� ����Ǿ��ִ� VDECODE[8]�� 1110b�̸� MOV A,X
   JE MOV_A_X
   CMP VDECODE[8],1111b						; �ǿ�����2�� ���� ����Ǿ��ִ� VDECODE[8]�� 1111b�̸� MOV A,Y
   JE MOV_A_Y

   PRINT ERR
   JMP END_M_MOV_A_REGI_P

MOV_A_A:									; MOV A,A�� ����
   MOV AX,A
   MOV A,AX
   JMP END_M_MOV_A_REGI_P
MOV_A_B:									; MOV A,B�� ����
   MOV AX,B
   MOV A,AX
   JMP END_M_MOV_A_REGI_P
MOV_A_C:									; MOV A,C�� ����
   MOV AX,C
   MOV A,AX
   JMP END_M_MOV_A_REGI_P
MOV_A_D:									; MOV A,D�� ����
   MOV AX,D
   MOV A,AX
   JMP END_M_MOV_A_REGI_P
MOV_A_E:									; MOV A,E�� ����
   MOV AX,E
   MOV A,AX
   JMP END_M_MOV_A_REGI_P
MOV_A_F:									; MOV A,F�� ����
   MOV AX,F
   MOV A,AX
   JMP END_M_MOV_A_REGI_P
MOV_A_X:									; MOV A,X�� ����
   MOV AX,X
   MOV A,AX
   JMP END_M_MOV_A_REGI_P
MOV_A_Y:									; MOV A,Y�� ����
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
;Function : MOV A,IMMEDIATE ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 26,2016
;   Last Modified On Nov 26,2016
;------------------------------------------------
MOV_A_IMME_P PROC                   
   MOV DX,VDECODE[10]					; VDECODE[10]�� ����Ǿ��ִ� IMMEDIATE���� �������� A�� ����
   MOV A,DX
   RET
MOV_A_IMME_P ENDP

;------------------------------------------------
;Procedure Name : MOV_A_REGI_IMME_P
;Function : MOV ��ɾ��� REGISTER-INDIRECT ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 26,2016
;   Last Modified On Nov 26,2016
;------------------------------------------------
MOV_A_REGI_IMME_P PROC                 ; MOV A,REGISTER_IMMEDIATE
   CMP VDECODE[8],1110				   ; �ǿ�����2�� ���� X
   JE MOV_A_R_I_X
   CMP VDECODE[8],1111				   ; �ǿ�����2�� ���� Y
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
;Function : MOV ��ɾ��� DIRECT ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 26,2016
;   Last Modified On Nov 26,2016
;------------------------------------------------
MOV_A_DI_P PROC                     ; MOV A,DIRECT
   MOV SI,VDECODE[10]				; VDECODE���� ����ִ� DIRCET�ּҰ��� ����
   MOV DX,M[SI]
   MOV A,DX
   RET
MOV_A_DI_P ENDP

;------------------------------------------------
;Procedure Name : MOV_B_P
;Function : MOV B, ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 26,2016
;   Last Modified On Nov 26,2016
;------------------------------------------------
MOV_B_P PROC
   MOV AX, VDECODE[2]
   AND AX,11b
   MOV VDECODE[2],AX
                              ; MOV B,
   CMP VDECODE[2],00b			; VDECODE[2]���� Ȯ���Ͽ� 00�̸� Register ���
   JE MOV_B_REGI
   CMP VDECODE[2],01b			; VDECODE[2]���� Ȯ���Ͽ� 01�̸� Immediate ���
   JE MOV_B_IMME
   CMP VDECODE[2],10b			; VDECODE[2]���� Ȯ���Ͽ� 10�̸� Register-Indirect ���
   JE MOV_B_REGI_IMME
   CMP VDECODE[2],11b			; VDECODE[2]���� Ȯ���Ͽ� 11�̸� Direct ���
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
;Function : MOV B,REGISTER ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 26,2016
;   Last Modified On Nov 26,2016
;------------------------------------------------
MOV_B_REGI_P PROC
   MOV AX,VDECODE[8]                         ; MOV B,REGISTER
   AND AX,1111b
   MOV VDECODE[8],AX

   CMP VDECODE[8],1000b						; �ǿ�����2�� ���� ����Ǿ��ִ� VDECODE[8]�� 1000b�̸� MOV B,A
   JE MOV_B_A
   CMP VDECODE[8],1001b						; �ǿ�����2�� ���� ����Ǿ��ִ� VDECODE[8]�� 1000b�̸� MOV B,B
   JE MOV_B_B
   CMP VDECODE[8],1010b						; �ǿ�����2�� ���� ����Ǿ��ִ� VDECODE[8]�� 1000b�̸� MOV B,C
   JE MOV_B_C
   CMP VDECODE[8],1011b						; �ǿ�����2�� ���� ����Ǿ��ִ� VDECODE[8]�� 1000b�̸� MOV B,D
   JE MOV_B_D
   CMP VDECODE[8],1100b						; �ǿ�����2�� ���� ����Ǿ��ִ� VDECODE[8]�� 1000b�̸� MOV B,E
   JE MOV_B_E
   CMP VDECODE[8],1101b						; �ǿ�����2�� ���� ����Ǿ��ִ� VDECODE[8]�� 1000b�̸� MOV B,F
   JE MOV_B_F
   CMP VDECODE[8],1110b						; �ǿ�����2�� ���� ����Ǿ��ִ� VDECODE[8]�� 1000b�̸� MOV B,X
   JE MOV_B_X
   CMP VDECODE[8],1111b						; �ǿ�����2�� ���� ����Ǿ��ִ� VDECODE[8]�� 1000b�̸� MOV B,Y
   JE MOV_B_Y

   PRINT ERR
   JMP END_M_MOV_B_REGI_P

MOV_B_A:									; MOV B,A�� ����
   MOV AX,A
   MOV B,AX
   JMP END_M_MOV_B_REGI_P
MOV_B_B:									; MOV B,B�� ����
   MOV AX,B
   MOV B,AX
   JMP END_M_MOV_B_REGI_P
MOV_B_C:									; MOV B,C�� ����
   MOV AX,C
   MOV B,AX
   JMP END_M_MOV_B_REGI_P
MOV_B_D:									; MOV B,D�� ����
   MOV AX,D
   MOV B,AX
   JMP END_M_MOV_B_REGI_P
MOV_B_E:									; MOV B,E�� ����
   MOV AX,E
   MOV B,AX
   JMP END_M_MOV_B_REGI_P
MOV_B_F:									; MOV B,F�� ����
   MOV AX,F
   MOV B,AX
   JMP END_M_MOV_B_REGI_P
MOV_B_X:									; MOV B,X�� ����
   MOV AX,X
   MOV B,AX
   JMP END_M_MOV_B_REGI_P
MOV_B_Y:									; MOV B,Y�� ����
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
;Function : MOV B,IMMEDIATE ����� ����
;PROGRAMED BY ������
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
;Function : MOV ��ɾ��� REGISTER-INDIRECT ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 26,2016
;   Last Modified On Nov 26,2016
;------------------------------------------------
MOV_B_REGI_IMME_P PROC                 ; MOV B,REGISTER_IMMEDIATE
   CMP VDECODE[8],1110				   ; �ǿ�����2�� ���� X
   JE MOV_B_R_I_X
   CMP VDECODE[8],1111				   ; �ǿ�����2�� ���� Y
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
;Function : MOV ��ɾ��� DIRECT ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 26,2016
;   Last Modified On Nov 26,2016
;------------------------------------------------
MOV_B_DI_P PROC                     ; MOV B,DIRECT
   MOV SI,VDECODE[10]  				; VDECODE���� ����ִ� DIRCET�ּҰ��� ���� 
   MOV DX,M[SI]
   MOV B,DX
   RET
MOV_B_DI_P ENDP

;------------------------------------------------
;Procedure Name : MOV_C_P
;Function : MOV C, ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 26,2016
;   Last Modified On Nov 26,2016
;------------------------------------------------
MOV_C_P PROC
   MOV AX, VDECODE[2]
   AND AX,11b
   MOV VDECODE[2],AX
                              ; MOV C,
   CMP VDECODE[2],00b			; VDECODE[2]���� Ȯ���Ͽ� 00�̸� Register ���
   JE MOV_C_REGI
   CMP VDECODE[2],01b			; VDECODE[2]���� Ȯ���Ͽ� 01�̸� Immediate ���
   JE MOV_C_IMME
   CMP VDECODE[2],10b			; VDECODE[2]���� Ȯ���Ͽ� 10�̸� Register-Indirect ���
   JE MOV_C_REGI_IMME
   CMP VDECODE[2],11b			; VDECODE[2]���� Ȯ���Ͽ� 11�̸� Direct ���
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
;Function : MOV C,REGISTER ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 26,2016
;   Last Modified On Nov 26,2016
;------------------------------------------------
MOV_C_REGI_P PROC
   MOV AX,VDECODE[8]                         ; MOV C,REGISTER
   AND AX,1111b
   MOV VDECODE[8],AX

   CMP VDECODE[8],1000b						; �ǿ�����2�� ���� ����Ǿ��ִ� VDECODE[8]�� 1000b�̸� MOV C,A
   JE MOV_C_A
   CMP VDECODE[8],1001b						; �ǿ�����2�� ���� ����Ǿ��ִ� VDECODE[8]�� 1000b�̸� MOV C,B
   JE MOV_C_B
   CMP VDECODE[8],1010b						; �ǿ�����2�� ���� ����Ǿ��ִ� VDECODE[8]�� 1000b�̸� MOV C,C
   JE MOV_C_C
   CMP VDECODE[8],1011b						; �ǿ�����2�� ���� ����Ǿ��ִ� VDECODE[8]�� 1000b�̸� MOV C,D
   JE MOV_C_D
   CMP VDECODE[8],1100b						; �ǿ�����2�� ���� ����Ǿ��ִ� VDECODE[8]�� 1000b�̸� MOV C,E
   JE MOV_C_E
   CMP VDECODE[8],1101b						; �ǿ�����2�� ���� ����Ǿ��ִ� VDECODE[8]�� 1000b�̸� MOV C,F
   JE MOV_C_F
   CMP VDECODE[8],1110b						; �ǿ�����2�� ���� ����Ǿ��ִ� VDECODE[8]�� 1000b�̸� MOV C,X
   JE MOV_C_X
   CMP VDECODE[8],1111b						; �ǿ�����2�� ���� ����Ǿ��ִ� VDECODE[8]�� 1000b�̸� MOV C,Y
   JE MOV_C_Y

   PRINT ERR
   JMP END_M_MOV_C_REGI_P

MOV_C_A:									; MOV C,A�� ����
   MOV AX,A
   MOV C,AX
   JMP END_M_MOV_C_REGI_P
MOV_C_B:									; MOV C,B�� ����
   MOV AX,B
   MOV C,AX
   JMP END_M_MOV_C_REGI_P
MOV_C_C:									; MOV C,C�� ����
   MOV AX,C
   MOV C,AX
   JMP END_M_MOV_C_REGI_P
MOV_C_D:									; MOV C,D�� ����
   MOV AX,D
   MOV C,AX
   JMP END_M_MOV_C_REGI_P
MOV_C_E:									; MOV C,E�� ����
   MOV AX,E
   MOV C,AX
   JMP END_M_MOV_C_REGI_P
MOV_C_F:									; MOV C,F�� ����
   MOV AX,F
   MOV C,AX
   JMP END_M_MOV_C_REGI_P
MOV_C_X:									; MOV C,X�� ����
   MOV AX,X
   MOV C,AX
   JMP END_M_MOV_C_REGI_P
MOV_C_Y:									; MOV C,Y�� ����
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
;Function : MOV C,IMMEDIATE ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 26,2016
;   Last Modified On Nov 26,2016
;------------------------------------------------
MOV_C_IMME_P PROC                   ; MOV C,IMMEDIATE
   MOV DX,VDECODE[10]					; VDECODE[10]�� ����Ǿ��ִ� IMMEDIATE���� �������� C�� ����
   MOV C,DX
   RET
MOV_C_IMME_P ENDP

;------------------------------------------------
;Procedure Name : MOV_A_REGI_IMME_P
;Function : MOV ��ɾ��� REGISTER-INDIRECT ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 26,2016
;   Last Modified On Nov 26,2016
;------------------------------------------------
MOV_C_REGI_IMME_P PROC                 ; MOV C,REGISTER_IMMEDIATE
   CMP VDECODE[8],1110				   ; �ǿ�����2�� ���� X
   JE MOV_C_R_I_X
   CMP VDECODE[8],1111				   ; �ǿ�����2�� ���� Y
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
;Function : MOV ��ɾ��� DIRECT ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 26,2016
;   Last Modified On Nov 26,2016
;------------------------------------------------
MOV_C_DI_P PROC                     ; MOV C,DIRECT
   MOV SI,VDECODE[10]   			; VDECODE[10]���� ����ִ� DIRCET�ּҰ��� ����
   MOV DX,M[SI]
   MOV C,DX
   RET
MOV_C_DI_P ENDP

;------------------------------------------------
;Procedure Name : MOV_D_P
;Function : MOV D, ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 26,2016
;   Last Modified On Nov 26,2016
;------------------------------------------------
MOV_D_P PROC
   MOV AX, VDECODE[2]
   AND AX,11b
   MOV VDECODE[2],AX
                              ; MOV D,
   CMP VDECODE[2],00b			; VDECODE[2]���� Ȯ���Ͽ� 00�̸� Register ���
   JE MOV_D_REGI
   CMP VDECODE[2],01b			; VDECODE[2]���� Ȯ���Ͽ� 01�̸� Immediate ���
   JE MOV_D_IMME
   CMP VDECODE[2],10b			; VDECODE[2]���� Ȯ���Ͽ� 10�̸� Register-Indirect ���
   JE MOV_D_REGI_IMME
   CMP VDECODE[2],11b			; VDECODE[2]���� Ȯ���Ͽ� 11�̸� Direct ���
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
;Function : MOV A,REGISTER ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 26,2016
;   Last Modified On Nov 26,2016
;------------------------------------------------
MOV_D_REGI_P PROC
   MOV AX,VDECODE[8]                         ; MOV D,REGISTER
   AND AX,1111b
   MOV VDECODE[8],AX

   CMP VDECODE[8],1000b						; �ǿ�����2�� ���� ����Ǿ��ִ� VDECODE[8]�� 1000b�̸� MOV D,A
   JE MOV_D_A
   CMP VDECODE[8],1001b						; �ǿ�����2�� ���� ����Ǿ��ִ� VDECODE[8]�� 1000b�̸� MOV D,B
   JE MOV_D_B
   CMP VDECODE[8],1010b						; �ǿ�����2�� ���� ����Ǿ��ִ� VDECODE[8]�� 1000b�̸� MOV D,C
   JE MOV_D_C
   CMP VDECODE[8],1011b						; �ǿ�����2�� ���� ����Ǿ��ִ� VDECODE[8]�� 1000b�̸� MOV D,D
   JE MOV_D_D
   CMP VDECODE[8],1100b						; �ǿ�����2�� ���� ����Ǿ��ִ� VDECODE[8]�� 1000b�̸� MOV D,E
   JE MOV_D_E
   CMP VDECODE[8],1101b						; �ǿ�����2�� ���� ����Ǿ��ִ� VDECODE[8]�� 1000b�̸� MOV D,F
   JE MOV_D_F
   CMP VDECODE[8],1110b						; �ǿ�����2�� ���� ����Ǿ��ִ� VDECODE[8]�� 1000b�̸� MOV D,X
   JE MOV_D_X
   CMP VDECODE[8],1111b						; �ǿ�����2�� ���� ����Ǿ��ִ� VDECODE[8]�� 1000b�̸� MOV D,Y
   JE MOV_D_Y

   PRINT ERR
   JMP END_M_MOV_D_REGI_P

MOV_D_A:									; MOV D,A�� ����
   MOV AX,A
   MOV D,AX
   JMP END_M_MOV_D_REGI_P
MOV_D_B:									; MOV D,B�� ����
   MOV AX,B
   MOV D,AX
   JMP END_M_MOV_D_REGI_P
MOV_D_C:									; MOV D,C�� ����
   MOV AX,C
   MOV D,AX
   JMP END_M_MOV_D_REGI_P
MOV_D_D:									; MOV D,D�� ����
   MOV AX,D
   MOV D,AX
   JMP END_M_MOV_D_REGI_P
MOV_D_E:									; MOV D,E�� ����
   MOV AX,E
   MOV D,AX
   JMP END_M_MOV_D_REGI_P
MOV_D_F:									; MOV D,F�� ����
   MOV AX,F
   MOV D,AX
   JMP END_M_MOV_D_REGI_P
MOV_D_X:									; MOV D,X�� ����
   MOV AX,X
   MOV D,AX
   JMP END_M_MOV_D_REGI_P
MOV_D_Y:									; MOV D,Y�� ����
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
;Function : MOV D,IMMEDIATE ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 26,2016
;   Last Modified On Nov 26,2016
;------------------------------------------------
MOV_D_IMME_P PROC                   ; MOV D,IMMEDIATE
   MOV DX,VDECODE[10]					; VDECODE[10]�� ����Ǿ��ִ� IMMEDIATE���� �������� D�� ����
   MOV D,DX
   RET
MOV_D_IMME_P ENDP

;------------------------------------------------
;Procedure Name : MOV_D_REGI_IMME_P
;Function : MOV ��ɾ��� REGISTER-INDIRECT ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 26,2016
;   Last Modified On Nov 26,2016
;------------------------------------------------
MOV_D_REGI_IMME_P PROC                 ; MOV D,REGISTER_IMMEDIATE
   CMP VDECODE[8],1110				   ; �ǿ�����2�� ���� X
   JE MOV_D_R_I_X
   CMP VDECODE[8],1111				   ; �ǿ�����2�� ���� Y
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
;Function : MOV ��ɾ��� DIRECT ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 26,2016
;   Last Modified On Nov 26,2016
;------------------------------------------------
MOV_D_DI_P PROC                     ; MOV D,DIRECT
   MOV SI,VDECODE[10]				; VDECODE[10]���� ����ִ� DIRCET�ּҰ��� ����   
   MOV DX,M[SI]
   MOV D,DX
   RET
MOV_D_DI_P ENDP

;------------------------------------------------
;Procedure Name : MOV_E_P
;Function : MOV E, ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 26,2016
;   Last Modified On Nov 26,2016
;------------------------------------------------
MOV_E_P PROC
   MOV AX, VDECODE[2]
   AND AX,11b
   MOV VDECODE[2],AX
                              ; MOV E,
   CMP VDECODE[2],00b			; VDECODE[2]���� Ȯ���Ͽ� 00�̸� Register ���
   JE MOV_E_REGI
   CMP VDECODE[2],01b			; VDECODE[2]���� Ȯ���Ͽ� 01�̸� Immediate ���
   JE MOV_E_IMME
   CMP VDECODE[2],10b			; VDECODE[2]���� Ȯ���Ͽ� 10�̸� Register-Indirect ���
   JE MOV_E_REGI_IMME
   CMP VDECODE[2],11b			; VDECODE[2]���� Ȯ���Ͽ� 11�̸� Direct ���
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
;Function : MOV E,REGISTER ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 26,2016
;   Last Modified On Nov 26,2016
;------------------------------------------------
MOV_E_REGI_P PROC
   MOV AX,VDECODE[8]                         ; MOV E,REGISTER
   AND AX,1111b
   MOV VDECODE[8],AX

   CMP VDECODE[8],1000b					; �ǿ�����2�� ���� ����Ǿ��ִ� VDECODE[8]�� 1000b�̸� MOV E,A
   JE MOV_E_A
   CMP VDECODE[8],1001b					; �ǿ�����2�� ���� ����Ǿ��ִ� VDECODE[8]�� 1000b�̸� MOV E,B
   JE MOV_E_B
   CMP VDECODE[8],1010b					; �ǿ�����2�� ���� ����Ǿ��ִ� VDECODE[8]�� 1000b�̸� MOV E,C
   JE MOV_E_C
   CMP VDECODE[8],1011b					; �ǿ�����2�� ���� ����Ǿ��ִ� VDECODE[8]�� 1000b�̸� MOV E,D
   JE MOV_E_D
   CMP VDECODE[8],1100b					; �ǿ�����2�� ���� ����Ǿ��ִ� VDECODE[8]�� 1000b�̸� MOV E,E
   JE MOV_E_E
   CMP VDECODE[8],1101b					; �ǿ�����2�� ���� ����Ǿ��ִ� VDECODE[8]�� 1000b�̸� MOV E,F
   JE MOV_E_F
   CMP VDECODE[8],1110b					; �ǿ�����2�� ���� ����Ǿ��ִ� VDECODE[8]�� 1000b�̸� MOV E,X
   JE MOV_E_X
   CMP VDECODE[8],1111b					; �ǿ�����2�� ���� ����Ǿ��ִ� VDECODE[8]�� 1000b�̸� MOV E,Y
   JE MOV_E_Y

   PRINT ERR
   JMP END_M_MOV_E_REGI_P

MOV_E_A:									; MOV E,A�� ����
   MOV AX,A
   MOV E,AX
   JMP END_M_MOV_E_REGI_P
MOV_E_B:									; MOV E,B�� ����
   MOV AX,B
   MOV E,AX
   JMP END_M_MOV_E_REGI_P
MOV_E_C:									; MOV E,C�� ����
   MOV AX,C
   MOV E,AX
   JMP END_M_MOV_E_REGI_P
MOV_E_D:									; MOV E,D�� ����
   MOV AX,D
   MOV E,AX
   JMP END_M_MOV_E_REGI_P
MOV_E_E:									; MOV E,E�� ����
   MOV AX,E
   MOV E,AX
   JMP END_M_MOV_E_REGI_P
MOV_E_F:									; MOV E,F�� ����
   MOV AX,F
   MOV E,AX
   JMP END_M_MOV_E_REGI_P
MOV_E_X:									; MOV E,X�� ����
   MOV AX,X
   MOV E,AX
   JMP END_M_MOV_E_REGI_P
MOV_E_Y:									; MOV E,Y�� ����
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
;Function : MOV E,IMMEDIATE ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 26,2016
;   Last Modified On Nov 26,2016
;------------------------------------------------
MOV_E_IMME_P PROC                   ; MOV E,IMMEDIATE
   MOV DX,VDECODE[10]					; VDECODE[10]�� ����Ǿ��ִ� IMMEDIATE���� �������� E�� ����
   MOV E,DX
   RET
MOV_E_IMME_P ENDP

;------------------------------------------------
;Procedure Name : MOV_E_REGI_IMME_P
;Function : MOV ��ɾ��� REGISTER-INDIRECT ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 26,2016
;   Last Modified On Nov 26,2016
;------------------------------------------------
MOV_E_REGI_IMME_P PROC                 ; MOV E,REGISTER_IMMEDIATE
   CMP VDECODE[8],1110				   ; �ǿ�����2�� ���� X
   JE MOV_E_R_I_X
   CMP VDECODE[8],1111				   ; �ǿ�����2�� ���� Y
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
;Function : MOV ��ɾ��� DIRECT ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 26,2016
;   Last Modified On Nov 26,2016
;------------------------------------------------
MOV_E_DI_P PROC                     ; MOV E,DIRECT
   MOV SI,VDECODE[10]  				; VDECODE[10]���� ����ִ� DIRCET�ּҰ��� ���� 
   MOV DX,M[SI]
   MOV E,DX
   RET
MOV_E_DI_P ENDP

;------------------------------------------------
;Procedure Name : MOV_F_P
;Function : MOV F, ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 26,2016
;   Last Modified On Nov 26,2016
;------------------------------------------------
MOV_F_P PROC
   MOV AX, VDECODE[2]
   AND AX,11b
   MOV VDECODE[2],AX
                              ; MOV F,
   CMP VDECODE[2],00b			; VDECODE[2]���� Ȯ���Ͽ� 00�̸� Register ���
   JE MOV_F_REGI
   CMP VDECODE[2],01b			; VDECODE[2]���� Ȯ���Ͽ� 01�̸� Immediate ���
   JE MOV_F_IMME
   CMP VDECODE[2],10b			; VDECODE[2]���� Ȯ���Ͽ� 10�̸� Register-Indirect ���
   JE MOV_F_REGI_IMME
   CMP VDECODE[2],11b			; VDECODE[2]���� Ȯ���Ͽ� 11�̸� Direct ���
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
;Function : MOV F,REGISTER ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 26,2016
;   Last Modified On Nov 26,2016
;------------------------------------------------
MOV_F_REGI_P PROC
   MOV AX,VDECODE[8]                         ; MOV F,REGISTER
   AND AX,1111b
   MOV VDECODE[8],AX

   CMP VDECODE[8],1000b						; �ǿ�����2�� ���� ����Ǿ��ִ� VDECODE[8]�� 1000b�̸� MOV F,A
   JE MOV_F_A
   CMP VDECODE[8],1001b						; �ǿ�����2�� ���� ����Ǿ��ִ� VDECODE[8]�� 1000b�̸� MOV F,B
   JE MOV_F_B
   CMP VDECODE[8],1010b						; �ǿ�����2�� ���� ����Ǿ��ִ� VDECODE[8]�� 1000b�̸� MOV F,C
   JE MOV_F_C
   CMP VDECODE[8],1011b						; �ǿ�����2�� ���� ����Ǿ��ִ� VDECODE[8]�� 1000b�̸� MOV F,D
   JE MOV_F_D
   CMP VDECODE[8],1100b						; �ǿ�����2�� ���� ����Ǿ��ִ� VDECODE[8]�� 1000b�̸� MOV F,E
   JE MOV_F_E
   CMP VDECODE[8],1101b						; �ǿ�����2�� ���� ����Ǿ��ִ� VDECODE[8]�� 1000b�̸� MOV F,F
   JE MOV_F_F
   CMP VDECODE[8],1110b						; �ǿ�����2�� ���� ����Ǿ��ִ� VDECODE[8]�� 1000b�̸� MOV F,X
   JE MOV_F_X
   CMP VDECODE[8],1111b						; �ǿ�����2�� ���� ����Ǿ��ִ� VDECODE[8]�� 1000b�̸� MOV F,Y
   JE MOV_F_Y

   PRINT ERR
   JMP END_M_MOV_F_REGI_P

MOV_F_A:									; MOV F,A�� ����
   MOV AX,A
   MOV F,AX
   JMP END_M_MOV_F_REGI_P
MOV_F_B:									; MOV F,B�� ����
   MOV AX,B
   MOV F,AX
   JMP END_M_MOV_F_REGI_P
MOV_F_C:									; MOV F,C�� ����
   MOV AX,C
   MOV F,AX
   JMP END_M_MOV_F_REGI_P
MOV_F_D:									; MOV F,D�� ����
   MOV AX,D
   MOV F,AX
   JMP END_M_MOV_F_REGI_P
MOV_F_E:									; MOV F,E�� ����
   MOV AX,E
   MOV F,AX
   JMP END_M_MOV_F_REGI_P
MOV_F_F:									; MOV F,F�� ����
   MOV AX,F
   MOV F,AX
   JMP END_M_MOV_F_REGI_P
MOV_F_X:									; MOV F,X�� ����
   MOV AX,X
   MOV F,AX
   JMP END_M_MOV_F_REGI_P
MOV_F_Y:									; MOV F,Y�� ����
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
;Function : MOV F,IMMEDIATE ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 26,2016
;   Last Modified On Nov 26,2016
;------------------------------------------------
MOV_F_IMME_P PROC                   ; MOV F,IMMEDIATE
   MOV DX,VDECODE[10]					; VDECODE[10]�� ����Ǿ��ִ� IMMEDIATE���� �������� F�� ����
   MOV F,DX
   RET
MOV_F_IMME_P ENDP

;------------------------------------------------
;Procedure Name : MOV_F_REGI_IMME_P
;Function : MOV ��ɾ��� REGISTER-INDIRECT ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 26,2016
;   Last Modified On Nov 26,2016
;------------------------------------------------
MOV_F_REGI_IMME_P PROC                 ; MOV F,REGISTER_IMMEDIATE
   CMP VDECODE[8],1110				   ; �ǿ�����2�� ���� X
   JE MOV_F_R_I_X
   CMP VDECODE[8],1111				   ; �ǿ�����2�� ���� Y
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
;Function : MOV ��ɾ��� DIRECT ����� ����
;PROGRAMED BY ������
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
;Function : MOV X, ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 26,2016
;   Last Modified On Nov 26,2016
;------------------------------------------------
MOV_X_P PROC
   MOV AX, VDECODE[2]
   AND AX,11b
   MOV VDECODE[2],AX
                              ; MOV X,
   CMP VDECODE[2],00b			; VDECODE[2]���� Ȯ���Ͽ� 00�̸� Register ���
   JE MOV_X_REGI
   CMP VDECODE[2],01b			; VDECODE[2]���� Ȯ���Ͽ� 01�̸� Immediate ���
   JE MOV_X_IMME
   CMP VDECODE[2],10b			; VDECODE[2]���� Ȯ���Ͽ� 10�̸� Register-Indirect ���
   JE MOV_X_REGI_IMME
   CMP VDECODE[2],11b			; VDECODE[2]���� Ȯ���Ͽ� 11�̸� Direct ���
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
;Function : MOV X,REGISTER ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 26,2016
;   Last Modified On Nov 26,2016
;------------------------------------------------
MOV_X_REGI_P PROC
   MOV AX,VDECODE[8]                         ; MOV X,REGISTER
   AND AX,1111b
   MOV VDECODE[8],AX

   CMP VDECODE[8],1000b						; �ǿ�����2�� ���� ����Ǿ��ִ� VDECODE[8]�� 1000b�̸� MOV X,A
   JE MOV_X_A
   CMP VDECODE[8],1001b						; �ǿ�����2�� ���� ����Ǿ��ִ� VDECODE[8]�� 1000b�̸� MOV X,B
   JE MOV_X_B
   CMP VDECODE[8],1010b						; �ǿ�����2�� ���� ����Ǿ��ִ� VDECODE[8]�� 1000b�̸� MOV X,C
   JE MOV_X_C
   CMP VDECODE[8],1011b						; �ǿ�����2�� ���� ����Ǿ��ִ� VDECODE[8]�� 1000b�̸� MOV X,D
   JE MOV_X_D
   CMP VDECODE[8],1100b						; �ǿ�����2�� ���� ����Ǿ��ִ� VDECODE[8]�� 1000b�̸� MOV X,E
   JE MOV_X_E
   CMP VDECODE[8],1101b						; �ǿ�����2�� ���� ����Ǿ��ִ� VDECODE[8]�� 1000b�̸� MOV X,F
   JE MOV_X_F
   CMP VDECODE[8],1110b						; �ǿ�����2�� ���� ����Ǿ��ִ� VDECODE[8]�� 1000b�̸� MOV X,X
   JE MOV_X_X
   CMP VDECODE[8],1111b						; �ǿ�����2�� ���� ����Ǿ��ִ� VDECODE[8]�� 1000b�̸� MOV X,Y
   JE MOV_X_Y

   PRINT ERR
   JMP END_M_MOV_X_REGI_P

MOV_X_A:									; MOV X,A�� ����
   MOV AX,A
   MOV X,AX
   JMP END_M_MOV_X_REGI_P
MOV_X_B:									; MOV X,B�� ����
   MOV AX,B
   MOV X,AX
   JMP END_M_MOV_X_REGI_P
MOV_X_C:									; MOV X,C�� ����
   MOV AX,C
   MOV X,AX
   JMP END_M_MOV_X_REGI_P
MOV_X_D:									; MOV X,D�� ����
   MOV AX,D
   MOV X,AX
   JMP END_M_MOV_X_REGI_P
MOV_X_E:									; MOV X,E�� ����
   MOV AX,E
   MOV X,AX
   JMP END_M_MOV_X_REGI_P
MOV_X_F:									; MOV X,F�� ����
   MOV AX,F
   MOV X,AX
   JMP END_M_MOV_X_REGI_P
MOV_X_X:									; MOV X,X�� ����
   MOV AX,X
   MOV X,AX
   JMP END_M_MOV_X_REGI_P
MOV_X_Y:									; MOV X,Y�� ����
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
;Function : MOV X,IMMEDIATE ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 26,2016
;   Last Modified On Nov 26,2016
;------------------------------------------------
MOV_X_IMME_P PROC                   ; MOV X,IMMEDIATE
   MOV DX,VDECODE[10]					; VDECODE[10]�� ����Ǿ��ִ� IMMEDIATE���� �������� X�� ����
   MOV X,DX
   RET
MOV_X_IMME_P ENDP

;------------------------------------------------
;Procedure Name : MOV_X_REGI_IMME_P
;Function : MOV ��ɾ��� REGISTER-INDIRECT ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 26,2016
;   Last Modified On Nov 26,2016
;------------------------------------------------
MOV_X_REGI_IMME_P PROC                 ; MOV X,REGISTER_IMMEDIATE
   CMP VDECODE[8],1110				   ; �ǿ�����2�� ���� X
   JE MOV_X_R_I_X
   CMP VDECODE[8],1111				   ; �ǿ�����2�� ���� Y
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
;Function : MOV ��ɾ��� DIRECT ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 26,2016
;   Last Modified On Nov 26,2016
;------------------------------------------------
MOV_X_DI_P PROC                     ; MOV X,DIRECT
   MOV SI,VDECODE[10]   			; VDECODE[10]���� ����ִ� DIRCET�ּҰ��� ����
   MOV DX,M[SI]
   MOV X,DX
   RET
MOV_X_DI_P ENDP


;------------------------------------------------
;Procedure Name : MOV_Y_P
;Function : MOV Y, ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 26,2016
;   Last Modified On Nov 26,2016
;------------------------------------------------
MOV_Y_P PROC
   MOV AX, VDECODE[2]
   AND AX,11b
   MOV VDECODE[2],AX
                              ; MOV Y,
   CMP VDECODE[2],00b			; VDECODE[2]���� Ȯ���Ͽ� 00�̸� Register ���
   JE MOV_Y_REGI
   CMP VDECODE[2],01b			; VDECODE[2]���� Ȯ���Ͽ� 01�̸� Immediate ���
   JE MOV_Y_IMME
   CMP VDECODE[2],10b			; VDECODE[2]���� Ȯ���Ͽ� 10�̸� Register-Indirect ���
   JE MOV_Y_REGI_IMME
   CMP VDECODE[2],11b			; VDECODE[2]���� Ȯ���Ͽ� 11�̸� Direct ���
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
;Function : MOV Y,REGISTER ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 26,2016
;   Last Modified On Nov 26,2016
;------------------------------------------------
MOV_Y_REGI_P PROC
   MOV AX,VDECODE[8]                         ; MOV Y,REGISTER
   AND AX,1111b
   MOV VDECODE[8],AX

   CMP VDECODE[8],1000b					; �ǿ�����2�� ���� ����Ǿ��ִ� VDECODE[8]�� 1000b�̸� MOV Y,A
   JE MOV_Y_A
   CMP VDECODE[8],1001b					; �ǿ�����2�� ���� ����Ǿ��ִ� VDECODE[8]�� 1000b�̸� MOV Y,B
   JE MOV_Y_B
   CMP VDECODE[8],1010b					; �ǿ�����2�� ���� ����Ǿ��ִ� VDECODE[8]�� 1000b�̸� MOV Y,C
   JE MOV_Y_C
   CMP VDECODE[8],1011b					; �ǿ�����2�� ���� ����Ǿ��ִ� VDECODE[8]�� 1000b�̸� MOV Y,D
   JE MOV_Y_D
   CMP VDECODE[8],1100b					; �ǿ�����2�� ���� ����Ǿ��ִ� VDECODE[8]�� 1000b�̸� MOV Y,E
   JE MOV_Y_E
   CMP VDECODE[8],1101b					; �ǿ�����2�� ���� ����Ǿ��ִ� VDECODE[8]�� 1000b�̸� MOV Y,F
   JE MOV_Y_F
   CMP VDECODE[8],1110b					; �ǿ�����2�� ���� ����Ǿ��ִ� VDECODE[8]�� 1000b�̸� MOV Y,X
   JE MOV_Y_X
   CMP VDECODE[8],1111b					; �ǿ�����2�� ���� ����Ǿ��ִ� VDECODE[8]�� 1000b�̸� MOV Y,Y
   JE MOV_Y_Y

   PRINT ERR
   JMP END_M_MOV_Y_REGI_P

MOV_Y_A:									; MOV Y,A�� ����
   MOV AX,A
   MOV Y,AX
   JMP END_M_MOV_Y_REGI_P
MOV_Y_B:									; MOV Y,A�� ����
   MOV AX,B
   MOV Y,AX
   JMP END_M_MOV_Y_REGI_P
MOV_Y_C:									; MOV Y,A�� ����
   MOV AX,C
   MOV Y,AX
   JMP END_M_MOV_Y_REGI_P
MOV_Y_D:									; MOV Y,A�� ����
   MOV AX,D
   MOV Y,AX
   JMP END_M_MOV_Y_REGI_P
MOV_Y_E:									; MOV Y,A�� ����
   MOV AX,E
   MOV Y,AX
   JMP END_M_MOV_Y_REGI_P
MOV_Y_F:									; MOV Y,A�� ����
   MOV AX,F
   MOV Y,AX
   JMP END_M_MOV_Y_REGI_P
MOV_Y_X:									; MOV Y,A�� ����
   MOV AX,X
   MOV Y,AX
   JMP END_M_MOV_Y_REGI_P
MOV_Y_Y:									; MOV Y,A�� ����
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
;Function : MOV Y,IMMEDIATE ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 26,2016
;   Last Modified On Nov 26,2016
;------------------------------------------------
MOV_Y_IMME_P PROC                   ; MOV Y,IMMEDIATE
   MOV DX,VDECODE[10]					; VDECODE[10]�� ����Ǿ��ִ� IMMEDIATE���� �������� A�� ����
   MOV Y,DX
   RET
MOV_Y_IMME_P ENDP

;------------------------------------------------
;Procedure Name : MOV_Y_REGI_IMME_P
;Function : MOV ��ɾ��� REGISTER-INDIRECT ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 26,2016
;   Last Modified On Nov 26,2016
;------------------------------------------------
MOV_Y_REGI_IMME_P PROC                 ; MOV Y,REGISTER_IMMEDIATE
   CMP VDECODE[8],1110				   ; �ǿ�����2�� ���� X
   JE MOV_Y_R_I_X
   CMP VDECODE[8],1111				   ; �ǿ�����2�� ���� Y
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
;Function : MOV ��ɾ��� DIRECT ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 26,2016
;   Last Modified On Nov 26,2016
;------------------------------------------------
MOV_Y_DI_P PROC                     ; MOV Y,DIRECT
   MOV SI,VDECODE[10]   			; VDECODE[10]���� ����ִ� DIRCET�ּҰ��� ����
   MOV DX,M[SI]
   MOV Y,DX
   RET
MOV_Y_DI_P ENDP


;------------------------------------------------
;Procedure Name : M_ADD
;Function : ADD ��ɾ� ����� ����
;PROGRAMED BY ���¿�
;PROGRAM VERSION
;   Creation Date :Nov 26,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
M_ADD PROC
;ADD ��ɾ� ����
   mov dx, VDECODE[4]
   mov ax, VDECODE[8]
   mov bx, VDECODE[2]
   
   and VDECODE[4], 1111b
   mov VDECODE[4], dx
   
   cmp VDECODE[4], 1000b	;operand1�� A�϶�
   je M_ADD_A
   cmp VDECODE[4], 1001b	;operand1�� B�϶�
   je M_ADD_B1
   cmp VDECODE[4], 1010b	;operand1�� C�϶�
   je M_ADD_C1
   cmp VDECODE[4], 1011b	;operand1�� D�϶�
   je M_ADD_D1
   cmp VDECODE[4], 1100b	;operand1�� E�϶�
   je M_ADD_E1
   cmp VDECODE[4], 1101b	;operand1�� F�϶�
   je M_ADD_F1
   cmp VDECODE[4], 1110b	;operand1�� X�϶�
   je M_ADD_X1
   cmp VDECODE[4], 1111b	;operand1�� Y�϶�
   je M_ADD_Y1
   jmp M_ADD_EXIT	;M_ADD ����
   
M_ADD_A:		;operand1�� A�� �� addressing mode ��
   and VDECODE[2], 11b
   mov VDECODE[2], bx
   
   cmp VDECODE[2], 00b		;Register ���
   je M_ADD_A_REG
   cmp VDECODE[2], 01b		;Immediate ���
   je M_ADD_A_IMME1
   cmp VDECODE[2], 10b		;Indirect ���
   je M_ADD_A_INDIRECT
   cmp VDECODE[2], 11b		;Direct ���
   je M_ADD_A_DIRECT
   jmp M_ADD_EXIT			;M_ADD ����
   
				;M_ADD_B, C, D, E, F, X, Y���� ������ �� 
				;�������� �����ذ��� ���� ���� �Ÿ��� ������ �б�
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
   
M_ADD_A_INDIRECT:			;operand1�� A�̰� INDIRECT���
   cmp VDECODE[8], 1110b	;operand1�� A�̰� operand2�� X�϶�
   je M_ADD_A_INDIRECT_X
   cmp VDECODE[8], 1111b	;operand1�� A�̰� operand2�� Y�϶�
   je M_ADD_A_INDIRECT_Y
M_ADD_A_INDIRECT_X:			;operand1�� A�̰� operand2�� X�϶�
   mov si, X
   mov bx, m[si]
   call M_ADD_A_REG_SOMETHING	;A�� � ���� �����ϴ� ���ν��� ��
   jmp M_ADD_A_EXIT				;M_ADD ����
M_ADD_A_INDIRECT_Y:				;operand1�� A�̰� operand2�� Y�϶�
   mov si, Y
   mov bx, m[si]
   call M_ADD_A_REG_SOMETHING
   jmp M_ADD_A_EXIT				;M_ADD ����
M_ADD_A_DIRECT:					;operand1�� A�̰� direct ����� ��
   mov si, VDECODE[10]
   mov bx, m[si]
   call M_ADD_A_REG_SOMETHING
   jmp M_ADD_A_EXIT				;M_ADD_A ����

				;�������� �����ذ��� ���� ���� �Ÿ��� ������ �б�   
M_ADD_A_IMME1:
   jmp M_ADD_A_IMME   
   
M_ADD_A_REG:			;operand1�� A�̰� operand2�� ���������϶�
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
   jmp M_ADD_A_EXIT				;M_ADD ����
   
;�������� �����ذ��� ���� ���� �Ÿ��� ������ �б� 
M_ADD_B2:
   jmp M_ADD_B
   
M_ADD_A_REG_A:					;ADD A, A
   mov bx, A
   call M_ADD_A_REG_SOMETHING
   jmp M_ADD_A_EXIT				;M_ADD ����
M_ADD_A_REG_B:					;ADD A, B
   mov bx, B
   call M_ADD_A_REG_SOMETHING
   jmp M_ADD_A_EXIT				;M_ADD ����
M_ADD_A_REG_C:					;ADD A, C
   mov bx, C
   call M_ADD_A_REG_SOMETHING
   jmp M_ADD_A_EXIT				;M_ADD ����
M_ADD_A_REG_D:					;ADD A, D
   mov bx, D
   call M_ADD_A_REG_SOMETHING
   jmp M_ADD_A_EXIT				;M_ADD ����
M_ADD_A_REG_E:					;ADD A, E
   mov bx, E
   call M_ADD_A_REG_SOMETHING
   jmp M_ADD_A_EXIT				;M_ADD ����
M_ADD_A_REG_F:					;ADD A, F
   mov bx, F
   call M_ADD_A_REG_SOMETHING
   jmp M_ADD_A_EXIT				;M_ADD ����
M_ADD_A_REG_X:					;ADD A, X
   mov bx, X
   call M_ADD_A_REG_SOMETHING
   jmp M_ADD_A_EXIT				;M_ADD ����
M_ADD_A_REG_Y:					;ADD A, Y
   mov bx, Y
   call M_ADD_A_REG_SOMETHING
   jmp M_ADD_A_EXIT				;M_ADD ����

M_ADD_A_IMME:					;operand1�� A�̰� immediate ����� ��
   mov ax, A
   mov bx, VDECODE[10]
   add ax, bx
   mov A, ax
   
M_ADD_A_EXIT:					;M_ADD�� ����
   jmp M_ADD_EXIT

M_ADD_B:						;operand1�� B�� �� addressing mode ��
   cmp VDECODE[2], 00b;Register ���
   je M_ADD_B_REG
   cmp VDECODE[2], 01b;Immediate ���
   je M_ADD_B_IMME1
   cmp VDECODE[2], 10b;Indirect ���
   je M_ADD_B_INDIRECT
   cmp VDECODE[2], 11b;Direct ���
   je M_ADD_B_DIRECT
   jmp M_ADD_EXIT				;M_ADD�� ����

M_ADD_B_INDIRECT:				;operand1�� B�̰� INDIRECT���
   cmp VDECODE[8], 1110b		;operand1�� B�̰� operand2�� X�϶�
   je M_ADD_B_INDIRECT_X
   cmp VDECODE[8], 1111b		;operand1�� B�̰� operand2�� Y�϶�
   je M_ADD_B_INDIRECT_Y
M_ADD_B_INDIRECT_X:				;operand1�� B�̰� operand2�� X�϶�
   mov si, X
   mov bx, m[si]
   call M_ADD_B_REG_SOMETHING	;B�� � ���� �����ϴ� ���ν��� ��
   jmp M_ADD_B_EXIT				;M_ADD ����
M_ADD_B_INDIRECT_Y:				;operand1�� B�̰� operand2�� Y�϶� 
   mov si, Y
   mov bx, m[si]
   call M_ADD_B_REG_SOMETHING
   jmp M_ADD_B_EXIT				;M_ADD ����
M_ADD_B_DIRECT:					;operand1�� B�̰� direct ����� ��
   mov si, VDECODE[10]
   mov bx, m[si]
   call M_ADD_B_REG_SOMETHING
   jmp M_ADD_B_EXIT				;M_ADD ����
  
				;�������� �����ذ��� ���� ���� �Ÿ��� ������ �б�   
M_ADD_B_IMME1:
   jmp M_ADD_B_IMME
   
M_ADD_B_REG:				;operand1�� B�̰� operand2�� ���������϶�   
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
   jmp M_ADD_B_EXIT			;M_ADD ����
   
				;�������� �����ذ��� ���� ���� �Ÿ��� ������ �б�  
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
   jmp M_ADD_B_EXIT		;M_ADD ����
M_ADD_B_REG_B:			;ADD B, B
   mov bx, B
   call M_ADD_B_REG_SOMETHING
   jmp M_ADD_B_EXIT		;M_ADD ����
M_ADD_B_REG_C:			;ADD B, C
   mov bx, C
   call M_ADD_B_REG_SOMETHING
   jmp M_ADD_B_EXIT		;M_ADD ����
M_ADD_B_REG_D:			;ADD B, D
   mov bx, D
   call M_ADD_B_REG_SOMETHING
   jmp M_ADD_B_EXIT		;M_ADD ����
M_ADD_B_REG_E:			;ADD B, E
   mov bx, E
   call M_ADD_B_REG_SOMETHING
   jmp M_ADD_B_EXIT		;M_ADD ����
M_ADD_B_REG_F:			;ADD B, F
   mov bx, F
   call M_ADD_B_REG_SOMETHING
   jmp M_ADD_B_EXIT		;M_ADD ����
M_ADD_B_REG_X:			;ADD B, X
   mov bx, X
   call M_ADD_B_REG_SOMETHING
   jmp M_ADD_B_EXIT		;M_ADD ����
M_ADD_B_REG_Y:			;ADD B, Y
   mov bx, Y
   call M_ADD_B_REG_SOMETHING
   jmp M_ADD_B_EXIT		;M_ADD ����

M_ADD_B_IMME:			;operand1�� B�̰� immediate ����� ��
   mov ax, B
   mov bx, VDECODE[10]
   add ax, bx
   mov B, ax
   
M_ADD_B_EXIT:			;M_ADD ����
   jmp M_ADD_EXIT

M_ADD_C:		;operand1�� C�� �� addressing mode ��
   cmp VDECODE[2], 00b		;Register ���
   je M_ADD_C_REG
   cmp VDECODE[2], 01b		;Immediate ���
   je M_ADD_C_IMME1
   cmp VDECODE[2], 10b		;Indirect ���
   je M_ADD_C_INDIRECT
   cmp VDECODE[2], 11b		;Direct ���
   je M_ADD_C_DIRECT
   jmp M_ADD_EXIT			;M_ADD ����

M_ADD_C_INDIRECT:			;operand1�� C�̰� INDIRECT���
   cmp VDECODE[8], 1110b	;operand1�� C�̰� operand2�� X�϶�
   je M_ADD_C_INDIRECT_X
   cmp VDECODE[8], 1111b	;operand1�� C�̰� operand2�� Y�϶�
   je M_ADD_C_INDIRECT_Y
M_ADD_C_INDIRECT_X:			;operand1�� C�̰� operand2�� X�϶�
   mov si, X
   mov bx, m[si]
   call M_ADD_C_REG_SOMETHING	;C�� � ���� �����ϴ� ���ν��� ��
   jmp M_ADD_C_EXIT				;M_ADD ����
M_ADD_C_INDIRECT_Y:				;operand1�� C�̰� operand2�� Y�϶�
   mov si, Y
   mov bx, m[si]
   call M_ADD_C_REG_SOMETHING
   jmp M_ADD_C_EXIT				;M_ADD ����
M_ADD_C_DIRECT:					;operand1�� C�̰� direct ����� ��
   mov si, VDECODE[10]
   mov bx, m[si]
   call M_ADD_C_REG_SOMETHING
   jmp M_ADD_C_EXIT				;M_ADD ����
   
					;�������� �����ذ��� ���� ���� �Ÿ��� ������ �б� 
M_ADD_C_IMME1:
   jmp M_ADD_C_IMME
   
M_ADD_C_REG:					;operand2�� ���������϶�   
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
   jmp M_ADD_C_EXIT				;M_ADD ����
   
					;�������� �����ذ��� ���� ���� �Ÿ��� ������ �б�    
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
   jmp M_ADD_C_EXIT				;M_ADD ����
M_ADD_C_REG_B:					;ADD C, B
   mov bx, B
   call M_ADD_C_REG_SOMETHING
   jmp M_ADD_C_EXIT				;M_ADD ����
M_ADD_C_REG_C:					;ADD C, C
   mov bx, C
   call M_ADD_C_REG_SOMETHING
   jmp M_ADD_C_EXIT				;M_ADD ����
M_ADD_C_REG_D:					;ADD C, D
   mov bx, D
   call M_ADD_C_REG_SOMETHING
   jmp M_ADD_C_EXIT				;M_ADD ����
M_ADD_C_REG_E:					;ADD C, E
   mov bx, E
   call M_ADD_C_REG_SOMETHING
   jmp M_ADD_C_EXIT				;M_ADD ����
M_ADD_C_REG_F:					;ADD C, F
   mov bx, F
   call M_ADD_C_REG_SOMETHING
   jmp M_ADD_C_EXIT				;M_ADD ����
M_ADD_C_REG_X:					;ADD C, X
   mov bx, X
   call M_ADD_C_REG_SOMETHING
   jmp M_ADD_C_EXIT				;M_ADD ����
M_ADD_C_REG_Y:					;ADD C, Y
   mov bx, Y
   call M_ADD_C_REG_SOMETHING
   jmp M_ADD_C_EXIT				;M_ADD ����

M_ADD_C_IMME:		;operand1�� C�̰� immediate ����� ��
   mov ax, C
   mov bx, VDECODE[10]
   add ax, bx
   mov C, ax
   
M_ADD_C_EXIT:			;M_ADD ����
   jmp M_ADD_EXIT
M_ADD_D:				;operand1�� D�� �� addressing mode ��
   cmp VDECODE[2], 00b	;Register ���
   je M_ADD_D_REG
   cmp VDECODE[2], 01b	;Immediate ���
   je M_ADD_D_IMME1
   cmp VDECODE[2], 10b	;Indirect ���
   je M_ADD_D_INDIRECT
   cmp VDECODE[2], 11b	;Direct ���
   je M_ADD_D_DIRECT
   jmp M_ADD_EXIT		;M_ADD ����

M_ADD_D_INDIRECT:			;operand1�� D�̰� INDIRECT���
   cmp VDECODE[8], 1110b	;operand1�� D�̰� operand2�� X�϶�
   je M_ADD_D_INDIRECT_X
   cmp VDECODE[8], 1111b	;operand1�� D�̰� operand2�� Y�϶�
   je M_ADD_D_INDIRECT_Y
M_ADD_D_INDIRECT_X:			;operand1�� D�̰� operand2�� X�϶�
   mov si, X
   mov bx, m[si]
   call M_ADD_D_REG_SOMETHING	;D�� � ���� �����ϴ� ���ν��� ��
   jmp M_ADD_D_EXIT			;M_ADD ����
M_ADD_D_INDIRECT_Y:			;operand1�� D�̰� operand2�� Y�϶�
   mov si, Y
   mov bx, m[si]
   call M_ADD_D_REG_SOMETHING
   jmp M_ADD_D_EXIT			;M_ADD ����
M_ADD_D_DIRECT:				;operand1�� D�̰� direct ����� ��
   mov si, VDECODE[10]
   mov bx, m[si]
   call M_ADD_D_REG_SOMETHING
   jmp M_ADD_D_EXIT			;M_ADD ����
   
			;�������� �����ذ��� ���� ���� �Ÿ��� ������ �б�    
M_ADD_D_IMME1:
   jmp M_ADD_D_IMME   
   
M_ADD_D_REG:				;operand1�� D�̰� operand2�� ���������϶�   
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
   jmp M_ADD_D_EXIT		;M_ADD ����
   
			;�������� �����ذ��� ���� ���� �Ÿ��� ������ �б�    
M_ADD_F4:
   jmp M_ADD_F
M_ADD_X4:
   jmp M_ADD_X
M_ADD_Y4:
   jmp M_ADD_Y
   
M_ADD_D_REG_A:					;ADD D, A
   mov bx, A
   call M_ADD_D_REG_SOMETHING
   jmp M_ADD_D_EXIT				;M_ADD ����
M_ADD_D_REG_B:					;ADD D, B
   mov bx, B
   call M_ADD_D_REG_SOMETHING
   jmp M_ADD_D_EXIT				;M_ADD ����
M_ADD_D_REG_C:					;ADD D, C
   mov bx, C
   call M_ADD_D_REG_SOMETHING
   jmp M_ADD_D_EXIT				;M_ADD ����
M_ADD_D_REG_D:					;ADD D, D
   mov bx, D
   call M_ADD_D_REG_SOMETHING
   jmp M_ADD_D_EXIT				;M_ADD ����
M_ADD_D_REG_E:					;ADD D, E
   mov bx, E
   call M_ADD_D_REG_SOMETHING
   jmp M_ADD_D_EXIT				;M_ADD ����
M_ADD_D_REG_F:					;ADD D, F
   mov bx, F
   call M_ADD_D_REG_SOMETHING
   jmp M_ADD_D_EXIT				;M_ADD ����
M_ADD_D_REG_X:					;ADD D, X
   mov bx, X
   call M_ADD_D_REG_SOMETHING
   jmp M_ADD_D_EXIT				;M_ADD ����
M_ADD_D_REG_Y:					;ADD D, Y
   mov bx, Y
   call M_ADD_D_REG_SOMETHING
   jmp M_ADD_D_EXIT				;M_ADD ����

M_ADD_D_IMME:				;operand1�� D�̰� immediate ����� ��
   mov ax, D
   mov bx, VDECODE[10]
   add ax, bx
   mov D, ax
   
M_ADD_D_EXIT:					;M_ADD ����
   jmp M_ADD_EXIT
   
M_ADD_E:				;operand1�� E�� �� addressing mode ��
   cmp VDECODE[2], 00b		;Register ���
   je M_ADD_E_REG
   cmp VDECODE[2], 01b		;Immediate ���
   je M_ADD_E_IMME1
   cmp VDECODE[2], 10b		;Indirect ���
   je M_ADD_E_INDIRECT
   cmp VDECODE[2], 11b		;Direct ���
   je M_ADD_E_DIRECT
   jmp M_ADD_EXIT			;M_ADD ����

M_ADD_E_INDIRECT:			;operand1�� E�̰� INDIRECT���
   cmp VDECODE[8], 1110b	;operand1�� E�̰� operand2�� X�϶�
   je M_ADD_E_INDIRECT_X
   cmp VDECODE[8], 1111b	;operand1�� E�̰� operand2�� Y�϶�
   je M_ADD_E_INDIRECT_Y
M_ADD_E_INDIRECT_X:			;operand1�� E�̰� operand2�� X�϶�
   mov si, X
   mov bx, m[si]
   call M_ADD_E_REG_SOMETHING	;E�� � ���� �����ϴ� ���ν��� ��
   jmp M_ADD_E_EXIT				;M_ADD ����
M_ADD_E_INDIRECT_Y:			;operand1�� E�̰� operand2�� Y�϶�
   mov si, Y
   mov bx, m[si]
   call M_ADD_E_REG_SOMETHING
   jmp M_ADD_E_EXIT				;M_ADD ����
M_ADD_E_DIRECT:
   mov si, VDECODE[10]			;operand1�� E�̰� direct ����� ��
   mov bx, m[si]
   call M_ADD_E_REG_SOMETHING
   jmp M_ADD_E_EXIT				;M_ADD ����
   
			;�������� �����ذ��� ���� ���� �Ÿ��� ������ �б�    
M_ADD_E_IMME1:
   jmp M_ADD_E_IMME   
   
M_ADD_E_REG:		;operand1�� E�̰� operand2�� ���������϶�   
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
   jmp M_ADD_E_EXIT				;M_ADD ����
   
M_ADD_E_REG_A:					;ADD E, A
   mov bx, A
   call M_ADD_E_REG_SOMETHING
   jmp M_ADD_E_EXIT				;M_ADD ����
M_ADD_E_REG_B:					;ADD E, B
   mov bx, B
   call M_ADD_E_REG_SOMETHING
   jmp M_ADD_E_EXIT				;M_ADD ����
M_ADD_E_REG_C:					;ADD E, C
   mov bx, C
   call M_ADD_E_REG_SOMETHING
   jmp M_ADD_E_EXIT				;M_ADD ����
M_ADD_E_REG_D:					;ADD E, D
   mov bx, D
   call M_ADD_E_REG_SOMETHING
   jmp M_ADD_E_EXIT				;M_ADD ����
M_ADD_E_REG_E:					;ADD E, E
   mov bx, E
   call M_ADD_E_REG_SOMETHING
   jmp M_ADD_E_EXIT				;M_ADD ����
M_ADD_E_REG_F:					;ADD E, F
   mov bx, F
   call M_ADD_E_REG_SOMETHING
   jmp M_ADD_E_EXIT				;M_ADD ����
M_ADD_E_REG_X:					;ADD E, X
   mov bx, X
   call M_ADD_E_REG_SOMETHING
   jmp M_ADD_E_EXIT				;M_ADD ����
M_ADD_E_REG_Y:					;ADD E, Y
   mov bx, Y
   call M_ADD_E_REG_SOMETHING
   jmp M_ADD_E_EXIT				;M_ADD ����

M_ADD_E_IMME:			;operand1�� E�̰� immediate ����� ��
   mov ax, E
   mov bx, VDECODE[10]
   add ax, bx
   mov E, ax
   
M_ADD_E_EXIT:			;M_ADD ����
   jmp M_ADD_EXIT
   
M_ADD_F:				;operand1�� F�� �� addressing mode ��
   cmp VDECODE[2], 00b	;Register ���
   je M_ADD_F_REG
   cmp VDECODE[2], 01b	;Immediate ���
   je M_ADD_F_IMME1
   cmp VDECODE[2], 10b	;Indirect ���
   je M_ADD_F_INDIRECT
   cmp VDECODE[2], 11b	;Direct ���
   je M_ADD_F_DIRECT
   jmp M_ADD_EXIT		;M_ADD ����

M_ADD_F_INDIRECT:		;operand1�� F�̰� INDIRECT���
   cmp VDECODE[8], 1110b	;operand1�� F�̰� operand2�� X�϶�
   je M_ADD_F_INDIRECT_X
   cmp VDECODE[8], 1111b	;operand1�� F�̰� operand2�� Y�϶�
   je M_ADD_F_INDIRECT_Y
M_ADD_F_INDIRECT_X:			;operand1�� F�̰� operand2�� X�϶�
   mov si, X
   mov bx, m[si]
   call M_ADD_F_REG_SOMETHING	;F�� � ���� �����ϴ� ���ν��� ��
   jmp M_ADD_F_EXIT				;M_ADD ����
M_ADD_F_INDIRECT_Y:				;operand1�� F�̰� operand2�� Y�϶�
   mov si, Y
   mov bx, m[si]
   call M_ADD_F_REG_SOMETHING
   jmp M_ADD_F_EXIT				;M_ADD ����
M_ADD_F_DIRECT:				;operand1�� F�̰� direct ����� ��
   mov si, VDECODE[10]
   mov bx, m[si]
   call M_ADD_F_REG_SOMETHING
   jmp M_ADD_F_EXIT			;M_ADD ����
   
			;�������� �����ذ��� ���� ���� �Ÿ��� ������ �б�    
M_ADD_F_IMME1:
   jmp M_ADD_F_IMME   
   
M_ADD_F_REG:			;operand1�� F�̰� operand2�� ���������϶�   
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
   jmp M_ADD_F_EXIT			;M_ADD ����
   
M_ADD_F_REG_A:				;ADD F, A
   mov bx, A
   call M_ADD_F_REG_SOMETHING
   jmp M_ADD_F_EXIT			;M_ADD ����
M_ADD_F_REG_B:				;ADD F, B
   mov bx, B
   call M_ADD_F_REG_SOMETHING
   jmp M_ADD_F_EXIT			;M_ADD ����
M_ADD_F_REG_C:				;ADD F, C
   mov bx, C
   call M_ADD_F_REG_SOMETHING
   jmp M_ADD_F_EXIT			;M_ADD ����
M_ADD_F_REG_D:				;ADD F, D
   mov bx, D
   call M_ADD_F_REG_SOMETHING
   jmp M_ADD_F_EXIT			;M_ADD ����
M_ADD_F_REG_E:				;ADD F, E
   mov bx, E
   call M_ADD_F_REG_SOMETHING
   jmp M_ADD_F_EXIT			;M_ADD ����
M_ADD_F_REG_F:				;ADD F, F
   mov bx, F
   call M_ADD_F_REG_SOMETHING
   jmp M_ADD_F_EXIT			;M_ADD ����
M_ADD_F_REG_X:				;ADD F, X
   mov bx, X
   call M_ADD_F_REG_SOMETHING
   jmp M_ADD_F_EXIT			;M_ADD ����
M_ADD_F_REG_Y:				;ADD F, Y
   mov bx, Y
   call M_ADD_F_REG_SOMETHING
   jmp M_ADD_F_EXIT			;M_ADD ����

M_ADD_F_IMME:				;operand1�� F�̰� immediate ����� ��
   mov ax, F
   mov bx, VDECODE[10]
   add ax, bx
   mov F, ax
   
M_ADD_F_EXIT:					;M_ADD ����
   jmp M_ADD_EXIT
   
M_ADD_X:				;operand1�� X�� �� addressing mode ��
   cmp VDECODE[2], 00b	;Register ���
   je M_ADD_X_REG
   cmp VDECODE[2], 01b	;Immediate ���
   je M_ADD_X_IMME1
   cmp VDECODE[2], 10b	;Indirect ���
   je M_ADD_X_INDIRECT
   cmp VDECODE[2], 11b	;Direct ���
   je M_ADD_X_DIRECT
   jmp M_ADD_EXIT		;M_ADD ����

M_ADD_X_INDIRECT:			;operand1�� X�̰� INDIRECT���
   cmp VDECODE[8], 1110b	;operand1�� X�̰� operand2�� X�϶�
   je M_ADD_X_INDIRECT_X
   cmp VDECODE[8], 1111b	;operand1�� X�̰� operand2�� Y�϶�
   je M_ADD_X_INDIRECT_Y
M_ADD_X_INDIRECT_X:			;operand1�� X�̰� operand2�� X�϶�
   mov si, X
   mov bx, m[si]
   call M_ADD_X_REG_SOMETHING	;X�� � ���� �����ϴ� ���ν��� ��
   jmp M_ADD_X_EXIT				;M_ADD ����
M_ADD_X_INDIRECT_Y:				;operand1�� X�̰� operand2�� Y�϶�
   mov si, Y
   mov bx, m[si]
   call M_ADD_X_REG_SOMETHING
   jmp M_ADD_X_EXIT				;M_ADD ����
M_ADD_X_DIRECT:					;operand1�� X�̰� direct ����� ��
   mov si, VDECODE[10]
   mov bx, m[si]
   call M_ADD_X_REG_SOMETHING
   jmp M_ADD_X_EXIT				;M_ADD ����
   
				;�������� �����ذ��� ���� ���� �Ÿ��� ������ �б�    
M_ADD_X_IMME1:   
   jmp M_ADD_X_IMME   
   
M_ADD_X_REG:			;operand1�� X�̰� operand2�� ���������϶�   
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
   jmp M_ADD_X_EXIT			;M_ADD ����
   
M_ADD_X_REG_A:				;ADD X, A
   mov bx, A
   call M_ADD_X_REG_SOMETHING
   jmp M_ADD_X_EXIT			;M_ADD ����
M_ADD_X_REG_B:				;ADD X, B
   mov bx, B
   call M_ADD_X_REG_SOMETHING
   jmp M_ADD_X_EXIT			;M_ADD ����
M_ADD_X_REG_C:				;ADD X, C
   mov bx, C
   call M_ADD_X_REG_SOMETHING
   jmp M_ADD_X_EXIT			;M_ADD ����
M_ADD_X_REG_D:				;ADD X, D
   mov bx, D
   call M_ADD_X_REG_SOMETHING
   jmp M_ADD_X_EXIT			;M_ADD ����
M_ADD_X_REG_E:				;ADD X, E
   mov bx, E
   call M_ADD_X_REG_SOMETHING
   jmp M_ADD_X_EXIT			;M_ADD ����
M_ADD_X_REG_F:				;ADD X, F
   mov bx, F
   call M_ADD_X_REG_SOMETHING
   jmp M_ADD_X_EXIT			;M_ADD ����
M_ADD_X_REG_X:				;ADD X, X
   mov bx, X
   call M_ADD_X_REG_SOMETHING
   jmp M_ADD_X_EXIT			;M_ADD ����
M_ADD_X_REG_Y:				;ADD X, Y
   mov bx, Y
   call M_ADD_X_REG_SOMETHING
   jmp M_ADD_X_EXIT			;M_ADD ����

M_ADD_X_IMME:			;operand1�� X�̰� operand2�� immediate�϶�
   mov ax, X
   mov bx, VDECODE[10]
   add ax, bx
   mov X, ax
   
M_ADD_X_EXIT:				;M_ADD ����
   jmp M_ADD_EXIT
   
M_ADD_Y:				;operand1�� Y�� �� addressing mode ��
   cmp VDECODE[2], 00b	;Register ���
   je M_ADD_Y_REG
   cmp VDECODE[2], 01b	;Immediate ���
   je M_ADD_Y_IMME1
   cmp VDECODE[2], 10b	;Indirect ���
   je M_ADD_Y_INDIRECT
   cmp VDECODE[2], 11b	;Direct ���
   je M_ADD_Y_DIRECT
   jmp M_ADD_EXIT		;M_ADD ����

M_ADD_Y_INDIRECT:			;operand1�� Y�̰� INDIRECT���
   cmp VDECODE[8], 1110b	;operand1�� Y�̰� operand2�� X�϶�
   je M_ADD_Y_INDIRECT_X
   cmp VDECODE[8], 1111b	;operand1�� Y�̰� operand2�� Y�϶�
   je M_ADD_Y_INDIRECT_Y
M_ADD_Y_INDIRECT_X:			;operand1�� Y�̰� operand2�� X�϶�
   mov si, X
   mov bx, m[si]
   call M_ADD_Y_REG_SOMETHING	;Y�� � ���� �����ϴ� ���ν��� ��
   jmp M_ADD_Y_EXIT				;M_ADD ����
M_ADD_Y_INDIRECT_Y:				;operand1�� Y�̰� operand2�� Y�϶�
   mov si, Y
   mov bx, m[si]
   call M_ADD_Y_REG_SOMETHING
   jmp M_ADD_Y_EXIT				;M_ADD ����
M_ADD_Y_DIRECT:					;operand1�� Y�̰� direct ����� ��
   mov si, VDECODE[10]
   mov bx, m[si]
   call M_ADD_Y_REG_SOMETHING
   jmp M_ADD_Y_EXIT				;M_ADD ����
   
			;�������� �����ذ��� ���� ���� �Ÿ��� ������ �б� 
M_ADD_Y_IMME1:
   jmp M_ADD_Y_IMME
   
M_ADD_Y_REG:				;operand1�� Y�̰� operand2�� ���������϶�   
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
   jmp M_ADD_Y_EXIT			;M_ADD ����
   
M_ADD_Y_REG_A:			;ADD Y, A
   mov bx, A
   call M_ADD_Y_REG_SOMETHING
   jmp M_ADD_Y_EXIT		;M_ADD ����
M_ADD_Y_REG_B:			;ADD Y, B
   mov bx, B
   call M_ADD_Y_REG_SOMETHING
   jmp M_ADD_Y_EXIT		;M_ADD ����
M_ADD_Y_REG_C:			;ADD Y, C
   mov bx, C
   call M_ADD_Y_REG_SOMETHING
   jmp M_ADD_Y_EXIT		;M_ADD ����
M_ADD_Y_REG_D:			;ADD Y, D
   mov bx, D
   call M_ADD_Y_REG_SOMETHING
   jmp M_ADD_Y_EXIT		;M_ADD ����
M_ADD_Y_REG_E:			;ADD Y, E
   mov bx, E
   call M_ADD_Y_REG_SOMETHING
   jmp M_ADD_Y_EXIT		;M_ADD ����
M_ADD_Y_REG_F:			;ADD Y, F
   mov bx, F
   call M_ADD_Y_REG_SOMETHING
   jmp M_ADD_Y_EXIT		;M_ADD ����
M_ADD_Y_REG_X:			;ADD Y, X
   mov bx, X
   call M_ADD_Y_REG_SOMETHING
   jmp M_ADD_Y_EXIT		;M_ADD ����
M_ADD_Y_REG_Y:			;ADD Y, Y
   mov bx, Y
   call M_ADD_Y_REG_SOMETHING
   jmp M_ADD_Y_EXIT		;M_ADD ����

M_ADD_Y_IMME:			;operand1�� Y�̰� immediate ����� ��
   mov ax, Y
   mov bx, VDECODE[10]
   add ax, bx
   mov Y, ax
   
M_ADD_Y_EXIT:				;M_ADD ����
   jmp M_ADD_EXIT
   
M_ADD_EXIT:					;M_ADD ����
   RET
M_ADD ENDP

M_ADD_A_REG_SOMETHING PROC		;A�� � ���� ADD�����ϴ� ���ν���
   mov ax, A
   add ax, bx
   mov A, ax
   RET
M_ADD_A_REG_SOMETHING ENDP

M_ADD_B_REG_SOMETHING PROC		;B�� � ���� ADD�����ϴ� ���ν���
   mov ax, B
   add ax, bx
   mov B, ax
   RET
M_ADD_B_REG_SOMETHING ENDP

M_ADD_C_REG_SOMETHING PROC		;C�� � ���� ADD�����ϴ� ���ν���
   mov ax, C
   add ax, bx
   mov C, ax
   RET
M_ADD_C_REG_SOMETHING ENDP

M_ADD_D_REG_SOMETHING PROC		;D�� � ���� ADD�����ϴ� ���ν���
   mov ax, D
   add ax, bx
   mov D, ax
   RET
M_ADD_D_REG_SOMETHING ENDP

M_ADD_E_REG_SOMETHING PROC		;E�� � ���� ADD�����ϴ� ���ν���
   mov ax, E
   add ax, bx
   mov E, ax
   RET
M_ADD_E_REG_SOMETHING ENDP


M_ADD_F_REG_SOMETHING PROC		;F�� � ���� ADD�����ϴ� ���ν���
   mov ax, F
   add ax, bx
   mov F, ax
   RET
M_ADD_F_REG_SOMETHING ENDP

M_ADD_X_REG_SOMETHING PROC		;X�� � ���� ADD�����ϴ� ���ν���
   mov ax, X
   add ax, bx
   mov X, ax
   RET
M_ADD_X_REG_SOMETHING ENDP

M_ADD_Y_REG_SOMETHING PROC		;Y�� � ���� ADD�����ϴ� ���ν���
   mov ax, Y
   add ax, bx
   mov Y, ax
   RET
M_ADD_Y_REG_SOMETHING ENDP

;------------------------------------------------
;Procedure Name : COMPARE_A
;Function : A REGISTER�� CMP ��ɾ�, REGISTER������� ����
;PROGRAMED BY �Ͽ���
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
COMPARE_A PROC			 ; REGISTER����϶� A�� ��
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
;Function : B REGISTER�� CMP ��ɾ�, REGISTER������� ����
;PROGRAMED BY �Ͽ���
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
COMPARE_B PROC      ; REGISTER����϶� B�� ��
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
;Function : C REGISTER�� CMP ��ɾ�, REGISTER������� ����
;PROGRAMED BY �Ͽ���
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
COMPARE_C PROC      ; REGISTER����϶� C�� ��
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
;Function : D REGISTER�� CMP ��ɾ�, REGISTER������� ����
;PROGRAMED BY �Ͽ���
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
COMPARE_D PROC      ; REGISTER����϶� D�� ��
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
;Function : E REGISTER�� CMP ��ɾ�, REGISTER������� ����
;PROGRAMED BY �Ͽ���
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
COMPARE_E PROC      ; REGISTER����϶� E�� ��
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
;Function : F REGISTER�� CMP ��ɾ�, REGISTER������� ����
;PROGRAMED BY �Ͽ���
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
COMPARE_F PROC      ; REGISTER����϶� F�� ��
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
;Function : X REGISTER�� CMP ��ɾ�, REGISTER������� ����
;PROGRAMED BY �Ͽ���
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
COMPARE_X PROC      ; REGISTER����϶� X�� ��
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
;Function : Y REGISTER�� CMP ��ɾ�, REGISTER������� ����
;PROGRAMED BY �Ͽ���
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
COMPARE_Y PROC      ; REGISTER����϶� Y�� ��
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
;Function : A REGISTER�� CMP ��ɾ�, IMMEDIATE������� ����
;PROGRAMED BY �Ͽ���
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
IMMEDIATE_A PROC   ; IMMEDIATE��� �϶� A�� ��
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
;Function : B REGISTER�� CMP ��ɾ�, IMMEDIATE������� ����
;PROGRAMED BY �Ͽ���
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
IMMEDIATE_B PROC   ; IMMEDIATE��� �϶� B�� ��
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
;Function : C REGISTER�� CMP ��ɾ�, IMMEDIATE������� ����
;PROGRAMED BY �Ͽ���
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
IMMEDIATE_C PROC   ; IMMEDIATE��� �϶� C�� ��
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
;Function : D REGISTER�� CMP ��ɾ�, IMMEDIATE������� ����
;PROGRAMED BY �Ͽ���
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
IMMEDIATE_D PROC   ; IMMEDIATE��� �϶� D�� ��
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
;Function : E REGISTER�� CMP ��ɾ�, IMMEDIATE������� ����
;PROGRAMED BY �Ͽ���
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
IMMEDIATE_E PROC   ; IMMEDIATE��� �϶� E�� ��
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
;Function : F REGISTER�� CMP ��ɾ�, IMMEDIATE������� ����
;PROGRAMED BY �Ͽ���
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
IMMEDIATE_F PROC   ; IMMEDIATE��� �϶� F�� ��
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
;Function : X REGISTER�� CMP ��ɾ�, IMMEDIATE������� ����
;PROGRAMED BY �Ͽ���
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
IMMEDIATE_X PROC   ; IMMEDIATE��� �϶� X�� ��
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
;Function : Y REGISTER�� CMP ��ɾ�, IMMEDIATE������� ����
;PROGRAMED BY �Ͽ���
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
IMMEDIATE_Y PROC   ; IMMEDIATE��� �϶� Y�� ��
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
;Function : A REGISTER�� CMP ��ɾ�, REGSTER INDIRECT������� ����
;PROGRAMED BY �Ͽ���
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
REG_INDIR_A PROC		; REGSTER INDIRECT��� �϶� A�� ��
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
;Function : B REGISTER�� CMP ��ɾ�, REGSTER INDIRECT������� ����
;PROGRAMED BY �Ͽ���
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
REG_INDIR_B PROC		; REGSTER INDIRECT��� �϶� B�� ��
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
;Function : C REGISTER�� CMP ��ɾ�, REGSTER INDIRECT������� ����
;PROGRAMED BY �Ͽ���
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
REG_INDIR_C PROC			; REGSTER INDIRECT��� �϶� C�� ��
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
;Function : D REGISTER�� CMP ��ɾ�, REGSTER INDIRECT������� ����
;PROGRAMED BY �Ͽ���
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
REG_INDIR_D PROC		; REGSTER INDIRECT��� �϶� D�� ��
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
;Function : E REGISTER�� CMP ��ɾ�, REGSTER INDIRECT������� ����
;PROGRAMED BY �Ͽ���
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
REG_INDIR_E PROC			; REGSTER INDIRECT��� �϶� E�� ��
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
;Function : F REGISTER�� CMP ��ɾ�, REGSTER INDIRECT������� ����
;PROGRAMED BY �Ͽ���
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
REG_INDIR_F PROC			; REGSTER INDIRECT��� �϶� F�� ��
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
;Function : X REGISTER�� CMP ��ɾ�, REGSTER INDIRECT������� ����
;PROGRAMED BY �Ͽ���
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
REG_INDIR_X PROC			; REGSTER INDIRECT��� �϶� X�� ��
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
;Function : Y REGISTER�� CMP ��ɾ�, REGSTER INDIRECT������� ����
;PROGRAMED BY �Ͽ���
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
REG_INDIR_Y PROC			; REGSTER INDIRECT��� �϶� Y�� ��
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
;Function : A REGISTER�� CMP ��ɾ�, DIRECT������� ����
;PROGRAMED BY �Ͽ���
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
DIR_A PROC				; DIRECT��� �϶� A�� ��
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
;Function : B REGISTER�� CMP ��ɾ�, DIRECT������� ����
;PROGRAMED BY �Ͽ���
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
DIR_B PROC			; DIRECT��� �϶� B�� ��
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
;Function : C REGISTER�� CMP ��ɾ�, DIRECT������� ����
;PROGRAMED BY �Ͽ���
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
DIR_C PROC				; DIRECT��� �϶� C�� ��
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
;Function : D REGISTER�� CMP ��ɾ�, DIRECT������� ����
;PROGRAMED BY �Ͽ���
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
DIR_D PROC				; DIRECT��� �϶� D�� ��
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
;Function : E REGISTER�� CMP ��ɾ�, DIRECT������� ����
;PROGRAMED BY �Ͽ���
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
DIR_E PROC				; DIRECT��� �϶� E�� ��
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
;Function : F REGISTER�� CMP ��ɾ�, DIRECT������� ����
;PROGRAMED BY �Ͽ���
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
DIR_F PROC				; DIRECT��� �϶� F�� ��
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
;Function : X REGISTER�� CMP ��ɾ�, DIRECT������� ����
;PROGRAMED BY �Ͽ���
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
DIR_X PROC				; DIRECT��� �϶� X�� ��
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
;Function : Y REGISTER�� CMP ��ɾ�, DIRECT������� ����
;PROGRAMED BY �Ͽ���
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
DIR_Y PROC				; DIRECT��� �϶� Y�� ��
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
;Function : CMP ��ɾ� ����� ����
;PROGRAMED BY �Ͽ���
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
M_CMP PROC				 ; CMP ���ν���
   MOV DX, VDECODE[4]
   MOV AX, VDECODE[8]
   MOV BX, VDECODE[10]
   AND VDECODE[2],11b
   
   CMP VDECODE[2], 00b	 ;REGISTER ���
   JE @REGISTER
   CMP VDECODE[2], 01b   ;IMMEDIATE ���
   JE @IMMEDIATE_1
   CMP VDECODE[2], 10b   ;REGISTER INDIRECT ���
   JE @REG_INDIRECT_1
   CMP VDECODE[2], 11b   ;DIRECT ���
   JE @DIRECT_1
   JMP @END
   
@REGISTER:
   MOV VDECODE[4], DX
   AND VDECODE[4], 1111b
   
   CMP VDECODE[4], 1000b	;��������A
   JE @REGISTER_COMPARE_A
   CMP VDECODE[4], 1001b	;��������B
   JE @REGISTER_COMPARE_B
   CMP VDECODE[4], 1010b	;��������C
   JE @REGISTER_COMPARE_C
   CMP VDECODE[4], 1011b	;��������D
   JE @REGISTER_COMPARE_D
   CMP VDECODE[4], 1100b	;��������E
   JE @REGISTER_COMPARE_E
   CMP VDECODE[4], 1101b	;��������F
   JE @REGISTER_COMPARE_F
   CMP VDECODE[4], 1110b	;��������X
   JE @REGISTER_COMPARE_X
   CMP VDECODE[4], 1111b	;��������Y
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
   
@IMMEDIATE:					;IMMEDIATE �� ��
   MOV VDECODE[4], DX
   AND VDECODE[4], 1111b
   
   CMP VDECODE[4], 1000b	;��������A
   JE @IMMEDIATE_COMPARE_A
   CMP VDECODE[4], 1001b	;��������B
   JE @IMMEDIATE_COMPARE_B
   CMP VDECODE[4], 1010b	;��������C
   JE @IMMEDIATE_COMPARE_C
   CMP VDECODE[4], 1011b	;��������D
   JE @IMMEDIATE_COMPARE_D
   CMP VDECODE[4], 1100b	;��������E
   JE @IMMEDIATE_COMPARE_E
   CMP VDECODE[4], 1101b	;��������F
   JE @IMMEDIATE_COMPARE_F
   CMP VDECODE[4], 1110b	;��������X
   JE @IMMEDIATE_COMPARE_X
   CMP VDECODE[4], 1111b	;��������Y
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

@REG_INDIRECT:				;INDIRECT �� ��
   MOV VDECODE[8], AX
   AND VDECODE[8], 1111b
   MOV VDECODE[4], DX
   AND VDECODE[4], 1111b
   
   CMP VDECODE[4], 1000b	;��������A
   JE @REG_COMPARE_A
   CMP VDECODE[4], 1001b	;��������B
   JE @REG_COMPARE_B
   CMP VDECODE[4], 1010b	;��������C
   JE @REG_COMPARE_C
   CMP VDECODE[4], 1011b	;��������D
   JE @REG_COMPARE_D
   CMP VDECODE[4], 1100b	;��������E
   JE @REG_COMPARE_E
   CMP VDECODE[4], 1101b	;��������F
   JE @REG_COMPARE_F
   CMP VDECODE[4], 1110b	;��������X
   JE @REG_COMPARE_X
   CMP VDECODE[4], 1111b	;��������Y
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

@DIRECT:					;DIRECT �� ��
   MOV VDECODE[10], BX
   MOV VDECODE[4], DX
   AND VDECODE[4], 1111b
   
   CMP VDECODE[4], 1000b	;��������A
   JE @DIR_COMPARE_A
   CMP VDECODE[4], 1001b	;��������B
   JE @DIR_COMPARE_B
   CMP VDECODE[4], 1010b	;��������C
   JE @DIR_COMPARE_C
   CMP VDECODE[4], 1011b	;��������D
   JE @DIR_COMPARE_D
   CMP VDECODE[4], 1100b	;��������E
   JE @DIR_COMPARE_E
   CMP VDECODE[4], 1101b	;��������F
   JE @DIR_COMPARE_F
   CMP VDECODE[4], 1110b	;��������X
   JE @DIR_COMPARE_X
   CMP VDECODE[4], 1111b	;��������Y
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
;Function : OR ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27 ,2016
;------------------------------------------------
M_OR PROC
	CMP VDECODE[4],1000b	; OPERAND1�� A�� ��
	JE M_OR_A
	CMP VDECODE[4],1001b	; OPERAND1�� B�� ��
	JE M_OR_B
	CMP VDECODE[4],1010b	; OPERAND1�� C�� ��
	JE M_OR_C				
	CMP VDECODE[4],1011b	; OPERAND1�� D�� ��
	JE M_OR_D
	CMP VDECODE[4],1100b	; OPERAND1�� E�� ��
	JE M_OR_E
	CMP VDECODE[4],1101b	; OPERAND1�� F�� ��
	JE M_OR_F
	CMP VDECODE[4],1110b	; OPERAND1�� X�� ��
	JE M_OR_X
	CMP VDECODE[4],1111b	; OPERAND1�� Y�� ��
	JE M_OR_Y

	PRINT ERR
	JMP END_M_OR

M_OR_A:
	CALL OR_A_P				; OR_A_P�� ȣ���Ѵ�.
	JMP END_M_OR
M_OR_B:
	CALL OR_B_P				; OR_B_P�� ȣ���Ѵ�.
	JMP END_M_OR
M_OR_C:
	CALL OR_C_P				; OR_C_P�� ȣ���Ѵ�.
	JMP END_M_OR
M_OR_D:
	CALL OR_D_P				; OR_D_P�� ȣ���Ѵ�.
	JMP END_M_OR
M_OR_E:
	CALL OR_E_P				; OR_E_P�� ȣ���Ѵ�.
	JMP END_M_OR
M_OR_F:
	CALL OR_F_P				; OR_F_P�� ȣ���Ѵ�.
	JMP END_M_OR
M_OR_X:
	CALL OR_X_P				; OR_X_P�� ȣ���Ѵ�.
	JMP END_M_OR
M_OR_Y:
	CALL OR_Y_P				; OR_Y_P�� ȣ���Ѵ�.
	JMP END_M_OR

END_M_OR:
	RET
M_OR ENDP

;------------------------------------------------
;Procedure Name : OR_A_P
;Function : OR A, �� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27 ,2016
;------------------------------------------------
OR_A_P PROC
   MOV AX, VDECODE[2]
   AND AX,11b
   MOV VDECODE[2],AX
                              ; OR A,
   CMP VDECODE[2],00b			; REGISTER ���
   JE OR_A_REGI
   CMP VDECODE[2],01b			; IMMEDIATE ���
   JE OR_A_IMME
   CMP VDECODE[2],10b			; REGISTER-INDIRECT ���
   JE OR_A_REGI_IMME
   CMP VDECODE[2],11b			; DIRECT ���
   JE OR_A_DI

   PRINT ERR
   JMP END_M_OR_A_P

OR_A_REGI:
   CALL OR_A_REGI_P				; OR_A_REGI_P ȣ��	
   JMP END_M_OR_A_P
OR_A_IMME:
   CALL OR_A_IMME_P				; OR_A_IMME_P ȣ��	
   JMP END_M_OR_A_P
OR_A_REGI_IMME:
   CALL OR_A_REGI_IMME_P				; OR_A_REGI_IMME_P ȣ��	
   JMP END_M_OR_A_P
OR_A_DI:
   CALL OR_A_DI_P				; OR_A_DI_P ȣ��	
   JMP END_M_OR_A_P

END_M_OR_A_P:
   RET
OR_A_P ENDP

;------------------------------------------------
;Procedure Name : OR_A_REGI_P
;Function : OR A, REGISTER �� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27 ,2016
;------------------------------------------------
OR_A_REGI_P PROC                         ; OR A,REGISTER

   MOV AX,VDECODE[8]
   AND AX,1111b
   MOV VDECODE[8],AX

   CMP VDECODE[8],1000b						; OPERAND2�� A
   JE OR_A_A
   CMP VDECODE[8],1001b						; OPERAND2�� B
   JE OR_A_B
   CMP VDECODE[8],1010b						; OPERAND2�� C
   JE OR_A_C
   CMP VDECODE[8],1011b						; OPERAND2�� D
   JE OR_A_D
   CMP VDECODE[8],1100b						; OPERAND2�� E
   JE OR_A_E
   CMP VDECODE[8],1101b						; OPERAND2�� F
   JE OR_A_F
   CMP VDECODE[8],1110b						; OPERAND2�� X
   JE OR_A_X
   CMP VDECODE[8],1111b						; OPERAND2�� Y
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
;Function : OR A, IMMEDIATE ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27 ,2016
;------------------------------------------------
OR_A_IMME_P PROC                   ; OR A,IMMEDIATE
   MOV DX,VDECODE[10]				; A�� VDECODE[10]�� ����Ǿ��ִ� IMMEDIATE ���� OR
   OR A,DX
   RET
OR_A_IMME_P ENDP

;------------------------------------------------
;Procedure Name : OR_A_REGI_IMME_P
;Function : OR A, REGISTER-INDIRECT ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27 ,2016
;------------------------------------------------
OR_A_REGI_IMME_P PROC                 ; OR A,REGISTER_IMMEDIATE
   CMP VDECODE[8],1110					; OPERAND2 ���� X
   JE OR_A_R_I_X
   CMP VDECODE[8],1111					; OPERAND2 ���� Y
   JE OR_A_R_I_Y
   
OR_A_R_I_X:
   MOV SI,X								; X�� ���� SI�� ����
   MOV DX,M[SI]							; DX�� M[SI]�� ����
   OR A,DX								; A�� DX�� OR
   JMP END_M_OR_A_REGI_IMME_P
OR_A_R_I_Y:
   MOV SI,Y								; Y�� ���� SI�� ����
   MOV DX,M[SI]							; DX�� M[SI]�� ����
   OR A,DX								; A�� DX�� OR

END_M_OR_A_REGI_IMME_P:
   RET
OR_A_REGI_IMME_P ENDP

;------------------------------------------------
;Procedure Name : OR_A_DI_P
;Function : OR A, DIRECT ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27 ,2016
;------------------------------------------------
OR_A_DI_P PROC                     ; OR A,DIRECT
   MOV SI,VDECODE[10]				; SI�� VDECODE[10]�� ����Ǿ��ִ� �ּҰ��� ����
   MOV DX,M[SI]						; DX�� M[SI]�� ����
   OR A,DX							; A�� DX�� OR
   RET
OR_A_DI_P ENDP

;------------------------------------------------
;Procedure Name : OR_B_P
;Function : OR B, �� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27 ,2016
;------------------------------------------------
OR_B_P PROC
   MOV AX, VDECODE[2]
   AND AX,11b
   MOV VDECODE[2],AX
                              ; OR B,
   CMP VDECODE[2],00b			; REGISTER ���
   JE OR_B_REGI
   CMP VDECODE[2],01b			; IMMEDIATE ���
   JE OR_B_IMME
   CMP VDECODE[2],10b			; REGISTER-INDIRECT ���
   JE OR_B_REGI_IMME
   CMP VDECODE[2],11b			; DIRECT ���
   JE OR_B_DI

   PRINT ERR
   JMP END_M_OR_B_P

OR_B_REGI:
   CALL OR_B_REGI_P				; OR_B_REGI_P ȣ��	
   JMP END_M_OR_B_P
OR_B_IMME:
   CALL OR_B_IMME_P				; OR_B_IMME_P ȣ��	
   JMP END_M_OR_B_P
OR_B_REGI_IMME:
   CALL OR_B_REGI_IMME_P		; OR_B_REGI_IMME_P ȣ��
   JMP END_M_OR_B_P
OR_B_DI:
   CALL OR_B_DI_P				; OR_B_DI_P ȣ��
   JMP END_M_OR_B_P

END_M_OR_B_P:
   RET
OR_B_P ENDP

;------------------------------------------------
;Procedure Name : OR_B_REGI_P
;Function : OR B, REGISTER �� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27 ,2016
;------------------------------------------------
OR_B_REGI_P PROC                         ; OR B,REGISTER

   MOV AX,VDECODE[8]
   AND AX,1111b
   MOV VDECODE[8],AX

   CMP VDECODE[8],1000b						; OPERAND2�� A
   JE OR_B_A
   CMP VDECODE[8],1001b						; OPERAND2�� B
   JE OR_B_B
   CMP VDECODE[8],1010b						; OPERAND2�� C
   JE OR_B_C
   CMP VDECODE[8],1011b						; OPERAND2�� D
   JE OR_B_D
   CMP VDECODE[8],1100b						; OPERAND2�� E
   JE OR_B_E
   CMP VDECODE[8],1101b						; OPERAND2�� F
   JE OR_B_F
   CMP VDECODE[8],1110b						; OPERAND2�� X
   JE OR_B_X
   CMP VDECODE[8],1111b						; OPERAND2�� Y
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
;Function : OR B, IMMEDIATE ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27 ,2016
;------------------------------------------------
OR_B_IMME_P PROC                   ; OR B,IMMEDIATE
   MOV DX,VDECODE[10]				; B�� VDECODE[10]�� ����Ǿ��ִ� IMMEDIATE ���� OR
   OR B,DX
   RET
OR_B_IMME_P ENDP

;------------------------------------------------
;Procedure Name : OR_B_REGI_IMME_P
;Function : OR B, REGISTER-INDIRECT ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27 ,2016
;------------------------------------------------
OR_B_REGI_IMME_P PROC                 ; OR B,REGISTER_IMMEDIATE
   CMP VDECODE[8],1110					; OPERAND2 ���� X
   JE OR_B_R_I_X
   CMP VDECODE[8],1111					; OPERAND2 ���� Y
   JE OR_B_R_I_Y
   
OR_B_R_I_X:
   MOV SI,X								; X�� ���� SI�� ����
   MOV DX,M[SI]							; DX�� M[SI]�� ����
   OR B,DX								; B�� DX�� OR
   JMP END_M_OR_B_REGI_IMME_P
OR_B_R_I_Y:
   MOV SI,Y								; Y�� ���� SI�� ����
   MOV DX,M[SI]							; DX�� M[SI]�� ����
   OR B,DX								; B�� DX�� OR

END_M_OR_B_REGI_IMME_P:
   RET
OR_B_REGI_IMME_P ENDP

;------------------------------------------------
;Procedure Name : OR_B_DI_P
;Function : OR A, DIRECT ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27 ,2016
;------------------------------------------------
OR_B_DI_P PROC                     ; OR B,DIRECT
   MOV SI,VDECODE[10]  				; SI�� VDECODE[10]�� ����Ǿ��ִ� �ּҰ��� ���� 
   MOV DX,M[SI]						; DX�� M[SI]�� ����
   OR B,DX							; B�� DX�� OR
   RET
OR_B_DI_P ENDP

;------------------------------------------------
;Procedure Name : OR_C_P
;Function : OR C, �� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27 ,2016
;------------------------------------------------
OR_C_P PROC
   MOV AX, VDECODE[2]
   AND AX,11b
   MOV VDECODE[2],AX
                              ; OR C,
   CMP VDECODE[2],00b			; REGISTER ���
   JE OR_C_REGI
   CMP VDECODE[2],01b			; IMMEDIATE ���
   JE OR_C_IMME
   CMP VDECODE[2],10b			; REGISTER-INDIRECT ���
   JE OR_C_REGI_IMME
   CMP VDECODE[2],11b			; DIRECT ���
   JE OR_C_DI

   PRINT ERR
   JMP END_M_OR_C_P

OR_C_REGI:
   CALL OR_C_REGI_P				; OR_C_REGI_P ȣ��
   JMP END_M_OR_C_P
OR_C_IMME:
   CALL OR_C_IMME_P				; OR_C_IMME_P ȣ��
   JMP END_M_OR_C_P
OR_C_REGI_IMME:
   CALL OR_C_REGI_IMME_P		; OR_C_REGI_IMME_P ȣ��
   JMP END_M_OR_C_P
OR_C_DI:
   CALL OR_C_DI_P				; OR_C_DI_P ȣ��
   JMP END_M_OR_C_P

END_M_OR_C_P:
   RET
OR_C_P ENDP
;------------------------------------------------
;Procedure Name : OR_C_REGI_P
;Function : OR C, REGISTER �� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27 ,2016
;------------------------------------------------
OR_C_REGI_P PROC                         ; OR C,REGISTER

   MOV AX,VDECODE[8]
   AND AX,1111b
   MOV VDECODE[8],AX

   CMP VDECODE[8],1000b						; OPERAND2�� A
   JE OR_C_A
   CMP VDECODE[8],1001b						; OPERAND2�� B
   JE OR_C_B
   CMP VDECODE[8],1010b						; OPERAND2�� C
   JE OR_C_C
   CMP VDECODE[8],1011b						; OPERAND2�� D
   JE OR_C_D
   CMP VDECODE[8],1100b						; OPERAND2�� E
   JE OR_C_E
   CMP VDECODE[8],1101b						; OPERAND2�� F
   JE OR_C_F
   CMP VDECODE[8],1110b						; OPERAND2�� X
   JE OR_C_X
   CMP VDECODE[8],1111b						; OPERAND2�� Y
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
;Function : OR C, IMMEDIATE ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27 ,2016
;------------------------------------------------
OR_C_IMME_P PROC                   ; OR C,IMMEDIATE
   MOV DX,VDECODE[10]				; C�� VDECODE[10]�� ����Ǿ��ִ� IMMEDIATE ���� OR
   OR C,DX
   RET
OR_C_IMME_P ENDP

;------------------------------------------------
;Procedure Name : OR_C_REGI_IMME_P
;Function : OR C, REGISTER-INDIRECT ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27 ,2016
;------------------------------------------------
OR_C_REGI_IMME_P PROC                 ; OR C,REGISTER_IMMEDIATE
   CMP VDECODE[8],1110					; OPERAND2 ���� X
   JE OR_C_R_I_X
   CMP VDECODE[8],1111					; OPERAND2 ���� Y
   JE OR_C_R_I_Y
   
OR_C_R_I_X:
   MOV SI,X								; X�� ���� SI�� ����
   MOV DX,M[SI]							; DX�� M[SI]�� ����
   OR C,DX								; C�� DX�� OR
   JMP END_M_OR_C_REGI_IMME_P
OR_C_R_I_Y:
   MOV SI,Y								; Y�� ���� SI�� ����
   MOV DX,M[SI]							; DX�� M[SI]�� ����
   OR C,DX								; C�� DX�� OR

END_M_OR_C_REGI_IMME_P:
   RET
OR_C_REGI_IMME_P ENDP

;------------------------------------------------
;Procedure Name : OR_C_DI_P
;Function : OR C, DIRECT ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27 ,2016
;------------------------------------------------
OR_C_DI_P PROC                     ; OR C,DIRECT
   MOV SI,VDECODE[10]   			; SI�� VDECODE[10]�� ����Ǿ��ִ� �ּҰ��� ����  
   MOV DX,M[SI]						; DX�� M[SI]�� ����
   OR C,DX							; C�� DX�� OR
   RET
OR_C_DI_P ENDP

;------------------------------------------------
;Procedure Name : OR_D_P
;Function : OR D, �� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27 ,2016
;------------------------------------------------
OR_D_P PROC
   MOV AX, VDECODE[2]
   AND AX,11b
   MOV VDECODE[2],AX
                              ; OR D,
   CMP VDECODE[2],00b			; REGISTER ���
   JE OR_D_REGI
   CMP VDECODE[2],01b			; IMMEDIATE ���
   JE OR_D_IMME
   CMP VDECODE[2],10b			; REGISTER-INDIRECT ���
   JE OR_D_REGI_IMME
   CMP VDECODE[2],11b			; DIRECT ���
   JE OR_D_DI

   PRINT ERR
   JMP END_M_OR_D_P

OR_D_REGI:
   CALL OR_D_REGI_P				; OR_D_REGI_P ȣ��
   JMP END_M_OR_D_P
OR_D_IMME:
   CALL OR_D_IMME_P				; OR_D_IMME_P ȣ��
   JMP END_M_OR_D_P
OR_D_REGI_IMME:
   CALL OR_D_REGI_IMME_P		; OR_D_REGI_IMME_P ȣ��
   JMP END_M_OR_D_P
OR_D_DI:
   CALL OR_D_DI_P				; OR_D_DI_P ȣ��
   JMP END_M_OR_D_P

END_M_OR_D_P:
   RET
OR_D_P ENDP

;------------------------------------------------
;Procedure Name : OR_D_REGI_P
;Function : OR D, REGISTER �� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27 ,2016
;------------------------------------------------
OR_D_REGI_P PROC                         ; OR D,REGISTER

   MOV AX,VDECODE[8]
   AND AX,1111b
   MOV VDECODE[8],AX

   CMP VDECODE[8],1000b						; OPERAND2�� A
   JE OR_D_A
   CMP VDECODE[8],1001b						; OPERAND2�� B
   JE OR_D_B
   CMP VDECODE[8],1010b						; OPERAND2�� C
   JE OR_D_C
   CMP VDECODE[8],1011b						; OPERAND2�� D
   JE OR_D_D
   CMP VDECODE[8],1100b						; OPERAND2�� E
   JE OR_D_E
   CMP VDECODE[8],1101b						; OPERAND2�� F
   JE OR_D_F
   CMP VDECODE[8],1110b						; OPERAND2�� X
   JE OR_D_X
   CMP VDECODE[8],1111b						; OPERAND2�� Y
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
;Function : OR D, IMMEDIATE ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27 ,2016
;------------------------------------------------
OR_D_IMME_P PROC                   ; OR D,IMMEDIATE
   MOV DX,VDECODE[10]				; D�� VDECODE[10]�� ����Ǿ��ִ� IMMEDIATE ���� OR
   OR D,DX
   RET
OR_D_IMME_P ENDP

;------------------------------------------------
;Procedure Name : OR_D_REGI_IMME_P
;Function : OR D, REGISTER-INDIRECT ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27 ,2016
;------------------------------------------------
OR_D_REGI_IMME_P PROC                 ; OR D,REGISTER_IMMEDIATE
   CMP VDECODE[8],1110					; OPERAND2 ���� X
   JE OR_D_R_I_X
   CMP VDECODE[8],1111					; OPERAND2 ���� Y
   JE OR_D_R_I_Y
   
OR_D_R_I_X:
   MOV SI,X								; X�� ���� SI�� ����
   MOV DX,M[SI]							; DX�� M[SI]�� ����
   OR D,DX								; D�� DX�� OR
   JMP END_M_OR_D_REGI_IMME_P
OR_D_R_I_Y:
   MOV SI,Y								; Y�� ���� SI�� ����
   MOV DX,M[SI]							; DX�� M[SI]�� ����
   OR D,DX								; D�� DX�� OR

END_M_OR_D_REGI_IMME_P:
   RET
OR_D_REGI_IMME_P ENDP

;------------------------------------------------
;Procedure Name : OR_D_DI_P
;Function : OR D, DIRECT ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27 ,2016
;------------------------------------------------
OR_D_DI_P PROC                     ; OR D,DIRECT
   MOV SI,VDECODE[10]    			; SI�� VDECODE[10]�� ����Ǿ��ִ� �ּҰ��� ����    
   MOV DX,M[SI]						; DX�� M[SI]�� ����
   OR D,DX							; D�� DX�� OR
   RET
OR_D_DI_P ENDP

;------------------------------------------------
;Procedure Name : OR_E_P
;Function : OR E, �� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27 ,2016
;------------------------------------------------
OR_E_P PROC
   MOV AX, VDECODE[2]
   AND AX,11b
   MOV VDECODE[2],AX
                              ; OR E,
   CMP VDECODE[2],00b			; REGISTER ���
   JE OR_E_REGI
   CMP VDECODE[2],01b			; IMMEDIATE ���
   JE OR_E_IMME
   CMP VDECODE[2],10b			; REGISTER-INDIRECT ���
   JE OR_E_REGI_IMME
   CMP VDECODE[2],11b			; DIRECT ���
   JE OR_E_DI

   PRINT ERR
   JMP END_M_OR_E_P

OR_E_REGI:
   CALL OR_E_REGI_P				; OR_E_REGI_P ȣ��
   JMP END_M_OR_E_P
OR_E_IMME:
   CALL OR_E_IMME_P				; OR_E_IMME_P ȣ��
   JMP END_M_OR_E_P
OR_E_REGI_IMME:
   CALL OR_E_REGI_IMME_P		; OR_E_REGI_IMME_P ȣ��
   JMP END_M_OR_E_P
OR_E_DI:
   CALL OR_E_DI_P				; OR_E_DI_P ȣ��
   JMP END_M_OR_E_P

END_M_OR_E_P:
   RET
OR_E_P ENDP

;------------------------------------------------
;Procedure Name : OR_E_REGI_P
;Function : OR E, REGISTER �� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27 ,2016
;------------------------------------------------
OR_E_REGI_P PROC                         ; OR E,REGISTER

   MOV AX,VDECODE[8]
   AND AX,1111b
   MOV VDECODE[8],AX

   CMP VDECODE[8],1000b						; OPERAND2�� A
   JE OR_E_A
   CMP VDECODE[8],1001b						; OPERAND2�� B
   JE OR_E_B
   CMP VDECODE[8],1010b						; OPERAND2�� C
   JE OR_E_C
   CMP VDECODE[8],1011b						; OPERAND2�� D
   JE OR_E_D
   CMP VDECODE[8],1100b						; OPERAND2�� E
   JE OR_E_E
   CMP VDECODE[8],1101b						; OPERAND2�� F
   JE OR_E_F
   CMP VDECODE[8],1110b						; OPERAND2�� X
   JE OR_E_X
   CMP VDECODE[8],1111b						; OPERAND2�� Y
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
;Function : OR E, IMMEDIATE ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27 ,2016
;------------------------------------------------
OR_E_IMME_P PROC                   ; OR E,IMMEDIATE
   MOV DX,VDECODE[10]				; E�� VDECODE[10]�� ����Ǿ��ִ� IMMEDIATE ���� OR
   OR D,DX
   RET
OR_E_IMME_P ENDP

;------------------------------------------------
;Procedure Name : OR_E_REGI_IMME_P
;Function : OR E, REGISTER-INDIRECT ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27 ,2016
;------------------------------------------------
OR_E_REGI_IMME_P PROC                 ; OR E,REGISTER_IMMEDIATE
   CMP VDECODE[8],1110					; OPERAND2 ���� X
   JE OR_E_R_I_X
   CMP VDECODE[8],1111					; OPERAND2 ���� Y
   JE OR_E_R_I_Y
   
OR_E_R_I_X:
   MOV SI,X								; X�� ���� SI�� ����
   MOV DX,M[SI]							; DX�� M[SI]�� ����
   OR E,DX								; E�� DX�� OR
   JMP END_M_OR_E_REGI_IMME_P
OR_E_R_I_Y:
   MOV SI,Y								; Y�� ���� SI�� ����
   MOV DX,M[SI]							; DX�� M[SI]�� ����
   OR E,DX								; E�� DX�� OR

END_M_OR_E_REGI_IMME_P:
   RET
OR_E_REGI_IMME_P ENDP

;------------------------------------------------
;Procedure Name : OR_E_DI_P
;Function : OR E, DIRECT ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27 ,2016
;------------------------------------------------
OR_E_DI_P PROC                     ; OR E,DIRECT
   MOV SI,VDECODE[10]    			; SI�� VDECODE[10]�� ����Ǿ��ִ� �ּҰ��� ����    
   MOV DX,M[SI]						; DX�� M[SI]�� ����
   OR E,DX							; E�� DX�� OR
   RET
OR_E_DI_P ENDP

;------------------------------------------------
;Procedure Name : OR_F_P
;Function : OR F, �� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27 ,2016
;------------------------------------------------
OR_F_P PROC
   MOV AX, VDECODE[2]
   AND AX,11b
   MOV VDECODE[2],AX
                              ; OR F,
   CMP VDECODE[2],00b			; REGISTER ���
   JE OR_F_REGI
   CMP VDECODE[2],01b			; IMMEDIATE ���
   JE OR_F_IMME
   CMP VDECODE[2],10b			; REGISTER-INDIRECT ���
   JE OR_F_REGI_IMME
   CMP VDECODE[2],11b			; DIRECT ���
   JE OR_F_DI

   PRINT ERR
   JMP END_M_OR_F_P

OR_F_REGI:
   CALL OR_F_REGI_P				; OR_F_REGI_P ȣ��
   JMP END_M_OR_F_P
OR_F_IMME:
   CALL OR_F_IMME_P				; OR_F_IMME_P ȣ��
   JMP END_M_OR_F_P
OR_F_REGI_IMME:
   CALL OR_F_REGI_IMME_P		; OR_F_REGI_IMME_P ȣ��
   JMP END_M_OR_F_P
OR_F_DI:
   CALL OR_F_DI_P				; OR_F_DI_P ȣ��
   JMP END_M_OR_F_P

END_M_OR_F_P:
   RET
OR_F_P ENDP

;------------------------------------------------
;Procedure Name : OR_F_REGI_P
;Function : OR F, REGISTER �� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27 ,2016
;------------------------------------------------
OR_F_REGI_P PROC                         ; OR F,REGISTER

   MOV AX,VDECODE[8]
   AND AX,1111b
   MOV VDECODE[8],AX

   CMP VDECODE[8],1000b						; OPERAND2�� A
   JE OR_F_A
   CMP VDECODE[8],1001b						; OPERAND2�� B
   JE OR_F_B
   CMP VDECODE[8],1010b						; OPERAND2�� C
   JE OR_F_C
   CMP VDECODE[8],1011b						; OPERAND2�� D
   JE OR_F_D
   CMP VDECODE[8],1100b						; OPERAND2�� E
   JE OR_F_E
   CMP VDECODE[8],1101b						; OPERAND2�� F
   JE OR_F_F
   CMP VDECODE[8],1110b						; OPERAND2�� X
   JE OR_F_X
   CMP VDECODE[8],1111b						; OPERAND2�� Y
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
;Function : OR F, IMMEDIATE ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27 ,2016
;------------------------------------------------
OR_F_IMME_P PROC                   ; OR F,IMMEDIATE
   MOV DX,VDECODE[10]				; F�� VDECODE[10]�� ����Ǿ��ִ� IMMEDIATE ���� OR
   OR F,DX
   RET
OR_F_IMME_P ENDP

;------------------------------------------------
;Procedure Name : OR_F_REGI_IMME_P
;Function : OR F, REGISTER-INDIRECT ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27 ,2016
;------------------------------------------------
OR_F_REGI_IMME_P PROC                 ; OR F,REGISTER_IMMEDIATE
   CMP VDECODE[8],1110					; OPERAND2 ���� X
   JE OR_F_R_I_X
   CMP VDECODE[8],1111					; OPERAND2 ���� Y
   JE OR_F_R_I_Y
   
OR_F_R_I_X:
   MOV SI,X								; X�� ���� SI�� ����
   MOV DX,M[SI]							; DX�� M[SI]�� ����
   OR F,DX								; F�� DX�� OR
   JMP END_M_OR_F_REGI_IMME_P
OR_F_R_I_Y:
   MOV SI,Y								; Y�� ���� SI�� ����
   MOV DX,M[SI]							; DX�� M[SI]�� ����
   OR F,DX								; F�� DX�� OR

END_M_OR_F_REGI_IMME_P:
   RET
OR_F_REGI_IMME_P ENDP

;------------------------------------------------
;Procedure Name : OR_F_DI_P
;Function : OR F, DIRECT ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27 ,2016
;------------------------------------------------
OR_F_DI_P PROC                     ; OR F,DIRECT
   MOV SI,VDECODE[10]    			; SI�� VDECODE[10]�� ����Ǿ��ִ� �ּҰ��� ����       
   MOV DX,M[SI]						; DX�� M[SI]�� ����
   OR F,DX							; F�� DX�� OR
   RET
OR_F_DI_P ENDP

;------------------------------------------------
;Procedure Name : OR_X_P
;Function : OR X, �� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27 ,2016
;------------------------------------------------
OR_X_P PROC
   MOV AX, VDECODE[2]
   AND AX,11b
   MOV VDECODE[2],AX
                              ; OR X,
   CMP VDECODE[2],00b			; REGISTER ���
   JE OR_X_REGI
   CMP VDECODE[2],01b			; IMMEDIATE ���
   JE OR_X_IMME
   CMP VDECODE[2],10b			; REGISTER-INDIRECT ���
   JE OR_X_REGI_IMME
   CMP VDECODE[2],11b			; DIRECT ���
   JE OR_X_DI

   PRINT ERR
   JMP END_M_OR_X_P

OR_X_REGI:
   CALL OR_X_REGI_P				; OR_X_REGI_P ȣ��
   JMP END_M_OR_X_P
OR_X_IMME:
   CALL OR_X_IMME_P				; OR_X_IMME_P ȣ��
   JMP END_M_OR_X_P
OR_X_REGI_IMME:
   CALL OR_X_REGI_IMME_P		; OR_X_REGI_IMME_P ȣ��
   JMP END_M_OR_X_P
OR_X_DI:
   CALL OR_X_DI_P				; OR_X_DI_P ȣ��
   JMP END_M_OR_X_P

END_M_OR_X_P:
   RET
OR_X_P ENDP

;------------------------------------------------
;Procedure Name : OR_X_REGI_P
;Function : OR X, REGISTER �� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27 ,2016
;------------------------------------------------
OR_X_REGI_P PROC                         ; OR X,REGISTER

   MOV AX,VDECODE[8]
   AND AX,1111b
   MOV VDECODE[8],AX

   CMP VDECODE[8],1000b						; OPERAND2�� A
   JE OR_X_A
   CMP VDECODE[8],1001b						; OPERAND2�� B
   JE OR_X_B
   CMP VDECODE[8],1010b						; OPERAND2�� C
   JE OR_X_C
   CMP VDECODE[8],1011b						; OPERAND2�� D
   JE OR_X_D
   CMP VDECODE[8],1100b						; OPERAND2�� E
   JE OR_X_E
   CMP VDECODE[8],1101b						; OPERAND2�� F
   JE OR_X_F
   CMP VDECODE[8],1110b						; OPERAND2�� X
   JE OR_X_X
   CMP VDECODE[8],1111b						; OPERAND2�� Y
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
;Function : OR X, IMMEDIATE ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27 ,2016
;------------------------------------------------
OR_X_IMME_P PROC                   ; OR X,IMMEDIATE
   MOV DX,VDECODE[10]				; X�� VDECODE[10]�� ����Ǿ��ִ� IMMEDIATE ���� OR
   OR X,DX
   RET
OR_X_IMME_P ENDP

;------------------------------------------------
;Procedure Name : OR_X_REGI_IMME_P
;Function : OR X, REGISTER-INDIRECT ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27 ,2016
;------------------------------------------------
OR_X_REGI_IMME_P PROC                 ; OR X,REGISTER_IMMEDIATE
   CMP VDECODE[8],1110					; OPERAND2 ���� X
   JE OR_X_R_I_X
   CMP VDECODE[8],1111					; OPERAND2 ���� Y
   JE OR_X_R_I_Y
   
OR_X_R_I_X:
   MOV SI,X								; X�� ���� SI�� ����
   MOV DX,M[SI]							; DX�� M[SI]�� ����
   OR X,DX								; X�� DX�� OR
   JMP END_M_OR_X_REGI_IMME_P
OR_X_R_I_Y:
   MOV SI,Y								; Y�� ���� SI�� ����
   MOV DX,M[SI]							; DX�� M[SI]�� ����
   OR X,DX								; X�� DX�� OR

END_M_OR_X_REGI_IMME_P:
   RET
OR_X_REGI_IMME_P ENDP

;------------------------------------------------
;Procedure Name : OR_X_DI_P
;Function : OR X, DIRECT ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27 ,2016
;------------------------------------------------
OR_X_DI_P PROC                     ; OR X,DIRECT
   MOV SI,VDECODE[10]     			; SI�� VDECODE[10]�� ����Ǿ��ִ� �ּҰ��� ����  
   MOV DX,M[SI]						; DX�� M[SI]�� ����
   OR X,DX							; X�� DX�� OR
   RET
OR_X_DI_P ENDP

;------------------------------------------------
;Procedure Name : OR_Y_P
;Function : OR Y, �� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27 ,2016
;------------------------------------------------
OR_Y_P PROC
   MOV AX, VDECODE[2]
   AND AX,11b
   MOV VDECODE[2],AX
                              ; OR Y,
   CMP VDECODE[2],00b			; REGISTER ���
   JE OR_Y_REGI
   CMP VDECODE[2],01b			; IMMEDIATE ���
   JE OR_Y_IMME
   CMP VDECODE[2],10b			; REGISTER-INDIRECT ���
   JE OR_Y_REGI_IMME
   CMP VDECODE[2],11b			; DIRECT ���
   JE OR_Y_DI

   PRINT ERR
   JMP END_M_OR_Y_P

OR_Y_REGI:
   CALL OR_Y_REGI_P				; OR_Y_REGI_P ȣ��
   JMP END_M_OR_Y_P
OR_Y_IMME:
   CALL OR_Y_IMME_P				; OR_Y_IMME_P ȣ��
   JMP END_M_OR_Y_P
OR_Y_REGI_IMME:
   CALL OR_Y_REGI_IMME_P		; OR_Y_REGI_IMME_P ȣ��
   JMP END_M_OR_Y_P
OR_Y_DI:
   CALL OR_Y_DI_P				; OR_Y_DI_P ȣ��
   JMP END_M_OR_Y_P

END_M_OR_Y_P:
   RET
OR_Y_P ENDP

;------------------------------------------------
;Procedure Name : OR__REGI_P
;Function : OR Y, REGISTER �� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27 ,2016
;------------------------------------------------

OR_Y_REGI_P PROC                         ; OR Y,REGISTER

   MOV AX,VDECODE[8]
   AND AX,1111b
   MOV VDECODE[8],AX

   CMP VDECODE[8],1000b						; OPERAND2�� A
   JE OR_Y_A
   CMP VDECODE[8],1001b						; OPERAND2�� B
   JE OR_Y_B
   CMP VDECODE[8],1010b						; OPERAND2�� C
   JE OR_Y_C
   CMP VDECODE[8],1011b						; OPERAND2�� D
   JE OR_Y_D
   CMP VDECODE[8],1100b						; OPERAND2�� E
   JE OR_Y_E
   CMP VDECODE[8],1101b						; OPERAND2�� F
   JE OR_Y_F
   CMP VDECODE[8],1110b						; OPERAND2�� X
   JE OR_Y_X
   CMP VDECODE[8],1111b						; OPERAND2�� Y
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
;Function : OR Y, IMMEDIATE ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27 ,2016
;------------------------------------------------
OR_Y_IMME_P PROC                   ; OR Y,IMMEDIATE
   MOV DX,VDECODE[10]				; Y�� VDECODE[10]�� ����Ǿ��ִ� IMMEDIATE ���� OR
   OR Y,DX
   RET
OR_Y_IMME_P ENDP

;------------------------------------------------
;Procedure Name : OR_Y_REGI_IMME_P
;Function : OR Y, REGISTER-INDIRECT ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27 ,2016
;------------------------------------------------
OR_Y_REGI_IMME_P PROC                 ; OR Y,REGISTER_IMMEDIATE
   CMP VDECODE[8],1110					; OPERAND2 ���� X
   JE OR_Y_R_I_X
   CMP VDECODE[8],1111					; OPERAND2 ���� Y
   JE OR_Y_R_I_Y
   
OR_Y_R_I_X:
   MOV SI,X								; X�� ���� SI�� ����
   MOV DX,M[SI]							; DX�� M[SI]�� ����
   OR Y,DX								; Y�� DX�� OR
   JMP END_M_OR_Y_REGI_IMME_P
OR_Y_R_I_Y:
   MOV SI,Y								; Y�� ���� SI�� ����
   MOV DX,M[SI]							; DX�� M[SI]�� ����
   OR Y,DX								; Y�� DX�� OR

END_M_OR_Y_REGI_IMME_P:
   RET
OR_Y_REGI_IMME_P ENDP

;------------------------------------------------
;Procedure Name : OR_Y_DI_P
;Function : OR Y, DIRECT ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 27 ,2016
;------------------------------------------------
OR_Y_DI_P PROC                     ; OR Y,DIRECT
   MOV SI,VDECODE[10]     			; SI�� VDECODE[10]�� ����Ǿ��ִ� �ּҰ��� ����  
   MOV DX,M[SI]						; DX�� M[SI]�� ����
   OR Y,DX							; Y�� DX�� OR
   RET
OR_Y_DI_P ENDP

;------------------------
;Procedure Name : M_HALT
;Function : HALT ����� �ϴ� ���ν���
;PROGRAMED BY �Ͽ���
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
;Function : �������� A�� NOT �ϴ� ���ν���
;PROGRAMED BY �Ͽ���
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
NOT_R_A PROC   ; �������� ��� A
   NOT A
   RET
NOT_R_A ENDP

;------------------------------------------------
;Procedure Name : NOT_R_B
;Function : �������� B�� NOT �ϴ� ���ν���
;PROGRAMED BY �Ͽ���
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
NOT_R_B PROC   ; �������� ��� B
   NOT B
   RET
NOT_R_B ENDP

;------------------------------------------------
;Procedure Name : NOT_R_C
;Function : �������� C�� NOT �ϴ� ���ν���
;PROGRAMED BY �Ͽ���
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
NOT_R_C PROC   ; �������� ��� C
   NOT C
   RET
NOT_R_C ENDP

;------------------------------------------------
;Procedure Name : NOT_R_D
;Function : �������� D�� NOT �ϴ� ���ν���
;PROGRAMED BY �Ͽ���
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
NOT_R_D PROC   ; �������� ��� D
   NOT D
   RET
NOT_R_D ENDP

;------------------------------------------------
;Procedure Name : NOT_R_E
;Function : �������� E�� NOT �ϴ� ���ν���
;PROGRAMED BY �Ͽ���
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
NOT_R_E PROC   ; �������� ��� E
   NOT E
   RET
NOT_R_E ENDP

;------------------------------------------------
;Procedure Name : NOT_R_F
;Function : �������� F�� NOT �ϴ� ���ν���
;PROGRAMED BY �Ͽ���
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
NOT_R_F PROC   ; �������� ��� F
   NOT F
   RET
NOT_R_F ENDP

;------------------------------------------------
;Procedure Name : NOT_R_X
;Function : �������� X�� NOT �ϴ� ���ν���
;PROGRAMED BY �Ͽ���
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
NOT_R_X PROC   ; �������� ��� X
   NOT X
   RET
NOT_R_X ENDP

;------------------------------------------------
;Procedure Name : NOT_R_Y
;Function : �������� Y�� NOT �ϴ� ���ν���
;PROGRAMED BY �Ͽ���
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
NOT_R_Y PROC   ; �������� ��� Y
   NOT Y
   RET
NOT_R_Y ENDP

;------------------------------------------------
;Procedure Name : NOT_I_X
;Function : �������� X�� ����Ű�� ���� ���� NOT �ϴ� ���ν���
;PROGRAMED BY �Ͽ���
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
NOT_I_X PROC      ; INDIRECT ��� X
   MOV SI, X
   MOV AX, m[SI]
   NOT AX
   MOV m[SI], AX
   RET
NOT_I_X ENDP

;------------------------------------------------
;Procedure Name : NOT_I_Y
;Function : �������� Y�� ����Ű�� ���� ���� NOT �ϴ� ���ν���
;PROGRAMED BY �Ͽ���
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
NOT_I_Y PROC      ; INDIRECT ��� Y
   MOV DI, Y
   MOV AX, m[DI]
   NOT AX
   MOV m[DI], AX
   RET
NOT_I_Y ENDP

;------------------------
;Procedure Name : M_NOT
;Function : NOT ����� �ϴ� ���ν���
;PROGRAMED BY �Ͽ���
;PROGRAM VERSION
;   Creation Date :Nov 27,2016
;   Last Modified On Nov 28 ,2016
;------------------------
M_NOT PROC
   MOV DX, VDECODE[4]
   MOV BX, VDECODE[10]
   AND VDECODE[2],11b
   
   CMP VDECODE[2], 00b   ;REGISTER ���
   JE @NOT_REGISTER
   CMP VDECODE[2], 01b   ;IMMEDIATE ���
   JE @NOT_IMMEDIATE_1
   CMP VDECODE[2], 10b   ;REGISTER INDIRECT ���
   JE @NOT_REG_INDIRECT_1
   CMP VDECODE[2], 11b   ;DIRECT ���
   JE @NOT_DIRECT_1
   JMP @ENDN
   
@NOT_REGISTER:   ;REGISTER ���
   MOV VDECODE[4], DX
   AND VDECODE[4], 1111b
   
   CMP VDECODE[4], 1000b ;��������A
   JE @REGISTER_NOT_A
   CMP VDECODE[4], 1001b ;��������B
   JE @REGISTER_NOT_B
   CMP VDECODE[4], 1010b ;��������C
   JE @REGISTER_NOT_C
   CMP VDECODE[4], 1011b ;��������D
   JE @REGISTER_NOT_D
   CMP VDECODE[4], 1100b ;��������E
   JE @REGISTER_NOT_E
   CMP VDECODE[4], 1101b ;��������F
   JE @REGISTER_NOT_F
   CMP VDECODE[4], 1110b ;��������X
   JE @REGISTER_NOT_X
   CMP VDECODE[4], 1111b ;��������Y
   JE @REGISTER_NOT_Y
   JMP @ENDN
   
@NOT_IMMEDIATE_1:
   JMP @NOT_IMMEDIATE
   
@NOT_REG_INDIRECT_1:
   JMP @NOT_REG_INDIRECT
   
@NOT_DIRECT_1:
   JMP @NOT_DIRECT_2

@REGISTER_NOT_A:
   CALL NOT_R_A					;NOT_R_A ȣ��
   JMP @ENDN
@REGISTER_NOT_B:
   CALL   NOT_R_B					;NOT_R_B ȣ��
   JMP @ENDN
@REGISTER_NOT_C:
   CALL   NOT_R_C					;NOT_R_C ȣ��
   JMP @ENDN
@REGISTER_NOT_D:   
   CALL   NOT_R_D					;NOT_R_D ȣ��
   JMP @ENDN
@REGISTER_NOT_E:   
   CALL   NOT_R_E					;NOT_R_E ȣ��
   JMP @ENDN
@REGISTER_NOT_F:
   CALL   NOT_R_F					;NOT_R_F ȣ��
   JMP @ENDN
@REGISTER_NOT_X:
   CALL   NOT_R_X					;NOT_R_X ȣ��
   JMP @ENDN
@REGISTER_NOT_Y:
   CALL   NOT_R_Y					;NOT_R_Y ȣ��
   JMP @ENDN
   
@NOT_IMMEDIATE:   ;IMMEDIATE ���
   JMP @ENDN

@NOT_DIRECT_2:
   JMP @NOT_DIRECT

@NOT_REG_INDIRECT:   ;REGISTER INDIRECT ���
   MOV VDECODE[4], DX
   AND VDECODE[4], 1111b

   CMP VDECODE[4], 1110b ;��������X
   JE @NOT_INDIRECT_X
   CMP VDECODE[4], 1111b ;��������Y
   JE @NOT_INDIRECT_Y
   JMP @ENDN

@NOT_INDIRECT_X:
   CALL NOT_I_X					; NOT_I_X ȣ��
   
   JMP @ENDN
@NOT_INDIRECT_Y:
   CALL NOT_I_Y					; NOT_I_Y ȣ��
   JMP @ENDN
   
@NOT_DIRECT:   ;DIRECT ���
@ENDN:
   RET
M_NOT ENDP

;------------------------------------------------
;Procedure Name : M_AND
;Function : AND ����� ����
;PROGRAMED BY ���¿�
;PROGRAM VERSION
;   Creation Date :Nov 24,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
M_AND PROC
;AND ��ɾ�
;��� ����
   cmp VDECODE[2], 00b      ;register ���
   je M_AND_REGISTER
   cmp VDECODE[2], 01b      ;immediate ���
   je M_AND_IMMEDIATE1
   cmp VDECODE[2], 10b      ;indirect ���
   je M_AND_INDIRECT1
   cmp VDECODE[2], 11b      ;direct ���
   je M_AND_DIRECT1
   jmp M_AND_END         ;M_AND ����
   
M_AND_REGISTER:            ;register ���
   cmp VDECODE[4], 1000b      ;operand1�� A
   je M_AND_REGISTER_A
   cmp VDECODE[4], 1001b      ;operand1�� B
   je M_AND_REGISTER_B1
   cmp VDECODE[4], 1010b      ;operand1�� C
   je M_AND_REGISTER_C1
   cmp VDECODE[4], 1011b      ;operand1�� D
   je M_AND_REGISTER_D1
   cmp VDECODE[4], 1100b      ;operand1�� E
   je M_AND_REGISTER_E1
   cmp VDECODE[4], 1101b      ;operand1�� F
   je M_AND_REGISTER_F1
   cmp VDECODE[4], 1110b      ;operand1�� X
   je M_AND_REGISTER_X1
   cmp VDECODE[4], 1111b      ;operand1�� Y
   je M_AND_REGISTER_Y1
   jmp M_AND_END         ;M_AND ����
   
;Immediate, Indirect, Register��� �б������� ������ ��
;�������� �����ذ��� ���� ���� �Ÿ��� ������ �б�
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
   
M_AND_REGISTER_A:         ;register ����̰� operand1�� A�϶�
   cmp VDECODE[8], 1000b      ;operand2�� A
   je M_AND_A_A
   cmp VDECODE[8], 1001b      ;operand2�� B
   je M_AND_A_B
   cmp VDECODE[8], 1010b      ;operand2�� C
   je M_AND_A_C
   cmp VDECODE[8], 1011b      ;operand2�� D
   je M_AND_A_D
   cmp VDECODE[8], 1100b      ;operand2�� E
   je M_AND_A_E
   cmp VDECODE[8], 1101b      ;operand2�� F
   je M_AND_A_F
   cmp VDECODE[8], 1110b      ;operand2�� X
   je M_AND_A_X
   cmp VDECODE[8], 1111b      ;operand2�� Y
   je M_AND_A_Y
   jmp M_AND_END         ;M_AND ����

   
M_AND_A_A:               ;AND A, A
   mov bx, A
   call M_AND_A_AND         ;A�� � ���� AND �����ϴ� ���ν��� ��
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
   
   
M_AND_REGISTER_B:         ;register ����̰� operand1�� B�϶�
   cmp VDECODE[8], 1000b      ;operand2�� A
   je M_AND_B_A
   cmp VDECODE[8], 1001b      ;operand2�� B
   je M_AND_B_B
   cmp VDECODE[8], 1010b      ;operand2�� C
   je M_AND_B_C
   cmp VDECODE[8], 1011b      ;operand2�� D
   je M_AND_B_D
   cmp VDECODE[8], 1100b      ;operand2�� E
   je M_AND_B_E
   cmp VDECODE[8], 1101b      ;operand2�� F
   je M_AND_B_F
   cmp VDECODE[8], 1110b      ;operand2�� X
   je M_AND_B_X
   cmp VDECODE[8], 1111b      ;operand2�� Y
   je M_AND_B_Y
   jmp M_AND_END         ;M_AND ����
   
;�������� �����ذ��� ���� ���� �Ÿ��� ������ �б�  
M_AND_IMMEDIATE2:
jmp M_AND_IMMEDIATE3   
M_AND_INDIRECT2:
jmp M_AND_INDIRECT3
M_AND_DIRECT2:
jmp M_AND_DIRECT3
   
M_AND_B_A:               ;AND B, A
   mov bx, A
   call M_AND_B_AND         ;B�� � ���� AND �����ϴ� ���ν��� ��
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
   
M_AND_REGISTER_C:         ;register ����̰� operand1�� C�϶�
   cmp VDECODE[8], 1000b      ;operand2�� A
   je M_AND_C_A
   cmp VDECODE[8], 1001b      ;operand2�� B
   je M_AND_C_B
   cmp VDECODE[8], 1010b      ;operand2�� C
   je M_AND_C_C
   cmp VDECODE[8], 1011b      ;operand2�� D
   je M_AND_C_D
   cmp VDECODE[8], 1100b      ;operand2�� E
   je M_AND_C_E
   cmp VDECODE[8], 1101b      ;operand2�� F
   je M_AND_C_F
   cmp VDECODE[8], 1110b      ;operand2�� X
   je M_AND_C_X
   cmp VDECODE[8], 1111b      ;operand2�� Y
   je M_AND_C_Y
   jmp M_AND_END         ;M_AND ����
   
;�������� �����ذ��� ���� ���� �Ÿ��� ������ �б�   
M_AND_IMMEDIATE3:
jmp M_AND_IMMEDIATE4
M_AND_INDIRECT3:
jmp M_AND_INDIRECT4
M_AND_DIRECT3:
jmp M_AND_DIRECT4
   
M_AND_C_A:               ;AND C, A
   mov bx, A
   call M_AND_C_AND         ;C�� � ���� AND �����ϴ� ���ν��� ��
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
   
M_AND_REGISTER_D:         ;register ����̰� operand1�� D�϶�
   cmp VDECODE[8], 1000b      ;operand2�� A
   je M_AND_D_A
   cmp VDECODE[8], 1001b      ;operand2�� B
   je M_AND_D_B
   cmp VDECODE[8], 1010b      ;operand2�� C
   je M_AND_D_C
   cmp VDECODE[8], 1011b      ;operand2�� D
   je M_AND_D_D
   cmp VDECODE[8], 1100b      ;operand2�� E
   je M_AND_D_E
   cmp VDECODE[8], 1101b      ;operand2�� F
   je M_AND_D_F
   cmp VDECODE[8], 1110b      ;operand2�� X
   je M_AND_D_X
   cmp VDECODE[8], 1111b      ;operand2�� Y
   je M_AND_D_Y
   jmp M_AND_END         ;M_AND ����
   
;�������� �����ذ��� ���� ���� �Ÿ��� ������ �б�   
M_AND_IMMEDIATE4:
jmp M_AND_IMMEDIATE5   
M_AND_INDIRECT4:
jmp M_AND_INDIRECT5
M_AND_DIRECT4:
jmp M_AND_DIRECT5
   
M_AND_D_A:               ;AND D, A
   mov bx, A
   call M_AND_D_AND         ;D�� � ���� AND �����ϴ� ���ν��� ��
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
M_AND_REGISTER_E:         ;register ����̰� operand1�� E�϶�
   cmp VDECODE[8], 1000b      ;operand2�� A
   je M_AND_E_A
   cmp VDECODE[8], 1001b      ;operand2�� B
   je M_AND_E_B
   cmp VDECODE[8], 1010b      ;operand2�� C
   je M_AND_E_C
   cmp VDECODE[8], 1011b      ;operand2�� D
   je M_AND_E_D
   cmp VDECODE[8], 1100b      ;operand2�� E
   je M_AND_E_E
   cmp VDECODE[8], 1101b      ;operand2�� F
   je M_AND_E_F
   cmp VDECODE[8], 1110b      ;operand2�� X
   je M_AND_E_X
   cmp VDECODE[8], 1111b      ;operand2�� Y
   je M_AND_E_Y
   jmp M_AND_END         ;M_AND ����
   
;�������� �����ذ��� ���� ���� �Ÿ��� ������ �б�   
M_AND_IMMEDIATE5:
jmp M_AND_IMMEDIATE6
M_AND_INDIRECT5:
jmp M_AND_INDIRECT6
M_AND_DIRECT5:
jmp M_AND_DIRECT6

M_AND_E_A:               ;AND E, A
   mov bx, A
   call M_AND_E_AND         ;E�� � ���� AND �����ϴ� ���ν��� ��
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
   
M_AND_REGISTER_F:         ;register ����̰� operand1�� F�϶�
   cmp VDECODE[8], 1000b      ;operand2�� A
   je M_AND_F_A
   cmp VDECODE[8], 1001b      ;operand2�� B
   je M_AND_F_B
   cmp VDECODE[8], 1010b      ;operand2�� C
   je M_AND_F_C
   cmp VDECODE[8], 1011b      ;operand2�� D
   je M_AND_F_D
   cmp VDECODE[8], 1100b      ;operand2�� E
   je M_AND_F_E
   cmp VDECODE[8], 1101b      ;operand2�� F
   je M_AND_F_F
   cmp VDECODE[8], 1110b      ;operand2�� X
   je M_AND_F_X
   cmp VDECODE[8], 1111b      ;operand2�� Y
   je M_AND_F_Y
   jmp M_AND_END         ;M_AND ����
   
;�������� �����ذ��� ���� ���� �Ÿ��� ������ �б�   
M_AND_IMMEDIATE6:
jmp M_AND_IMMEDIATE7
M_AND_INDIRECT6:
jmp M_AND_INDIRECT7   
M_AND_DIRECT6:
jmp M_AND_DIRECT7
   
M_AND_F_A:               ;AND F, A
   mov bx, A
   call M_AND_F_AND         ;F�� � ���� AND �����ϴ� ���ν��� ��
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
   
M_AND_REGISTER_X:         ;register ����̰� operand1�� X�϶�
   cmp VDECODE[8], 1000b      ;operand2�� A
   je M_AND_X_A
   cmp VDECODE[8], 1001b      ;operand2�� B
   je M_AND_X_B
   cmp VDECODE[8], 1010b      ;operand2�� C
   je M_AND_X_C
   cmp VDECODE[8], 1011b      ;operand2�� D
   je M_AND_X_D
   cmp VDECODE[8], 1100b      ;operand2�� E
   je M_AND_X_E
   cmp VDECODE[8], 1101b      ;operand2�� F
   je M_AND_X_F
   cmp VDECODE[8], 1110b      ;operand2�� X
   je M_AND_X_X
   cmp VDECODE[8], 1111b      ;operand2�� Y
   je M_AND_X_Y
   jmp M_AND_END         ;M_AND ����
 
;�������� �����ذ��� ���� ���� �Ÿ��� ������ �б� 
M_AND_IMMEDIATE7:
jmp M_AND_IMMEDIATE8
M_AND_INDIRECT7:
jmp M_AND_INDIRECT8
M_AND_DIRECT7:
jmp M_AND_DIRECT8
   
M_AND_X_A:               ;AND X, A
   mov bx, A
   call M_AND_X_AND         ;X�� � ���� AND �����ϴ� ���ν��� ��
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
M_AND_REGISTER_Y:         ;register ����̰� operand1�� Y�϶�
   cmp VDECODE[8], 1000b      ;operand2�� A
   je M_AND_Y_A
   cmp VDECODE[8], 1001b      ;operand2�� B
   je M_AND_Y_B
   cmp VDECODE[8], 1010b      ;operand2�� C
   je M_AND_Y_C
   cmp VDECODE[8], 1011b      ;operand2�� D
   je M_AND_Y_D
   cmp VDECODE[8], 1100b      ;operand2�� E
   je M_AND_Y_E
   cmp VDECODE[8], 1101b      ;operand2�� F
   je M_AND_Y_F
   cmp VDECODE[8], 1110b      ;operand2�� X
   je M_AND_Y_X
   cmp VDECODE[8], 1111b      ;operand2�� Y
   je M_AND_Y_Y
   jmp M_AND_END         ;M_AND ����
   
;�������� �����ذ��� ���� ���� �Ÿ��� ������ �б�
M_AND_IMMEDIATE8:
jmp M_AND_IMMEDIATE
M_AND_INDIRECT8:
jmp M_AND_INDIRECT
M_AND_DIRECT8:
jmp M_AND_DIRECT
   
M_AND_Y_A:               ;AND Y, A
   mov bx, A
   call M_AND_Y_AND         ;Y�� � ���� AND �����ϴ� ���ν��� ��
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
   
M_AND_IMMEDIATE:         ;immediate ���
   cmp VDECODE[4], 1000b      ;operand1�� A
   je M_AND_IMMEDIATE_A
   cmp VDECODE[4], 1001b      ;operand1�� B
   je M_AND_IMMEDIATE_B
   cmp VDECODE[4], 1010b      ;operand1�� C
   je M_AND_IMMEDIATE_C
   cmp VDECODE[4], 1011b      ;operand1�� D
   je M_AND_IMMEDIATE_D
   cmp VDECODE[4], 1100b      ;operand1�� E
   je M_AND_IMMEDIATE_E
   cmp VDECODE[4], 1101b      ;operand1�� F
   je M_AND_IMMEDIATE_F
   cmp VDECODE[4], 1110b      ;operand1�� X
   je M_AND_IMMEDIATE_X
   cmp VDECODE[4], 1111b      ;operand1�� Y
   je M_AND_IMMEDIATE_Y
   jmp M_AND_END         ;M_AND ����
   
M_AND_IMMEDIATE_A:         ;immediate ����̰� operand1�� A�϶�
   mov bx, VDECODE[10]
   call M_AND_A_AND
   jmp M_AND_END
M_AND_IMMEDIATE_B:         ;immediate ����̰� operand1�� B�϶�
   mov bx, VDECODE[10]
   call M_AND_B_AND
   jmp M_AND_END
M_AND_IMMEDIATE_C:         ;immediate ����̰� operand1�� C�϶�
   mov bx, VDECODE[10]
   call M_AND_C_AND
   jmp M_AND_END
M_AND_IMMEDIATE_D:         ;immediate ����̰� operand1�� D�϶�
   mov bx, VDECODE[10]
   call M_AND_D_AND
   jmp M_AND_END
M_AND_IMMEDIATE_E:         ;immediate ����̰� operand1�� E�϶�
   mov bx, VDECODE[10]
   call M_AND_E_AND
   jmp M_AND_END
M_AND_IMMEDIATE_F:         ;immediate ����̰� operand1�� F�϶�
   mov bx, VDECODE[10]
   call M_AND_F_AND
   jmp M_AND_END
M_AND_IMMEDIATE_X:         ;immediate ����̰� operand1�� X�϶�
   mov bx, VDECODE[10]
   call M_AND_X_AND
   jmp M_AND_END
M_AND_IMMEDIATE_Y:         ;immediate ����̰� operand1�� Y�϶�
   mov bx, VDECODE[10]
   call M_AND_Y_AND
   jmp M_AND_END
   

M_AND_INDIRECT:            ;Indirect���
   cmp VDECODE[4], 1000b      ;operand1�� A
   je M_AND_INDIRECT_A
   cmp VDECODE[4], 1001b      ;operand1�� B
   je M_AND_INDIRECT_B
   cmp VDECODE[4], 1010b      ;operand1�� C
   je M_AND_INDIRECT_C1
   cmp VDECODE[4], 1011b      ;operand1�� D
   je M_AND_INDIRECT_D1
   cmp VDECODE[4], 1100b      ;operand1�� E
   je M_AND_INDIRECT_E1
   cmp VDECODE[4], 1101b      ;operand1�� F
   je M_AND_INDIRECT_F1
   cmp VDECODE[4], 1110b      ;operand1�� X
   je M_AND_INDIRECT_X1
   cmp VDECODE[4], 1111b      ;operand1�� Y
   je M_AND_INDIRECT_Y1
   jmp M_AND_END         ;M_AND ����
   
;�������� �����ذ��� ���� ���� �Ÿ��� ������ �б�   
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
   
M_AND_INDIRECT_A:         ;Indirect����̰� operand1�� A�϶�
   cmp VDECODE[8], 1110b
   je M_AND_A_ADX            ;operand2�� X
   cmp VDECODE[8], 1111b
   je M_AND_A_ADY            ;operand2�� Y
   jmp M_AND_END         ;M_AND ����
   
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
   
M_AND_INDIRECT_B:         ;Indirect����̰� operand1�� B�϶�
   cmp VDECODE[8], 1110b
   je M_AND_B_ADX            ;operand2�� X
   cmp VDECODE[8], 1111b
   je M_AND_B_ADY            ;operand2�� Y
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
   
M_AND_INDIRECT_C:         ;Indirect����̰� operand1�� C�϶�
   cmp VDECODE[8], 1110b
   je M_AND_C_ADX            ;operand2�� X
   cmp VDECODE[8], 1111b
   je M_AND_C_ADY            ;operand2�� Y
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
   
M_AND_INDIRECT_D:         ;Indirect����̰� operand1�� D�϶�
   cmp VDECODE[8], 1110b
   je M_AND_D_ADX            ;operand2�� X
   cmp VDECODE[8], 1111b
   je M_AND_D_ADY            ;operand2�� Y
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
   
M_AND_INDIRECT_E:         ;Indirect����̰� operand1�� E�϶�
   cmp VDECODE[8], 1110b
   je M_AND_E_ADX            ;operand2�� X
   cmp VDECODE[8], 1111b
   je M_AND_E_ADY            ;operand2�� X
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
   
M_AND_INDIRECT_F:         ;Indirect����̰� operand1�� F�϶�
   cmp VDECODE[8], 1110b
   je M_AND_F_ADX            ;operand2�� X
   cmp VDECODE[8], 1111b
   je M_AND_F_ADY            ;operand2�� Y
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
   
M_AND_INDIRECT_X:         ;Indirect����̰� operand1�� X�϶�
   cmp VDECODE[8], 1110b
   je M_AND_X_ADX            ;operand2�� X
   cmp VDECODE[8], 1111b
   je M_AND_X_ADY            ;operand2�� Y
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
   
M_AND_INDIRECT_Y:         ;Indirect����̰� operand1�� Y�϶�
   cmp VDECODE[8], 1110b
   je M_AND_Y_ADX            ;operand2�� X
   cmp VDECODE[8], 1111b
   je M_AND_Y_ADY            ;operand2�� Y
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

M_AND_DIRECT:            ;Direct���
   cmp VDECODE[4], 1000b      ;operand1�� A
   je M_AND_DIRECT_A
   cmp VDECODE[4], 1001b      ;operand1�� B
   je M_AND_DIRECT_B
   cmp VDECODE[4], 1010b      ;operand1�� C
   je M_AND_DIRECT_C
   cmp VDECODE[4], 1011b      ;operand1�� D
   je M_AND_DIRECT_D
   cmp VDECODE[4], 1100b      ;operand1�� E
   je M_AND_DIRECT_E
   cmp VDECODE[4], 1101b      ;operand1�� F
   je M_AND_DIRECT_F
   cmp VDECODE[4], 1110b      ;operand1�� X
   je M_AND_DIRECT_X
   cmp VDECODE[4], 1111b      ;operand1�� Y
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

M_AND_A_AND PROC         ;A�� � ���� AND�����ϴ� ���ν���
   mov ax, A
   and ax, bx
   mov A, ax
   RET
M_AND_A_AND ENDP

M_AND_B_AND PROC         ;B�� � ���� AND�����ϴ� ���ν���
   mov ax, B
   and ax, bx
   mov B, ax
   RET
M_AND_B_AND ENDP

M_AND_C_AND PROC         ;C�� � ���� AND�����ϴ� ���ν���
   mov ax, C
   and ax, bx
   mov C, ax
   RET
M_AND_C_AND ENDP

M_AND_D_AND PROC         ;D�� � ���� AND�����ϴ� ���ν���
   mov ax, D
   and ax, bx
   mov D, ax
   RET
M_AND_D_AND ENDP

M_AND_E_AND PROC         ;E�� � ���� AND�����ϴ� ���ν���
   mov ax, E
   and ax, bx
   mov E, ax
   RET
M_AND_E_AND ENDP

M_AND_F_AND PROC         ;F�� � ���� AND�����ϴ� ���ν���
   mov ax, F
   and ax, bx
   mov F, ax
   RET
M_AND_F_AND ENDP

M_AND_X_AND PROC         ;X�� � ���� AND�����ϴ� ���ν���
   mov ax, X
   and ax, bx
   mov X, ax
   RET
M_AND_X_AND ENDP

M_AND_Y_AND PROC         ;Y�� � ���� AND�����ϴ� ���ν���
   mov ax, Y
   and ax, bx
   mov Y, ax
   RET
M_AND_Y_AND ENDP

;------------------------------------------------
;Procedure Name : M_MUL
;Function : MUL ��ɾ� ����� ����
;PROGRAMED BY ���¿�, ������
;PROGRAM VERSION
;   Creation Date :Nov 10,2016
;   Last Modified On Dec 16 ,2016
;------------------------------------------------
M_MUL PROC
;MUL ��ɾ� ����
   mov dx, VDECODE[4]
   mov ax, VDECODE[8]
   mov bx, VDECODE[2]
   
   and VDECODE[4], 1111b
   mov VDECODE[4], dx
   
   cmp VDECODE[4], 1000b   ;operand1�� A�϶�
   je M_MUL_A
   cmp VDECODE[4], 1001b   ;operand1�� B�϶�
   je M_MUL_B1
   cmp VDECODE[4], 1010b   ;operand1�� C�϶�
   je M_MUL_C1
   cmp VDECODE[4], 1011b   ;operand1�� D�϶�
   je M_MUL_D1
   cmp VDECODE[4], 1100b   ;operand1�� E�϶�
   je M_MUL_E1
   cmp VDECODE[4], 1101b   ;operand1�� F�϶�
   je M_MUL_F1
   cmp VDECODE[4], 1110b   ;operand1�� X�϶�
   je M_MUL_X1
   cmp VDECODE[4], 1111b   ;operand1�� Y�϶�
   je M_MUL_Y1
   jmp M_MUL_EXIT   ;M_MUL ����
   
M_MUL_A:      ;operand1�� A�� �� mulressing mode ��
   and VDECODE[2], 11b
   mov VDECODE[2], bx
   
   cmp VDECODE[2], 00b      ;Register ���
   je M_MUL_A_REG
   cmp VDECODE[2], 01b      ;Immediate ���
   je M_MUL_A_IMME1
   cmp VDECODE[2], 10b      ;Indirect ���
   je M_MUL_A_INDIRECT
   cmp VDECODE[2], 11b      ;Direct ���
   je M_MUL_A_DIRECT
   jmp M_MUL_EXIT         ;M_MUL ����
   
            ;M_MUL_B, C, D, E, F, X, Y���� ������ �� 
            ;�������� �����ذ��� ���� ���� �Ÿ��� ������ �б�
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
   
M_MUL_A_INDIRECT:         ;operand1�� A�̰� INDIRECT���
   cmp VDECODE[8], 1110b   ;operand1�� A�̰� operand2�� X�϶�
   je M_MUL_A_INDIRECT_X
   cmp VDECODE[8], 1111b   ;operand1�� A�̰� operand2�� Y�϶�
   je M_MUL_A_INDIRECT_Y
M_MUL_A_INDIRECT_X:         ;operand1�� A�̰� operand2�� X�϶�
   mov si, X
   mov bx, m[si]
   call M_MUL_A_REG_SOMETHING   ;A�� � ���� �����ϴ� ���ν��� ��
   jmp M_MUL_A_EXIT            ;M_MUL ����
M_MUL_A_INDIRECT_Y:            ;operand1�� A�̰� operand2�� Y�϶�
   mov si, Y
   mov bx, m[si]
   call M_MUL_A_REG_SOMETHING
   jmp M_MUL_A_EXIT            ;M_MUL ����
M_MUL_A_DIRECT:               ;operand1�� A�̰� direct ����� ��
   mov si, VDECODE[10]
   mov bx, m[si]
   call M_MUL_A_REG_SOMETHING
   jmp M_MUL_A_EXIT            ;M_MUL_A ����

            ;�������� �����ذ��� ���� ���� �Ÿ��� ������ �б�   
M_MUL_A_IMME1:
   jmp M_MUL_A_IMME   
   
M_MUL_A_REG:         ;operand1�� A�̰� operand2�� ���������϶�
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
   jmp M_MUL_A_EXIT            ;M_MUL ����
   
;�������� �����ذ��� ���� ���� �Ÿ��� ������ �б� 
M_MUL_B2:
   jmp M_MUL_B
   
M_MUL_A_REG_A:               ;MUL A, A
   mov bx, A
   call M_MUL_A_REG_SOMETHING
   jmp M_MUL_A_EXIT            ;M_MUL ����
M_MUL_A_REG_B:               ;MUL A, B
   mov bx, B
   call M_MUL_A_REG_SOMETHING
   jmp M_MUL_A_EXIT            ;M_MUL ����
M_MUL_A_REG_C:               ;MUL A, C
   mov bx, C
   call M_MUL_A_REG_SOMETHING
   jmp M_MUL_A_EXIT            ;M_MUL ����
M_MUL_A_REG_D:               ;MUL A, D
   mov bx, D
   call M_MUL_A_REG_SOMETHING
   jmp M_MUL_A_EXIT            ;M_MUL ����
M_MUL_A_REG_E:               ;MUL A, E
   mov bx, E
   call M_MUL_A_REG_SOMETHING
   jmp M_MUL_A_EXIT            ;M_MUL ����
M_MUL_A_REG_F:               ;MUL A, F
   mov bx, F
   call M_MUL_A_REG_SOMETHING
   jmp M_MUL_A_EXIT            ;M_MUL ����
M_MUL_A_REG_X:               ;MUL A, X
   mov bx, X
   call M_MUL_A_REG_SOMETHING
   jmp M_MUL_A_EXIT            ;M_MUL ����
M_MUL_A_REG_Y:               ;MUL A, Y
   mov bx, Y
   call M_MUL_A_REG_SOMETHING
   jmp M_MUL_A_EXIT            ;M_MUL ����

M_MUL_A_IMME:               ;operand1�� A�̰� immediate ����� ��
   mov ax, A
   mov bx, VDECODE[10]
   mul bx
   mov A, ax
   
M_MUL_A_EXIT:               ;M_MUL�� ����
   jmp M_MUL_EXIT

M_MUL_B:                  ;operand1�� B�� �� mulressing mode ��
   cmp VDECODE[2], 00b;Register ���
   je M_MUL_B_REG
   cmp VDECODE[2], 01b;Immediate ���
   je M_MUL_B_IMME1
   cmp VDECODE[2], 10b;Indirect ���
   je M_MUL_B_INDIRECT
   cmp VDECODE[2], 11b;Direct ���
   je M_MUL_B_DIRECT
   jmp M_MUL_EXIT            ;M_MUL�� ����

M_MUL_B_INDIRECT:            ;operand1�� B�̰� INDIRECT���
   cmp VDECODE[8], 1110b      ;operand1�� B�̰� operand2�� X�϶�
   je M_MUL_B_INDIRECT_X
   cmp VDECODE[8], 1111b      ;operand1�� B�̰� operand2�� Y�϶�
   je M_MUL_B_INDIRECT_Y
M_MUL_B_INDIRECT_X:            ;operand1�� B�̰� operand2�� X�϶�
   mov si, X
   mov bx, m[si]
   call M_MUL_B_REG_SOMETHING   ;B�� � ���� �����ϴ� ���ν��� ��
   jmp M_MUL_B_EXIT            ;M_MUL ����
M_MUL_B_INDIRECT_Y:            ;operand1�� B�̰� operand2�� Y�϶� 
   mov si, Y
   mov bx, m[si]
   call M_MUL_B_REG_SOMETHING
   jmp M_MUL_B_EXIT            ;M_MUL ����
M_MUL_B_DIRECT:               ;operand1�� B�̰� direct ����� ��
   mov si, VDECODE[10]
   mov bx, m[si]
   call M_MUL_B_REG_SOMETHING
   jmp M_MUL_B_EXIT            ;M_MUL ����
  
            ;�������� �����ذ��� ���� ���� �Ÿ��� ������ �б�   
M_MUL_B_IMME1:
   jmp M_MUL_B_IMME
   
M_MUL_B_REG:            ;operand1�� B�̰� operand2�� ���������϶�   
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
   jmp M_MUL_B_EXIT         ;M_MUL ����
   
            ;�������� �����ذ��� ���� ���� �Ÿ��� ������ �б�  
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
   jmp M_MUL_B_EXIT      ;M_MUL ����
M_MUL_B_REG_B:         ;MUL B, B
   mov bx, B
   call M_MUL_B_REG_SOMETHING
   jmp M_MUL_B_EXIT      ;M_MUL ����
M_MUL_B_REG_C:         ;MUL B, C
   mov bx, C
   call M_MUL_B_REG_SOMETHING
   jmp M_MUL_B_EXIT      ;M_MUL ����
M_MUL_B_REG_D:         ;MUL B, D
   mov bx, D
   call M_MUL_B_REG_SOMETHING
   jmp M_MUL_B_EXIT      ;M_MUL ����
M_MUL_B_REG_E:         ;MUL B, E
   mov bx, E
   call M_MUL_B_REG_SOMETHING
   jmp M_MUL_B_EXIT      ;M_MUL ����
M_MUL_B_REG_F:         ;MUL B, F
   mov bx, F
   call M_MUL_B_REG_SOMETHING
   jmp M_MUL_B_EXIT      ;M_MUL ����
M_MUL_B_REG_X:         ;MUL B, X
   mov bx, X
   call M_MUL_B_REG_SOMETHING
   jmp M_MUL_B_EXIT      ;M_MUL ����
M_MUL_B_REG_Y:         ;MUL B, Y
   mov bx, Y
   call M_MUL_B_REG_SOMETHING
   jmp M_MUL_B_EXIT      ;M_MUL ����

M_MUL_B_IMME:         ;operand1�� B�̰� immediate ����� ��
   mov ax, B
   mov bx, VDECODE[10]
   mul bx
   mov B, ax
   
M_MUL_B_EXIT:         ;M_MUL ����
   jmp M_MUL_EXIT

M_MUL_C:      ;operand1�� C�� �� mulressing mode ��
   cmp VDECODE[2], 00b      ;Register ���
   je M_MUL_C_REG
   cmp VDECODE[2], 01b      ;Immediate ���
   je M_MUL_C_IMME1
   cmp VDECODE[2], 10b      ;Indirect ���
   je M_MUL_C_INDIRECT
   cmp VDECODE[2], 11b      ;Direct ���
   je M_MUL_C_DIRECT
   jmp M_MUL_EXIT         ;M_MUL ����

M_MUL_C_INDIRECT:         ;operand1�� C�̰� INDIRECT���
   cmp VDECODE[8], 1110b   ;operand1�� C�̰� operand2�� X�϶�
   je M_MUL_C_INDIRECT_X
   cmp VDECODE[8], 1111b   ;operand1�� C�̰� operand2�� Y�϶�
   je M_MUL_C_INDIRECT_Y
M_MUL_C_INDIRECT_X:         ;operand1�� C�̰� operand2�� X�϶�
   mov si, X
   mov bx, m[si]
   call M_MUL_C_REG_SOMETHING   ;C�� � ���� �����ϴ� ���ν��� ��
   jmp M_MUL_C_EXIT            ;M_MUL ����
M_MUL_C_INDIRECT_Y:            ;operand1�� C�̰� operand2�� Y�϶�
   mov si, Y
   mov bx, m[si]
   call M_MUL_C_REG_SOMETHING
   jmp M_MUL_C_EXIT            ;M_MUL ����
M_MUL_C_DIRECT:               ;operand1�� C�̰� direct ����� ��
   mov si, VDECODE[10]
   mov bx, m[si]
   call M_MUL_C_REG_SOMETHING
   jmp M_MUL_C_EXIT            ;M_MUL ����
   
               ;�������� �����ذ��� ���� ���� �Ÿ��� ������ �б� 
M_MUL_C_IMME1:
   jmp M_MUL_C_IMME
   
M_MUL_C_REG:               ;operand2�� ���������϶�   
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
   jmp M_MUL_C_EXIT            ;M_MUL ����
   
               ;�������� �����ذ��� ���� ���� �Ÿ��� ������ �б�    
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
   jmp M_MUL_C_EXIT            ;M_MUL ����
M_MUL_C_REG_B:               ;MUL C, B
   mov bx, B
   call M_MUL_C_REG_SOMETHING
   jmp M_MUL_C_EXIT            ;M_MUL ����
M_MUL_C_REG_C:               ;MUL C, C
   mov bx, C
   call M_MUL_C_REG_SOMETHING
   jmp M_MUL_C_EXIT            ;M_MUL ����
M_MUL_C_REG_D:               ;MUL C, D
   mov bx, D
   call M_MUL_C_REG_SOMETHING
   jmp M_MUL_C_EXIT            ;M_MUL ����
M_MUL_C_REG_E:               ;MUL C, E
   mov bx, E
   call M_MUL_C_REG_SOMETHING
   jmp M_MUL_C_EXIT            ;M_MUL ����
M_MUL_C_REG_F:               ;MUL C, F
   mov bx, F
   call M_MUL_C_REG_SOMETHING
   jmp M_MUL_C_EXIT            ;M_MUL ����
M_MUL_C_REG_X:               ;MUL C, X
   mov bx, X
   call M_MUL_C_REG_SOMETHING
   jmp M_MUL_C_EXIT            ;M_MUL ����
M_MUL_C_REG_Y:               ;MUL C, Y
   mov bx, Y
   call M_MUL_C_REG_SOMETHING
   jmp M_MUL_C_EXIT            ;M_MUL ����

M_MUL_C_IMME:      ;operand1�� C�̰� immediate ����� ��
   mov ax, C
   mov bx, VDECODE[10]
   mul bx
   mov C, ax
   
M_MUL_C_EXIT:         ;M_MUL ����
   jmp M_MUL_EXIT
M_MUL_D:            ;operand1�� D�� �� mulressing mode ��
   cmp VDECODE[2], 00b   ;Register ���
   je M_MUL_D_REG
   cmp VDECODE[2], 01b   ;Immediate ���
   je M_MUL_D_IMME1
   cmp VDECODE[2], 10b   ;Indirect ���
   je M_MUL_D_INDIRECT
   cmp VDECODE[2], 11b   ;Direct ���
   je M_MUL_D_DIRECT
   jmp M_MUL_EXIT      ;M_MUL ����

M_MUL_D_INDIRECT:         ;operand1�� D�̰� INDIRECT���
   cmp VDECODE[8], 1110b   ;operand1�� D�̰� operand2�� X�϶�
   je M_MUL_D_INDIRECT_X
   cmp VDECODE[8], 1111b   ;operand1�� D�̰� operand2�� Y�϶�
   je M_MUL_D_INDIRECT_Y
M_MUL_D_INDIRECT_X:         ;operand1�� D�̰� operand2�� X�϶�
   mov si, X
   mov bx, m[si]
   call M_MUL_D_REG_SOMETHING   ;D�� � ���� �����ϴ� ���ν��� ��
   jmp M_MUL_D_EXIT         ;M_MUL ����
M_MUL_D_INDIRECT_Y:         ;operand1�� D�̰� operand2�� Y�϶�
   mov si, Y
   mov bx, m[si]
   call M_MUL_D_REG_SOMETHING
   jmp M_MUL_D_EXIT         ;M_MUL ����
M_MUL_D_DIRECT:            ;operand1�� D�̰� direct ����� ��
   mov si, VDECODE[10]
   mov bx, m[si]
   call M_MUL_D_REG_SOMETHING
   jmp M_MUL_D_EXIT         ;M_MUL ����
   
         ;�������� �����ذ��� ���� ���� �Ÿ��� ������ �б�    
M_MUL_D_IMME1:
   jmp M_MUL_D_IMME   
   
M_MUL_D_REG:            ;operand1�� D�̰� operand2�� ���������϶�   
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
   jmp M_MUL_D_EXIT      ;M_MUL ����
   
         ;�������� �����ذ��� ���� ���� �Ÿ��� ������ �б�    
M_MUL_F4:
   jmp M_MUL_F
M_MUL_X4:
   jmp M_MUL_X
M_MUL_Y4:
   jmp M_MUL_Y
   
M_MUL_D_REG_A:               ;MUL D, A
   mov bx, A
   call M_MUL_D_REG_SOMETHING
   jmp M_MUL_D_EXIT            ;M_MUL ����
M_MUL_D_REG_B:               ;MUL D, B
   mov bx, B
   call M_MUL_D_REG_SOMETHING
   jmp M_MUL_D_EXIT            ;M_MUL ����
M_MUL_D_REG_C:               ;MUL D, C
   mov bx, C
   call M_MUL_D_REG_SOMETHING
   jmp M_MUL_D_EXIT            ;M_MUL ����
M_MUL_D_REG_D:               ;MUL D, D
   mov bx, D
   call M_MUL_D_REG_SOMETHING
   jmp M_MUL_D_EXIT            ;M_MUL ����
M_MUL_D_REG_E:               ;MUL D, E
   mov bx, E
   call M_MUL_D_REG_SOMETHING
   jmp M_MUL_D_EXIT            ;M_MUL ����
M_MUL_D_REG_F:               ;MUL D, F
   mov bx, F
   call M_MUL_D_REG_SOMETHING
   jmp M_MUL_D_EXIT            ;M_MUL ����
M_MUL_D_REG_X:               ;MUL D, X
   mov bx, X
   call M_MUL_D_REG_SOMETHING
   jmp M_MUL_D_EXIT            ;M_MUL ����
M_MUL_D_REG_Y:               ;MUL D, Y
   mov bx, Y
   call M_MUL_D_REG_SOMETHING
   jmp M_MUL_D_EXIT            ;M_MUL ����

M_MUL_D_IMME:            ;operand1�� D�̰� immediate ����� ��
   mov ax, D
   mov bx, VDECODE[10]
   mul bx
   mov D, ax
   
M_MUL_D_EXIT:               ;M_MUL ����
   jmp M_MUL_EXIT
   
M_MUL_E:            ;operand1�� E�� �� mulressing mode ��
   cmp VDECODE[2], 00b      ;Register ���
   je M_MUL_E_REG
   cmp VDECODE[2], 01b      ;Immediate ���
   je M_MUL_E_IMME1
   cmp VDECODE[2], 10b      ;Indirect ���
   je M_MUL_E_INDIRECT
   cmp VDECODE[2], 11b      ;Direct ���
   je M_MUL_E_DIRECT
   jmp M_MUL_EXIT         ;M_MUL ����

M_MUL_E_INDIRECT:         ;operand1�� E�̰� INDIRECT���
   cmp VDECODE[8], 1110b   ;operand1�� E�̰� operand2�� X�϶�
   je M_MUL_E_INDIRECT_X
   cmp VDECODE[8], 1111b   ;operand1�� E�̰� operand2�� Y�϶�
   je M_MUL_E_INDIRECT_Y
M_MUL_E_INDIRECT_X:         ;operand1�� E�̰� operand2�� X�϶�
   mov si, X
   mov bx, m[si]
   call M_MUL_E_REG_SOMETHING   ;E�� � ���� �����ϴ� ���ν��� ��
   jmp M_MUL_E_EXIT            ;M_MUL ����
M_MUL_E_INDIRECT_Y:         ;operand1�� E�̰� operand2�� Y�϶�
   mov si, Y
   mov bx, m[si]
   call M_MUL_E_REG_SOMETHING
   jmp M_MUL_E_EXIT            ;M_MUL ����
M_MUL_E_DIRECT:
   mov si, VDECODE[10]         ;operand1�� E�̰� direct ����� ��
   mov bx, m[si]
   call M_MUL_E_REG_SOMETHING
   jmp M_MUL_E_EXIT            ;M_MUL ����
   
         ;�������� �����ذ��� ���� ���� �Ÿ��� ������ �б�    
M_MUL_E_IMME1:
   jmp M_MUL_E_IMME   
   
M_MUL_E_REG:      ;operand1�� E�̰� operand2�� ���������϶�   
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
   jmp M_MUL_E_EXIT            ;M_MUL ����
   
M_MUL_E_REG_A:               ;MUL E, A
   mov bx, A
   call M_MUL_E_REG_SOMETHING
   jmp M_MUL_E_EXIT            ;M_MUL ����
M_MUL_E_REG_B:               ;MUL E, B
   mov bx, B
   call M_MUL_E_REG_SOMETHING
   jmp M_MUL_E_EXIT            ;M_MUL ����
M_MUL_E_REG_C:               ;MUL E, C
   mov bx, C
   call M_MUL_E_REG_SOMETHING
   jmp M_MUL_E_EXIT            ;M_MUL ����
M_MUL_E_REG_D:               ;MUL E, D
   mov bx, D
   call M_MUL_E_REG_SOMETHING
   jmp M_MUL_E_EXIT            ;M_MUL ����
M_MUL_E_REG_E:               ;MUL E, E
   mov bx, E
   call M_MUL_E_REG_SOMETHING
   jmp M_MUL_E_EXIT            ;M_MUL ����
M_MUL_E_REG_F:               ;MUL E, F
   mov bx, F
   call M_MUL_E_REG_SOMETHING
   jmp M_MUL_E_EXIT            ;M_MUL ����
M_MUL_E_REG_X:               ;MUL E, X
   mov bx, X
   call M_MUL_E_REG_SOMETHING
   jmp M_MUL_E_EXIT            ;M_MUL ����
M_MUL_E_REG_Y:               ;MUL E, Y
   mov bx, Y
   call M_MUL_E_REG_SOMETHING
   jmp M_MUL_E_EXIT            ;M_MUL ����

M_MUL_E_IMME:         ;operand1�� E�̰� immediate ����� ��
   mov ax, E
   mov bx, VDECODE[10]
   mul bx
   mov E, ax
   
M_MUL_E_EXIT:         ;M_MUL ����
   jmp M_MUL_EXIT
   
M_MUL_F:            ;operand1�� F�� �� mulressing mode ��
   cmp VDECODE[2], 00b   ;Register ���
   je M_MUL_F_REG
   cmp VDECODE[2], 01b   ;Immediate ���
   je M_MUL_F_IMME1
   cmp VDECODE[2], 10b   ;Indirect ���
   je M_MUL_F_INDIRECT
   cmp VDECODE[2], 11b   ;Direct ���
   je M_MUL_F_DIRECT
   jmp M_MUL_EXIT      ;M_MUL ����

M_MUL_F_INDIRECT:      ;operand1�� F�̰� INDIRECT���
   cmp VDECODE[8], 1110b   ;operand1�� F�̰� operand2�� X�϶�
   je M_MUL_F_INDIRECT_X
   cmp VDECODE[8], 1111b   ;operand1�� F�̰� operand2�� Y�϶�
   je M_MUL_F_INDIRECT_Y
M_MUL_F_INDIRECT_X:         ;operand1�� F�̰� operand2�� X�϶�
   mov si, X
   mov bx, m[si]
   call M_MUL_F_REG_SOMETHING   ;F�� � ���� �����ϴ� ���ν��� ��
   jmp M_MUL_F_EXIT            ;M_MUL ����
M_MUL_F_INDIRECT_Y:            ;operand1�� F�̰� operand2�� Y�϶�
   mov si, Y
   mov bx, m[si]
   call M_MUL_F_REG_SOMETHING
   jmp M_MUL_F_EXIT            ;M_MUL ����
M_MUL_F_DIRECT:            ;operand1�� F�̰� direct ����� ��
   mov si, VDECODE[10]
   mov bx, m[si]
   call M_MUL_F_REG_SOMETHING
   jmp M_MUL_F_EXIT         ;M_MUL ����
   
         ;�������� �����ذ��� ���� ���� �Ÿ��� ������ �б�    
M_MUL_F_IMME1:
   jmp M_MUL_F_IMME   
   
M_MUL_F_REG:         ;operand1�� F�̰� operand2�� ���������϶�   
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
   jmp M_MUL_F_EXIT         ;M_MUL ����
   
M_MUL_F_REG_A:            ;MUL F, A
   mov bx, A
   call M_MUL_F_REG_SOMETHING
   jmp M_MUL_F_EXIT         ;M_MUL ����
M_MUL_F_REG_B:            ;MUL F, B
   mov bx, B
   call M_MUL_F_REG_SOMETHING
   jmp M_MUL_F_EXIT         ;M_MUL ����
M_MUL_F_REG_C:            ;MUL F, C
   mov bx, C
   call M_MUL_F_REG_SOMETHING
   jmp M_MUL_F_EXIT         ;M_MUL ����
M_MUL_F_REG_D:            ;MUL F, D
   mov bx, D
   call M_MUL_F_REG_SOMETHING
   jmp M_MUL_F_EXIT         ;M_MUL ����
M_MUL_F_REG_E:            ;MUL F, E
   mov bx, E
   call M_MUL_F_REG_SOMETHING
   jmp M_MUL_F_EXIT         ;M_MUL ����
M_MUL_F_REG_F:            ;MUL F, F
   mov bx, F
   call M_MUL_F_REG_SOMETHING
   jmp M_MUL_F_EXIT         ;M_MUL ����
M_MUL_F_REG_X:            ;MUL F, X
   mov bx, X
   call M_MUL_F_REG_SOMETHING
   jmp M_MUL_F_EXIT         ;M_MUL ����
M_MUL_F_REG_Y:            ;MUL F, Y
   mov bx, Y
   call M_MUL_F_REG_SOMETHING
   jmp M_MUL_F_EXIT         ;M_MUL ����

M_MUL_F_IMME:            ;operand1�� F�̰� immediate ����� ��
   mov ax, F
   mov bx, VDECODE[10]
   mul bx
   mov F, ax
   
M_MUL_F_EXIT:               ;M_MUL ����
   jmp M_MUL_EXIT
   
M_MUL_X:            ;operand1�� X�� �� mulressing mode ��
   cmp VDECODE[2], 00b   ;Register ���
   je M_MUL_X_REG
   cmp VDECODE[2], 01b   ;Immediate ���
   je M_MUL_X_IMME1
   cmp VDECODE[2], 10b   ;Indirect ���
   je M_MUL_X_INDIRECT
   cmp VDECODE[2], 11b   ;Direct ���
   je M_MUL_X_DIRECT
   jmp M_MUL_EXIT      ;M_MUL ����

M_MUL_X_INDIRECT:         ;operand1�� X�̰� INDIRECT���
   cmp VDECODE[8], 1110b   ;operand1�� X�̰� operand2�� X�϶�
   je M_MUL_X_INDIRECT_X
   cmp VDECODE[8], 1111b   ;operand1�� X�̰� operand2�� Y�϶�
   je M_MUL_X_INDIRECT_Y
M_MUL_X_INDIRECT_X:         ;operand1�� X�̰� operand2�� X�϶�
   mov si, X
   mov bx, m[si]
   call M_MUL_X_REG_SOMETHING   ;X�� � ���� �����ϴ� ���ν��� ��
   jmp M_MUL_X_EXIT            ;M_MUL ����
M_MUL_X_INDIRECT_Y:            ;operand1�� X�̰� operand2�� Y�϶�
   mov si, Y
   mov bx, m[si]
   call M_MUL_X_REG_SOMETHING
   jmp M_MUL_X_EXIT            ;M_MUL ����
M_MUL_X_DIRECT:               ;operand1�� X�̰� direct ����� ��
   mov si, VDECODE[10]
   mov bx, m[si]
   call M_MUL_X_REG_SOMETHING
   jmp M_MUL_X_EXIT            ;M_MUL ����
   
            ;�������� �����ذ��� ���� ���� �Ÿ��� ������ �б�    
M_MUL_X_IMME1:   
   jmp M_MUL_X_IMME   
   
M_MUL_X_REG:         ;operand1�� X�̰� operand2�� ���������϶�   
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
   jmp M_MUL_X_EXIT         ;M_MUL ����
   
M_MUL_X_REG_A:            ;MUL X, A
   mov bx, A
   call M_MUL_X_REG_SOMETHING
   jmp M_MUL_X_EXIT         ;M_MUL ����
M_MUL_X_REG_B:            ;MUL X, B
   mov bx, B
   call M_MUL_X_REG_SOMETHING
   jmp M_MUL_X_EXIT         ;M_MUL ����
M_MUL_X_REG_C:            ;MUL X, C
   mov bx, C
   call M_MUL_X_REG_SOMETHING
   jmp M_MUL_X_EXIT         ;M_MUL ����
M_MUL_X_REG_D:            ;MUL X, D
   mov bx, D
   call M_MUL_X_REG_SOMETHING
   jmp M_MUL_X_EXIT         ;M_MUL ����
M_MUL_X_REG_E:            ;MUL X, E
   mov bx, E
   call M_MUL_X_REG_SOMETHING
   jmp M_MUL_X_EXIT         ;M_MUL ����
M_MUL_X_REG_F:            ;MUL X, F
   mov bx, F
   call M_MUL_X_REG_SOMETHING
   jmp M_MUL_X_EXIT         ;M_MUL ����
M_MUL_X_REG_X:            ;MUL X, X
   mov bx, X
   call M_MUL_X_REG_SOMETHING
   jmp M_MUL_X_EXIT         ;M_MUL ����
M_MUL_X_REG_Y:            ;MUL X, Y
   mov bx, Y
   call M_MUL_X_REG_SOMETHING
   jmp M_MUL_X_EXIT         ;M_MUL ����

M_MUL_X_IMME:         ;operand1�� X�̰� operand2�� immediate�϶�
   mov ax, X
   mov bx, VDECODE[10]
   mul bx
   mov X, ax
   
M_MUL_X_EXIT:            ;M_MUL ����
   jmp M_MUL_EXIT
   
M_MUL_Y:            ;operand1�� Y�� �� mulressing mode ��
   cmp VDECODE[2], 00b   ;Register ���
   je M_MUL_Y_REG
   cmp VDECODE[2], 01b   ;Immediate ���
   je M_MUL_Y_IMME1
   cmp VDECODE[2], 10b   ;Indirect ���
   je M_MUL_Y_INDIRECT
   cmp VDECODE[2], 11b   ;Direct ���
   je M_MUL_Y_DIRECT
   jmp M_MUL_EXIT      ;M_MUL ����

M_MUL_Y_INDIRECT:         ;operand1�� Y�̰� INDIRECT���
   cmp VDECODE[8], 1110b   ;operand1�� Y�̰� operand2�� X�϶�
   je M_MUL_Y_INDIRECT_X
   cmp VDECODE[8], 1111b   ;operand1�� Y�̰� operand2�� Y�϶�
   je M_MUL_Y_INDIRECT_Y
M_MUL_Y_INDIRECT_X:         ;operand1�� Y�̰� operand2�� X�϶�
   mov si, X
   mov bx, m[si]
   call M_MUL_Y_REG_SOMETHING   ;Y�� � ���� �����ϴ� ���ν��� ��
   jmp M_MUL_Y_EXIT            ;M_MUL ����
M_MUL_Y_INDIRECT_Y:            ;operand1�� Y�̰� operand2�� Y�϶�
   mov si, Y
   mov bx, m[si]
   call M_MUL_Y_REG_SOMETHING
   jmp M_MUL_Y_EXIT            ;M_MUL ����
M_MUL_Y_DIRECT:               ;operand1�� Y�̰� direct ����� ��
   mov si, VDECODE[10]
   mov bx, m[si]
   call M_MUL_Y_REG_SOMETHING
   jmp M_MUL_Y_EXIT            ;M_MUL ����
   
         ;�������� �����ذ��� ���� ���� �Ÿ��� ������ �б� 
M_MUL_Y_IMME1:
   jmp M_MUL_Y_IMME
   
M_MUL_Y_REG:            ;operand1�� Y�̰� operand2�� ���������϶�   
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
   jmp M_MUL_Y_EXIT         ;M_MUL ����
   
M_MUL_Y_REG_A:         ;MUL Y, A
   mov bx, A
   call M_MUL_Y_REG_SOMETHING
   jmp M_MUL_Y_EXIT      ;M_MUL ����
M_MUL_Y_REG_B:         ;MUL Y, B
   mov bx, B
   call M_MUL_Y_REG_SOMETHING
   jmp M_MUL_Y_EXIT      ;M_MUL ����
M_MUL_Y_REG_C:         ;MUL Y, C
   mov bx, C
   call M_MUL_Y_REG_SOMETHING
   jmp M_MUL_Y_EXIT      ;M_MUL ����
M_MUL_Y_REG_D:         ;MUL Y, D
   mov bx, D
   call M_MUL_Y_REG_SOMETHING
   jmp M_MUL_Y_EXIT      ;M_MUL ����
M_MUL_Y_REG_E:         ;MUL Y, E
   mov bx, E
   call M_MUL_Y_REG_SOMETHING
   jmp M_MUL_Y_EXIT      ;M_MUL ����
M_MUL_Y_REG_F:         ;MUL Y, F
   mov bx, F
   call M_MUL_Y_REG_SOMETHING
   jmp M_MUL_Y_EXIT      ;M_MUL ����
M_MUL_Y_REG_X:         ;MUL Y, X
   mov bx, X
   call M_MUL_Y_REG_SOMETHING
   jmp M_MUL_Y_EXIT      ;M_MUL ����
M_MUL_Y_REG_Y:         ;MUL Y, Y
   mov bx, Y
   call M_MUL_Y_REG_SOMETHING
   jmp M_MUL_Y_EXIT      ;M_MUL ����

M_MUL_Y_IMME:         ;operand1�� Y�̰� immediate ����� ��
   mov ax, Y
   mov bx, VDECODE[10]
   mul bx
   mov Y, ax
   
M_MUL_Y_EXIT:            ;M_MUL ����
   jmp M_MUL_EXIT
   
M_MUL_EXIT:               ;M_MUL ����
   RET
M_MUL ENDP

M_MUL_A_REG_SOMETHING PROC      ;A�� � ���� MUL�����ϴ� ���ν���
   mov ax, A
   mul bx
   mov A, ax
   RET
M_MUL_A_REG_SOMETHING ENDP

M_MUL_B_REG_SOMETHING PROC      ;B�� � ���� MUL�����ϴ� ���ν���
   mov ax, B
   mul bx
   mov B, ax
   RET
M_MUL_B_REG_SOMETHING ENDP

M_MUL_C_REG_SOMETHING PROC      ;C�� � ���� MUL�����ϴ� ���ν���
   mov ax, C
   mul bx
   mov C, ax
   RET
M_MUL_C_REG_SOMETHING ENDP

M_MUL_D_REG_SOMETHING PROC      ;D�� � ���� MUL�����ϴ� ���ν���
   mov ax, D
   mul bx
   mov D, ax
   RET
M_MUL_D_REG_SOMETHING ENDP

M_MUL_E_REG_SOMETHING PROC      ;E�� � ���� MUL�����ϴ� ���ν���
   mov ax, E
   mul bx
   mov E, ax
   RET
M_MUL_E_REG_SOMETHING ENDP


M_MUL_F_REG_SOMETHING PROC      ;F�� � ���� MUL�����ϴ� ���ν���
   mov ax, F
   mul bx
   mov F, ax
   RET
M_MUL_F_REG_SOMETHING ENDP

M_MUL_X_REG_SOMETHING PROC      ;X�� � ���� MUL�����ϴ� ���ν���
   mov ax, X
   mul bx
   mov X, ax
   RET
M_MUL_X_REG_SOMETHING ENDP

M_MUL_Y_REG_SOMETHING PROC      ;Y�� � ���� MUL�����ϴ� ���ν���
   mov ax, Y
   mul bx
   mov Y, ax
   RET
M_MUL_Y_REG_SOMETHING ENDP



;------------------------------------------------
;Procedure Name : M_SHIFT
;Function : SHIFT ��ɾ� ����� ����
;PROGRAMED BY ���¿�
;PROGRAM VERSION
;   Creation Date :Nov 28,2016
;   Last Modified On Nov 29 ,2016
;------------------------------------------------
M_SHIFT PROC
   AND VDECODE[6],11b		;VDECODE[6]�� SHL,SHR�� �Ǵ�
   AND VDECODE[4],1111b		;VDECODE[4]�� Register�� �Ǵ�

   CMP VDECODE[6],00b		;VDECODE[6]�� 00b�� ��� SHL
   JE M_SHIFT_LEFT			;
   CMP VDECODE[6],01b		;VDECODE[6]�� 01b�� ��� SHR
   JE M_SHIFT_RIGHT			
					
	M_SHIFT_ERROR:			;�Ѵ� �ƴϸ� �߸��� �� ERROR�޼��� ���
	MOV DX, OFFSET STR_WRONGFUNCTION
	CALL PUTS
	CALL NEWLINE
	JMP M_SHIFT_EXIT
   M_SHIFT_LEFT:			;SHL�� ����
   CMP VDECODE[4],1000b		;VDECODE[4]�� 1000b�ΰ��
   JNE M_SHIFT_LEFT_B		;Register A�� ���� Shift left
   SHL A,1					
   JE M_SHIFT_EXIT_1	
   M_SHIFT_LEFT_B:		
   CMP VDECODE[4],1001b		;VDECODE[4]�� 1001b�ΰ��
   JNE M_SHIFT_LEFT_C		;��Register B�� ���� Shift left
   SHL B,1					
   JE M_SHIFT_EXIT_1		
   M_SHIFT_LEFT_C:			
   CMP VDECODE[4],1010b		;VDECODE[4]�� 1010b�ΰ��
   JNE M_SHIFT_LEFT_D		;Register C�� ���� Shift left
   SHL C,1					
   JE M_SHIFT_EXIT_1		
   M_SHIFT_LEFT_D:			
   CMP VDECODE[4],1011b		;VDECODE[4]�� 1011b�ΰ��
   JNE M_SHIFT_LEFT_E		;Register D�� ���� Shift left
   SHL D,1					
   JE M_SHIFT_EXIT_1		
   M_SHIFT_LEFT_E:			
   CMP VDECODE[4],1100b		;VDECODE[4]�� 1100b�ΰ��
   JNE M_SHIFT_LEFT_F		;Register E�� ���� Shift left
   SHL E,1					
   JE M_SHIFT_EXIT_1		
   M_SHIFT_LEFT_F:			
   CMP VDECODE[4],1101b		;VDECODE[4]�� 1101b�ΰ��
   JNE M_SHIFT_LEFT_X		;Register F�� ���� Shift left
   SHL F,1					
   JE M_SHIFT_EXIT_1		
   M_SHIFT_LEFT_X:			
   CMP VDECODE[4],1110b		;VDECODE[4]�� 1110b�ΰ��
   JNE M_SHIFT_LEFT_Y		;Register X�� ���� Shift left
   SHL X,1					
   JE M_SHIFT_EXIT_1		
   M_SHIFT_LEFT_Y:			
   CMP VDECODE[4],1111b		;VDECODE[4]�� 1111b�ΰ��
   JNE M_SHIFT_EXIT			;Register Y�� ���� Shift left
   SHL Y,1					
   JE M_SHIFT_EXIT_1		
   M_SHIFT_EXIT_1:			
   JMP M_SHIFT_EXIT			

   M_SHIFT_RIGHT:			;SHL�� ����
   CMP VDECODE[4],1000b		;DECODE[4]�� 1000b�ΰ��
   JNE M_SHIFT_RIGHT_B		;Register A�� ���� Shift Right
   SHR A,1					
   JE M_SHIFT_EXIT			
   M_SHIFT_RIGHT_B:			
   CMP VDECODE[4],1001b		;VDECODE[4]�� 1001b�ΰ��
   JNE M_SHIFT_RIGHT_C		;Register B�� ���� Shift Right
   SHR B,1					
   JE M_SHIFT_EXIT			
   M_SHIFT_RIGHT_C:			
   CMP VDECODE[4],1010b		;VDECODE[4]�� 1010b�ΰ��
   JNE M_SHIFT_RIGHT_D		;Register C�� ���� Shift Right
   SHR C,1					
   JE M_SHIFT_EXIT			
   M_SHIFT_RIGHT_D:			
   CMP VDECODE[4],1011b		;VDECODE[4]�� 1011b�ΰ��
   JNE M_SHIFT_RIGHT_E		;Register D�� ���� Shift Right
   SHR D,1					
   JE M_SHIFT_EXIT			
   M_SHIFT_RIGHT_E:			
   CMP VDECODE[4],1100b		;VDECODE[4]�� 1100b�ΰ��
   JNE M_SHIFT_RIGHT_F		;Register E�� ���� Shift Right
   SHR E,1					
   JE M_SHIFT_EXIT			
   M_SHIFT_RIGHT_F:			
   CMP VDECODE[4],1101b		;VDECODE[4]�� 1101b�ΰ��
   JNE M_SHIFT_RIGHT_X		;Register F�� ���� Shift Right
   SHR F,1					
   JE M_SHIFT_EXIT			
   M_SHIFT_RIGHT_X:			
   CMP VDECODE[4],1110b		;VDECODE[4]�� 1110b�ΰ��
   JNE M_SHIFT_RIGHT_Y		;Register X�� ���� Shift Right
   SHR X,1					
   JE M_SHIFT_EXIT		
   M_SHIFT_RIGHT_Y:			
   CMP VDECODE[4],1111b		;VDECODE[4]�� 1111b�ΰ��
   JNE M_SHIFT_EXIT			;Register Y�� ���� Shift Right
   SHR Y,1				
   JE M_SHIFT_EXIT		

   M_SHIFT_EXIT:			;SHIFT�Լ� ����
   RET						
M_SHIFT ENDP

;------------------------------------------------
;Procedure Name : M_DIV
;Function : DIV ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 28,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
M_DIV PROC
   CMP VDECODE[4],1000b ; OPERAND1�� A�� ��
   JE M_DIV_A
   CMP VDECODE[4],1001b ; OPERAND1�� B�� ��
   JE M_DIV_B
   CMP VDECODE[4],1010b ; OPERAND1�� C�� ��
   JE M_DIV_C           
   CMP VDECODE[4],1011b ; OPERAND1�� D�� ��
   JE M_DIV_D
   CMP VDECODE[4],1100b ; OPERAND1�� E�� ��
   JE M_DIV_E
   CMP VDECODE[4],1101b ; OPERAND1�� F�� ��
   JE M_DIV_F
   CMP VDECODE[4],1110b ; OPERAND1�� X�� ��
   JE M_DIV_X
   CMP VDECODE[4],1111b ; OPERAND1�� Y�� ��
   JE M_DIV_Y

   PRINT ERR
   JMP END_M_DIV

M_DIV_A:
   CALL DIV_A_P			; DIV_A_P ȣ��
   JMP END_M_DIV
M_DIV_B:
   CALL DIV_B_P			; DIV_B_P ȣ��
   JMP END_M_DIV
M_DIV_C:
   CALL DIV_C_P			; DIV_C_P ȣ��
   JMP END_M_DIV
M_DIV_D:
   CALL DIV_D_P			; DIV_D_P ȣ��
   JMP END_M_DIV
M_DIV_E:
   CALL DIV_E_P			; DIV_E_P ȣ��
   JMP END_M_DIV
M_DIV_F:
   CALL DIV_F_P			; DIV_F_P ȣ��
   JMP END_M_DIV
M_DIV_X:
   CALL DIV_X_P			; DIV_X_P ȣ��
   JMP END_M_DIV
M_DIV_Y:
   CALL DIV_Y_P			; DIV_Y_P ȣ��
   JMP END_M_DIV

END_M_DIV:
   RET
M_DIV ENDP

;------------------------------------------------
;Procedure Name : DIV_A_P
;Function : DIV A, ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 28,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
DIV_A_P PROC

   MOV AX, VDECODE[2]
   AND AX,11b
   MOV VDECODE[2],AX
                              ; DIV A,
   CMP VDECODE[2],00b			; REGISTER ���
   JE DIV_A_REGI
   CMP VDECODE[2],01b			; IMMEDIATE ���
   JE DIV_A_IMME
   CMP VDECODE[2],10b			; REGISTER-INDIRECT ���
   JE DIV_A_REGI_IMME
   CMP VDECODE[2],11b			; DIRECT ���
   JE DIV_A_DI

   PRINT ERR
   JMP END_M_DIV_A_P

DIV_A_REGI:
   CALL DIV_A_REGI_P		; DIV_A_REGI_P ȣ��
   JMP END_M_DIV_A_P
DIV_A_IMME:
   CALL DIV_A_IMME_P		; DIV_A_IMME_P ȣ��
   JMP END_M_DIV_A_P
DIV_A_REGI_IMME:
   CALL DIV_A_REGI_IMME_P		; DIV_A_REGI_IMME_P ȣ��
   JMP END_M_DIV_A_P
DIV_A_DI:
   CALL DIV_A_DI_P		; DIV_A_DI_P ȣ��
   JMP END_M_DIV_A_P

END_M_DIV_A_P:
   RET
DIV_A_P ENDP

;------------------------------------------------
;Procedure Name : DIV_A_REGI_P
;Function : DIV A, �������� ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 28,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
DIV_A_REGI_P PROC
   MOV AX,VDECODE[8]                         ; DIV A,REGISTER
   AND AX,1111b
   MOV VDECODE[8],AX

   CMP VDECODE[8],1000b		; OPERAND2 �� A
   JE DIV_A_A
   CMP VDECODE[8],1001b		; OPERAND2 �� B
   JE DIV_A_B
   CMP VDECODE[8],1010b		; OPERAND2 �� C
   JE DIV_A_C
   CMP VDECODE[8],1011b		; OPERAND2 �� D
   JE DIV_A_D
   CMP VDECODE[8],1100b		; OPERAND2 �� E
   JE DIV_A_E
   CMP VDECODE[8],1101b		; OPERAND2 �� F
   JE DIV_A_F
   CMP VDECODE[8],1110b		; OPERAND2 �� X
   JE DIV_A_X
   CMP VDECODE[8],1111b		; OPERAND2 �� Y
   JE DIV_A_Y

   PRINT ERR
   JMP END_M_DIV_A_REGI_P

DIV_A_A:
   MOV BX,A					; BX�� A���� ����
	MOV AX,A				; AX�� A���� ����
	DIV BL					; BL������ A���� DIV
   CALL SHR_F				; E,F �������Ϳ� ���� ��,�������� ����
   JMP END_M_DIV_A_REGI_P
DIV_A_B:
	MOV BX,B					; BX�� B���� ����
	MOV AX,A					; BX�� A���� ����
	DIV BL					; BL������ A���� DIV
	CALL SHR_F				; E,F �������Ϳ� ���� ��,�������� ����
   JMP END_M_DIV_A_REGI_P
DIV_A_C:
   MOV BX,C					; BX�� C���� ����
	MOV AX,A					; BX�� A���� ����
	DIV BL					; BL������ A���� DIV
   CALL SHR_F				; E,F �������Ϳ� ���� ��,�������� ����
   JMP END_M_DIV_A_REGI_P
DIV_A_D:
   MOV BX,D					; BX�� D���� ����
	MOV AX,A					; BX�� A���� ����
	DIV BL					; BL������ A���� DIV
   CALL SHR_F				; E,F �������Ϳ� ���� ��,�������� ����
   JMP END_M_DIV_A_REGI_P
DIV_A_E:
   MOV BX,E					; BX�� E���� ����
	MOV AX,A					; BX�� A���� ����
	DIV BL					; BL������ A���� DIV
   CALL SHR_F				; E,F �������Ϳ� ���� ��,�������� ����
   JMP END_M_DIV_A_REGI_P
DIV_A_F:
   MOV BX,F					; BX�� F���� ����
	MOV AX,A					; BX�� A���� ����
	DIV BL					; BL������ A���� DIV
   CALL SHR_F				; E,F �������Ϳ� ���� ��,�������� ����
   JMP END_M_DIV_A_REGI_P
DIV_A_X:
   MOV BX,X					; BX�� X���� ����
	MOV AX,A					; BX�� A���� ����
	DIV BL					; BL������ A���� DIV
   CALL SHR_F				; E,F �������Ϳ� ���� ��,�������� ����
   JMP END_M_DIV_A_REGI_P
DIV_A_Y:
   MOV BX,Y					; BX�� Y���� ����
	MOV AX,A					; BX�� A���� ����
	DIV BL					; BL������ A���� DIV
   CALL SHR_F				; E,F �������Ϳ� ���� ��,�������� ����
   JMP END_M_DIV_A_REGI_P
   
   PRINT ERR
   JMP END_M_DIV_A_REGI_P

END_M_DIV_A_REGI_P:
   RET
DIV_A_REGI_P ENDP

;------------------------------------------------
;Procedure Name : DIV_A_IMME_P
;Function : DIV A, IMMEDIATE ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 28,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
DIV_A_IMME_P PROC                   ; DIV A,IMMEDIATE
   MOV DX,VDECODE[10]				; A�� ���� VDECODE[10]�� ����Ǿ��ִ� IMMEDIATE������ DIV
   MOV AX,A
   DIV DL
   CALL SHR_F						; E,F �������Ϳ� ���� ��,�������� ����			
   RET
DIV_A_IMME_P ENDP

;------------------------------------------------
;Procedure Name : DIV_A_REGI_IMME_P
;Function : DIV A, REGISTER-IMMEDIATE ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 28,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
DIV_A_REGI_IMME_P PROC                  ; DIV A,REGISTER_IMMEDIATE
   CMP VDECODE[8],1110					; OPERAND2 ���� X
   JE DIV_A_R_I_X
   CMP VDECODE[8],1111					; OPERAND2 ���� Y
   JE DIV_A_R_I_Y
   
DIV_A_R_I_X:
   MOV SI,X								; X�� ���� SI�� ����
   MOV DX,M[SI]							; M[SI]�� ���� DX�� ����
   MOV AX,A								
   DIV DL								; A�� ���� DX������ DIV
   CALL SHR_F						; E,F �������Ϳ� ���� ��,�������� ����
   JMP END_M_DIV_A_REGI_IMME_P
DIV_A_R_I_Y:
   MOV SI,Y								; Y�� ���� SI�� ����
   MOV DX,M[SI]							; M[SI]�� ���� DX�� ����
   MOV AX,A
   DIV DL								; A�� ���� DX������ DIV
   CALL SHR_F						; E,F �������Ϳ� ���� ��,�������� ����

END_M_DIV_A_REGI_IMME_P:
   RET
DIV_A_REGI_IMME_P ENDP

;------------------------------------------------
;Procedure Name : DIV_A_DI_P
;Function : DIV A, DIRECT ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 28,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
DIV_A_DI_P PROC                     ; DIV A,DIRECT
   MOV SI,VDECODE[10]				; VDECODE[10]�� ����Ǿ��ִ� �ּҰ��� SI�� ����   
   MOV DX,M[SI]						; M[SI]���� DX�� ����
   MOV AX,A
   DIV DL							; A�� ���� DX�� DIV
   CALL SHR_F						; E,F �������Ϳ� ���� ��,�������� ����				
   RET
DIV_A_DI_P ENDP

;------------------------------------------------
;Procedure Name : DIV_B_P
;Function : DIV B, ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 28,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
DIV_B_P PROC

   MOV AX, VDECODE[2]
   AND AX,11b
   MOV VDECODE[2],AX
                              ; DIV B,
   CMP VDECODE[2],00b			; REGISTER ���
   JE DIV_B_REGI
   CMP VDECODE[2],01b			; IMMEDIATE ���
   JE DIV_B_IMME
   CMP VDECODE[2],10b			; REGISTER-INDIRECT ���
   JE DIV_B_REGI_IMME
   CMP VDECODE[2],11b			; DIRECT ���
   JE DIV_B_DI

   PRINT ERR
   JMP END_M_DIV_B_P

DIV_B_REGI:
   CALL DIV_B_REGI_P		; DIV_B_REGI_P ȣ��
   JMP END_M_DIV_B_P
DIV_B_IMME:
   CALL DIV_B_IMME_P		; DIV_B_IMME_P ȣ��
   JMP END_M_DIV_B_P
DIV_B_REGI_IMME:
   CALL DIV_B_REGI_IMME_P		; DIV_B_REGI_IMME_P ȣ��
   JMP END_M_DIV_B_P
DIV_B_DI:
   CALL DIV_B_DI_P		; DIV_B_DI_P ȣ��
   JMP END_M_DIV_B_P

END_M_DIV_B_P:
   RET
DIV_B_P ENDP

;------------------------------------------------
;Procedure Name : DIV_B_REGI_P
;Function : DIV B, �������� ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 28,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
DIV_B_REGI_P PROC
   MOV AX,VDECODE[8]                         ; DIV B,REGISTER
   AND AX,1111b
   MOV VDECODE[8],AX

   CMP VDECODE[8],1000b		; OPERAND2 �� A
   JE DIV_B_A
   CMP VDECODE[8],1001b		; OPERAND2 �� B
   JE DIV_B_B
   CMP VDECODE[8],1010b		; OPERAND2 �� C
   JE DIV_B_C
   CMP VDECODE[8],1011b		; OPERAND2 �� D
   JE DIV_B_D
   CMP VDECODE[8],1100b		; OPERAND2 �� E
   JE DIV_B_E
   CMP VDECODE[8],1101b		; OPERAND2 �� F
   JE DIV_B_F
   CMP VDECODE[8],1110b		; OPERAND2 �� X
   JE DIV_B_X
   CMP VDECODE[8],1111b		; OPERAND2 �� Y
   JE DIV_B_Y

   PRINT ERR
   JMP END_M_DIV_B_REGI_P

DIV_B_A:
	MOV BX,A				; BX�� A���� ����
	MOV AX,B				; AX�� B���� ����
	DIV BL					; BL������ B���� DIV
   CALL SHR_F				; E,F �������Ϳ� ���� ��,�������� ����
   JMP END_M_DIV_B_REGI_P
DIV_B_B:
	MOV BX,B				; BX�� B���� ����
	MOV AX,B				; AX�� B���� ����
	DIV BL					; BL������ B���� DIV
	CALL SHR_F				; E,F �������Ϳ� ���� ��,�������� ����
   JMP END_M_DIV_B_REGI_P
DIV_B_C:
   MOV BX,C					; BX�� C���� ����
	MOV AX,B				; AX�� B���� ����
	DIV BL					; BL������ B���� DIV
   CALL SHR_F				; E,F �������Ϳ� ���� ��,�������� ����
   JMP END_M_DIV_B_REGI_P
DIV_B_D:
   MOV BX,D					; BX�� D���� ����
	MOV AX,B				; AX�� B���� ����
	DIV BL					; BL������ B���� DIV
   CALL SHR_F				; E,F �������Ϳ� ���� ��,�������� ����
   JMP END_M_DIV_B_REGI_P
DIV_B_E:
   MOV BX,E					; BX�� E���� ����
	MOV AX,B				; AX�� B���� ����
	DIV BL					; BL������ B���� DIV
   CALL SHR_F				; E,F �������Ϳ� ���� ��,�������� ����
   JMP END_M_DIV_B_REGI_P
DIV_B_F:
   MOV BX,F					; BX�� F���� ����
	MOV AX,B				; AX�� B���� ����
	DIV BL					; BL������ B���� DIV
   CALL SHR_F				; E,F �������Ϳ� ���� ��,�������� ����
   JMP END_M_DIV_B_REGI_P
DIV_B_X:
   MOV BX,X					; BX�� X���� ����
	MOV AX,B				; AX�� B���� ����
	DIV BL					; BL������ B���� DIV
   CALL SHR_F				; E,F �������Ϳ� ���� ��,�������� ����
   JMP END_M_DIV_B_REGI_P
DIV_B_Y:
   MOV BX,Y					; BX�� X���� ����
	MOV AX,B				; AX�� B���� ����
	DIV BL					; BL������ B���� DIV
   CALL SHR_F				; E,F �������Ϳ� ���� ��,�������� ����
   JMP END_M_DIV_B_REGI_P
   
   PRINT ERR
   JMP END_M_DIV_B_REGI_P

END_M_DIV_B_REGI_P:
   RET
DIV_B_REGI_P ENDP

;------------------------------------------------
;Procedure Name : DIV_B_IMME_P
;Function : DIV B, IMMEDIATE ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 28,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
DIV_B_IMME_P PROC                   ; DIV B,IMMEDIATE
   MOV DX,VDECODE[10]				; D�� ���� VDECODE[10]�� ����Ǿ��ִ� IMMEDIATE������ DIV
   MOV AX,B
   DIV DL
   CALL SHR_F						; E,F �������Ϳ� ���� ��,�������� ����			
   RET
DIV_B_IMME_P ENDP

;------------------------------------------------
;Procedure Name : DIV_B_REGI_IMME_P
;Function : DIV B, REGISTER-IMMEDIATE ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 28,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
DIV_B_REGI_IMME_P PROC                 ; DIV B,REGISTER_IMMEDIATE
   CMP VDECODE[8],1110					; OPERAND2 ���� X
   JE DIV_B_R_I_X
   CMP VDECODE[8],1111					; OPERAND2 ���� Y
   JE DIV_B_R_I_Y
   
DIV_B_R_I_X:
   MOV SI,X								; X�� ���� SI�� ����
   MOV DX,M[SI]							; M[SI]�� ���� DX�� ����
   MOV AX,B
   DIV DL								; B�� ���� DX������ DIV
   CALL SHR_F						; E,F �������Ϳ� ���� ��,�������� ����
   JMP END_M_DIV_B_REGI_IMME_P
DIV_B_R_I_Y:
   MOV SI,Y								; Y�� ���� SI�� ����
   MOV DX,M[SI]							; M[SI]�� ���� DX�� ����
   MOV AX,B
   DIV DL								; B�� ���� DX������ DIV
   CALL SHR_F						; E,F �������Ϳ� ���� ��,�������� ����

END_M_DIV_B_REGI_IMME_P:
   RET
DIV_B_REGI_IMME_P ENDP

;------------------------------------------------
;Procedure Name : DIV_B_DI_P
;Function : DIV B, DIRECT ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 28,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
DIV_B_DI_P PROC                     ; DIV B,DIRECT
   MOV SI,VDECODE[10]  				; VDECODE[10]�� ����Ǿ��ִ� �ּҰ��� SI�� ���� 
   MOV DX,M[SI]						; M[SI]���� DX�� ����
   MOV AX,B
   DIV DL							; B�� ���� DX�� DIV
   CALL SHR_F						; E,F �������Ϳ� ���� ��,�������� ����	
   RET
DIV_B_DI_P ENDP

;------------------------------------------------
;Procedure Name : DIV_C_P
;Function : DIV C, ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 28,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
DIV_C_P PROC

   MOV AX, VDECODE[2]
   AND AX,11b
   MOV VDECODE[2],AX
                              ; DIV C,
   CMP VDECODE[2],00b			; REGISTER ���
   JE DIV_C_REGI
   CMP VDECODE[2],01b			; IMMEDIATE ���
   JE DIV_C_IMME
   CMP VDECODE[2],10b			; REGISTER-INDIRECT ���
   JE DIV_C_REGI_IMME
   CMP VDECODE[2],11b			; DIRECT ���
   JE DIV_C_DI

   PRINT ERR
   JMP END_M_DIV_C_P

DIV_C_REGI:
   CALL DIV_C_REGI_P		; DIV_C_REGI_P ȣ��
   JMP END_M_DIV_C_P
DIV_C_IMME:
   CALL DIV_C_IMME_P		; DIV_C_IMME_P ȣ��
   JMP END_M_DIV_C_P
DIV_C_REGI_IMME:
   CALL DIV_C_REGI_IMME_P		; DIV_C_REGI_IMME_P ȣ��
   JMP END_M_DIV_C_P
DIV_C_DI:
   CALL DIV_C_DI_P		; DIV_C_DI_P ȣ��
   JMP END_M_DIV_C_P

END_M_DIV_C_P:
   RET
DIV_C_P ENDP

;------------------------------------------------
;Procedure Name : DIV_C_REGI_P
;Function : DIV C, �������� ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 28,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
DIV_C_REGI_P PROC
   MOV AX,VDECODE[8]                         ; DIV C,REGISTER
   AND AX,1111b
   MOV VDECODE[8],AX

   CMP VDECODE[8],1000b		; OPERAND2 �� A
   JE DIV_C_A
   CMP VDECODE[8],1001b		; OPERAND2 �� B
   JE DIV_C_B
   CMP VDECODE[8],1010b		; OPERAND2 �� C
   JE DIV_C_C
   CMP VDECODE[8],1011b		; OPERAND2 �� D
   JE DIV_C_D
   CMP VDECODE[8],1100b		; OPERAND2 �� E
   JE DIV_C_E
   CMP VDECODE[8],1101b		; OPERAND2 �� F
   JE DIV_C_F
   CMP VDECODE[8],1110b		; OPERAND2 �� X
   JE DIV_C_X
   CMP VDECODE[8],1111b		; OPERAND2 �� Y
   JE DIV_C_Y

   PRINT ERR
   JMP END_M_DIV_C_REGI_P

DIV_C_A:
	MOV BX,A				; BX�� A���� ����
	MOV AX,C				; AX�� C���� ����
	DIV BL					; BL������ C���� DIV
   CALL SHR_F				; E,F �������Ϳ� ���� ��,�������� ����
   JMP END_M_DIV_C_REGI_P
DIV_C_B:
	MOV BX,B				; BX�� B���� ����
	MOV AX,C				; AX�� C���� ����
	DIV BL					; BL������ C���� DIV
	CALL SHR_F				; E,F �������Ϳ� ���� ��,�������� ����
   JMP END_M_DIV_C_REGI_P
DIV_C_C:
   MOV BX,C				; BX�� C���� ����
	MOV AX,C				; AX�� C���� ����
	DIV BL					; BL������ C���� DIV
   CALL SHR_F				; E,F �������Ϳ� ���� ��,�������� ����
   JMP END_M_DIV_C_REGI_P
DIV_C_D:
   MOV BX,D				; BX�� D���� ����
	MOV AX,C				; AX�� C���� ����
	DIV BL					; BL������ C���� DIV
   CALL SHR_F				; E,F �������Ϳ� ���� ��,�������� ����
   JMP END_M_DIV_C_REGI_P
DIV_C_E:
   MOV BX,E				; BX�� E���� ����
	MOV AX,C				; AX�� C���� ����
	DIV BL					; BL������ C���� DIV
   CALL SHR_F				; E,F �������Ϳ� ���� ��,�������� ����
   JMP END_M_DIV_C_REGI_P
DIV_C_F:
   MOV BX,F				; BX�� F���� ����
	MOV AX,C				; AX�� C���� ����
	DIV BL					; BL������ C���� DIV
   CALL SHR_F				; E,F �������Ϳ� ���� ��,�������� ����
   JMP END_M_DIV_C_REGI_P
DIV_C_X:
   MOV BX,X				; BX�� X���� ����
	MOV AX,C				; AX�� C���� ����
	DIV BL					; BL������ C���� DIV
   CALL SHR_F				; E,F �������Ϳ� ���� ��,�������� ����
   JMP END_M_DIV_C_REGI_P
DIV_C_Y:
   MOV BX,Y				; BX�� Y���� ����
	MOV AX,C				; AX�� C���� ����
	DIV BL					; BL������ C���� DIV
   CALL SHR_F				; E,F �������Ϳ� ���� ��,�������� ����
   JMP END_M_DIV_C_REGI_P
   
   PRINT ERR
   JMP END_M_DIV_C_REGI_P

END_M_DIV_C_REGI_P:
   RET
DIV_C_REGI_P ENDP

;------------------------------------------------
;Procedure Name : DIV_C_IMME_P
;Function : DIV C, IMMEDIATE ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 28,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
DIV_C_IMME_P PROC                   ; DIV C,IMMEDIATE
   MOV DX,VDECODE[10]				; D�� ���� VDECODE[10]�� ����Ǿ��ִ� IMMEDIATE������ DIV
   MOV AX,C
   DIV DL
   CALL SHR_F						; E,F �������Ϳ� ���� ��,�������� ����
   RET
DIV_C_IMME_P ENDP

;------------------------------------------------
;Procedure Name : DIV_C_REGI_IMME_P
;Function : DIV C, REGISTER-IMMEDIATE ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 28,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
DIV_C_REGI_IMME_P PROC                 ; DIV C,REGISTER_IMMEDIATE
   CMP VDECODE[8],1110					; OPERAND2 ���� X
   JE DIV_C_R_I_X
   CMP VDECODE[8],1111					; OPERAND2 ���� Y
   JE DIV_C_R_I_Y
   
DIV_C_R_I_X:
   MOV SI,X								; X�� ���� SI�� ����
   MOV DX,M[SI]							; M[SI]�� ���� DX�� ����
   MOV AX,C
   DIV DL								; C�� ���� DX������ DIV
   CALL SHR_F						; E,F �������Ϳ� ���� ��,�������� ����
   JMP END_M_DIV_C_REGI_IMME_P
DIV_C_R_I_Y:
   MOV SI,Y								; Y�� ���� SI�� ����
   MOV DX,M[SI]							; M[SI]�� ���� DX�� ����
   MOV AX,C
   DIV DL								; C�� ���� DX������ DIV
   CALL SHR_F						; E,F �������Ϳ� ���� ��,�������� ����

END_M_DIV_C_REGI_IMME_P:
   RET
DIV_C_REGI_IMME_P ENDP

;------------------------------------------------
;Procedure Name : DIV_C_DI_P
;Function : DIV C, DIRECT ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 28,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
DIV_C_DI_P PROC                     ; DIV C,DIRECT
   MOV SI,VDECODE[10]    			; VDECODE[10]�� ����Ǿ��ִ� �ּҰ��� SI�� ����  
   MOV DX,M[SI]						; M[SI]���� DX�� ����
   MOV AX,C
   DIV DL							; C�� ���� DX�� DIV
   CALL SHR_F
   RET
DIV_C_DI_P ENDP

;------------------------------------------------
;Procedure Name : DIV_D_P
;Function : DIV D, ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 28,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
DIV_D_P PROC

   MOV AX, VDECODE[2]
   AND AX,11b
   MOV VDECODE[2],AX
                              ; DIV D,
   CMP VDECODE[2],00b			; REGISTER ���
   JE DIV_D_REGI
   CMP VDECODE[2],01b			; IMMEDIATE ���
   JE DIV_D_IMME
   CMP VDECODE[2],10b			; REGISTER-INDIRECT ���
   JE DIV_D_REGI_IMME
   CMP VDECODE[2],11b			; DIRECT ���
   JE DIV_D_DI

   PRINT ERR
   JMP END_M_DIV_D_P

DIV_D_REGI:
   CALL DIV_D_REGI_P		; DIV_D_REGI_P ȣ��
   JMP END_M_DIV_D_P
DIV_D_IMME:
   CALL DIV_D_IMME_P		; DIV_D_IMME_P ȣ��
   JMP END_M_DIV_D_P
DIV_D_REGI_IMME:
   CALL DIV_D_REGI_IMME_P		; DIV_D_REGI_IMME_P ȣ��
   JMP END_M_DIV_D_P
DIV_D_DI:
   CALL DIV_D_DI_P		; DIV_D_DI_P ȣ��
   JMP END_M_DIV_D_P

END_M_DIV_D_P:
   RET
DIV_D_P ENDP


;------------------------------------------------
;Procedure Name : DIV_D_REGI_P
;Function : DIV D, �������� ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 28,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
DIV_D_REGI_P PROC
   MOV AX,VDECODE[8]                         ; DIV D,REGISTER
   AND AX,1111b
   MOV VDECODE[8],AX

   CMP VDECODE[8],1000b		; OPERAND2 �� A
   JE DIV_D_A
   CMP VDECODE[8],1001b		; OPERAND2 �� B
   JE DIV_D_B
   CMP VDECODE[8],1010b		; OPERAND2 �� C
   JE DIV_D_C
   CMP VDECODE[8],1011b		; OPERAND2 �� D
   JE DIV_D_D
   CMP VDECODE[8],1100b		; OPERAND2 �� E
   JE DIV_D_E
   CMP VDECODE[8],1101b		; OPERAND2 �� F
   JE DIV_D_F
   CMP VDECODE[8],1110b		; OPERAND2 �� X
   JE DIV_D_X
   CMP VDECODE[8],1111b		; OPERAND2 �� Y
   JE DIV_D_Y

   PRINT ERR
   JMP END_M_DIV_D_REGI_P

DIV_D_A:
	MOV BX,A				; BX�� A���� ����
	MOV AX,D				; AX�� D���� ����
	DIV BL					; BL������ D���� DIV
   CALL SHR_F				; E,F �������Ϳ� ���� ��,�������� ����
   JMP END_M_DIV_D_REGI_P
DIV_D_B:
	MOV BX,B				; BX�� B���� ����
	MOV AX,D				; AX�� D���� ����
	DIV BL					; BL������ D���� DIV
	CALL SHR_F				; E,F �������Ϳ� ���� ��,�������� ����
   JMP END_M_DIV_D_REGI_P
DIV_D_C:
   MOV BX,C				; BX�� C���� ����
	MOV AX,D				; AX�� D���� ����
	DIV BL					; BL������ D���� DIV
   CALL SHR_F				; E,F �������Ϳ� ���� ��,�������� ����
   JMP END_M_DIV_D_REGI_P
DIV_D_D:
   MOV BX,D				; BX�� D���� ����
	MOV AX,D				; AX�� D���� ����
	DIV BL					; BL������ D���� DIV
   CALL SHR_F				; E,F �������Ϳ� ���� ��,�������� ����
   JMP END_M_DIV_D_REGI_P
DIV_D_E:
   MOV BX,E				; BX�� E���� ����
	MOV AX,D				; AX�� D���� ����
	DIV BL					; BL������ D���� DIV
   CALL SHR_F				; E,F �������Ϳ� ���� ��,�������� ����
   JMP END_M_DIV_D_REGI_P
DIV_D_F:
   MOV BX,F				; BX�� F���� ����
	MOV AX,D				; AX�� D���� ����
	DIV BL					; BL������ D���� DIV
   CALL SHR_F				; E,F �������Ϳ� ���� ��,�������� ����
   JMP END_M_DIV_D_REGI_P
DIV_D_X:
   MOV BX,X				; BX�� X���� ����
	MOV AX,D				; AX�� D���� ����
	DIV BL					; BL������ D���� DIV
   CALL SHR_F				; E,F �������Ϳ� ���� ��,�������� ����
   JMP END_M_DIV_D_REGI_P
DIV_D_Y:
   MOV BX,Y				; BX�� Y���� ����
	MOV AX,D				; AX�� D���� ����
	DIV BL					; BL������ D���� DIV
   CALL SHR_F				; E,F �������Ϳ� ���� ��,�������� ����
   JMP END_M_DIV_D_REGI_P
   
   PRINT ERR
   JMP END_M_DIV_D_REGI_P

END_M_DIV_D_REGI_P:
   RET
DIV_D_REGI_P ENDP

;------------------------------------------------
;Procedure Name : DIV_D_IMME_P
;Function : DIV D, IMMEDIATE ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 28,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
DIV_D_IMME_P PROC                   ; DIV D,IMMEDIATE
   MOV DX,VDECODE[10]				; D�� ���� VDECODE[10]�� ����Ǿ��ִ� IMMEDIATE������ DIV
   MOV AX,D
   DIV DL
   CALL SHR_F						; E,F �������Ϳ� ���� ��,�������� ����
   RET
DIV_D_IMME_P ENDP

;------------------------------------------------
;Procedure Name : DIV_D_REGI_IMME_P
;Function : DIV D, REGISTER-IMMEDIATE ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 28,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
DIV_D_REGI_IMME_P PROC                 ; DIV D,REGISTER_IMMEDIATE
   CMP VDECODE[8],1110					; OPERAND2 ���� X
   JE DIV_D_R_I_X
   CMP VDECODE[8],1111					; OPERAND2 ���� Y
   JE DIV_D_R_I_Y
   
DIV_D_R_I_X:
   MOV SI,X								; X�� ���� SI�� ����
   MOV DX,M[SI]							; M[SI]�� ���� DX�� ����
   MOV AX,D
   DIV DL								; D�� ���� DX������ DIV
   CALL SHR_F						; E,F �������Ϳ� ���� ��,�������� ����
   JMP END_M_DIV_D_REGI_IMME_P
DIV_D_R_I_Y:
   MOV SI,Y								; Y�� ���� SI�� ����
   MOV DX,M[SI]							; M[SI]�� ���� DX�� ����
   MOV AX,D
   DIV DL								; D�� ���� DX������ DIV
   CALL SHR_F						; E,F �������Ϳ� ���� ��,�������� ����

END_M_DIV_D_REGI_IMME_P:
   RET
DIV_D_REGI_IMME_P ENDP

;------------------------------------------------
;Procedure Name : DIV_D_DI_P
;Function : DIV D, DIRECT ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 28,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
DIV_D_DI_P PROC                     ; DIV D,DIRECT
   MOV SI,VDECODE[10]    			; VDECODE[10]�� ����Ǿ��ִ� �ּҰ��� SI�� ����   
   MOV DX,M[SI]						; M[SI]���� DX�� ����
   MOV AX,D
   DIV DL							; D�� ���� DX�� DIV
   CALL SHR_F
   RET
DIV_D_DI_P ENDP

;------------------------------------------------
;Procedure Name : DIV_E_P
;Function : DIV E, ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 28,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
DIV_E_P PROC

   MOV AX, VDECODE[2]
   AND AX,11b
   MOV VDECODE[2],AX
                              ; DIV E,
   CMP VDECODE[2],00b			; REGISTER ���
   JE DIV_E_REGI
   CMP VDECODE[2],01b			; IMMEDIATE ���
   JE DIV_E_IMME
   CMP VDECODE[2],10b			; REGISTER-INDIRECT ���
   JE DIV_E_REGI_IMME
   CMP VDECODE[2],11b			; DIRECT ���
   JE DIV_E_DI

   PRINT ERR
   JMP END_M_DIV_E_P

DIV_E_REGI:
   CALL DIV_E_REGI_P		; DIV_E_REGI_P ȣ��
   JMP END_M_DIV_E_P
DIV_E_IMME:
   CALL DIV_E_IMME_P		; DIV_E_IMME_P ȣ��
   JMP END_M_DIV_E_P
DIV_E_REGI_IMME:
   CALL DIV_E_REGI_IMME_P		; DIV_E_REGI_IMME_P ȣ��
   JMP END_M_DIV_E_P
DIV_E_DI:
   CALL DIV_E_DI_P		; DIV_E_DI_P ȣ��
   JMP END_M_DIV_E_P

END_M_DIV_E_P:
   RET
DIV_E_P ENDP

;------------------------------------------------
;Procedure Name : DIV_E_REGI_P
;Function : DIV E, �������� ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 28,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
DIV_E_REGI_P PROC
   MOV AX,VDECODE[8]                         ; DIV E,REGISTER
   AND AX,1111b
   MOV VDECODE[8],AX

   CMP VDECODE[8],1000b		; OPERAND2 �� A
   JE DIV_E_A
   CMP VDECODE[8],1001b		; OPERAND2 �� B
   JE DIV_E_B
   CMP VDECODE[8],1010b		; OPERAND2 �� C
   JE DIV_E_C
   CMP VDECODE[8],1011b		; OPERAND2 �� D
   JE DIV_E_D
   CMP VDECODE[8],1100b		; OPERAND2 �� E
   JE DIV_E_E
   CMP VDECODE[8],1101b		; OPERAND2 �� F
   JE DIV_E_F
   CMP VDECODE[8],1110b		; OPERAND2 �� X
   JE DIV_E_X
   CMP VDECODE[8],1111b		; OPERAND2 �� Y
   JE DIV_E_Y

   PRINT ERR
   JMP END_M_DIV_E_REGI_P

DIV_E_A:
	MOV BX,A				; BX�� A���� ����
	MOV AX,E				; AX�� E���� ����
	DIV BL					; BL������ E���� DIV
   CALL SHR_F				; E,F �������Ϳ� ���� ��,�������� ����
   JMP END_M_DIV_E_REGI_P
DIV_E_B:
	MOV BX,B				; BX�� B���� ����
	MOV AX,E				; AX�� E���� ����
	DIV BL					; BL������ E���� DIV
	CALL SHR_F				; E,F �������Ϳ� ���� ��,�������� ����
   JMP END_M_DIV_E_REGI_P
DIV_E_C:
   MOV BX,C				; BX�� C���� ����
	MOV AX,E				; AX�� E���� ����
	DIV BL					; BL������ E���� DIV
   CALL SHR_F				; E,F �������Ϳ� ���� ��,�������� ����
   JMP END_M_DIV_E_REGI_P
DIV_E_D:
   MOV BX,D				; BX�� D���� ����
	MOV AX,E				; AX�� E���� ����
	DIV BL					; BL������ E���� DIV
   CALL SHR_F				; E,F �������Ϳ� ���� ��,�������� ����
   JMP END_M_DIV_E_REGI_P
DIV_E_E:
   MOV BX,E				; BX�� E���� ����
	MOV AX,E				; AX�� E���� ����
	DIV BL					; BL������ E���� DIV
   CALL SHR_F				; E,F �������Ϳ� ���� ��,�������� ����
   JMP END_M_DIV_E_REGI_P
DIV_E_F:
   MOV BX,F				; BX�� F���� ����
	MOV AX,E				; AX�� E���� ����
	DIV BL					; BL������ E���� DIV
   CALL SHR_F				; E,F �������Ϳ� ���� ��,�������� ����
   JMP END_M_DIV_E_REGI_P
DIV_E_X:
   MOV BX,X				; BX�� X���� ����
	MOV AX,E				; AX�� E���� ����
	DIV BL					; BL������ E���� DIV
   CALL SHR_F				; E,F �������Ϳ� ���� ��,�������� ����
   JMP END_M_DIV_E_REGI_P
DIV_E_Y:
   MOV BX,Y				; BX�� Y���� ����
	MOV AX,E				; AX�� E���� ����
	DIV BL					; BL������ E���� DIV
   CALL SHR_F				; E,F �������Ϳ� ���� ��,�������� ����
   JMP END_M_DIV_E_REGI_P
   
   PRINT ERR
   JMP END_M_DIV_E_REGI_P

END_M_DIV_E_REGI_P:
   RET
DIV_E_REGI_P ENDP

;------------------------------------------------
;Procedure Name : DIV_E_IMME_P
;Function : DIV E, IMMEDIATE ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 28,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
DIV_E_IMME_P PROC                   ; DIV E,IMMEDIATE
   MOV DX,VDECODE[10]				; E�� ���� VDECODE[10]�� ����Ǿ��ִ� IMMEDIATE������ DIV
   MOV AX,E
   DIV DL
   CALL SHR_F						; E,F �������Ϳ� ���� ��,�������� ����
   RET
DIV_E_IMME_P ENDP

;------------------------------------------------
;Procedure Name : DIV_E_REGI_IMME_P
;Function : DIV E, REGISTER-IMMEDIATE ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 28,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
DIV_E_REGI_IMME_P PROC                 ; DIV E,REGISTER_IMMEDIATE
   CMP VDECODE[8],1110					; OPERAND2 ���� X
   JE DIV_E_R_I_X
   CMP VDECODE[8],1111					; OPERAND2 ���� Y
   JE DIV_E_R_I_Y
   
DIV_E_R_I_X:
   MOV SI,X								; X�� ���� SI�� ����
   MOV DX,M[SI]							; M[SI]�� ���� DX�� ����
   MOV AX,E
   DIV DL								; E�� ���� DX������ DIV
   CALL SHR_F						; E,F �������Ϳ� ���� ��,�������� ����
   JMP END_M_DIV_E_REGI_IMME_P
DIV_E_R_I_Y:
   MOV SI,Y								; Y�� ���� SI�� ����
   MOV DX,M[SI]							; M[SI]�� ���� DX�� ����
   MOV AX,E
   DIV DL								; E�� ���� DX������ DIV
   CALL SHR_F						; E,F �������Ϳ� ���� ��,�������� ����

END_M_DIV_E_REGI_IMME_P:
   RET
DIV_E_REGI_IMME_P ENDP

;------------------------------------------------
;Procedure Name : DIV_E_DI_P
;Function : DIV E, DIRECT ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 28,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
DIV_E_DI_P PROC                     ; DIV E,DIRECT
   MOV SI,VDECODE[10]    			; VDECODE[10]�� ����Ǿ��ִ� �ּҰ��� SI�� ����   
   MOV DX,M[SI]						; M[SI]���� DX�� ����
   MOV AX,E
   DIV DL							; E�� ���� DX�� DIV
   CALL SHR_F
   RET
DIV_E_DI_P ENDP

;------------------------------------------------
;Procedure Name : DIV_F_P
;Function : DIV F, ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 28,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
DIV_F_P PROC

   MOV AX, VDECODE[2]
   AND AX,11b
   MOV VDECODE[2],AX
                              ; DIV F,
   CMP VDECODE[2],00b			; REGISTER ���
   JE DIV_F_REGI
   CMP VDECODE[2],01b			; IMMEDIATE ���
   JE DIV_F_IMME
   CMP VDECODE[2],10b			; REGISTER-INDIRECT ���
   JE DIV_F_REGI_IMME
   CMP VDECODE[2],11b			; DIRECT ���
   JE DIV_F_DI

   PRINT ERR
   JMP END_M_DIV_F_P

DIV_F_REGI:
   CALL DIV_F_REGI_P		; DIV_F_REGI_P ȣ��
   JMP END_M_DIV_F_P
DIV_F_IMME:
   CALL DIV_F_IMME_P		; DIV_F_IMME_P ȣ��
   JMP END_M_DIV_F_P
DIV_F_REGI_IMME:
   CALL DIV_F_REGI_IMME_P		; DIV_F_REGI_IMME_P ȣ��
   JMP END_M_DIV_F_P
DIV_F_DI:
   CALL DIV_F_DI_P		; DIV_F_DI_P ȣ��
   JMP END_M_DIV_F_P

END_M_DIV_F_P:
   RET
DIV_F_P ENDP

;------------------------------------------------
;Procedure Name : DIV_F_REGI_P
;Function : DIV F, �������� ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 28,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
DIV_F_REGI_P PROC
   MOV AX,VDECODE[8]                         ; DIV F,REGISTER
   AND AX,1111b
   MOV VDECODE[8],AX

   CMP VDECODE[8],1000b		; OPERAND2 �� A
   JE DIV_F_A
   CMP VDECODE[8],1001b		; OPERAND2 �� B
   JE DIV_F_B
   CMP VDECODE[8],1010b		; OPERAND2 �� C
   JE DIV_F_C
   CMP VDECODE[8],1011b		; OPERAND2 �� D
   JE DIV_F_D
   CMP VDECODE[8],1100b		; OPERAND2 �� E
   JE DIV_F_E
   CMP VDECODE[8],1101b		; OPERAND2 �� F
   JE DIV_F_F
   CMP VDECODE[8],1110b		; OPERAND2 �� X
   JE DIV_F_X
   CMP VDECODE[8],1111b		; OPERAND2 �� Y
   JE DIV_F_Y

   PRINT ERR
   JMP END_M_DIV_F_REGI_P

DIV_F_A:
	MOV BX,A				; BX�� A���� ����
	MOV AX,F				; AX�� F���� ����
	DIV BL					; BL������ F���� DIV
   CALL SHR_F				; E,F �������Ϳ� ���� ��,�������� ����
   JMP END_M_DIV_F_REGI_P
DIV_F_B:
	MOV BX,B				; BX�� B���� ����
	MOV AX,F				; AX�� F���� ����
	DIV BL					; BL������ F���� DIV
	CALL SHR_F				; E,F �������Ϳ� ���� ��,�������� ����
   JMP END_M_DIV_F_REGI_P
DIV_F_C:
   MOV BX,C				; BX�� C���� ����
	MOV AX,F				; AX�� F���� ����
	DIV BL					; BL������ F���� DIV
   CALL SHR_F				; E,F �������Ϳ� ���� ��,�������� ����
   JMP END_M_DIV_F_REGI_P
DIV_F_D:
   MOV BX,D				; BX�� D���� ����
	MOV AX,F				; AX�� F���� ����
	DIV BL					; BL������ F���� DIV
   CALL SHR_F				; E,F �������Ϳ� ���� ��,�������� ����
   JMP END_M_DIV_F_REGI_P
DIV_F_E:
   MOV BX,E				; BX�� E���� ����
	MOV AX,F				; AX�� F���� ����
	DIV BL					; BL������ F���� DIV
   CALL SHR_F				; E,F �������Ϳ� ���� ��,�������� ����
   JMP END_M_DIV_F_REGI_P
DIV_F_F:
   MOV BX,F				; BX�� F���� ����
	MOV AX,F				; AX�� F���� ����
	DIV BL					; BL������ F���� DIV
   CALL SHR_F				; E,F �������Ϳ� ���� ��,�������� ����
   JMP END_M_DIV_F_REGI_P
DIV_F_X:
   MOV BX,X				; BX�� X���� ����
	MOV AX,F				; AX�� F���� ����
	DIV BL					; BL������ F���� DIV
   CALL SHR_F				; E,F �������Ϳ� ���� ��,�������� ����
   JMP END_M_DIV_F_REGI_P
DIV_F_Y:
   MOV BX,Y				; BX�� Y���� ����
	MOV AX,F				; AX�� F���� ����
	DIV BL					; BL������ F���� DIV
   CALL SHR_F				; E,F �������Ϳ� ���� ��,�������� ����
   JMP END_M_DIV_F_REGI_P
   
   PRINT ERR
   JMP END_M_DIV_F_REGI_P

END_M_DIV_F_REGI_P:
   RET
DIV_F_REGI_P ENDP

;------------------------------------------------
;Procedure Name : DIV_F_IMME_P
;Function : DIV F, IMMEDIATE ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 28,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
DIV_F_IMME_P PROC                   ; DIV F,IMMEDIATE
   MOV DX,VDECODE[10]				; E�� ���� VDECODE[10]�� ����Ǿ��ִ� IMMEDIATE������ DIV
   MOV AX,F
   DIV DL
   CALL SHR_F						; E,F �������Ϳ� ���� ��,�������� ����
   RET
DIV_F_IMME_P ENDP

DIV_F_REGI_IMME_P PROC                 ; DIV F,REGISTER_IMMEDIATE
   CMP VDECODE[8],1110					; OPERAND2 ���� X
   JE DIV_F_R_I_X
   CMP VDECODE[8],1111					; OPERAND2 ���� Y
   JE DIV_F_R_I_Y
   
DIV_F_R_I_X:
   MOV SI,X								; X�� ���� SI�� ����
   MOV DX,M[SI]							; M[SI]�� ���� DX�� ����
   MOV AX,F
   DIV DL								; F�� ���� DX������ DIV
   CALL SHR_F						; E,F �������Ϳ� ���� ��,�������� ����
   JMP END_M_DIV_F_REGI_IMME_P
DIV_F_R_I_Y:
   MOV SI,Y								; Y�� ���� SI�� ����
   MOV DX,M[SI]							; M[SI]�� ���� DX�� ����
   MOV AX,F
   DIV DL								; F�� ���� DX������ DIV
   CALL SHR_F						; E,F �������Ϳ� ���� ��,�������� ����

END_M_DIV_F_REGI_IMME_P:
   RET
DIV_F_REGI_IMME_P ENDP

;------------------------------------------------
;Procedure Name : DIV_F_DI_P
;Function : DIV F, DIRECT ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 28,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
DIV_F_DI_P PROC                     ; DIV F,DIRECT
   MOV SI,VDECODE[10]    			; VDECODE[10]�� ����Ǿ��ִ� �ּҰ��� SI�� ����   
   MOV DX,M[SI]						; M[SI]���� DX�� ����
   MOV AX,F
   DIV DL							; F�� ���� DX�� DIV
   CALL SHR_F
   RET
DIV_F_DI_P ENDP

;------------------------------------------------
;Procedure Name : DIV_X_P
;Function : DIV X, ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 28,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
DIV_X_P PROC

   MOV AX, VDECODE[2]
   AND AX,11b
   MOV VDECODE[2],AX
                              ; DIV X,
   CMP VDECODE[2],00b			; REGISTER ���
   JE DIV_X_REGI
   CMP VDECODE[2],01b			; IMMEDIATE ���
   JE DIV_X_IMME
   CMP VDECODE[2],10b			; REGISTER-INDIRECT ���
   JE DIV_X_REGI_IMME
   CMP VDECODE[2],11b			; DIRECT ���
   JE DIV_X_DI

   PRINT ERR
   JMP END_M_DIV_X_P

DIV_X_REGI:
   CALL DIV_X_REGI_P		; DIV_X_REGI_P ȣ��
   JMP END_M_DIV_X_P
DIV_X_IMME:
   CALL DIV_X_IMME_P		; DIV_X_IMME_P ȣ��
   JMP END_M_DIV_X_P
DIV_X_REGI_IMME:
   CALL DIV_X_REGI_IMME_P		; DIV_X_REGI_IMME_P ȣ��
   JMP END_M_DIV_X_P
DIV_X_DI:
   CALL DIV_X_DI_P		; DIV_X_DI_P ȣ��
   JMP END_M_DIV_X_P

END_M_DIV_X_P:
   RET
DIV_X_P ENDP

;------------------------------------------------
;Procedure Name : DIV_X_REGI_P
;Function : DIV X, �������� ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 28,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
DIV_X_REGI_P PROC
   MOV AX,VDECODE[8]                         ; DIV X,REGISTER
   AND AX,1111b
   MOV VDECODE[8],AX

   CMP VDECODE[8],1000b		; OPERAND2 �� A
   JE DIV_X_A
   CMP VDECODE[8],1001b		; OPERAND2 �� B
   JE DIV_X_B
   CMP VDECODE[8],1010b		; OPERAND2 �� C
   JE DIV_X_C
   CMP VDECODE[8],1011b		; OPERAND2 �� D
   JE DIV_X_D
   CMP VDECODE[8],1100b		; OPERAND2 �� E
   JE DIV_X_E
   CMP VDECODE[8],1101b		; OPERAND2 �� F
   JE DIV_X_F
   CMP VDECODE[8],1110b		; OPERAND2 �� X
   JE DIV_X_X
   CMP VDECODE[8],1111b		; OPERAND2 �� Y
   JE DIV_X_Y

   PRINT ERR
   JMP END_M_DIV_X_REGI_P

DIV_X_A:
	MOV BX,A				; BX�� A���� ����
	MOV AX,X				; AX�� X���� ����
	DIV BL					; BL������ X���� DIV
   CALL SHR_F				; E,F �������Ϳ� ���� ��,�������� ����
   JMP END_M_DIV_X_REGI_P
DIV_X_B:
	MOV BX,B				; BX�� B���� ����
	MOV AX,X				; AX�� X���� ����
	DIV BL					; BL������ X���� DIV
	CALL SHR_F				; E,F �������Ϳ� ���� ��,�������� ����
   JMP END_M_DIV_X_REGI_P
DIV_X_C:
   MOV BX,C				; BX�� C���� ����
	MOV AX,X				; AX�� X���� ����
	DIV BL					; BL������ X���� DIV
   CALL SHR_F				; E,F �������Ϳ� ���� ��,�������� ����
   JMP END_M_DIV_X_REGI_P
DIV_X_D:
   MOV BX,D				; BX�� D���� ����
	MOV AX,X				; AX�� X���� ����
	DIV BL					; BL������ X���� DIV
   CALL SHR_F				; E,F �������Ϳ� ���� ��,�������� ����
   JMP END_M_DIV_X_REGI_P
DIV_X_E:
   MOV BX,E				; BX�� E���� ����
	MOV AX,X				; AX�� X���� ����
	DIV BL					; BL������ X���� DIV
   CALL SHR_F				; E,F �������Ϳ� ���� ��,�������� ����
   JMP END_M_DIV_X_REGI_P
DIV_X_F:
   MOV BX,F				; BX�� F���� ����
	MOV AX,X				; AX�� X���� ����
	DIV BL					; BL������ X���� DIV
   CALL SHR_F				; E,F �������Ϳ� ���� ��,�������� ����
   JMP END_M_DIV_X_REGI_P
DIV_X_X:
   MOV BX,X				; BX�� X���� ����
	MOV AX,X				; AX�� X���� ����
	DIV BL					; BL������ X���� DIV
   CALL SHR_F				; E,F �������Ϳ� ���� ��,�������� ����
   JMP END_M_DIV_X_REGI_P
DIV_X_Y:
   MOV BX,Y				; BX�� Y���� ����
	MOV AX,X				; AX�� X���� ����
	DIV BL					; BL������ X���� DIV
   CALL SHR_F				; E,F �������Ϳ� ���� ��,�������� ����
   JMP END_M_DIV_X_REGI_P
   
   PRINT ERR
   JMP END_M_DIV_X_REGI_P

END_M_DIV_X_REGI_P:
   RET
DIV_X_REGI_P ENDP

;------------------------------------------------
;Procedure Name : DIV_X_IMME_P
;Function : DIV X, IMMEDIATE ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 28,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
DIV_X_IMME_P PROC                   ; DIV X,IMMEDIATE
   MOV DX,VDECODE[10]				; E�� ���� VDECODE[10]�� ����Ǿ��ִ� IMMEDIATE������ DIV
   MOV AX,X
   DIV DL
   CALL SHR_F						; E,F �������Ϳ� ���� ��,�������� ����
   RET
DIV_X_IMME_P ENDP

DIV_X_REGI_IMME_P PROC                 ; DIV X,REGISTER_IMMEDIATE
   CMP VDECODE[8],1110					; OPERAND2 ���� X
   JE DIV_X_R_I_X
   CMP VDECODE[8],1111					; OPERAND2 ���� Y
   JE DIV_X_R_I_Y
   
DIV_X_R_I_X:
   MOV SI,X								; X�� ���� SI�� ����
   MOV DX,M[SI]							; M[SI]�� ���� DX�� ����
   MOV AX,X
   DIV DL								; X�� ���� DX������ DIV
   CALL SHR_F						; E,F �������Ϳ� ���� ��,�������� ����
   JMP END_M_DIV_X_REGI_IMME_P
DIV_X_R_I_Y:
   MOV SI,Y								; Y�� ���� SI�� ����
   MOV DX,M[SI]							; M[SI]�� ���� DX�� ����
   MOV AX,X
   DIV DL								; F�� ���� DX������ DIV
   CALL SHR_F						; E,F �������Ϳ� ���� ��,�������� ����

END_M_DIV_X_REGI_IMME_P:
   RET
DIV_X_REGI_IMME_P ENDP

;------------------------------------------------
;Procedure Name : DIV_X_DI_P
;Function : DIV X, DIRECT ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 28,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
DIV_X_DI_P PROC                     ; DIV X,DIRECT
   MOV SI,VDECODE[10]    			; VDECODE[10]�� ����Ǿ��ִ� �ּҰ��� SI�� ����   
   MOV DX,M[SI]						; M[SI]���� DX�� ����
   MOV AX,X
   DIV DL							; X�� ���� DX�� DIV
   CALL SHR_F
   RET
DIV_X_DI_P ENDP

;------------------------------------------------
;Procedure Name : DIV_Y_P
;Function : DIV Y, ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 28,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
DIV_Y_P PROC

   MOV AX, VDECODE[2]
   AND AX,11b
   MOV VDECODE[2],AX
                              ; DIV Y,
   CMP VDECODE[2],00b			; REGISTER ���
   JE DIV_Y_REGI
   CMP VDECODE[2],01b			; IMMEDIATE ���
   JE DIV_Y_IMME
   CMP VDECODE[2],10b			; REGISTER-INDIRECT ���
   JE DIV_Y_REGI_IMME
   CMP VDECODE[2],11b			; DIRECT ���
   JE DIV_Y_DI

   PRINT ERR
   JMP END_M_DIV_Y_P

DIV_Y_REGI:
   CALL DIV_Y_REGI_P		; DIV_Y_REGI_P ȣ��
   JMP END_M_DIV_Y_P
DIV_Y_IMME:
   CALL DIV_Y_IMME_P		; DIV_Y_IMME_P ȣ��
   JMP END_M_DIV_Y_P
DIV_Y_REGI_IMME:
   CALL DIV_Y_REGI_IMME_P		; DIV_Y_REGI_IMME_P ȣ��
   JMP END_M_DIV_Y_P
DIV_Y_DI:
   CALL DIV_Y_DI_P		; DIV_Y_DI_P ȣ��
   JMP END_M_DIV_Y_P

END_M_DIV_Y_P:
   RET
DIV_Y_P ENDP

;------------------------------------------------
;Procedure Name : DIV_Y_REGI_P
;Function : DIV Y, �������� ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 28,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
DIV_Y_REGI_P PROC
   MOV AX,VDECODE[8]                         ; DIV Y,REGISTER
   AND AX,1111b
   MOV VDECODE[8],AX

   CMP VDECODE[8],1000b		; OPERAND2 �� A
   JE DIV_Y_A
   CMP VDECODE[8],1001b		; OPERAND2 �� B
   JE DIV_Y_B
   CMP VDECODE[8],1010b		; OPERAND2 �� C
   JE DIV_Y_C
   CMP VDECODE[8],1011b		; OPERAND2 �� D
   JE DIV_Y_D
   CMP VDECODE[8],1100b		; OPERAND2 �� E
   JE DIV_Y_E
   CMP VDECODE[8],1101b		; OPERAND2 �� F
   JE DIV_Y_F
   CMP VDECODE[8],1110b		; OPERAND2 �� X
   JE DIV_Y_X
   CMP VDECODE[8],1111b		; OPERAND2 �� Y
   JE DIV_Y_Y

   PRINT ERR
   JMP END_M_DIV_Y_REGI_P

DIV_Y_A:
	MOV BX,A				; BX�� A���� ����
	MOV AX,Y				; AX�� Y���� ����
	DIV BL					; BL������ Y���� DIV
   CALL SHR_F				; E,F �������Ϳ� ���� ��,�������� ����
   JMP END_M_DIV_Y_REGI_P
DIV_Y_B:
	MOV BX,B				; BX�� B���� ����
	MOV AX,Y				; AX�� Y���� ����
	DIV BL					; BL������ Y���� DIV
	CALL SHR_F				; E,F �������Ϳ� ���� ��,�������� ����
   JMP END_M_DIV_Y_REGI_P
DIV_Y_C:
    MOV BX,C				; BX�� C���� ����
	MOV AX,Y				; AX�� Y���� ����
	DIV BL					; BL������ Y���� DIV
   CALL SHR_F				; E,F �������Ϳ� ���� ��,�������� ����
   JMP END_M_DIV_Y_REGI_P
DIV_Y_D:
   MOV BX,D				; BX�� D���� ����
	MOV AX,Y				; AX�� Y���� ����
	DIV BL					; BL������ Y���� DIV
   CALL SHR_F				; E,F �������Ϳ� ���� ��,�������� ����
   JMP END_M_DIV_Y_REGI_P
DIV_Y_E:
   MOV BX,E				; BX�� E���� ����
	MOV AX,Y				; AX�� Y���� ����
	DIV BL					; BL������ Y���� DIV
   CALL SHR_F				; E,F �������Ϳ� ���� ��,�������� ����
   JMP END_M_DIV_Y_REGI_P
DIV_Y_F:
   MOV BX,F				; BX�� F���� ����
	MOV AX,Y				; AX�� Y���� ����
	DIV BL					; BL������ Y���� DIV
   CALL SHR_F				; E,F �������Ϳ� ���� ��,�������� ����
   JMP END_M_DIV_Y_REGI_P
DIV_Y_X:
   MOV BX,X				; BX�� X���� ����
	MOV AX,Y				; AX�� Y���� ����
	DIV BL					; BL������ Y���� DIV
   CALL SHR_F				; E,F �������Ϳ� ���� ��,�������� ����
   JMP END_M_DIV_Y_REGI_P
DIV_Y_Y:
   MOV BX,Y				; BX�� Y���� ����
	MOV AX,Y				; AX�� Y���� ����
	DIV BL					; BL������ Y���� DIV
   CALL SHR_F				; E,F �������Ϳ� ���� ��,�������� ����
   JMP END_M_DIV_Y_REGI_P
   
   PRINT ERR
   JMP END_M_DIV_Y_REGI_P

END_M_DIV_Y_REGI_P:
   RET
DIV_Y_REGI_P ENDP

;------------------------------------------------
;Procedure Name : DIV_Y_IMME_P
;Function : DIV Y, IMMEDIATE ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 28,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
DIV_Y_IMME_P PROC                   ; DIV Y,IMMEDIATE
   MOV DX,VDECODE[10]				; E�� ���� VDECODE[10]�� ����Ǿ��ִ� IMMEDIATE������ DIV
   MOV AX,Y
   DIV DL
   CALL SHR_F						; E,F �������Ϳ� ���� ��,�������� ����
   RET
DIV_Y_IMME_P ENDP

DIV_Y_REGI_IMME_P PROC                 ; DIV Y,REGISTER_IMMEDIATE
   CMP VDECODE[8],1110					; OPERAND2 ���� X
   JE DIV_Y_R_I_X
   CMP VDECODE[8],1111					; OPERAND2 ���� Y
   JE DIV_Y_R_I_Y
   
DIV_Y_R_I_X:
   MOV SI,X								; X�� ���� SI�� ����
   MOV DX,M[SI]							; M[SI]�� ���� DX�� ����
   MOV AX,Y
   DIV DL								; Y�� ���� DX������ DIV
   CALL SHR_F						; E,F �������Ϳ� ���� ��,�������� ����
   JMP END_M_DIV_Y_REGI_IMME_P
DIV_Y_R_I_Y:
   MOV SI,Y								; Y�� ���� SI�� ����
   MOV DX,M[SI]							; M[SI]�� ���� DX�� ����
   MOV AX,Y
   DIV DL								; Y�� ���� DX������ DIV
   CALL SHR_F						; E,F �������Ϳ� ���� ��,�������� ����

END_M_DIV_Y_REGI_IMME_P:
   RET
DIV_Y_REGI_IMME_P ENDP

;------------------------------------------------
;Procedure Name : DIV_Y_DI_P
;Function : DIV Y, DIRECT ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 28,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
DIV_Y_DI_P PROC                     ; DIV Y,DIRECT
   MOV SI,VDECODE[10]      			; VDECODE[10]�� ����Ǿ��ִ� �ּҰ��� SI�� ���� 
   MOV DX,M[SI]						; M[SI]���� DX�� ����
   MOV AX,Y
   DIV DL							; Y�� ���� DX�� DIV
   CALL SHR_F
   RET
DIV_Y_DI_P ENDP

;------------------------------------------------
;Procedure Name : SHR_F
;Function : AX�� ���� DX�� ������ E,F�� ��, �������� �������ִ� ����� ����
;PROGRAMED BY ������
;PROGRAM VERSION
;   Creation Date :Nov 28,2016
;   Last Modified On Nov 28 ,2016
;------------------------------------------------
SHR_F PROC							; E, F�� ��, ������ �������ִ� PROC
   MOV E,AX						; E�� �� ����
   AND E,0000000011111111b
   MOV F,AX						; F�� ������ ����
   AND F,1111111100000000b

	MOV CX,8
LL1:													; F�� ���� SHR 8ĭ ���ش�
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
   CMDLINE db 40 dup(0) ; ��ɾ� ����
   CMD_MEM_LEN DB 00h ; �ӽ� �޸� ��ɾ� ����
   CMD_MEM_ADDR DW 0000h ; �ӽ� �޸� �Ľ� �ּ� 
   CMD_MEM_VAL1 DW 0000h ; �ӽ� �޸� �Ľ� ��
   CMD_MEM_VAL2 DW 0000h ; �ӽ� �޸� �Ľ� ��

   DCD DB 4 dup('?')   ;decode�� �ϱ����� �迭 ����
   VDECODE DW 12 dup(?)   ;opcode,operand ���� �ϴ� �迭
   EDECODE DW 12 dup(?)   ;�����Ҷ� opcode,operand�� ����
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