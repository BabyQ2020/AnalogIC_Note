`include "constants.vams" 
`include "disciplines.vams" 
module DFF (R, D, CK,Q, QN, P, G); 
    output Q, QN; 
    input D, CK, R;
    inout  P, G; 
    electrical R, D, CK,Q, QN, P, G; 

    parameter real tplh = 0.1n from (0:100m); 
    parameter real tphl = 0.1n from (0:100m); 
    parameter real tr = 0.1n from (0:100m); 
    parameter real tf = 0.1n from (0:100m); 
    parameter real relVth = 0.7 from (0:1); 

    integer q; 
    real tdel, vth, vddss; 

    analog begin  
        @(initial_step) begin  
            vddss = V(P, G);  
            vth = vddss*relVth;  
            q = 0;
        end  
            vddss = V( P, G);  
            vth = vddss*relVth;  
 
        @(cross(V(R, G)-vth, -1)) begin 
            q = 0;
            tdel = tphl;
        end

        @(cross(V(CK, G)-vth, 1)) begin
            q = (V(R, G)>vth)? (V(D, G)>vth):0;
            tdel = q? tplh:tphl;
        end
        V(Q, G) <+ vddss*transition(q, tdel, tr, tf); 
        V(QN, G) <+ vddss*transition(!q, tdel, tr, tf);   
    end 
endmodule
