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

//�������������ͨ·
//����Ϊ���׶ε��������ֵ��Ҫ�ֽ׶Σ���ͬ������ˮ�߼�ʹ�źź�����ͬҲҪ������һ�飬�൱����ȫ�ķ���
module datapath(
    input wire clk, rst,                // ʱ���ź��븴λ�ź�
    // Fetch �׶�
    output wire [31:0] pcF,             // ��ǰ PC ֵ
    input wire [31:0] instrF,           // ȡָ�׶ε�ָ��
    // Decode �׶�
    input wire pcsrcD, branchD,         // ��֧�����ź�
    input wire jumpD,                   // ��ת�ź�
    output wire equalD,                 // �Ƚ��ź� (�Ĵ���ֵ�Ƿ����)
    output wire [5:0] opD, functD,      // �������빦����
    // Execute �׶�
    input wire memtoregE,hilocoE,HISelE,LOSelE,HIwenE,LOwenE,       // �ڴ浽�Ĵ���д�ź�
    input wire alusrcE, regdstE,        // ALU ������Դѡ����Ŀ��Ĵ���ѡ��
    input wire regwriteE,               // �Ĵ���дʹ��
    input wire [5:0] alucontrolE,       // ALU �����ź�
    output wire flushE,                 // ˢ���ź�
    // Memory �׶�
    input wire memtoregM,hilocoM,HIwenM,LOwenM,         // �ڴ浽�Ĵ���д�ź�
    input wire regwriteM,               // �Ĵ���дʹ��
    output wire [31:0] aluoutM,         // ALU ���
    output wire [31:0] writedata2M,      // д���ڴ������
    output wire [3:0] memwriteM,        //д�洢���Ŀ����ź�
    input wire [31:0] readdataM,        // ���ڴ��ȡ������
    // Writeback �׶�
    input wire memtoregW,hilocoW,       // �ڴ浽�Ĵ���д�ź�
    input wire regwriteW                // �Ĵ���дʹ��
);

//���е����������������ͬ�ļ���Ҫ��д������
    // ************************ Fetch �׶� ************************
    wire stallF;                        // ȡָ�׶ε���ͣ�ź�
    wire [31:0] pcnextFD, pcnextbrFD, pcplus4F, pcbranchD; // PC ����ź�

    // ************************ Decode �׶� ************************
    wire [31:0] pcplus4D, instrD;       // ����׶ε� PC ��ָ��
    wire forwardaD, forwardbD;          // ǰ���ź� (����׶�)
    wire [4:0] rsD, rtD, rdD;           // Դ�Ĵ�����Ŀ��Ĵ���
    wire [4:0] saD;                     //��λָ���������
    wire flushD, stallD;                // ����׶���ͣ��ˢ���ź�
    wire [31:0] signimmD, signimmshD;   // �����������Ƶ�������
    wire [31:0] srcaD, srca2D, srcbD, srcb2D; // �Ĵ���������ǰ������

    // ************************ Execute �׶� ************************
    wire [1:0] forwardaE, forwardbE;    // ǰ���ź� (ִ�н׶�)
    wire [4:0] rsE, rtE, rdE;           // Դ�Ĵ�����Ŀ��Ĵ���
    wire [4:0] saE;                     //��λָ���������
    wire [4:0] writeregE;               // д��Ĵ�����ַ
    wire [31:0] signimmE;               // ִ�н׶εķ�����չ������
    wire [31:0] srcaE, srca2E, srcbE, srcb2E, srcb3E; // ִ�н׶μĴ�������
    wire [31:0] aluoutE;                // ALU ���
    wire [31:0] hiE,loE;                  //�˳����������Ľ�����
    wire [31:0] multiOutHIE,multiOutLOE;  //�˳�����������Ĵ������ݵ�ѡ��

    // ************************ Memory �׶� ************************
    wire [4:0] writeregM;               // �洢�׶ε�д�Ĵ�����ַ
    wire [31:0] writedataM;
    wire adesM, adelM;
    wire [6:0] exceptM;
    wire [5:0] alucontrolM;
    wire [31:0] multiOutHIM,multiOutLOM;  //�˳�����������Ĵ������ݵ�ѡ��
    wire [31:0] multiOutHIMW,multiOutLOMW;  //�˳�����������Ĵ������ݵ�ѡ��
    // ************************ Writeback �׶� ************************
    wire [4:0] writeregW;               // д�ؽ׶ε�д�Ĵ�����ַ
    wire [31:0] aluoutW, readdataW, resultW; // д�ؽ׶ε� ALU ���������
    wire [31:0] multiOutHIW,multiOutLOW;  //�˳�����������Ĵ������ݵ�ѡ��
    wire [31:0] preresultW;
    wire [5:0] alucontrolW;
    wire adelW;

    // ********************** ����ð�ռ��ģ�� **********************
    hazard h(
        // Fetch �׶�
        stallF,
        // Decode �׶�
        rsD, rtD,
        branchD,
        forwardaD, forwardbD,
        stallD,
        // Execute �׶�
        rsE, rtE,
        writeregE,
        regwriteE,
        memtoregE,
        forwardaE, forwardbE,
        flushE,
        // Memory �׶�
        writeregM,
        regwriteM,
        memtoregM,
//        alucontrolM,
        // Writeback �׶�
        writeregW,
        regwriteW
    );

    // ********************* ȡָ�׶��߼� (Fetch) ********************
    //pcFΪԭ����pc��������ֵ��pcplus4FΪ���������µļ�������ֵ��pcnextbrFDΪ���յ�pcѡ�����ֵ
    //pcsrcDΪ��֧����һ��equal�Ŀ���ֵ��������ģ�ȷ��Ҫѡ���ĸ��źţ�pcbranchDΪ��֧��ַ�ļ���
    mux2 #(32) pcbrmux(pcplus4F, pcbranchD, pcsrcD, pcnextbrFD); // 2����֧��ԭʼ��4�����ֵ�ַ��ѡ��
    mux2 #(32) pcmux(pcnextbrFD, {pcplus4D[31:28], instrD[25:0], 2'b00}, jumpD, pcnextFD); // 3���ڶ�������ת���������ֵ�ѡ����ת���źŽ�Ϊ���⣩
