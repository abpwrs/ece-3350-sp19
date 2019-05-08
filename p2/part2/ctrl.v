// ECE:3350 SISC computer project
// finite state machine
// Cooper Bell, Tina Liu, and Alex Powers 

`timescale 1ns/100ps

module ctrl (clk, rst_f, opcode, mm, stat, rf_we, alu_op, wb_sel, br_sel, pc_rst, pc_write, pc_sel, ir_load, rb_sel);

  /* DONE: Declare the ports listed above as inputs or outputs */
  input clk, rst_f; 
  input [3:0] opcode, mm, stat;
  output  rf_we, wb_sel;
  reg rf_we, wb_sel;
  output [1:0] alu_op;
  reg [1:0] alu_op;
  
  // part 2 
  output br_sel, pc_rst, pc_write, pc_sel, ir_load, rb_sel;
  reg br_sel, pc_rst, pc_write, pc_sel, ir_load, rb_sel;
  // states
  parameter start0 = 0, start1 = 1, fetch = 2, decode = 3, execute = 4, mem = 5, writeback = 6;
   
  // opcodes
  parameter NOOP = 0, LOD = 1, STR = 2, SWP = 3, BRA = 4, BRR = 5, BNE = 6, BNR = 7, ALU_OP = 8, HLT=15;
    
  // addressing modes
  parameter am_imm = 8;

  // state registers
  reg [2:0]  present_state, next_state;

  initial
    
      present_state = start0;
      //next_state = start1; // pretty sure this goes here 
    

  /* TODO: Write a sequential procedure that progresses the fsm to the next state on the
       positive edge of the clock, OR resets the state to 'start1' on the negative edge
       of rst_f. Notice that the computer is reset when rst_f is low, not high. */

always @(posedge clk or negedge rst_f) // watch for positive clock or negative rst_f edges
    begin
    if(rst_f == 0)
        begin
            present_state <= start1; 
            next_state <= fetch;
            pc_rst <= 1;
        end 
    else
        begin 
            present_state <= next_state;
            pc_rst <= 0;
        end 
    end 
  
  /* TODO: Write a combination procedure that determines the next state of the fsm. */
    
always@(opcode or present_state)
    begin
        case(present_state) // next state of fsm 
            start0: 
                begin
                    next_state <= start1; 
                end
                
            start1: 
                begin
                    next_state <= fetch;
                end
                
            fetch: 
                begin
                    next_state <= decode;
                end
                
            decode:
                begin
                    next_state <= execute;
                end
                
            execute:
                begin
                    next_state <= mem;
                end
                
            mem:
                begin
                    next_state <= writeback;
                end
                
            writeback: 
                begin
                    next_state <= fetch;
                end
                
        endcase 
    end

  /* TODO: Generate outputs based on the FSM states and inputs. For Parts 2, 3 and 4 you will
       add the new control signals here. */
always@(opcode or present_state)
    begin
        case(present_state) // generate output based on fsm state and input 
            start0:
                begin
                    rf_we = 0; 
                    wb_sel = 0; 
                    alu_op = 2'b10;
                    br_sel = 0;
                    pc_rst = 1;
                    pc_write = 0;
                    pc_sel = 0;
                    ir_load = 0;
                    rb_sel = 0;
                end
                
            start1:
                begin
                    rf_we = 0;
                    wb_sel = 0; 
                    alu_op = 2'b00; 
                    br_sel = 0;
                    pc_rst = 0;
                    pc_write = 0;
                    pc_sel = 0;
                    ir_load = 0;
                    rb_sel = 0;
                end
                
            fetch:
                begin
                    $display("fetching"); 
                    rf_we = 0; 
                    wb_sel = 0;
                    alu_op = 2'b00; 
                    pc_rst = 0;
                    pc_write = 1;
                    pc_sel = 0;
                    ir_load = 1;
                end
                
            decode:
                begin
                    pc_write = 0;
                    ir_load = 0;
                    pc_sel = 1;
                    $display("decode");
                    if ((opcode == BRR) || (opcode == BRA) || (opcode == BNR) || (opcode == BNE))
                        begin
                            if ((opcode == BRA) || (opcode == BRR))
                                begin
                                    if(opcode == BRA)
                                        begin
                                            br_sel <= 1'b1;
                                        end
                                    else if(opcode == BRR)
                                        begin
                                            br_sel <= 1'b0;
                                        end

                                    if ((mm & stat) != 4'b0000)
                                        begin
                                            pc_sel <= 1'b1; 
                                            pc_write <= 1'b1;
                                        end
                                    else
                                        begin
                                            pc_sel <= 1'b0;
                                        end
                                end
                            else if ((opcode == BNE) || (opcode == BNR))
                                begin
                                    if(opcode == BNE)
                                        begin
                                            br_sel <= 1'b1;
                                        end
                                    else if(opcode == BNR)
                                        begin
                                            br_sel <= 1'b0;
                                        end

                                    if(mm == 4'b0000)
                                        begin
                                            pc_sel <= 1'b1;
                                            pc_write <= 1'b1;
                                        end
                                    else
                                        begin               
                                            if((mm & stat) != 4'b0000)
                                                begin
                                                    pc_sel <= 1'b0;
                                                end
                                            else
                                                begin
                                                    pc_sel <= 1'b1;
                                                    pc_write <= 1'b1;
                                                end
                                        end
                                end
                        end    
                end
                
            execute:
                begin
                    $display("execute"); 
                    pc_write = 0;
                    pc_sel = 0;
            
                if (opcode == ALU_OP)
                        if (am_imm != mm)
                        begin
                                alu_op = 2'b00; 
                        end
                    else    
                        begin
                                alu_op = 2'b01; 
                        end
                end
            mem:
                begin
                    $display("mem"); 
                    if((am_imm == mm) && (ALU_OP == opcode))
                        begin
                            alu_op = 2'b01; 
                        end
                    else
                        begin
                            alu_op = 2'b00; 
                        end 
                end
            writeback:
                begin
                    $display("writeback"); 
                    if (ALU_OP == opcode)
                        rf_we = 1; 
                    alu_op = 2'b10; 
                end
                
            default: // set everything to 0 
                begin
                    alu_op = 2'b00;
                    wb_sel = 0; 
                    rf_we = 0;  
                    br_sel = 0;
                    pc_rst = 0;
                    pc_write = 0;
                    pc_sel = 0;
                    ir_load = 0;
                    rb_sel = 0;
                end
<<<<<<< HEAD
        endcase 
    end 
=======
                
        endcase 
    end 
						
			execute:
				begin
				    $display("execute"); 
					pc_write = 0;
					pc_sel = 0;
			
				if (opcode == ALU_OP)
				        if (am_imm != mm)
						begin
					    		alu_op = 2'b00; 
						end
					else 	
						begin
					    		alu_op = 2'b01; 
						end
				end
			mem:
				begin
					$display("mem"); 
					if((am_imm == mm) && (ALU_OP == opcode))
						begin
							alu_op = 2'b01; 
						end
					else
						begin
							alu_op = 2'b00; 
						end 
				end
			writeback:
				begin
					$display("writeback"); 
					if (ALU_OP == opcode)
						rf_we = 1; 
					alu_op = 2'b10; 
				end
				
			default: // set everything to 0 
				begin
					alu_op = 2'b00;
					wb_sel = 0; 
					rf_we = 0;  
					br_sel = 0;
					pc_rst = 0;
					pc_write = 0;
					pc_sel = 0;
					ir_load = 0;
					rb_sel = 0;
				end
				
		endcase 
	end 
>>>>>>> cf2e3d3b614937b88ed794db5924b17beca09af3


// Halt on HLT instruction
  
  always @ (opcode)
  begin
    if (opcode == HLT)
    begin 
      #5 $display ("Halt."); //Delay 5 ns so $monitor will print the halt instruction
      $stop;
    end
  end
    
  
endmodule
