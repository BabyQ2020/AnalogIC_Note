// VerilogA for zhanget_lib_sch, ADDER, veriloga

`include "constants.vams"
`include "disciplines.vams"

module ADDER(A1, A2, Y);
input A1, A2;
output Y;
electrical A1, A2, Y;
parameter real k1 = 1;
parameter real k2 = 1;

   analog
   	V(Y) <+ k1*V(A1) + k2*V(A2);
endmodule
