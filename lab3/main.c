#define RAW_SPACE(addr)     (*(volatile unsigned long *)(addr))

//Ten fragment musisz zmodyfikowac samodzielnie
#define SYKOM_CTRL_ADDR     (0x001008c0)		

#define SYKOM_ID_ADDR       ((SYKOM_CTRL_ADDR)+4)
#define SYKOM_UART_ADDR     ((SYKOM_CTRL_ADDR)+8)

// LAB3
#define SYKT_GPIO_ADDR_SPACE 	((SYKOM_CTRL_ADDR)+12)
//#define SYKT_GPIO_CTRL_ADDR 	(SYKT_GPIO_ADDR_SPACE+0xCCCCCCCC) 
// os 1: 0x01a4
#define SYKT_GPIO_OS1_ADDR 	((SYKOM_CTRL_ADDR)+0x01A4) 
// os 2: 0x01d4
#define SYKT_GPIO_OS2_ADDR 	((SYKOM_CTRL_ADDR)+0x01D4) 

// counter bitstatus address
#define SYKT_GPIO_COUNTER_ADDR ((SYKOM_CTRL_ADDR)+0x388)
#define LAST(bits) (bits & 0x1)

#define GET_NTH(bits, nth) (LAST(bits >> nth) << nth)

#define CNT_BS 18

#define u32 unsigned long

#define BAD_ADDR 0x3333

#define SYKOM_EXIT_VAL      (0x00003333)
#define SYKOM_UART_VAL      (0x00008888)
#define HEX_SYMBOLS 	    "0123456789ABCDEF"
#define MASK 0b1111
unsigned char result[8];

void my_simulation_exit(unsigned char ret_code) {
    RAW_SPACE(SYKOM_CTRL_ADDR) = SYKOM_EXIT_VAL | (((unsigned long)ret_code)<<16);
}

void my_putchar(unsigned char c) {
    RAW_SPACE(SYKOM_UART_ADDR)=SYKOM_UART_VAL | ((0x000000FF & (unsigned long)c)<<16);
}

unsigned long my_get_cpu_id(void) {
    return RAW_SPACE(SYKOM_ID_ADDR);
}

void putchars(unsigned char *s) {
	int i = 0;
	while(s[i] != '\0') {
		my_putchar(s[i]);
		i++;
	}
}

char val2hex(unsigned int i) {
    	return HEX_SYMBOLS[i];
}

unsigned char* num2hex(unsigned int n) {
	for(int i=0;i<8;i++) {
		result[8-1-i] = val2hex( (n>>(i*4)) & MASK );
	}
	return result;

}


void count() {
	putchars("Start count outer\n");
	u32 bitstatus = GET_NTH(RAW_SPACE(SYKT_GPIO_COUNTER_ADDR), CNT_BS);
	
	putchars("\n");
	u32 licznik = RAW_SPACE(SYKT_GPIO_COUNTER_ADDR);
//	while(1) {
//		putchars("LICZNIK=");
//		u32 licznik = RAW_SPACE(SYKT_GPIO_COUNTER_ADDR);
//		putchars(num2hex(licznik));
//		putchars("\n");
//	}
	putchars(num2hex(licznik));
	putchars("\n");
	
	putchars("Started counter\n");
	putchars("BITSTATUS=");
	putchars(num2hex(bitstatus));
	putchars("\n#########\n");

	
	// zapis - "start command"
	RAW_SPACE(SYKT_GPIO_COUNTER_ADDR) = (u32)(1 << 20);
	
	// odczyt
//	while((LAST(RAW_SPACE(SYKT_GPIO_COUNTER_ADDR) >> CNT_BS) << CNT_BS) != (u32)(1<<20)) {
//		putchars("Waiting for startcount...\n");
//	}
	
	u32 current_bitstatus = GET_NTH(RAW_SPACE(SYKT_GPIO_COUNTER_ADDR), CNT_BS);
	
	while(current_bitstatus == bitstatus) {
		current_bitstatus = GET_NTH(RAW_SPACE(SYKT_GPIO_COUNTER_ADDR), CNT_BS);
		putchars("Counting...\n");
		putchars("\n");
		putchars("LICZNIK=");
		putchars(num2hex(RAW_SPACE(SYKT_GPIO_COUNTER_ADDR)));
		putchars("\n");
	}
	
	putchars("BITSTATUS=");
	putchars(num2hex(current_bitstatus >> CNT_BS));
	putchars("\n");
	putchars("End count\n");
}

