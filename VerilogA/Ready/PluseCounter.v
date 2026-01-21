`include "constants.vams"
`include "disciplines.vams"
module PluseCounter(CLK,CNT);
    input CLK; 
    output CNT;
    electrical CLK, CNT;

    parameter real vth = 1.0;
    parameter real tdel =0.5n from(1p:1m);
    parameter real tr = 0.5n from(1p:1m);
    parameter real tf = 0.5n from(1p:1m);
    
    integer cnt_v;
    analog begin
        @(initial_step) begin
            cnt_v = 0;
        end

        @(cross(V(CLK)-vth, 1, 0.1n)) begin
            cnt_v = cnt_v +1;
        end
        V(CNT) <+ transition(cnt_v, tdel, tr, tf);
    end
endmodule

    
