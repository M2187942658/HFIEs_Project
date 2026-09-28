%{
fea: Feature extraction function
    INPUT:
        ps_path: File path for P- and S-wave arrival time data. 
        dpath: Directory path containing waveform data. 
        class: Type label representing the earthquake type (specified as an integer). 
    OUTPUT:
        fea_result: Feature extraction results. 

    This script implements a feature extraction function designed to demonstrate the extraction process;
the underlying calculations align with the formulas used during the research period. The `class`
input is determined by the user: when inputting P- and S-wave arrival time data for TEs, set this
parameter to the corresponding type label; similarly, when inputting data for HFIEs, set it to the
appropriate label. Ensure that the labels for TEs and HFIEs are distinct. For example, in the
original research, 1 was used as the label for TEs, and 4 was used for HFIEs.

fea：特征值提取函数
    INPUT：
        ps_path：P、S波到时数据地址。
        dpath：波形数据存放文件夹地址。
        class：类型标签，用于表示地震类型，规定为整数int。
    OUTPUT:
        fea_result：特征提取结果。

    该函数为特征值提取函数，该脚本旨在演示特征提取功能，其计算部分与研究期间
所用计算式一致。输入项class由用户决定，当输入TEs的P、S波到时数据，请将该项设为
你预期的类型标签；当输入HFIEs的P、S波到时数据，请将该项设为你预期的类型标签，
TEs与HFIEs的类型标签请确保互异。例如，在研究期间，1作为TEs的标签，4作为HFIEs
的标签。

Email：meijiamu26@mails.ucas.ac.cn

%}


function fea_result = fea(ps_path, dpath, class)

data = load(ps_path);
fieldname = fieldnames(data);
ps = getfield(data, fieldname{1});

filename = ps.fname;
PINDEX = ps.p_index;
SINDEX = ps.s_index;
DAY2SECOND = 86400; % Used for time conversion|用于时间转换

fea_result = table('Size', [numel(filename), 32], 'VariableTypes', ...
    {'string', 'double', 'double', 'double', ...
    'double', 'double', 'double', 'double', ...
    'double', 'double', 'double', 'double', ...
    'double', 'double', 'double', 'double', ...
    'double', 'double', 'double', 'double', ...
    'double', 'double', 'double', 'double', ...
    'double', 'double', 'double', 'double', ...
    'double', 'double', 'double', 'double'}, ...
    'VariableNames', ...
    {'fname', 'T_sp', 'R_E', 'D_5_95', ...
    'CFE_S_H', 'SEE_S_H', 'R_A', 'CFE_P', ...
    'SEE_P', 'CFE_S_E', 'CFE_S_N', 'DF_S_H', ...
    'DF_P', 'SEA_S_H', 'SEA_P', 'SEE_S_E', ...
    'SEE_S_N', 'Peak_S','RMS_S', 'Peak_P', ...
    'RMS_P', 'CFA_S_H', 'CFA_P', 'DF_S_E', ...
    'DF_S_N', 'SEA_S_E', 'SEA_S_N','CFA_S_E', ...
    'CFA_S_N', 'Kurt_S', 'Kurt_P', 'Classification'} ...
    );

