function scores_test = score(Res)
%{
Introduction:
    This function serves as a scoring function; it analyzes the model's 
output to evaluate its performance.

介绍：
    本函数为评分函数，对模型输出结果进行分析，进而对模型性能做出一定评价。

Email：meijiamu26@mails.ucas.ac.cn
%}

Test_OUTPUT = Res.Test_OUTPUT;
R_test = Res.R_test;
P_test = Res.P_test;

% Output the confusion matrix
% 输出混淆矩阵
confusion_matrix_test = confusionmat(Test_OUTPUT, R_test);
tn_test = confusion_matrix_test(1, 1);
fp_test = confusion_matrix_test(1, 2);
fn_test = confusion_matrix_test(2, 1);
tp_test = confusion_matrix_test(2, 2);

% Accuracy
accuracy_test = (tp_test + tn_test) / (tp_test + tn_test + fp_test + fn_test);

% Precision
precision_test = tp_test / (tp_test + fp_test);

% Recall
recall_test = tp_test / (tp_test + fn_test);

% F1
f1_test = (2 * precision_test * recall_test) / (precision_test + recall_test);

% Specificity
specificity_test = tn_test / (tn_test + fp_test);

% MCC
mcc_test = ((tp_test * tn_test) - (fp_test * fn_test)) / ...
    sqrt((tp_test + fp_test) * (tp_test + fn_test) * (tn_test ...
    + fp_test) * (tn_test + fn_test));

% AUC
[~, ~, ~, auc_test] = perfcurve(Test_OUTPUT, P_test(:, 2), categorical(4));

scores_test = table('Size', [1, 7], ...
    'VariableTypes', ...
    {'double', 'double', 'double', 'double', 'double', 'double', 'double'} ...
    , 'VariableNames', ...
    {'accuracy', 'precision', 'recall', 'F1', 'specificity', 'mcc', 'auc'});

scores_test.accuracy = accuracy_test;
scores_test.precision = precision_test;
scores_test.recall = recall_test;
scores_test.F1 = f1_test;
scores_test.specificity = specificity_test;
scores_test.mcc = mcc_test;
scores_test.auc = auc_test;
end