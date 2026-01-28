//Verilog-AMS HDL for "CARACAL_SIM", "sw_trim" "verilogams"
`include "constants.vams"
`include "disciplines.vams"
module get_freq(CLK,Tsw,Fsw);
    input CLK;
    output Tsw, Fsw;
    voltage CLK, Tsw, Fsw;
 
    parameter VTH=1;
 
    real last_time=0;
    real current_time=0;
 
    real tsw1=0;
    real fsw1=0;
   
    analog begin
        @ (cross(V(CLK) - VTH, 1, 10p)) begin
            current_time=$abstime;

            if(last_time >0) begin
                tsw1=current_time-last_time;    
                fsw1=(tsw1>0)? 1/tsw1:0;
            end

            last_time=current_time;
        end
 
        //V(Tsw) <+ tsw1*1e9;    //ns
        //V(Fsw) <+ fsw1*1e-6;   //MHz
      
        V(Fsw) <+ transition(tsw1,1n,1n,1n);//ns
        V(Fsw) <+ transition(fsw1,1n,1n,1n);//MHz
    end
endmodule
