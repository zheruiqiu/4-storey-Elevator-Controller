// 请求处理模块
// rq_process rq_process0(upReq_reg,downReq_reg,inEleReq_reg,up_need,down_need,clk32hz,upReq,downReq,inEleReq,position,ud_mode)
module rq_process(eff_req,allReq_reg,upReq_reg,downReq_reg,inEleReq_reg,hst_down,lst_up,clk,upReq,downReq,inEleReq,position,ud_mode);
/*
** 输出列表
** allReq_reg   : 当前有效请求
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
output reg [1:0] ud_mode; //00_no require,01_up mode,10_down mode
input [3:0] upReq,downReq,inEleReq,position;
output reg [3:0] upReq_reg=4'd0;
output reg [3:0] downReq_reg=4'd0;
output reg [3:0] inEleReq_reg=4'd0;
output reg [3:0] allReq_reg;
output reg [3:0] eff_req;
output reg [3:0] hst_down;
output reg [3:0] lst_up;


always @(posedge clk)         // 上升沿触发
    begin
		if(|(4'b1000 & downReq_reg)==1) hst_down = 4'b1000;
		else if(|(4'b0100 & downReq_reg)==1) hst_down = 4'b0100;
		else if(|(4'b0010 & downReq_reg)==1) hst_down = 4'b0010;
		else hst_down = 4'b0000;
		if(|(4'b0001 & upReq_reg)==1) lst_up = 4'b0001;
		else if(|(4'b0010 & upReq_reg)==1) lst_up = 4'b0010;
		else if(|(4'b0100 & upReq_reg)==1) lst_up = 4'b0100;
		else lst_up = 4'b0000;

		upReq_reg<=upReq | upReq_reg;     
        downReq_reg<=downReq | downReq_reg; 
        inEleReq_reg<=inEleReq | inEleReq_reg;
		allReq_reg = upReq_reg|downReq_reg|inEleReq_reg;
		if (allReq_reg==4'b0000) ud_mode<=2'b00;

		if (ud_mode==2'b00)
		begin
			allReq_reg = upReq_reg|downReq_reg|inEleReq_reg;
			if (position<allReq_reg && allReq_reg!=4'b0000) ud_mode<=2'b01;         // 上方存在有效请求，则有上升需求
            else if (position>allReq_reg && allReq_reg!=4'b0000) ud_mode<=2'b10;  // 下方存在有效请求，则有下降需求
		end
		if (ud_mode==2'b01)
		begin
			upReq_reg    <= upReq_reg    & (~position);    // 取消已到达楼层的请求
			inEleReq_reg <= inEleReq_reg & (~position);
			if (position==hst_down && hst_down>upReq_reg) 
			begin				
				downReq_reg  <= downReq_reg & (~position);
				ud_mode<=2'b00;
			end
			eff_req = ((~(position-4'b0001)) & (upReq_reg | inEleReq_reg));
			if (hst_down>upReq_reg) eff_req = hst_down | eff_req;
			if (eff_req != 4'b0000) ud_mode <= 2'b01;
			else ud_mode <= 2'b00;
		end
		if (ud_mode==2'b10)
		begin
			downReq_reg  <= downReq_reg  & (~position);    // 取消已到达楼层的请求
			inEleReq_reg <= inEleReq_reg & (~position);
			if (position==lst_up && (lst_up<downReq_reg || downReq_reg==4'b0000))
			begin
				upReq_reg <= upReq_reg & (~position);
				ud_mode<=2'b00;
			end
			else
			begin
				eff_req = ((position-4'b0001) & (downReq_reg | inEleReq_reg));
				if (lst_up<downReq_reg || downReq_reg==4'b0000) eff_req = lst_up | eff_req;
				if (eff_req != 4'b0000) ud_mode <= 2'b10;
				else ud_mode <= 2'b00;
			end
		end
	end


endmodule

// 电梯外请求对外接口
// rq_interface rq_interface0(upReq,downReq,upInput,downInput);
module rq_interface(upReq,downReq,upInput,downInput);
/*
** 输出列表
** upReq     : 上升请求
** downReq   : 下降请求
** 输入列表
** upInput   :电梯上升按键
** downInput :电梯下降按键
*/
input [2:0] upInput,downInput;
output [3:0] upReq,downReq;

assign upReq = {1'b0,upInput};
assign downReq = {downInput,1'b0};

endmodule