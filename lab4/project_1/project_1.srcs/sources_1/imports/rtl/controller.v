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
//触发器将信号分成了好几段
//取址、译码、执行、访存、回写
module controller(
	input wire clk,rst,
	//decode stage
	input wire[5:0] opD,functD,                //当前指令的操作码以及后面的功能码
	output wire pcsrcD,branchD,equalD,jumpD,   //PC更新信号来源，分支指令信号，比较结果，跳转信号
	
	//execute stage
	input wire flushE,                         //执行阶段的刷新信号
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
	//将译码阶段的控制信号 (memtoregD, memwriteD, alusrcD, 等) 传递到执行阶段
	floprc #(16) regE(
		clk,
		rst,
		flushE,
		{memtoregD,hilocoD,memwriteD,alusrcD,regdstD,regwriteD,HISelD,LOSelD,HIwenD,LOwenD,alucontrolD},
		{memtoregE,hilocoE,memwriteE,alusrcE,regdstE,regwriteE,HISelE,LOSelE,HIwenE,LOwenE,alucontrolE}
		);
    //将执行阶段的控制信号 (memtoregE, memwriteE, 等) 传递到存储阶段
	flopr #(8) regM(
		clk,rst,
		{memtoregE,hilocoE,memwriteE,regwriteE,HIwenE,LOwenE},
		{memtoregM,hilocoM,memwriteM,regwriteM,HIwenM,LOwenM}
		);
	//将存储阶段的控制信号 (memtoregM, regwriteM) 传递到写回阶段
	flopr #(8) regW(
		clk,rst,
		{memtoregM,hilocoM,regwriteM},
		{memtoregW,hilocoW,regwriteW}
		);
endmodule
