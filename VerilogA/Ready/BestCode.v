/********************************************************************************
* @File name    : BestCode.v
* @Author       : zhanget / Ertong Zhang
* @Version      : 1.4
* @Created Date : 2024-07-28
* @Modified Date: 2026-1-19
* @Description  : Auto Trim, get the best trim code
********************************************************************************/

`include "discipline.h"
`include "constants.vams"
`include "disciplines.vams"
module BestCode(VDD, VSS, EN, CLK, VR_TAR, VR_ACT, VOS, CODE);
  input VDD, VSS, EN, CLK, VR_TAR, VR_ACT;
  output VOS; // VR_ACT-VR_TAR
  output CODE[6:0];

  voltage VDD, VSS, EN, CLK, VR_TAR, VR_ACT, VOS;
  voltage CODE[6:0];

  parameter integer Bits = 4;       // the bits of TRIM CODE, range:2:7

  real vddss =0;
  real vth = 1.0;   
  real vos_v = 0;
 

  // internal variables
  integer CNT = 0; //counter
  integer CNT_max = pow(2,Bits); // max counter
  integer CODE_v = 7'b0000000; // internal code

  integer i = 0;
  integer bst_code = 0;

  real Vos_min = 0;
  real Vos_current = 0; //current Vos
  real Vos_array[128:0] = [ 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ];   // store Vos

  // initial output                        
  // analog begin
  //   @(initial_step) begin
  //     vddss = V(VDD,VSS);  
  //     vref = V(VR_ACT,VSS);
  //     vth = 0.5*vddss;

  //     V(CODE[6],VSS) <+ 0;
  //     V(CODE[5],VSS) <+ 0;
  //     V(CODE[4],VSS) <+ 0;
  //     V(CODE[3],VSS) <+ 0;
  //     V(CODE[2],VSS) <+ 0;
  //     V(CODE[1],VSS) <+ 0;
  //     V(CODE[0],VSS) <+ 0;
  //     V(VOS) <+ 0; 
  //   end
  // end

  //EN 0000000
  analog begin
    vddss = V(VDD,VSS);  
    vos_v = V(VR_ACT,VR_TAR);
    vth = 0.5*vddss;

    @ (cross(V(EN,VSS) - vth, 1, 1n)) begin
      CNT = 0;
      CODE_v = 7'b00000;
    end
  end

  //CLK posedge, get the Vos
  analog begin
    @ (cross(V(CLK,VSS) - vth, 1, 1n)) begin
      Vos_array[CNT] = vos_v > 0? vos_v:-vos_v;
      Vos_current = Vos_array[CNT]; 

      // Find the minimum Vos value and corresponding CODE
      if(CNT==CNT_max-1) begin 
        Vos_min = Vos_array[0];
        bst_code = 0;

        for (i = 1; i <= CNT_max-1; i = i + 1) begin
          if (Vos_array[i] < Vos_min) begin
            Vos_min = Vos_array[i];
            bst_code = i;
          end
         end
      end
    end
  end


  // CLK negedge, +1
  analog begin
    @ (cross(V(CLK,VSS) - vth, -1, 1n)) begin
      if(CNT<=CNT_max-1) begin
        CNT = CNT+1;
        // CODE_v = CNT;
        CODE_v = V(EN,VSS) > vth? CNT:0;
      end

      // get the BestCode
      if(CNT==CNT_max) begin
        CODE_v = bst_code;
        CODE_v = V(EN,VSS) > vth? bst_code:0;   
      end
    end
  end

  //
  analog begin
    V(CODE[6],VSS) <+ vddss * transition((CODE_v&7'b1000000)>>6,1n ,1n, 1n);
    V(CODE[5],VSS) <+ vddss * transition((CODE_v&7'b0100000)>>5,1n, 1n, 1n);
    V(CODE[4],VSS) <+ vddss * transition((CODE_v&7'b0010000)>>4,1n, 1n, 1n);
    V(CODE[3],VSS) <+ vddss * transition((CODE_v&7'b0001000)>>3,1n, 1n, 1n);
    V(CODE[2],VSS) <+ vddss * transition((CODE_v&7'b0000100)>>2,1n, 1n, 1n);
    V(CODE[1],VSS) <+ vddss * transition((CODE_v&7'b0000010)>>1,1n, 1n, 1n);
    V(CODE[0],VSS) <+ vddss * transition((CODE_v&7'b0000001)>>0,1n, 1n, 1n);
    V(VOS) <+ transition(Vos_current, 1n, 1n, 1n); 
  end 
endmodule
