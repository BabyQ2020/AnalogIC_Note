`include "constants.vams" 
`include "disciplines.vams" 
module AND3 (Y, A, B, C, P, G); 
    output Y; 
    input A, B, C;
    inout  P, G; 
    electrical Y, A, B, C, P, G; 

    parameter real tplh = 0.1n from (0:100m); 
    parameter real tphl = 0.1n from (0:100m); 
    parameter real tr = 0.1n from (0:100m); 
    parameter real tf = 0.1n from (0:100m); 
    parameter real relVth = 0.5 from (0:1); 

    integer a, b, c, y; 
    real tdel, vth, vddss; 

    analog begin  
        @(initial_step) begin  
            vddss = V( P, G);  
            vth = vddss*relVth;  
            a = (V(A, G)>vth);  
            b = (V(B, G)>vth);
            c = (V(C, G)>vth);    
            y = (a&&b&&c);  
        end  
            vddss = V( P, G);  
            vth = vddss*relVth;  
            a = (V(A, G)>vth);  
            b = (V(B, G)>vth);
            c = (V(C, G)>vth); 

        @(cross(V(A, G)-vth, 0) or cross(V(B, G)-vth, 0) or cross(V(C, G)-vth, 0)) begin 
            y = (a&&b&&c);  
            tdel = y? tplh:tphl;
        end
            V(Y, G) <+ vddss*transition(y, tdel, tr, tf);  
        end 
endmodule
