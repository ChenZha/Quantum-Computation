#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Nov  6 19:46:42 2017

@author: chen
"""

import matplotlib.pyplot as plt
import numpy as np
from pylab import *
from qutip import *
from scipy.sparse import *

Num_Q = 3

E_e=[]
for II in range(0,Num_Q):
    cmdstr=''
    for JJ in range(0,Num_Q):
        if II==JJ:
            cmdstr+='basis(3,1)*basis(3,1).dag(),'
        else:
            cmdstr+='qeye(3),'
    E_e.append(eval('tensor('+cmdstr+')'))

E_g=[]
for II in range(0,Num_Q):
    cmdstr=''
    for JJ in range(0,Num_Q):
        if II==JJ:
            cmdstr+='basis(3,0)*basis(3,0).dag(),'
        else:
            cmdstr+='qeye(3),'
    E_g.append(eval('tensor('+cmdstr+')'))
            
'''
输入只有psi
'''
psi = qload(str(Num_Q)+'qubit')

level = ['E_g','E_e']
population = []
labels = []
for i in range(2**(Num_Q)):
    index = i
    code = ''  #code of state
    Measure = '' #measurement of state
    for j in range(Num_Q):
        code = str(np.int(np.mod(index,2))) + code
        Measure = '*'+level[np.int(np.mod(index,2))] +'['+str(j)+']' + Measure
        index = np.floor(index/2)
    Measure = eval('1'+Measure)
    population.append(expect(Measure,psi))
    labels.append(code)
    
'''
不同基矢下的测量结果(概率)
the probability of differe eigenvector
'''
#theory = np.zeros(2**(Num_Q));theory[0] = 0.5;theory[-1] = 0.5;
#error = np.sum(np.abs(theory-population))/2
#figure();plt.bar(range(len(population)),population,tick_label = labels);plt.title('ErrorRate = '+str(error));
#for x,y in zip(range(len(population)),population):
#    plt.text(x,y+0.01,'%.3f'%y,ha = 'center',va = 'bottom')

'''
密度矩阵的实部与虚部
the real part and imaginary part of density matrix 
'''
loc = []
for c in labels:
    l = 0
    for index , i in enumerate(c):
        l+=eval(i)*3**(Num_Q-1-index)
    loc.append(l)
mtr = psi.data.toarray()[meshgrid(loc,loc)]
re = np.real(mtr)
im = np.imag(mtr)

fig = plt.figure()
ax1 = fig.add_subplot(111, projection='3d')
x = range(len(population))
y = range(len(population))
x,y = meshgrid(x,y)

x = x.flatten('F')
y = y.flatten('F')
z = np.zeros_like(x)

dx = 0.5*np.ones_like(x)
dy = 0.5*np.ones_like(y)
dz1 = re.flatten('F')
ax1.bar3d(x,y,z,dx,dy,dz1);ax1.set_title('Real');ax1.set_zlim(-0.6,0.6)

dz2 = im.flatten('F')
fig = plt.figure()
ax2 = fig.add_subplot(111, projection='3d')
ax2.bar3d(x,y,z,dx,dy,dz2);ax2.set_title('Imag');ax2.set_zlim(-0.6,0.6)

    
    
