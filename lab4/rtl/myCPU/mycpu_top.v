module mycpu_top(
    input clk,
    input resetn,  //low active

    //cpu inst sram
    output        inst_sram_en   ,
    output [3 :0] inst_sram_wen  ,
    output [31:0] inst_sram_addr ,
    output [31:0] inst_sram_wdata,
    input  [31:0] inst_sram_rdata,
    //cpu data sram
    output        data_sram_en   ,
    output [3 :0] data_sram_wen  ,
    output [31:0] data_sram_addr ,
    output [31:0] data_sram_wdata,
    input  [31:0] data_sram_rdata
);

// �?个例�?
	wire [31:0] pc;
	wire [31:0] instr;
	wire [3:0] memwrite;
	wire [31:0] aluout, writedata, readdata;
    mips mips(
        .clk(clk),
        .rst(~resetn),
        //instr
        // .inst_en(inst_en),
        .pcF(pc),                    //pcF
        .instrF(instr),              //instrF
        //data
        // .data_en(data_en),
        .memwriteM(memwrite),//��дʹ��
        .aluoutM(aluout),//��ַ
        .writedataM(writedata),//Ҫд��洢��������
        .readdataM(readdata)//Ҫ��ȡ�洢��������
    );

    assign inst_sram_en = 1'b1;    
    assign inst_sram_wen = 4'b0;
    assign inst_sram_addr = pc;
    assign inst_sram_wdata = 32'b0;
    assign instr = inst_sram_rdata;

    assign data_sram_en = 1'b1;     
    assign data_sram_wen = {memwrite};
    assign data_sram_addr = aluout;
    assign data_sram_wdata = writedata;
    assign readdata = data_sram_rdata;

    //ascii
    instdec instdec(
        .instr(instr)
    );

endmodule