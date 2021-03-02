
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

; setup and load the idt
	; clear idt
	mov eax, 0x00000000
	lea di, [0x0000]
	mov cx, 0x0200 ; 512 dwords = 2048 bytes
	cld
	rep
	stosd
	; copy some entries
	lea si, [_idt32_data]
	lea di, [0x0000]
	mov cx, 0x0040 ; 32 entires = 64 dwords = 256 bytes
	cld
	rep
	movsd
	; load idt
	lidt [_idt32_ptr]

; setup and load the gdt
	lea si, [_gdt32_data]
	lea di, [0x0800]
	mov cx, 0x0006 ; 3 entries = 6 dwords = 24 bytes
	cld
	rep
	movsd
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


; ISRs
; VERIFY: if we disable interrupts and set the idt_ptr
; to (0, 0), we can delay setting up interrupts for when
; we're already running C code.
; (this is not true with the gdt_ptr)

; division-by-zero
_isr0:
	iret

; debug
_isr1:
	iret

; non-maskable interrupt
_isr2:
	iret

; breakpoint
_isr3:
	iret

; overflow
_isr4:
	iret

; out of bounds
_isr5:
	iret

; invalid opcode
_isr6:
	iret

; no coprocessor
_isr7:
	iret

; double fault
_isr8:
	; error code
	pop eax
	iret

; coprocessor segment overrun
_isr9:
	iret

; invalid TSS
_isr10:
	; error code
	pop eax
	iret

; segment not present
_isr11:
	; error code
	pop eax
	iret

; stack fault
_isr12:
	; error code
	pop eax
	iret

; general protection fault
_isr13:
	; error code
	pop eax
	iret

; page fault
_isr14:
	; error code
	pop eax
	iret

; unknown interrupt
_isr15:
	iret

; coprocessor fault
_isr16:
	iret

; alignment check
_isr17:
	; error code
	pop eax
	iret

; machine check
_isr18:
	iret

; reserved exceptions
_isr19:
_isr20:
_isr21:
_isr22:
_isr23:
_isr24:
_isr25:
_isr26:
_isr27:
_isr28:
_isr29:
_isr30:
_isr31:
	iret

section .data
; idt pointer
_idt32_ptr:
	dw 0x0800
	dd 0x00000000

; gdt pointer
_gdt32_ptr:
	dw 0x0018
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

; because we're still in real mode, we can
; ignore the upper word of the idt entry
align 8
_idt32_data:
%macro idt32_entry 1
	dw %1, 0x0008, 0x8E00, 0x0000
%endmacro
	idt32_entry _isr0
	idt32_entry _isr1
	idt32_entry _isr2
	idt32_entry _isr3
	idt32_entry _isr4
	idt32_entry _isr5
	idt32_entry _isr6
	idt32_entry _isr7
	idt32_entry _isr8
	idt32_entry _isr9
	idt32_entry _isr10
	idt32_entry _isr11
	idt32_entry _isr12
	idt32_entry _isr13
	idt32_entry _isr14
	idt32_entry _isr15
	idt32_entry _isr16
	idt32_entry _isr17
	idt32_entry _isr18
	idt32_entry _isr19
	idt32_entry _isr20
	idt32_entry _isr21
	idt32_entry _isr22
	idt32_entry _isr23
	idt32_entry _isr24
	idt32_entry _isr25
	idt32_entry _isr26
	idt32_entry _isr27
	idt32_entry _isr28
	idt32_entry _isr29
	idt32_entry _isr30
	idt32_entry _isr31
%undef idt32_entry
