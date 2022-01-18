
print_nl:
	xor bh, bh
	mov ah, 0x0E
	mov al, 0x0A ; new line
	int 0x10
	mov al, 0x0D ; carriage return
	int 0x10
	ret

; di = ptr to nul-terminated string
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

getchar:
	mov ah, 0
	int 0x16
	ret

getip:
	pop ax
	push ax
	ret

boot_move:
; move boot code to base address 0x10000
	mov ax, BOOTSEG
	mov ds, ax
	mov ax, INITSEG
	mov es, ax
	mov si, 0
	mov di, 0
	mov cx, 0x80 ; 128 dwords = 512 bytes
	cld
	rep
	movsd
	jmp INITSEG:.init

_gdt32_null:
	db 0x00, 0x00	; limit 0-15 bits
	db 0x00, 0x00	; base 0-15 bits
	db 0x00			; base 16-23 bits
	db 0x00			; access
	db 0x00			; flags (4 high bits), limit 16-19 bits (4 low bits)
	db 0x00			; base 24-31 bits

%macro idt_entry 2
	mov edi, %1
	mov esi, %2
	call set_idt_entry
%endmacro

	idt_entry 0, _isr0
	idt_entry 1, _isr1
	idt_entry 2, _isr2
	idt_entry 3, _isr3
	idt_entry 4, _isr4
	idt_entry 5, _isr5
	idt_entry 6, _isr6
	idt_entry 7, _isr7
	idt_entry 8, _isr8
	idt_entry 9, _isr9
	idt_entry 10, _isr10
	idt_entry 11, _isr11
	idt_entry 12, _isr12
	idt_entry 13, _isr13
	idt_entry 14, _isr14
	idt_entry 15, _isr15
	idt_entry 16, _isr16
	idt_entry 17, _isr17
	idt_entry 18, _isr18
	idt_entry 19, _isr19
	idt_entry 20, _isr20
	idt_entry 21, _isr21
	idt_entry 22, _isr22
	idt_entry 23, _isr23
	idt_entry 24, _isr24
	idt_entry 25, _isr25
	idt_entry 26, _isr26
	idt_entry 27, _isr27
	idt_entry 28, _isr28
	idt_entry 29, _isr29
	idt_entry 30, _isr30
	idt_entry 31, _isr31

%undef idt_entry

; edi = entry nr
; esi = base addr
set_idt_entry:
	shl edi, 3 ; edi *= 8

	; set base address
	mov eax, esi
	mov word [edi + 0x00], ax
	shl eax, 16
	mov word [edi + 0x06], ax

	; cs (based on gdt and constant for now)
	mov word [edi + 0x02], 0x0008
	; this is always zero
	mov byte [edi + 0x04], 0x00
	; present + ring + type (constant for now)
	mov byte [edi + 0x05], 0x8E
	
	ret

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
