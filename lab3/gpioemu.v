/* verilator lint_off UNUSED */
/* verilator lint_off MULTIDRIVEN */
/* verilator lint_off DECLFILENAME */

module gpioemu(n_reset, saddress[15:0], srd, swr, sdata_in[31:0], sdata_out[31:0],
gpio_in[31:0], gpio_latch, gpio_out[31:0], clk,
counter_out, zliczanie_out, bitstatus_out);
	// inputs
	input 			n_reset;
	input 	[15:0] 	saddress;
	input 			srd;
	input 			swr;
	input 	[31:0] 	sdata_in;
	
	output	[31:0] 	sdata_out;	
	
	input 	[31:0] 	gpio_in;
	input 			gpio_latch;
	
	output 	[31:0] 	gpio_out;
	
	reg 	[31:0] 	gpio_in_s;
	reg 	[31:0] 	gpio_out_s;
	reg 	[31:0] 	sdata_out_s;
	
	input 			clk;
	
	// wlasne
	reg 	[7:0]	counter;
	reg 			zliczanie;
	reg 			bitstatus;
	
	// outputs
	output 			zliczanie_out;
	output			bitstatus_out;
	output 	[7:0]	counter_out;

	assign zliczanie_out = zliczanie;
	assign bitstatus_out = bitstatus;
	assign counter_out = counter;
	assign sdata_out = sdata_out_s;
	assign gpio_out = gpio_out_s;
	
	initial counter = 8'd170;
	
	//odpowiedz na reset (aktywowane przejściem 1->0)
	always @(negedge n_reset) begin
		// gpio_latch <= 0;
		gpio_in_s <= 0;
		gpio_out_s <= 0;
		sdata_out_s <= 0;
		counter <= 8'd170;
		zliczanie <= 0;
		bitstatus <= 0;
	end
	
	// zatrzaskiwanie
	always @(posedge gpio_latch) begin
		gpio_in_s[31:0] <= gpio_in[31:0];
	end
	
	// counter 
	// 8-bitowy, zliczający w przód od wartości początkowej 170 
	always @(posedge clk) begin
		if(zliczanie) begin
			if(counter == 8'd255) begin
				bitstatus <= ~bitstatus;
			end
			counter <= counter + 8'd1;
		end
		
	end
	
	// zapis
	always @(posedge swr) begin
		// zmiana bitu statusu dostępnego pod adresem 0x0388 z przesunięciem 18 bitów - zatrzymanie zliczania
		if(saddress == 16'h0388) begin
			if(sdata_in[18] == 0) begin
				zliczanie <= 0;
			end
			if(sdata_in[20] == 1) begin
				counter <= 8'd170;
				zliczanie <= 1;
			end
		end
		// oś 1 0x01A4
		else if(saddress == 16'h01a4) begin
			gpio_out_s[3:0]	 <= sdata_in[16:13];
		end
		// oś 2 0x01D4
		else if(saddress == 16'h01d4) begin
			gpio_out_s[15:12] <= sdata_in[4:1];
		end
	end
	
	// odczyt
	always @(posedge srd) begin
		if(saddress == 16'h0388) begin
			sdata_out_s[18] <= bitstatus;
			sdata_out_s[7:0] <= counter;
		end
		// oś 1
		else if(saddress == 16'h01a4) begin
			sdata_out_s[16:13] <= gpio_in_s[3:0];
		end
		// oś 2
		else if(saddress == 16'h01d4) begin
			sdata_out_s[4:1] <= gpio_in_s[15:12];
		end
		else begin
			sdata_out_s[31:0] <= 32'b0;
		end
	end
	
endmodule
