# -*- coding: utf-8 -*-
"""
Created on Fri Feb 17 20:11:13 2017

@author: Chen
"""

import csv
import matplotlib.pyplot as plt
import numpy as np
from qutip import *

pi = np.pi
wc1 = 2.0  * 2 * pi  # cavity frequency
wc2 = 2.0 * 2 * pi  # cavity frequency
wa = 2.0  * 2 * pi  # atom frequency
g1  = 0.5 * 2 * pi  # coupling strength
g2  = 0.5 * 2 * pi  # coupling strength
#kappa = 0.005       # cavity dissipation rate
#gamma = 0.05        # atom dissipation rate
N = 10              # number of cavity fock states

#==============================================================================
def evo1(t,args=None):
    return np.cos(wc1*t)
def evo2(t,args=None):
    return np.cos(wc2*t)
#==============================================================================

tlist = np.linspace(0,4,101)

psi0 = tensor(basis(N,0),basis(N,0), basis(2,1))    # start with an excited atom
a  = tensor(destroy(N), qeye(N),qeye(2))
b  = tensor(qeye(N),destroy(N), qeye(2))
sm = tensor(qeye(N),qeye(N), destroy(2))
sx = tensor(qeye(N),qeye(N), sigmax())
sy = tensor(qeye(N),qeye(N), sigmay())
sz = tensor(qeye(N),qeye(N), sigmaz())



Hq = wc1 * a.dag() * a +wc2 * b.dag() * b + wa * sm.dag() * sm + g1 * (a.dag() + a) * (sm + sm.dag()) + g2 * (b.dag() + b) * (sm + sm.dag())
#Hq = wc2 * b.dag() * b + wa * sm.dag() * sm + g2 * (b.dag() + b) * (sm + sm.dag())
    
Hc0 = wa * sm.dag() * sm
Hc1 = [g1*(sm.dag()+sm),evo1]
Hc2 = [g2*(sm.dag()+sm),evo2]
Hc = [Hc0,Hc2]

resultq = mesolve(Hq,psi0,tlist,[],[sx,sy,sz])
sphere = Bloch()
sphere.add_points([resultq.expect[0], resultq.expect[1], resultq.expect[2]])
sphere.make_sphere()
plt.show()
fig, axes = plt.subplots(1, 3, figsize=(10,6))
axes[0].plot(tlist, resultq.expect[0])
axes[1].plot(tlist, resultq.expect[1])
axes[2].plot(tlist, resultq.expect[2])
axes[0].set_title('X')
axes[1].set_title('Y')
axes[2].set_title('Z')

resultc = mesolve(Hc,psi0,tlist,[],[sx,sy,sz])
sphere = Bloch()
sphere.add_points([resultc.expect[0], resultc.expect[1], resultc.expect[2]])
sphere.make_sphere()
plt.show()
fig, axes = plt.subplots(1, 3, figsize=(10,6))
axes[0].plot(tlist, resultc.expect[0])
axes[1].plot(tlist, resultc.expect[1])
axes[2].plot(tlist, resultc.expect[2])
axes[0].set_title('X')
axes[1].set_title('Y')
axes[2].set_title('Z')
