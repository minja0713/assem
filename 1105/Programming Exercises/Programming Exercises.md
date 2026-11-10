## 1. FindLargest 프로시저

**번역:** 부호 있는 doubleword 배열의 포인터와 배열 길이를 매개변수로 받는 `FindLargest` 프로시저를 작성하세요. 배열에서 가장 큰 원소를 `EAX`로 반환해야 합니다. 프로시저 선언에 매개변수 목록이 있는 `PROC` 지시어를 사용하세요. 프로시저가 변경하는 레지스터 중 `EAX`를 제외한 모든 레지스터를 보존하세요. 길이가 서로 다른 배열 세 개(음수 포함)를 전달하는 테스트 프로그램과 `FindLargest`의 `PROTO` 선언도 작성하세요.

### 구현

```asm
FindLargest PROTO, pArray:PTR SDWORD, elementCount:DWORD

FindLargest PROC USES ebx ecx esi, pArray:PTR SDWORD, elementCount:DWORD
    mov esi, pArray
    mov ecx, elementCount
    test ecx, ecx
    jz  FL_Empty

    mov eax, [esi]              ; 첫 원소를 현재 최댓값으로 설정
    add esi, TYPE SDWORD
    dec ecx
    jz  FL_Done

FL_Loop:
    mov ebx, [esi]
    cmp ebx, eax
    jle FL_Next                 ; signed 비교
    mov eax, ebx

FL_Next:
    add esi, TYPE SDWORD
    loop FL_Loop

FL_Done:
    ret

FL_Empty:
    xor eax, eax                ; 빈 배열이면 0 반환
    ret
FindLargest ENDP
```

`jle`는 부호 있는 비교입니다. 배열 원소가 모두 음수여도 첫 원소부터 비교하므로 최댓값을 올바르게 찾습니다. 길이 0인 배열은 입력 조건에 명시되어 있지 않으므로 예제에서는 0을 반환하도록 정했습니다.

### 테스트 예시

```asm
.data
a1 SDWORD -8, -3, -20, -11
a2 SDWORD  4, 19
a3 SDWORD -100, 0, -1, 27, 6

.code
INVOKE FindLargest, ADDR a1, LENGTHOF a1 ; EAX = -3
call WriteInt
call Crlf

INVOKE FindLargest, ADDR a2, LENGTHOF a2 ; EAX = 19
call WriteInt
call Crlf

INVOKE FindLargest, ADDR a3, LENGTHOF a3 ; EAX = 27
call WriteInt
call Crlf
```

---

## 2. Chess Board

**번역:** 회색과 흰색 칸이 번갈아 나타나는 8×8 체스판을 출력하는 프로그램을 작성하세요. Irvine32 라이브러리의 `SetTextColor`와 `GotoXY`를 사용할 수 있습니다. 전역 변수를 피하고, 모든 프로시저에서 선언된 매개변수를 사용하세요. 한 가지 작업에 집중하는 짧은 프로시저들로 구성하세요.

### 구현 예시

아래 코드는 각 칸을 공백 두 개로 출력해 가로세로 비율이 체스판에 가깝게 보이도록 합니다. 각 프로시저는 필요한 정보를 매개변수로 받습니다.

```asm
DrawSquare PROC USES ebx, row:DWORD, col:DWORD, bgColor:DWORD
    ; 콘솔 좌표: DH = 행, DL = 열. 한 칸을 문자 두 칸 너비로 표시
    mov eax, row
    mov dh, al
    mov eax, col
    shl eax, 1
    mov dl, al
    call GotoXY

    ; 전경색은 흰색, 배경색은 bgColor
    mov eax, bgColor
    shl eax, 4
    add eax, white
    call SetTextColor

    mov al, ' '
    call WriteChar
    mov al, ' '
    call WriteChar
    ret
DrawSquare ENDP


DrawBoard PROC USES esi edi, shadeColor:DWORD, whiteColor:DWORD
    xor esi, esi                ; row = 0

DB_Row:
    cmp esi, 8
    jae DB_Done

    xor edi, edi                ; col = 0
DB_Col:
    cmp edi, 8
    jae DB_NextRow

    mov eax, esi
    add eax, edi
    test eax, 1
    jnz DB_WhiteSquare

    mov eax, shadeColor
    jmp DB_Draw

DB_WhiteSquare:
    mov eax, whiteColor

DB_Draw:
    INVOKE DrawSquare, esi, edi, eax
    inc edi
    jmp DB_Col

DB_NextRow:
    inc esi
    jmp DB_Row

DB_Done:
    ret
DrawBoard ENDP
```

