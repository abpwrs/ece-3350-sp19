// ECE:3350 SISC processor project
// main SISC module, part 1
// Cooper Bell, Tina Liu, and Alex Powers 

`timescale 1ns/100ps  

module sisc (clk, rst_f, ir);

  input clk, rst_f;
  input [31:0] ir;

// declare all internal wires here
wire [3:0] mux_four_to_rf;
wire [3:0] stat_to_control;
wire alu_ctrl_to_stat_enable;
wire [3:0] alu_to_stat;
wire [1:0] control_to_alu;
wire control_to_mux_thirty_two_enable;
wire [31:0] alu_result_to_mux_thirty_two;
wire control_to_rf;
wire [31:0] mux_thirty_two_to_rf;
wire [31:0] rsa_to_alu;
wire [31:0] rsb_to_alu;


// component instantiation goes here

// done
statreg sreg (
  .clk(clk), 
  .in(alu_to_stat), 
  .enable(alu_ctrl_to_stat_enable), 
  .out(stat_to_control)
  );

// done
ctrl control (
  .clk(clk), 
  .rst_f(rst_f), 
  .opcode(ir[31:28]), 
  .mm(ir[27:24]), 
  .stat(stat_to_control), 
  .rf_we(control_to_rf), 
  .alu_op(control_to_alu), 
  .wb_sel(control_to_mux_thirty_two_enable)
  );

// done
mux4 mux_four (
  .in_a(ir[15:12]), 
  .in_b(ir[23:20]), 
  .sel(1'b0), 
  .out(mux_four_to_rf));

// done
mux32 mux_thirty_two (
  .in_a(alu_result_to_mux_thirty_two), 
  .in_b(32'h00), 
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
  .write_reg(ir[23:20]), 
  .write_data(mux_thirty_two_to_rf), 
  .rf_we(control_to_rf), 
  .rsa(rsa_to_alu), 
  .rsb(rsb_to_alu)
  );

  initial
  
// put a $monitor statement here.  
  $monitor("t=%3d, R1=%8h, R2=%8h, R3=%8h, R4=%8h, R5=%8h, IR=%8h, ALU_OP=%b, STAT:%4b", $time, register_file.ram_array[1], register_file.ram_array[2], register_file.ram_array[3], register_file.ram_array[4], register_file.ram_array[5], ir, control_to_alu,stat_to_control);


endmodule