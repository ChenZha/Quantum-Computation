# -*- coding: utf-8 -*-
"""
Created on Sun Feb 19 15:40:22 2017

@author: Chen
"""
'''
两qubit直接通过sigmax进行耦合，强度为0.5*g1*g2*(Delta1+Delta2)/(Delta1*Delta2)
间接耦合曲线明显不平滑，直接耦合曲线平滑
不进行旋转波近似，直接耦合和间接耦合的周期相差10%左右
进行旋转波近似后，间接耦合的不平滑没有消去，但周期与直接耦合基本一致
（高频项影响比较大；简介耦合的不平滑应该主要是腔的影响）
'''

from qutip import *
import numpy as np
import matplotlib.pyplot as plt 
from qutip import gates


from time import clock
starttime=clock()

wc = 6.0  * 2 * pi  # cavity frequency
wa1 = 5.0  * 2 * pi  # atom frequency
wa2 = 5.0  * 2 * pi  # atom frequency
g1  = 0.1 * 2 * pi  # coupling strength
g2  = 0.1 * 2 * pi  # coupling strength
delta1 = wa1-wc
delta2 = wa2-wc
N = 15              # number of cavity fock states
n = 0               # number of photon
level = 2

tlist = np.linspace(0,50,4001)

psi0 = tensor(basis(N,n), basis(level,1),basis(level,0))    # start with an excited atom

a  = tensor(destroy(N), qeye(level), qeye(level))
sm1 = tensor(qeye(N), destroy(level), qeye(level))
sm2 = tensor(qeye(N),  qeye(level), destroy(level))
sz1 = tensor(qeye(N), sigmaz(), qeye(level))
sz2 = tensor(qeye(N),  qeye(level), sigmaz())

#==============================================================================
'''
间接耦合
'''
#without RWA
#H = wc * a.dag() * a + wa1 * sm1.dag() * sm1 + wa2 * sm2.dag() * sm2 + g1 * (a.dag() + a) * (sm1 + sm1.dag()) + g2 * (a.dag() + a) * (sm2 + sm2.dag())
#with RWA
H = wc * a.dag() * a + wa1 * sm1.dag() * sm1 + wa2 * sm2.dag() * sm2 + g1 * (a.dag()*sm1 + a*sm1.dag()) + g2 * (a.dag()*sm2 + a*sm2.dag())
output = mesolve(H, psi0, tlist, [], [a.dag()*a,sm1.dag()*sm1,sm2.dag()*sm2])
n_c = output.expect[0]
n_a1 = output.expect[1]
n_a2 = output.expect[2]


fig, axes = plt.subplots(1, 1, figsize=(10,6))

axes.plot(tlist, n_c, label="Cavity")
axes.plot(tlist, n_a1, label="Atom1 excited state")
axes.plot(tlist, n_a2, label="Atom2 excited state")
axes.legend(loc=1)
axes.set_xlabel('Time')
axes.set_ylabel('Occupation probability')
axes.set_title('Vacuum Rabi oscillations')
#==============================================================================

#==============================================================================
'''
直接通过sigmax耦合
'''
H1 = wa1 * sm1.dag() * sm1 + wa2 * sm2.dag() * sm2 + 0.5*g1*g2*(delta1+delta2)/(delta1*delta2)*(sm1 + sm1.dag())*(sm2 + sm2.dag())
output = mesolve(H1, psi0, tlist, [], [a.dag()*a,sm1.dag()*sm1,sm2.dag()*sm2])
n_c = output.expect[0]
n_a1 = output.expect[1]
n_a2 = output.expect[2]
fig, axes = plt.subplots(1, 1, figsize=(10,6))
axes.plot(tlist, n_c, label="Cavity")
axes.plot(tlist, n_a1, label="Atom1 excited state")
axes.plot(tlist, n_a2, label="Atom2 excited state")
axes.legend(loc=1)
axes.set_xlabel('Time')
axes.set_ylabel('Occupation probability')
axes.set_title('Vacuum Rabi oscillations_SX')
#==============================================================================


#==============================================================================
#H2 = wa1 * sm1.dag() * sm1 + wa2 * sm2.dag() * sm2 + g1*g2*(delta1*delta2)/(delta1+delta2)*sz1*sz2
#output = mesolve(H2, psi0, tlist, [], [a.dag()*a,sm1.dag()*sm1,sm2.dag()*sm2])
#n_c = output.expect[0]
#n_a1 = output.expect[1]
#n_a2 = output.expect[2]
#fig, axes = plt.subplots(1, 1, figsize=(10,6))
#axes.plot(tlist, n_c, label="Cavity")
#axes.plot(tlist, n_a1, label="Atom1 excited state")
#axes.plot(tlist, n_a2, label="Atom2 excited state")
#axes.legend(loc=1)
#axes.set_xlabel('Time')
#axes.set_ylabel('Occupation probability')
#axes.set_title('Vacuum Rabi oscillations_SZ')
#==============================================================================

finishtime=clock()
print 'Time used: ', (finishtime-starttime), 's'

