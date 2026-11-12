.386
.model flat, stdcall
.stack 4096

ExitProcess PROTO, dwExitCode:DWORD
printf PROTO C :PTR BYTE, :VARARG
scanf PROTO C :PTR BYTE, :VARARG

.data
    msg1 BYTE "Enter 5 integers: ", 0
    msg2 BYTE 13, 10, "Sum = %d", 13, 10, 0
    msg3 BYTE "Average = %d", 13, 10, 0

    format BYTE "%d", 0
    num DWORD 5 DUP(?)

    sum DWORD 0
    avg DWORD 0

.code
main PROC

    ; 정수 5개 입력
    INVOKE printf, ADDR msg1

    mov esi, OFFSET num
    mov ecx, 5

input_loop:
    INVOKE scanf, ADDR format, esi
    add esi, 4
    loop input_loop

    ; 합계 계산
    mov esi, OFFSET num
    mov ecx, 5
    mov eax, 0

sum_loop:
    add eax, [esi]
    add esi, 4
    loop sum_loop

    mov sum, eax

    ; 평균 계산
    mov ebx, 5
    cdq
    idiv ebx
    mov avg, eax

    ; 합계 출력
    INVOKE printf, ADDR msg2, sum

    ; 평균 출력
    INVOKE printf, ADDR msg3, avg

    INVOKE ExitProcess, 0

main ENDP
END main
