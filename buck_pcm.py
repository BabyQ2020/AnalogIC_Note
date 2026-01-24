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
    phase_deg = (phase_deg + 180)           # 相位包裹到 [-180°, +180°]
    
    ax_mag.semilogx(freq, mag_db, label=label, color=color, ls=ls, lw=lw)
    ax_ph.semilogx(freq, phase_deg, label=label, color=color, ls=ls, lw=lw)

def plot_x(ax_mag, ax_ph, fcross_target):
    """
    设置 x 轴 竖线穿越频率标记
    """
    ax_mag.axvline(fcross_target, color='red', ls='--', lw=1.2,
                   label=f"Target fcross = {fcross_target/1e3:.0f} kHz")
    ax_ph.axvline(fcross_target, color='red', ls='--', lw=1.2)


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
# 主逻辑：扫描输入电压 VIN
# ────────────────────────────────────────────────
vin_list = [10, 15, 25, 35, 45]           # input voltages to sweep (V)


# ────────────────────────────────────────────────
# 固定参数：功率级参数，内部必要的设计参数，反馈电阻参数
# ────────────────────────────────────────────────
VO   = 5                      # output voltage (V)
IO   = 2                      # output current (A)

L_bk    = 10e-6               # buck inductor (H)
C_O     = 2.2e-6              # output capacitor (F)
R_ESR   = 10e-3               # capacitor ESR (Ω)
R_O  = VO / IO                # load resistance (Ω)

VREF = 2.5                    # Voltage Reference Voltage (V)
R_FBB   = 100e3               # feedback resistor bottom (Ω)
# R_FBT   = 100e3               # feedback resistor top (Ω)
R_FBT   = (VO/VREF - 1)*R_FBB # feedback resistor top (Ω)

fsw     = 1000e3              # switching frequency (Hz)
fcross  = 0.1*fsw               # target crossover frequency (Hz)

Gm_EA   = 50e-6               # error amplifier transconductance (S)
Ri      = 0.2                 # current sense gain inverse (Ri = 1/gmps)
Vse     = 0.25                # slope compensation peak voltage (V)


# ────────────────────────────────────────────────
# 绘图相关参数：创建绘图句柄，绘图范围
# ────────────────────────────────────────────────
fig, (ax_mag, ax_ph) = plt.subplots(2, 1, figsize=(10, 8), sharex=True)
omega = np.logspace(0, 8, 2000)   # frequency vector for Bode plot (rad/s)

# ────────────────────────────────────────────────
# 主循环
# ────────────────────────────────────────────────
for vin in vin_list:
    VIN = vin                 # input voltage (V) - 当前扫描值
    
    # 功率级零极点（依赖于 ESR 和负载）
    wz_out = 1 / (R_ESR * C_O)                      # output ESR zero
    wp_out = 1 / ((R_ESR + R_O) * C_O)              # output filter pole
    
    # 补偿器设计
    wc     = 2 * np.pi * fcross                     # crossover angular frequency
    wp0    = wc * Ri / R_O                          # low-frequency pole of compensator
    wz_EA  = wp_out                                 # compensator zero (cancel output pole)
    wp_EA  = wz_out                                 # compensator pole (cancel ESR zero)
    
    s = tf('s')
    Gvc = (-wp0 / s) * (1 + s / wz_EA) / (1 + s / wp_EA)   # Type-II compensator
    
    # 等效电流内环传递函数（包含斜坡补偿）
    Gci = (1 / Ri) * (1 / (1 + s * (Vse * fsw * L_bk + (0.5*VIN - VO)*Ri) / (VIN * Ri * fsw)))
    
    # 输出阻抗（功率级）
    zo = (1 + s * R_ESR * C_O) * R_O / (1 + s * (R_ESR + R_O) * C_O)
    
    # 总开环增益
    Hs = Gvc * Gci * zo
    
    # 计算增益裕度与相位裕度
    gm, pm, wg, wp_freq = margin(Hs)
    f_actual = wp_freq / (2 * np.pi) if wp_freq is not None else None
    
    print(f"VIN = {VIN:2d} V | GM: {gm:6.2f} dB  PM: {pm+180:5.1f}°  @ {f_actual:.2e} Hz")
    
    # 绘制当前 VIN 的曲线
    bode_single(ax_mag, ax_ph, Hs, 
                label=f'VIN={VIN}V', 
                color=plt.cm.tab10(len(vin_list) - vin_list.index(vin)),
                omega=omega)
    
# ────────────────────────────────────────────────
# 循环结束后统一设置图表样式
# ────────────────────────────────────────────────

# 绘制 目标穿越频率所对应的竖线
plot_x(ax_mag, ax_ph,fcross)

# 设置图标样式
plot_bode(ax_mag, ax_ph,          
          xlim=(1, 1e7),                # x轴范围
          mag_ylim=(-40, 110),          # 幅度 y轴自动
          phase_ylim=(-200, 10),
          mag_yticks=[-20, 0, 20, 40, 60, 80, 100],
          phase_yticks=[-180, -135, -90, -45, 0, 45, 90])        # 相位 y轴范围

plt.show()

# ────────────────────────────────────────────────
# 补偿网络元件计算（以最后一次循环的值为例）
# ────────────────────────────────────────────────
C_COMP = R_FBB / (R_FBT + R_FBB) * Gm_EA * (R_O / Ri) / wc
R_COMP = 1 / (C_COMP * wz_EA)
C_HF   = 1 / (R_COMP * wp_EA)

print("\nCompensation Parameters (last VIN case):")
print(f" R_FBB = {R_FBB*1e-3:.2f} kΩ")
print(f" R_FBT = {R_FBT*1e-3:.1f} kΩ")
print(f" R_COMP = {R_COMP*1e-3:.2f} kΩ")
print(f" C_COMP = {C_COMP*1e12:.1f} pF")
print(f" C_HF   = {C_HF*1e12:.1f} pF")
