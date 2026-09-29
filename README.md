# Demonstration Project on Distinguishing Earthquakes Induced by Shale Gas Hydraulic Fracturing

------

## Project Overview

This project demonstrates how to distinguish between earthquakes induced by shale gas hydraulic fracturing and tectonic earthquakes. The core functions showcased—such as feature extraction, waveform data preprocessing, and model training details—align with the methodologies employed in the original research experiments; this demonstration project was created by omitting the specific pipeline processing and repetitive experimental steps used during the actual study.

## Project Operation Instructions

This project can be run with a single click using `main.m`. Before running the project, please configure the settings in `main.m` and extract the pre-prepared data from the `data` folder. Additionally, users must independently add the necessary tools for reading waveform data; the link to the tool project is: [IPGP/mseed-lib: Matlab/Octave codes to read and write miniSEED files](https://github.com/IPGP/mseed-lib).

## Data Notes

The demonstration data used in this project is identical to the data used in the research.

Raw waveform data is available at: 
https://drive.google.com/file/d/1B9ZgsbZps3hfVdBaIhsdLhPA6ijZK9uu/view?usp=drive_link

Processed waveform data is available at: 
https://drive.google.com/file/d/1bGQcM7m9h840zcePKs8dZm1tPiPwUocC/view?usp=drive_link

## Code Explanation
| File or directory name        | Explanation                                                  |
| :---------------------------- | ------------------------------------------------------------ |
| main.m                        | This is the project's main program, designed to control the project and support one-click execution. Before using it for the first time, ensure the configuration is correct; specifically, the user must configure the `XGB_Setting.PYTHON_ENV` variable. |
| data\requirements.txt         | A list of libraries required to run the Python script, making it easy to install dependencies. |
| data\HFIEs.zip                | This dataset contains seismic waveform data associated with hydraulic fracturing for shale gas. Please decompress the files yourself when using the project, ensuring that you avoid creating redundant nested directory structures. All waveform data included here have already been processed. |
| data\HFIEs_index_PS.mat       | The arrival times of P- and S-waves in the seismic waveforms induced by shale gas hydraulic fracturing were manually picked. |
| data\TEs.zip                  | This dataset contains tectonic earthquake waveforms. Please extract the files yourself before running the project, ensuring that you avoid creating redundant nested directory structures during extraction. All waveform data included here has already been processed. |
| data\TEs_index_PS.mat         | The arrival times of P and S waves in the tectonic earthquake waveforms were all picked manually. |
| py\classifier_xgb_function.py | Python script for implementing XGBoost model training functionality |
| src\classifier_lstm.m         | Function implementing LSTM model training                    |
| src\classifier_rf.m           | Function implementing the Random Forest model training process |
| src\classifier_svm.m          | Function implementing SVM model training                     |
| src\classifier_xgb.m          | Main function for XGBoost model training                     |
| src\fea.m                     | Feature extraction function                                  |
| src\score.m                   | Model evaluation function                                    |
| process.py                    | Waveform data preprocessing function                         |
| Events.txt                    | Detailed spatiotemporal information on earthquakes induced by shale gas hydraulic fracturing |
| temp                          | Cache directory                                              |

------

------

# 页岩气水力压裂诱发地震区分演示项目

------

## 项目介绍

本项目用于演示页岩气水力压裂诱发地震与构造地震区分，本项目中所演示的核心功能，如特征提取、波形数据预处理、模型训练细节等均与项目研究实验时所采用的方法一致，在去除研究时所撰写的流水线处理部分与重复实验部分，得到了本演示项目。

## 项目运行说明

本项目可通过main.mat一键运行。运行本项目时，请先配置好main.m中的配置信息，解压data文件中提前准备的数据。此外，须用户自行添加用于读取波形数据的工具，工具项目链接：[IPGP/mseed-lib: Matlab/Octave codes to read and write miniSEED files](https://github.com/IPGP/mseed-lib)。

## 数据说明

本项目中所用到的演示数据均与研究时所用数据一致。

原始波形数据可获取自：https://drive.google.com/file/d/1B9ZgsbZps3hfVdBaIhsdLhPA6ijZK9uu/view?usp=drive_link

经处理波形数据可获取自：https://drive.google.com/file/d/1bGQcM7m9h840zcePKs8dZm1tPiPwUocC/view?usp=drive_link

## 代码说明
| 文件或目录名称                | 说明                                                         |
| :---------------------------- | ------------------------------------------------------------ |
| main.m                        | 项目主程序，用于控制项目，支持一键运行。初次使用时，须确定配置正确，变量XGB_Setting.PYTHON_ENV须用户自行配置。 |
| data\requirements.txt         | Python脚本运行所需库列表，方便安装依赖库。                   |
| data\HFIEs.zip                | 页岩气水力压裂诱发地震波形数据，在运行本项目时，请自行解压，解压时，请避免出现目录重复嵌套。本波形数据均已经过处理。 |
| data\HFIEs_index_PS.mat       | 页岩气水力压裂诱发地震波形中的P、S波达到时刻，均为手动拾取。 |
| data\TEs.zip                  | 构造地震波形数据，在运行本项目时，请自行解压，解压时，请避免出现目录重复嵌套。本波形数据均已经过处理。 |
| data\TEs_index_PS.mat         | 构造地震波形中的P、S波达到时刻，均为手动拾取。               |
| py\classifier_xgb_function.py | XGBoost模型训练功能实现Python脚本                            |
| src\classifier_lstm.m         | LSTM模型训练功能实现函数                                     |
| src\classifier_rf.m           | RF模型训练功能实现函数                                       |
| src\classifier_svm.m          | SVM模型训练功能实现函数                                      |
| src\classifier_xgb.m          | XGBoost模型训练功能主函数                                    |
| src\fea.m                     | 特征提取函数                                                 |
| src\score.m                   | 模型评价函数                                                 |
| process.py                    | 波形数据预处理函数                                           |
| Events.txt                    | 页岩气水力压裂诱发地震的详细时空信息                         |
| temp                          | 缓存目录                                                     |





