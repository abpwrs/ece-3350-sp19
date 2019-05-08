// ECE:3350 SISC processor project
// main SISC module, part 1
// Cooper Bell, Tina Liu, and Alex Powers 

`timescale 1ns/100ps  

module sisc (clk, rst_f);

  input clk, rst_f;

// declare all internal wires here

// part1 wires
wire [31:0] ir;
wire [31:0] im_to_ir;
wire [3:0] mux_four_to_rf;
wire [3:0] stat_to_control;
wire alu_ctrl_to_stat_enable;
wire [3:0] alu_to_stat;
wire [1:0] control_to_alu;
wire [1:0] control_to_mux_thirty_two_enable;
wire [31:0] alu_result_to_mux_thirty_two;
wire control_to_rf;
wire [31:0] mux_thirty_two_to_rf;
wire [31:0] rsa_to_alu;
wire [31:0] rsb_to_alu;

// part 2 wires
wire sisc_to_branch;
wire [15:0] pc_out_wire;
wire [15:0] br_to_pc;
wire ir_load_wire;
wire pc_sel_wire;
wire pc_write_wire;
wire pc_rst_wire;
wire rd_sel_wire;

// part 3 wires
wire ctrl_to_dm_write_select;
wire [1:0] ctrl_to_mux16_mm_sel;
wire [15:0] mux16_to_dm;
wire [31:0] dm_to_mux32;
wire wr_sel_wire;
wire [3:0] write_reg_wire;
// component instantiation goes here

// done
statreg sreg (
  .clk(clk), 
  .in(alu_to_stat), 
  .enable(alu_ctrl_to_stat_enable), 
  .out(stat_to_control)
  );

// DONE
ctrl control (
  .clk(clk), 
  .rst_f(rst_f), 
  .opcode(ir[31:28]), 
  .mm(ir[27:24]), 
  .stat(stat_to_control), 
  .rf_we(control_to_rf), 
  .alu_op(control_to_alu), 
  .wb_sel(control_to_mux_thirty_two_enable), 
  .br_sel(sisc_to_branch),
  .pc_rst(pc_rst_wire), 
  .pc_write(pc_write_wire), 
  .pc_sel(pc_sel_wire), 
  .ir_load(ir_load_wire), 
  .rd_sel(rd_sel_wire), 
  .dm_we(ctrl_to_dm_write_select), 
  .mm_sel(ctrl_to_mux16_mm_sel),
  .wr_sel(wr_sel_wire)
);

// done
mux4 mux_four (
  .in_a(ir[15:12]), 
  .in_b(ir[23:20]), 
  .sel(rd_sel_wire),
  .out(mux_four_to_rf));

// done
mux32 mux_thirty_two (
  .in_a(alu_result_to_mux_thirty_two), 
  .in_b(dm_to_mux32), 
  .in_c(rsa_to_alu),
  .in_d(rsb_to_alu),
  .sel(control_to_mux_thirty_two_enable), 
  .out(mux_thirty_two_to_rf)
  );

// done
alu arithmetic_logic_unit (
  .clk(clk), 
  .rsa(rsa_to_alu), 
  .rsb(rsb_to_alu), 
  .imm(ir[15:0]), 
  .alu_op(control_to_alu), 
  .alu_result(alu_result_to_mux_thirty_two), 
  .stat(alu_to_stat), 
  .stat_en(alu_ctrl_to_stat_enable)
  );

// done
rf register_file (
  .clk(clk), 
  .read_rega(ir[19:16]), 
  .read_regb(mux_four_to_rf), 
  .write_reg(write_reg_wire), 
  .write_data(mux_thirty_two_to_rf), 
  .rf_we(control_to_rf), 
  .rsa(rsa_to_alu), 
  .rsb(rsb_to_alu)
  );

// done
br branch (
  .pc_inc(pc_out_wire), 
  .imm(ir[15:0]), 
  .br_sel(sisc_to_branch), 
  .br_addr(br_to_pc));

// done
ir instruction_register(
  .clk(clk), 
  .ir_load(ir_load_wire), 
  .read_data(im_to_ir), 
  .instr(ir));

// done
pc program_counter(
  .clk(clk), 
  .br_addr(br_to_pc), 
  .pc_sel(pc_sel_wire), 
  .pc_write(pc_write_wire), 
  .pc_rst(pc_rst_wire), 
  .pc_out(pc_out_wire));
// done
im instruction_memory(
  .read_addr(pc_out_wire), 
  .read_data(im_to_ir));

// DONE
dm data_memory(
  .read_addr(mux16_to_dm), 
  .write_addr(mux16_to_dm), 
  .write_data(rsb_to_alu), 
  .dm_we(ctrl_to_dm_write_select), 
  .read_data(dm_to_mux32));


// DONE
mux16 mux_sixteen(
  .in_a(alu_result_to_mux_thirty_two), 
  .in_b(ir[15:0]),
  .in_c(rsa_to_alu[15:0]),
  .sel(ctrl_to_mux16_mm_sel), 
  .out(mux16_to_dm));

mux4 mux_four_2 (
  .in_a(ir[23:20]), 
  .in_b(ir[19:16]), 
  .sel(wr_sel_wire),
  .out(write_reg_wire));

  initial
  
// put a $monitor statement here.  
  $monitor("t=%3d, R1=%8h, R2=%8h, R3=%8h, R4=%8h, R5=%8h, IR=%8h, ALU_OP=%b, STAT:%4b, read_data:%8h, br_sel=%1b, pc_write=%1b, pc_sel=%1b, M[8]:%8h, M[9]:%8h, M[3]:%8h", $time, register_file.ram_array[1], register_file.ram_array[2], register_file.ram_array[3], register_file.ram_array[4], register_file.ram_array[5], ir, control_to_alu,stat_to_control, im_to_ir, sisc_to_branch, pc_write_wire, pc_sel_wire, data_memory.ram_array[8], data_memory.ram_array[9], data_memory.ram_array[3] );
  //$monitor("m[0]=%8h, m[1]=%8h, m[2]=%8h, m[3]=%8h, m[4]=%8h, m[5]=%8h, m[6]=%8h", data_memory.ram_array[0],data_memory.ram_array[1],data_memory.ram_array[2],data_memory.ram_array[3],data_memory.ram_array[4],data_memory.ram_array[5],data_memory.ram_array[6]);

endmodule