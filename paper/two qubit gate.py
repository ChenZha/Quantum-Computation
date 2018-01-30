# -*- coding: utf-8 -*-
"""
Created on Fri Feb 24 16:20:57 2017

@author: Chen
"""

from qutip import *
import numpy as np
import matplotlib.pyplot as plt 
from qutip import gates


from time import clock
starttime=clock()

w_c = 6.0  * 2 * pi  # cavity frequency
w_q = np.array([ 5.0 , 5.1 ]) * 2 * np.pi
g = np.array([0.1 , 0.1]) * 2 * np.pi
eta_q = np.array([0.1 , 0.1]) * 2 * np.pi
N = 10              # number of cavity fock states
n= 1

#==============================================================================
psi0 = tensor(basis(N,n),basis(3,0),basis(3,2))
tlist = np.linspace(0,50,401)
#==============================================================================

#==============================================================================
a = tensor(destroy(N),qeye(3),qeye(3))
sm0 = tensor(qeye(N),destroy(3),qeye(3))
sm1 = tensor(qeye(N),qeye(3),destroy(3))

sh0 = tensor(qeye(N),basis(3,2)*basis(3,2).dag(),qeye(3))
sh1 = tensor(qeye(N),qeye(3),basis(3,2)*basis(3,2).dag())#用以表征非简谐性的对角线最后一项

sz0 = sm0.dag()*sm0
sz1 = sm1.dag()*sm1

sx0=sm0.dag()+sm0
sx1=sm1.dag()+sm1

sy0=-1j*(sm0.dag()-sm0)
sy1=-1j*(sm1.dag()-sm1)

Heta0 = -eta_q[0] * sh0
Heta1 = -eta_q[1] * sh1  #非简谐项

HC = w_c*a.dag()*a
Hcoupling = g[0] * sx0 * (a.dag()+a) + g[1] * sx1 * (a.dag()+a)

Hq0 =  w_q[0]*sm0.dag()*sm0 + Heta0 
Hq1 =  w_q[1]*sm1.dag()*sm1 + Heta1 
#==============================================================================





H = HC + Hq0 + Hq1 + Hcoupling

result = mesolve(H,psi0,tlist,[],[sx0,sy0,sz0,sm0.dag()*sm0,sx1,sy1,sz1,sm1.dag()*sm1,a.dag()*a])
#==============================================================================
fig, axes = plt.subplots(2, 5, figsize=(10,6))
axes[0][0].plot(tlist, result.expect[0])
axes[0][1].plot(tlist, result.expect[1])
axes[0][2].plot(tlist, result.expect[2])
axes[0][3].plot(tlist, result.expect[3])
axes[0][4].plot(tlist, result.expect[8])
axes[0][0].set_title('X1')
axes[0][1].set_title('Y1')
axes[0][2].set_title('Z1')
axes[0][3].set_title('N_a1')
axes[0][4].set_title('N_c')
axes[1][0].plot(tlist, result.expect[4])
axes[1][1].plot(tlist, result.expect[5])
axes[1][2].plot(tlist, result.expect[6])
axes[1][3].plot(tlist, result.expect[7])
axes[1][4].plot(tlist, result.expect[8])
axes[1][0].set_title('X2')
axes[1][1].set_title('Y2')
axes[1][2].set_title('Z2')
axes[1][3].set_title('N_a2')
axes[1][4].set_title('N_c')
#==============================================================================
finishtime=clock()
print 'Time used: ', (finishtime-starttime), 's'
