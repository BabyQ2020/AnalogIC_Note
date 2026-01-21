/********************************************************************************
* @File name    : Best Code.v
* @Author       : zhanget / Ertong Zhang
* @Version      : 1.2
* @Created Date : 2024-07-28
* @Modified Date: 2024-08-04
* @Description  : Auto Trim, get the best trim code
********************************************************************************/

`include "discipline.h"
`include "constants.vams"
`include "disciplines.vams"
module BestCode (EN, CLK, VR, VOS, TRIM_CODE);
    input EN, CLK, VR;
    output VOS;
    output TRIM_CODE[6:0];

    voltage EN, CLK,VR;
    voltage VOS;
    voltage TRIM_CODE[6:0];

    parameter real VDD = 3.3;       // Supply voltage, you can adjust this value as needed
    parameter real VTH = 1.0;       // Threshold voltage
    parameter real VR_TAR = 1.0;    // target value
    parameter integer Bits=4;  // the bits of TRIM CODE, range:2:7

    // internal variables
    integer CNT=0; //counter
    integer CNT_max=pow(2,Bits); // max counter
    integer CODE=7'b0000000; // internal code

    integer i=0;
    integer Index_min=0;

    real Vos_min=0;
    real Vos_current=0; //current Vos
    real Vos_temp[128:0]=[  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ];   // store Vos

    // initial output                        
    analog begin
        @(initial_step) begin
            // transition( value, tdel, trise, tfall );
            V(TRIM_CODE[6]) <+ 0;
            V(TRIM_CODE[5]) <+ 0;
            V(TRIM_CODE[4]) <+ 0;
            V(TRIM_CODE[3]) <+ 0;
            V(TRIM_CODE[2]) <+ 0;
            V(TRIM_CODE[1]) <+ 0;
            V(TRIM_CODE[0]) <+ 0;
            V(VOS) <+ 0; 
        end
    end


    //EN上升沿写入初始数据 0000000
    analog begin
        @ (cross(V(EN) - VTH, 1, 10n)) begin
            CNT=0;
            CODE=7'b00000;
        end
    end

    //CLK 上升沿读取数据，并计算Vos
    analog begin
        @ (cross(V(CLK) - VTH, 1, 10n)) begin
            Vos_temp[CNT]=(V(VR)-VR_TAR)>0?(V(VR)-1):(1-V(VR));
            Vos_current=Vos_temp[CNT]; 

            // Find the minimum Vos value and corresponding TRIM_CODE
            if(CNT==CNT_max-1) begin  
                Vos_min = Vos_temp[0];
                Index_min = 0;

                for (i = 1; i <= CNT_max-1; i = i + 1) begin
                    if (Vos_temp[i] < Vos_min) begin
                        Vos_min = Vos_temp[i];
                        Index_min = i;
                    end
                end
            end
        end
    end


    // CLK 下降沿写入数据
    analog begin
        @ (cross(V(CLK) - VTH, -1, 10n)) begin
            // 写入前Max-1次的数据
            if(CNT<=CNT_max-1) begin
                CNT=CNT+1;
                CODE=CNT;
            end
            
            // 写入最后一次的bestcode
            if(CNT==CNT_max) begin
                CODE=Index_min;     
            end
        end
    end

    //将计算结果赋值给输出
    analog begin
        // transition( value, tdel, trise, tfall );
        V(TRIM_CODE[6]) <+ transition(((CODE&7'b1000000)>>6)*VDD,1n,1n,1n);
        V(TRIM_CODE[5]) <+ transition(((CODE&7'b0100000)>>5)*VDD,1n,1n,1n);
        V(TRIM_CODE[4]) <+ transition(((CODE&7'b0010000)>>4)*VDD,1n,1n,1n);
        V(TRIM_CODE[3]) <+ transition(((CODE&7'b0001000)>>3)*VDD,1n,1n,1n);
        V(TRIM_CODE[2]) <+ transition(((CODE&7'b0000100)>>2)*VDD,1n,1n,1n);
        V(TRIM_CODE[1]) <+ transition(((CODE&7'b0000010)>>1)*VDD,1n,1n,1n);
        V(TRIM_CODE[0]) <+ transition(((CODE&7'b0000001)>>0)*VDD,1n,1n,1n);
        V(VOS) <+ transition(Vos_current,1n,1n,1n); 
    end  
      
endmodule