// processor -> gpio (sdata_in -> gpio_out)
void os1_zapis() {
	putchars("Os 1\nADDR=0x01A4\nProcessor (przesuniecie 13) -> GPIO (4 najmlodsze bity):\n\n######\nTEST ZAPISU:\n#####\n\n");
	u32 cnt = 0;
	u32 przesuniecie = 13;
	for(;;) {
		if(cnt > 255) {
			cnt = 0;
		}
		cnt = cnt + 1;
		RAW_SPACE(SYKT_GPIO_OS1_ADDR) = cnt << przesuniecie;
		putchars("Ustawiam wartosc na: ");
		putchars(num2hex(cnt));
		putchars("\n");
	}
}

// gpio -> processor (gpio_in -> sdata_out)
void os1_odczyt() {
	putchars("Os 1\nADDR=0x01A4\nGPIO (4 najmlodsze bity) -> Processor (przesuniecie 13):\n\n######\nTEST ODCZYTU:\n#####\n\n");
	
	for(;;) {
		u32 current_value = RAW_SPACE(SYKT_GPIO_OS1_ADDR);
		putchars("Wartosc na magistrali procesora: ");
		putchars(num2hex(current_value));
		putchars("\n\n");
	}
	
	putchars("Exited.");
}

// processor -> gpio (sdata_in -> gpio_out)
void os2_zapis() {
	putchars("Os 2\nADDR=0x01D4\nProcessor (przesuniecie 1) -> GPIO (4 najstarsze bity):\n\n######\nTEST ZAPISU:\n#####\n\n");
	u32 cnt = 0;
	u32 przesuniecie = 1;
	for(;;) {
		if(cnt > 255) {
			cnt = 0;
		}
		cnt = cnt + 1;
		RAW_SPACE(SYKT_GPIO_OS2_ADDR) = cnt << przesuniecie;
		putchars("Ustawiam wartosc na: ");
		putchars(num2hex(cnt));
		putchars("\n");
	}
}

// processor -> gpio (gpio_in -> sdata_out)
void os2_odczyt() {
	putchars("Os 2\nADDR=0x01D4\nGPIO (4 najstarsze bity) -> Processor (przesuniecie 1):\n\n######\nTEST ODCZYTU:\n#####\n\n");
	
	for(;;) {
		u32 current_value = RAW_SPACE(SYKT_GPIO_OS2_ADDR);
		putchars("Wartosc na magistrali procesora: ");
		putchars(num2hex(current_value));
		putchars("\n\n");
	}
	
	putchars("Exited.");
}

// bad address - neutrality test:
// gpio -> processor
void zly_addr_odczyt() {
	putchars("TEST ZLEGO ADRESU - ODCZYT\nADDR=0x3333\n");
	
	for(;;) {
		u32 current_value = RAW_SPACE(BAD_ADDR);
		putchars("Wartosc na magistrali procesora: ");
		putchars(num2hex(current_value));
		putchars("\n\n");
	}
	
}

int main(void) {
    putchars("RISCV-APP: test ("__FILE__", "__DATE__", "__TIME__")\n");
    
    // TESTY: `ODKOMENTUJ` TEST, ABY GO WYKONAÆ
    
    // counter test
	//count();
	
	// zapis os 1
	//os1_zapis();
	
	// odczyt os 1
	//os1_odczyt();
	
	// zapis os2
	//os2_zapis();
	
	// odczyt os2
	//os2_odczyt();
	
	// odczyt zly adres
	zly_addr_odczyt();
	
	// Closing
	putchars("Closing simulation...\n");
	my_simulation_exit((unsigned char)SYKOM_EXIT_VAL);

    return 0;
}

