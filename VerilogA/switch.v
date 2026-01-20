`include "constants.vams"
`include "disciplines.vams"
module switch (S, A, Z);
input S;
inout A, Z;
electrical S, A, Z;

parameter real vh = 1;
parameter real vl = 0.5;
parameter real ron = 10m from (1e-6:inf);
parameter real roff = 1e7 from (1e3:inf);
parameter real td = 2n from (0:inf);
parameter real tr = 1n from (0:inf);
parameter real tf = 1n from (0:inf);

real rsw;
integer rstate;

    analog begin
        @(initial_step) begin
            rstate=0;
        end
    end

    analog begin
        @(cross(V(S)-vh,1)) begin
        rstate=1;
        end

        @(cross(V(S)-vl,-1)) begin
        rstate=0;
        end

        rsw=roff*pow(ron/roff, transition(rstate, td, tr, tf));
        I(A, Z) <+ V(A, Z)/rsw;
    end
endmodule
