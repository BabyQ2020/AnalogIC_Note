% Buck, Peck Current Mode 
% update time: 2025-10-12
clear
clc

% 绘制波特图设置
s = tf('s'); 
op = bodeoptions;
op.FreqUnits = 'Hz';
% op.PhaseWrapping = 'on';
op.XLim={[1 1e8]};         %设置横轴范围
op.XLabel.FontSize =12;     %设置横轴标签大小
op.YLabel.FontSize =12;     %设置纵轴标签大小
op.Title.FontSize =12;      %设置标题大小

% 参数扫描设置，k可以替换为任意需要设置的参数，例如VIN， VO，IL等
k = 1; 
n = length(k);

for i=1:n
    % 输入输出参数
    VIN = 10;
    VO = 5;
    IO = 2; 
    
    % 功率级器件参数
    L_bk = 10e-6;   %10uH
    C_O = 2.2e-6;    % 2.2uF
    R_ESR = 10e-3;  %10m ohm
    R_O = VO/IO;
    Ri = 0.2; %Ri=1/gmps=1/5=0.2
    
    % 内部 环路控制参数
    fsw = 1000e3; % 开关频率
    fcross = 100e3;  % 穿越频率
    Vse = 0.25; % 斜波补偿峰值
    
    % 功率级 零极点计算   
    wz_out = 1/(R_ESR*C_O);
    wp_out = 1/((R_ESR+R_O)*C_O);

    % 补偿级传递函数 设计过程
    wc = 2*pi*fcross;
    wp0 = wc*Ri/R_O;
    % wz_EA = 0.5*wc; % 一般可设置为穿越频率的1/10
    wz_EA = wp_out;
    wp_EA = wz_out;
    
    % 补偿级传递函数
    Gvc_num = (-wp0/s)*(1+s/wz_EA);
    Gvc_den = (1+s/wp_EA);
    Gvc = Gvc_num/Gvc_den;

    % 等效电流内环
    Gci = (1/Ri)*(1/(1+s*(Vse*fsw*L_bk+(0.5*VIN-VO)*Ri)/(VIN*Ri*fsw)));
    % Gci = (1/Ri);

    % 功率级等效阻抗 
    zo_num = (1 + s*R_ESR*C_O)*R_O; 
    zo_den = 1 + s*(R_ESR+R_O)*C_O;
    zo = zo_num/zo_den;

    % 环路增益
    Hs = Gvc*Gci*zo;
    margin(Hs,op)

    set(findall(gcf,'type','line'),'linewidth',1); % 设置线宽为1
    hold on
end

% 理想的 环路传输函数
HS2 = wc/s;
bode(HS2,op,'r--')

legend("k="+string(k),'linewidth',1) %显示图例
grid on



%具体参数计算
%设置 反馈电阻值
R_FBT = 100e3;
R_FBB = 100e3;

% 计算补偿级参数
Gm_EA = 50e-6;
C_COMP = R_FBB/(R_FBT+R_FBB)*Gm_EA*(R_O/Ri)/wc;
R_COMP = 1/(C_COMP*wz_EA);
C_HF = 1/(R_COMP*wp_EA);

% 输出补偿级 参数
fprintf("Gvc Parameters:\n")
fprintf(' R_FBT  = %.2fk\n',R_FBT*1e-3)
fprintf(' R_FBB  = %.2fk\n',R_FBB*1e-3)
fprintf(' R_COMP = %.2fk\n',R_COMP*1e-3)
fprintf(' C_COMP = %.1fp\n',C_COMP*1e12)
fprintf(' C_HF   = %.1fp\n',C_HF*1e12)


