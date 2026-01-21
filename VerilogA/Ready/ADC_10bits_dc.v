`include "constants.vams"
`include "disciplines.vams"

module ADC_10bit_dc(VDD, VSS, VREF, A, Y); 
    output Y[9:0]; 
    input A, VREF;
    inout  VDD, VSS; 
    electrical VDD, VSS, VREF, A, Y[9:0]; 

    real vdd_v = 0;
    real vref_v = 0;
    real va_v = 0;
    integer code_v = 0;

    analog begin  
        @(initial_step) begin  
            vdd_v = V(VDD, VSS);
            vref_v =  V(VREF, VSS);
            va_v = V(A, VSS);
        end  

        vdd_v = V(VDD, VSS);
        vref_v =  V(VREF, VSS);
        va_v = V(A, VSS);

        if(va_v > vref_v) begin
            code_v = 1023;
        end
        else if(va_v >= 0) begin
            code_v = 1023*va_v/vref_v;
        end
        else begin
            code_v = 0;
        end

        V(Y[0], VSS) <+ vdd_v*transition((code_v&10'b0000000001)>>0, 1n, 1n, 1n);
        V(Y[1], VSS) <+ vdd_v*transition((code_v&10'b0000000010)>>1, 1n, 1n, 1n);  
        V(Y[2], VSS) <+ vdd_v*transition((code_v&10'b0000000100)>>2, 1n, 1n, 1n);
        V(Y[3], VSS) <+ vdd_v*transition((code_v&10'b0000001000)>>3, 1n, 1n, 1n);
        V(Y[4], VSS) <+ vdd_v*transition((code_v&10'b0000010000)>>4, 1n, 1n, 1n);
        V(Y[5], VSS) <+ vdd_v*transition((code_v&10'b0000100000)>>5, 1n, 1n, 1n);
        V(Y[6], VSS) <+ vdd_v*transition((code_v&10'b0001000000)>>6, 1n, 1n, 1n);
        V(Y[7], VSS) <+ vdd_v*transition((code_v&10'b0010000000)>>7, 1n, 1n, 1n);
        V(Y[8], VSS) <+ vdd_v*transition((code_v&10'b0100000000)>>8, 1n, 1n, 1n);
        V(Y[9], VSS) <+ vdd_v*transition((code_v&10'b1000000000)>>9, 1n, 1n, 1n);
    end 
endmodule
