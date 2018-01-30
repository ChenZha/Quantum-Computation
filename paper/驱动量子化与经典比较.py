# -*- coding: utf-8 -*-
"""
Created on Sat Feb 18 12:02:54 2017

@author: Chen
"""
'''
量子化：耦合g
半经典：耦合2g*sqrt(n+1)
将cos（wc*t）进行旋转波近似后，曲线平滑
'''

from qutip import *
import numpy as np
import matplotlib.pyplot as plt 
from qutip import gates


wc = 2.0  * 2 * pi  # cavity frequency
wa = 2.0  * 2 * pi  # atom frequency
g  = 1 * 2 * pi  # coupling strength

N = 10           # number of cavity fock states
n = 0
 
tlist = np.linspace(0,1,101)

psi0 = tensor(basis(N,n), basis(2,1))    # start with an excited atom

a  = tensor(destroy(N), qeye(2))
sm = tensor(qeye(N), destroy(2))
sx = tensor(qeye(N),sigmax())
sy = tensor(qeye(N),sigmay())
sz = tensor(qeye(N),sigmaz())

def evo(t,args=None):
    return np.cos(wc*t)
    
def evo0(t,args=None):
    return np.exp(-1j*wc*t)
    
def evo1(t,args=None):
    return np.exp(1j*wc*t)
    
    
#Hq = wc * a.dag() * a + wa * sm.dag() * sm + g * (a.dag() + a) * (sm + sm.dag())
Hq = wc * a.dag() * a + wa * sm.dag() * sm + g * (a.dag()*sm + a* sm.dag())
resultq = mesolve(Hq,psi0,tlist,[],[sx,sy,sz,sm.dag()*sm])
sphere = Bloch()
sphere.add_points([resultq.expect[0], resultq.expect[1], resultq.expect[2]])
sphere.make_sphere()
plt.show()
fig, axes = plt.subplots(1, 4, figsize=(10,6))
axes[0].plot(tlist, resultq.expect[0])
axes[1].plot(tlist, resultq.expect[1])
axes[2].plot(tlist, resultq.expect[2])
axes[3].plot(tlist, resultq.expect[3])
axes[0].set_title('X')
axes[1].set_title('Y')
axes[2].set_title('Z')
axes[3].set_title('N_a')

Hc1 = wa * sm.dag() * sm
#Hc2 = [2*np.sqrt(n+1)*g*(sm.dag()+sm),evo]
#Hc = [Hc1,Hc2]
Hc2 = [2*np.sqrt(n+1)*g*sm.dag(),evo0]
Hc3 = [2*np.sqrt(n+1)*g*sm,evo1]
Hc = [Hc1,Hc2,Hc3]
resultc = mesolve(Hc,psi0,tlist,[],[sx,sy,sz,sm.dag()*sm])
sphere = Bloch()
sphere.add_points([resultc.expect[0], resultc.expect[1], resultc.expect[2]])
sphere.make_sphere()
plt.show()
fig, axes = plt.subplots(1, 4, figsize=(10,6))
axes[0].plot(tlist, resultc.expect[0])
axes[1].plot(tlist, resultc.expect[1])
axes[2].plot(tlist, resultc.expect[2])
axes[3].plot(tlist, resultc.expect[3])
axes[0].set_title('X')
axes[1].set_title('Y')
axes[2].set_title('Z')
axes[3].set_title('N_a')