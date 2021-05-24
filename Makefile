BOCHS=bochs
BOCHSTEST=bochsdbg
NASM=nasm
CC1=tools\cc1.exe
GAS2NASK=tools\gas2nask.exe
NASK=tools\nask.exe
OBJ2BIM=tools\obj2bim.exe
RULE=tools\obj2bim.rul
MAP=src\kernel.map
BIM2HRB=tools\bim2hrb.exe

run: boot.img
	$(BOCHS) -f bochsrc-sos.bxrc

boot.img: kernel
	$(NASM) -f bin src\after.asm -o bin\after
	copy /b bin\kernel+bin\after boot\boot.img

kernel: kernel.hrb
	$(NASM) -f bin src\loader.asm -o bin\loader
	copy /b bin\loader+src\kernel.hrb bin\kernel

kernel.hrb: kernel.bim
	$(BIM2HRB) src\kernel.bim src\kernel.hrb 0

kernel.bim: kernel.obj func.obj
	$(OBJ2BIM) @$(RULE) out:src\kernel.bim stack:3136k map:$(MAP) src\kernel.obj src\func.obj

kernel.obj: kernel.asm
	$(NASK) src\kernel.asm src\kernel.obj src\kernel.lst

kernel.asm: kernel.gas
	$(GAS2NASK) src\kernel.gas src\kernel.asm

kernel.gas:
	$(CC1) -o src\kernel.gas src\kernel.c

func.obj:
	$(NASK) src\func.asm src\func.obj src\func.lst

test: boot.img
	$(BOCHSTEST) -f bochsrc-sos.bxrc

clean:
	del /F /S boot\boot.img bin\kernel bin\after bin\loader src\kernel.hrb src\kernel.bim src\kernel.obj src\kernel.asm src\kernel.gas src\func.obj
