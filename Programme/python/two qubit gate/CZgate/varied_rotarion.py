#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sat Jun 10 18:24:43 2017

@author: chen
"""

import time 
import csv
import matplotlib.pyplot as plt
import numpy as np
from pylab import *
from qutip import *
from scipy.optimize import *
from mpl_toolkits.mplot3d import Axes3D
from scipy.special import *
from multiprocessing import Pool
from decimal import *
from math import *

def Gate_CZ(t,args = None):

    tp = T

    geff = np.sqrt(2)*0.5*g[1]*g[0]*(1/abs(w_q[0]-w_c)+1/abs(w_q[1]-w_c))
    xi = atan(2*geff/(w_q[1]-w_q[0]-eta_q[1]))
    if xi<0:
        xi=xi+np.pi
    else:
        xi=xi
    xf = np.pi/2#atan(2*geff/((w_q[1]-w_q[0])-(Ee[2]-Ee[3])))#
    if xf<0:
        xf=xf+np.pi
    else:
        xf=xf
    Hx = geff
    delta = (w_q[1]-w_q[0]-eta_q[1])
    w_t =  (delta-2*Hx/np.tan(xi+(xf-xi)/2*(1-np.cos(2*np.pi*t/tp))-0.16*(1-np.cos(2*2*np.pi*t/tp))))
    
    

    return w_t

#==============================================================================
## Cavity Frequency
global w_c
w_c= 5.1 * 2 * np.pi

## Qubits frequency
global w_q
w_q = np.array([ 6.05 , 6.1 , 6 , 5.9 , 5.8 , 5.7 , 5.6 , 5.5 , 5.4 , 5.3]) * 2 * np.pi

## Coupling Strength
global g
g = np.array([0.02, 0.02, 0.02, 0.02, 0.02, 0.02, 0.02, 0.02, 0.02, 0.02]) * 2 * np.pi

## Qubits Anharmonicity
global eta_q
eta_q=  np.array([0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25]) * 2 * np.pi
global N
N = 3

#==============================================================================

a = tensor(destroy(N),qeye(3),qeye(3))
sm = np.array([tensor(qeye(N),destroy(3),qeye(3)) , tensor(qeye(N),qeye(3),destroy(3))])

E_uc = np.array([tensor(qeye(N),basis(3,2)*basis(3,2).dag(),qeye(3)) , tensor(qeye(N),qeye(3), basis(3,2)*basis(3,2).dag())])
#用以表征非简谐性的对角线最后一�?非计算能�?
#E_uc1 = tensor(qeye(N),qeye(3), Qobj([[0,0],[0,1]]))

E_e = np.array([tensor(qeye(N),basis(3,1)*basis(3,1).dag(),qeye(3)),tensor(qeye(N),qeye(3),basis(3,1)*basis(3,1).dag())])
#激发�?    
E_g = np.array([tensor(qeye(N),basis(3,0)*basis(3,0).dag(),qeye(3)) , tensor(qeye(N),qeye(3),basis(3,0)*basis(3,0).dag())])
#基�?    
sn = np.array([sm[0].dag()*sm[0] , sm[1].dag()*sm[1]])

sx = np.array([sm[0].dag()+sm[0],sm[1].dag()+sm[1]]);
sxm = np.array([tensor(qeye(N),Qobj([[0,1,0],[1,0,0],[0,0,0]]),qeye(3)) , tensor(qeye(N),qeye(3),Qobj([[0,1,0],[1,0,0],[0,0,0]]))])


sy = np.array([1j*(sm[0].dag()-sm[0]) , 1j*(sm[1].dag()-sm[1])]);
sym = np.array([tensor(qeye(N),Qobj([[0,-1j,0],[1j,0,0],[0,0,0]]),qeye(3)) , tensor(qeye(N),qeye(3),Qobj([[0,-1j,0],[1j,0,0],[0,0,0]]))])

sz = np.array([E_g[0] - E_e[0] , E_g[1] - E_e[1]])


#==============================================================================

starttime=time.time()

#==============================================================================

#==============================================================================
HCoupling = g[0]*(a+a.dag())*(sm[0]+sm[0].dag()) + g[1]*(a+a.dag())*(sm[1]+sm[1].dag())
#HCoupling = g[0]*(a*sm[0].dag()+a.dag()*sm[0]) + g[1]*(a*sm[1].dag()+a.dag()*sm[1])
Hc = w_c * a.dag() * a 
H_eta = -eta_q[0] * E_uc[0] - eta_q[1] * E_uc[1]
Hq = w_q[0]*sn[0] + w_q[1]*sn[1]
H0 = Hq + H_eta + Hc + HCoupling

[E,S] = H0.eigenstates()
global Ee
Ee = E

#==============================================================================
Hv = [sn[0],Gate_CZ]
H = [H0,Hv]


#==============================================================================
global T
T = 604
tlist = np.linspace(0,T,T+1)
number = 9

psi0 = (S[number]).unit()
#==============================================================================
options=Options()
options.atol=1e-11
options.rtol=1e-9
options.first_step=0.01
options.num_cpus= 4
options.nsteps=1e6
options.gui='True'
options.ntraj=1000
options.rhs_reuse=False
result = mesolve(H,psi0,tlist,[],[],options = options)

time1 = time.time()
print( 'Evolve Time: ', (time1-starttime), 's')

fid = []
ang = []
wave = []
err = []

for i,t in enumerate(tlist):
    wt = Gate_CZ(t)
    Ht = wt*sn[0]
    H = H0+Ht
    [E0,S0] = H.eigenstates()
    wave.append(wt)
    U = (1j*H0*t).expm()
    if number != 9:
        
        fid.append(fidelity(S0[number],result.states[i]))
        ang.append(angle((S0[number].dag()*U*result.states[i])[0][0]))
    else:
        S92 = (ptrace(S0[9],2).data.toarray())[1][1]
        if abs(S92)>0.5:
            fid.append(fidelity(S0[9],result.states[i]))
            err.append(fidelity(S0[8],result.states[i]))
            ang.append(angle((S0[9].dag()*U*result.states[i])[0][0]))
        else:
            fid.append(fidelity(S0[8],result.states[i]))
            err.append(fidelity(S0[9],result.states[i]))
            ang.append(angle((S0[8].dag()*U*result.states[i])[0][0]))
        
    
    
    
            
        
    
fig, axes = plt.subplots(1, 2, figsize=(10,6))
axes[0].plot(tlist, fid, label='000');axes[0].set_xlabel('Time');axes[0].set_ylabel('fid')
axes[1].plot(tlist, ang, label='000');axes[1].set_xlabel('Time');axes[1].set_ylabel('Angle')
fig.suptitle('state['+str(number)+']')
plt.tight_layout()
fig.subplots_adjust(top=0.88)

plt.figure()
plt.plot(tlist,err)

time2 = time.time()
print( 'Comparation Time: ', (time2-time1), 's')