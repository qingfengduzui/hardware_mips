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

//������op���ɵĿ����ź�
module maindec(
	input wire[5:0] op,            //�����ָ���6λ������op
	input wire[5:0] funct,         //�������ֶΣ���������R��ָ����˳���ָ��
	output wire memtoreg,memwrite,hiloco, //�ڴ浽�Ĵ������ڴ�дʹ��
	output wire HISel,LOSel,HIwen,LOwen,//�Ĵ������ǳ˳���������ѡ��浽/HI/LO��дʹ���ź�
	output wire branch,alusrc,     //��֧�źš�ALUԴѡ��
	output wire regdst,regwrite,   //Ŀ��Ĵ���ѡ�񡢼Ĵ���дʹ��
	output wire jump,              //��ת�ź�
	output wire[5:0] aluop         //ALU�������ƣ�����aludec��ִ��
    );
	reg[17:0] controls;             //����������
	assign {regwrite,regdst,alusrc,branch,memwrite,hiloco,memtoreg,jump,HISel,LOSel,HIwen,LOwen,aluop} = controls;
	//regwrite�Ĵ���дʹ�ܣ�1�Ļ������Ĵ�������д����
	//regdstȷ����д��rt���滹��rd����//��Ҫ����ָ���ʽ�Ĳ�ͬ
	//alusrc�����Ƿ�ʹ�����������������ͼĴ�����ѡ��һ��)
	//
	//memwrite�洢����дʹ�ܣ�1�Ļ������洢������д����
	//memtoregѡ��д�ص����ڴ����ݻ���alu����������(0ΪALU����������)
	always @(*) begin
		case (op)
		    //�߼��������λ��������ź�����
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
			//�ô�����ź�����
			6'b100000:controls <= 18'b10100_010_0000_010101;//21LB
			6'b100100:controls <= 18'b10100_010_0000_010110;//22LBU
			6'b100001:controls <= 18'b10100_010_0000_010111;//23LH
			6'b100101:controls <= 18'b10100_010_0000_011000;//24LHU
			6'b100011:controls <= 18'b10100_010_0000_011001;//25LW
			6'b101000:controls <= 18'b00101_000_0000_011010;//26SB
			6'b101001:controls <= 18'b00101_000_0000_011011;//27SH
			6'b101011:controls <= 18'b00101_000_0000_011100;//28SW
			//��������ָ��(R-TYPE����һ��,������Ƿ�R-TYPE��ָ��)
			6'b001000:controls <= 18'b10100_000_0000_100011;//35ADDI
			6'b001001:controls <= 18'b10100_000_0000_100100;//36ADDIU
			6'b001010:controls <= 18'b10100_000_0000_100101;//37SLTI
			6'b001011:controls <= 18'b10100_000_0000_100110;//38SLTIU
			
			
			
			//�ӣ�֮ǰʣ�ģ�д���ٿ���
//			6'b100011:controls <= 13'b1010010000101;//5LW
//			6'b101011:controls <= 13'b0010100000110;//6SW
			6'b000100:controls <= 18'b000100000000000111;//7BEQ
////			6'b001000:controls <= 13'b1010000001000;//8ADDI
			6'b000010:controls <= 18'b0000_0001_0000_001001;//9J
			default:  controls <= 18'b00000_000_0000_001010;//10illegal op
		endcase
	end
endmodule
