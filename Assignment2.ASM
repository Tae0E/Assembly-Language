.model small
.stack

.data
input1 db "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx$"
 
 ; �����Ͽ� ������ ���ڿ� ����Ȯ��
myname db 100 dup('$') ;�̸� �Է�
reverse db 100 dup('$') ;������ �Է�
student db 100 dup('$') ;�й� �Է�
inputtg db 20 dup('$')   ;t�Ǵ� g�Է�
torg db "TEXT Mode?$"
etr db 0ah, 0dh, '$'

.code

main proc
   
	mov ax, @data
	mov ds, ax
; �̸� �Է�
	mov ah, 3FH     
	lea dx, myname
	int 21h
   
 ; myname�� �����ּҰ��� si, input1�� �����ּҰ��� di�� ����
	mov si, offset myname
	mov di, offset input1
 
 ; ������ ���ڿ��� ���� ���
	mov cx,al
	dec cx ; �Է¹����� �� $�� ������ ���� ����
	dec cx
 ;�Է¹��� myname ���
	mov ah, 09
	mov dx, offset myname
	int 21h

lp1:
 ; �� ����Ʈ�� �����ϱ�
	mov al, [si]
	mov [di], al
 
 ; ���� ���� ����Ʈ�� ����Ű�� �ϱ����� si, di ����
	inc si
	inc di
 
 ; ������ ���ڿ��� ���ڰ��� ��ŭ �ݺ��ϱ�
	loop lp1

	mov al,' ' ;��ĭ ����
	mov [di],al
	inc si
	inc di
 ;�й��� �Է�
 	mov ah, 3FH                    
 	mov bx, 00
 	mov cx, 100
 	lea dx, student
 	int 21h

 ; student�� �����ּҰ��� si�� ����
 	mov si, offset student

 ; ������ ���ڿ��� ���ڰ��� ���
  	mov cx, al
  	dec cx ; �Է¹����� �� $�� ������ ������ŭ ����
  	dec cx
 ;�Է¹��� �й� ���
  	mov ah, 09
 	mov dx, offset student
 	int 21h

lp2:
 ; �� ����Ʈ�� ����
 	mov al, [si]
 	mov [di], al
 
 ; ���� ���� ����Ʈ�� ����Ű�� �ϱ����� si, di ����
 	inc si
 	inc di
 
 ; ������ ���ڿ��� ���ڰ��� ��ŭ �ݺ��ϱ�
 	loop lp2

 	mov al,' ' ;��ĭ ����
 	mov [di],al
 	inc si
 	inc di

 ; input1 ���
 	mov ah, 09
 	mov dx, offset input1
 	int 21h
 ;����
 	mov ah, 09
 	mov dx, offset etr
 	int 21h 

 	mov si, offset input1 + 39 ; �� ���� ����Ű�� offset�� 39�� ����
 	mov bx, offset reverse
 	mov cx,40 ; 40���ڸ� ����� �� �ְ� cx���� 40���� �ʱ�ȭ

lp3: ; �ѹ���Ʈ�� �����ϱ� ���� loop
  	mov al,[si]
  	mov [bx],al
  	dec si
  	inc bx
  	loop lp3
 ;�Ųٷ� ����� reverse ���
 	mov ah, 09
 	mov dx, offset reverse
 	int 21h 
 ;����
 	mov ah, 09
 	mov dx, offset etr
 	int 21h
lp4:
 ; t �Ǵ� g�Է�
	mov ah, 09
 	mov dx, offset torg
 	int 21h 

   	mov ah, 3FH     
  	mov bx, 00
   	mov cx, 1
   	lea dx, inputtg
   	int 21h

  	mov ah,0fh      ; AL�������Ϳ� ���� ȭ�� ��尪�� ����
  	int 10h
 	mov ah,00h 		; ȭ�� Ŭ����
  	int 10h

 ;�빮�� T, G�� ������ �ְ� ����ó��
   	cmp inputtg, 't'
   	JE lp6
   	cmp inputtg, 'T'
   	JE lp6
   	cmp inputtg, 'g'
   	JE lp11
   	cmp inputtg, 'G'
   	JE lp11

   	cmp inputtg, 14h
   	JE lp5
 ;����

	mov ah, 09
 	mov dx, offset etr
 	int 21h
 ;t, g, ctrl + t �ܿ� �ٸ� ���� �Է½� �ٽ� �ǵ��ư���
   	JNE lp4

   	mov bl, 0
  	mov ah, 09h
   	mov al, 0
   	lea cx, reverse
   	int 10h
   	int 21h
   
