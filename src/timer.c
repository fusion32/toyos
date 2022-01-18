#include "system.h"

static u32 freq = 18;

// for some reason we need to tag this as volatile
// or the compiler will optimize away the memory
// read inside timer_wait
static volatile u32 timer_ticks = 0;

static void timer_callback(struct interrupt_state *s){
	timer_ticks += 1;
}

void timer_freq(u32 hz){
	u32 divisor = 1193180 / hz;
	if(divisor > 0xFFFF)
		divisor = 0xFFFF;
	else if(divisor == 0)
		divisor = 1;
	freq = 1193180 / divisor;
	outportb(0x0043, 0x36);
	outportb(0x0040, divisor & 0xFF);
	outportb(0x0040, (divisor >> 8) & 0xFF);
}

void timer_install(void){
	irq_install_callback(0, timer_callback);
}

void timer_wait(u32 secs){
	u32 now = timer_ticks;
	u32 end = timer_ticks + secs * freq;
	while(now < end)
		now = timer_ticks;
}
