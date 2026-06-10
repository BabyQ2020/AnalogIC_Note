### BUCK,Peak Current Mode, 根据基础设计参数，绘制波特图 ####

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.ticker as ticker
from control import tf, bode, margin

def bode_single(ax_mag, ax_ph, Hs, label=None, color='C0', ls='-', lw=1.0, omega=None):
    """绘制单条 Bode 曲线（幅度 + 相位）"""
    if omega is None:
        omega = np.logspace(0, 8, 2000)      # 默认频率范围：1 Hz ~ 100 MHz,计算2000个点
    mag, phase, _ = bode(Hs, omega=omega, plot=False)
    freq = omega / (2 * np.pi)
    mag_db = 20 * np.log10(mag)
    phase_deg = np.degrees(phase)
    phase_deg = (phase_deg+360)%180-180           # 相位包裹到 [-180°, +180°]
    
    ax_mag.semilogx(freq, mag_db, label=label, color=color, ls=ls, lw=lw)
    ax_ph.semilogx(freq, phase_deg, label=label, color=color, ls=ls, lw=lw)

def plot_x(ax_mag, ax_ph, freq, freq_str):
    """
    设置 x 轴 竖线穿越频率标记
    """
    ax_mag.axvline(freq, color='red', ls='--', lw=1.2,
                   label= freq_str + f"= {freq/1e3:.1f} kHz")
    ax_ph.axvline(freq, color='red', ls='--', lw=1.2)

def plot_bode(ax_mag, ax_ph, xlim=(1, 1e8), mag_ylim=None, phase_ylim=(-270, 90), mag_yticks=None, phase_yticks=None):
    """
    设置 Bode 图公共元素：网格、坐标轴范围
    """  
    # 对数网格（主 + 次）
    for ax in (ax_mag, ax_ph):
        ax.grid(True, which='major', ls='-', lw=1.0, alpha=0.8, color='gray')
        ax.minorticks_on()
        ax.xaxis.set_minor_locator(ticker.LogLocator(base=10, subs=np.arange(2,10)))
        ax.grid(which='minor', ls=':', lw=0.6, alpha=0.7, color='gray')
    
    # 设置x坐标轴范围
    ax_mag.set_xlim(xlim)
    ax_ph.set_xlim(xlim)

    # 设置y坐标轴范围
    if mag_ylim is not None:
        ax_mag.set_ylim(mag_ylim)
    if phase_ylim is not None:
        ax_ph.set_ylim(phase_ylim)

    # 自定义 y 轴主刻度
    if mag_yticks is not None:
        ax_mag.set_yticks(mag_yticks)
    if phase_yticks is not None:
        ax_ph.set_yticks(phase_yticks)

    # 图表标题与标签
    ax_mag.set_title('Bode Plot - Magnitude and Phase (VIN sweep)')
    ax_mag.set_ylabel('Magnitude [dB]')
    ax_mag.legend(loc='best', fontsize=9)
    
    ax_ph.set_ylabel('Phase [deg]')
    ax_ph.set_xlabel('Frequency [Hz]')
    ax_ph.legend(loc='best', fontsize=9)

    plt.tight_layout()
    plt.subplots_adjust(hspace=0.1)


# ────────────────────────────────────────────────
# 主逻辑：功率级参数，内部必要的设计参数
# ────────────────────────────────────────────────
VIN = 24     # input voltages to sweep (V)
VO = 5                          # output voltage (V)
# IO = 2                          # output current (A)
A_list = [0.1, 1, 2, 2.5]         # output current (A)

# power stage
L_BK    = 6.8e-6                 # buck inductor (H)
R_ESR   = 10e-3                 # capacitor ESR (Ω)
C_O     = 22e-6                # output capacitor (F)

# Error amplifier
VREF = 1.0                  # Voltage Reference Voltage (V)
GM   = 100e-6                 # error amplifier transconductance (S)
RI   = 1/5                # current sense gain inverse (RI = 1/gmps)
VSE  = 0.5                  # slope compensation peak voltage (V)

