// 请求处理模块
// rq_process rq_process0(upReq_reg,downReq_reg,inEleReq_reg,up_need,down_need,clk32hz,upReq,downReq,inEleReq,position,ud_mode)
module rq_process(allReq_reg,upReq_reg,downReq_reg,inEleReq_reg,up_need,down_need,clk,upReq,downReq,inEleReq,position,ud_mode);
/*
** 输出列表
** allReq_reg   : 所有有效请求
** upReq_reg    : 有效上升请求
** downReq_reg  : 有效下降请求
** inEleReq_reg : 有效梯内请求
** up_need      : 上升需求
** down_need    : 下降需求
** 输入列表
** clk(clk32hz) : 高频32Hz时钟
** upReq        : 上升请求按键
** downReq      : 下降请求按键
** inEleReq     : 梯内请求按键
** position     : 电梯所在位置
** ud_mode      : 运行模式(00_停止,01_上升,10_下降)
*/
input clk;
input [1:0] ud_mode; //00_no require,01_up mode,10_down mode
input [3:0] upReq,downReq,inEleReq,position;
output reg [3:0] upReq_reg=4'd0;
output reg [3:0] downReq_reg=4'd0;
output reg [3:0] inEleReq_reg=4'd0;
output reg [3:0] allReq_reg;
output reg up_need=1'd0;
output reg down_need=1'd0;

always @(posedge clk)                              // 上升沿触发
    begin
        upReq_reg    <= upReq_reg    & (~position);    // 取消已到达楼层的请求
        downReq_reg  <= downReq_reg  & (~position);
        inEleReq_reg <= inEleReq_reg & (~position);
	    allReq_reg = upReq_reg | downReq_reg | inEleReq_reg;  // 所有有效请求 = 各种有效请求按位取或
	    if (allReq_reg==4'b0000) begin up_need<=1'b0; down_need<=1'b0; end
        if(ud_mode==2'b01 && (position<upReq || position<downReq || position<inEleReq))
        begin                                          // 上升过程中，仅响应上方的请求
            upReq_reg<=upReq | upReq_reg;
            downReq_reg<=downReq | downReq_reg;
            inEleReq_reg<=inEleReq | inEleReq_reg;
           up_need<=1'b1;                             //上方存在有效请求，则有上升需求
        end
        else if(ud_mode==2'b10 && (position>upReq || position>downReq || position>inEleReq) && (|(upReq|downReq|inEleReq)))
        begin                                          // 下降过程中，仅响应下方的请求
            upReq_reg<=upReq | upReq_reg;
            downReq_reg<=downReq | downReq_reg;
            inEleReq_reg<=inEleReq | inEleReq_reg;
             down_need<=1'b1;                           //下方存在有效请求，则有下降需求
        end
         else if(ud_mode==2'b00)
        begin                                          // 停止过程中，响应第一个请求
            upReq_reg<=upReq | upReq_reg;
            downReq_reg<=downReq | downReq_reg;
            inEleReq_reg<=inEleReq | inEleReq_reg;
            #7  if (position<allReq_reg && allReq_reg!=4'b0000) up_need<=1;          //上方存在有效请求，则有上升需求
                else if (position>allReq_reg && allReq_reg!=4'b0000) down_need<=1;   //下方存在有效请求，则有下降需求
        end
    end

endmodule

// 电梯外请求对外接口

module rq_interface(upReq,downReq,upInput,downInput);
input [2:0] upInput,downInput;
output [3:0] upReq,downReq;

assign upReq = {1'b0,upInput};
assign downReq = {downInput,1'b0};

endmodule