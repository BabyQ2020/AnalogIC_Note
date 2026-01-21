`include "constants.vams"
`include "disciplines.vams"

module GetFrequence(CLK,Tsw,Fsw); 
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
            tsw1=current_time-last_time;    
            fsw1=(tsw1>0)? 1/tsw1:0;
            last_time=current_time;
        end

        V(Tsw) <+ tsw1;   
        V(Fsw) <+ fsw1;   
    end
    
endmodule
