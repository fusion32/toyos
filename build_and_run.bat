@ECHO OFF

del /Q .\build\*

nasm -f bin -o "build/boot.bin" "src/boot.s"
nasm -f bin -o "build/setup.bin" "src/setup.s"

nasm -f elf32 -o "build/head.o" "src/head.s"
gcc -Wall -m32 -mabi=sysv -O -fstrength-reduce -fomit-frame-pointer -finline-functions -nostdinc -fno-builtin -c -o "build/main.o" "src/main.c"
gcc -Wall -m32 -mabi=sysv -O -fstrength-reduce -fomit-frame-pointer -finline-functions -nostdinc -fno-builtin -c -o "build/vga.o" "src/vga.c"
gcc -Wall -m32 -mabi=sysv -O -fstrength-reduce -fomit-frame-pointer -finline-functions -nostdinc -fno-builtin -c -o "build/idt.o" "src/idt.c"
gcc -Wall -m32 -mabi=sysv -O -fstrength-reduce -fomit-frame-pointer -finline-functions -nostdinc -fno-builtin -c -o "build/irq.o" "src/irq.c"
gcc -Wall -m32 -mabi=sysv -O -fstrength-reduce -fomit-frame-pointer -finline-functions -nostdinc -fno-builtin -c -o "build/isr.o" "src/isr.c"
gcc -Wall -m32 -mabi=sysv -O -fstrength-reduce -fomit-frame-pointer -finline-functions -nostdinc -fno-builtin -c -o "build/timer.o" "src/timer.c"
gcc -Wall -m32 -mabi=sysv -O -fstrength-reduce -fomit-frame-pointer -finline-functions -nostdinc -fno-builtin -c -o "build/keyboard.o" "src/keyboard.c"

REM ld (on windows) can't output binary format directly so we need the objcopy step
REM 0x9000 - .text (4KB)
REM 0xA000 - .bss (4KB)
REM 0xB000 - .data (2KB)
REM 0xB800 - .rdata (2KB)
ld -O2 -m i386pe -Ttext 0x9000 -Tbss 0xA000 -Tdata 0xB000 --section-start .rdata=0xB800 --section-start .idata=0xF800 --section-start .reloc=0xFC00 -e _start -o "build/kernel.tmp" "build/head.o" "build/main.o" "build/vga.o" "build/idt.o" "build/irq.o" "build/isr.o" "build/timer.o" "build/keyboard.o"
objcopy -j .text -j .bss -j .data -j .rdata -O binary "build/kernel.tmp" "build/kernel.bin"

REM (0, 0) - 1 boot sector
REM (1, 0) - 4 setup sectors
REM (5, 0) - kernel image with 32 sectors for now (16KB)
REM (37, 0) - tail sector to ensure the kernel image have 32 sectors
makeiso -imagename=image.iso -sectorsize=512 -s0:0 "build/boot.bin" -s0:510 "bin/bootsig.bin" -s1:0 "build/setup.bin" -s5:0 "build/kernel.bin" -s37:511 "bin/zero.bin"

qemu-system-x86_64 -monitor stdio -d cpu_reset -D log.txt -L "X:\Program Files\qemu" -drive format=raw,file=image.iso

