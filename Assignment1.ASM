;�������б� ��ǻ�Ͱ��а� 2�г� 21311859 ���¿�
;Computer Systems and Assembly Assignment #1
.model small
.stack 100h
.data
student DB "21311859$"
id DB "59", '$'
guess DB 5 dup('$') ;�Է¹��� ����
question DB "Please input your id : $"
result1 DB "Your Student ID Is $"
result2 DB "Wrong Number - Only 2 digits  $"

.code
mainfunc proc
;cmp���� ���н� return���� ����
return:
	mov ax, @data ;����Ÿ ���׸�Ʈ �ҷ�����
	mov ds, ax
;question ���
	mov ah, 9h
	mov dx, offset question
	int 21h

;���ڿ� �Է¹ޱ�
	mov ah, 3FH
	mov bx, 00
	mov cx, 100
	lea dx, guess
	int 21h
;���ڿ� ���ϱ� ���� ���� ����
	mov si, guess
	mov di, id

	cmp si, di;�ΰ� ��
	je correct;������ correct�� �̵�

	lea dx, result2
	mov ah, 9
	int 21h
	jmp return
;�й� ���
correct:
	lea dx, result1
	mov ah, 9
	int 21h
	mov ah, 9h
	mov dx, offset student
	int 21h

;���α׷� ���Ḧ ���� int 21h interrupt ���� �� ���α׷� ����
	mov ax, 4c00h
	int 21h

mainfunc ENDP
END mainfunc