문제 2의 테스트 코드는 다음과 같습니다.

```asm
main PROC
    INVOKE DrawBoard, gray, white
    call Crlf
    exit
main ENDP
```

---

## 3. 색이 번갈아 바뀌는 체스판

**번역:** 문제 2를 확장하세요. 500밀리초마다 색이 칠해진 칸의 색을 바꾸고 체스판을 다시 출력합니다. 가능한 4비트 배경색을 모두 사용하여 체스판을 16번 표시할 때까지 반복하세요. 흰색 칸은 계속 흰색으로 유지합니다.

**풀이:** 앞 문제의 `DrawBoard`가 `shadeColor`와 `whiteColor`를 매개변수로 받으므로, `shadeColor`를 0부터 15까지 바꾸면 됩니다. `Delay`에는 밀리초를 `EAX`로 전달합니다.

```asm
main PROC
    LOCAL colorIndex:DWORD

    mov colorIndex, 0

CB_Loop:
    INVOKE DrawBoard, colorIndex, white
    cmp colorIndex, 15
    je  CB_Done

    mov eax, 500
    call Delay
    inc colorIndex
    jmp CB_Loop

CB_Done:
    exit
main ENDP
```

0~15는 4비트 배경색 값 전체입니다. 마지막 화면은 출력한 뒤 대기 없이 종료합니다.

---

## 4. FindThrees 프로시저

**번역:** 배열 안에 값 `3`이 연속해서 세 번 나타나면 1을 반환하고, 그렇지 않으면 0을 반환하는 `FindThrees` 프로시저를 작성하세요. 입력 매개변수는 배열 포인터와 배열 크기입니다. 매개변수 목록이 있는 `PROC` 지시어를 사용하고, `EAX`를 제외하고 변경하는 레지스터를 보존하세요. 서로 다른 배열을 사용해 여러 번 호출하는 테스트 프로그램을 작성하세요.

### 구현

```asm
FindThrees PROTO, pArray:PTR SDWORD, elementCount:DWORD

FindThrees PROC USES ecx esi, pArray:PTR SDWORD, elementCount:DWORD
    mov ecx, elementCount
    cmp ecx, 3
    jb  FT_NotFound

    mov esi, pArray

FT_Loop:
    cmp DWORD PTR [esi], 3
    jne FT_Next
    cmp DWORD PTR [esi+4], 3
    jne FT_Next
    cmp DWORD PTR [esi+8], 3
    je  FT_Found

FT_Next:
    add esi, 4
    dec ecx
    cmp ecx, 3
    jae FT_Loop

FT_NotFound:
    xor eax, eax
    ret

FT_Found:
    mov eax, 1
    ret
FindThrees ENDP
```

### 테스트 예시

```asm
.data
t1 SDWORD 1, 3, 3, 3, 8
t2 SDWORD 3, 3, 2, 3, 3
t3 SDWORD 3, 3, 3

.code
INVOKE FindThrees, ADDR t1, LENGTHOF t1 ; EAX = 1
INVOKE FindThrees, ADDR t2, LENGTHOF t2 ; EAX = 0
INVOKE FindThrees, ADDR t3, LENGTHOF t3 ; EAX = 1
```

---

## 5. DifferentInputs 프로시저

**번역:** 세 입력 매개변수의 값이 모두 서로 다르면 `EAX = 1`, 그렇지 않으면 `EAX = 0`을 반환하는 `DifferentInputs` 프로시저를 작성하세요. `PROC` 매개변수 목록과 `PROTO` 선언을 사용하고, 서로 다른 입력을 전달하는 테스트 프로그램에서 다섯 번 호출하세요.

### 구현

