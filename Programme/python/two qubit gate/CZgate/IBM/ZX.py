#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Oct 30 22:26:33 2017

@author: chen
"""
import time 
import csv
import matplotlib.pyplot as plt
import numpy as np
from pylab import *
from qutip import *
from scipy.optimize import *
from scipy.integrate import *
from scipy import interpolate 
from mpl_toolkits.mplot3d import Axes3D
from scipy.special import *
from multiprocessing import Pool
from decimal import *
from math import *
import gc 
import sys

sm0 = tensor(destroy(2),qeye(2))
X1 = tensor(sigmax(),qeye(2))
Y1 = tensor(sigmay(),qeye(2))
Z1 = tensor(sigmaz(),qeye(2))

sm1 = tensor(qeye(2),destroy(2))
X2 = tensor(qeye(2),sigmax())
Y2 = tensor(qeye(2),sigmay())
Z2 = tensor(qeye(2),sigmaz())

g = 0.003*2*np.pi
wq = 5.0*2*np.pi
omega = 0.1*2*np.pi

psi0 = tensor(basis(2,0),basis(2,1))

H = [-wq/2*Z1,[omega/2*X1,'(erf((t-8)/5)-erf((t-90+8)/5))*np.cos((5.0*2*np.pi+0.2*2*np.pi)*t)']]
#H = [H,[0.1*2*np.pi/2*sm0.dag(),'np.exp(1j*0.2*np.pi*t)'],[0.1*2*np.pi/2*sm0,'np.exp(-1j*0.2*np.pi*t)']]
tlist = np.linspace(0,100,1001)

output = mesolve(H,psi0,tlist,[],[])

n_x0 = [] ; n_y0 = [] ; n_z0 = [];
n_x1 = [] ; n_y1 = [] ; n_z1 = [];
for t in range(0,len(tlist)):
    U0 = basis(2,0)*basis(2,0).dag()+np.exp(1j*(wq)*tlist[t])*basis(2,1)*basis(2,1).dag()
    U1 = basis(2,0)*basis(2,0).dag()+np.exp(1j*(wq)*tlist[t])*basis(2,1)*basis(2,1).dag()
    U = tensor(U0,U1)
#        U = (1j*H0*tlist[t]).expm()
    
    opx0 = U.dag()*(X1)*U
    opy0 = U.dag()*(Y1)*U
    opz0 = Z1
    opx1 = U.dag()*(X2)*U
    opy1 = U.dag()*(Y2)*U
    opz1 = Z2
    n_x0.append(expect(opx0,output.states[t]))
    n_y0.append(expect(opy0,output.states[t]))
    n_z0.append(expect(opz0,output.states[t]))
    n_x1.append(expect(opx1,output.states[t]))
    n_y1.append(expect(opy1,output.states[t]))
    n_z1.append(expect(opz1,output.states[t]))
    

   
fig ,axes = plt.subplots(3,1)
axes[0].plot(tlist,n_x0);axes[0].set_xlabel('t');axes[0].set_ylabel('X0')
axes[1].plot(tlist,n_y0);axes[1].set_xlabel('t');axes[1].set_ylabel('Y0')
axes[2].plot(tlist,n_z0);axes[2].set_xlabel('t');axes[2].set_ylabel('Z0')
sphere = Bloch()
sphere.add_points([n_x0 , n_y0 , n_z0])
sphere.add_vectors([n_x0[-1],n_y0[-1],n_z0[-1]])
sphere.make_sphere() 
sphere = Bloch()
sphere.add_points([n_x1 , n_y1 , n_z1])
sphere.add_vectors([n_x1[-1],n_y1[-1],n_z1[-1]])
sphere.make_sphere() 
plt.show() 