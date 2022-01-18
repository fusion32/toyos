#include "system.h"

/* text_ptr should point to a 80x25 matrix of
 * u16's where the high byte is the character's
 * attribute and the low byte is the character
**/
static u16 *text_ptr = (u16*)0xB8000;
static u16 text_attrib = 0x0F00;
static i32 cursor_x = 0;
static i32 cursor_y = 0;

static void scroll_up(void){
	u16 blank = 0x20 | text_attrib;
	memcpy(text_ptr, &text_ptr[80], 80 * 24 * 2);
	memset16(&text_ptr[80 * 24], blank, 80);
	if(cursor_y > 0)
		cursor_y -= 1;
}

static void move_cursor(void){
	u16 i = cursor_x + 80 * cursor_y;
	outportb(0x03D4, 14);
	outportb(0x03D5, (u8)((i >> 8) & 0xFF));
	outportb(0x03D4, 15);
	outportb(0x03D5, (u8)(i & 0xFF));
}

void cls(void){
	u16 blank = 0x20 | text_attrib;
	memset16(text_ptr, blank, 80*25);
	move_cursor();
}

void putch(u8 ch){
	switch(ch){
		case 0x08: // backspace
			if(cursor_x > 0)
				cursor_x -= 1;
			break;

		case 0x09: // tab
			cursor_x = (cursor_x + 7) & ~7;
			break;

		case 0x0A: // new line
			cursor_x = 0;
			cursor_y += 1;
			break;

		case 0x0D: // carriage return
			cursor_x = 0;
			break;

		default: // print character
			text_ptr[cursor_x + 80 * cursor_y] = ch | text_attrib;
			cursor_x += 1;
			break;
	}

	// check for new line
	if(cursor_x >= 80){
		cursor_y += 1;
		cursor_x = 0;
	}

	// check for scroll up
	if(cursor_y >= 25)
		scroll_up();

	move_cursor();
}

void puts(const char *str){
	u8 *p = (u8*)str;
	while(*p){
		putch(*p);
		p += 1;
	}
}

void settextcolor(u8 background, u8 foreground){
	text_attrib =
		((background << 4) & 0xF0)
		| (foreground & 0x0F);
	text_attrib <<= 8;
}

void video_init(void){
	cls();
}
