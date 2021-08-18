#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Jun  9 11:49:37 2017

@author: chen
"""
'''
Frequency is fixed.
Phase accumulate
different rotation frame
'''

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




def angle_plot(number):
#==============================================================================
    ## Cavity Frequency
    w_c= 5.1 * 2 * np.pi
    
    ## Qubits frequency
    w_q = np.array([ 5.85 , 6.1 , 6 , 5.9 , 5.8 , 5.7 , 5.6 , 5.5 , 5.4 , 5.3]) * 2 * np.pi
    
    ## Coupling Strength
    g = np.array([0.02, 0.02, 0.02, 0.02, 0.02, 0.02, 0.02, 0.02, 0.02, 0.02]) * 2 * np.pi
    
    ## Qubits Anharmonicity
    
    eta_q=  np.array([0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25]) * 2 * np.pi
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
    HCoupling = g[0]*(a+a.dag())*(sm[0]+sm[0].dag()) + g[1]*(a+a.dag())*(sm[1]+sm[1].dag())
#    HCoupling = g[0]*(a*sm[0].dag()+a.dag()*sm[0]) + g[1]*(a*sm[1].dag()+a.dag()*sm[1])
    Hc = w_c * a.dag() * a 
    H_eta = -eta_q[0] * E_uc[0] - eta_q[1] * E_uc[1]
    Hq = w_q[0]*sn[0] + w_q[1]*sn[1]
    H = Hq + H_eta + Hc + HCoupling
    
    H0 = Hc+H_eta+Hq
    
    [E,S] = H.eigenstates()
#    print(E[0])
#==============================================================================

    T = 100
    tlist = np.linspace(0,T,T+1)
    psi0 = (S[number]).unit()
#    psi0=tensor(basis(3,0), basis(3,0), basis(3,0))
           
           
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
    
    ang0 = []
    ang1 = []
    ang2 = []
    fid0 = []
    fid1 = []
    fid2 = []
    
    for t in range(len(tlist)):
        ang0.append(angle((psi0.dag()*result.states[t])[0][0]))
        fid0.append(fidelity(psi0,result.states[t]))
        
#        rf0 = np.exp(1j*(E[0]/3.0)*tlist[t])*basis(3,0)*basis(3,0).dag()+np.exp(1j*(E[1])*tlist[t])*basis(3,1)*basis(3,1).dag()
#        rf1 = np.exp(1j*(E[0]/3.0)*tlist[t])*basis(3,0)*basis(3,0).dag()+np.exp(1j*(E[2])*tlist[t])*basis(3,1)*basis(3,1).dag()
#        rf2 = np.exp(1j*(E[0]/3.0)*tlist[t])*basis(3,0)*basis(3,0).dag()+np.exp(1j*(E[3])*tlist[t])*basis(3,1)*basis(3,1).dag()
        
#        rf0 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(E[1])*tlist[t])*basis(3,1)*basis(3,1).dag()
#        rf1 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(E[2])*tlist[t])*basis(3,1)*basis(3,1).dag()
#        rf2 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(E[3])*tlist[t])*basis(3,1)*basis(3,1).dag()

        rf0 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(E[1]-E[0])*tlist[t])*basis(3,1)*basis(3,1).dag()
        rf1 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(E[2]-E[0])*tlist[t])*basis(3,1)*basis(3,1).dag()
        rf2 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(E[3]-E[0])*tlist[t])*basis(3,1)*basis(3,1).dag()
        U1 = tensor(rf0,rf1,rf2)
    #    U1 = tensor(qeye(3),rf1,rf2)
        ang1.append(angle((psi0.dag()*U1*result.states[t])[0][0]))
        fid1.append(fidelity(psi0,U1*result.states[t]))
        
        U2 = (1j*H*tlist[t]).expm()
        ang2.append(angle((psi0.dag()*U2*result.states[t])[0][0]))
        fid2.append(fidelity(psi0,U2*result.states[t]))
        
#    fig, axes = plt.subplots(1, 3, figsize=(10,6))
#    axes[0].plot(tlist, ang0, label='NORF');axes[0].set_xlabel('Time');axes[0].set_ylabel('Angle');axes[0].set_title('NORF')
#    axes[1].plot(tlist, ang1, label='RF1');axes[1].set_xlabel('Time');axes[1].set_ylabel('Angle');axes[1].set_title('RF1')
#    axes[2].plot(tlist, ang2, label='RF2');axes[2].set_xlabel('Time');axes[2].set_ylabel('Angle');axes[2].set_title('RF2')
#    
#    fig.suptitle('state['+str(number)+']')
#    plt.tight_layout()
#    fig.subplots_adjust(top=0.88)
    

    fig, axes = plt.subplots(1, 3, figsize=(10,6))
    axes[0].plot(tlist, fid0, label='NORF');axes[0].set_xlabel('Time');axes[0].set_ylabel('Fid');axes[0].set_title('NORF')
    axes[1].plot(tlist, fid1, label='RF1');axes[1].set_xlabel('Time');axes[1].set_ylabel('Fid');axes[1].set_title('RF1')
    axes[2].plot(tlist, fid2, label='RF2');axes[2].set_xlabel('Time');axes[2].set_ylabel('Fid');axes[2].set_title('RF2')
    
    fig.suptitle('state['+str(number)+']')
    plt.tight_layout()
    fig.subplots_adjust(top=0.88)
    
    
    return(ang0,ang1,ang2,fid0,fid1,fid2,S,E,tlist)



if __name__ == '__main__':
    starttime=time.time()
    angle0 = []
    angle1 = []
    angle2 = []
    fidelity0 = []
    fidelity1 = []
    fidelity2 = []
    
    for i in [0,2,3,8]:
        a,b,c,fid0,fid1,fid2,S,E,tlist = angle_plot(i)
        angle0.append(a)
        angle1.append(b)
        angle2.append(c)
        fidelity0.append(fid1)
        fidelity1.append(fid1)
        fidelity2.append(fid2)
        
    angle0 = np.array(angle0)
    angle1 = np.array(angle1)
    angle2 = np.array(angle2)
    fidelity0 = np.array(fidelity0)
    fidelity1 = np.array(fidelity1)
    fidelity2 = np.array(fidelity2)
    
#    fig, axes = plt.subplots(1, 4, figsize=(10,6))
#    axes[0].plot(tlist, angle0[0]-angle0[0], label='000');axes[0].set_xlabel('Time');axes[0].set_ylabel('Angle')
#    axes[1].plot(tlist, angle0[1]-angle0[0], label='010');axes[1].set_xlabel('Time');axes[1].set_ylabel('Angle')
#    axes[2].plot(tlist, angle0[2]-angle0[0], label='001');axes[2].set_xlabel('Time');axes[2].set_ylabel('Angle')
#    axes[3].plot(tlist, angle0[3]-angle0[0], label='011');axes[2].set_xlabel('Time');axes[2].set_ylabel('Angle')
#    fig.suptitle('NORF')
#    plt.tight_layout()
#    fig.subplots_adjust(top=0.88)
#    
#    fig, axes = plt.subplots(1, 4, figsize=(10,6))
#    axes[0].plot(tlist, angle1[0]-angle1[0], label='000');axes[0].set_xlabel('Time');axes[0].set_ylabel('Angle')
#    axes[1].plot(tlist, angle1[1]-angle1[0], label='010');axes[1].set_xlabel('Time');axes[1].set_ylabel('Angle')
#    axes[2].plot(tlist, angle1[2]-angle1[0], label='001');axes[2].set_xlabel('Time');axes[2].set_ylabel('Angle')
#    axes[3].plot(tlist, angle1[3]-angle1[0], label='011');axes[2].set_xlabel('Time');axes[2].set_ylabel('Angle')
#    fig.suptitle('RF1')
#    plt.tight_layout()
#    fig.subplots_adjust(top=0.88)
    
    fig, axes = plt.subplots(1, 4, figsize=(10,6))
    axes[0].plot(tlist, angle2[0]-angle2[0], label='000');axes[0].set_xlabel('Time');axes[0].set_ylabel('Angle')
    axes[1].plot(tlist, angle2[1]-angle2[0], label='010');axes[1].set_xlabel('Time');axes[1].set_ylabel('Angle')
    axes[2].plot(tlist, angle2[2]-angle2[0], label='001');axes[2].set_xlabel('Time');axes[2].set_ylabel('Angle')
    axes[3].plot(tlist, angle2[3]-angle2[0], label='011');axes[2].set_xlabel('Time');axes[2].set_ylabel('Angle')
    fig.suptitle('RF2')
    plt.legend()
    plt.tight_layout()
    fig.subplots_adjust(top=0.88)

    finishtime=time.time()
    print( 'Time used: ', (finishtime-starttime), 's')