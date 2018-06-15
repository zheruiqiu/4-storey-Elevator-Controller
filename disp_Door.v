module disp_door(dispStage,disp);
input [1:0] dispStage;
output reg[5:0] disp;
always @(dispStage)
    case(dispStage)
        2'b00:disp<=6'b111111;
        2'b01:disp<=6'b11zz11;
        2'b10:disp<=6'b1zzzz1;
        2'b11:disp<=6'bzzzzzz;
    endcase
endmodule