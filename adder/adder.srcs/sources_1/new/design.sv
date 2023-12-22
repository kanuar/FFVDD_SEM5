`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Raunak Kodwani
// 
// Create Date: 22.12.2023 10:35:57
// Design Name: 
// Module Name: adder
// Project Name: Adder with two test benches
// Target Devices: Artix-7 temp grade -1
// Tool Versions: Xilinx vivado 2017.4
// Description: 
// adder design with layered test bench
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// source from 
// https://verificationguide.com/systemverilog-examples/systemverilog-testbench-example-adder-2/#TestBench_Architecture
// https://verificationguide.com/systemverilog-examples/systemverilog-testbench-example-with-scb/#google_vignette
//////////////////////////////////////////////////////////////////////////////////

// Code your design here
module adder
  (input logic clk,reset,
    input logic [3:0]a,b,
   output logic [7:0]c);
  always @(posedge clk)
    begin
      if(reset)
        c<=0;
      else
        c<=a+b;
    end
  
endmodule