; memory layout
;	[0x0000, 0x0800) - idt
;	[0x0800, 0x0818) - gdt
;	[0x0818, 0x1000) - reserved for now
;	[0x1000, 0x2000) - kernel data
;	[0x2000, 0x6000) - kernel stack
;	[0x8000, 0x9000) - kernel setup
;	[0x9000, ...) - kernel

section .text
[bits 16]
[org 0x7C00]
boot:
; set stack and segments
	mov ax, 0x0000
	cli
	mov ds, ax
	mov es, ax
	mov ss, ax
	mov sp, 0x6000
	sti

; enable a20 line
	call enable_a20

; load kernel
	; save boot device
	mov [bootdev], dl

	; reset disk drive
	xor ah, ah
	xor dl, dl
	int 0x13

	; check disk parameters
	mov ah, 0x08
	mov dl, [bootdev]
	int 0x13

	; load 4 setup sectors at 0x8000
	mov ax, 0x0204
	mov bx, 0x8000
	mov cx, 0x0002
	mov dh, 0x00
	mov dl, [bootdev]
	int 0x13
	jc read_error

	; put kernel sectors at 0x9000
	; (assume 32 sectors ~= 16KB)
	mov ax, 0x0220
	mov bx, 0x9000
	mov cx, 0x0006
	mov dh, 0x00
	mov dl, [bootdev]
	int 0x13
	jc read_error

; jump to setup
	jmp 0x0000:0x8000

bootdev db 0x00
errstr db "There was a problem while loading the kernel.", 0

read_error:
	lea di, [errstr]
	call print_str
	call getchar

	; reboot
	mov bx, 0x1234
	mov ax, 0x0040
	mov ds, ax
	mov [0x0072], bx
	jmp 0xFFFF:0000

print_nl:
	xor bh, bh
	mov ah, 0x0E
	mov al, 0x0A ; new line
	int 0x10
	mov al, 0x0D ; carriage return
	int 0x10
	ret

print_str:
	xor bh, bh
	mov ah, 0x0E
.loop:
	mov al, [di]
	cmp al, 0
	jz .loop_exit
	int 0x10
	inc di
	jmp .loop
	
.loop_exit:
	call print_nl
	ret

getchar:
	mov ah, 0
	int 0x16
	ret

; di = value to print in binary
print_bin_16:
	xor bh, bh
	mov ah, 0x0E
	mov al, '0'
	int 0x10
	mov al, 'b'
	int 0x10

	mov cx, 16
	mov bx, 0x8000
.loop:
	mov al, '1'
	test di, bx
	jnz .B1
	mov al, '0'
.B1:
	int 0x10
	shr bx, 1
	loop .loop

	call print_nl
	ret

; carry flag set = a20 enabled
; carry flag clear = a20 disabled
check_a20:
	push es
	mov ax, 0x0000
	mov es, ax
	mov byte [es:0x0000], 0xDD

	mov ax, 0xFFFF
	mov es, ax
	mov al, byte [es:0x0010]

	cmp al, 0xDD
	clc
	je .eq
	stc
.eq:
	pop es
	ret

enable_a20:
	call check_a20
	jc .enabled
	in al, 0x92		; this enables a20 but should be checked before hand
	;and al, 0xFD	; - disable
	or al, 0x02		; - enable
	out 0x92, al
.enabled:
	ret
