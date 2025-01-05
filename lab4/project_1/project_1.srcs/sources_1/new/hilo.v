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
    input wire wen,         //дʹ��
    input wire[31:0] wd,    //Ҫд��ȥ������
    output wire[31:0] rd     //Ҫ������������ 
    );
    
    reg [31:0] hilo;//�Ĵ���
    
    always @(negedge clk) begin
        if(wen) begin
            hilo <= wd;
        end
    end
    
    assign rd = hilo;
    
endmodule
