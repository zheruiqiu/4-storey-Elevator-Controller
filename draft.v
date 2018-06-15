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