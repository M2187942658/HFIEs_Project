import os
import obspy
from numpy.polynomial import polynomial as P

def process_function(dir, saveDir):
    dir = sanitize_path(dir)
    saveDir = sanitize_path(saveDir)
    list = os.listdir(dir)
    for i in list:
        path = os.path.join(dir, i)
        print(path)
        print("----------------------------------------Demean----------------------------------------")
        st = obspy.core.read(path)
        print(f"Channel 1 mean value before demean:{st[0].data.mean()}")
        print(f"Channel 2 mean value before demean:{st[1].data.mean()}")
        print(f"Channel 3 mean value before demean:{st[2].data.mean()}")
        # Perform mean centering|进行去均值
        st[0].detrend("demean")
        st[1].detrend("demean")
        st[2].detrend("demean")
        print(f"Channel 1 mean value after demean:{st[0].data.mean()}")
        print(f"Channel 2 mean value after demean:{st[1].data.mean()}")
        print(f"Channel 3 mean value after demean:{st[2].data.mean()}")
        print("----------------------------------------Linear----------------------------------------")
        slope_before1 = P.polyfit(st[0].times(), st[0].data, deg=1)[1]
        slope_before2 = P.polyfit(st[1].times(), st[1].data, deg=1)[1]
        slope_before3 = P.polyfit(st[2].times(), st[2].data, deg=1)[1]
        print(f"Channel 1 slpoe before linear detrend:{slope_before1}")
        print(f"Channel 2 slpoe before linear detrend:{slope_before2}")
        print(f"Channel 3 slpoe before linear detrend:{slope_before3}")
        # Perform detrending|进行去线性趋势
        st[0].detrend("linear")
        st[1].detrend("linear")
        st[2].detrend("linear")
        slope_after1 = P.polyfit(st[0].times(), st[0].data, deg=1)[1]
        slope_after2 = P.polyfit(st[1].times(), st[1].data, deg=1)[1]
        slope_after3 = P.polyfit(st[2].times(), st[2].data, deg=1)[1]
        print(f"Channel 1 slpoe after linear detrend:{slope_after1}")
        print(f"Channel 2 slpoe after linear detrend:{slope_after2}")
        print(f"Channel 3 slpoe after linear detrend:{slope_after3}")
        print("----------------------------------------Taper----------------------------------------")
        # Implement a taper|进行波形尖灭
        st[0].taper(max_percentage=0.05, type="hann")
        print("Channel 1")
        st[1].taper(max_percentage=0.05, type="hann")
        print("Channel 2")
        st[2].taper(max_percentage=0.05, type="hann")
        print("Channel 3")
        print("----------------------------------------BandPass----------------------------------------")
        # 4th-order Butterworth band-pass filter|四阶Butterworth带通滤波器
        st.filter(
        "bandpass",
        freqmin=2,
        freqmax=20,
        corners=4,
        zerophase=True
        )
        st.write(
            os.path.join(saveDir, i)
        )
        print("----------------------------------------DONE----------------------------------------")

import re
from pathlib import Path

def sanitize_path(raw_path: str | Path) -> Path:
    """
    Clean and normalize the input path:
    1. Support Path objects or strings.
    2. Remove leading/trailing whitespace and extraneous quotes (") or ') carried over from copying. 
    3. Fix characters that were escaped due to the absence of an `r""` prefix (e.g., `\\t` becoming a tab, `\\n` becoming a newline). 
    4. Convert to a standard Path object. 
    清洗并规范化输入路径：
    1. 支持 Path 对象或字符串。
    2. 去除首尾空白及复制带入的多余引号（" 或 '）。
    3. 修复因未加 r"" 导致已被转义的字符（如 \\t 变成制表符，\\n 变成换行）。
    4. 统一转为标准 Path 对象。
    """
    if isinstance(raw_path, Path):
        return raw_path.resolve()

    if not isinstance(raw_path, str):
        raise TypeError(f"The path must be a string or a Path object; received: {type(raw_path)}")
    
    # 1. Strip leading/trailing whitespace and extra quotation marks (common on Windows: the "Copy as path" feature automatically includes double quotes).
    # 1. 剥离前后空白和多余引号（Windows 常见：用户“复制为路径”会自带双引号）
    clean_str = raw_path.strip().strip("'\"")
    # 2. Fix cases where escape sequences (e.g., \t, \n, \r) were corrupted due to the omission of the 'r' prefix
    # Tabs or newlines do not typically appear in valid file paths; if encountered, restore them to their backslash-escaped form.
    # 2. 补救未加 r 前缀导致转义字符被破坏的情况（如 \t, \n, \r 等）
    # 路径中通常不可能合法存在制表符或换行符，遇到时将其还原为反斜杠形式
    escape_fixes = {
        '\t': r'\t',
        '\n': r'\n',
        '\r': r'\r',
        '\b': r'\b',
        '\f': r'\f',
        '\a': r'\a',
        '\v': r'\v',
    }
    for char, replacement in escape_fixes.items():
        if char in clean_str:
            clean_str = clean_str.replace(char, replacement)

    # 3. Canonicalization: Convert to absolute paths and resolve symbolic links.
    # 3. 统一规范化：转为绝对路径并解析符号链接
    return Path(clean_str).resolve() 
    
if __name__ == "__main__":
    process_function("D:\Seismic_ShaleGas_DDATA\D\DATA", "D:\Seismic_ShaleGas_DDATA\D\test")