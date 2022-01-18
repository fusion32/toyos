#include "system.h"

struct idt_entry{
	u16 base_low;
	u16 code_selector;
	u8 always0;
	u8 flags;
	u16 base_high;
} __attribute__((packed, aligned(8)));

struct idt_ptr{
	u16 limit;
	u32 base;
} __attribute__((packed));

static struct idt_entry *idt = 0x00000000;
void idt_set(u32 nr, u32 base){
	struct idt_entry *entry = &idt[nr];
	entry->base_low = base & 0xFFFF;
	entry->code_selector = 0x08; // based on the gdt (constant for now)
	entry->always0 = 0;
	entry->flags = 0x8E; // present + ring 0 + type (constant for now)
	entry->base_high = (base >> 16) & 0xFFFF;
}

void putd(u32 d){
	putb((d >> 24) & 0xFF);
	putb((d >> 16) & 0xFF);
	putb((d >> 8) & 0xFF);
	putb(d & 0xFF);
}

void idt_init(void){
	struct idt_ptr idtp = {.limit = 0x07FF, .base = 0x00000000 };
	memset(idt, 0, sizeof(idt));
	isr_install();
	irq_install();
	idt_load(&idtp);
}
