`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/22 09:53:32
// Design Name: 
// Module Name: floprc
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

//可复位、可清零的 D 触发器 
module floprc #(parameter WIDTH = 16)(
	input wire clk,rst,clear,  //时钟信号、复位信号、清零信号
	input wire[WIDTH-1:0] d,   //输入数据，宽度为参数 WIDTH
	output reg[WIDTH-1:0] q    //输出数据，宽度为参数 WIDTH
    );

	always @(posedge clk,posedge rst) begin
		if(rst) begin
			q <= 0;
		end else if (clear)begin
			q <= 0;
		end else begin 
			q <= d;
		end
	end
endmodule
