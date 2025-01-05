`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/10/23 15:27:24
// Design Name: 
// Module Name: aludec
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


module aludec(
    input wire[5:0] funct,     //指令的低6位funct字段
    input wire[5:0] aluop,     //maindec解析的aluop
    output reg[5:0] alucontrol //ALU的控制信号
);

    always @(*) begin
        case (aluop)
            6'b000000:case(funct)
                6'b100100:alucontrol <= 6'b001011;//11AND
                6'b100111:alucontrol <= 6'b001100;//12NOR
                6'b100101:alucontrol <= 6'b001101;//13OR
                6'b100110:alucontrol <= 6'b001110;//14XOR
                6'b000100:alucontrol <= 6'b001111;//15SLLV
                6'b000000:alucontrol <= 6'b010000;//16SLL
                6'b000111:alucontrol <= 6'b010001;//17SRAV
                6'b000011:alucontrol <= 6'b010010;//18SRA
                6'b000110:alucontrol <= 6'b010011;//19SRLV
                6'b000010:alucontrol <= 6'b010100;//20SRL
                6'b100000:alucontrol <= 6'b011101;//29ADD
                6'b100001:alucontrol <= 6'b011110;//30ADDU
                6'b100010:alucontrol <= 6'b011111;//31SUB
                6'b100011:alucontrol <= 6'b100000;//32SUBU
                6'b101010:alucontrol <= 6'b100001;//33SLT
                6'b101011:alucontrol <= 6'b100010;//34SLTU
            endcase
            6'b000001:alucontrol <= 6'b000001;//1ANDI
            6'b000010:alucontrol <= 6'b000010;//2LUI
            6'b000011:alucontrol <= 6'b000011;//3ORI
            6'b000100:alucontrol <= 6'b000100;//4XORI
//            6'b000101:alucontrol <= 6'b000101;//5LW
//            6'b000110:alucontrol <= 6'b000110;//6SW
            //访存指令
            6'b010101:alucontrol <= 6'b010101;//21LB
            6'b010110:alucontrol <= 6'b010110;//22LBU
            6'b010111:alucontrol <= 6'b010111;//23LH
            6'b011000:alucontrol <= 6'b011000;//24LHU
            6'b011001:alucontrol <= 6'b011001;//25LW
            6'b011010:alucontrol <= 6'b011010;//26SB
            6'b011011:alucontrol <= 6'b011011;//27SH
            6'b011100:alucontrol <= 6'b011100;//28SW
            //算术运算指令
            6'b100011:alucontrol <= 6'b100011;//35ADDI
            6'b100100:alucontrol <= 6'b100100;//36ADDIU
            6'b100101:alucontrol <= 6'b100101;//37SLTI
            6'b100110:alucontrol <= 6'b100110;//38SLTIU
            6'b100111:alucontrol <= 6'b100111;//39DIV
            6'b101000:alucontrol <= 6'b101000;//40DIVU
            6'b101001:alucontrol <= 6'b101001;//41MULT
            6'b101010:alucontrol <= 6'b101010;//42MULTU
            6'b101011:alucontrol <= 6'b101011;//43MFHI
            6'b101100:alucontrol <= 6'b101100;//44MFLO
            6'b101101:alucontrol <= 6'b101101;//MTHI
            6'b101110:alucontrol <= 6'b101110;//MTLO
            
            
            6'b000111:alucontrol <= 6'b000111;//7BEQ
//            6'b001000:alucontrol <= 6'b001000;//8ADDI
            6'b001001:alucontrol <= 6'b001001;//9J
            default:alucontrol <= 6'b001010;//10ILLEGAL OP
        endcase
    end

endmodule

