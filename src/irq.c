#include "system.h"

extern void irq0(void);
extern void irq1(void);
extern void irq2(void);
extern void irq3(void);
extern void irq4(void);
extern void irq5(void);
extern void irq6(void);
extern void irq7(void);
extern void irq8(void);
extern void irq9(void);
extern void irq10(void);
extern void irq11(void);
extern void irq12(void);
extern void irq13(void);
extern void irq14(void);
extern void irq15(void);

static void *irq_callbacks[] = {
	0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0,
};

void irq_install_callback(u32 nr, void *callback){
	irq_callbacks[nr] = callback;
}

void irq_handler(struct interrupt_state *s){
	//puts("IRQ ");
	//putb((u8)(s->int_nr - 0x20));
	//puts("\n");

	void *(*callback)(struct interrupt_state*);
	callback = irq_callbacks[s->int_nr - 0x20];
	if(callback)
		callback(s);

	// send EOI to slave PIC if it was cascaded from it
	if(s->int_nr >= 40)
		outportb(0x00A0, 0x20);
	// send EOI to master PIC always
	outportb(0x0020, 0x20);
}

#if 0
void irq_enable_all(void){
	/* mov al, 0x00
	 * out 0xA1, al
	 * mov al, 0x00
	 * out 0x21, al
	 */
	outportb(0x00A1, 0x00);
	outportb(0x0021, 0x00);
}

void irq_disable_all(void){
	/* mov al, 0xFF
	 * out 0xA1, al
	 * mov al, 0xFB
	 * out 0x21, al
	 */
	outportb(0x00A1, 0xFF);
	outportb(0x0021, 0xFB);
}
#endif

void irq_install(void){
	idt_set(32, (u32)irq0);
	idt_set(33, (u32)irq1);
	idt_set(34, (u32)irq2);
	idt_set(35, (u32)irq3);
	idt_set(36, (u32)irq4);
	idt_set(37, (u32)irq5);
	idt_set(38, (u32)irq6);
	idt_set(39, (u32)irq7);
	idt_set(40, (u32)irq8);
	idt_set(41, (u32)irq9);
	idt_set(42, (u32)irq10);
	idt_set(43, (u32)irq11);
	idt_set(44, (u32)irq12);
	idt_set(45, (u32)irq13);
	idt_set(46, (u32)irq14);
	idt_set(47, (u32)irq15);
}
