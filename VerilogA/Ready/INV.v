`include "constants.vams" 
`include "disciplines.vams" 
module INV (Y, A, P, G); 
    output Y; 
    input A;
    inout  P, G; 
    electrical Y, A, P, G; 

    parameter real tplh = 0.1n from (0:100m); 
    parameter real tphl = 0.1n from (0:100m); 
    parameter real tr = 0.1n from (0:100m); 
    parameter real tf = 0.1n from (0:100m); 
    parameter real relVth = 0.5 from (0:1); 

    integer a, y; 
    real tdel, vth, vddss; 

    analog begin  
        @(initial_step) begin  
            vddss = V(P, G);  
            vth = vddss*relVth;  
            a = (V(A, G)>vth);  
            y = !a;  
        end  
            vddss = V( P, G);  
            vth = vddss*relVth;
            a = (V(A, G)>vth);  

        @(cross(V(A, G)-vth, 0)) or cross(V(P, G)-0.7, 0) begin 
            y = !a;  
            tdel = y? tplh:tphl;
        end
            
        V(Y, G) <+ vddss*transition(y, tdel, tr, tf);  
    end 
endmodule
