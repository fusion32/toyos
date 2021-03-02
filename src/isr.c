#include "system.h"

extern void isr0(void);
extern void isr1(void);
extern void isr2(void);
extern void isr3(void);
extern void isr4(void);
extern void isr5(void);
extern void isr6(void);
extern void isr7(void);
extern void isr8(void);
extern void isr9(void);
extern void isr10(void);
extern void isr11(void);
extern void isr12(void);
extern void isr13(void);
extern void isr14(void);
extern void isr15(void);
extern void isr16(void);
extern void isr17(void);
extern void isr18(void);
extern void isr19(void);
extern void isr20(void);
extern void isr21(void);
extern void isr22(void);
extern void isr23(void);
extern void isr24(void);
extern void isr25(void);
extern void isr26(void);
extern void isr27(void);
extern void isr28(void);
extern void isr29(void);
extern void isr30(void);
extern void isr31(void);

void isr_handler(struct interrupt_state *s){
	puts("ISR ");
	putb((u8)s->int_nr);
	puts("\n");
	sti();
}

void isr_install(void){
	idt_set(0, (u32)isr0);
	idt_set(1, (u32)isr1);
	idt_set(2, (u32)isr2);
	idt_set(3, (u32)isr3);
	idt_set(4, (u32)isr4);
	idt_set(5, (u32)isr5);
	idt_set(6, (u32)isr6);
	idt_set(7, (u32)isr7);
	idt_set(8, (u32)isr8);
	idt_set(9, (u32)isr9);
	idt_set(10, (u32)isr10);
	idt_set(11, (u32)isr11);
	idt_set(12, (u32)isr12);
	idt_set(13, (u32)isr13);
	idt_set(14, (u32)isr14);
	idt_set(15, (u32)isr15);
	idt_set(16, (u32)isr16);
	idt_set(17, (u32)isr17);
	idt_set(18, (u32)isr18);
	idt_set(19, (u32)isr19);
	idt_set(20, (u32)isr20);
	idt_set(21, (u32)isr21);
	idt_set(22, (u32)isr22);
	idt_set(23, (u32)isr23);
	idt_set(24, (u32)isr24);
	idt_set(25, (u32)isr25);
	idt_set(26, (u32)isr26);
	idt_set(27, (u32)isr27);
	idt_set(28, (u32)isr28);
	idt_set(29, (u32)isr29);
	idt_set(30, (u32)isr30);
	idt_set(31, (u32)isr31);
}
