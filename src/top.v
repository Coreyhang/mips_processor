// processer top


module top(
	input			clk,
	input			nrst
	);

	// control signal
	wire [1:0] C_PCsel;				// ID	
	wire C_ALUsrc1;					// EX
	wire [1:0] C_ALUsrc2;			// EX
	wire [1:0] C_RegDst;					// EX
	wire [1:0] C_ALUop;				// EX
	wire C_ALUout;					// EX
	wire C_MemRead, C_MemWrite;		// MEM
	wire C_RegWrite, C_MemtoReg;	// WB

	// forwarding signal
	reg F_JrSel;
	reg [1:0] F_RsSel, F_RtSel;
	reg [1:0] F_ALUSel1, F_ALUSel2;

	// IF
	reg [31:0] pc;
	reg [31:0] next_pc;
	wire [31:0] pc_plus4, pc_j, pc_jr, pc_eq;
	wire[31:0] instruction;
	reg stall;						// stall for one cycle (load use)

	// IF/ID
	reg [31:0] IFID_pc_plus4;
	reg [31:0] IFID_instruction;

	// ID
	wire rs_not_equal_rt;					// rs data not equal to rt (used by controller)
	wire is_nop;							// NOP
	wire [31:0] reg_data_rs, reg_data_rt;	// data from reg
	reg [31:0] data_rs, data_rt;			// final data
	wire [31:0] sign_extend, zero_extend;	// extend immediate data
	wire [31:0] reg_data_w;					// data to write to reg
	wire [4:0] reg_addr_w;					// addr to write in reg

	// ID/EX
	reg [31:0] IDEX_pc_plus4;
	reg [31:0] IDEX_data_rs, IDEX_data_rt;
	reg [31:0] IDEX_sign_extend, IDEX_zero_extend;
	reg [4:0] IDEX_addr_rt, IDEX_addr_rd;

	reg [4:0] IDEX_instruction_sa;			// for ALU use
	reg [3:0] IDEX_instruction_op;
	reg [5:0] IDEX_instruction_funct;

	reg IDEX_EX_C_ALUsrc1;					// EX
	reg [1:0] IDEX_EX_C_ALUsrc2;			// EX
	reg [1:0] IDEX_EX_C_RegDst;					// EX
	reg [1:0] IDEX_EX_C_ALUop;				// EX
	reg IDEX_EX_C_ALUout;					// EX
	reg IDEX_M_C_MemRead, IDEX_M_C_MemWrite;		// MEM
	reg IDEX_WB_C_RegWrite, IDEX_WB_C_MemtoReg;	// WB

	reg [4:0] IDEX_register_rs, IDEX_register_rt, IDEX_register_rd;		// for Forwarding

	// EX
	wire [31:0] alu_out, lui_out, alu_final_out, alu_in1;
	reg [31:0] alu_src2_out, alu_src1_out, alu_in2;
	reg [4:0] addr_reg_dst;
	wire [4:0] C_ALUctl;					// ALU control

	// EX/MEM
	reg [31:0] EXMEM_data_rt, EXMEM_ALUout;
	reg [4:0] EXMEM_addr_reg_write;

	reg EXMEM_M_C_MemRead, EXMEM_M_C_MemWrite;		// MEM
	reg EXMEM_WB_C_RegWrite, EXMEM_WB_C_MemtoReg;	// WB

	reg [4:0] EXMEM_register_rd;					// for Forwarding

	// MEM
	wire [31:0] dcache_read_data;

	// MEM/WB
	reg [31:0] MEMWB_data_dcache, MEMWB_data_ALUout;
	reg [4:0] MEMWB_addr_reg_write;

	reg MEMWB_WB_C_RegWrite, MEMWB_WB_C_MemtoReg;	// WB

	reg [4:0] MEMWB_register_rd;					// for Forwarding

	// WB


	// ****** controller ******* //

	controller controller_u(.op(IFID_instruction[31:26]), .funct(IFID_instruction[5:0]), 
							.rs_not_equal_rt(rs_not_equal_rt), .is_nop(is_nop),
							.pc_sel(C_PCsel), .reg_dst(C_RegDst), .alu_src1(C_ALUsrc1), 
							.alu_src2(C_ALUsrc2), .alu_op(C_ALUop), .alu_out(C_ALUout),
							.mem_read(C_MemRead), .mem_write(C_MemWrite), .mem_to_reg(C_MemtoReg),
							.reg_write(C_RegWrite));

	
	// ****** IF ******* //
	
	assign pc_plus4 = pc + 32'd4;
	
	always @(posedge clk or negedge nrst) begin
		if (~nrst)
			pc <= 32'd0;
		else if (stall)
			pc <= pc;
		else
			pc <= next_pc;
	end

	always @( * ) begin
		case(C_PCsel)
			2'd0: next_pc = pc_plus4;
			2'd1: next_pc = pc_eq;
			2'd2: next_pc = pc_j;
			2'd3: next_pc = pc_jr;
			default: next_pc = 32'd0;
		endcase
	end

	icache #(.addr_width(9)) icache_u(.nrst(nrst), .instruction_addr(pc[10:2]), .instruction_data(instruction));
	
	
	// ****** IF/ID ******* //
	
	always @(posedge clk or negedge nrst) begin
		if (~nrst) begin
			IFID_pc_plus4 <= 32'd0; 
			IFID_instruction <= 32'd0;
		end
		else begin
			IFID_pc_plus4 <= pc_plus4;
			IFID_instruction <= instruction;
		end
	end

	// ****** ID ******* //

	assign sign_extend[31:16] = IFID_instruction[15] ? {16{1'b1}} : {16{1'b0}};		// sign extend immediate number
	assign sign_extend[15:0] = IFID_instruction[15:0];
	assign zero_extend[31:16] = {16{1'b0}};											// zero extend immediate number
	assign zero_extend[15:0] = IFID_instruction[15:0];

	assign pc_j = {IFID_pc_plus4[31:28], IFID_instruction[25:0], 2'b00};			// pc addr for J/Jal
	assign pc_eq = IFID_pc_plus4 + {sign_extend[29:0], 2'b00};						// pc addr for Beq Bne
	assign pc_jr = F_JrSel ? EXMEM_ALUout : data_rs;								// PC addr for Jr
	
	always @( * )begin																		// for data hazards
		case (F_RsSel)
			2'd0: data_rs = reg_data_rs;
			2'd1: data_rs = reg_data_w;
			2'd2: data_rs = EXMEM_ALUout;
			default:  data_rs = 0;
		endcase
	end
	
	always @( * )begin
		case (F_RtSel)
			2'd0: data_rt = reg_data_rt;
			2'd1: data_rt = reg_data_w;
			2'd2: data_rt = EXMEM_ALUout;
			default:  data_rt = 0;
		endcase
	end


	assign rs_not_equal_rt = | (data_rs ^ data_rt);									// for Beq/Bne

	assign is_nop = (~(| IFID_instruction[25:0])) | stall;							// is instruction[25:0] is all zero ?
	
	registers registers_u(	.clk(clk), .reset(nrst), .wr(MEMWB_WB_C_RegWrite), .re(1'b1), .addr_rs(IFID_instruction[25:21]), 
							.addr_rt(IFID_instruction[20:16]), .addr_w(reg_addr_w), .data_rs(reg_data_rs), .data_rt(reg_data_rt), 
							.data_w(reg_data_w));

	always @( * )begin
		if (IDEX_M_C_MemRead & ((IDEX_register_rt == IFID_instruction[25:21]) | (IDEX_register_rt == IFID_instruction[20:16])))
			stall = 1;
		else
			stall = 0;
	end
	
	// ****** ID/EX ******* //

	always @(posedge clk or negedge nrst)begin
		if (~nrst)begin
			IDEX_pc_plus4 <= 32'd0;
			IDEX_data_rs <= 32'd0;
			IDEX_data_rt <= 32'd0;
			IDEX_sign_extend <= 32'd0;
			IDEX_zero_extend <= 32'd0;
			IDEX_addr_rt <= 5'd0;
			IDEX_addr_rd <= 5'd0;
			IDEX_EX_C_ALUsrc1 <= 0;			// control signals
		 	IDEX_EX_C_ALUsrc2 <= 0;
			IDEX_EX_C_RegDst <= 0;
			IDEX_EX_C_ALUop <= 0;
			IDEX_EX_C_ALUout <= 0;
			IDEX_M_C_MemRead <= 0;
			IDEX_M_C_MemWrite <= 0;
			IDEX_WB_C_RegWrite <= 0;
			IDEX_WB_C_MemtoReg <= 0;
			IDEX_instruction_op <= 0;		// for ALU use
			IDEX_instruction_sa <= 0;
			IDEX_instruction_funct <= 0;
			IDEX_register_rs <= 0;			// for Forwarding
			IDEX_register_rt <= 0;
			IDEX_register_rd <= 0;
		end
		else begin
			IDEX_pc_plus4 <= IFID_pc_plus4;
			IDEX_data_rs <= data_rs;
			IDEX_data_rt <= data_rt;
			IDEX_sign_extend <= sign_extend;
			IDEX_zero_extend <= zero_extend;
			IDEX_addr_rt <= IFID_instruction[20:16];
			IDEX_addr_rd <= IFID_instruction[15:11];
			IDEX_EX_C_ALUsrc1 <= C_ALUsrc1;			// control signals
		 	IDEX_EX_C_ALUsrc2 <= C_ALUsrc2;
			IDEX_EX_C_RegDst <= C_RegDst;
			IDEX_EX_C_ALUop <= C_ALUop;
			IDEX_EX_C_ALUout <= C_ALUout;
			IDEX_M_C_MemRead <= C_MemRead;
			IDEX_M_C_MemWrite <= C_MemWrite;
			IDEX_WB_C_RegWrite <= C_RegWrite;
			IDEX_WB_C_MemtoReg <= C_MemtoReg;
			IDEX_instruction_op <= IFID_instruction[29:26];		// for ALU use
			IDEX_instruction_sa <= IFID_instruction[10:6];
			IDEX_instruction_funct <= IFID_instruction[5:0];
			IDEX_register_rs <= IFID_instruction[25:21];			// for Forwarding
			IDEX_register_rt <= IFID_instruction[20:16];
			IDEX_register_rd <= IFID_instruction[15:11];
		end
	end	
	
	// ****** EX ******* //

	assign alu_in1 = IDEX_EX_C_ALUsrc1 ? IDEX_pc_plus4 : alu_src1_out;
	always @( * ) begin
		case (IDEX_EX_C_ALUsrc2)
			2'd0: alu_in2 = alu_src2_out;
			2'd1: alu_in2 = IDEX_sign_extend;
			2'd2: alu_in2 = IDEX_zero_extend;
			2'd3: alu_in2 = 32'd4;
			default: alu_in2 = 32'd0;
		endcase
	end

	always @( * )begin
		case (F_ALUSel1)
			2'd0: alu_src1_out = IDEX_data_rs;
			2'd1: alu_src1_out = EXMEM_ALUout;
			2'd2: alu_src1_out = reg_data_w;
			default: alu_src1_out = 0;
		endcase
	end
	always @( * )begin
		case (F_ALUSel2)
			2'd0: alu_src2_out = IDEX_data_rt;
			2'd1: alu_src2_out = EXMEM_ALUout;
			2'd2: alu_src2_out = reg_data_w;
			default: alu_src2_out = 0;
		endcase
	end

	assign lui_out = {IDEX_zero_extend[15:0], 16'd0};
	assign alu_final_out = IDEX_EX_C_ALUout ? lui_out : alu_out;

	always @( * )begin
		case (IDEX_EX_C_RegDst)
			2'd0: addr_reg_dst = IDEX_addr_rt;
			2'd1: addr_reg_dst = IDEX_addr_rd;
			2'd2: addr_reg_dst = 31;
			default: addr_reg_dst = 0;
		endcase
	end

	alu_controller alu_controller_u(.alu_op(IDEX_EX_C_ALUop), .op(IDEX_instruction_op), .f(IDEX_instruction_funct), .alu_ctl(C_ALUctl));

	alu alu_u(.alu_ctl(C_ALUctl), .a(alu_in1), .b(alu_in2), .alu_out(alu_out), .sa(IDEX_instruction_sa));

	// ****** EX/MEM ******* //
	
	always @(posedge clk or negedge nrst)begin
		if (~nrst)begin
			EXMEM_data_rt <= 32'd0;
			EXMEM_ALUout <= 32'd0;
			EXMEM_addr_reg_write <= 5'd0;
			EXMEM_M_C_MemRead <= 0;		// control signals
			EXMEM_M_C_MemWrite <= 0;
			EXMEM_WB_C_RegWrite <= 0;
			EXMEM_WB_C_MemtoReg <= 0;
			EXMEM_register_rd <= 0;		// for Forwarding
		end
		else begin
			EXMEM_data_rt <= IDEX_data_rt;
			EXMEM_ALUout <= alu_final_out;
			EXMEM_addr_reg_write <= addr_reg_dst;
			EXMEM_M_C_MemRead <= IDEX_M_C_MemRead;		// control signals
			EXMEM_M_C_MemWrite <= IDEX_M_C_MemWrite;
			EXMEM_WB_C_RegWrite <= IDEX_WB_C_RegWrite;
			EXMEM_WB_C_MemtoReg <= IDEX_WB_C_MemtoReg;
//			EXMEM_register_rd <= IDEX_register_rd;		// for Forwarding
		end
	end	

	// ****** MEM ******* //
	
	dcache dcache_u(.clk(clk), .reset(nrst), .wr(EXMEM_M_C_MemWrite), .re(EXMEM_M_C_MemRead), .addr(EXMEM_ALUout), 
					.wdata(EXMEM_data_rt), .rdata(dcache_read_data));

	// ****** MEM/WB ******* //

	always @(posedge clk or negedge nrst)begin
		if (~nrst)begin
			MEMWB_data_dcache <= 32'd0;
			MEMWB_data_ALUout <= 32'd0;
			MEMWB_addr_reg_write <= 5'd0;
			MEMWB_WB_C_RegWrite <= 0;			// control signals
			MEMWB_WB_C_MemtoReg <= 0;
			MEMWB_register_rd <= 0;				// for Forwarding
		end
		else begin
			MEMWB_data_dcache <= dcache_read_data;
			MEMWB_data_ALUout <= EXMEM_ALUout;
			MEMWB_addr_reg_write <= EXMEM_addr_reg_write;
			MEMWB_WB_C_RegWrite <= EXMEM_WB_C_RegWrite;			// control signals
			MEMWB_WB_C_MemtoReg <= EXMEM_WB_C_MemtoReg;
//			MEMWB_register_rd <= EXMEM_register_rd;				// for Forwarding ????? 需要吗，啊
		end
	end	
	
	// ****** WB ******* //
	
	assign reg_data_w = MEMWB_WB_C_MemtoReg ? MEMWB_data_dcache : MEMWB_data_ALUout;
	assign reg_addr_w = MEMWB_addr_reg_write;


	// ****** Forwarding ******* //
	wire EX_ID_forward_en;
	wire MEM_ID_forward_en;

	assign EX_ID_forward_en = EXMEM_WB_C_RegWrite & (| EXMEM_addr_reg_write);
	assign MEM_ID_forward_en = MEMWB_WB_C_RegWrite & (| MEMWB_addr_reg_write);

	always @( * )begin
		if (EX_ID_forward_en & (IDEX_register_rs == EXMEM_addr_reg_write))	// 1a
			F_ALUSel1 = 2'd1;
		else if (MEM_ID_forward_en & (IDEX_register_rs == MEMWB_addr_reg_write))		// 2a
			F_ALUSel1 = 2'd2;
		else
			F_ALUSel1 = 2'd0;
	end

	always @( * )begin
		if (EX_ID_forward_en & (IDEX_register_rt == EXMEM_addr_reg_write))	// 1a
			F_ALUSel2 = 2'd1;
		else if (MEM_ID_forward_en & (IDEX_register_rt == MEMWB_addr_reg_write))		// 2a
			F_ALUSel2 = 2'd2;
		else
			F_ALUSel2 = 2'd0;
	end
	
	always @( * )begin
		if (EXMEM_WB_C_RegWrite & (IFID_instruction[25:21] == EXMEM_addr_reg_write))
			F_RsSel = 2'd2;
		else if (MEMWB_WB_C_RegWrite & (IFID_instruction[25:21] == MEMWB_addr_reg_write))
			F_RsSel = 2'd1;
		else
			F_RsSel = 2'd0;
	end

	always @( * )begin
		if (EXMEM_WB_C_RegWrite & (IFID_instruction[20:16] == EXMEM_addr_reg_write))
			F_RtSel = 2'd2;
		else if (MEMWB_WB_C_RegWrite & (IFID_instruction[20:16] == MEMWB_addr_reg_write))
			F_RtSel = 2'd1;
		else
			F_RtSel = 2'd0;
	end

	wire is_inst_jr;
	assign is_inst_jr = (C_ALUop == 2'b10) & (~IFID_instruction[5]) & (IFID_instruction[3]);
	always @( * )begin
		if (is_inst_jr & (IFID_instruction[25:21] == EXMEM_register_rd))
			F_JrSel = 1;
		else
			F_JrSel = 0;
	end


endmodule
