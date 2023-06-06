// ALU controller

module alu_controller
(
    input [1:0] alu_op,
    input [3:0] op,
    input [5:0] f,          // function
    output [4:0] alu_ctl
);

assign alu_ctl[4] = (alu_op == 2'b01) & (op[2:0] == 3'b001);
assign alu_ctl[3] = (alu_op == 2'b10) & (~f[5]) & (~f[0]);
assign alu_ctl[2] = (alu_op == 2'b10) & (~f[2]) & f[1];
assign alu_ctl[1] = ~( ((alu_op == 2'b10) & ((~f[5]) | (f[2] & (~f[1])))) 
                    | ((alu_op == 2'b01) & op[3] & op[2] & (~op[1])) );
assign alu_ctl[0] = ((alu_op == 2'b10) & (f[3] ^ f[2]) & (f[1] ^ f[0])) | 
                    ((alu_op == 2'b01) & op[2] & (op[1] ^ op[0]));

endmodule