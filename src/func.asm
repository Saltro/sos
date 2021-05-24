[format "WCOFF"]
[instrset "i486p"]
[bits 32]
global      _printstr

[section .text]

_printstr:
      push  ebp
      mov   ebp,  esp
      sub   esp,  4
      mov   dword [-0x4+ebp], 0
      mov   esi,  dword [0x4+ebp]
print:
      mov   ebx,  dword [-0x4+ebp]
      mov   al,   byte [esi]
      cmp   al,   0
      je    over
      mov   byte  [0xb8000+6*160+ebx],   al
      add   ebx,  2
      inc   esi
      mov   [-0x4+ebp], ebx
      jmp   print
over:
      ret