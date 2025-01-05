`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/01/03 20:06:18
// Design Name: 
// Module Name: addr_except
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


module addr_except(
    input [31:0] addrs,     //访存地址
    input [5:0] alucontrolM,//访存类型
    output reg adelM,       //LH、LW指令地址错例外
    output reg adesM        //LH、LW指令地址错例外
    );
    
    always@(*) begin
        adelM <= 1'b0;      //赋初值,否则生成latch
        adesM <= 1'b0;
        case (alucontrolM)
            6'b010111: if (addrs[1:0] != 2'b00 & addrs[1:0] != 2'b10 ) begin
                adelM <= 1'b1;
            end
            6'b011000: if ( addrs[1:0] != 2'b00 & addrs[1:0] != 2'b10 ) begin
                adelM <= 1'b1;
            end
            6'b011001: if ( addrs[1:0] != 2'b00 ) begin
                adelM <= 1'b1;
            end
            6'b011011: if (addrs[1:0] != 2'b00 & addrs[1:0] != 2'b10 ) begin
                adesM <= 1'b1;
            end
            6'b011100: if ( addrs[1:0] != 2'b00 ) begin
                adesM <= 1'b1;
            end
            default: begin
                adelM <= 1'b0;
                adesM <= 1'b0;
            end
        endcase
    end
endmodule