lp5:
 ;text mode ����
   	mov al, 03h    
   	mov ah, 0
   	int 10h
   	JMP lp4


lp6: 	

	mov ah, 09
 	mov dx, offset etr
 	int 21h

   	mov cx, 0 ;cx�� 0���� �ʱ�ȭ
   	mov di, offset myname ;di�� myname�� �����ּ� ����


lp7:
   	mov al,[di] ; ���ڿ��� ���� Ȯ���ϸ� cx�� ���ڿ��� ���̸� ī��Ʈ
   	cmp al,'$' ; di�� ����Ű�°��� ���ڰ� Null������ Ȯ��
   	je lp8 ; ������ lp8�� ����
   	inc di ; �ٸ��� di�� 1�������� �������ڸ� ����Ű�� �� 
   	inc cx ; cx�� 1����
   	jmp lp7 ; lp7�� ����
lp8:
   	dec cx ; �Է¹����� �� $�� ���� ��ŭ�� ī��Ʈ ����
   	dec cx
   	mov bl, 112      ; �̸� �����۾��� ȸ������
   	mov ah, 09h
   	mov al, 0
   	lea dx, myname
   	int 10h
   	int 21h

   	mov cx,0
   	mov di, offset student
lp9:
   	mov al,[di]
   	cmp al,'$'
   	JE lp10
   	inc di
   	inc cx
   	JMP lp9
lp10:
   	dec cx
   	dec cx
   	mov bl, 135      ; �й� �۾� ������
   	mov ah, 09h
   	mov al, 0
   	lea dx, student
   	int 10h
   	int 21h
 	mov ah, 09
 	mov dx, offset etr
 	int 21h
   	JMP lp4
   
lp11:
   	mov cx,0
   	mov di, offset myname
lp12:
   	mov al,[di]
   	cmp al,'$'
   	je lp13
   	inc di
   	inc cx
   	jmp lp12
lp13:
 	mov ah, 09
 	mov dx, offset etr
 	int 21h
   	dec cx
   	dec cx
   
   	mov al, 13h   ; graphics mode
   	mov ah, 0
   	int 10h
   
   	mov al, 1
   	mov bh, 0
   	mov bl, 50   ; ���
   	mov cx, msglend - offset msgl
   	mov dl, 0
   	mov dh, 0
   	push cs
   	pop es
  	mov bp, offset msgl
   	mov ah, 13h
   	int 10h
   
   	mov al, 1
   	mov bh, 1
   	mov bl, 9   ; �ϴû�
   	mov cx, msglend - offset msgl
   	mov dl, 0
   	mov dh, 1
   	push cs
   	pop es
   	mov bp, offset msgl
   	mov ah, 13h
   	int 10h
   
   	mov al, 1
   	mov bh, 0
   	mov bl, 8   ; ȸ��
   	mov cx, msglend - offset msgl
   	mov dl, 0
   	mov dh, 2
   	push cs
   	pop es
   	mov bp, offset msgl
   	mov ah, 13h
   	int 10h
   
   	mov al, 1
  	mov bh, 0
   	mov bl, 6   ; ����
   	mov cx, msglend - offset msgl
   	mov dl, 0
   	mov dh, 3
   	push cs
   	pop es
   	mov bp, offset msgl
   	mov ah, 13h
   	int 10h
   	jmp msglend
   	msgl db "Dept of Computer Engineering"

msglend:
 	mov ah, 09
 	mov dx, offset etr
 	int 21h
   	JMP lp4

   

  ; ���α׷� ���Ḧ ���� INT 21H ���ͷ�Ʈ �Ӽ� ���� �� ����
main endp
   	mov AX,4C00H                
        int 21H
end