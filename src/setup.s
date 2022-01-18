
section .text

[bits 16]
[org 0x8000]
setup32:

	mov ah, 0x0E
	mov al, 'S'
	int 0x10
	mov al, '3'
	int 0x10
	mov al, '2'
	int 0x10

; disable interrupts
	cli
	in al, 0x70
	or al, 0x80
	out 0x70, al

; NOTE: because interrupts are disabled, we can set the
; idt to (limit = 0, base = 0) and setup it later

; setup gdt
	lea si, [_gdt32_data]
	lea di, [0x0800]
	mov cx, 0x0006 ; 3 entries = 6 dwords = 24 bytes
	cld
	rep
	movsd

; load gdt and idt
	lgdt [_gdt32_ptr]

; enter protected mode
	mov ax, 0x0001
	lmsw ax
	; NOTE: This jump needs to be before [bits 32] or else
	; we'll get a GPF. I think this is because the processor
	; just got into protected mode and this jump instruction
	; was already decoded as a 16-bit instruction.
	; ("jmp 0x08:.pm" works as well but is a 16-bit jump)
	jmp dword 0x08:.pm ; flush instruction queue + set CS to use the gdt
.pm:

[bits 32]
; reset segments to use the gdt
	mov eax, 0x10
	mov ds, eax
	mov es, eax
	mov fs, eax
	mov gs, eax
	mov ss, eax

; reprogram PIC to map IRQs 0-16 to idt entries 32-47
	; 0x20 = 8259A-1 cmd port
	; 0x21 = 8259A-1 data port
	; 0xA0 = 8259A-2 cmd port
	; 0xA1 = 8259A-2 data port

	; this basically reset both PICs
	; configure them accordingly

	mov al, 0x11
	out 0x20, al
	out 0xA0, al
	mov al, 0x20
	out 0x21, al
	mov al, 0x28
	out 0xA1, al
	mov al, 0x04
	out 0x21, al
	mov al, 0x02
	out 0xA1, al
	mov al, 0x01
	out 0x21, al
	out 0xA1, al

	; mask all irqs for now
	mov al, 0xFF
	out 0xA1, al
	mov al, 0xFB
	out 0x21, al

; jump to kernel
	jmp 0x9000

section .data
; idt pointer
_idt32_ptr:
	dw 0x0000
	dd 0x00000000

; gdt pointer
_gdt32_ptr:
	dw 0x0017
	dd 0x00000800

align 8
_gdt32_data:
; null descriptor
	; base = 0x00000000
	; limit = 0x00000
	; access = 0x00
	; flags = 0x0
	db 0x00, 0x00, 0x00, 0x00
	db 0x00, 0x00, 0x00, 0x00
; code descriptor
	; base = 0x00000000
	; limit = 0xFFFFF
	; access = 0x9A
	; flags = 0xC
	db 0xFF, 0xFF, 0x00, 0x00
	db 0x00, 0x9A, 0xCF, 0x00
; data descriptor
	; base = 0x00000000
	; limit = 0xFFFFF
	; access = 0x92
	; flags = 0xC
	db 0xFF, 0xFF, 0x00, 0x00
	db 0x00, 0x92, 0xCF, 0x00
