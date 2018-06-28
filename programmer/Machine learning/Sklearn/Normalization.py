from sklearn import preprocessing
import numpy as np

a = np.array([[10,2.7,3.6],[-100,5,-2],[120,20,40]],dtype = np.float64)
print(a)
print(preprocessing.scale(a))#preprocessing.scale对每一竖列进行归一化，先将平均值平移到0，再除以std


'''
数据标准化对机器学习成效的影响
'''
#将资料分割成train和test模块
from sklearn.model_selection import train_test_split

#生成适合做classification 资料的模块
from sklearn.datasets.samples_generator import make_classification

#Support Vector Machine中的Support Vector Classifier
from sklearn.svm import SVC
import matplotlib.pyplot as plt

X,Y = make_classification(n_samples=300,n_features=2,n_redundant=0,n_informative=2,random_state=22,n_clusters_per_class=1,scale=100)
plt.scatter(X[:,0],X[:,1],c = Y)
plt.show()

''' 未标准化 '''
X_train,X_test,Y_train,Y_test = train_test_split(X,Y,test_size = 0.3)
clf = SVC()
clf.fit(X_train,Y_train)
print('未标准化',clf.score(X_test,Y_test))

''' 标准化 '''
X = preprocessing.scale(X)
X_train,X_test,Y_train,Y_test = train_test_split(X,Y,test_size = 0.3)
clf = SVC()
clf.fit(X_train,Y_train)
print('标准化',clf.score(X_test,Y_test))
