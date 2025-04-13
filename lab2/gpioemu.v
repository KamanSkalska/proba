module gpioemu(n_reset, saddress[15:0], srd, swr, sdata_in[31:0], sdata_out[31:0],
gpio_in[31:0], gpio_latch, gpio_out[31:0], clk,
counter_out, zliczanie_out, bitstatus_out);

	// Definicje sygnalow laczacych
	input n_reset;
	input [15:0] saddress;
	input srd;
	input swr;
	input [31:0] sdata_in;
	input [31:0] gpio_in;
	input gpio_latch;
	
	output [31:0] sdata_out;	
	output [31:0] gpio_out;
	
	reg 	[31:0] 	gpio_in_s;
	reg 	[31:0] 	gpio_out_s;
	reg 	[31:0] 	sdata_out_s;
	
	//output[31:0] gpio_in_s_insp; 
	input 			clk;
	
	//Definicje dodatkowych elementow wewnetrznych 
	reg 	[7:0] counter;
	reg 	zliczanie;
	reg 	bitstatus;
	reg INT_bitstatus;
	reg count_direction_s; 
	
	
	output  zliczanie_out;
	output bitstatus_out;
	output [7:0] counter_out;
	output INT_bitstatus_out;
	output count_direction;

	//Przypisania
	initial counter = 8'd195;
	
	assign zliczanie_out = zliczanie;
	assign INT_bitstatus_out = INT_bitstatus;
	assign bitstatus_out = bitstatus;
	assign counter_out = counter;
	assign sdata_out = sdata_out_s;
	assign gpio_out = gpio_out_s;
	assign count_direction = count_direction_s;
	
	
//Reset poszczegolnych elementow (n_reset 1->0)
	always @(negedge n_reset) begin
		// gpio_latch <= 0;
		gpio_in_s <= 0;
		gpio_out_s <= 0;
		sdata_out_s <= 0;
		counter <= 8'd195;
		zliczanie <= 1;
		bitstatus <= 0;
		INT_bitstatus <= 0;
		count_direction_s <= 0;
	end
	
//Zapis stanu w reakcji na gpio_latch
	always @(posedge gpio_latch) begin
		gpio_in_s[31:0] <= gpio_in[31:0];
	end
	

//Licznik 8-bitowy, zliczajacy w dol od wartosci poczatkowej 195
	always @(posedge clk) begin
    if (zliczanie) begin
        if (counter == 8'd0) begin
            INT_bitstatus <= 1; // Ustawienie bitu INT przy zerze
        end
        else begin
            if (count_direction_s) begin
                counter <= counter + 8'd1;
            end else begin
                counter <= counter - 8'd1;
            end
        end
    end
end
	
//Akcje wykonywane na zmiane parametru swr (zapis)
		always @(posedge swr) begin
		if (saddress == 16'ha7c) begin
			if (sdata_in[6]) begin // Restart licznika
				counter <= 8'd195;
				INT_bitstatus <= 0;
			end
			if (sdata_in[8]) begin // Zmiana kierunku
				count_direction_s <= ~count_direction_s;
			end
    end
// zapis os 1 0xa74
		else if(saddress == 16'ha74) begin
			gpio_out_s <= 0;
			gpio_out_s[3:0] <= sdata_in[16:13];
		end
// zapis os 2 0xa78
		else if(saddress == 16'ha78) begin
			gpio_out_s <= 0;
			gpio_out_s[15:12] <= sdata_in[4:1];
		end
		else begin
			gpio_out_s[31:0] <= 32'd0;
		end
	end
	
//Akcje wykonywane na zmiane parametru srd (odczyt)
	always @(posedge srd) begin
		if(saddress == 16'ha7c) begin
			//sdata_out_s[18] <= INT_bitstatus;
		end
// odczyt os 1 0xa74
		else if(saddress == 16'ha74) begin
			//sdata_out_s <= 0;
			sdata_out_s[8:5] <= gpio_in_s[3:0];
		end
// oczyt os 2 0xa78
		else if(saddress == 16'ha78) begin
			//sdata_out_s <= 0;
			sdata_out_s[10:7] <= gpio_in_s[15:12];
		end
		else begin
			//sdata_out_s[31:0] <= 32'b0;
		end
	end
	
endmodule