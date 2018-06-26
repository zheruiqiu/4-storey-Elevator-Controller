//counter_open open_Timer(dispStage,DoorCount,endOpen,clk4hz,opendoor,delay);
module counter_open(dispStage,count,endOpen,CP,StOpen,pause,close);
	input CP,StOpen,pause,close;
	output reg [6:0] count;
	output reg endOpen;
	output reg [1:0] dispStage=2'b00;
	reg [6:0] endTime = 7'b0010101;
	always @ (posedge CP)
		if(!StOpen) begin count <= 7'b0000000;endOpen<=0;dispStage<=2'b00; end
		else
			begin
			if(count == endTime)
				begin count<=7'd0;endOpen<=1;dispStage<=2'b00; end
			else if (close)count = endTime-7'b0000011;
            else if (pause)endTime <= endTime;
			else
				begin 
				count<=count+1'd1;endOpen<=0;
				if (count == 7'd1)dispStage<=2'b01;
				else if (count == 7'd2)dispStage<=2'b10;
				else if (count == 7'd3)dispStage<=2'b11;
				else if (count == endTime-7'b0000010)dispStage<=2'b10;
				else if (count == endTime-7'b0000001)dispStage<=2'b01;
				//else dispStage<=2'b00;
				end
			end
endmodule
/*
如果需要缩短延迟信号响应时间，用这一段
module delaybutton(pause,counter,delay_reg,CP_L,CP_H,delay);
input delay,CP_L,CP_H;
output reg pause=0;
output reg delay_reg=0;
output reg [6:0] counter;
parameter conuntEnd = 7'd20;
always @ (posedge CP_L)
	begin
		if(!delay_reg) counter<=7'd0;
		else if (delay == delay_reg) counter<=7'd0;
		else if (counter==conuntEnd) counter<=7'd0;
		else counter<=counter+1'b1;
	end
always @ (posedge CP_H)
	begin
		delay_reg <= delay|delay_reg;
		if(!delay_reg) pause<=0;
		else if (delay == delay_reg) begin pause<=1;end
		else if (counter==conuntEnd) begin delay_reg<=0;pause<=1'b0;end
		else pause<=1;
	end
endmodule
*/

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
		upReq_reg<={downReq[2],upReq[2:1],1'b0} | upReq_reg;
        downReq_reg<={1'b0,downReq[1:0],upReq[0]} | downReq_reg;
        inEleReq_reg<=inEleReq | inEleReq_reg;
	    if (allReq_reg==4'b0000) begin up_need<=1'b0; down_need<=1'b0; end

		if (ud_mode==2'b01)
		begin
			upReq_reg    <= upReq_reg    & (~position); // 取消已到达楼层的请求
			inEleReq_reg <= inEleReq_reg & (~position);
			allReq_reg = upReq_reg | inEleReq_reg;
        	if (allReq_reg!=4'b0000) up_need<=1'b1;                             //上方存在有效请求，则有上升需求
		end
		else if (ud_mode==2'b10)
		begin
			downReq_reg  <= downReq_reg  & (~position); // 取消已到达楼层的请求
			inEleReq_reg <= inEleReq_reg & (~position);
			allReq_reg = downReq_reg | inEleReq_reg;
        	if (allReq_reg!=4'b0000) down_need<=1'b1;
		end
        else if(ud_mode==2'b00)
        begin                                          // 停止过程中，响应第一个请求
            allReq_reg = upReq_reg | downReq_reg | inEleReq_reg;
            if (position<allReq_reg && allReq_reg!=4'b0000) up_need<=1;          //上方存在有效请求，则有上升需求
            else if (position>allReq_reg && allReq_reg!=4'b0000) down_need<=1;   //下方存在有效请求，则有下降需求
        end
    end

endmodule

20180626
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

		upReq_reg=upReq | upReq_reg;     
        downReq_reg=downReq | downReq_reg; 
        inEleReq_reg=inEleReq | inEleReq_reg;
		allReq_reg = upReq_reg|downReq_reg|inEleReq_reg;
		if (allReq_reg==4'b0000) ud_mode=2'b00;

		if (ud_mode==2'b00)
		begin
			allReq_reg = upReq_reg|downReq_reg|inEleReq_reg;
			if (position<allReq_reg && allReq_reg!=4'b0000) ud_mode=2'b01;         // 上方存在有效请求，则有上升需求
            else if (position>allReq_reg && allReq_reg!=4'b0000) ud_mode=2'b10;  // 下方存在有效请求，则有下降需求
		end
		if (ud_mode==2'b01)
		begin
			upReq_reg    = upReq_reg    & (~position);    // 取消已到达楼层的请求
			inEleReq_reg = inEleReq_reg & (~position);
			if (position==hst_down && hst_down>upReq_reg) 
			begin				
				downReq_reg  = downReq_reg & (~position);
				eff_req = eff_req & (~position);
				ud_mode=2'b00;
			end
			eff_req = ((~(position-4'b0001)) & (upReq_reg | inEleReq_reg));
			if (hst_down>upReq_reg) eff_req = (hst_down | eff_req) & (~position);
			if (eff_req != 4'b0000) ud_mode = 2'b01;
			else ud_mode = 2'b00;
		end
		if (ud_mode==2'b10)
		begin
				downReq_reg  = (downReq_reg  & (~position));    // 取消已到达楼层的请求
				inEleReq_reg = (inEleReq_reg & (~position));
			if (position==lst_up && (lst_up<downReq_reg || downReq_reg==4'b0000))
			begin
				upReq_reg = upReq_reg & (~position);
				eff_req = eff_req & (~position);
				ud_mode=2'b00;
			end
			else
			begin
				eff_req = ((position-4'b0001) & (downReq_reg | inEleReq_reg));
				if (lst_up<downReq_reg || downReq_reg==4'b0000) eff_req = (lst_up | eff_req) & (~position);
				if (eff_req != 4'b0000) ud_mode = 2'b10;
				else ud_mode = 2'b00;
			end
		end
	end