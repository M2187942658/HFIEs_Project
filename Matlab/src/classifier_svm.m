function classifier_svm(TRAIN_DATA)
%{
Introduction:
    This function implements the training of an SVM model.
介绍：
    本函数为SVM模型训练实现。

Email：meijiamu26@mails.ucas.ac.cn
%}

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
SVM = fitcsvm(...
    Train_input',...
    Train_OUTPUT,...
    'KernelFunction','rbf',...
    'KernelScale','auto',...
    'BoxConstraint', 10, ...
    'Standardize',false);
SVM = fitPosterior(SVM);

[R_test, P_test] = predict(SVM, Test_input');

Res = struct();

Res.Test_OUTPUT = Test_OUTPUT;
Res.R_test = R_test;
Res.P_test = P_test;

scores_table = score(Res);

disp('----------------SVM----------------')
fprintf('Accuracy: %.4f\n', scores_table.accuracy);
fprintf('Precision: %.4f\n', scores_table.precision);
fprintf('Recall: %.4f\n', scores_table.recall);
fprintf('F1: %.4f\n', scores_table.F1);
fprintf('Specificity: %.4f\n', scores_table.specificity);
fprintf('MCC: %.4f\n', scores_table.mcc);
fprintf('AUC: %.4f\n', scores_table.auc);
end