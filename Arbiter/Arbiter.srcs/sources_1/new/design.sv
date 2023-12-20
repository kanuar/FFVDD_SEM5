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
// test bench design for an arbiter
// Dependencies: 
// 
// Revision: 
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module design_module
#(parameter N=4)
(
input logic clk,reset,
input logic [N-1:0] data,
input logic [3:0] request,
input logic [2:0] opcode,
output logic [3:0] grant,
output logic [N-1:0] d_out,
output logic op_error
);

typedef enum logic [2:0] {NORMAL,FORCE0,FORCE1,FORCE2,FORCE3,ACCESS_OFF,ACCESS_ON,RESERVED} t_opcode;
logic  [N-1:0] cur_data,next_data;
logic [3:0] cur_grant,next_grant;
logic cur_op,next_op;

always_ff @(posedge clk)
begin
    if(reset)
    begin
        cur_grant<=0;
        cur_op<=1;
        cur_data<=0;
    end
    
    else
    begin
        cur_grant<=next_grant;
        cur_op<=next_op;
        cur_data<=next_data;
    end
    
end

always_comb
begin
    casez(opcode)
        NORMAL: 
            begin
                next_data=data;
                next_op=0;
                next_grant=request;
            end
        FORCE0:
            begin
                next_data=data;
                next_op=0;
                next_grant=1;
            end
        FORCE1:
            begin
                next_data=data;
                next_op=0;
                next_grant=2;
            end
        FORCE2:
            begin
                next_data=data;
                next_op=0;
                next_grant=4;
            end
        FORCE3:
            begin
                next_data=data;
                next_op=0;
                next_grant=8;
            end
        ACCESS_OFF:
            begin
                next_data=0;
                next_op=1;
                next_grant=request;
            end
        ACCESS_ON:
            begin
                next_data=data;
                next_op=0;
                next_grant=request;
            end
        RESERVED:
            begin 
                next_data=0;
                next_op=1;
                next_grant=0;
            end
    endcase
end

assign grant=cur_grant;
assign d_out=cur_data;
assign op_error=cur_op;

endmodule
