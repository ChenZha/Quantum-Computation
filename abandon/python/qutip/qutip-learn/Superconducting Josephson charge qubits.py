# -*- coding: utf-8 -*-
"""
Created on Wed Jan 25 23:14:23 2017

@author: lenovo
"""

from qutip import *
import numpy as np
import matplotlib.pyplot as plt 
from qutip import gates

from time import clock
starttime=clock()


#==============================================================================
def hamiltonian(Ec, Ej, N, ng):
    """
    Return the charge qubit hamiltonian as a Qobj instance.
    """
    m = np.diag(4 * Ec * (arange(-N,N+1)-ng)**2) + 0.5 * Ej * (np.diag(-np.ones(2*N), 1) + 
                                                               np.diag(-np.ones(2*N), -1))
    return Qobj(m)
#==============================================================================
#==============================================================================
def plot_energies(ng_vec, energies, ymax=(20, 3)):
    """
    Plot energy levels as a function of bias parameter ng_vec.
    """
    fig, axes = plt.subplots(1,2, figsize=(16,6))

    for n in range(len(energies[0,:])):
        axes[0].plot(ng_vec, energies[:,n])
    axes[0].set_ylim(-2, ymax[0])
    axes[0].set_xlabel(r'$n_g$', fontsize=18)
    axes[0].set_ylabel(r'$E_n$', fontsize=18)   

    for n in range(len(energies[0,:])):
        axes[1].plot(ng_vec, (energies[:,n]-energies[:,0])/(energies[:,1]-energies[:,0]))
    axes[1].set_ylim(-0.1, ymax[1])
    axes[1].set_xlabel(r'$n_g$', fontsize=18)
    axes[1].set_ylabel(r'$(E_n-E_0)/(E_1-E_0)$', fontsize=18)
    return fig, axes
    
    
def visualize_dynamics(result, ylabel):
    """
    Plot the evolution of the expectation values stored in result.
    """
    fig, ax = plt.subplots(figsize=(12,5))

    ax.plot(result.times, result.expect[0])

    ax.set_ylabel(ylabel, fontsize=16)
    ax.set_xlabel(r'$t$', fontsize=16);
#==============================================================================


#==============================================================================
N = 10
Ec = 1.0
Ej = 10.0
ng_vec = np.linspace(-4, 4, 200)

energies = array([hamiltonian(Ec, Ej, N, ng).eigenenergies() for ng in ng_vec])
plot_energies(ng_vec, energies, ymax=(50, 3));
#==============================================================================


#==============================================================================
# Transmon regime
#Ec = 1.0
#Ej = 50.0
#==============================================================================


#==============================================================================
H = hamiltonian(Ec, Ej, N, 0.5)
evals, ekets = H.eigenstates()
psi_g = ekets[0] # basis(2, 0)
psi_e = ekets[1] # basis(2, 1)
sx = psi_g * psi_e.dag() + psi_e * psi_g.dag()
sz = psi_e * psi_e.dag() - psi_g * psi_g.dag()


H0 = 0.5 * (evals[1]-evals[0]) * sz

A = 0.25  # some driving amplitude
Hd = 0.5 * A * sx # obtained by driving ng(t), 
                  #but now H0 is in the eigenbasis so the drive becomes a sigma_x

energy_level_diagram([H0,Hd,H0+Hd], figsize=(4,2))
#==============================================================================

#==============================================================================
'''
取出粒子最有可能存在的Hillbert空间中的一部分

'''
keep_states = where(abs(ekets[1].full().flatten()) > 0.1)[0]
H0 = H0.extract_states(keep_states)
Hd = Hd.extract_states(keep_states)

#==============================================================================
finishtime=clock()
print 'Time used: ', (finishtime-starttime), 's'