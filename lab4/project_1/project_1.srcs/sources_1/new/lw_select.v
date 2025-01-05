`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/01/03 20:20:51
// Design Name: 
// Module Name: lw_select
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


module lw_select(
    input wire adelW,               //LH、LW指令地址错例外
    input wire [31:0] aluoutW,      //ALU计算出的访存指令地址
    input [5:0] alucontrolW,        //访存指令类型
    input [31:0] lwresultW,         //读取内存的整字结果(4字节)
    output reg [31:0] resultW       //读取内存的真实结果(LB1字节/LH2字节)
    );

    always@ (*) begin
        if(~adelW) begin
            case(alucontrolW)
                6'b010101: case(aluoutW[1:0])  //LB指令读取1字节并按符号扩展
                    2'b00: resultW = {{24{lwresultW[7]}},lwresultW[7:0]};
                    2'b01: resultW = {{24{lwresultW[15]}},lwresultW[15:8]};
                    2'b10: resultW = {{24{lwresultW[23]}},lwresultW[23:16]};
                    2'b11: resultW = {{24{lwresultW[31]}},lwresultW[31:24]};
                    default: resultW = lwresultW;
                endcase
                6'b010110: case(aluoutW[1:0]) //LBU指令读取1字节并0扩展
                    2'b00: resultW = {{24{1'b0}},lwresultW[7:0]};
                    2'b01: resultW = {{24{1'b0}},lwresultW[15:8]};
                    2'b10: resultW = {{24{1'b0}},lwresultW[23:16]};
                    2'b11: resultW = {{24{1'b0}},lwresultW[31:24]};
                    default: resultW = lwresultW;
                endcase
                6'b010111: case(aluoutW[1:0])  //LH指令读取2字节并按符号扩展
                    2'b00: resultW = {{16{lwresultW[15]}},lwresultW[15:0]};
                    2'b10: resultW = {{16{lwresultW[31]}},lwresultW[31:16]};
                    default: resultW = lwresultW;  
                endcase
                6'b011000:case(aluoutW[1:0])  //LHU指令读取2字节并0扩展
                    2'b00: resultW = {{16{1'b0}},lwresultW[15:0]};
                    2'b10: resultW = {{16{1'b0}},lwresultW[31:16]};
                    default: resultW = lwresultW;    
                endcase
                default: resultW = lwresultW;   //LW指令读取4字节
            endcase
        end
        else begin
            resultW = 32'b0;
        end
    end
endmodule
