.model small
.stack 100h

.data
    msg1    db 'First number (0-99): $'
    msg2    db 13,10,'Second number (0-99): $'
    result  db 13,10,13,10,'--- Results ---',13,10,'$'
    addMsg  db 'A + B = $'
    subMsg  db 'A - B = $'
    mulMsg  db 'A * B = $'
    divMsg  db 'A / B = $'
    remMsg  db ', remainder = $'
    divZero db 'Cannot divide by zero.$'
    regsMsg db 13,10,13,10,'--- Register snapshots (hex) ---',13,10,'$'
    axMsg   db 'AX = $'
    bxMsg   db 'BX = $'
    cxMsg   db 'CX = $'
    dxMsg   db 'DX = $'
    crlf    db 13,10,'$'

    numA    dw 0
    numB    dw 0
    addRes  dw 0
    subRes  dw 0
    mulRes  dw 0
    divRes  dw 0
    remRes  dw 0

    savedAX dw 0
    savedBX dw 0
    savedCX dw 0
    savedDX dw 0

.code
main proc
    mov ax, @data
    mov ds, ax

    ; Read first number
    lea dx, msg1
    mov ah, 09h
    int 21h
    call ReadNum
    mov numA, ax

    ; Read second number
    lea dx, msg2
    mov ah, 09h
    int 21h
    call ReadNum
    mov numB, ax

    ; Addition
    mov ax, numA
    add ax, numB
    mov addRes, ax

    ; Subtraction
    mov ax, numA
    sub ax, numB
    mov subRes, ax

    ; Multiplication
    mov ax, numA
    mul numB
    mov mulRes, ax

    ; Division and remainder
    cmp numB, 0
    je divide_by_zero

    mov ax, numA
    xor dx, dx
    div numB
    mov divRes, ax
    mov remRes, dx
    jmp division_done

divide_by_zero:
    mov divRes, 0
    mov remRes, 0

division_done:
    ; Save register snapshots:
    ; AX = sum, BX = difference, CX = product, DX = quotient
    mov ax, addRes
    mov savedAX, ax
    mov bx, subRes
    mov savedBX, bx
    mov cx, mulRes
    mov savedCX, cx
    mov dx, divRes
    mov savedDX, dx

    ; Print arithmetic results
    lea dx, result
    mov ah, 09h
    int 21h

    lea dx, addMsg
    mov ah, 09h
    int 21h
    mov ax, addRes
    call PrintNum
    call NewLine

    lea dx, subMsg
    mov ah, 09h
    int 21h
    mov ax, subRes
    call PrintSigned
    call NewLine

    lea dx, mulMsg
    mov ah, 09h
    int 21h
    mov ax, mulRes
    call PrintNum
    call NewLine

    lea dx, divMsg
    mov ah, 09h
    int 21h

    cmp numB, 0
    je show_div_zero

    mov ax, divRes
    call PrintNum

    lea dx, remMsg
    mov ah, 09h
    int 21h
    mov ax, remRes
    call PrintNum
    call NewLine
    jmp show_registers

show_div_zero:
    lea dx, divZero
    mov ah, 09h
    int 21h
    call NewLine

show_registers:
    lea dx, regsMsg
    mov ah, 09h
    int 21h

    lea dx, axMsg
    mov ah, 09h
    int 21h
    mov ax, savedAX
    call PrintHex
    call NewLine

    lea dx, bxMsg
    mov ah, 09h
    int 21h
    mov ax, savedBX
    call PrintHex
    call NewLine

    lea dx, cxMsg
    mov ah, 09h
    int 21h
    mov ax, savedCX
    call PrintHex
    call NewLine

    lea dx, dxMsg
    mov ah, 09h
    int 21h
    mov ax, savedDX
    call PrintHex
    call NewLine

    mov ax, 4C00h
    int 21h
main endp


; Read a decimal number from the keyboard.
; Returns the value in AX. Enter a value from 0 to 99.
ReadNum proc
    xor bx, bx

read_loop:
    mov ah, 01h
    int 21h

    cmp al, 13
    je read_done

    ; Ignore characters that are not digits
    cmp al, '0'
    jb read_loop
    cmp al, '9'
    ja read_loop

    sub al, '0'
    xor ah, ah
    mov cx, ax

    mov ax, bx
    mov dx, 10
    mul dx
    add ax, cx
    mov bx, ax
    jmp read_loop

read_done:
    mov ax, bx
    ret
ReadNum endp


; Print unsigned decimal value in AX
PrintNum proc
    push bx
    push cx
    push dx

    cmp ax, 0
    jne pn_convert

    mov dl, '0'
    mov ah, 02h
    int 21h
    jmp pn_done

pn_convert:
    mov bx, 10
    xor cx, cx

pn_loop:
    xor dx, dx
    div bx
    push dx
    inc cx
    cmp ax, 0
    jne pn_loop

pn_output:
    pop dx
    add dl, '0'
    mov ah, 02h
    int 21h
    loop pn_output

pn_done:
    pop dx
    pop cx
    pop bx
    ret
PrintNum endp


; Print signed decimal value in AX
PrintSigned proc
    cmp ax, 8000h
    jb ps_positive

    push ax
    mov dl, '-'
    mov ah, 02h
    int 21h
    pop ax
    neg ax

ps_positive:
    call PrintNum
    ret
PrintSigned endp


; Print the 16-bit value in AX as four hexadecimal digits
PrintHex proc
    push bx
    push cx
    push dx

    mov bx, ax
    mov cx, 4

hex_loop:
    rol bx, 4
    mov dl, bl
    and dl, 0Fh

    cmp dl, 9
    jbe hex_digit
    add dl, 7

hex_digit:
    add dl, '0'
    mov ah, 02h
    int 21h
    loop hex_loop

    pop dx
    pop cx
    pop bx
    ret
PrintHex endp


NewLine proc
    lea dx, crlf
    mov ah, 09h
    int 21h
    ret
NewLine endp

end main
