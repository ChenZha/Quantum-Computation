import numpy as np
from scipy.optimize import curve_fit
import matplotlib.pyplot as plt
t = []
p = []
lines = open('T1data.txt')
for line in lines:
    t.append(eval(line.split()[0].strip()))
    p.append(eval(line.split()[1].strip()))


#用指数形式来拟合
t = np.array(t)
p = np.array(p)
p = np.power(10,p)
def func(t,n,tqp,tr):
    return np.exp(n*(np.exp(-t/tqp)-1))*np.exp(-t/tr)
popt, pcov = curve_fit(func, t, p)
n = popt[0]#popt里面是拟合系数，读者可以自己help其用法
tqp = popt[1]
tr = popt[2]
pvals=func(t,n,tqp,tr)
plot1=plt.plot(t, p, '*',label='original values')
plot2=plt.plot(t, pvals, 'r',label='curve_fit values')
plt.xlabel('t axis')
plt.ylabel('p axis')
plt.legend(loc=4)#指定legend的位置,读者可以自己help它的用法
plt.title('curve_fit')
plt.show()

pass