function classifier_lstm(TRAIN_DATA)
%{
Introduction:
    This function implements the training of an LSTM model.

介绍：
    本函数为LSTM模型训练实现。

Email：meijiamu26@mails.ucas.ac.cn
%}
% Data preparation phase
% 数据准备阶段
DATA = TRAIN_DATA(:, 2:end);
TRAIN_INPUT_NUM = size(DATA, 2) - 1;
TRAIN_OUTPUT_NUM = 2;

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

Train_INPUT = cell(size(Train_input, 2), 1);
for i = 1:size(Train_input, 2)
    Train_INPUT{i} = Train_input(:, i);
end
Test_INPUT = cell(size(Test_input, 2), 1);
for i = 1:size(Test_input, 2)
    Test_INPUT{i} = Test_input(:, i);
end

Train_INPUT = Train_INPUT';
Test_INPUT = Test_INPUT';

% Model parameter configuration
% 模型参数配置
Layers = [...
    sequenceInputLayer(TRAIN_INPUT_NUM)
    lstmLayer(200, 'OutputMode', 'last')
    dropoutLayer(0.3)
    fullyConnectedLayer(32)
    reluLayer
    fullyConnectedLayer(TRAIN_OUTPUT_NUM)
    softmaxLayer
    classificationLayer];

% Set training parameters
% 设置训练参数
Options = trainingOptions('adam', ...
    'MaxEpochs', 300, ...
    'ExecutionEnvironment', 'cpu', ...
    'MiniBatchSize', 16, ...
    'GradientThreshold', 1, ...
    'Verbose', false, ...
    'Shuffle', 'every-epoch', ...
    'InitialLearnRate', 1e-3, ...
    'ValidationPatience', 20);

% Train the model
% 训练模型
LSTM_net = trainNetwork(Train_INPUT, Train_OUTPUT, Layers, Options);

% Perform classification using an LSTM model
% 使用LSTM模型进行分类
Res = struct();
Res.Test_OUTPUT = Test_OUTPUT;
Res.R_test = classify(LSTM_net, Test_INPUT, "MiniBatchSize", 16, "SequenceLength", "longest");
Res.P_test = predict(LSTM_net, Test_INPUT);

% Rating
% 评分
scores_table = score(Res);

disp('----------------LSTM----------------')
fprintf('Accuracy: %.4f\n', scores_table.accuracy);
fprintf('Precision: %.4f\n', scores_table.precision);
fprintf('Recall: %.4f\n', scores_table.recall);
fprintf('F1: %.4f\n', scores_table.F1);
fprintf('Specificity: %.4f\n', scores_table.specificity);
fprintf('MCC: %.4f\n', scores_table.mcc);
fprintf('AUC: %.4f\n', scores_table.auc);
end