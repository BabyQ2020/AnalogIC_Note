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
# 主逻辑：功率级参数，内部必要的设计参数，反馈电阻参数
# ────────────────────────────────────────────────
# VIN = 24          # input voltages to sweep (V)
A_list = [24,18,12,10]     # input voltages to sweep (V)
VO = 5                          # output voltage (V)
IO = 2                          # output current (A)

L_BK    = 6.8e-6                 # buck inductor (H)
R_ESR   = 10e-3                 # capacitor ESR (Ω)
C_O     = 22e-6                # output capacitor (F)


VREF = 1.0                      # Voltage Reference Voltage (V)
GM   = 100e-6                 # error amplifier transconductance (S)
RI   = 1/5                   # current sense gain inverse (RI = 1/gmps)
VSE  = 0.5                  # slope compensation peak voltage (V)

fsw     = 1000e3                # switching frequency (Hz)
fcross  = 0.1*fsw               # target crossover frequency (Hz)

# ────────────────────────────────────────────────
# 绘图相关参数：创建绘图句柄，绘图计算范围
# ────────────────────────────────────────────────
fig, (ax_mag, ax_ph) = plt.subplots(2, 1, figsize=(10, 8), sharex=True)
omega = np.logspace(0, 8, 2000)   # frequency vector for Bode plot (rad/s)

# ────────────────────────────────────────────────
# 主循环
# ────────────────────────────────────────────────
for i in A_list:
    VIN = i                 # input voltage (V) - 当前扫描值

    R_O = VO / IO               # load resistance (Ω)
    
    # 功率级零极点（依赖于 ESR 和负载）
    wz_out = 1 / (R_ESR * C_O)                      # output ESR zero
    wp_out = 1 / ((R_ESR + R_O) * C_O)              # output filter pole
    
    # 补偿器设计
    wz_EA  = wp_out                                 # compensator zero (cancel output pole)
    wp_EA  = wz_out                                 # compensator pole (cancel ESR zero)
    
    R_COMP = (2*np.pi*VO*RI*C_O*fcross)/(VREF * GM)
    C_COMP = 1/(R_COMP * wz_EA)
    C_HF   = 1 / (R_COMP * wp_EA)


    # s 域符号设置
    s = tf('s')

    # feedback
    Gdiv = VREF/VO

    # Type-II 补偿级传递函数
    Gvc = GM*(1+s*R_COMP*C_COMP)/(C_COMP*s*(1+s*R_COMP*C_HF))  # Type-II compensator
    
    # 等效电流内环传递函数（包含斜坡补偿）
    Gci = (1 / RI) * (1 / (1 + s * (VSE * fsw * L_BK + (0.5*VIN - VO)*RI) / (VIN * RI * fsw)))
    
    # 输出阻抗（功率级）
    Zo = (1 + s * R_ESR * C_O) * R_O / (1 + s * (R_ESR + R_O) * C_O)
    
    # 总开环增益
    Hs = Gdiv * Gvc * Gci * Zo
    
    # 计算增益裕度与相位裕度
    gm, pm, wg, wp_freq = margin(Hs)
    f_actual = wp_freq / (2 * np.pi) if wp_freq is not None else None

    print(f"i = {i:2.2f} | GM: {gm:3.2f} dB  PM: {pm:3.1f}°  @ {f_actual:.2e} Hz")
    print(f"R_COMP = {R_COMP*1e-3:.2f} kΩ | " + f"C_COMP = {C_COMP*1e12:.1f} pF | " + f"C_HF = {C_HF*1e12:.1f} pF")
    
    
    # 绘制当前 VIN 的曲线
    bode_single(ax_mag, ax_ph, Hs, 
                label=f'i={i}', 
                color=plt.cm.tab10(len(A_list) - A_list.index(i)),
                omega=omega)
    

    
# ────────────────────────────────────────────────
# 循环结束后统一设置图表样式
# ────────────────────────────────────────────────

# 绘制 目标穿越频率所对应的竖线
plot_x(ax_mag, ax_ph,fcross,'fcross')

# 设置图标样式
plot_bode(ax_mag, ax_ph,          
          xlim=(1, 1e7),                # x轴范围
          mag_ylim=(-40, 110),          # 幅度 y轴自动
          phase_ylim=(-200, 10),
          mag_yticks=[-20, 0, 20, 40, 60, 80, 100],
          phase_yticks=[-180, -135, -90, -45, 0])        # 相位 y轴范围

plt.show()

