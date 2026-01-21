`include "constants.vams"
`include "disciplines.vams"

module DiodeSim(A, Z);
    inout A, Z;
    electrical A, Z;

    parameter real is=1p from(0:inf);
    parameter real r =0 from(0:inf);
    
    analog begin
        I(A,Z) <+ is*(limexp((V(A,Z)-r*I(A,Z))/$vt) - 1);
    end

endmodule
