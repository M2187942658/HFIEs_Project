function classifier_rf(TRAIN_DATA)
%{
Introduction:
    This function implements the training of a Random Forest model.

介绍：
    本函数为Random Forest模型训练实现。

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

Train_input = Train_DATA(:, 1:end-1);
Test_input = Test_DATA(:, 1:end-1);

[Train_input, Psin] = mapminmax(Train_input', -1, 1);
Test_input = mapminmax('apply', Test_input', Psin);

Train_OUTPUT = categorical(TRAIN_DATA.Classification(1:INDEX));
Test_OUTPUT = categorical(TRAIN_DATA.Classification(INDEX+1:end));

% Set model parameters
% 设置模型参数
RF = TreeBagger(500,...
    Train_input',...
    Train_OUTPUT,...
    'Method','classification',...
    'OOBPrediction','on',...
    'NumPredictorsToSample',5 , ...
    'OOBPredictorImportance','on');

[R_test, P_test] = predict(RF,Test_input');
R_test = categorical(str2double(R_test));

Res = struct();

Res.Test_OUTPUT = Test_OUTPUT;
Res.R_test = R_test;
Res.P_test = P_test;

scores_table = score(Res);

disp('----------------RF----------------')
fprintf('Accuracy: %.4f\n', scores_table.accuracy);
fprintf('Precision: %.4f\n', scores_table.precision);
fprintf('Recall: %.4f\n', scores_table.recall);
fprintf('F1: %.4f\n', scores_table.F1);
fprintf('Specificity: %.4f\n', scores_table.specificity);
fprintf('MCC: %.4f\n', scores_table.mcc);
fprintf('AUC: %.4f\n', scores_table.auc);
end