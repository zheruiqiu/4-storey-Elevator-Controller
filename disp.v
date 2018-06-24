// 开门指示灯
// disp_door Display(dispDoor,dispStage)
module disp_door(dispDoor,dispStage);
/*
** 输出列表
** dispDoor(dispDoor)   :指示灯输出
** 输入列表
** dispStage(dispStage) :显示状态
*/
input [1:0] dispStage;
output reg[5:0] dispDoor;
always @(dispStage)
    case(dispStage)
        2'b00:dispDoor<=6'b111111;
        2'b01:dispDoor<=6'b11zz11;
        2'b10:dispDoor<=6'b1zzzz1;
        2'b11:dispDoor<=6'bzzzzzz;
    endcase

endmodule

module disp_floor(floorNum,position);
/*
** 输出列表
** floorNum(floorNum) :楼层指示输出
** 输入列表
** position(position) : 电梯所在位置
*/
input [3:0] position;
output reg [6:0] floorNum;

always @(position)
	case(position)
		4'b0001: floorNum = 7'b0110000;
		4'b0010: floorNum = 7'b1101101;
		4'b0100: floorNum = 7'b1111001;
		4'b1000: floorNum = 7'b0110011;
    endcase

endmodule


module disp_mode(ud_mode,dispMode);
input [1:0] ud_mode;
output reg[1:0]dispMode;

always @(ud_mode)
	case(ud_mode)
		2'b00: dispMode = 2'b00;
		2'b01: dispMode = 2'b0z;
		2'b10: dispMode = 2'bz0;
    endcase

endmodule