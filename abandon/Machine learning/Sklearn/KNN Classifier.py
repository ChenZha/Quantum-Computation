'''
KNN classifier 就是选择几个临近点，综合它们做个平均来作为预测值
'''
from sklearn import datasets
from sklearn.model_selection import train_test_split
from sklearn.neighbors import KNeighborsClassifier

iris = datasets.load_iris()
iris_X = iris.data
iris_Y = iris.target
#feature 存在X，target存在Y,X有四个属性，Y有0,1,2三类

'''
把数据集分成训练集和测试集，其中test_size = 0.3 , 代表测试集占总数据的0.3
'''
X_train,X_test,Y_train,Y_test = train_test_split(iris_X,iris_Y,test_size = 0.3)

knn = KNeighborsClassifier()
knn.fit(X_train,Y_train)#以训练集进行训练
print(knn.predict(X_test))
print(Y_test)
print(knn.predict(X_test)==Y_test)
