`include "constants.vams" 
`include "disciplines.vams" 
module BUFFER (Y, A, P, G); 
    output Y; 
    input A;
    inout  P, G; 
    electrical Y, A, P, G; 

    parameter real tplh = 0.1n from (0:100m); 
    parameter real tphl = 0.1n from (0:100m); 
    parameter real tr = 0.1n from (0:100m); 
    parameter real tf = 0.1n from (0:100m); 
    parameter real relVth = 0.5 from (0:1); 

    integer y; 
    real tdel, vth, vddss; 

    analog begin  
        @(initial_step) begin  
            vddss = V( P, G);  
            vth = vddss*relVth;  
            y = (V(A, G)>vth);  
        end  
        vddss = V( P, G);  
        vth = vddss*relVth;  

        @(cross(V(A, G)-vth, 0)) or cross(V(P, G)-0.7, 0) begin 
            y = (V(A, G)>vth);  
            if (y) begin   
                tdel=tplh;  
            end  
            else begin   
                tdel=tphl;  
            end
        end
            
        V(Y, G) <+ vddss*transition(y, tdel, tr, tf);  
    end 
endmodule
