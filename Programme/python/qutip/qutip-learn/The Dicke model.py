# -*- coding: utf-8 -*-
"""
Created on Sat Jan 21 11:16:57 2017

@author: lenovo
"""

from qutip import *
import numpy as np
import matplotlib.pyplot as plt 
from qutip import gates

from time import clock
starttime=clock()


#==============================================================================
"""
parameters 
"""
w  = 1.0
w0 = 1.0

g = 1.0
gc = sqrt(w * w0)/2 # critical coupling strength

kappa = 0.05 
gamma = 0.15

M = 16
N = 4
j = N/2.0
n = 2*j + 1

a  = tensor(destroy(M), qeye(n))
Jp = tensor(qeye(M), jmat(j, '+'))
Jm = tensor(qeye(M), jmat(j, '-'))
Jz = tensor(qeye(M), jmat(j, 'z'))

H0 = w * a.dag() * a + w0 * Jz
H1 = 1.0 / sqrt(N) * (a + a.dag()) * (Jp + Jm)
H = H0 + g * H1
#============================================================================
g_vec = np.linspace(0.01, 1.0, 20)

# Ground state and steady state for the Hamiltonian: H = H0 + g * H1
psi_gnd_list = [(H0 + g * H1).groundstate()[1] for g in g_vec]

n_gnd_vec = expect(a.dag() * a, psi_gnd_list)  #cavity 光子数
Jz_gnd_vec = expect(Jz, psi_gnd_list)  #在Jz方向上的投影

fig, axes = plt.subplots(1, 2, sharex=True, figsize=(12,4))

axes[0].plot(g_vec, n_gnd_vec, 'b', linewidth=2, label="cavity occupation")
axes[0].set_ylim(0, max(n_gnd_vec))
axes[0].set_ylabel("Cavity gnd occ. prob.", fontsize=16)
axes[0].set_xlabel("interaction strength", fontsize=16)

axes[1].plot(g_vec, Jz_gnd_vec, 'b', linewidth=2, label="cavity occupation")
axes[1].set_ylim(-j, j)
axes[1].set_ylabel(r"$\langle J_z\rangle$", fontsize=16)
axes[1].set_xlabel("interaction strength", fontsize=16)
fig.tight_layout()

#==============================================================================
#psi_gnd_sublist = psi_gnd_list[::4]
#
#xvec = np.linspace(-7,7,200)
#
#fig_grid = (3, len(psi_gnd_sublist))
#fig = plt.figure(figsize=(3*len(psi_gnd_sublist),9))
#
#for idx, psi_gnd in enumerate(psi_gnd_sublist):
#
#    # trace out the cavity density matrix
#    rho_gnd_cavity = ptrace(psi_gnd, 0)
#    
#    # calculate its wigner function
#    W = wigner(rho_gnd_cavity, xvec, xvec)
#    
#    # plot its wigner function
#    ax = plt.subplot2grid(fig_grid, (0, idx))
#    ax.contourf(xvec, xvec, W, 100)
#
#    # plot its fock-state distribution
#    ax = plt.subplot2grid(fig_grid, (1, idx))
#    ax.bar(arange(0, M), real(rho_gnd_cavity.diag()), color="blue", alpha=0.6)
#    ax.set_ylim(0, 1)
#    ax.set_xlim(0, M)    
#    
## plot the cavity occupation probability in the ground state
#ax = plt.subplot2grid(fig_grid, (2, 0), colspan=fig_grid[1])
#ax.plot(g_vec, n_gnd_vec, 'r', linewidth=2, label="cavity occupation")
#ax.set_xlim(0, max(g_vec))
#ax.set_ylim(0, max(n_gnd_vec)*1.2)
#ax.set_ylabel("Cavity gnd occ. prob.", fontsize=16)
#ax.set_xlabel("interaction strength", fontsize=16)
#
#for g in g_vec[::4]:
#    ax.plot([g,g],[0,max(n_gnd_vec)*1.2], 'b:', linewidth=2.5) 
#==============================================================================


#==============================================================================
#entropy_tot    = zeros(shape(g_vec))
#entropy_cavity = zeros(shape(g_vec))
#entropy_spin   = zeros(shape(g_vec))
#
#for idx, psi_gnd in enumerate(psi_gnd_list):
#
#    rho_gnd_cavity = ptrace(psi_gnd, 0)
#    rho_gnd_spin   = ptrace(psi_gnd, 1)
#    
#    entropy_tot[idx]    = entropy_vn(psi_gnd, 2)
#    entropy_cavity[idx] = entropy_vn(rho_gnd_cavity, 2)
#    entropy_spin[idx]   = entropy_vn(rho_gnd_spin, 2)
#    
#fig, axes = plt.subplots(1, 1, figsize=(12,6))
#axes.plot(g_vec, entropy_tot, 'k', g_vec, entropy_cavity, 'b', g_vec, entropy_spin, 'r--')
#
#axes.set_ylim(0, 1.5)
#axes.set_ylabel("Entropy of subsystems", fontsize=16)
#axes.set_xlabel("interaction strength", fontsize=16)
#
#fig.tight_layout()
#==============================================================================


#==============================================================================
#def calulcate_entropy(M, N, g_vec):
#    
#    j = N/2.0
#    n = 2*j + 1
#
#    # setup the hamiltonian for the requested hilbert space sizes
#    a  = tensor(destroy(M), qeye(n))
#    Jp = tensor(qeye(M), jmat(j, '+'))
#    Jm = tensor(qeye(M), jmat(j, '-'))
#    Jz = tensor(qeye(M), jmat(j, 'z'))
#
#    H0 = w * a.dag() * a + w0 * Jz
#    H1 = 1.0 / sqrt(N) * (a + a.dag()) * (Jp + Jm)
#
#    # Ground state and steady state for the Hamiltonian: H = H0 + g * H1
#    psi_gnd_list = [(H0 + g * H1).groundstate()[1]  for g in g_vec]
#    
#    entropy_cavity = zeros(shape(g_vec))
#    entropy_spin   = zeros(shape(g_vec))
#
#    for idx, psi_gnd in enumerate(psi_gnd_list):
#
#        rho_gnd_cavity = ptrace(psi_gnd, 0)
#        rho_gnd_spin   = ptrace(psi_gnd, 1)
#    
#        entropy_cavity[idx] = entropy_vn(rho_gnd_cavity, 2)
#        entropy_spin[idx]   = entropy_vn(rho_gnd_spin, 2)
#        
#    return entropy_cavity, entropy_spin
#
#g_vec = np.linspace(0.2, 0.8, 60)
#N_vec = [4, 8, 12, 16, 24, 32]
#MM = 25
#
#fig, axes = plt.subplots(1, 1, figsize=(12,6))
#
#for NN in N_vec:
#    
#    entropy_cavity, entropy_spin = calulcate_entropy(MM, NN, g_vec)
#    
#    axes.plot(g_vec, entropy_cavity, 'b', label="N = %d" % NN)
#    axes.plot(g_vec, entropy_spin, 'r--')
#
#axes.set_ylim(0, 1.75)
#axes.set_ylabel("Entropy of subsystems", fontsize=16)
#axes.set_xlabel("interaction strength", fontsize=16)
#axes.legend()
 
#==============================================================================

finishtime=clock()
print 'Time used: ', (finishtime-starttime), 's'
#==============================================================================
 
#==============================================================================
