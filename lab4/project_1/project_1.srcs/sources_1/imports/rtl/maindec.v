`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/10/23 15:21:30
// Design Name: 
// Module Name: maindec
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

//操作码op生成的控制信号
module maindec(
	input wire[5:0] op,            //输入的指令高6位操作码op
	input wire[5:0] funct,         //控制码字段，用来区分R型指令与乘除法指令
	output wire memtoreg,memwrite,hiloco, //内存到寄存器、内存写使能
	output wire HISel,LOSel,HIwen,LOwen,//寄存器还是乘除器运算结果选择存到/HI/LO的写使能信号
	output wire branch,alusrc,     //分支信号、ALU源选择
	output wire regdst,regwrite,   //目标寄存器选择、寄存器写使能
	output wire jump,              //跳转信号
	output wire[5:0] aluop         //ALU操作控制，控制aludec的执行
    );
	reg[17:0] controls;             //解析后的组合
	assign {regwrite,regdst,alusrc,branch,memwrite,hiloco,memtoreg,jump,HISel,LOSel,HIwen,LOwen,aluop} = controls;
	//regwrite寄存器写使能，1的话能往寄存器里面写东西
	//regdst确定是写到rt里面还是rd里面//主要用于指令格式的不同
	//alusrc控制是否使用立即数（立即数和寄存器中选择一个)
	//
	//memwrite存储器的写使能，1的话能往存储器里面写东西
	//memtoreg选择写回的是内存数据还是alu运算后的数据(0为ALU运算后的数据)
	always @(*) begin
		case (op)
		    //逻辑运算和移位运算控制信号生成
		    //R-TYRE(11AND/12NOR/13OR/14XOR/15SLLV/16SLL/17SRAV/18SRA/19SRLV/20SRL/29ADD/30ADDU/31SUB/32SUBU/33SLT/34SLTU)
			6'b000000:case(funct)
			     6'b011010:controls <= 18'b00000_100_0011_100111 ;//39DIV
			     6'b011011:controls <= 18'b00000_100_0011_101000 ;//40DIVU
			     6'b011000:controls <= 18'b00000_100_0011_101001 ;//41MULT
			     6'b011001:controls <= 18'b00000_100_0011_101010 ;//42MULTU
			     6'b010000:controls <= 18'b11000_100_0000_101011 ;//43MFHI
			     6'b010010:controls <= 18'b11000_110_0000_101100 ;//44MFLO
			     6'b010001:controls <= 18'b00000_100_1010_101101 ;//45MTHI
			     6'b010011:controls <= 18'b00000_100_0101_101110 ;//46MTLO
			     default:controls <= 18'b11000_000_0000_000000;//R-TYRE
			endcase
			6'b001100:controls <= 18'b10100_000_0000_000001;//1ANDI
			6'b001111:controls <= 18'b10100_000_0000_000010;//2LUI
			6'b001101:controls <= 18'b10100_000_0000_000011;//3ORI
			6'b001110:controls <= 18'b10100_000_0000_000100;//4XORI
			//访存控制信号生成
			6'b100000:controls <= 18'b10100_010_0000_010101;//21LB
			6'b100100:controls <= 18'b10100_010_0000_010110;//22LBU
			6'b100001:controls <= 18'b10100_010_0000_010111;//23LH
			6'b100101:controls <= 18'b10100_010_0000_011000;//24LHU
			6'b100011:controls <= 18'b10100_010_0000_011001;//25LW
			6'b101000:controls <= 18'b00101_000_0000_011010;//26SB
			6'b101001:controls <= 18'b00101_000_0000_011011;//27SH
			6'b101011:controls <= 18'b00101_000_0000_011100;//28SW
			//算术运算指令(R-TYPE上有一坨,下面的是非R-TYPE型指令)
			6'b001000:controls <= 18'b10100_000_0000_100011;//35ADDI
			6'b001001:controls <= 18'b10100_000_0000_100100;//36ADDIU
			6'b001010:controls <= 18'b10100_000_0000_100101;//37SLTI
			6'b001011:controls <= 18'b10100_000_0000_100110;//38SLTIU
			
			
			
			//杂（之前剩的，写着再看）
//			6'b100011:controls <= 13'b1010010000101;//5LW
//			6'b101011:controls <= 13'b0010100000110;//6SW
			6'b000100:controls <= 18'b000100000000000111;//7BEQ
////			6'b001000:controls <= 13'b1010000001000;//8ADDI
			6'b000010:controls <= 18'b0000_0001_0000_001001;//9J
			default:  controls <= 18'b00000_000_0000_001010;//10illegal op
		endcase
	end
endmodule
