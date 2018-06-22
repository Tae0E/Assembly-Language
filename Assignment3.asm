;영남대학교 컴퓨터공학과 2학년 21311859 정태영
;Assignment #3
.model small
.stack

.data
nameinput db "Input Your Name : $" ;이름 입력
myname db 100 dup('$') ;이름
xpos db 100 dup('$');x좌표
ypos db 100 dup('$') ;y좌표
.code

main proc

;데이터 영역 불러오기
	mov ax, @data
	mov ds, ax
;이름 입력란
	mov ah, 09H
	mov dx, offset nameinput
	int 21h
;이름 입력받기
	mov ah, 3FH     
	lea dx, myname
	int 21h
;인터럽트 9를 찾아오기
	mov ax, 0
	mov ds, ax

	mov bx, 09h * 04h
;원래의 인터럽트 9 주소를 스택에 저장
	mov dx, word ptr [bx]
	push dx
	mov dx, word ptr [bx]+2
	push dx

	mov ax, 0
	mov dx, ax

	mov bx, 09h * 04h
;kbd_handler로 인터럽트 9을 삽입
	cli ;인터럽트 비활성화
	mov word ptr [bx], offset kbd_handler ;키보드 ISR 불러오기
	mov word ptr [bx]+2, seg kbd_handler 
	sti ;인터럽트 활성화

;데이터 영역 불러오기
	mov ax, @data
	mov ds, ax
	jmp RANDLOOP1
;이름을 빨간글씨로 깜빡이게 출력
RANDLOOP2:
  	mov ah,0fh      ; AL레지스터에 현재 화면 모드값이 저장
  	int 10h
 	mov ah,00h 		; 화면 클리어
 	int 10h
	
	mov bl, 132 ;빨간글씨에 깜빡임
    mov ah, 09h
    mov al, 0
    lea dx, myname                         ; 이름을 출력
    int 10h
    int 21h

;5초동안 delay되게 해야 하지만 완성X
;입력받은 이름을 랜덤한 위치에서 출력시키기
RANDLOOP1:
;시스템의 시간을 얻어옴
	mov ah, 2CH
	int 21h  
;y의 좌표 얻어오기
  	mov  ax, dx
   	xor  dx, dx
   	mov  cx, 20   
  	div  cx       
	mov ypos, dl
;시스템의 시간을 얻어옴
	mov ah, 2CH
	int 21h  
;x의 좌표 알아오기
  	mov  ax, dx
   	xor  dx, dx
   	mov  cx, 70   
  	div  cx   
	mov xpos, dl  
;화면 초기화
  	mov ah,0fh      ; AL레지스터에 현재 화면 모드값이 저장
  	int 10h
 	mov ah,00h 		; 화면 클리어
 	int 10h
;가로에 x좌표, 세로에 y좌표 넣고 커서 위치 설정
	mov ah, 02
	mov dl, xpos
	mov dh, ypos
	int 10h
;이름 출력
   	mov ah, 09h
	lea dx, myname
	int 21h

	call kbd_handler ;kbd_handler 출력


;인터럽트9를 다시 원상태로 복귀
exit1:
	mov ax, 0
	mov dx, ax

	mov bx, 09h * 04h ;인터럽트 9를 다시 찾아오기

	cli ;인터럽트 비활성화
	pop dx 
	mov word ptr [bx], dx ;원래 주소로 돌아감
	pop dx
	mov word ptr [bx]+2, dx 
	sti ; 인터럽트 활성화  
	
jmp exit2
;kbd_handler 정의
PUBLIC kbd_handler
kbd_handler proc near
;최근 레지스터들을 스택에 저장
	push ax
	push bx
	push cx
	push dx
	push sp
	push bp
	push si
	push di
;포트 64h
	in al, 64h
	test al, 01h

	in al, 60h ; 키보드로 입력받은 키를 포트 60h로 해서 받아오기
;입력받은 키보드가 x인지 아닌지 비교해서 점프
	cmp al, 45 ;45는 키보드 scan코드로의 X
	je exit1 ;X가 맞으면 종료지점으로 점프
	jb jtoR2 ;x가 아니면 RANDLOOP1을 뛰어넘어 빨간글씨를 출력시키는 지점으로 출력
	jmp RANDLOOP1 ;원래 이름을 랜덤으로 출력시키는 코드의 반복
jtoR2:
	jmp RANDLOOP2 ;빨갛고 깜빡이는 이름 출력시키는 지점으로 점프

;종료전 작동가능한 인터럽트 제어에 종료신호 보냄
	mov al, 20h
	out 20h, al
;종료전 저장되었던 레지스터들을 로드시킴
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

exit2:;종료지점
main endp ; 프로그램 종료
   	mov AX,4C00H                
        int 21H
end