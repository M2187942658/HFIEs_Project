%{
main: 
    Main program for the demonstration of the project distinguishing 
earthquakes induced by shale gas hydraulic fracturing.

main：
    页岩气水力压裂诱发地震区分项目演示代码主程序

Email：meijiamu26@mails.ucas.ac.cn
%}

addpath(genpath('./src'))
addpath(genpath('./data'))
addpath(genpath('./temp'))
addpath(genpath('./py'))
FARTHER_PATH = pwd();
XGB_Setting = struct();
XGB_Setting.PYTHON_ENV = ; % Please set up the Python environment. | 请设定Python环境
XGB_Setting.PY_PATH = fullfile(FARTHER_PATH, 'py', 'classifier_xgb_function.py');
XGB_Setting.SAVE_PATH  = fullfile(FARTHER_PATH, 'temp', 'XGB_result.mat');
XGB_Setting.INPUT_PATH = fullfile(FARTHER_PATH, 'temp', 'XGB_data.mat');

TEs_DATA_PATH = './data/TEs';
HFIEs_DATA_PATH = './data/HFIEs';
TEs_PS_INFO_PATH = './data/TEs_index_PS.mat';
HFIEs_PS_INFO_PATH = './data/HFIEs_index_PS.mat';

%{
The labels for HFIEs must be greater than those for TEs, because the 
subsequent scoring process uses MATLAB's default function to generate the 
confusion matrix; MATLAB defaults to sorting labels in ascending order, 
treating the first label as the negative class and the second as the positive class.

HFIEs的标签须大于TEs的，因为后续评分中，使用matlab的默认函数生成混淆矩阵，
matlab默认对标签进行升序排列，将第一个标签作为负类，第二个作为正类。
%}
% Use 4 to represent HFIEs.
% 使用4代表HFIEs
fea_HFIEs = fea(HFIEs_PS_INFO_PATH, HFIEs_DATA_PATH, 4);
% Use 1 to represent TEs.
% 使用1代表TEs
fea_TEs = fea(TEs_PS_INFO_PATH, TEs_DATA_PATH, 1);

DATA = [fea_HFIEs; fea_TEs];
DATA = DATA(randperm(size(DATA, 1)), :);

 % Train an LSTM model
 % 训练LSTM模型
classifier_lstm(DATA);
classifier_svm(DATA); % 训练SVM模型
classifier_rf(DATA); % 训练RF模型
classifier_xgb(XGB_Setting, DATA); % 训练XGBoost模型

