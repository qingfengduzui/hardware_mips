`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/10/23 15:21:30
// Design Name: 
// Module Name: controller
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
//���������źŷֳ��˺ü���
//ȡַ�����롢ִ�С��ô桢��д
module controller(
	input wire clk,rst,
	//decode stage
	input wire[5:0] opD,functD,                //��ǰָ��Ĳ������Լ�����Ĺ�����
	output wire pcsrcD,branchD,equalD,jumpD,   //PC�����ź���Դ����ָ֧���źţ��ȽϽ������ת�ź�
	
	//execute stage
	input wire flushE,                         //ִ�н׶ε�ˢ���ź�
	output wire memtoregE,alusrcE,hilocoE,HISelE,LOSelE,HIwenE,LOwenE,
	output wire regdstE,regwriteE,	
	output wire[5:0] alucontrolE,

	//mem stage
	output wire memtoregM,memwriteM,hilocoM,HIwenM,LOwenM,
				regwriteM,
	//write back stage
	output wire memtoregW,regwriteW,hilocoW

    );
	
	//decode stage
	wire[5:0] aluopD;
	wire memtoregD,memwriteD,alusrcD,hilicoD,HISelD,LOSelD,HIwenD,LOwenD,
		regdstD,regwriteD;
	wire[5:0] alucontrolD;

	//execute stage
	wire memwriteE;

	maindec md(
		opD,
		functD,
		memtoregD,memwriteD,hilocoD,
		HISelD,LOSelD,HIwenD,LOwenD,
		branchD,alusrcD,
		regdstD,regwriteD,
		jumpD,
		aluopD
		);
	aludec ad(functD,aluopD,alucontrolD);

	assign pcsrcD = branchD & equalD;

	//pipeline registers
	//������׶εĿ����ź� (memtoregD, memwriteD, alusrcD, ��) ���ݵ�ִ�н׶�
	floprc #(16) regE(
		clk,
		rst,
		flushE,
		{memtoregD,hilocoD,memwriteD,alusrcD,regdstD,regwriteD,HISelD,LOSelD,HIwenD,LOwenD,alucontrolD},
		{memtoregE,hilocoE,memwriteE,alusrcE,regdstE,regwriteE,HISelE,LOSelE,HIwenE,LOwenE,alucontrolE}
		);
    //��ִ�н׶εĿ����ź� (memtoregE, memwriteE, ��) ���ݵ��洢�׶�
	flopr #(8) regM(
		clk,rst,
		{memtoregE,hilocoE,memwriteE,regwriteE,HIwenE,LOwenE},
		{memtoregM,hilocoM,memwriteM,regwriteM,HIwenM,LOwenM}
		);
	//���洢�׶εĿ����ź� (memtoregM, regwriteM) ���ݵ�д�ؽ׶�
	flopr #(8) regW(
		clk,rst,
		{memtoregM,hilocoM,regwriteM},
		{memtoregW,hilocoW,regwriteW}
		);
endmodule
