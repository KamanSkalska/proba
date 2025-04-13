`timescale 1ns/100ps

module gpioemu_tb;

	reg n_reset = 1;
	reg [15:0]  saddress = 0;
	reg srd = 0;
	reg swr = 0;
	reg [31:0]  sdata_in = 0;
	reg [31:0]  gpio_in = 0;
	reg gpio_latch = 0;
	reg clk = 0;
	
    wire [7:0]	counter_out;
	wire zliczanie_out;
	wire bitstatus_out;
    wire [31:0] gpio_out;
	wire [31:0] sdata_out;

initial begin
	$dumpfile("gpioemu.vcd");
	$dumpvars(0, gpioemu_tb);
end

initial begin
	forever begin
	#5 clk = ~clk;
	end
end

initial begin
	// test reset
	# 5 n_reset = 0;
	# 5 n_reset = 1;
	
	// test gpio_latch
	# 5 gpio_in = 32'b0101;
	# 5 gpio_latch = 1;
	# 5 gpio_latch = 0;
	
	// test read - good address
	# 5 saddress = 16'ha74;
	# 5 srd = 1;
	# 5 srd = 0;
	
	// test read - bad address	
	# 5 saddress = 16'ha80;
	# 5 srd = 1;
	# 5 srd = 0;
	
	// test change latched value
	# 5 gpio_in = 32'b00001010000000000000;
	# 5 gpio_latch = 1;
	# 5 gpio_latch = 0;
	
	// test read - good address
	# 5 saddress = 16'ha78;
	# 5 srd = 1;
	# 5 srd = 0;
	
	// test read - bad address	
	# 5 saddress = 16'h04c2;
	# 5 srd = 1;
	# 5 srd = 0;
	
	// put new value in sdata_in
	# 5 sdata_in = 32'b10100000000010100;
	
	// address 0x04ax
	// test write - good address
	# 5 saddress = 16'ha78;
	# 5 swr = 1;
	# 5 swr = 0;
	
	// test write - bad address
	# 5 saddress = 16'h04c1;
	# 5 swr = 1;
	# 5 swr = 0;
	
	// address 0x04cx
	// test write - good address
	# 5 saddress = 16'ha74;
	# 5 swr = 1;
	# 5 swr = 0;
	
	// test write - bad address
	# 5 saddress = 16'h04c1;
	# 5 swr = 1;
	# 5 swr = 0;
	
	
	//test counter stop
	# 5 saddress = 16'h1d70;
	# 5 sdata_in = 32'b0000000000000000000;
	# 50 swr 	 = 1;
	# 50 swr 	 = 0;
	# 5 sdata_in = 32'b1000000000000000000;
	
	// test counter reset
	# 5 saddress = 16'h1d70;
	# 5 sdata_in = 32'b100000000000000000000;
	# 5 swr 	 = 1;
	# 5 swr 	 = 0;
	# 5 sdata_in = 32'b0;
	
	// test final reset
	# 5 n_reset = 0;
	# 5 n_reset = 1;
	
	
end

	gpioemu e1(n_reset, saddress, srd, swr, sdata_in, sdata_out,
				gpio_in, gpio_latch, gpio_out, clk,
				counter_out, zliczanie_out, bitstatus_out);
	
	initial #5000 $finish;
endmodule
