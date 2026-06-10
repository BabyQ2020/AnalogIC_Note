// Created Tue Jan 11 19:05:18 2022

`include "constants.vams"
`include "disciplines.vams"

module amp (VP, VN, VO);
    output VO;
    input VP, VN;
    electrical VO, VP, VN;

    parameter real vos = 1m;
    parameter real gain = 1000;
    parameter real vo_max = 5;
    parameter real vo_min = 0;
 
    real vo_v;
    analog begin
		vo_v = gain*(V(VP,VN)+vos);
        vo_v = vo_v<vo_min ? vo_min : vo_v;
        vo_v = vo_v>vo_max ? vo_max : vo_v;

        V(VO) <+ vo_v;
    end
endmodule
