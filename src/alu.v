// ALU

module alu(
	input [4:0]			alu_ctl,
	input [31:0]		a,
	input [31:0]		b,
	input [4:0]			sa,
	output reg [31:0]	alu_out//,
//	output				overflow
	);
	
//	wire calcu_flow;
//	assign calcu_flow = ((~a[31]) & (~b[31]) & alu_out[31]) | (a[31] & b[31] & (~alu_out[31]));
//	assign overfolw = alu_ctl[4] ? 1'd0 : calcu_flow;
	
	always @( * )begin
		case(alu_ctl[3:0])
			4'd2: alu_out = a + b;
			4'd6: alu_out = a - b;
			4'd0: alu_out = a & b;
			4'd3: alu_out = a ^ b;
			4'd1: alu_out = a | b;
			4'd7: alu_out = (a < b) ? 32'd1 : 32'd0;
			4'd8: alu_out = b << sa;
			4'd12: alu_out = b >> sa;
			default: alu_out = 32'd0;
		endcase
	end

endmodule
			
			