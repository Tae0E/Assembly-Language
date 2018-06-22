.model small
.stack

.data
input1 db "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx$"
 
 ; 복사하여 저장할 문자열 공간확보
myname db 100 dup('$') ;이름 입력
reverse db 100 dup('$') ;역으로 입력
student db 100 dup('$') ;학번 입력
inputtg db 20 dup('$')   ;t또는 g입력
torg db "TEXT Mode?$"
etr db 0ah, 0dh, '$'

.code

main proc
   
	mov ax, @data
	mov ds, ax
; 이름 입력
	mov ah, 3FH     
	lea dx, myname
	int 21h
   
 ; myname의 시작주소값을 si, input1의 시작주소값을 di에 저장
	mov si, offset myname
	mov di, offset input1
 
 ; 복사할 문자열의 갯수 얻기
	mov cx,al
	dec cx ; 입력받을때 들어간 $와 엔터의 갯수 감소
	dec cx
 ;입력받은 myname 출력
	mov ah, 09
	mov dx, offset myname
	int 21h

lp1:
 ; 한 바이트씩 복사하기
	mov al, [si]
	mov [di], al
 
 ; 각각 다음 바이트를 가리키게 하기위해 si, di 증가
	inc si
	inc di
 
 ; 복사할 문자열의 문자갯수 만큼 반복하기
	loop lp1

	mov al,' ' ;한칸 띄우기
	mov [di],al
	inc si
	inc di
 ;학번을 입력
 	mov ah, 3FH                    
 	mov bx, 00
 	mov cx, 100
 	lea dx, student
 	int 21h

 ; student의 시작주소값을 si에 저장
 	mov si, offset student

 ; 복사할 문자열의 문자갯수 얻기
  	mov cx, al
  	dec cx ; 입력받을때 들어간 $와 엔터의 갯수만큼 감소
  	dec cx
 ;입력받은 학번 출력
  	mov ah, 09
 	mov dx, offset student
 	int 21h

lp2:
 ; 한 바이트씩 복사
 	mov al, [si]
 	mov [di], al
 
 ; 각각 다음 바이트를 가리키게 하기위해 si, di 증가
 	inc si
 	inc di
 
 ; 복사할 문자열의 문자갯수 만큼 반복하기
 	loop lp2

 	mov al,' ' ;한칸 띄우기
 	mov [di],al
 	inc si
 	inc di

 ; input1 출력
 	mov ah, 09
 	mov dx, offset input1
 	int 21h
 ;개행
 	mov ah, 09
 	mov dx, offset etr
 	int 21h 

 	mov si, offset input1 + 39 ; 맨 끝을 가리키게 offset을 39를 더함
 	mov bx, offset reverse
 	mov cx,40 ; 40글자를 출력할 수 있게 cx값을 40으로 초기화

lp3: ; 한바이트씩 복사하기 위해 loop
  	mov al,[si]
  	mov [bx],al
  	dec si
  	inc bx
  	loop lp3
 ;거꾸로 저장된 reverse 출력
 	mov ah, 09
 	mov dx, offset reverse
 	int 21h 
 ;개행
 	mov ah, 09
 	mov dx, offset etr
 	int 21h
lp4:
 ; t 또는 g입력
	mov ah, 09
 	mov dx, offset torg
 	int 21h 

   	mov ah, 3FH     
  	mov bx, 00
   	mov cx, 1
   	lea dx, inputtg
   	int 21h

  	mov ah,0fh      ; AL레지스터에 현재 화면 모드값이 저장
  	int 10h
 	mov ah,00h 		; 화면 클리어
  	int 10h

 ;대문자 T, G도 받을수 있게 예외처리
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
 ;개행

	mov ah, 09
 	mov dx, offset etr
 	int 21h
 ;t, g, ctrl + t 외에 다른 문자 입력시 다시 되돌아가기
   	JNE lp4

   	mov bl, 0
  	mov ah, 09h
   	mov al, 0
   	lea cx, reverse
   	int 10h
   	int 21h
   
lp5:
 ;text mode 진입
   	mov al, 03h    
   	mov ah, 0
   	int 10h
   	JMP lp4


lp6: 	

	mov ah, 09
 	mov dx, offset etr
 	int 21h

   	mov cx, 0 ;cx를 0으로 초기화
   	mov di, offset myname ;di에 myname의 시작주소 넣음


lp7:
   	mov al,[di] ; 문자열의 끝을 확인하며 cx로 문자열의 길이를 카운트
   	cmp al,'$' ; di가 가리키는곳의 글자가 Null인지를 확인
   	je lp8 ; 같으면 lp8로 점프
   	inc di ; 다르면 di를 1증가시켜 다음글자를 가리키게 함 
   	inc cx ; cx를 1증가
   	jmp lp7 ; lp7로 점프
lp8:
   	dec cx ; 입력받을때 들어간 $와 엔터 만큼의 카운트 감소
   	dec cx
   	mov bl, 112      ; 이름 검정글씨에 회색바탕
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
   	mov bl, 135      ; 학번 글씨 깜빡임
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
   	mov bl, 50   ; 녹색
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
   	mov bl, 9   ; 하늘색
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
   	mov bl, 8   ; 회색
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
   	mov bl, 6   ; 갈색
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

   

  ; 프로그램 종료를 위한 INT 21H 인터럽트 속성 설정 및 종료
main endp
   	mov AX,4C00H                
        int 21H
end