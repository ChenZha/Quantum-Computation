# -*- coding: utf-8 -*-
"""
Created on Fri Jul 08 20:39:21 2016

@author: Administrator
"""

# -*- coding: utf-8 -*-
"""
Created on Fri Jul 08 16:51:11 2016

@author: Administrator
"""

import matplotlib.pyplot as plt
import numpy as np
from numpy import *
from qutip import *

#Q1 defination
sm1 = tensor(destroy(2),qeye(2))
sz1 = tensor(sigmaz(), qeye(2))
sx1=sm1+sm1.dag()
sy1=1j*(-sm1+sm1.dag())

#Q2 defination
sm2 = tensor(qeye(2),destroy(2))
sz2 = tensor(qeye(2), sigmaz())
sx2=sm2+sm2.dag()
sy2=1j*(-sm2+sm2.dag())

w_q1=5*2*pi
w_q2=6*2*pi
g_12 = 0 * 2 * pi # Q1 & Q2 coupling strength

gamma_1 =1./20000          # Q1 dissipation rate
gamma_phi_1 = 1./200      # Q1 dissipation daphsaing rate

gamma_2 =1./2000          # Q1 dissipation rate
gamma_phi_2 = 1./2000000      # Q1 dissipation daphsaing rate

omega_01=5*2*pi
Omega_01_I=0.01 *2*pi
Omega_01_Q=0 *2*pi
omega_02=6*2*pi
Omega_02_I=0 *2*pi
Omega_02_Q=0 *2*pi



n_th = 0.01 # environment temperature
c_ops = []
c_ops.append(sqrt(gamma_1 * (1+n_th)) * sm1)
c_ops.append(sqrt(gamma_1 * n_th) * sm1.dag())
c_ops.append(sqrt(gamma_phi_1) * sz1)
c_ops.append(sqrt(gamma_2 * (1+n_th)) * sm2)
c_ops.append(sqrt(gamma_2 * n_th) * sm2.dag())
c_ops.append(sqrt(gamma_phi_2) * sz2)

H_0=w_q1*sm1.dag()*sm1+w_q2*sm2.dag()*sm2
H_I_12 = g_12 * (sm1*sm2.dag()+sm1.dag()*sm2)
H_I_01=Omega_01_I*sx1/2+Omega_01_Q*sy1/2-omega_01*sm1.dag()*sm1
H_I_02=Omega_02_I*sx2/2+Omega_02_Q*sy2/2-omega_02*sm2.dag()*sm2

H=H_0+H_I_12+H_I_01+H_I_02

psi0=tensor(basis(2,1),basis(2,1))
tlist= np.linspace(0,1000,1000)
e_op_list=[sz1,sx1,sy1,sz2,sx2,sy2]

output = mesolve(H, psi0, tlist, c_ops, e_op_list)


fig, axes = plt.subplots(6, 1, figsize=(10,12))
legends=['sz1','sx1','sy1','sz2','sx2','sy2']

for ii in range(0,6):
    n_q = output.expect[ii]
    
    axes[ii].plot(tlist, n_q)
    axes[ii].set_ylim([-1,1.05])
    axes[ii].set_xlabel('Time')
    axes[ii].set_ylabel(legends[ii])


plt.show()



T = 25

op_basis = [[qeye(2), sigmax(), sigmay(), sigmaz()]]*2

op_labels = [["i", "x", "y", "z"]] * 2

U = propagator(H_I_12, T, c_ops)

#fig1, axes1 = plt.subplots(1, 2, figsize=(10,6))
qpt_plot_combined(qpt(U, op_basis), op_labels)