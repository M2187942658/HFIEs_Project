function [scores_table, xy_roc_cell] = classifier_xgb(SETTING, TRAIN_DATA)
%{
Introduction:
    This function trains an XGBoost model by invoking Python via the command line. 
Since MATLAB lacks a native XGBoost training function, this function utilizes the
official Python `xgboost` library to perform the training.

Note: 
    Ensure the following libraries are installed in your Python environment 
(versions used during development):
--numpy(2.2.6)
--pandas(2.3.3)
--scikit-learn(1.7.2)
--scipy(1.15.3)
--xgboost(3.2.0)

Information:
    Python version used during development: 3.10.8

介绍：
    本函数通过命令行调用Python进行XGBoost模型训练。
    由于MatLab没有官方原生XGBoost训练函数，本函数通过命令行调用Python进行
XGBoost模型训练，借由Python官方原生的xgboost库实现XBGoost原生模型训练。

注意：确保所用python环境中已安装一下库(程序开发时所用版本)：
    --numpy(2.2.6)
    --pandas(2.3.3)
    --scikit-learn(1.7.2)
    --scipy(1.15.3)
    --xgboost(3.2.0)

信息：
    程序开发时所用Python-Version：3.10.8

Email：meijiamu26@mails.ucas.ac.cn
%}

% Data preparation phase
% 数据准备阶段
DATA = TRAIN_DATA(:, 2:end);

NUM = size(DATA, 1);
INDEX = floor(0.7 * NUM);
Train = DATA(1:INDEX, :);
Test = DATA(INDEX+1:end, :);

Train_DATA = Train{:, :};
Test_DATA = Test{:, :};

Train_XGB_input = Train_DATA(:, 1:end-1);
Test_XGB_input = Test_DATA(:, 1:end-1);

[Train_XGB_input, Psin] = mapminmax(Train_XGB_input', -1, 1);
Test_XGB_input = mapminmax('apply', Test_XGB_input', Psin);

Train_OUTPUT = categorical(TRAIN_DATA.Classification(1:INDEX));
Y_XGB_train = TRAIN_DATA.Classification(1:INDEX);
Y_XGB_train(Y_XGB_train==1) = 0; 
Y_XGB_train(Y_XGB_train==4) = 1; 

Test_OUTPUT = categorical(TRAIN_DATA.Classification(INDEX+1:end));
Y_XGB_test = TRAIN_DATA.Classification(INDEX+1:end);
Y_XGB_test(Y_XGB_test==1) = 0;
Y_XGB_test(Y_XGB_test==4) = 1;

Train_XGB_input = Train_XGB_input';
Test_XGB_input = Test_XGB_input';

save('.\temp\XGB_data.mat', 'Train_XGB_input', 'Test_XGB_input', 'Y_XGB_train', 'Y_XGB_test');
while 1
    pause(0.3)
    if isfile('.\temp\XGB_data.mat')
        break
    end
end

command = append(SETTING.PYTHON_ENV, ' ', SETTING.PY_PATH, ' -i ', ...
    SETTING.INPUT_PATH, ' -o ', SETTING.SAVE_PATH);

% Call Python to run the XGBoost training script
% 调用Python运行xgboost训练脚本
system(command);

while 1
    pause(0.3)
    if isfile('.\temp\XGB_result.mat')
        break
    end
end

load('./temp/XGB_result.mat')
delete('./temp/XGB_result.mat')
delete('./temp/XGB_data.mat')

P_test = double(P_test);
R_test(R_test==1) = 4; 
R_test(R_test==0) = 1;
R_test = categorical(R_test');

Res = struct();
Res.Test_OUTPUT = Test_OUTPUT;
Res.R_test = R_test;
Res.P_test = P_test;

scores_table= score(Res);

disp('----------------XGBoost----------------')
fprintf('Accuracy: %.4f\n', scores_table.accuracy);
fprintf('Precision: %.4f\n', scores_table.precision);
fprintf('Recall: %.4f\n', scores_table.recall);
fprintf('F1: %.4f\n', scores_table.F1);
fprintf('Specificity: %.4f\n', scores_table.specificity);
fprintf('MCC: %.4f\n', scores_table.mcc);
fprintf('AUC: %.4f\n', scores_table.auc);
end