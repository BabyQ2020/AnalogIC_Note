/********************************************************************************
* @File name    : and2.v
* @Author       : zhanget / Ertong Zhang
* @Version      : 1.0
* @Created Date : 2026-02-27
* @Modified Date: 2026-02-27
* @Description  : and2
********************************************************************************/

`include "constants.vams"
`include "disciplines.vams"

module and2 (Y, A, B, VDD, VSS);
	output Y;
	input A, B, VDD, VSS;
	electrical Y, A, B, VDD, VSS;

	parameter real tplh = 0.1n from (0:100m);
	parameter real tphl = 0.1n from (0:100m);
	parameter real tr = 0.1n from (0:100m);
	parameter real tf = 0.1n from (0:100m);
	parameter real relVth = 0.5 from (0:1);

	integer a, b, y;
	real tdel, vth, vddss;

	analog begin
		@(initial_step) begin
			vddss = V(VDD, VSS);
			vth = vddss * relVth;
			a = V(A, VSS) > vth;
			b = V(B, VSS) > vth;
			y = a & b;
		end

		vddss = V(VDD, VSS);
		vth = vddss * relVth;

		@(cross(V(A, VSS)-vth, 0));
		@(cross(V(B, VSS)-vth, 0));

		a = V(A, VSS)>vth;
		b = V(B, VSS)>vth;
		y = a & b;
		tdel = y? tplh : tphl;

		V(Y, VSS) <+ vddss*transition(y, tdel, tr, tf);	
	end
endmodule
