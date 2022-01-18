#include "system.h"

static u8 scan2ascii[128] = {
	0,
	0, '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '=', '\b',
	'\t', 'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '[', ']', '\n',
	0, 'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';', '\'', '`',
	0, '\\', 'z', 'x', 'c', 'v', 'b', 'n', 'm', ',', '.', '/', 0,
	'*', 0, ' ', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	'-', 0, 0, 0, '+', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
};

static void keyboard_callback(struct interrupt_state *s){
	u8 scancode = inportb(0x0060);
	if(scancode & 0x80){
		// key up
	}else{
		// key down
		u8 ch = scan2ascii[scancode];
		if(ch)
			putch(scan2ascii[scancode]);
	}
}

void keyboard_install(void){
	/*
	u8 status;
	do{
		status = inportb(0x0064);
	}while(status & 2);
	*/

	irq_install_callback(1, keyboard_callback);
}
