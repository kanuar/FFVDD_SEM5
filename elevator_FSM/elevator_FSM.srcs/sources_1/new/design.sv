`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.12.2023 14:55:43
// Design Name: 
// Module Name: design_module
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module design_module
#(parameter N=12)
(
input logic clk,reset,
input logic [7:0] request,
input logic [3:0] opcode,
output logic direction,
output logic [7:0] service,
output logic [1:0] error_code, status
);

typedef enum logic [2:0] {GENERAL,EMERGENCY,OVERRIDE_TOP,OVERRIDE_BOTTOM,OVERRIDE_WAIT,OVERRIDE_RELEASE,PRIORITY,SKIP} t_opcode;
typedef enum logic [1:0]{NO_ERROR,OVERRIDE,FLOOR_OUT_OF_BOUNDS,RESET_CALL} t_error_code;
typedef enum logic [1:0] {RUNNING,WAITING,IDLE,ERROR} t_status;
typedef enum logic [2:0] {START,STOP,DOOR_OPEN,DOOR_CLOSE,PREPARE_DOOR,RESUME,PAUSE_ERROR} t_state;
typedef enum logic {DOWN,UP} t_direction;

int queue [$];
int down_queue [$];
logic [7:0] cur_service,next_service;
logic [1:0] cur_code,next_code,cur_status,next_status;
logic [2:0] cur_state,next_state;
logic cur_direction,next_direction;
always_ff @(posedge clk)
begin
    if(reset)
    begin
        cur_service<=0;
        cur_code<=RESET_CALL;
        cur_status<=ERROR;
        cur_state<=PAUSE_ERROR; 
        cur_direction<=UP;
    end
    
    else
    begin
        cur_service<=next_service;
        cur_code<=next_code;
        cur_status<=next_status;
        cur_state<=next_state;
        cur_direction<=next_direction;
    end
end

always_comb
begin
    casez(opcode)
        GENERAL:
            begin
                casez(cur_state)
                    START:
                        begin
                            next_service=queue.pop_front();
                            next_state=RESUME;
                            next_direction=next_service>cur_service?UP:DOWN;
                            next_status=queue.size()>0?RUNNING:ERROR;
                            next_code=request>N?FLOOR_OUT_OF_BOUNDS:NO_ERROR;
                            queue.push_back(request);
                        end
                        
                    STOP:
                        begin
                            
                        end
                        
                    DOOR_OPEN:
                        begin
                        end
                        
                    DOOR_CLOSE:
                        begin
                        end
                        
                    PREPARE_DOOR:
                        begin
                        end
                        
                    RESUME:
                        begin
                        end
                        
                    PAUSE_ERROR:
                        begin
                        end
                        
                    default: 
                        begin
                            next_state=PAUSE_ERROR;
                        end
                        
                endcase
            end
        
        EMERGENCY:
            begin
            end
        
        OVERRIDE_TOP:
            begin
            end
       
        OVERRIDE_BOTTOM:
            begin
            end
       
        OVERRIDE_WAIT:
            begin
            end
       
        OVERRIDE_RELEASE:
            begin
            end
       
        PRIORITY:
            begin
            end
       
        SKIP:
            begin
            end
    
    endcase
end


endmodule
