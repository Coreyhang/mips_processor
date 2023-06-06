// registers

module registers(
	input 			clk,
	input				reset,
	input				wr,
	input				re,
	input[4:0]		addr_rs,
	input[4:0]		addr_rt,
	input[4:0]    	addr_w,
	output[31:0]	data_rs,
	output[31:0]	data_rt,
	input[31:0]		data_w
);
  
  reg[31:0] register [31:0]; 
 
  assign data_rs = re ? register[addr_rs] : 0;
 
  assign data_rt = re ? register[addr_rt] : 0;
 
 
	always@(posedge clk or negedge reset)
	 begin
		if (~reset)
		begin
        register[0  ] <= 32'd0;
        register[1  ] <= 32'd0;
        register[2  ] <= 32'd0;
        register[3  ] <= 32'd0;
        register[4  ] <= 32'd0;
        register[5  ] <= 32'd0;
        register[6  ] <= 32'd0;
        register[7  ] <= 32'd0;
        register[8  ] <= 32'd0;
        register[9  ] <= 32'd0;
        register[10 ] <= 32'd0;
        register[11 ] <= 32'd0;
        register[12 ] <= 32'd0;
        register[13 ] <= 32'd0;
        register[14 ] <= 32'd0;
        register[15 ] <= 32'd0;
        register[16 ] <= 32'd0;
        register[17 ] <= 32'd0;
        register[18 ] <= 32'd0;
        register[19 ] <= 32'd0;
        register[20 ] <= 32'd0;
        register[21 ] <= 32'd0;
        register[22 ] <= 32'd0;
        register[23 ] <= 32'd0;
        register[24 ] <= 32'd0;
		  register[25 ] <= 32'd0;
        register[26 ] <= 32'd0;
        register[27 ] <= 32'd0;
        register[28 ] <= 32'd0;
        register[29 ] <= 32'd0;
        register[30 ] <= 32'd0;
        register[31 ] <= 32'd0;
		end
		else begin
			if(wr)
				register[addr_w]<= data_w; 
		end
	 end

	
endmodule
