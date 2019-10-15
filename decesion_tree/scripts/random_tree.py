#ランダムフォレスト
import pandas as pd

# read kaggle taitanic train data
target_file_path = "../../titanic/train.csv"
df_origin = pd.read_csv(target_file_path)

#前処理
from sklearn.model_selection import train_test_split
#欠損値処理
df_origin['Fare'] = df_origin['Fare'].fillna(df_origin['Fare'].median())
df_origin['Age'] = df_origin['Age'].fillna(df_origin['Age'].median())
df_origin['Embarked'] = df_origin['Embarked'].fillna('S')

#カテゴリ変数の変換
df_origin['Sex'] = df_origin['Sex'].apply(lambda x: 1 if x == 'male' else 0)
df_origin['Embarked'] = df_origin['Embarked'].map( {'S': 0, 'C': 1, 'Q': 2} ).astype(int)

df_origin = df_origin.drop(['Cabin','Name','PassengerId','Ticket'],axis=1)
train_X = df_origin.drop('Survived', axis=1)
train_y = df_origin.Survived
(train_X, test_X ,train_y, test_y) = train_test_split(train_X, train_y, test_size = 0.3, random_state = 666)

#学習
#ランダムフォレスト
#n_estimators:木をいくつ生成するか。デフォルトでは10。
#max_depth:木の深さの設定
#max_features:分岐に用いる説明変数の数を設定
#min_sample_split:分割する際の最小のサンプル数を設定
#random_state:seedの設定。seedを設定しないとモデルが毎回変わるので注意。

from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import (roc_curve, auc, accuracy_score)

clf = RandomForestClassifier(random_state=0)
clf = clf.fit(train_X, train_y)
pred = clf.predict(test_X)
fpr, tpr, thresholds = roc_curve(test_y, pred, pos_label=1)
auc(fpr, tpr)
accuracy_score(pred, test_y)

print("AUC:{}".format(auc(fpr, tpr)))
print("正解率:{}".format(accuracy_score(pred, test_y)))

#変数重要度の可視化
import matplotlib.pyplot as plt
import numpy as np
%matplotlib inline

features = train_X.columns
importances = clf.feature_importances_
indices = np.argsort(importances)

plt.figure(figsize=(6,6))
plt.barh(range(len(indices)), importances[indices], color='b', align='center')
plt.yticks(range(len(indices)), features[indices])
plt.show()

