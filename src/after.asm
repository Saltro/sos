kernelseg   equ   0x0800

jmp   start
aftermbr:   db '------MBR finished!------', 0

start:
      mov   ax,   kernelseg
      mov   ds,   ax
      mov   es,   ax
      mov   si,   aftermbr
      call  printstr
      call  newline
      jmp   while

printstr:
      mov   al,   [si]
      cmp   al,   0
      je    disover
      mov   ah,   0xe
      int   0x10
      inc   si
      jmp   printstr
disover:
      ret

newline:
      mov   ah,   0xe
      mov   al,   0xd
      int   10h
      mov   al,   0xa
      int   0x10
      ret

while:
      jmp   while

times 1473024-($-$$) db 0
