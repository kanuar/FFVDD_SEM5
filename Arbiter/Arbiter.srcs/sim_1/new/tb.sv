`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Raunak Kodwani
// 
// Create Date: 20.12.2023 12:11:25
// Design Name: aribiter
// Module Name: design_module
// Project Name: Arbiter
// Target Devices: xc7a35tcpg236-1 
// Tool Versions: 
// Description: 
// arbiter design taken from the book Formal Verification: An Essential Toolkit for Modern VLSI Design -2014 print
// test bench for an arbiter
// Dependencies: 
// 
// Revision: 
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb();
typedef enum logic [2:0] {NORMAL,FORCE0,FORCE1,FORCE2,FORCE3,ACCESS_OFF,ACCESS_ON,RESERVED} t_opcode;
logic clk,reset,op_error;
logic [7:0]data_in,data_out;
logic [3:0]request,grant;
logic [2:0]opcode;

design_module #(8) dut(clk,reset,data_in,request,opcode,grant,data_out,op_error);

always begin
#5 clk=~clk;
end

initial begin
    clk=0;
    reset=1;
    #10
    repeat(40)
    begin
        #5
        reset=0;
        data_in=$random();
        request=$random();
        opcode=$random();
        #20
        reset=1;
    end
    #20
  
	$dumpfile("dump.vcd"); $dumpvars;
    $finish();
end

sequence seq_1;
  @(posedge clk) (grant==4'h8 && request==4'ha);
  endsequence
  
  //calling assert property
  a_1: assert property(seq_1);
 
    anothergc_1: assert property(@(posedge clk) !(grant[0] && !(request[0])));
      
      
endmodule
      
      
      
/*

module tb();
typedef enum logic [2:0] {NORMAL,FORCE0,FORCE1,FORCE2,FORCE3,ACCESS_OFF,ACCESS_ON,RESERVED} t_opcode;
logic clk,reset,op_error;
logic [7:0]data_in,data_out;
logic [3:0]request,grant;
logic [2:0]opcode;

design_module #(8) dut(clk,reset,data_in,request,opcode,grant,data_out,op_error);

always begin
#5 clk=~clk;
end

initial begin
    clk=0;
    reset=1;
    #10
    repeat(40)
    begin
        #5
        reset=0;
        data_in=$random();
        request=$random();
        opcode=$random();
        #20
        reset=1;
    end
    #20
  	
	$dumpvars;
  	$dumpfile("dump.vcd");
  
    $finish();
end


  

always @(posedge clk)
begin

// few features work only inside clocking blocks

check_grant: assert property(!(grant[0]&&!request[0]))
  else $display($time," granted 0 without request");

check_opcode: assert property(opcode!=RESERVED)
  else $display($time," arbiter is reserved by another process");

cover_all_at_once: cover property(request==4'hf);
  $display($time," all ports busy");

  // sequence to check for the 
sequence a;
  request==4'a;
  grant==4'h8;
endsequence
  

end
  
endmodule
  
  */