```asm
DifferentInputs PROTO, val1:DWORD, val2:DWORD, val3:DWORD

DifferentInputs PROC USES ecx edx, val1:DWORD, val2:DWORD, val3:DWORD
    mov eax, val1
    mov ecx, val2
    cmp eax, ecx
    je  DI_False

    mov edx, val3
    cmp eax, edx
    je  DI_False
    cmp ecx, edx
    je  DI_False

    mov eax, 1
    ret

DI_False:
    xor eax, eax
    ret
DifferentInputs ENDP
```

### 다섯 번 호출하는 테스트 예시

```asm
INVOKE DifferentInputs, 1, 2, 3 ; 1
INVOKE DifferentInputs, 1, 1, 3 ; 0
INVOKE DifferentInputs, 5, 3, 4 ; 1
INVOKE DifferentInputs, 7, 7, 7 ; 0
INVOKE DifferentInputs, -1, 0, 1 ; 1
```

---

## 6. 정수 쌍 교환하기

**번역:** 임의의 순서로 정수를 담은 배열을 만드세요. 8.4.6절의 `Swap` 프로시저를 이용하여 배열에서 이웃한 정수 쌍을 차례로 맞바꾸는 반복문을 작성하세요.

### Swap 프로시저와 테스트 예시

아래 `Swap`은 두 원소의 주소를 받아 값을 교환하는 형태입니다. 배열의 원소 쌍은 `(0,1)`, `(2,3)`, `(4,5)` 순서로 교환합니다.

```asm
Swap PROC USES esi edi, pLeft:PTR SDWORD, pRight:PTR SDWORD
    mov esi, pLeft
    mov edi, pRight
    mov eax, [esi]
    xchg eax, [edi]
    mov [esi], eax
    ret
Swap ENDP
```

```asm
.data
values SDWORD 13, -7, 25, 0, -1, 44, 8, 3

.code
main PROC
    mov esi, OFFSET values
    mov ecx, LENGTHOF values / 2

SW_Loop:
    lea eax, [esi+4]            ; 두 번째 원소의 주소
    INVOKE Swap, esi, eax
    add esi, 8                  ; 다음 원소 쌍으로 이동
    loop SW_Loop

    ; 결과: -7, 13, 0, 25, 44, -1, 3, 8
    mov esi, OFFSET values
    mov ecx, LENGTHOF values
SW_Display:
    mov eax, [esi]
    call WriteInt
    call Crlf
    add esi, 4
    loop SW_Display

    exit
main ENDP
```

이 예제의 초기 배열은 임의로 섞인 값의 한 예입니다. 원소 개수는 짝수로 두었습니다.

---

## 7. 최대공약수(GCD)

**번역:** 두 정수의 최대공약수를 구하는 유클리드 알고리즘을 재귀적으로 구현하세요. 다음 쌍을 사용해 GCD 프로시저를 다섯 번 호출하는 테스트 프로그램을 작성하고, 매번 결과를 표시하세요: `(5,20)`, `(24,18)`, `(11,7)`, `(432,226)`, `(26,13)`.

### 재귀 구현

아래 코드는 먼저 두 입력의 절댓값을 만든 뒤, `gcd(x,y) = gcd(y, x mod y)`를 재귀적으로 적용합니다. 이 예제는 `EAX`에 결과를 반환합니다.

```asm
GCD PROTO, x:SDWORD, y:SDWORD

GCD PROC, x:SDWORD, y:SDWORD
    LOCAL a:DWORD, b:DWORD

    ; a = abs(x), 32비트 INT_MIN도 unsigned magnitude로 처리
    mov eax, x
    cdq
    xor eax, edx
    sub eax, edx
    mov a, eax

    ; b = abs(y)
    mov eax, y
    cdq
    xor eax, edx
    sub eax, edx
    mov b, eax

    cmp b, 0
    jne GCD_Recurse

    mov eax, a
    ret

GCD_Recurse:
    mov eax, a
    xor edx, edx
    div b                       ; unsigned a / b, 나머지는 EDX
    INVOKE GCD, b, edx
    ret
GCD ENDP
```

### 테스트 입력과 결과

| 입력 | GCD |
|---|---:|
| `(5, 20)` | 5 |
| `(24, 18)` | 6 |
| `(11, 7)` | 1 |
| `(432, 226)` | 2 |
| `(26, 13)` | 13 |

