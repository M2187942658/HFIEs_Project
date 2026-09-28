"""XGBoost bridge called by ``src/classifier_xgb.m``.

供 ``src/classifier_xgb.m`` 调用的 XGBoost 桥接脚本。
"""

from __future__ import annotations

import argparse

import numpy as np
import scipy.io as sio
from xgboost import XGBClassifier


def classifier_xgb_function(infile: str, outfile: str) -> None:
    """Train XGBoost from Matlab's MAT input and save MAT predictions.

    从 Matlab 的 MAT 输入训练 XGBoost，并将预测结果保存回 MAT 文件。
    """

    mat = sio.loadmat(infile)
    x_train = np.asarray(mat["Train_XGB_input"], dtype=float)
    x_test = np.asarray(mat["Test_XGB_input"], dtype=float)
    y_train = np.asarray(mat["Y_XGB_train"]).reshape(-1).astype(int)
    model = XGBClassifier(
        n_estimators=200, max_depth=3, learning_rate=0.1,
        subsample=1.0, colsample_bytree=0.8,
        objective="binary:logistic", eval_metric="logloss",
    )
    model.fit(x_train, y_train)
    sio.savemat(outfile, {
        "Importance": model.feature_importances_,
        "R_test": model.predict(x_test).astype(int),
        "P_test": model.predict_proba(x_test),
    })


def main() -> None:
    """Run the Matlab-compatible command-line interface.

    运行与 Matlab 兼容的命令行接口。
    """

    parser = argparse.ArgumentParser(description="XGBoost training bridge / XGBoost 训练桥接脚本")
    parser.add_argument("-i", "--input", required=True, help="MAT input path / MAT 输入路径")
    parser.add_argument("-o", "--output", required=True, help="MAT output path / MAT 输出路径")
    args = parser.parse_args()
    classifier_xgb_function(args.input, args.output)


if __name__ == "__main__":
    main()

