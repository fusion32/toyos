
%macro stack_frame_start 0
	push ebp
	mov ebp, esp
%endmacro

%macro stack_frame_end 0
	mov esp, ebp
	pop ebp
%endmacro

section .text
extern _kentry
global _start
_start:
	push 0
	mov ebp, esp

	call _kentry
	jmp $

; u8 inportb(u16 port)
; (TODO: this should be an inline function)
global _inportb
_inportb:
	mov dx, [esp + 4]
	in al, dx
	ret

; void outportb(u16 port, u8 data)
; (TODO: this should be an inline function)
global _outportb
_outportb:
	mov dx, word [esp + 4]
	mov al, byte [esp + 8]
	out dx, al
	ret

; void gdt_load(void *gdtp)
;global _gdt_load
;_gdt_load:
;	mov eax, [esp + 4]
;	lgdt [eax]
;	mov eax, 0x10
;	mov ds, eax
;	mov es, eax
;	mov fs, eax
;	mov gs, eax
;	jmp 0x08:.L1
;.L1:
;	ret

; void idt_load(void *idtp)
global _idt_load
_idt_load:
	mov eax, [esp + 4]
	lidt [eax]
	ret

; void nmi_enable(void)
global _nmi_enable
_nmi_enable:
	in al, 0x70
	and al, 0x7F
	out 0x70, al
	ret

; void nmi_disable(void)
global _nmi_disable
_nmi_disable:
	in al, 0x70
	or al, 0x80
	out 0x70, al
	ret

; void irq_enable_all(void)
global _irq_enable_all
_irq_enable_all:
	mov al, 0x00
	out 0xA1, al
	out 0x21, al
	ret

; void irq_disable_all(void)
global _irq_disable_all
_irq_disable_all:
	mov al, 0xFF
	out 0xA1, al
	mov al, 0xFB
	out 0x21, al
	ret

; void memcpy(void *dst, void *src, u32 count)
global _memcpy
_memcpy:
	; TODO: use movsd which needs src and dst to be aligned
	stack_frame_start
	push esi
	push edi

	mov edi, [ebp + 8]
	mov esi, [ebp + 12]
	mov ecx, [ebp + 16]
	cld
	rep
	movsb

	pop edi
	pop esi
	stack_frame_end
	ret

; void memset(void *dst, u32 val, u32 count);
global _memset
_memset:
	stack_frame_start
	push edi

	mov edi, [ebp + 8]
	mov eax, [ebp + 12]
	mov ecx, [ebp + 16]
	cld
	rep
	stosb

	pop edi
	stack_frame_end
	ret

; void memset16(void *dst, u32 val, u32 count);
global _memset16
_memset16:
	stack_frame_start
	push edi

	mov edi, [ebp + 8]
	mov eax, [ebp + 12]
	mov ecx, [ebp + 16]
	cld
	rep
	stosw

	pop edi
	stack_frame_end
	ret

; ISRs
; Because some ISRs push an error code on the stack
; we push a dummy error code for ISRs that don't. This
; keeps the stack uniform to be used from the interrupt
; handlers in C.

global _isr0
global _isr1
global _isr2
global _isr3
global _isr4
global _isr5
global _isr6
global _isr7
global _isr8
global _isr9
global _isr10
global _isr11
global _isr12
global _isr13
global _isr14
global _isr15
global _isr16
global _isr17
global _isr18
global _isr19
global _isr20
global _isr21
global _isr22
global _isr23
global _isr24
global _isr25
global _isr26
global _isr27
global _isr28
global _isr29
global _isr30
global _isr31

%macro isr_w_err_code 1
	cli
	; error code already on the stack
	push %1
	jmp _isr_common
%endmacro

%macro isr_wo_err_code 1
	cli
	push 0 ; dummy error code
	push %1
	jmp _isr_common
%endmacro

; division-by-zero
_isr0:
	isr_wo_err_code 0
; debug
_isr1:
	isr_wo_err_code 1
; non-maskable interrupt
_isr2:
	isr_wo_err_code 2
; breakpoint
_isr3:
	isr_wo_err_code 3
; overflow
_isr4:
	isr_wo_err_code 4
; out of bounds
_isr5:
	isr_wo_err_code 5
; invalid opcode
_isr6:
	isr_wo_err_code 6
; no coprocessor
_isr7:
	isr_wo_err_code 7
; double fault
_isr8:
	isr_w_err_code 8
; coprocessor segment overrun
_isr9:
	isr_wo_err_code 9
; invalid TSS
_isr10:
	isr_w_err_code 10
; segment not present
_isr11:
	isr_w_err_code 11
; stack fault
_isr12:
	isr_w_err_code 12
; general protection fault
_isr13:
	isr_w_err_code 13
; page fault
_isr14:
	isr_w_err_code 14
; unknown interrupt
_isr15:
	isr_wo_err_code 15
; coprocessor fault
_isr16:
	isr_wo_err_code 16
; alignment check
_isr17:
	isr_wo_err_code 17
; machine check
_isr18:
	isr_wo_err_code 18
; reserved exceptions
_isr19:
	isr_wo_err_code 19
_isr20:
	isr_wo_err_code 20
_isr21:
	isr_wo_err_code 21
_isr22:
	isr_wo_err_code 22
_isr23:
	isr_wo_err_code 23
_isr24:
	isr_wo_err_code 24
_isr25:
	isr_wo_err_code 25
_isr26:
	isr_wo_err_code 26
_isr27:
	isr_wo_err_code 27
_isr28:
	isr_wo_err_code 28
_isr29:
	isr_wo_err_code 29
_isr30:
	isr_wo_err_code 30
_isr31:
	isr_wo_err_code 31

extern _isr_handler
_isr_common:
	pusha
	push ds
	push es
	push fs
	push gs
	mov eax, esp
	push eax
	call _isr_handler
	pop eax
	pop gs
	pop fs
	pop es
	pop ds
	popa
	add esp, 8 ; pop err_code and int_nr
	iret

; IRQs
global _irq0
global _irq1
global _irq2
global _irq3
global _irq4
global _irq5
global _irq6
global _irq7
global _irq8
global _irq9
global _irq10
global _irq11
global _irq12
global _irq13
global _irq14
global _irq15

%macro irq 1
	cli
	push 0 ; push dummy error code
	push %1
	jmp _irq_common
%endmacro

_irq0:
	irq 32
_irq1:
	irq 33
_irq2:
	irq 34
_irq3:
	irq 35
_irq4:
	irq 36
_irq5:
	irq 37
_irq6:
	irq 38
_irq7:
	irq 39
_irq8:
	irq 40
_irq9:
	irq 41
_irq10:
	irq 42
_irq11:
	irq 43
_irq12:
	irq 44
_irq13:
	irq 45
_irq14:
	irq 46
_irq15:
	irq 47

extern _irq_handler
_irq_common:
	pusha
	push ds
	push es
	push fs
	push gs
	mov eax, esp
	push eax
	call _irq_handler
	pop eax
	pop gs
	pop fs
	pop es
	pop ds
	popa
	add esp, 8 ; pop err_code and int_nr
	iret
