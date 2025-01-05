`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/01/04 20:08:51
// Design Name: 
// Module Name: hilo
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


module hilo(
    input wire clk,
    input wire wen,         //写使能
    input wire[31:0] wd,    //要写进去的数据
    output wire[31:0] rd     //要读出来的数据 
    );
    
    reg [31:0] hilo;//寄存器
    
    always @(negedge clk) begin
        if(wen) begin
            hilo <= wd;
        end
    end
    
    assign rd = hilo;
    
endmodule
