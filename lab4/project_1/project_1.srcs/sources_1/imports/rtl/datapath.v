`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/02 15:12:22
// Design Name: 
// Module Name: datapath
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

//下面的整个数据通路
//参数为各阶段的输入输出值，要分阶段，不同级的流水线即使信号含义相同也要再输入一遍，相当于完全的分离
module datapath(
    input wire clk, rst,                // 时钟信号与复位信号
    // Fetch 阶段
    output wire [31:0] pcF,             // 当前 PC 值
    input wire [31:0] instrF,           // 取指阶段的指令
    // Decode 阶段
    input wire pcsrcD, branchD,         // 分支控制信号
    input wire jumpD,                   // 跳转信号
    output wire equalD,                 // 比较信号 (寄存器值是否相等)
    output wire [5:0] opD, functD,      // 操作码与功能码
    // Execute 阶段
    input wire memtoregE,hilocoE,HISelE,LOSelE,HIwenE,LOwenE,       // 内存到寄存器写信号
    input wire alusrcE, regdstE,        // ALU 数据来源选择与目标寄存器选择
    input wire regwriteE,               // 寄存器写使能
    input wire [5:0] alucontrolE,       // ALU 控制信号
    output wire flushE,                 // 刷新信号
    // Memory 阶段
    input wire memtoregM,hilocoM,HIwenM,LOwenM,         // 内存到寄存器写信号
    input wire regwriteM,               // 寄存器写使能
    output wire [31:0] aluoutM,         // ALU 输出
    output wire [31:0] writedata2M,      // 写入内存的数据
    output wire [3:0] memwriteM,        //写存储器的控制信号
    input wire [31:0] readdataM,        // 从内存读取的数据
    // Writeback 阶段
    input wire memtoregW,hilocoW,       // 内存到寄存器写信号
    input wire regwriteW                // 寄存器写使能
);

//所有的连线如果在两个不同的级别都要给写成两份
    // ************************ Fetch 阶段 ************************
    wire stallF;                        // 取指阶段的暂停信号
    wire [31:0] pcnextFD, pcnextbrFD, pcplus4F, pcbranchD; // PC 相关信号

    // ************************ Decode 阶段 ************************
    wire [31:0] pcplus4D, instrD;       // 译码阶段的 PC 和指令
    wire forwardaD, forwardbD;          // 前递信号 (译码阶段)
    wire [4:0] rsD, rtD, rdD;           // 源寄存器与目标寄存器
    wire [4:0] saD;                     //移位指令的立即数
    wire flushD, stallD;                // 译码阶段暂停与刷新信号
    wire [31:0] signimmD, signimmshD;   // 立即数与左移的立即数
    wire [31:0] srcaD, srca2D, srcbD, srcb2D; // 寄存器数据与前递数据

    // ************************ Execute 阶段 ************************
    wire [1:0] forwardaE, forwardbE;    // 前递信号 (执行阶段)
    wire [4:0] rsE, rtE, rdE;           // 源寄存器与目标寄存器
    wire [4:0] saE;                     //移位指令的立即数
    wire [4:0] writeregE;               // 写入寄存器地址
    wire [31:0] signimmE;               // 执行阶段的符号扩展立即数
    wire [31:0] srcaE, srca2E, srcbE, srcb2E, srcb3E; // 执行阶段寄存器数据
    wire [31:0] aluoutE;                // ALU 输出
    wire [31:0] hiE,loE;                  //乘除法运算器的结果输出
    wire [31:0] multiOutHIE,multiOutLOE;  //乘除法运算结果与寄存器数据的选择

    // ************************ Memory 阶段 ************************
    wire [4:0] writeregM;               // 存储阶段的写寄存器地址
    wire [31:0] writedataM;
    wire adesM, adelM;
    wire [6:0] exceptM;
    wire [5:0] alucontrolM;
    wire [31:0] multiOutHIM,multiOutLOM;  //乘除法运算结果与寄存器数据的选择
    wire [31:0] multiOutHIMW,multiOutLOMW;  //乘除法运算结果与寄存器数据的选择
    // ************************ Writeback 阶段 ************************
    wire [4:0] writeregW;               // 写回阶段的写寄存器地址
    wire [31:0] aluoutW, readdataW, resultW; // 写回阶段的 ALU 输出和数据
    wire [31:0] multiOutHIW,multiOutLOW;  //乘除法运算结果与寄存器数据的选择
    wire [31:0] preresultW;
    wire [5:0] alucontrolW;
    wire adelW;

    // ********************** 数据冒险检测模块 **********************
    hazard h(
        // Fetch 阶段
        stallF,
        // Decode 阶段
        rsD, rtD,
        branchD,
        forwardaD, forwardbD,
        stallD,
        // Execute 阶段
        rsE, rtE,
        writeregE,
        regwriteE,
        memtoregE,
        forwardaE, forwardbE,
        flushE,
        // Memory 阶段
        writeregM,
        regwriteM,
        memtoregM,
//        alucontrolM,
        // Writeback 阶段
        writeregW,
        regwriteW
    );

    // ********************* 取指阶段逻辑 (Fetch) ********************
    //pcF为原来的pc计数器的值，pcplus4F为自增条件下的计数器的值，pcnextbrFD为最终的pc选择的新值
    //pcsrcD为分支和另一个equal的控制值计算出来的，确定要选择哪个信号，pcbranchD为分支地址的计算
    mux2 #(32) pcbrmux(pcplus4F, pcbranchD, pcsrcD, pcnextbrFD); // 2、分支与原始加4的两种地址的选择
    mux2 #(32) pcmux(pcnextbrFD, {pcplus4D[31:28], instrD[25:0], 2'b00}, jumpD, pcnextFD); // 3、第二步下跳转和上面两种的选择（跳转的信号较为特殊）
//    mux2 #(32) pcmux(pcnextbrFD, pcnextbrFD, jumpD, pcnextFD);
    pc #(32) pcreg(clk, rst, ~stallF, pcnextFD, pcF);           // 4，最终的pc寄存器的值
    adder pcadd1(pcF, 32'b100, pcplus4F);                      // 1、简单直接加4的操作

    // ********************* 译码阶段逻辑 (Decode) *******************
    regfile rf(clk, regwriteW, rsD, rtD, writeregW, resultW, srcaD, srcbD); // 寄存器堆中各种的操作
    flopenr #(32) r1D(clk, rst, ~stallD, pcplus4F, pcplus4D);                     // 延迟寄存 PC,将pc继续传下去
    flopenrc #(32) r2D(clk, rst, ~stallD, flushD, instrF, instrD); // 延迟寄存指令，将指令继续传下去
    signext se(instrD[15:0],instrD[29:28], signimmD);                       // 符号扩展
    sl2 immsh(signimmD, signimmshD);                          // 立即数左移 2 位
    adder pcadd2(pcplus4D, signimmshD, pcbranchD);            // 分支目标地址计算
    //确定向前传递的是哪个信号
    mux2 #(32) forwardamux(srcaD, aluoutM, forwardaD, srca2D); // 前递 A
    mux2 #(32) forwardbmux(srcbD, aluoutM, forwardbD, srcb2D); // 前递 B
    eqcmp comp(srca2D, srcb2D, equalD);                       // 比较模块
    //将指令按照R型指令的格式进行分解
    assign opD = instrD[31:26];                               // 操作码
    assign functD = instrD[5:0];                              // 功能码
    assign rsD = instrD[25:21];                               // 寄存器 RS
    assign rtD = instrD[20:16];                               // 寄存器 RT
    assign rdD = instrD[15:11];                               // 寄存器 RD
    assign saD = instrD[10:6];                                //移位指令时的立即数

    // ******************** 执行阶段逻辑 (Execute) *******************
    floprc #(32) r1E(clk, rst, flushE, srcaD, srcaE);          // 延迟寄存源寄存器数据 A，向后传播之前取到的寄存器数据
    floprc #(32) r2E(clk, rst, flushE, srcbD, srcbE);          // 延迟寄存源寄存器数据 B，向后传播之前取到的寄存器数据
    floprc #(32) r3E(clk, rst, flushE, signimmD, signimmE);    // 延迟寄存符号扩展数据，向后传播之前取到的寄存器数据
    floprc #(5) r4E(clk, rst, flushE, rsD, rsE);               // 延迟寄存寄存器 RS，继续向后传播指令的中的寄存器编号
    floprc #(5) r5E(clk, rst, flushE, rtD, rtE);               // 延迟寄存寄存器 RT，继续向后传播指令的中的寄存器编号
    floprc #(5) r6E(clk, rst, flushE, rdD, rdE);               // 延迟寄存寄存器 RD，继续向后传播指令的中的寄存器编号
    floprc #(5) r7E(clk, rst, flushE, saD, saE);               // 延迟移位立即数，继续向后传播指令的中的寄存器编号
    mux3 #(32) forwardaemux(srcaE, resultW, aluoutM, forwardaE, srca2E); // 前递 A
    mux3 #(32) forwardbemux(srcbE, resultW, aluoutM, forwardbE, srcb2E); // 前递 B
    mux2 #(32) srcbmux(srcb2E, signimmE, alusrcE, srcb3E);     // ALU 操作数选择，（1立即数和0寄存器的值选择）
    alu alu(srca2E, srcb3E, saE, alucontrolE, aluoutE);             // ALU 运算
//    multi_div multi_div(srca2E,srcb2E,alucontrolE,hiE,loE);           //乘除法运算
    multi_div multi_div (
        .a(srca2E),         // 输入信号 srca2E 连接到 a
        .b(srcb2E),         // 输入信号 srcb2E 连接到 b
        .op(alucontrolE),   // 输入信号 alucontrolE 连接到 op
        .y1(hiE),           // 输出信号 hiE 连接到 y1
        .y0(loE)            // 输出信号 loE 连接到 y0
    );

    mux2 #(32) HImux(hiE, srca2E, HISelE, multiOutHIE);                //写入HI寄存器的数据选择
    mux2 #(32) LOmux(loE, srca2E, LOSelE, multiOutLOE);                //写入LO寄存器的数据选择
    mux2 #(5) wrmux(rtE, rdE, regdstE, writeregE);             // 写寄存器选择/0选rt

    // ******************** 存储阶段逻辑 (Memory) *******************
    
    flopr #(32) r1M(clk, rst, srcb2E, writedataM);             // 延迟rt中取得的数据
    flopr #(32) r2M(clk, rst, aluoutE, aluoutM);               // 延迟 ALU计算的 输出
    flopr #(5) r3M(clk, rst, writeregE, writeregM);            // 延迟寄存写寄存器地址
    flopr #(16) r4M(clk, rst, alucontrolE, alucontrolM);         //延迟alu的控制信号
    flopr #(32) r5M(clk, rst, multiOutHIE,multiOutHIM);          //延迟要写入HI的数据
    flopr #(32) r6M(clk, rst, multiOutLOE,multiOutLOM);          //延迟要写入LO的数据
    hilo hi(clk,HIwenM,multiOutHIM,multiOutHIMW);                 //写入HI寄存器并从中获取数值
    hilo lo(clk,LOwenM,multiOutLOM,multiOutLOMW);                 //写入HI寄存器并从中获取数值
    //为不同的写内存指令(sb、sh、sw)解码写地址类型,即字节、半字、整字的位置
    sw_select swsel(
		.adesM(adesM),
		.addressM(aluoutM),
		.alucontrolM(alucontrolM),
		.memwriteM(memwriteM)
		);
    //地址例外
    addr_except addrexcept(
        .addrs(aluoutM),
        .alucontrolM(alucontrolM),
        .adelM(adelM),
        .adesM(adesM)
        ); 
        
    //异常采集
	assign exceptM[6:5]={adesM,adelM};
	//写入存储器的数据
	assign writedata2M = (alucontrolM == 6'b011010)? {{writedataM[7:0]},{writedataM[7:0]},{writedataM[7:0]},{writedataM[7:0]}}:
						(alucontrolM == 6'b011011)? {{writedataM[15:0]},{writedataM[15:0]}}:
						(alucontrolM == 6'b011100)? {{writedataM[31:0]}}:
						writedataM;//根据不同的指令选择不同的要写到存储器中的数据

    // ******************** 写回阶段逻辑 (Writeback) ****************
    flopr #(32) r1W(clk, rst, aluoutM, aluoutW);               // 延迟寄存 ALU 输出
    flopr #(32) r2W(clk, rst, readdataM, readdataW);           // 延迟寄存内存数据
    flopr #(5) r3W(clk, rst, writeregM, writeregW);            // 延迟寄存写寄存器地址
    flopr #(8) r4W(clk, rst, alucontrolM, alucontrolW);         //延迟alu的控制信号
    flopr #(32) r5W(clk, rst, multiOutHIMW,multiOutHIW);          //延迟要写入HI的数据
    flopr #(32) r6W(clk, rst, multiOutLOMW,multiOutLOW);          //延迟要写入LO的数据
    floprc #(1) r7W(clk,rst,flushW,adelM,adelW);
    
    mux4 #(32) writeregmux(aluoutW, readdataW,multiOutHIW, multiOutLOW, {hilocoW,memtoregW}, preresultW); // 写回数据选择（1选存储器数据/0选alu计算数据）
    //根据访存指令类型将从内存中读取的整字结果截取并扩展
	lw_select lwsel(
		.adelW(adelW),
		.aluoutW(aluoutW),
		.alucontrolW(alucontrolW),
		.lwresultW(preresultW),
		.resultW(resultW)
		);

endmodule

