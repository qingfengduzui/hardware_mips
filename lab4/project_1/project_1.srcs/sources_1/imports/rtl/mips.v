`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/07 10:58:03
// Design Name: 
// Module Name: mips
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


module mips(
	input wire clk, rst,                       // ʱ���źź͸�λ�ź�
    output wire [31:0] pcF,                    // ��ǰ PC (���������) ֵ
    input wire [31:0] instrF,                  // ȡָ�׶ε�ָ��
    output wire [3:0] memwriteM,                     // �洢�׶ε��ڴ�дʹ���ź�
    output wire [31:0] aluoutM, writedataM,    // �洢�׶ε� ALU �����д�ڴ�����
    input wire [31:0] readdataM                // ���ڴ��ȡ������
    );
	
	wire [5:0] opD,functD;
	wire regdstE,alusrcE,pcsrcD,memtoregE,memtoregM,memtoregW,hilocoE,hilocoM,hilocoW,HISelE,LOSelE,HIwenE,LOwenE,HIwenM,LOwenM,
			regwriteE,regwriteM,regwriteW;
	wire [5:0] alucontrolE;
	wire flushE,equalD;

	controller c(
		clk,rst,
		//decode stage
		opD,functD,
		pcsrcD,branchD,equalD,jumpD,
		
		//execute stage
		flushE,
		memtoregE,alusrcE,hilocoE,HISelE,LOSelE,HIwenE,LOwenE,
		regdstE,regwriteE,	
		alucontrolE,

		//mem stage
		memtoregM,memwriteM_QAE,hilocoM,HIwenM,LOwenM,
		regwriteM,
		//write back stage
		memtoregW,regwriteW,hilocoW
		);
	datapath dp(
		clk,rst,
		//fetch stage
		pcF,
		instrF,
		//decode stage
		pcsrcD,branchD,
		jumpD,
		equalD,
		opD,functD,
		//execute stage
		memtoregE,hilocoE,HISelE,LOSelE,HIwenE,LOwenE,
		alusrcE,regdstE,
		regwriteE,
		alucontrolE,
		flushE,
		//mem stage
		memtoregM,hilocoM,HIwenM,LOwenM,
		regwriteM,
		aluoutM,writedataM,
		memwriteM,
		readdataM,
		//writeback stage
		memtoregW,hilocoW,
		regwriteW
	    );
	
endmodule
