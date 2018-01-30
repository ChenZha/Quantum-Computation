#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Oct  6 14:22:32 2017

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
import gc 
import sys
import os


def CreateBasicOperator(Num_Q):
    N = 3
    cmdstr=''
    for II in range(0,Num_Q):
        cmdstr+='qeye(3),'
    a= eval('tensor(destroy(N),'+cmdstr+')')

    sm=[]
    for II in range(0,Num_Q):
        cmdstr=''
        for JJ in range(0,Num_Q):
            if II==JJ:
                cmdstr+='destroy(3),'
            else:
                cmdstr+='qeye(3),'
        sm.append(eval('tensor(qeye(N),'+cmdstr+')'))

    smm=[]
    for II in range(0,Num_Q):
        cmdstr=''
        for JJ in range(0,Num_Q):
            if II==JJ:
                cmdstr+='basis(3,2)*basis(3,2).dag(),'
            else:
                cmdstr+='qeye(3),'
        smm.append(eval('tensor(qeye(N),'+cmdstr+')'))
    
    E_e=[]
    for II in range(0,Num_Q):
        cmdstr=''
        for JJ in range(0,Num_Q):
            if II==JJ:
                cmdstr+='basis(3,1)*basis(3,1).dag(),'
            else:
                cmdstr+='qeye(3),'
        E_e.append(eval('tensor(qeye(N),'+cmdstr+')'))
    
    E_g=[]
    for II in range(0,Num_Q):
        cmdstr=''
        for JJ in range(0,Num_Q):
            if II==JJ:
                cmdstr+='basis(3,0)*basis(3,0).dag(),'
            else:
                cmdstr+='qeye(3),'
        E_g.append(eval('tensor(qeye(N),'+cmdstr+')'))
        
    sn=[]
    sx=[]
    sy=[]
    sz = []
    for II in range(0,Num_Q):
        sn.append(sm[II].dag()*sm[II])
        sx.append(sm[II].dag()+sm[II])
        sy.append(1j*(sm[II].dag()-sm[II]))   
        sz.append(E_g[II] - E_e[II] )
        
    return a, sm, smm, E_e, E_g, sn, sx, sy , sz

def wave(t):
#    omega0 = 0.0119 * 2* np.pi
#    omega1 = 0.0288 * 2* np.pi
#    omega0 = 0.0219 * 2* np.pi
#    omega1 = 0.0418 * 2* np.pi
    tp = 100
    wq0=wq[0]+g[0]**2/(wq[0]-wc) 
    wq1=wq[1]+g[1]**2/(wq[1]-wc) 
    ramp=1
    
    w = (2*omega0*(-erf((t-tp/2)/(ramp))*np.cos(wq0 * t)+2*np.exp(-(t-tp/2)**2/(ramp)**2)/(ramp)/np.sqrt(pi)/(eta_q[0])*np.cos(wq0 * t-np.pi/2)))
#    w = 2*omega0*(-erf((t-tp/2)/(ramp)))
    return(w)
def decoupleCZ(P):
#    omega0 = P[0]
#    omega1 = P[1]
#    tp = P[2]
#    D = 0.5
    omega0 = 0.0119 * 2* np.pi
    omega1 = 0.0288 * 2* np.pi
    tp = P[0]
    D = P[1]
    
    tlist = np.linspace(0,tp,10*tp+1)
#    figure();plot(tlist,np.vectorize(wave)(tlist))
    
    a, sm, E_uc, E_e, E_g, sn, sx, sy , sz = CreateBasicOperator(3)
    
    HCoupling = g[0]*(a+a.dag())*(sm[0]+sm[0].dag()) + g[1]*(a+a.dag())*(sm[1]+sm[1].dag())+g[2]*(a+a.dag())*(sm[2]+sm[2].dag())
    Hc = wc * a.dag() * a 
    H_eta = eta_q[0] * E_uc[0] + eta_q[1] * E_uc[1]+eta_q[2] * E_uc[2]
    Hq = wq[0]*sn[0] + wq[1]*sn[1] + wq[2]*sn[2]
    H0 = Hq + H_eta + Hc + HCoupling
    
    [E,S] = H0.eigenstates()
#    print(E/2/np.pi)
    
#    w0 = '2*omega0*np.cos(wq0 * t)*(0<t<tp/2.0)-2*omega0*np.cos(wq0 * t)*(tp/2.0<t<tp)'
#    w1 = '2*omega1*np.cos(wq1 * t)*(0<t<tp/2.0)-2*omega1*np.cos(wq1 * t)*(tp/2.0<t<tp)'
    w0 = '(2*omega0*(-erf((t-tp/2)/(ramp))*np.cos(wq0 * t)+D*2*np.exp(-(t-tp/2)**2/(ramp)**2)/(ramp)/np.sqrt(pi)/('+str(eta_q[0])+')*np.cos(wq0 * t-np.pi/2)))*(0<t<tp)'
    w1 = '(2*omega1*(-erf((t-tp/2)/(ramp))*np.cos(wq1 * t)+D*2*np.exp(-(t-tp/2)**2/(ramp)**2)/(ramp)/np.sqrt(pi)/('+str(eta_q[1])+')*np.cos(wq1 * t-np.pi/2)))*(0<t<tp)'
    