예를 들어 한 번의 호출은 다음과 같습니다.

```asm
INVOKE GCD, 432, 226
call WriteDec                  ; EAX = 2
call Crlf
```

---

## 8. 일치하는 원소 개수 세기

**번역:** 부호 있는 doubleword 배열 두 개의 포인터와 두 배열의 길이를 나타내는 세 번째 매개변수를 받는 `CountMatches` 프로시저를 작성하세요. 첫 번째 배열의 각 원소 $x_i$에 대해 두 번째 배열의 대응 원소 $y_i$가 같으면 개수를 증가시킵니다. 일치하는 원소 개수를 `EAX`로 반환하세요. 서로 다른 배열 쌍 두 개를 전달하는 테스트 프로그램, `INVOKE` 호출, `PROTO` 선언을 작성하고 `EAX` 이외에 변경하는 레지스터를 보존하세요.

### 구현

```asm
CountMatches PROTO, pArray1:PTR SDWORD, pArray2:PTR SDWORD, elementCount:DWORD

CountMatches PROC USES ebx ecx esi edi, \
    pArray1:PTR SDWORD, pArray2:PTR SDWORD, elementCount:DWORD

    mov esi, pArray1
    mov edi, pArray2
    mov ecx, elementCount
    xor eax, eax

CM_Loop:
    test ecx, ecx
    jz CM_Done

    mov ebx, [esi]
    cmp ebx, [edi]
    jne CM_Next
    inc eax

CM_Next:
    add esi, 4
    add edi, 4
    dec ecx
    jmp CM_Loop

CM_Done:
    ret
CountMatches ENDP
```

```asm
.data
m1a SDWORD 1, 2, 3, 4
m1b SDWORD 1, 9, 3, 0
m2a SDWORD -1, 5, 8
m2b SDWORD -1, 5, 7

.code
INVOKE CountMatches, ADDR m1a, ADDR m1b, LENGTHOF m1a ; EAX = 2
call WriteDec
call Crlf
INVOKE CountMatches, ADDR m2a, ADDR m2b, LENGTHOF m2a ; EAX = 2
call WriteDec
call Crlf
```

---

## 9. 거의 일치하는 원소 개수 세기

**번역:** 부호 있는 doubleword 배열 두 개의 포인터, 배열 길이, 대응 원소 사이에 허용되는 최대 차이 `diff`를 매개변수로 받는 `CountNearMatches` 프로시저를 작성하세요. 각 대응 원소의 절댓값 차이가 `diff` 이하이면 개수를 증가시키고, 그 개수를 `EAX`로 반환하세요. 배열 쌍 두 개를 전달하는 테스트 프로그램을 작성하고 `INVOKE` 및 `PROTO`를 사용하세요. `EAX` 이외에 변경하는 레지스터를 보존하세요.

> 문제 이미지의 마지막 문장에는 `CountMatches`의 `PROTO`라고 적혀 있지만, 이 문제에서 정의하는 프로시저 이름에 맞춰 `CountNearMatches PROTO`로 작성합니다.

### 구현

```asm
CountNearMatches PROTO, \
    pArray1:PTR SDWORD, pArray2:PTR SDWORD, elementCount:DWORD, diff:DWORD

CountNearMatches PROC USES ebx ecx esi edi, \
    pArray1:PTR SDWORD, pArray2:PTR SDWORD, elementCount:DWORD, diff:DWORD
    LOCAL matches:DWORD

    mov esi, pArray1
    mov edi, pArray2
    mov ecx, elementCount
    mov matches, 0

CNM_Loop:
    test ecx, ecx
    jz CNM_Done

    mov eax, [esi]
    mov ebx, [edi]
    cmp eax, ebx
    jge CNM_XGreater
    sub ebx, eax
    mov eax, ebx
    jmp CNM_Compare

CNM_XGreater:
    sub eax, ebx

CNM_Compare:
    cmp eax, diff
    ja  CNM_Next
    inc matches

CNM_Next:
    add esi, 4
    add edi, 4
    dec ecx
    jmp CNM_Loop

CNM_Done:
    mov eax, matches
    ret
CountNearMatches ENDP
```

