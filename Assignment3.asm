;�������б� ��ǻ�Ͱ��а� 2�г� 21311859 ���¿�
;Assignment #3
.model small
.stack

.data
nameinput db "Input Your Name : $" ;�̸� �Է�
myname db 100 dup('$') ;�̸�
xpos db 100 dup('$');x��ǥ
ypos db 100 dup('$') ;y��ǥ
.code

main proc

;������ ���� �ҷ�����
	mov ax, @data
	mov ds, ax
;�̸� �Է¶�
	mov ah, 09H
	mov dx, offset nameinput
	int 21h
;�̸� �Է¹ޱ�
	mov ah, 3FH     
	lea dx, myname
	int 21h
;���ͷ�Ʈ 9�� ã�ƿ���
	mov ax, 0
	mov ds, ax

	mov bx, 09h * 04h
;������ ���ͷ�Ʈ 9 �ּҸ� ���ÿ� ����
	mov dx, word ptr [bx]
	push dx
	mov dx, word ptr [bx]+2
	push dx

	mov ax, 0
	mov dx, ax

	mov bx, 09h * 04h
;kbd_handler�� ���ͷ�Ʈ 9�� ����
	cli ;���ͷ�Ʈ ��Ȱ��ȭ
	mov word ptr [bx], offset kbd_handler ;Ű���� ISR �ҷ�����
	mov word ptr [bx]+2, seg kbd_handler 
	sti ;���ͷ�Ʈ Ȱ��ȭ

;������ ���� �ҷ�����
	mov ax, @data
	mov ds, ax
	jmp RANDLOOP1
;�̸��� �����۾��� �����̰� ���
RANDLOOP2:
  	mov ah,0fh      ; AL�������Ϳ� ���� ȭ�� ��尪�� ����
  	int 10h
 	mov ah,00h 		; ȭ�� Ŭ����
 	int 10h
	
	mov bl, 132 ;�����۾��� ������
    mov ah, 09h
    mov al, 0
    lea dx, myname                         ; �̸��� ���
    int 10h
    int 21h

;5�ʵ��� delay�ǰ� �ؾ� ������ �ϼ�X
;�Է¹��� �̸��� ������ ��ġ���� ��½�Ű��
RANDLOOP1:
;�ý����� �ð��� ����
	mov ah, 2CH
	int 21h  
;y�� ��ǥ ������
  	mov  ax, dx
   	xor  dx, dx
   	mov  cx, 20   
  	div  cx       
	mov ypos, dl
;�ý����� �ð��� ����
	mov ah, 2CH
	int 21h  
;x�� ��ǥ �˾ƿ���
  	mov  ax, dx
   	xor  dx, dx
   	mov  cx, 70   
  	div  cx   
	mov xpos, dl  
;ȭ�� �ʱ�ȭ
  	mov ah,0fh      ; AL�������Ϳ� ���� ȭ�� ��尪�� ����
  	int 10h
 	mov ah,00h 		; ȭ�� Ŭ����
 	int 10h
;���ο� x��ǥ, ���ο� y��ǥ �ְ� Ŀ�� ��ġ ����
	mov ah, 02
	mov dl, xpos
	mov dh, ypos
	int 10h
;�̸� ���
   	mov ah, 09h
	lea dx, myname
	int 21h

	call kbd_handler ;kbd_handler ���


;���ͷ�Ʈ9�� �ٽ� �����·� ����
exit1:
	mov ax, 0
	mov dx, ax

	mov bx, 09h * 04h ;���ͷ�Ʈ 9�� �ٽ� ã�ƿ���

	cli ;���ͷ�Ʈ ��Ȱ��ȭ
	pop dx 
	mov word ptr [bx], dx ;���� �ּҷ� ���ư�
	pop dx
	mov word ptr [bx]+2, dx 
	sti ; ���ͷ�Ʈ Ȱ��ȭ  
	
jmp exit2
;kbd_handler ����
PUBLIC kbd_handler
kbd_handler proc near
;�ֱ� �������͵��� ���ÿ� ����
	push ax
	push bx
	push cx
	push dx
	push sp
	push bp
	push si
	push di
;��Ʈ 64h
	in al, 64h
	test al, 01h

	in al, 60h ; Ű����� �Է¹��� Ű�� ��Ʈ 60h�� �ؼ� �޾ƿ���
;�Է¹��� Ű���尡 x���� �ƴ��� ���ؼ� ����
	cmp al, 45 ;45�� Ű���� scan�ڵ���� X
	je exit1 ;X�� ������ ������������ ����
	jb jtoR2 ;x�� �ƴϸ� RANDLOOP1�� �پ�Ѿ� �����۾��� ��½�Ű�� �������� ���
	jmp RANDLOOP1 ;���� �̸��� �������� ��½�Ű�� �ڵ��� �ݺ�
jtoR2:
	jmp RANDLOOP2 ;������ �����̴� �̸� ��½�Ű�� �������� ����

;������ �۵������� ���ͷ�Ʈ ��� �����ȣ ����
	mov al, 20h
	out 20h, al
;������ ����Ǿ��� �������͵��� �ε��Ŵ
	pop di
	pop si
	pop bp
	pop sp
	pop dx
	pop cx
	pop bx
	pop ax

	iret
kbd_handler endp

exit2:;��������
main endp ; ���α׷� ����
   	mov AX,4C00H                
        int 21H
end