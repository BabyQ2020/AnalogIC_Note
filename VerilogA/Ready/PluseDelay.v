`include "constants.vams"
`include "disciplines.vams"

module PluseDelay (Y, A,  P, G); 
    output Y; 
    input A;
    inout  P, G; 
    electrical Y, A, P, G; 
    
    parameter real tplh = 10n from (0:100m); 
    parameter real tphl = 10n from (0:100m); 
    parameter real tr = 0.1n from (0:100m); 
    parameter real tf = 0.1n from (0:100m); 
    parameter real relVth = 0.5 from (0:1); 

    integer a; 
    real tdel, vth, vddss; 

    analog begin  
        @(initial_step) begin  
            vddss = V( P, G);  
            vth = vddss*relVth;  
            a = (V(A, G)>=vth);  
        end  
            vddss = V( P, G);  
            vth = vddss*relVth;  
            a = (V(A, G)>=vth);  

        @(cross(V(A, G)-vth, 0)) begin 
            tdel = a? tplh:tphl;
        end
            V(Y, G) <+ vddss*transition(a, tdel, tr, tf);  
        end 
endmodule

