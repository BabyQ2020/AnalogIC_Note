// VerilogA for zhanget_lib_sch, CLAMP, veriloga

`include "constants.vams"
`include "disciplines.vams"

module CLAMP(Y, VSS);
    inout Y, VSS;
    electrical Y, VSS;

    parameter Vmax = 5.5;               // 上限钳位电压 (V)
    parameter Vmin = -0.6;              // 下限钳位电压 (V)
    parameter rs  = 1m;                 // 钳位电阻 (Ω)
    parameter output_max_current = 1e-3; // 最大正向输出电流 (A)，用于上限钳位
    parameter output_min_current = -1e-3; // 最小输出电流 (A)，用于下限钳位，应为负值

    real raw_current, limited_current;
  
    analog begin
        // 上限钳位 (电压高于 Vmax)
        if (V(Y, VSS) - Vmax > 0) begin
            raw_current = (V(Y, VSS) - Vmax) / rs;
            // 限制最大电流
            limited_current = (raw_current > output_max_current) ? output_max_current : raw_current;
            I(Y, VSS) <+ limited_current;
        end
        // 下限钳位 (电压低于 Vmin)
        else if (V(Y, VSS) - Vmin < 0) begin
            raw_current = (V(Y, VSS) - Vmin) / rs;   // 此值为负
            // 限制最小电流 (更负)
            limited_current = (raw_current < output_min_current) ? output_min_current : raw_current;
            I(Y, VSS) <+ limited_current;
        end
        // 正常范围内不贡献电流 (等效为高阻)
    end
endmodule
