// VerilogA for zhanget_lib_sch, OTA, veriloga

`include "constants.vams"
`include "disciplines.vams"

module OTA(VP, VN, OUT, VDD, VSS);
  // Ports
  input VP, VN, VDD, VSS;
  output OUT;
  electrical VP, VN, OUT, VDD, VSS;

  // Parameters
  parameter real gm = 10u;               // Transconductance (S)
  parameter real max_output_current = 50u; // Maximum output current (A)
  parameter real min_output_current = -50u;// Minimum output current (A)
  
  real I_ideal;

  analog begin
    
    // Ideal output current: I = gm * (V(VP) - V(VN))
    I_ideal = gm * V(VN, VP);

    // Current limiting
    if (I_ideal > max_output_current)
      I_ideal = max_output_current;
    else if (I_ideal < min_output_current)
      I_ideal = min_output_current;

    // Output current source (from OUT to VSS) with parallel output resistance
    I(OUT, VSS) <+ I_ideal;           // Controlled current
  end
endmodule
