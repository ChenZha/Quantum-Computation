#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Mar 14 21:08:47 2017

@author: chen
"""

from qutip import *
import numpy as np
import matplotlib.pyplot as plt 
from qutip import gates

from time import clock
starttime=clock()

#==============================================================================
'''
parameters
'''
pi = np.pi
 
wq0 = 2.0 * 2 * pi      # qubit0 frequency
wq1 = 3.0 * 2 * pi      # qubit1 frequency
g = 0.05 * 2 * pi   # coupling strength

delta = abs(wq0 - wq1)        # detuning
if delta:
    chi = g**2/delta  # dispersive
    print(chi)
else:
    print('resonate')
# qubit operators
sm0 = tensor(destroy(2) , qeye(2))
sz0 = tensor(sigmaz() , qeye(2))
sx0 = tensor(sigmax() , qeye(2))
sy0 = tensor(sigmay() , qeye(2))
nq0 = sm0.dag() * sm0
            
sm1 = tensor(qeye(2) , destroy(2))
sz1 = tensor(qeye(2) , sigmaz())
sx1 = tensor(qeye(2) , sigmax())
sy1 = tensor(qeye(2) , sigmay())
nq1 = sm1.dag() * sm1

#==============================================================================
#H = -wq0*sz0/2 - wq1*sz1/2 + g*sx0*sx1
#H = -wq0*sz0/2 - wq1*sz1/2 + g*(sm0*sm1.dag() + sm0.dag()*sm1)
H = -wq0*sz0/2 - wq1*sz1/2 + g*sz0*sz1


#==============================================================================
psi0 = tensor((basis(2,1)+1j*basis(2,0)).unit(), (basis(2,1)+basis(2,0)).unit())
#tlist = np.linspace(0, 20, 10000)
tlist = np.linspace(0, 2000, 20000) 
res = mesolve(H, psi0, tlist, [], [], options=Odeoptions(nsteps=5000))

#==============================================================================


##==============================================================================
#qz0 = expect(sz0, res.states)
#qz1 = expect(sz1, res.states)
#
#fig, ax = plt.subplots(1, 1, sharex=True, figsize=(12,4))
#
#ax.plot(tlist, qz0, 'r', linewidth=2, label="qubit0")
#ax.plot(tlist, qz1, 'b--', linewidth=2, label="qubit1")
#ax.set_ylabel("$\sigma_z$", fontsize=16)
#ax.set_xlabel("Time (ns)", fontsize=16)
#ax.legend()
#fig.tight_layout()
#
#
#qx0 = expect(sx0, res.states)
#qx1 = expect(sx1, res.states)
#
#fig, ax = plt.subplots(1, 1, sharex=True, figsize=(12,4))
#
#ax.plot(tlist, qx0, 'r', linewidth=2, label="qubit0")
#ax.plot(tlist, qx1, 'b--', linewidth=2, label="qubit1")
#ax.set_ylabel("$\sigma_x$", fontsize=16)
#ax.set_xlabel("Time (ns)", fontsize=16)
#ax.legend()
#fig.tight_layout()
##==============================================================================


#==============================================================================
corr_vec = correlation(H, psi0, None, tlist, [], sx0, sx0)

fig, ax = plt.subplots(1, 1, sharex=True, figsize=(12,4))
ax.plot(tlist, np.real(corr_vec), 'r', linewidth=2, label="qubit0")
ax.set_ylabel("correlation", fontsize=16)
ax.set_xlabel("Time (ns)", fontsize=16)
ax.legend()
fig.tight_layout() 


w, S = spectrum_correlation_fft(tlist, corr_vec)
fig, ax = plt.subplots(figsize=(9,3))
#ax.plot(w, abs(S))
ax.plot((w-wq0) / (  chi), abs(S))
#ax.set_xlim(-40,40)
ax.set_xlabel(r'$(\omega-\omega_{q1})/\chi$', fontsize=18)


delta = (w-wq0) / ( chi)
top = delta[np.where(S == max(S))]
print(top)
#==============================================================================
finishtime=clock()
print ('Time used: ', (finishtime-starttime), 's')