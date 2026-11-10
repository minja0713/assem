## 8.10.2 Algorithm Workbench

### 1. AddThree의 스택 프레임 그리기

**번역:** 다음은 세 개의 doubleword를 더하는 `AddThree` 프로시저의 호출 순서입니다. `STDCALL` 호출 규약을 사용한다고 가정합니다.

```asm
push 10h
push 20h
push 30h
call AddThree
```

프로시저가 런타임 스택에 `EBP`를 push한 직후의 스택 프레임을 그리세요.

**풀이:** `CALL`이 반환 주소를 push하고, 프로시저 프롤로그가 이전 `EBP`를 push한 다음 프레임 포인터를 설정한다고 가정하면 다음과 같습니다.

```asm
push ebp
mov  ebp, esp
```

스택은 낮은 주소가 위쪽이고, `ESP`는 가장 최근에 push한 항목을 가리킵니다.

```text
낮은 주소
┌──────────────────────────────┐
│ 이전 EBP                     │  [EBP]       ← ESP
├──────────────────────────────┤
│ 반환 주소                    │  [EBP + 4]
├──────────────────────────────┤
│ 30h (마지막으로 push한 인수)  │  [EBP + 8]
├──────────────────────────────┤
│ 20h                          │  [EBP + 0Ch]
├──────────────────────────────┤
│ 10h (처음 push한 인수)        │  [EBP + 10h]
└──────────────────────────────┘
높은 주소
```

엄밀히 `push ebp` 직후이면서 아직 `mov ebp,esp`를 실행하지 않은 순간이라면, 저장된 이전 EBP는 `[ESP]`에 있고 `EBP` 레지스터는 아직 이전 값을 가리킵니다. 위 그림의 `[EBP + offset]` 표기는 프레임 포인터 설정까지 마친 표준 프레임 기준입니다.

`STDCALL`에서는 피호출자가 인수를 정리하므로 세 개의 doubleword 인수라면 반환 시 `ret 12`에 해당합니다.

### 2. 세 정수의 합을 반환하는 AddThree 작성

**번역:** 세 개의 정수 매개변수를 받아 그 합을 계산하고 `EAX`에 반환하는 `AddThree` 프로시저를 작성하세요.

**풀이:**

```asm
AddThree PROC, val1:DWORD, val2:DWORD, val3:DWORD
    mov eax, val1
    add eax, val2
    add eax, val3
    ret
AddThree ENDP
```

`.MODEL flat, STDCALL` 환경에서 매개변수 형식을 선언하면 MASM이 프로시저의 스택 프레임과 `STDCALL` 매개변수 정리를 처리합니다. 호출 예:

```asm
INVOKE AddThree, 10, 20, 30 ; 결과: EAX = 60
```

### 3. doubleword 배열을 가리키는 지역 포인터 선언

**번역:** doubleword 배열을 가리키는 `pArray`라는 지역 변수를 선언하세요.

**풀이:**

```asm
LOCAL pArray:PTR DWORD
```

### 4. 20바이트 배열인 지역 변수 선언

**번역:** 20바이트 배열인 `buffer`라는 지역 변수를 선언하세요.

**풀이:**

```asm
LOCAL buffer[20]:BYTE
```

---

## 8.11 프로그래밍 연습문제

### 5. 16비트 부호 없는 정수를 가리키는 지역 포인터

**번역:** 16비트 부호 없는 정수를 가리키는 `pwArray`라는 지역 변수를 선언하세요.

**풀이:**

```asm
LOCAL pwArray:PTR WORD
```

`WORD`는 16비트 자료형입니다.

### 6. 8비트 부호 있는 정수 지역 변수

**번역:** 8비트 부호 있는 정수를 저장하는 `myByte`라는 지역 변수를 선언하세요.

**풀이:**

```asm
LOCAL myByte:SBYTE
```

### 7. doubleword 20개로 이루어진 지역 배열

