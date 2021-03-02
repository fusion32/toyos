#include "system.h"

/*
inline u8 inportb(u16 port){
	u8 ret;
	__asm__ __volatile__ ("inb %1, %0" : "=a"(ret) : "dN"(port));
	return ret;
}

inline void outportb(u16 port, u8 data){
	__asm__ __volatile__ ("outb %1, %0" :: "dN"(port), "a"(data));
}
*/

void putb(u8 b){
	static u8 conv[16] = {
		'0', '1', '2', '3',
		'4', '5', '6', '7',
		'8', '9', 'A', 'B',
		'C', 'D', 'E', 'F',
	};
	putch(conv[(b >> 4) & 0x0F]);
	putch(conv[b & 0x0F]);
}

void kentry(void){
	u32 i, j;
	init_video();
	idt_init();

	nmi_enable();
	irq_enable_all();
	sti();

/*
	for(i = 0x00; i <= 0xFF; i += 1){
		settextcolor((i >> 4) & 0x0F, i & 0x0F);
		putch('(');
		putb((i >> 4) & 0x0F);
		putch(',');
		putb(i & 0x0F);
		putch(')');
		putch('\n');
		for(j = 0; j < 0x7FFFFFF; j += 1);
	}
*/
	for(;;);
}
