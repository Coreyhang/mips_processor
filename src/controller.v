// controller

module controller
(
    input [5:0] op,
    input [5:0] funct,
    input rs_not_equal_rt,
    input is_nop,
    output reg [1:0] pc_sel,
    output reg [1:0] reg_dst,
    output reg alu_src1,
    output reg [1:0] alu_src2,
    output reg [1:0] alu_op,
    output reg alu_out,
    output reg mem_read,
    output reg mem_write,
    output reg mem_to_reg,
    output reg reg_write
);
    always @( * )begin
        reg_dst = 2'd0;         // default
        alu_src1 = 1'd0;
        alu_src2 = 2'd0;
        alu_out = 1'd0;
        alu_op = 2'd0;
        mem_read = 1'd0;
        mem_write = 1'd0;
        mem_to_reg = 1'd0;
        pc_sel = 2'd0;
        reg_write = 1'd0;
        case (op[5])
            1'd1: begin                         // lw sw
                pc_sel = 2'd0;
                reg_dst = 2'd0;
                alu_src1 = 1'd0;
                alu_src2 = 2'd1;
                alu_out = 1'd0;
                alu_op = 2'd0;
                mem_to_reg = 1'd1;
                if ( op[3] )begin   // sw
                    mem_read = 1'd0;
                    mem_write = 1'd1;
                    reg_write = 1'd0;
                end
                else begin          // lw
                    mem_read = 1'd1;
                    mem_write = 1'd0;
                    reg_write = 1'd1;
                end
            end
            1'd0:  begin
                case ( | op[3:1] )
                    1'd0: begin                 // R type
                        if (is_nop)begin
                            reg_dst = 2'd0;         // nop
                            alu_src1 = 1'd0;
                            alu_src2 = 2'd0;
                            alu_out = 1'd0;
                            alu_op = 2'd0;
                            mem_read = 1'd0;
                            mem_write = 1'd0;
                            mem_to_reg = 1'd0;
                            pc_sel = 2'd0;
                            reg_write = 1'd0;
                        end
                        else begin
                            reg_dst = 2'd1;
                            alu_src1 = 1'd0;
                            alu_src2 = 2'd0;
                            alu_out = 1'd0;
                            alu_op = 2'd2;
                            mem_read = 1'd0;
                            mem_write = 1'd0;
                            mem_to_reg = 1'd0;
                            if (funct[3] & (~funct[5]))begin
                                pc_sel = 2'd3;  // jr
                                reg_write = 1'd0;
                            end
                            else begin
                                pc_sel = 2'd0;
                                reg_write = 1'd1;
                            end
                        end
                    end
                    1'd1: begin                 // I type
                        alu_op = 2'd1;
                        mem_read = 1'd0;
                        mem_write = 1'd0;
                        mem_to_reg = 1'd0;
 
                        if ((~op[3]) & op[2])begin  // beq bne
                            pc_sel[1] = 0;
                            pc_sel[0] = ~(op[0] ^ rs_not_equal_rt); 
                        end
                        else if ((~op[3]) & (~op[2]))begin  // j jal
                            pc_sel = 2'd2;
                        end
                        else begin
                            pc_sel = 2'd0;
                        end

                        if ( (~op[2]) & op[1] & op[0])begin  // jal
                            reg_dst = 2'd2;
                            alu_src1 = 1'd1;
                        end
                        else begin
                            reg_dst = 2'd0;
                            alu_src1 = 1'd0;
                        end

                        alu_out = & op[3:0];    // lui

                        if ((~op[2]) & (~op[1]))    // addi addiu
                            alu_src2 = 2'd1;
                        else if((~op[2]) & op[1])   // j jal
                            alu_src2 = 2'd3;
                        else
                            alu_src2 = 2'd2;

                        reg_write = ~((~op[3]) & ((op[1] ^ op[0]) | op[2]));  // beq bne j
                    end
                endcase
            end
        endcase
    end


endmodule
