# -*- coding: utf-8 -*-
"""
Created on Wed Jan 25 22:45:09 2017

@author: lenovo
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
N = 20

wr = 2.0 * 2 * pi      # resonator frequency
wq = 3.0 * 2 * pi      # qubit frequency
chi = 0.025 * 2 * pi   # parameter in the dispersive hamiltonian

delta = abs(wr - wq)        # detuning
g = np.sqrt(delta * chi)  # coupling strength that is consistent with chi 

# cavity operators
a = tensor(destroy(N), qeye(2))
nc = a.dag() * a
xc = a + a.dag()

# atomic operators
sm = tensor(qeye(N), destroy(2))
sz = tensor(qeye(N), sigmaz())
sx = tensor(qeye(N), sigmax())
nq = sm.dag() * sm
xq = sm + sm.dag()

I = tensor(qeye(N), qeye(2))
#==============================================================================


#==============================================================================
# dispersive hamiltonian
#H = wr * (a.dag() * a + I/2.0) + (wq / 2.0) * sz + chi * (a.dag() * a + I/2) * sz
H = wr * (a.dag() * a + I/2.0) - (wq / 2.0) * sz + g * (a.dag() + a)*(sm +sm.dag())
#==============================================================================


#==============================================================================
psi0 = tensor(coherent(N, np.sqrt(4)), (basis(2,0)+basis(2,1)).unit())
tlist = np.linspace(0, 250, 1000)
res = mesolve(H, psi0, tlist, [], [], options=Odeoptions(nsteps=5000))

#nc_list = expect(nc, res.states)
#nq_list = expect(nq, res.states)
#
#fig, ax = plt.subplots(1, 1, sharex=True, figsize=(12,4))
#
#ax.plot(tlist, nc_list, 'r', linewidth=2, label="cavity")
#ax.plot(tlist, nq_list, 'b--', linewidth=2, label="qubit")
#ax.set_ylim(0, 7)
#ax.set_ylabel("n", fontsize=16)
#ax.set_xlabel("Time (ns)", fontsize=16)
#ax.legend()
#fig.tight_layout()
#
#
#xc_list = expect(xc, res.states)
#fig, ax = plt.subplots(1, 1, sharex=True, figsize=(12,4))
#ax.plot(tlist, xc_list, 'r', linewidth=2, label="cavity")
#ax.set_ylabel("x", fontsize=16)
#ax.set_xlabel("Time (ns)", fontsize=16)
#ax.legend()
#fig.tight_layout()


#==============================================================================


#==============================================================================
'''
Correlation function for the resonator
''' 


tlist = np.linspace(0, 100, 1000) 
corr_vec = correlation(H, psi0, None, tlist, [], a.dag(), a)
fig, ax = plt.subplots(1, 1, sharex=True, figsize=(12,4))
ax.plot(tlist, np.real(corr_vec), 'r', linewidth=2, label="resonator")
ax.set_ylabel("correlation", fontsize=16)
ax.set_xlabel("Time (ns)", fontsize=16)
ax.legend()
ax.set_xlim(0,50)
fig.tight_layout()



w, S = spectrum_correlation_fft(tlist, corr_vec)
fig, ax = plt.subplots(figsize=(9,3))
#ax.plot(w / (2 * pi), abs(S))
ax.plot((w-wr) / ( chi), abs(S))
ax.set_xlabel(r'$\omega$', fontsize=18)
#ax.set_xlim(wr/(2*pi)-.5, wr/(2*pi)+.5)
#==============================================================================


#==============================================================================
'''
Correlation function of the qubit
'''
corr_vec = correlation(H, psi0, None, tlist, [], sx, sx)

fig, ax = plt.subplots(1, 1, sharex=True, figsize=(12,4))
ax.plot(tlist, np.real(corr_vec), 'r', linewidth=2, label="qubit")
ax.set_ylabel("correlation", fontsize=16)
ax.set_xlabel("Time (ns)", fontsize=16)
ax.legend()
ax.set_xlim(0,50)
fig.tight_layout() 


w, S = spectrum_correlation_fft(tlist, corr_vec)
fig, ax = plt.subplots(figsize=(9,3))
#ax.plot(w / (2 * pi), abs(S))
ax.plot((w-wq) / ( 2 * chi), abs(S))
ax.set_xlabel(r'$\omega$', fontsize=18)
#==============================================================================
finishtime=clock()
print ('Time used: ', (finishtime-starttime), 's')