`diff`는 음수가 아닌 정수라고 가정합니다. 두 원소의 signed 순서를 먼저 판정한 뒤 차이를 unsigned 값으로 비교하면, 큰 양수와 큰 음수 사이 차이도 올바르게 처리할 수 있습니다.

### 테스트 예시

```asm
.data
n1a SDWORD 10, 20, -5, 100
n1b SDWORD 12, 25, -8, 90
n2a SDWORD -10, 0, 50
n2b SDWORD  -7, 5, 51

.code
INVOKE CountNearMatches, ADDR n1a, ADDR n1b, LENGTHOF n1a, 5 ; EAX = 3
call WriteDec
call Crlf
INVOKE CountNearMatches, ADDR n2a, ADDR n2b, LENGTHOF n2a, 3 ; EAX = 2
call WriteDec
call Crlf
```

---

## 10. Show Procedure Parameters

**번역:** 호출한 프로시저의 런타임 스택에 있는 32비트 매개변수들의 주소와 16진수 값을 출력하는 `ShowParams` 프로시저를 작성하세요. 가장 낮은 주소부터 가장 높은 주소 순서로 출력합니다. 프로시저에는 출력할 매개변수 개수를 나타내는 정수 하나를 전달합니다. 예를 들어 `MySample`이 인수 세 개로 호출되었다면, `MySample` 내부에서 `ShowParams`에 3을 전달해 출력할 수 있어야 합니다.

### 구현

`ShowParams`가 매개변수 세 개를 가진 프로시저 안에서 호출되고, 표준 프레임 포인터 프롤로그를 사용한다고 가정합니다. `ShowParams` 자신의 프레임에서 `[EBP+16]`은 호출한 프로시저의 첫 번째 스택 매개변수입니다.

```asm
.data
paramHeading BYTE "Stack parameters:",0dh,0ah
             BYTE "------------------------------",0dh,0ah,0
addressText  BYTE "Address ",0
equalsText   BYTE " = ",0

.code
ShowParams PROTO, paramCount:DWORD

ShowParams PROC USES esi, paramCount:DWORD
    LOCAL pAddr:DWORD, remaining:DWORD

    mov eax, ebp
    add eax, 16                 ; 호출한 프로시저의 첫 인수 주소
    mov pAddr, eax
    mov eax, paramCount
    mov remaining, eax

    mov edx, OFFSET paramHeading
    call WriteString

SP_Loop:
    cmp remaining, 0
    je  SP_Done

    mov edx, OFFSET addressText
    call WriteString

    mov eax, pAddr
    call WriteHex               ; 매개변수의 스택 주소

    mov edx, OFFSET equalsText
    call WriteString

    mov esi, pAddr
    mov eax, [esi]
    call WriteHex               ; 해당 주소에 저장된 32비트 값
    call Crlf

    add pAddr, 4
    dec remaining
    jmp SP_Loop

SP_Done:
    ret
ShowParams ENDP


MySample PROC first:DWORD, second:DWORD, third:DWORD
    INVOKE ShowParams, 3
    ret
MySample ENDP
```

호출 예:

```asm
main PROC
    INVOKE MySample, 1234h, 5000h, 6543h
    exit
main ENDP
```

화면 주소는 실행 때마다 달라질 수 있지만, 출력되는 값의 순서는 `00001234`, `00005000`, `00006543`입니다. 주소 증가 폭은 매개변수마다 4바이트입니다.

---

## 요약

| 번호 | 핵심 내용 |
|---:|---|
| 1 | signed 비교로 배열 최댓값 검색, 변경 레지스터는 `USES`로 보존 |
| 2 | `GotoXY`와 `SetTextColor`로 8×8 칸 출력 |
| 3 | 배경색을 0~15로 바꾸며 500ms 간격으로 재출력 |
| 4 | 배열에서 `3, 3, 3` 연속 구간 검색 |
| 5 | 세 입력값의 쌍별 비교 |
| 6 | 인접한 원소를 두 개씩 `Swap` |
| 7 | 재귀 유클리드 알고리즘 |
| 8 | 대응하는 배열 원소가 같은 개수 계산 |
| 9 | 대응 원소의 절댓값 차이가 `diff` 이하인 개수 계산 |
| 10 | 호출자의 스택 매개변수를 주소 오름차순으로 출력 |
