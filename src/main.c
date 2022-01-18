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
	// init kernel
	video_init();
	idt_init();
	timer_install();
	keyboard_install();

	// reenable interrupts
	nmi_enable();
	irq_enable_all();
	sti();


	for(;;){
		u32 i;
		for(i = 0x00; i <= 0xFF; i += 1){
			if((i & 0xF) == ((i >> 4) & 0xF))
				continue;
			timer_wait(1);
			settextcolor((i >> 4) & 0x0F, i & 0x0F);
			puts("one second has passed\n");
		}
	}

	for(;;);
}
