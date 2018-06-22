;영남대학교 컴퓨터공학과 2학년 21311859 정태영
;Computer Systems and Assembly Assignment #1
.model small
.stack 100h
.data
student DB "21311859$"
id DB "59", '$'
guess DB 5 dup('$') ;입력받을 변수
question DB "Please input your id : $"
result1 DB "Your Student ID Is $"
result2 DB "Wrong Number - Only 2 digits  $"

.code
mainfunc proc
;cmp구문 실패시 return으로 점프
return:
	mov ax, @data ;데이타 세그먼트 불러오기
	mov ds, ax
;question 출력
	mov ah, 9h
	mov dx, offset question
	int 21h

;문자열 입력받기
	mov ah, 3FH
	mov bx, 00
	mov cx, 100
	lea dx, guess
	int 21h
;문자열 비교하기 위해 따로 저장
	mov si, guess
	mov di, id

	cmp si, di;두개 비교
	je correct;만족시 correct로 이동

	lea dx, result2
	mov ah, 9
	int 21h
	jmp return
;학번 출력
correct:
	lea dx, result1
	mov ah, 9
	int 21h
	mov ah, 9h
	mov dx, offset student
	int 21h

;프로그램 종료를 위해 int 21h interrupt 설정 및 프로그램 종료
	mov ax, 4c00h
	int 21h

mainfunc ENDP
END mainfunc