//    mux2 #(32) pcmux(pcnextbrFD, pcnextbrFD, jumpD, pcnextFD);
    pc #(32) pcreg(clk, rst, ~stallF, pcnextFD, pcF);           // 4�����յ�pc�Ĵ�����ֵ
    adder pcadd1(pcF, 32'b100, pcplus4F);                      // 1����ֱ�Ӽ�4�Ĳ���

    // ********************* ����׶��߼� (Decode) *******************
    regfile rf(clk, regwriteW, rsD, rtD, writeregW, resultW, srcaD, srcbD); // �Ĵ������и��ֵĲ���
    flopenr #(32) r1D(clk, rst, ~stallD, pcplus4F, pcplus4D);                     // �ӳټĴ� PC,��pc��������ȥ
    flopenrc #(32) r2D(clk, rst, ~stallD, flushD, instrF, instrD); // �ӳټĴ�ָ���ָ���������ȥ
    signext se(instrD[15:0],instrD[29:28], signimmD);                       // ������չ
    sl2 immsh(signimmD, signimmshD);                          // ���������� 2 λ
    adder pcadd2(pcplus4D, signimmshD, pcbranchD);            // ��֧Ŀ���ַ����
    //ȷ����ǰ���ݵ����ĸ��ź�
    mux2 #(32) forwardamux(srcaD, aluoutM, forwardaD, srca2D); // ǰ�� A
    mux2 #(32) forwardbmux(srcbD, aluoutM, forwardbD, srcb2D); // ǰ�� B
    eqcmp comp(srca2D, srcb2D, equalD);                       // �Ƚ�ģ��
    //��ָ���R��ָ��ĸ�ʽ���зֽ�
    assign opD = instrD[31:26];                               // ������
    assign functD = instrD[5:0];                              // ������
    assign rsD = instrD[25:21];                               // �Ĵ��� RS
    assign rtD = instrD[20:16];                               // �Ĵ��� RT
    assign rdD = instrD[15:11];                               // �Ĵ��� RD
    assign saD = instrD[10:6];                                //��λָ��ʱ��������

    // ******************** ִ�н׶��߼� (Execute) *******************
    floprc #(32) r1E(clk, rst, flushE, srcaD, srcaE);          // �ӳټĴ�Դ�Ĵ������� A����󴫲�֮ǰȡ���ļĴ�������
    floprc #(32) r2E(clk, rst, flushE, srcbD, srcbE);          // �ӳټĴ�Դ�Ĵ������� B����󴫲�֮ǰȡ���ļĴ�������
    floprc #(32) r3E(clk, rst, flushE, signimmD, signimmE);    // �ӳټĴ������չ���ݣ���󴫲�֮ǰȡ���ļĴ�������
    floprc #(5) r4E(clk, rst, flushE, rsD, rsE);               // �ӳټĴ�Ĵ��� RS��������󴫲�ָ����еļĴ������
    floprc #(5) r5E(clk, rst, flushE, rtD, rtE);               // �ӳټĴ�Ĵ��� RT��������󴫲�ָ����еļĴ������
    floprc #(5) r6E(clk, rst, flushE, rdD, rdE);               // �ӳټĴ�Ĵ��� RD��������󴫲�ָ����еļĴ������
    floprc #(5) r7E(clk, rst, flushE, saD, saE);               // �ӳ���λ��������������󴫲�ָ����еļĴ������
    mux3 #(32) forwardaemux(srcaE, resultW, aluoutM, forwardaE, srca2E); // ǰ�� A
    mux3 #(32) forwardbemux(srcbE, resultW, aluoutM, forwardbE, srcb2E); // ǰ�� B
    mux2 #(32) srcbmux(srcb2E, signimmE, alusrcE, srcb3E);     // ALU ������ѡ�񣬣�1��������0�Ĵ�����ֵѡ��
    alu alu(srca2E, srcb3E, saE, alucontrolE, aluoutE);             // ALU ����
//    multi_div multi_div(srca2E,srcb2E,alucontrolE,hiE,loE);           //�˳�������
    multi_div multi_div (
        .a(srca2E),         // �����ź� srca2E ���ӵ� a
        .b(srcb2E),         // �����ź� srcb2E ���ӵ� b
        .op(alucontrolE),   // �����ź� alucontrolE ���ӵ� op
        .y1(hiE),           // ����ź� hiE ���ӵ� y1
        .y0(loE)            // ����ź� loE ���ӵ� y0
    );

    mux2 #(32) HImux(hiE, srca2E, HISelE, multiOutHIE);                //д��HI�Ĵ���������ѡ��
    mux2 #(32) LOmux(loE, srca2E, LOSelE, multiOutLOE);                //д��LO�Ĵ���������ѡ��
    mux2 #(5) wrmux(rtE, rdE, regdstE, writeregE);             // д�Ĵ���ѡ��/0ѡrt

    // ******************** �洢�׶��߼� (Memory) *******************
    
    flopr #(32) r1M(clk, rst, srcb2E, writedataM);             // �ӳ�rt��ȡ�õ�����
    flopr #(32) r2M(clk, rst, aluoutE, aluoutM);               // �ӳ� ALU����� ���
    flopr #(5) r3M(clk, rst, writeregE, writeregM);            // �ӳټĴ�д�Ĵ�����ַ
    flopr #(16) r4M(clk, rst, alucontrolE, alucontrolM);         //�ӳ�alu�Ŀ����ź�
    flopr #(32) r5M(clk, rst, multiOutHIE,multiOutHIM);          //�ӳ�Ҫд��HI������
    flopr #(32) r6M(clk, rst, multiOutLOE,multiOutLOM);          //�ӳ�Ҫд��LO������
    hilo hi(clk,HIwenM,multiOutHIM,multiOutHIMW);                 //д��HI�Ĵ��������л�ȡ��ֵ
    hilo lo(clk,LOwenM,multiOutLOM,multiOutLOMW);                 //д��HI�Ĵ��������л�ȡ��ֵ
    //Ϊ��ͬ��д�ڴ�ָ��(sb��sh��sw)����д��ַ����,���ֽڡ����֡����ֵ�λ��
    sw_select swsel(
		.adesM(adesM),
		.addressM(aluoutM),
		.alucontrolM(alucontrolM),
		.memwriteM(memwriteM)
		);
    //��ַ����
    addr_except addrexcept(
        .addrs(aluoutM),
        .alucontrolM(alucontrolM),
        .adelM(adelM),
        .adesM(adesM)
        ); 
        
    //�쳣�ɼ�
	assign exceptM[6:5]={adesM,adelM};
	//д��洢��������
	assign writedata2M = (alucontrolM == 6'b011010)? {{writedataM[7:0]},{writedataM[7:0]},{writedataM[7:0]},{writedataM[7:0]}}:
						(alucontrolM == 6'b011011)? {{writedataM[15:0]},{writedataM[15:0]}}:
						(alucontrolM == 6'b011100)? {{writedataM[31:0]}}:
						writedataM;//���ݲ�ͬ��ָ��ѡ��ͬ��Ҫд���洢���е�����

    // ******************** д�ؽ׶��߼� (Writeback) ****************
    flopr #(32) r1W(clk, rst, aluoutM, aluoutW);               // �ӳټĴ� ALU ���
    flopr #(32) r2W(clk, rst, readdataM, readdataW);           // �ӳټĴ��ڴ�����
    flopr #(5) r3W(clk, rst, writeregM, writeregW);            // �ӳټĴ�д�Ĵ�����ַ
    flopr #(8) r4W(clk, rst, alucontrolM, alucontrolW);         //�ӳ�alu�Ŀ����ź�
    flopr #(32) r5W(clk, rst, multiOutHIMW,multiOutHIW);          //�ӳ�Ҫд��HI������
    flopr #(32) r6W(clk, rst, multiOutLOMW,multiOutLOW);          //�ӳ�Ҫд��LO������
    floprc #(1) r7W(clk,rst,flushW,adelM,adelW);
    
    mux4 #(32) writeregmux(aluoutW, readdataW,multiOutHIW, multiOutLOW, {hilocoW,memtoregW}, preresultW); // д������ѡ��1ѡ�洢������/0ѡalu�������ݣ�
    //���ݷô�ָ�����ͽ����ڴ��ж�ȡ�����ֽ����ȡ����չ
	lw_select lwsel(
		.adelW(adelW),
		.aluoutW(aluoutW),
		.alucontrolW(alucontrolW),
		.lwresultW(preresultW),
		.resultW(resultW)
		);

endmodule

