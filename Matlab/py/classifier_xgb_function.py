import scipy.io as sio
import argparse
import numpy as np
from xgboost import XGBClassifier

def classifier_xgb_function(infile, outfile):
    mat = sio.loadmat(infile)
    Xtrain = np.array(mat['Train_XGB_input'])
    Xtest = np.array(mat['Test_XGB_input'])

    ytrain = np.ravel(mat['Y_XGB_train'])
    ytest = np.ravel(mat['Y_XGB_test'])

    ytrain = ytrain.astype(int)
    ytest = ytest.astype(int)

    model = XGBClassifier(
        n_estimators=200,
        max_depth=3,
        learning_rate=0.1,
        subsample=1,
        colsample_bytree=0.8,
        objective='binary:logistic',
        eval_metric='logloss',
    )

    model.fit(Xtrain, ytrain)
    R_test = model.predict(Xtest)
    P_test = model.predict_proba(Xtest)

    importance = model.feature_importances_

    sio.savemat(
        outfile,
        {
            'Importance': importance,
            'R_test': R_test,
            'P_test': P_test,
        }
    )
    
if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='XGBoost模型训练功能实现')
    parser.add_argument('-i', '--input', help='指定输入文件地址')
    parser.add_argument('-o', '--output', help='指定输出文件地址')
    args = parser.parse_args()
    inputfile = args.input
    outfile = args.output
    classifier_xgb_function(inputfile, outfile)
    