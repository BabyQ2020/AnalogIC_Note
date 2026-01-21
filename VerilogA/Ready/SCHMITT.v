`include "constants.vams" 
`include "disciplines.vams" 
module SCHMMIT (Y, A, P, G); 
    output Y; 
    input A;
    inout  P, G; 
    electrical Y, A, P, G; 

    parameter real tplh = 0.1n from (0:100m); 
    parameter real tphl = 0.1n from (0:100m); 
    parameter real tr = 0.1n from (0:100m); 
    parameter real tf = 0.1n from (0:100m); 
    parameter real relVthH = 0.7 from (0:1); 
    parameter real relVthL = 0.3 from (0:1); 

    integer y; 
    real tdel, vthH, vthL, vddss; 

    analog begin  
        @(initial_step) begin  
            vddss = V(P, G);  
            vthH = vddss*relVthH;  
            vthL = vddss*relVthL;
            y= (V(A, G)>vthH)? 0:1;
        end  
            vddss = V( P, G);  
            vthH = vddss*relVthH;  
            vthL = vddss*relVthL; 

        @(cross(V(A, G)-vthH, +1)) begin 
            y = 0; 
            tdel=tphl; 
        end
        @(cross(V(A, G)-vthL, -1)) begin 
            y = 1; 
            tdel=tplh; 
        end

        V(Y, G) <+ vddss*transition(y, tdel, tr, tf);  
    end 
endmodule
