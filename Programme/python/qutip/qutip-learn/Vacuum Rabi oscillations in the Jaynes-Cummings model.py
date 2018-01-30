# -*- coding: utf-8 -*-
"""
Created on Tue Jan 17 23:15:02 2017

@author: Chen
"""
"""
在使用create 和destroy算符时，由于使用的是截断的Hillbert空间，最高位的计算会出现问题，
只要舍掉最高Fock 态就好

"""

from qutip import *
import numpy as np
import matplotlib.pyplot as plt 
from qutip import gates


from time import clock
starttime=clock()


wc = 2.0  * 2 * pi  # cavity frequency
wa = 1.9  * 2 * pi  # atom frequency
g  = 0.05 * 2 * pi  # coupling strength
kappa = 0.005       # cavity dissipation rate
gamma = 0.05        # atom dissipation rate
N = 15              # number of cavity fock states
n_th_a = 0.0        # avg number of thermal bath excitation
use_rwa = False

tlist = np.linspace(0,10,101)

psi0 = tensor(basis(N,0), basis(2,1))    # start with an excited atom
a  = tensor(destroy(N), qeye(2))
sm = tensor(qeye(N), destroy(2))
sx = tensor(qeye(N),sigmax())
sy = tensor(qeye(N),sigmay())
sz = tensor(qeye(N),sigmaz())
#==============================================================================
def evo0(t,args=None):
    return np.exp(1j*wc*t)
    
def evo1(t,args=None):
    return np.exp(-1j*wc*t)
#==============================================================================
# Hamiltonian
if use_rwa: #旋转波近似
    H = wc * a.dag() * a + wa * sm.dag() * sm + g * (a.dag() * sm + a * sm.dag())
#    H0 = wc * a.dag() * a + wa * sm.dag() * sm
#    H1 = [g * a.dag() * sm,evo0]
#    H2 = [g * a * sm.dag(),evo1]
#    H = [H0,H1,H2]
    
else:
    H = wc * a.dag() * a + wa * sm.dag() * sm + g * (a.dag() + a) * (sm + sm.dag())
#    H0 = wc * a.dag() * a + wa * sm.dag() * sm
#    H1 = [g * (a.dag() * sm+a.dag() * sm.dag()),evo0]
#    H2 = [g * (a * sm+a * sm.dag()),evo1]
#    H = [H0,H1,H2]
    
    
    
#==============================================================================
c_ops = []
 # cavity relaxation
rate = kappa * (1 + n_th_a)
if rate > 0.0:
    c_ops.append(sqrt(rate) * a)
 
 # cavity excitation, if temperature > 0
rate = kappa * n_th_a
if rate > 0.0:
    c_ops.append(sqrt(rate) * a.dag())
 
 # qubit relaxation
rate = gamma
if rate > 0.0:
    c_ops.append(sqrt(rate) * sm)
#==============================================================================
    

output = mesolve(H, psi0, tlist, [], [a.dag()*a,sm.dag()*sm])
n_c = output.expect[0]
n_a = output.expect[1]

fig, axes = plt.subplots(1, 1, figsize=(10,6))

axes.plot(tlist, n_c, label="Cavity")
axes.plot(tlist, n_a, label="Atom excited state")
axes.legend(loc=1)
axes.set_xlabel('Time')
axes.set_ylabel('Occupation probability')
axes.set_title('Vacuum Rabi oscillations')

#sphere = Bloch()
#sphere.add_points([resultq.expect[0], resultq.expect[1], resultq.expect[2]])
#sphere.make_sphere()
#plt.show()
#fig, axes = plt.subplots(1, 3, figsize=(10,6))
#axes[0].plot(tlist, resultq.expect[0])
#axes[1].plot(tlist, resultq.expect[1])
#axes[2].plot(tlist, resultq.expect[2])
#axes[0].set_title('X')
#axes[1].set_title('Y')
#axes[2].set_title('Z')

#==============================================================================
#output = mesolve(H, psi0, tlist, c_ops, [])
## find the indices of the density matrices for the times we are interested in
#t_idx = where([tlist == t for t in [0.0, 5.0, 15.0, 25.0]])[1]
#tlist[t_idx]
#
## get a list density matrices
#rho_list = array(output.states)[t_idx]
#xvec = np.linspace(-3,3,200)
#fig, axes = plt.subplots(1,len(rho_list), sharex=True, figsize=(3*len(rho_list),3))
#
#
#for idx, rho in enumerate(rho_list):
#
#    # trace out the atom from the density matrix, to obtain
#    # the reduced density matrix for the cavity
#    rho_cavity = ptrace(rho, 0)
#    
#    # calculate its wigner function
#    W = wigner(rho_cavity, xvec, xvec)
#    
#    # plot its wigner function
#    axes[idx].contourf(xvec, xvec, W, 100, norm=mpl.colors.Normalize(-.25,.25), cmap=plt.get_cmap('RdBu'))
#
#    axes[idx].set_title(r"$t = %.1f$" % tlist[t_idx][idx], fontsize=16)
#==============================================================================
finishtime=clock()
print 'Time used: ', (finishtime-starttime), 's'



