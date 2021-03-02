#ifndef SYSTEM_H_
#define SYSTEM_H_

#define NULL ((void*)0)

typedef unsigned char u8;
typedef signed char i8;
typedef unsigned short u16;
typedef signed short i16;
typedef unsigned int u32;
typedef signed int i32;
typedef unsigned long long u64;
typedef signed long long i64;

// head.s
extern void memcpy(void *dst, void *src, u32 count);
extern void memset(void *dst, u32 val, u32 count);
extern void memset16(void *dst, u32 val, u32 count);
//extern void gdt_load(void *gdtp);
extern void idt_load(void *idtp);

#define cli() __asm__ __volatile__ ("cli")
#define sti() __asm__ __volatile__ ("sti")
extern void nmi_enable(void);
extern void nmi_disable(void);
extern void irq_enable_all(void);
extern void irq_disable_all(void);

// idt.c
struct interrupt_state{
	u32 gs, fs, es, ds; // explicitly pushed
	u32 edi, esi, ebp, unrelated_esp, ebx, edx, ecx, eax; // pusha
	u32 int_nr, err_code; // explicitly pushed
	u32 eip, cs, eflags, esp, ss; // pushed by the processor on interrupt
};
extern void idt_set(u32 nr, u32 base);
extern void idt_init(void);

// irq.c
extern void irq_install(void);

// isr.c
extern void isr_install(void);

// gdt.c

// main.c
extern u8 inportb(u16 port);
extern void outportb(u16 port, u8 data);
extern void putb(u8 b);

// vga.c
extern void cls(void);
extern void putch(u8 ch);
extern void puts(const char *str);
extern void settextcolor(u8 background, u8 foreground);
extern void init_video(void);


#endif //SYSTEM_H_
