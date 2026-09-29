T = load("D:\Seismic_ShaleGas_DDATA\D\BANDPASS\N_PS.mat");
dirpath = "D:\Seismic_ShaleGas_DDATA\D\BANDPASS\N";


fieldname = fieldnames(T);

ps = getfield(T, fieldname{1});

filename = ps.fname;
PINDEX = ps.p_index;
SINDEX = ps.s_index;
PS_GAP_TIME = ps.ps_gap_time;
DAY2SECOND = 86400;

% 结果表预编译
Result = table('Size', [numel(filename), 32], 'VariableTypes', ...
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

% 开始提取特征值
for i = 1:numel(filename)
    filepath = fullfile(dirpath, filename(i));
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

    % P-S时间差
    T_sp = (st - pt) * DAY2SECOND;

    if T_sp >= 2
        P = Z(pindex:pindex_end);
        P_tarray = timeArray(pindex:pindex_end);
    else
        P = Z(pindex:sindex-1);
        P_tarray = timeArray(pindex:sindex-1);
    end
    S_H = H(sindex:sindex_end);
    S_E = E(sindex:sindex_end);
    S_N = N(sindex:sindex_end);
    S_tarray = timeArray(sindex:sindex_end);

    % P波最大振幅
    A_P = max(abs(P));
    % S波最大振幅
    A_S = max(S_H); % H
    R_A = A_S / A_P;
    % P波能量
    E_P = sum(P.^2);
    % S波能量
    E_S = sum(S_H.^2); % H
    % 能量比
    R_E = E_S / E_P;
    % P波RMS
    RMS_P = rms(P);
    % P波峰值振幅
    Peak_P = max(abs(P));
    % P波均值
    mu_P = mean(P);
    % P波标准差
    sigma_P = mean((P - mu_P).^2)^0.5;
    % P波峰度
    if sigma_P > 0
        Kurt_P = mean((P - mu_P).^4) / sigma_P^4;
    else
        Kurt_P = 0;
    end

    % --- P波谱熵提取 ---
    len_P = length(P);
    % 为了做频谱分析，再次进行去均值
    p_fft = (P - mean(P)) .* hamming(len_P); % 引入Hanmming窗解决频谱泄露问题
    p = fft(p_fft);
    A_p = abs(p);
    halfLen_P = floor(len_P / 2) + 1; % 这里需注意数学概念[]与[)的区别
    A_p = A_p(1:halfLen_P);
    f_P = (0:halfLen_P-1) .* sample_rate ./ len_P;
    f_P = f_P';
    % P波振幅加权中心频率
    CFA_P = sum(f_P .* A_p) / sum(A_p);
    % P波功率加权中心频率
    CFE_P = sum(f_P .* A_p.^2) ./ sum(A_p.^2);
    % P波主频
    [~,idx] = max(A_p);
    DF_P = f_P(idx);
    % Pi(振幅)
    Pi_A = A_p ./ sum(A_p);
    % P波振幅谱熵
    SEA_P = -sum(Pi_A(Pi_A>0) .* log(Pi_A(Pi_A>0)));
    % Pi(功率)
    Pi_E = A_p.^2 ./ sum(A_p.^2);
    % P波功率谱熵
    SEE_P = -sum(Pi_E(Pi_E>0) .* log(Pi_E(Pi_E>0)));


    len_S = length(S_H);
    halfLen_S = floor(len_S / 2) + 1;
    f_S = (0:halfLen_S-1) .* sample_rate ./ len_S;
    f_S = f_S';
    % --- S波谱熵提取(E) ---

    s_e_fft = (S_E - mean(S_E)) .* hamming(len_S);
    s_e = fft(s_e_fft);
    A_s_e = abs(s_e);
    A_s_e = A_s_e(1:halfLen_S);
    % S波振幅加权中心频率
    CFA_S_E = sum(f_S .* A_s_e) / sum(A_s_e);
    % S波功率加权中心频率
    CFE_S_E = sum(f_S .* A_s_e.^2) ./ sum(A_s_e.^2);
    % S波中频
    [~,idx] = max(A_s_e);
    DF_S_E = f_S(idx);
    % Si(振幅)
    Si_A_E = A_s_e ./ sum(A_s_e);
    % S波振幅谱熵
    SEA_S_E = -sum(Si_A_E(Si_A_E>0) .* log(Si_A_E(Si_A_E>0)));
    % Si(功率)
    Si_E_E = A_s_e.^2 ./ sum(A_s_e.^2);
    % S波功率谱熵
    SEE_S_E = -sum(Si_E_E(Si_E_E>0) .* log(Si_E_E(Si_E_E>0)));

    % --- S波谱熵提取(N) ---

    s_n_fft = (S_N - mean(S_N)) .* hamming(len_S);
    s_n = fft(s_n_fft);
    A_s_n = abs(s_n);
    A_s_n = A_s_n(1:halfLen_S);
    % S波振幅加权中心频率
    CFA_S_N = sum(f_S .* A_s_n) / sum(A_s_n);
    % S波功率加权中心频率
    CFE_S_N = sum(f_S .* A_s_n.^2) ./ sum(A_s_n.^2);
    % S波中频
    [~,idx] = max(A_s_n);
    DF_S_N = f_S(idx);
    % Si(振幅)
    Si_A_N = A_s_n ./ sum(A_s_n);
    % S波振幅谱熵
    SEA_S_N = -sum(Si_A_N(Si_A_N>0) .* log(Si_A_N(Si_A_N>0)));
    % Si(功率)
    Si_E_N = A_s_n.^2 ./ sum(A_s_n.^2);
    % S波功率谱熵
    SEE_S_N = -sum(Si_E_N(Si_E_N>0) .* log(Si_E_N(Si_E_N>0)));

    % --- S波谱熵提取(H) ---

    A_s_h = sqrt(A_s_e.^2 + A_s_n.^2);
    % S波振幅加权中心频率
    CFA_S_H = sum(f_S .* A_s_h) / sum(A_s_h);
    % S波功率加权中心频率
    CFE_S_H = sum(f_S .* A_s_h.^2) ./ sum(A_s_h.^2);
    % S波中频
    [~,idx] = max(A_s_h);
    DF_S_H = f_S(idx);
    % Si(振幅)
    Si_A_H = A_s_h ./ sum(A_s_h);
    % S波振幅谱熵
    SEA_S_H = -sum(Si_A_H(Si_A_H>0) .* log(Si_A_H(Si_A_H>0)));
    % Si(功率)
    Si_E_H = A_s_h.^2 ./ sum(A_s_h.^2);
    % S波功率谱熵
    SEE_S_H = -sum(Si_E_H(Si_E_H>0) .* log(Si_E_H(Si_E_H>0)));

    % S波RMS
    RMS_S = rms(S_H); % H
    % S波峰值振幅
    Peak_S = max(S_H); % H
    % S波均值
    mu_S = mean(S_H); % H
    % S波标准差
    sigma_S = mean((S_H - mu_S).^2)^0.5; % H
    % S波峰度
    if sigma_S > 0
        Kurt_S = mean((S_H - mu_S).^4) / sigma_S^4;
    else
        Kurt_S = 0;
    end

    % S波D_5_95
    Ds_5_95 = cal_D_5_95(S_H, S_tarray);

    Result.fname(i) = filename(i);
    Result.T_sp(i) = T_sp;
    Result.R_A(i) = R_A;
    Result.R_E(i) = R_E;
    Result.RMS_P(i) = RMS_P;
    Result.Peak_P(i) = Peak_P;
    Result.Kurt_P(i) = Kurt_P;
    Result.SEA_P(i) = SEA_P;
    Result.SEE_P(i) = SEE_P;
    Result.RMS_S(i) = RMS_S;
    Result.Peak_S(i) = Peak_S;
    Result.Kurt_S(i) = Kurt_S;
    Result.SEA_S_H(i) = SEA_S_H;
    Result.SEA_S_E(i) = SEA_S_E;
    Result.SEA_S_N(i) = SEA_S_N;
    Result.SEE_S_H(i) = SEE_S_H;
    Result.SEE_S_E(i) = SEE_S_E;
    Result.SEE_S_N(i) = SEE_S_N;
    Result.CFA_P(i) = CFA_P;
    Result.CFA_S_H(i) = CFA_S_H;
    Result.CFA_S_E(i) = CFA_S_E;
    Result.CFA_S_N(i) = CFA_S_N;
    Result.CFE_P(i) = CFE_P;
    Result.CFE_S_H(i) = CFE_S_H;
    Result.CFE_S_E(i) = CFE_S_E;
    Result.CFE_S_N(i) = CFE_S_N;
    Result.D_5_95(i) = Ds_5_95;
    Result.Classification(i) = 1; % N:1, S:4
    Result.DF_P(i) = DF_P;
    Result.DF_S_H(i) = DF_S_H;
    Result.DF_S_E(i) = DF_S_E;
    Result.DF_S_N(i) = DF_S_N;
end

function D_5_95 = cal_D_5_95(wave, tarray)
DAY2SECOND = 86400;

e = wave .^2 ;
C = cumsum(e);
R = C ./ C(end);

idx5 = find(R >= 0.05, 1, 'first');
idx95 = find(R >= 0.95, 1, 'first');

D_5_95 = (tarray(idx95) - tarray(idx5)) * DAY2SECOND;
end

N_SPE = Result;
save("D:\Seismic_ShaleGas_DDATA\D\BANDPASS\N_SPE.mat", 'N_SPE', '-mat');
clear