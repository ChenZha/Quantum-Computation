# -*- coding: utf-8 -*-
"""
Created on Sat Jan 21 21:25:08 2017

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
Decay of a coherent state to an incoherent (thermal) state
'''
N = 20
tlist = np.linspace(0,10.0,200)
a = destroy(N)
H = 2*pi*a.dag()*a

# collapse operator
G1 = 0.75
n_th = 2.00  # bath temperature in terms of excitation number
c_ops = [sqrt(G1*(1+n_th)) * a, sqrt(G1*n_th) * a.dag()]

# start with a coherent state
rho0 = coherent_dm(N, 2.0)

# first calculate the occupation number as a function of time
result = mesolve(H, rho0, tlist, c_ops, [a.dag() * a])
n = result.expect[0]

# calculate the correlation function G1 and normalize with n to obtain g1
G1 = correlation(H, rho0, None, tlist, c_ops, a.dag(), a)
g1 = G1 / sqrt(n[0] * n)

fig, axes = plt.subplots(2, 1, sharex=True, figsize=(12,6))

axes[0].plot(tlist, real(g1), 'b', label=r'First-order coherence function $g^{(1)}(\tau)$')
axes[1].plot(tlist, real(n),  'r', label=r'occupation number $n(\tau)$')
axes[0].legend()
axes[1].legend()
axes[1].set_xlabel(r'$\tau$');
#==============================================================================



#==============================================================================
'''
Second-order coherence function
''' 

def correlation_ss_gtt(H, tlist, c_ops, a_op, b_op, c_op, d_op, rho0=None):
    """
    Calculate the correlation function <A(0)B(tau)C(tau)D(0)>

    (ss_gtt = steadystate general two-time)
    
    See, Gardiner, Quantum Noise, Section 5.2.1

    .. note::
        Experimental. 
    """
    if rho0 == None:
        rho0 = steadystate(H, c_ops)

    return mesolve(H, d_op * rho0 * a_op, tlist, c_ops, [b_op * c_op]).expect[0]
    
G2 = correlation_ss_gtt(H, tlist, c_ops, a.dag(), a.dag(), a, a, rho0=rho0)
g2 = G2 / n**2

fig, axes = plt.subplots(2, 1, sharex=True, figsize=(12,6))

axes[0].plot(tlist, real(g2), 'b', label=r'Second-order coherence function $g^{(2)}(\tau)$')
axes[1].plot(tlist, real(n),  'r', label=r'occupation number $n(\tau)$')
axes[0].legend(loc=0)
axes[1].legend()
axes[1].set_xlabel(r'$\tau$');
#==============================================================================