for i = 1:numel(filename)
    filepath = fullfile(dpath, filename(i));
    wave = rdmseed(char(filepath), 'simple');
    [INFO, ~] = rdmseed(char(filepath));
    sample_rate = INFO(1).SampleRate;
    for j = 1:3
        switch wave(j).name(end)
            case "E"
                E = wave(j).d;
            case "N"
                N = wave(j).d;
            case "Z"
                Z = wave(j).d;
        end
    end
    L = min([numel(E), numel(N), numel(Z)]);
    timeArray = wave(1).t(1:L);
    H = hypot(E(1:L), N(1:L));
    E = E(1:L);
    N = N(1:L);
    Z = Z(1:L);
    pindex = PINDEX(i);
    sindex = SINDEX(i);
    pt = wave(1).t(pindex);
    st = wave(1).t(sindex);
    st_ = st + 3 / DAY2SECOND;
    pt_ = pt + 2 / DAY2SECOND;
    sindex_end = find(wave(1).t >= st_, 1, 'first');
    pindex_end = find(wave(1).t >= pt_, 1, 'first');

    %  S-P Travel Time Difference|P-S时间差
    T_sp = (st - pt) * DAY2SECOND;

    if T_sp >= 2
        P = Z(pindex:pindex_end);
    else
        P = Z(pindex:sindex-1);
    end
    S_H = H(sindex:sindex_end);
    S_E = E(sindex:sindex_end);
    S_N = N(sindex:sindex_end);
    S_tarray = timeArray(sindex:sindex_end);

    % Maximum P-wave amplitude|P波最大振幅
    A_P = max(abs(P));
    % Maximum amplitude of S-waves|S波最大振幅
    A_S = max(S_H); % H
    % S-to-P Amplitude Ratio|P、S波振幅比
    R_A = A_S / A_P;
    % P-wave energy|P波能量
    E_P = sum(P.^2);
    % S-wave energy|S波能量
    E_S = sum(S_H.^2); % H
    % S-to-P Energy Ratio|P、S波能量比
    R_E = E_S / E_P;
    % Root Mean Square Amplitude of P|P波RMS
    RMS_P = rms(P);
    % Peak Amplitude of P|P波峰值振幅
    Peak_P = max(abs(P));
    % Mean P-wave value|P波均值
    mu_P = mean(P);
    % Standard deviation of P-wave|P波标准差
    sigma_P = mean((P - mu_P).^2)^0.5;
    % Kurtosis of P|P波峰度
    if sigma_P > 0
        Kurt_P = mean((P - mu_P).^4) / sigma_P^4;
    else
        Kurt_P = 0;
    end

    % --- Extraction of P-wave spectral entropy|P波谱熵提取 ---
    len_P = length(P);
    % To perform spectral analysis, the mean is removed again.
    % 为了做频谱分析，再次进行去均值
    % Introduce the Hamming window to address the problem of spectral leakage.
    p_fft = (P - mean(P)) .* hamming(len_P);
    p = fft(p_fft);
    A_p = abs(p);
    % Here, it is important to note the distinction between the mathematical concepts of [] and [).
    % 这里需注意数学概念[]与[)的区别
    halfLen_P = floor(len_P / 2) + 1;
    A_p = A_p(1:halfLen_P);
    f_P = (0:halfLen_P-1) .* sample_rate ./ len_P;
    f_P = f_P';
    % Amplitude-Weighted Central Frequency of P|P波振幅加权中心频率
    CFA_P = sum(f_P .* A_p) / sum(A_p);
    % Energy-weighted Centroid Frequency of P|P波功率加权中心频率
    CFE_P = sum(f_P .* A_p.^2) ./ sum(A_p.^2);
    % Dominant Frequency of P|P波主频
    [~,idx] = max(A_p);
    DF_P = f_P(idx);
    % Pi (Amplitude)|Pi(振幅)
    Pi_A = A_p ./ sum(A_p);
    % Spectral Entropy based on Amplitude of P|P波振幅谱熵
    SEA_P = -sum(Pi_A(Pi_A>0) .* log(Pi_A(Pi_A>0)));
    % Pi (Energy)|Pi(功率)
    Pi_E = A_p.^2 ./ sum(A_p.^2);
    % Spectral Energy Entropy of P|P波功率谱熵
    SEE_P = -sum(Pi_E(Pi_E>0) .* log(Pi_E(Pi_E>0)));


    len_S = length(S_H);
    halfLen_S = floor(len_S / 2) + 1;
    f_S = (0:halfLen_S-1) .* sample_rate ./ len_S;
    f_S = f_S';
    % --- S-spectrum entropy extraction (E)|S波谱熵提取(E) ---

    s_e_fft = (S_E - mean(S_E)) .* hamming(len_S);
    s_e = fft(s_e_fft);
    A_s_e = abs(s_e);
    A_s_e = A_s_e(1:halfLen_S);
    % Amplitude-Weighted Central Frequency of S|S波振幅加权中心频率
    CFA_S_E = sum(f_S .* A_s_e) / sum(A_s_e);
    % Energy-weighted Centroid Frequency of S|S波功率加权中心频率
    CFE_S_E = sum(f_S .* A_s_e.^2) ./ sum(A_s_e.^2);
    % Dominant Frequency of S|S波中频
    [~,idx] = max(A_s_e);
    DF_S_E = f_S(idx);
    % Si (amplitude)|Si(振幅)
    Si_A_E = A_s_e ./ sum(A_s_e);
    % Spectral Entropy based on Amplitude of S|S波振幅谱熵
    SEA_S_E = -sum(Si_A_E(Si_A_E>0) .* log(Si_A_E(Si_A_E>0)));
    % Si (Energy)|Si(功率)
    Si_E_E = A_s_e.^2 ./ sum(A_s_e.^2);
    % Spectral Energy Entropy of S|S波功率谱熵
    SEE_S_E = -sum(Si_E_E(Si_E_E>0) .* log(Si_E_E(Si_E_E>0)));

    % --- S-spectrum entropy extraction (N)|S波谱熵提取(N) ---

    s_n_fft = (S_N - mean(S_N)) .* hamming(len_S);
    s_n = fft(s_n_fft);
    A_s_n = abs(s_n);
    A_s_n = A_s_n(1:halfLen_S);
    % Amplitude-Weighted Central Frequency of S|S波振幅加权中心频率
    CFA_S_N = sum(f_S .* A_s_n) / sum(A_s_n);
    % Energy-weighted Centroid Frequency of S|S波功率加权中心频率
    CFE_S_N = sum(f_S .* A_s_n.^2) ./ sum(A_s_n.^2);
    % Dominant Frequency of S|S波中频
    [~,idx] = max(A_s_n);
    DF_S_N = f_S(idx);
    % Si (amplitude)|Si(振幅)
    Si_A_N = A_s_n ./ sum(A_s_n);
    % Spectral Entropy based on Amplitude of S|S波振幅谱熵
    SEA_S_N = -sum(Si_A_N(Si_A_N>0) .* log(Si_A_N(Si_A_N>0)));
    % Si (Energy)|Si(功率)
    Si_E_N = A_s_n.^2 ./ sum(A_s_n.^2);
    % Spectral Energy Entropy of S|S波功率谱熵
    SEE_S_N = -sum(Si_E_N(Si_E_N>0) .* log(Si_E_N(Si_E_N>0)));

    % --- S-spectrum entropy extraction (H)|S波谱熵提取(H) ---

    A_s_h = sqrt(A_s_e.^2 + A_s_n.^2);
    % Amplitude-Weighted Central Frequency of S|S波振幅加权中心频率
    CFA_S_H = sum(f_S .* A_s_h) / sum(A_s_h);
    % Energy-weighted Centroid Frequency of S|S波功率加权中心频率
    CFE_S_H = sum(f_S .* A_s_h.^2) ./ sum(A_s_h.^2);
    % Dominant Frequency of S|S波中频
    [~,idx] = max(A_s_h);
    DF_S_H = f_S(idx);
    % Si (amplitude)|Si(振幅)
    Si_A_H = A_s_h ./ sum(A_s_h);
    % Spectral Entropy based on Amplitude of S|S波振幅谱熵
    SEA_S_H = -sum(Si_A_H(Si_A_H>0) .* log(Si_A_H(Si_A_H>0)));
    % Si (Energy)|Si(功率)
    Si_E_H = A_s_h.^2 ./ sum(A_s_h.^2);
    % Spectral Energy Entropy of S|S波功率谱熵
    SEE_S_H = -sum(Si_E_H(Si_E_H>0) .* log(Si_E_H(Si_E_H>0)));

    % Root Mean Square Amplitude of S|S波RMS
    RMS_S = rms(S_H); % H
    % Peak Amplitude of S|S波峰值振幅
    Peak_S = max(S_H); % H
    % Mean S-wave value|S波均值
    mu_S = mean(S_H); % H
    % Standard deviation of the S-wave|S波标准差
    sigma_S = mean((S_H - mu_S).^2)^0.5; % H
    % Kurtosis of S|S波峰度
    if sigma_S > 0
        Kurt_S = mean((S_H - mu_S).^4) / sigma_S^4;
    else
        Kurt_S = 0;
    end

    % Effective Duration|S波D_5_95
    Ds_5_95 = cal_D_5_95(S_H, S_tarray);

    fea_result.fname(i) = filename(i);
    fea_result.T_sp(i) = T_sp;
    fea_result.R_A(i) = R_A;
    fea_result.R_E(i) = R_E;
    fea_result.RMS_P(i) = RMS_P;
    fea_result.Peak_P(i) = Peak_P;
    fea_result.Kurt_P(i) = Kurt_P;
    fea_result.SEA_P(i) = SEA_P;
    fea_result.SEE_P(i) = SEE_P;
    fea_result.RMS_S(i) = RMS_S;
    fea_result.Peak_S(i) = Peak_S;
    fea_result.Kurt_S(i) = Kurt_S;
    fea_result.SEA_S_H(i) = SEA_S_H;
    fea_result.SEA_S_E(i) = SEA_S_E;
    fea_result.SEA_S_N(i) = SEA_S_N;
    fea_result.SEE_S_H(i) = SEE_S_H;
    fea_result.SEE_S_E(i) = SEE_S_E;
    fea_result.SEE_S_N(i) = SEE_S_N;
    fea_result.CFA_P(i) = CFA_P;
    fea_result.CFA_S_H(i) = CFA_S_H;
    fea_result.CFA_S_E(i) = CFA_S_E;
    fea_result.CFA_S_N(i) = CFA_S_N;
    fea_result.CFE_P(i) = CFE_P;
    fea_result.CFE_S_H(i) = CFE_S_H;
    fea_result.CFE_S_E(i) = CFE_S_E;
    fea_result.CFE_S_N(i) = CFE_S_N;
    fea_result.D_5_95(i) = Ds_5_95;
    fea_result.Classification(i) = class;
    fea_result.DF_P(i) = DF_P;
    fea_result.DF_S_H(i) = DF_S_H;
    fea_result.DF_S_E(i) = DF_S_E;
    fea_result.DF_S_N(i) = DF_S_N;
end

end

% Function for calculating Effective Duration|有效持续时长计算函数
function D_5_95 = cal_D_5_95(wave, tarray)
DAY2SECOND = 86400;

e = wave .^2 ;
C = cumsum(e);
R = C ./ C(end);

idx5 = find(R >= 0.05, 1, 'first');
idx95 = find(R >= 0.95, 1, 'first');

D_5_95 = (tarray(idx95) - tarray(idx5)) * DAY2SECOND;
end