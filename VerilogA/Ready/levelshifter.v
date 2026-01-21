`include "constants.vams"
`include "disciplines.vams"

module LeverShifter(A, Z, VDD1, VSS1, VDD2, VSS2);
  input A, VDD1, VSS1, VDD2, VSS2;
  output Z;
  electrical A, Z, VDD1, VSS1, VDD2, VSS2;
  
  parameter real relVth = 0.5   from (0:1); 
  parameter real tdel   = 0.5n  from (0:1m);
  parameter real tr     = 0.5n  from (0:1m);
  parameter real tf     = 0.5n  from (0:1m);


  real vddss1, vddss2,vth;
  integer z1;
  
  analog begin
    vddss1 = V(VDD1,VSS1);
    vddss2 = V(VDD2,VSS2);
    vth = vddss1 * relVth;
    
	z1 = (V(A,VSS1) > vth)? 1:0;

	V(Z,VSS2) <+ vddss2*transition(z1, tdel, tr, tf);
  end
	
endmodule


