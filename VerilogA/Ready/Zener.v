`include "disciplines.vams"

module zener_diode(A, Z);
  electrical A, Z;  // 
  parameter real Vz = 5.1;    //  @ 25C (5.1V)
  parameter real Vf = 0.7;    //  @ 25C
  parameter real Rz = 2.0;    //  (2)
  parameter real Rf = 0.1;    //  (0.1)
  parameter real TempCoeff = 0.0001; // 0.05 default (%/C)
  parameter real Tnom = 27;   // 
  parameter real n_ideal = 1.0; // 
  real Vt;                    // 
  real Vz_actual;             // 
  real Is;                    // 
  real Vpn;                   // 

  analog begin
    // 
    Vt = $vt(Tnom);           // (k*T/q)
    Is = 1e-12;               // 
    
    // 
    Vz_actual = Vz * (1 + TempCoeff*0.01*(Tnom - $temperature));
    
    // 
    Vpn = V(A,Z);

    // 
    if (Vpn > Vf) begin       // 
      I(A,Z) <+ (Vpn - Vf)/Rf + Is*(exp(Vpn/(n_ideal*Vt)) - 1);
    end
    else if (Vpn < -Vz_actual) begin  // 
      I(A,Z) <+ (Vpn + Vz_actual)/Rz;
    end
    else begin                // 
      I(A,Z) <+ Is*(exp(Vpn/(n_ideal*Vt)) - 1);
    end
  end
endmodule