// 状态控制模块
// state_control state_control0(opendoor,mv2nxt,ud_mode,state,position,clk32Hz,switch,allReq_reg,endRun,endOpen,up_need,down_need)
module state_control(opendoor,mv2nxt,ud_mode,state,position,clk,switch,allReq_reg,endRun,endOpen,up_need,down_need);
/*
** 输出列表
** opendoor(opendoor)     : 开门指令
** mv2nxt(mv2nxt)         : 移动指令  move to next floor
** ud_mode(ud_mode)       : 运行模式
** state(state)           : 运行状态
** position(position)     : 电梯所在位置
** 输入列表
** clk(clk32Hz)           : 时钟(高频时钟)
** switch(switch)         : 电梯总开关
** allReq_reg(allReq_reg) : 当前有效请求
** endRun(endRun)         : 移动完毕
** endOpen(endOpen)       : 开门完毕
** up_need(up_need)       : 上升需求
** down_need(down_need)   : 下降需求
*/
input clk,switch,endRun,endOpen;
input [3:0] allReq_reg;
input up_need,down_need;
output reg [1:0] ud_mode;
output reg [2:0] state;           //000_stop,001_pause,010_move
output reg [3:0] position;
output reg opendoor,mv2nxt;

always @(posedge clk)
    begin
        if (allReq_reg==4'b0000) ud_mode<=2'b00;
        else if (up_need) ud_mode<=2'b01;
        else if (down_need) ud_mode<=2'b10;

		if (switch==1'b0)         // 最高优先级电梯总开关，关闭时
		begin
			state[2:0]=3'b000;    // 电梯处于停滞状态
			opendoor=1'b0;        // 关门
            mv2nxt=1'b0;          // 不移动
			position=4'b0001;     // 始终在一楼
        end
        else                      // 电梯总开关开启状态
        begin
            case (state)
            3'b000:state[2:0]=3'b001;                      // 总开关开启后，电梯进入暂停状态
            3'b001:                                        // 电梯处于暂停状态时
            begin
                if(|(allReq_reg & position)==1)            // 如果此层需要停靠
                begin
                    opendoor=1'b1;                         // 开门计时开始
                end
                else if ((up_need | down_need)==1 && opendoor!=1'b1)    // 如果有其它层需要停靠,且未开门
                begin
                    mv2nxt=1;
                    state=3'b010;                          // 转入移动状态
                end
    			else state[2:0]=3'b001;                    // 否则(有其它层需要停靠或已经开门)，则保持暂停
                if (endOpen==1)                            // 开门完毕
                begin
                    opendoor=0;                            // 开门计时清零
                    mv2nxt=1;
                    if (ud_mode!=2'b00) state=3'b010;
					else mv2nxt=0;
                end
            end
            3'b010:                                        // 电梯处于移动状态时
            begin
                if(endRun==1)                              // 如果运行完毕
                begin                                      // 如果处于上升模式，楼层上升；反之，下降
                    mv2nxt=0;                              // 运行计时清零
                    if(ud_mode==2'b01)                     // 如果此时处于上升状态
        			begin 
	       			    position=position<<1;              // 电梯上移
					    state=3'b001;                      // 并转入暂停
					end
                    else                                   // 如果此时处于下降状态
                    begin 
					    position=position>>1;              // 电梯下移
					    state=3'b001;                      // 并转入暂停
    				end
                end
            end
            endcase
        end
    end

endmodule