# Type II compensation
R_COMP = 138.23e3 # compnsation Res
C_COMP = 399.5e-12 # compensation cap
C_HF = 1.6e-12 # compensation cap

# switch fsw
fsw = 1000e3                # switching frequency (Hz)

# ────────────────────────────────────────────────
# 绘图相关参数：创建绘图句柄，绘图计算范围
# ────────────────────────────────────────────────
fig, (ax_mag, ax_ph) = plt.subplots(2, 1, figsize=(10, 8), sharex=True)
omega = np.logspace(0, 8, 2000)   # frequency vector for Bode plot (rad/s)

# ────────────────────────────────────────────────
# 主循环
# ────────────────────────────────────────────────
for i in A_list:

    IO = i
    R_O     = VO / IO               # load resistance (Ω)

    K = (R_O*VREF*GM)/(RI*VO*C_COMP) # 系数K

    fz_out = 1 / (2*np.pi*R_ESR * C_O)             # output ESR zero
    fp_out = 1 / (2*np.pi*(R_ESR + R_O) * C_O)     # output filter pole

    fz_EA = 1/(2*np.pi*R_COMP*C_COMP) # 补偿级产生的零点，与输出极点 fp_out 抵消
    fp_EA = 1/(2*np.pi*R_COMP*C_HF) # 补偿级产生的极点，与输出esr零点 fz_out 抵消

    fp_ci = (VIN*RI*fsw)/(2*np.pi*(VSE*fsw*L_BK+(0.5*VIN-VO)*RI)) # 内部电流环引入的高频极点

    fcross  = (VREF*GM*R_COMP)/(2*np.pi*VO*RI*C_O)    #crossover frequency (Hz)

    # 创建 s 域符号
    s = tf('s')

    # 开环传输函数 表达式
    Hs = K*((1+s/(2*np.pi*fz_EA))*(1+s/(2*np.pi*fz_out)))/(s*(1+s/(2*np.pi*fp_EA))*(1+s/(2*np.pi*fp_ci))*(1+s/(2*np.pi*fp_out)))
    
    # 计算增益裕度与相位裕度
    gm, pm, wg, wp_freq = margin(Hs)
    f_actual = wp_freq / (2 * np.pi) if wp_freq is not None else None
    
    print(f"i = {i:.2f} | GM: {gm:6.2f} dB  PM: {pm:5.1f}°  @ {f_actual:.2e} Hz")
    
    # 绘制当前 参数的曲线
    bode_single(ax_mag, ax_ph, Hs, 
                label=f'i={i}', 
                color=plt.cm.tab10(len(A_list) - A_list.index(i)),
                omega=omega)
    
    
# ────────────────────────────────────────────────
# 循环结束后统一设置图表样式
# ────────────────────────────────────────────────

# 绘制 目标穿越频率所对应的竖线
# plot_x(ax_mag, ax_ph,fp_out,'fp_out')

# # 绘制 目标穿越频率所对应的竖线
# plot_x(ax_mag, ax_ph,fz_EA,'fz_EA')

# # 绘制 目标穿越频率所对应的竖线
# plot_x(ax_mag, ax_ph,fcross,'fcross')

# # 绘制 目标穿越频率所对应的竖线
# plot_x(ax_mag, ax_ph,fz_out,'fz_out')

# # 绘制 目标穿越频率所对应的竖线
# plot_x(ax_mag, ax_ph,fp_EA,'fp_EA')

# # 绘制 目标穿越频率所对应的竖线
# plot_x(ax_mag, ax_ph,fp_ci,'fp_ci')


# 设置图标样式
plot_bode(ax_mag, ax_ph,          
          xlim=(1, 1e7),                # x轴范围
          mag_ylim=(-40, 110),          # 幅度 y轴自动
          phase_ylim=(-200, 10),
          mag_yticks=[-20, 0, 20, 40, 60, 80, 100],
          phase_yticks=[-180, -135, -90, -45, 0])        # 相位 y轴范围

plt.show()
