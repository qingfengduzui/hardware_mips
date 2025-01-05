`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/01/04 16:16:47
// Design Name: 
// Module Name: multi_div
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

//乘除法器
module multi_div(
    input wire [31:0] a, b,              // 32 位操作数 a 和 b
    input wire [5:0] op,                 // 操作码 (6 位)，决定 ALU 操作
    output  reg [31:0] y1,                 // 写到HI寄存器部分
    output  reg [31:0] y0                 //  写到LO寄存器部分
);

    reg [63:0] result1,result2;

    always @(*) begin
        case (op)
            6'b100111: begin             // 39 DIV (signed division)
                if (b != 0) begin
                    y0 = $signed(a) / $signed(b); // LO 为商
                    y1 = $signed(a) % $signed(b); // HI 为余数
                end else begin
                    y0 = 32'hFFFFFFFF; // 指定除数为 0 的情况
                    y1 = 32'hFFFFFFFF;
                end
            end

            6'b101000: begin             // 40 DIVU (unsigned division)
                if (b != 0) begin
                    y0 = a / b; // LO 为商
                    y1 = a % b; // HI 为余数
                end else begin
                    y0 = 32'hFFFFFFFF; // 指定除数为 0 的情况
                    y1 = 32'hFFFFFFFF;
                end
            end
            6'b101001: begin                        //41 MULT
                result1 = $signed(a) * $signed(b);
                y1 = result1[63:32];
                y0 = result1[31:0];
            end
            6'b101010: begin                        //42 MULTU
                result2 = a * b;
                y1 = result2[63:32];
                y0 = result2[31:0];
            end
        endcase
     end
endmodule
