@ECHO OFF

nasm -f bin -o "bin/boot.bin" "src/boot.s"
nasm -f bin -o "bin/setup.bin" "src/setup.s"

nasm -f elf32 -o "bin/head.o" "src/head.s"
gcc -Wall -m32 -mabi=sysv -O -fstrength-reduce -fomit-frame-pointer -finline-functions -nostdinc -fno-builtin -c -o "bin/main.o" "src/main.c"
gcc -Wall -m32 -mabi=sysv -O -fstrength-reduce -fomit-frame-pointer -finline-functions -nostdinc -fno-builtin -c -o "bin/vga.o" "src/vga.c"
gcc -Wall -m32 -mabi=sysv -O -fstrength-reduce -fomit-frame-pointer -finline-functions -nostdinc -fno-builtin -c -o "bin/idt.o" "src/idt.c"
gcc -Wall -m32 -mabi=sysv -O -fstrength-reduce -fomit-frame-pointer -finline-functions -nostdinc -fno-builtin -c -o "bin/irq.o" "src/irq.c"
gcc -Wall -m32 -mabi=sysv -O -fstrength-reduce -fomit-frame-pointer -finline-functions -nostdinc -fno-builtin -c -o "bin/isr.o" "src/isr.c"

REM ld (on windows) can't output binary format directly so we need the objcopy step
REM 0x9000 - .text (4KB)
REM 0xA000 - .bss (4KB)
REM 0xB000 - .data (2KB)
REM 0xB800 - .rdata (2KB)
REM 0xC000 - .idata (1KB) (not sure what this is but it's on the objdump)
ld -O2 -m i386pe -Ttext 0x9000 -Tbss 0xA000 -Tdata 0xB000 --section-start .rdata=0xB800 --section-start .idata=0xC000 -e _start -o "bin/kernel.tmp" "bin/head.o" "bin/main.o" "bin/vga.o" "bin/idt.o" "bin/irq.o" "bin/isr.o"
objcopy -O binary "bin/kernel.tmp" "bin/kernel.bin"

REM (0, 0) - 1 boot sector
REM (1, 0) - 4 setup sectors
REM (5, 0) - kernel image with 16 sectors for now
REM (13, 0) - tail sector to ensure the kernel image have at least 21 sectors
makeiso -imagename=image.iso -sectorsize=512 -s0:0 "bin/boot.bin" -s0:510 "bin/bootsig.bin" -s1:0 "bin/setup.bin" -s5:0 "bin/kernel.bin" -s37:511 "bin/zero.bin"

qemu-system-x86_64 -monitor stdio -d cpu_reset -D log.txt -L "X:\Program Files\qemu" -drive format=raw,file=image.iso

