mbrseg      equ   0x7c0        ;启动扇区存放段地址
newseg      equ   0x800        ;内核代码存放段地址
maxcylind   equ   0
maxheader   equ   0
maxsector   equ   18
dptaddr     equ   0x7e0

jmp   start

welcome:    db '------Welcome to sOS------', 0
showcsmsg:  db 'Now CS is: ', 0
sector:     db 2
header:     db 0
cylind:     db 0

start:
      mov   ax,   mbrseg
      mov   ds,   ax
      mov   si,   welcome
      call  printstr__
      call  newline__
      call  showcs__
      call  newline__
      call  floppyload__
      jmp   newseg:0

printstr__:                  ;显示指定的字符串, 以'$'为结束标记
      mov   al,   [si]
      cmp   al,   0
      je    disover__
      mov   ah,   0xe
      int   0x10
      inc   si
      jmp   printstr__
disover__:
      ret

newline__:
      mov   ah,   0xe
      mov   al,   0xd
      int   10h
      mov   al,   0xa
      int   10h
      ret

showcs__:
      mov   si,   showcsmsg
      call  printstr__
      mov   dx,   0x3078
      call  printasciibyte__
      mov   bx,   cs
      cmp   bx,   0
      je    printzero__
      mov   ax,   0x10
      div   bh
      mov   dx,   ax
      call  processdiv__
      mov   dx,   ax
      call  printasciibyte__
      div   bl
      mov   dx,   ax
      call  processdiv__
      mov   dx,   ax
      call  printasciibyte__
      ret

;被除数不能为 0
printzero__:
      mov   dx,   0x3030
      call  printasciibyte__
      call  printasciibyte__
      ret

;输入 dl 为商 dh 为余数，输入转换后的 ascii 码 ax
processdiv__:
      call  hextoascii__
      mov   ah,   al
      mov   dl,   dh
      call  hextoascii__
      ret

;输入十六进制数字 dl 变成相应的 ascii 码 al
hextoascii__:
      add   dl,   0x30
      cmp   dl,   0x3a
      jns   hextoupperalpha__
      mov   al,   dl
      ret
;十六进制数字 al 大于 10 则表示为大写字母
hextoupperalpha__:
      add   dl,   0x7
      mov   al,   dl
      ret

;通过系统调用输出 ascii 码 dx
printasciibyte__:
      mov   ah,   0x0e
      mov   al,   dh
      int   0x10
      mov   al,   dl
      int   0x10
      ret

floppyload__:
      mov   ax,   newseg
      mov   es,   ax
      call  readsectors__
      ret

readsectors__:
      call  readonesector__
      mov   ax,   es
      add   ax,   0x20
      mov   es,   ax
      inc   byte [sector]
      cmp   byte [sector],   maxsector
      jle   readsectors__
      mov   byte [sector],   1
      inc   byte [header]
      cmp   byte [header],   maxheader
      jle   readsectors__
      mov   byte [header],   0
      inc   byte [cylind]
      cmp   byte [cylind],   maxcylind
      jle   readsectors__
      ret

readonesector__:
      mov   ah,   0x02
      mov   bx,   0
      mov   dl,   0
      mov   al,   1
      mov   cl,   [sector]
      mov   ch,   [cylind]
      mov   dh,   [header]
      int   0x13
      ret


times 510-($-$$) db 0
db 0x55,0xaa

jmp   jmpprotectmode
gdtsize     dw    32-1
gdtaddr     dd    0x00007e00

jmpprotectmode:
      mov   ax,   newseg
      sub   ax,   0x20
      mov   ds,   ax
      mov   ax,   dptaddr
      mov   es,   ax
      call  createdpt
      call  openprotectmode
      jmp   dword  0x0008:main-512

createdpt:
      lgdt  [gdtsize]
      ; 创建0#描述符，它是空描述符，这是处理器的要求
      mov   dword  [es:0x00], 0x00
      mov   dword  [es:0x04], 0x00

      ; 创建#1描述符，保护模式下的代码段描述符
      mov   dword  [es:0x08], 0x8000ffff
      mov   dword  [es:0x0c], 0x00409800

      ; 创建#2描述符，保护模式下的数据段描述符
      mov   dword  [es:0x10], 0x0000ffff  ;（把DS的基地址定义为0）
      mov   dword  [es:0x14], 0x00c09200  ; (标志位G=1,表示以KB为单位)

      ; 创建#3描述符，保护模式下的堆栈段描述符
      mov   dword  [es:0x18], 0x00007a00
      mov   dword  [es:0x1c], 0x00409600

      ret

openprotectmode:
      cli   ; 禁止中断
      in    al,   0x92
      or    al,   0000_0010b
      out   0x92, al    ; 开启 A20 地址线
      mov   eax,  cr0
      or    eax,  1
      mov   cr0,  eax   ; 设置 cr0 最后一位为 0，打开保护模式
      ret

[bits 32]
main:
      mov   ax,   00000000000_10_000b ; 加载数据段选择子(0x10)
      mov   ds,   ax

      jmp   $+0x26      ; 跳转至 c 程序