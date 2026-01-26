// VerilogA for zhanget_lib_sch, comp_en, veriloga

`include "constants.vams"
`include "disciplines.vams"

module comp_en (EN, VP, VN, VDD, VSS, VO);
input EN, VP, VN, VDD, VSS;
output VO;
electrical EN, VP, VN, VDD, VSS, VO;

parameter real vhyst=0;
parameter real td=1n;
parameter real tr=1n;
parameter real tf=1n;

integer y;
real minimum;

  analog begin
	@(initial_step) begin
        minimum=1n;
        if ( V(EN,VSS)<V(VDD,VSS) )
            y=0;
        else
            y=(V(VP,VN)-minimum)>0;
	end

	@(cross(V(VP,VN)-minimum, 0));
        if ( V(EN,VSS)<V(VDD,VSS)/2 )
            y=0;
        else begin
            if(V(VP,VN)>minimum) begin
                y=1;
                minimum=-vhyst;  //accurate vth when y flip from low to high, hys always =vn-vp
            end
            else begin
                y=0;
                minimum=0;
            end
        end
        V(VO,VSS) <+ V(VDD,VSS)*transition(y,td,tr,tf);
  end
endmodule