**번역:** doubleword 20개로 이루어진 `myArray`라는 지역 변수를 선언하세요.

**풀이:**

```asm
LOCAL myArray[20]:DWORD
```

### 8. 전경색과 배경색을 설정하는 SetColor 프로시저

**번역:** `forecolor`와 `backcolor`라는 두 개의 스택 매개변수를 받으며 Irvine32 라이브러리의 `SetTextColor`를 호출하는 `SetColor` 프로시저를 작성하세요.

**풀이:** Irvine32의 `SetTextColor`는 `EAX`의 하위 4비트에서 전경색을, 다음 4비트에서 배경색을 받습니다. 따라서 속성값은 `forecolor + backcolor * 16`입니다.

```asm
SetColor PROC, forecolor:DWORD, backcolor:DWORD
    mov eax, backcolor
    shl eax, 4
    add eax, forecolor
    call SetTextColor
    ret
SetColor ENDP
```

호출 예:

```asm
INVOKE SetColor, lightGreen, blue
```

### 9. 지정한 색으로 문자 하나를 출력하는 WriteColorChar

**번역:** `char`, `forecolor`, `backcolor`라는 세 개의 스택 매개변수를 받는 `WriteColorChar` 프로시저를 작성하세요. 지정한 전경색과 배경색으로 문자 하나를 출력해야 합니다.

**풀이:**

```asm
WriteColorChar PROC, char:DWORD, forecolor:DWORD, backcolor:DWORD
    mov eax, backcolor
    shl eax, 4
    add eax, forecolor
    call SetTextColor

    mov eax, char
    call WriteChar
    ret
WriteColorChar ENDP
```

`WriteChar`는 `AL`의 문자를 출력하므로 `EAX`에 문자를 넣으면 하위 바이트인 `AL`이 전달됩니다. 호출 예:

```asm
INVOKE WriteColorChar, 'A', yellow, blue
```

### 10. DumpMem을 감싸는 DumpMemory 프로시저

**번역:** Irvine32 라이브러리의 `DumpMem` 프로시저를 감싸는 `DumpMemory`라는 프로시저를 작성하세요. 선언된 매개변수와 `USES` 지시어를 사용하세요. 예를 들어 다음과 같이 호출할 수 있어야 합니다.

```asm
INVOKE DumpMemory, OFFSET array, LENGTHOF array, TYPE array
```

**풀이:** `DumpMem`은 `ESI`에 시작 주소, `ECX`에 표시할 항목 수, `EBX`에 항목 크기(바이트)를 받습니다.

```asm
DumpMemory PROC USES esi ecx ebx, \
    pArray:PTR BYTE, itemCount:DWORD, itemSize:DWORD

    mov esi, pArray
    mov ecx, itemCount
    mov ebx, itemSize
    call DumpMem
    ret
DumpMemory ENDP
```

호출 예:

```asm
.data
array DWORD 10h, 20h, 30h, 40h

.code
INVOKE DumpMemory, OFFSET array, LENGTHOF array, TYPE array
```

이 예에서 `LENGTHOF array`는 원소 개수인 4이고 `TYPE array`는 원소 크기인 4바이트입니다.

### 11. MultArray의 프로시저와 PROTO 선언

**번역:** doubleword 배열을 가리키는 포인터 두 개와 배열 원소 개수를 나타내는 세 번째 매개변수를 받는 `MultArray` 프로시저를 선언하세요. 이 프로시저의 `PROTO` 선언도 작성하세요.

**풀이:** 프로토타입과 프로시저 선언의 매개변수 목록을 일치시킵니다.

```asm
MultArray PROTO, pArray1:PTR DWORD, pArray2:PTR DWORD, elementCount:DWORD
```

프로시저 정의의 선언부는 다음과 같이 쓸 수 있습니다.

```asm
MultArray PROC, pArray1:PTR DWORD, pArray2:PTR DWORD, elementCount:DWORD
    ; 여기에 배열 처리 코드를 작성
    ret
MultArray ENDP
```
