`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/02 14:52:16
// Design Name: 
// Module Name: alu
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


module alu(
    input wire [31:0] a, b,              // 32 位操作数 a 和 b
    input wire [4:0] sa,                 //移位操作时的立即数
    input wire [5:0] op,                 // 操作码 (6 位)，决定 ALU 操作
    output reg [31:0] y,                 // 运算结果
    output reg overflow,                 // 溢出标志
    output wire zero                     // 零标志
);

    always @(*) begin
        case (op)
            //逻辑算数指令
            6'b001011:y <= a & b ;              //AND
            6'b001100:y <= ~(a | b);            //NOR
            6'b001101:y <= a | b;               //OR
            6'b001110:y <= a ^ b;               //XOR
            6'b000001:y <= a & b;               //ANDI
            6'b000010:y <= {b[15:0], 16'b0};    //LUI
            6'b000011:y <= a | b;               //ORI
            6'b000100:y <= a ^ b;               //XORI
            
            //移位运算指令
            6'b001111:y <=b << a[4:0];          //SLLV
            6'b010000:y <=b << sa;              //SLL
            6'b010001:y <=$signed(b) >>> a[4:0];//SRAV
            6'b010010:y <=$signed(b) >>> sa;    //SRA
            6'b010011:y <=b >> a[4:0];          //SRLV
            6'b010100:y <=b >> sa;              //SRL
            
            //访令
            6'b010101:y <= a + b;//21LB
            6'b010110:y <= a + b;//22LBU
            6'b010111:y <= a + b;//23LH
            6'b011000:y <= a + b;//24LHU
            6'b011001:y <= a + b;//25LW
            6'b011010:y <= a + b;//26SB
            6'b011011:y <= a + b;//27SH
            6'b011100:y <= a + b;//28SW
            
            //算术运算指令
            6'b011101:y <= a + b;//29ADD
            6'b011110:y <= a + b;//30ADDU
            6'b011111:y <= a - b;//31SUB
            6'b100000:y <= a - b;//32SUBU
            6'b100001:y <= (a[31] & !b[31]) ? 1: ((!a[31] & b[31]) ? 0: a<b);//33SLT
            6'b100010:y <= (a < b) ? 1 : 0;//34SLTU
            6'b100011:y <= a + b;//35ADDI
            6'b100100:y <= a + b;//36ADDIU
            6'b100101:y <= (a[31] & !b[31]) ? 1: ((!a[31] & b[31]) ? 0: a<b);//37SLTI
            6'b100110:y <= (a < b) ? 1 : 0;//38SLTIU
    
    
    
    
    
    
            
//            6'b000101:y <=       ;//LW
//            6'b000110:y <=       ;//SW
//            6'b000111:y <=       ;//BEQ
            6'b001000: begin
                y <= a + b; // ADDI
                // 溢出检测：如果 a 和 b 符号位相同，且结果的符号位与 a 不同，则溢出
                if ((a[31] == b[31]) && (y[31] != a[31])) begin
                    overflow = 1; // 设置溢出标志
                end
            end
//            6'b001001:y <=       ;//J
            default: y <= 32'b0;//默认结果为0
        endcase
     end
     
     assign zero = (y == 32'b0);
            


endmodule

