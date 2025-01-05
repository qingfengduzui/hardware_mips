`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/01/03 19:49:41
// Design Name: 
// Module Name: sw_select
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
module sw_select(
    input wire adesM, 
    input [31:0] addressM,      //写内存地址,末两位决定写地址
    input [5:0] alucontrolM,    //指令类型
    output reg [3:0] memwriteM  //写地址类型
    );

    always@ (*) begin
        if(adesM) 
            memwriteM = 4'b0000;
        else begin    
            case(alucontrolM)
            //SB
                6'b011010: begin
                    case(addressM[1:0])
                        2'b11: memwriteM = 4'b1000;
                        2'b10: memwriteM = 4'b0100;
                        2'b01: memwriteM = 4'b0010;
                        2'b00: memwriteM = 4'b0001;
                        default: memwriteM = 4'b0000;
                    endcase
                end 
                //SH   
                6'b011011: begin
                    case(addressM[1:0])
                        2'b00: memwriteM = 4'b0011;
                        2'b10: memwriteM = 4'b1100;
                        default: memwriteM = 4'b0000;
                    endcase
                end
                //SW
                6'b011100:
                    memwriteM = 4'b1111;
                default: memwriteM = 4'b0000;       
            endcase
        end
    end
endmodule