#    w0 = '(2*omega0*(np.exp(-(t-tp/4)**2/2.0/6**2)*np.cos(wq0 * t)+(t-tp/4)/2/6**2/'+str(eta_q[0])+'*np.exp(-(t-tp/4)**2/2.0/6**2)*np.cos(wq0 * t-np.pi/2)))*(0<t<=tp/2)-(2*omega0*(np.exp(-(t-3*tp/4)**2/2.0/6**2)*np.cos(wq0 * t)+(t-3*tp/4)/2/6**2/'+str(eta_q[0])+'*np.exp(-(t-3*tp/4)**2/2.0/6**2)*np.cos(wq0 * t-np.pi/2)))*(tp/2<t<=tp)'
#    w1 = '(2*omega1*(np.exp(-(t-tp/4)**2/2.0/6**2)*np.cos(wq1 * t)+(t-tp/4)/2/6**2/'+str(eta_q[1])+'*np.exp(-(t-tp/4)**2/2.0/6**2)*np.cos(wq1 * t-np.pi/2)))*(0<t<=tp/2)-(2*omega1*(np.exp(-(t-3*tp/4)**2/2.0/6**2)*np.cos(wq1 * t)+(t-3*tp/4)/2/6**2/'+str(eta_q[1])+'*np.exp(-(t-3*tp/4)**2/2.0/6**2)*np.cos(wq1 * t-np.pi/2)))*(tp/2<t<=tp)'
    
    
    H1 = [(sm[0].dag() + sm[0]),w0]
    H2 = [(sm[1].dag() + sm[1]),w1]
    
    H = [H0 , H1 , H2]

    
    
#    args = {'omega0':omega0 , 'omega1':omega1 , 'wq0':5.63863310*2*np.pi , 'wq1':5.63863310*2*np.pi , 'tp':tp}
    args = {'omega0':omega0 , 'omega1':omega1 , 'wq0':wq[0]+g[0]**2/(wq[0]-wc) , 'wq1':wq[1]+g[1]**2/(wq[1]-wc) , 'tp':tp , 'ramp': 1 , 'D':D}
#    args = {'omega0':omega0 , 'omega1':omega1 , 'wq0':wq[0] , 'wq1':wq[1] , 'tp':tp}
    
    options=Options()
    options.atol=1e-8
    options.rtol=1e-6
    options.first_step=0.01
    options.num_cpus= 4
    options.nsteps=1e6
    options.gui='True'
    options.ntraj=1000
    options.rhs_reuse=False
    
    zz0 = tensor(basis(3,0) , (basis(3,0)+basis(3,1)).unit() , (basis(3,0)+basis(3,1)).unit() , basis(3,0)) 
    zf0 = tensor(basis(3,0) , (basis(3,0)+basis(3,1)).unit() , (basis(3,0)-basis(3,1)).unit() , basis(3,0)) 
    fz0 = tensor(basis(3,0) , (basis(3,0)-basis(3,1)).unit() , (basis(3,0)+basis(3,1)).unit() , basis(3,0)) 
    ff0 = tensor(basis(3,0) , (basis(3,0)-basis(3,1)).unit() , (basis(3,0)-basis(3,1)).unit() , basis(3,0)) 
    
    psi0 = (zz0+zf0).unit()
#    psi0 = (zz0).unit()
    
    result = mesolve(H , psi0 , tlist , [] , [] , args = args , options = options)
#    print(ptrace(result.states[-1] , 0))
#    print(ptrace(result.states[-1] , 1))
#    print(ptrace(result.states[-1] , 2))
#    print(args)

    U0 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(wq[0]+g[0]**2/(wq[0]-wc))*tlist[-1])*basis(3,1)*basis(3,1).dag()
    U1 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(wq[1]+g[1]**2/(wq[1]-wc))*tlist[-1])*basis(3,1)*basis(3,1).dag()
    U2 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(wq[2]+g[2]**2/(wq[2]-wc))*tlist[-1])*basis(3,1)*basis(3,1).dag()
    U = tensor(qeye(3) , U0 , U1 , U2)
    
    target = (1j*zz0+zf0).unit()
#    target = (zz0).unit()
    fid = fidelity(U*result.states[-1]*result.states[-1].dag()*U.dag(), target)
    
