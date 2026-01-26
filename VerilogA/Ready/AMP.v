// Created Tue Jan 11 19:05:18 2022

`include "constants.vams"
`include "disciplines.vams"

module AMP (VP, VN, VO, VDD, VSS);
    output VO;
    input VP, VN, VDD, VSS;
    electrical VO, VP, VN, VDD, VSS;

    parameter real vos = 1m;
    parameter real gain = 1000;
 
    real vddss, vo_v;
    analog begin
        @(initial_step) begin
            vddss = V(VDD, VSS);
			vo_v = 0;
        end

		vddss = V(VDD, VSS);
		vo_v = gain*(V(VP,VN)+vos);

		if(vo_v<0) vo_v = 0;
		if(vo_v>vddss) vo_v = vddss;

        V(VO, VSS) <+ vo_v;
    end
endmodule