#    n_x0 = [] ; n_y0 = [] ; n_z0 = [];
#    n_x1 = [] ; n_y1 = [] ; n_z1 = [];
#    uc_0 = [] ; uc_1 = [] ; nc = []
#    N_zz = [];N_zf = [];N_fz = [];N_ff = [];
#    for t in range(0,len(tlist)):
#        U0 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(wq[0]+g[0]**2/(wq[0]-wc))*tlist[t])*basis(3,1)*basis(3,1).dag()
#        U1 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(wq[1]+g[1]**2/(wq[1]-wc))*tlist[t])*basis(3,1)*basis(3,1).dag()
#        U2 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(wq[2]+g[2]**2/(wq[2]-wc))*tlist[t])*basis(3,1)*basis(3,1).dag()
#        U = tensor(qeye(3) , U0 , U1 , U2)
##        U = (1j*H0*tlist[t]).expm()
#        
#        opx0 = U.dag()*sx[0]*U
#        opy0 = U.dag()*sy[0]*U
#        opz0 = sz[0]
#        opx1 = U.dag()*sx[1]*U
#        opy1 = U.dag()*sy[1]*U
#        opz1 = sz[1]
#        opzz = U.dag()*zz0*zz0.dag()*U
#        opzf = U.dag()*zf0*zf0.dag()*U
#        opfz = U.dag()*fz0*fz0.dag()*U
#        opff = U.dag()*ff0*ff0.dag()*U
#        n_x0.append(expect(opx0,result.states[t]))
#        n_y0.append(expect(opy0,result.states[t]))
#        n_z0.append(expect(opz0,result.states[t]))
#        n_x1.append(expect(opx1,result.states[t]))
#        n_y1.append(expect(opy1,result.states[t]))
#        n_z1.append(expect(opz1,result.states[t]))
#        nc.append(expect(a.dag()*a,result.states[t]))
#        uc_0.append(expect(E_uc[0],result.states[t]))
#        uc_1.append(expect(E_uc[1],result.states[t]))
#        N_zz.append(expect(opzz,result.states[t]))
#        N_zf.append(expect(opzf,result.states[t]))
#        N_fz.append(expect(opfz,result.states[t]))
#        N_ff.append(expect(opff,result.states[t]))
#
#    
#    
#    sphere = Bloch()
#    sphere.add_points([n_x0 , n_y0 , n_z0])
#    sphere.add_vectors([n_x0[-1],n_y0[-1],n_z0[-1]])
#    sphere.make_sphere() 
#    sphere = Bloch()
#    sphere.add_points([n_x1 , n_y1 , n_z1])
#    sphere.add_vectors([n_x1[-1],n_y1[-1],n_z1[-1]])
#    sphere.make_sphere() 
#    plt.show()
#    
#    fig , axes = plt.subplots(3,1)
#    axes[0].plot(tlist,nc);axes[0].set_xlabel('t');axes[0].set_ylabel('N_cavity')
#    axes[1].plot(tlist,uc_0);axes[1].set_xlabel('t');axes[1].set_ylabel('N of Level2_Q0')
#    axes[2].plot(tlist,uc_1);axes[2].set_xlabel('t');axes[2].set_ylabel('N of Level2_Q1')
#    
#    fig , axes = plt.subplots(4,1)
#    axes[0].plot(tlist,N_zz);axes[0].set_xlabel('t');axes[0].set_ylabel('N++')
#    axes[1].plot(tlist,N_zf);axes[1].set_xlabel('t');axes[1].set_ylabel('N+-')
#    axes[2].plot(tlist,N_fz);axes[2].set_xlabel('t');axes[2].set_ylabel('N-+')
#    axes[3].plot(tlist,N_ff);axes[3].set_xlabel('t');axes[3].set_ylabel('N--')

    print(fid,P)
    
    return(1-fid)


if __name__ == '__main__':
    starttime=time.time()
    
    wc = 5.795  * 2 * np.pi  # cavity frequency
    wq = np.array([ 5.640 , 5.640 , 6.84]) * 2 * np.pi      
    g = np.array([0.0142 , 0.0142 , 0.0142]) * 2 * np.pi
    eta_q = np.array([-0.250 , -0.250 , -0.250]) * 2 * np.pi
                    
    geff = 0.5*g[0]*g[1]*(1/(wq[0]-wc)+1/(wq[1]-wc))
#    print(geff)
    
    omega0 = 0.0119 * 2* np.pi
    omega1 = 0.0288 * 2* np.pi
#    omega0 = 0.0219 * 2* np.pi
#    omega1 = 0.0418 * 2* np.pi
#    tp = 100
#    fid = decoupleCZ([omega0 , omega1 , tp])
#    print(fid)

    x0 = [np.pi/2/abs(geff),0.5]
    result = minimize(decoupleCZ, x0, method="Nelder-Mead",options={'disp': True})
    print(result.x[0],result.x[1])
    
    
    
    
    
    finishtime=time.time()
    print( 'Time used: ', (finishtime-starttime), 's')
    
    
    