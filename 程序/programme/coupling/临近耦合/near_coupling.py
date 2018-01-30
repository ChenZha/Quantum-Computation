#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Jun 27 16:13:53 2017

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

def wave(t,tp,para,phi):
    Hx = g
    xi = atan(2*g/(w_q[1]-w_q[0]-eta_q[1]))
    if xi<0:
        xi=xi+np.pi
    else:
        xi=xi
    xf = atan(2*g/((w_q[1]-w_q[0])-(Eq[1]-Eq[0])))#np.pi/2
    if xf<0:
        xf=xf+np.pi
    else:
        xf=xf
    delta = (w_q[1]-w_q[0]-eta_q[1])
    
    w = (delta-2*Hx/np.tan(xi+(xf-xi)/2*(1-np.cos(2*np.pi*t/tp))-para*(1-np.cos(2*2*np.pi*t/tp))))
    
    return(w)

def Gate_CZ(tp=603.9,para = -0.16,phi = -1.71848,delta=0.069066):

        
    
    args_i={}
    w_t_i='(delta-2*Hx/np.tan(xi+(xf-xi)/2*(1-np.cos(2*np.pi*t/tp))-para*(1-np.cos(2*2*np.pi*t/tp))))*('+str(0)+'<t<='+str(tp)+')'
    w_t_i+='+(deltaz*np.exp(-(t-20-'+str(tp)+')**2/2.0/width**2))*('+str(tp)+'<t<=('+str(tp)+'+40))'
    
    args_i['Hx']=g
           
    xi = atan(2*g/(w_q[1]-w_q[0]-eta_q[1]))
    if xi<0:
        args_i['xi']=xi+np.pi
    else:
        args_i['xi']=xi
    xf = atan(2*g/((w_q[1]-w_q[0])-(Eq[1]-Eq[0])))#np.pi/2
    if xf<0:
        args_i['xf']=xf+np.pi
    else:
        args_i['xf']=xf
               
    args_i['tp']=tp 
    args_i['para']=para
    args_i['width']=6
    args_i['deltaz']=delta*phi
           
    args_i['delta']=(w_q[1]-w_q[0]-eta_q[1])



    return w_t_i,args_i

def CZgate(psi0):
#    global Eq,g,w_q,eta_q
    
    
#==============================================================================
    if TG == 1:
        tp=fx[0]
        para = fx[1]
        phi = fx[2]
        delta=0.069066
    else:
        
        tp=603.9
        para = -0.16
        phi = -1.71848
        delta=0.069066

    HCoupling = g*(sm[0]+sm[0].dag())*(sm[1]+sm[1].dag())
    H_eta = eta_q[0] * E_uc[0] + eta_q[1] * E_uc[1]
    Hq = w_q[0]*sn[0] + w_q[1]*sn[1]
    H0 = Hq + H_eta + HCoupling
    
    w_t,args=Gate_CZ(tp , para , phi , delta)
    
    Hd = [sn[0],w_t]
    H = [H0,Hd]
    
#    print(tp,para,phi)
    #==============================================================================
    '''dissipation'''
    Q = 35000
    kappa = 1/13000.0
#    print(kappa)
#    kappa_phi = w_c/Q
    gamma = np.array([1.0/14.8 , 1.0/10]) *1e-3
    gamma_phi = np.array([1.0/10-1.0/2.0/14.8 , 1.0/10-1.0/2.0/10]) *1e-3
    n_th = 0.01
    cops = []
#     for ii in range(2):
        
#        cops.append(np.sqrt(gamma[ii] * (1+n_th)) * sm[ii])
#        cops.append(np.sqrt(gamma[ii] * n_th) * sm[ii].dag())
#        cops.append(np.sqrt(gamma_phi[ii]) * sm[ii].dag()*sm[ii])
#    cops.append(np.sqrt(kappa * (1+n_th)) * a)
#    cops.append(np.sqrt(kappa * n_th) * a.dag())
#    cops.append(np.sqrt(kappa_phi) * a.dag()*a)
    #==============================================================================
    '''evolution'''
    
    options=Options()
    options.atol=1e-11
    options.rtol=1e-9
    options.first_step=0.01
    options.num_cpus= 4
    options.nsteps=1e6
    options.gui='True'
    options.ntraj=1000
    options.rhs_reuse=False
    

    
    

    tlist = np.linspace(0,tp+40,int(tp+40)+1)
    result = mesolve(H,psi0,tlist,cops,[],args = args,options = options)
    

    return(result.states,tlist)
    
def gf(psi):
    psi0 = psi[0]
    psi_target = psi[1]
    
    psi_total, tlist_total=CZgate(psi0)
    if RF:
        UT = (1j*H0*tlist_total[-1]).expm()
    else:
        U0 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(Eq[0])*tlist_total[-1])*basis(3,1)*basis(3,1).dag()
        U1 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(Eq[1])*tlist_total[-1])*basis(3,1)*basis(3,1).dag()
        UT = tensor(U0,U1)
    fid = fidelity(UT*psi_total[-1]*psi_total[-1].dag()*UT.dag(), psi_target)
    return(fid)  

  
def getfid(m):
    global fx
    fx = np.zeros(3)
    fx[0]=m[0]
    fx[1]=m[1]
    fx[2]=m[2]
    
#==============================================================================
    psi = []
    if RS:
        for i in range(n):
            for j in range(n):
                t = []
                t.append((bastate[0]+i*bastate[1]+j*bastate[2]+i*j*bastate[5]).unit())
                t.append((bastate[0]+i*bastate[1]+j*bastate[2]-i*j*bastate[5]).unit())
                psi.append(t)
    else:
        for i in range(n):
            for j in range(n):
                t = []
                t.append((tensor(basis(3,0),basis(3,0))+j*tensor(basis(3,0),basis(3,1))+i*tensor(basis(3,1),basis(3,0))+i*j*tensor(basis(3,1),basis(3,1))).unit())
                t.append((tensor(basis(3,0),basis(3,0))+j*tensor(basis(3,0),basis(3,1))+i*tensor(basis(3,1),basis(3,0))-i*j*tensor(basis(3,1),basis(3,1))).unit())
                psi.append(t)
                
    psi = np.array(psi)
    
    
    p = Pool(16)
    A = p.map(gf,psi)
    p.close()
    p.join()
    fid = mean(A)
#        print(A)
    print(fid)
    
    return(1-fid)   
def TestCZ():
    global n,RF,RS
    n = 4
    RS = 0
    RF = 1

        
    
    x0 = [np.pi/np.sqrt(2)/g+10,-0.19,0]
    res = minimize(getfid, x0, method="Nelder-Mead",options={'disp': True})
    print(res.x[0],res.x[1],res.x[2])
    
    
    tlist = np.linspace(0,res.x[0],int(res.x[0]))
    w = wave(tlist,tp = res.x[0],para = res.x[1],phi = res.x[2])
    figure();
    plot(tlist,w);title(str(RS)+str(RF))
    return(res.x[0],res.x[1],res.x[2])
            
        
#==============================================================================

    
if __name__ == '__main__':
    
    starttime=time.time()
    
    
    
    
    
    w_q = np.array([ 5.9 , 6.036]) * 2 * np.pi      
    g = 0.0109  * 2 * np.pi
    eta_q = np.array([-0.245 , -0.244]) * 2 * np.pi
    N = 3             # number of cavity fock states
    n= 0
    #==============================================================================

    sm = np.array([tensor(destroy(3),qeye(3)) , tensor(qeye(3),destroy(3))])
    
    E_uc = np.array([tensor(basis(3,2)*basis(3,2).dag(),qeye(3)) , tensor(qeye(3), basis(3,2)*basis(3,2).dag())])
    #用以表征非简谐性的对角线最后一�?非计算能�?
    #E_uc1 = tensor(qeye(3), Qobj([[0,0],[0,1]]))
    
    E_e = np.array([tensor(basis(3,1)*basis(3,1).dag(),qeye(3)),tensor(qeye(3),basis(3,1)*basis(3,1).dag())])
    #激发�?    
    E_g = np.array([tensor(basis(3,0)*basis(3,0).dag(),qeye(3)) , tensor(qeye(3),basis(3,0)*basis(3,0).dag())])
    #基�?    
    sn = np.array([sm[0].dag()*sm[0] , sm[1].dag()*sm[1]])
    
    sx = np.array([sm[0].dag()+sm[0],sm[1].dag()+sm[1]]);
    sxm = np.array([tensor(Qobj([[0,1,0],[1,0,0],[0,0,0]]),qeye(3)) , tensor(qeye(3),Qobj([[0,1,0],[1,0,0],[0,0,0]]))])
    
    
    sy = np.array([1j*(sm[0].dag()-sm[0]) , 1j*(sm[1].dag()-sm[1])]);
    sym = np.array([tensor(Qobj([[0,-1j,0],[1j,0,0],[0,0,0]]),qeye(3)) , tensor(qeye(3),Qobj([[0,-1j,0],[1j,0,0],[0,0,0]]))])
    
    sz = np.array([E_g[0] - E_e[0] , E_g[1] - E_e[1]])
    #==============================================================================
    #==============================================================================
    '''Hamilton'''
    
    HCoupling = g*(sm[0]+sm[0].dag())*(sm[1]+sm[1].dag())
    H_eta = eta_q[0] * E_uc[0] + eta_q[1] * E_uc[1]
    Hq = w_q[0]*sn[0] + w_q[1]*sn[1]
    H0 = Hq + H_eta + HCoupling
    
    
    E = H0.eigenstates()
    Ee = E[0]
    bastate = E[1]
    
    Eq = np.zeros(2)#energy of qubit
    if w_q[0]<w_q[1]:
        Eq[0] = Ee[1]
        Eq[1] = Ee[2]
    else:
        Eq[0] = Ee[2]
        Eq[1] = Ee[1]
    
    
    
    
    
    
#==============================================================================
    psi0=tensor(basis(3,0),basis(3,1))
#    psi0=tensor((basis(3,0)+basis(3,1)).unit(),basis(3,1))
#    psi0=tensor((basis(3,1),basis(3,0)+basis(3,1)).unit())
#    psi0=tensor((basis(3,0)+basis(3,1)).unit(),(basis(3,0)+basis(3,1)).unit())
#==============================================================================
    TG = 1
    
    if TG ==1:
        tp,para,phi = TestCZ()
    else:
        states,tlist = CZgate(psi0)
        n_x0 = [] ; n_y0 = [] ; n_z0 = [];
        n_x1 = [] ; n_y1 = [] ; n_z1 = [];
        for t in range(0,len(tlist)):
#            U0 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(Eq[0])*tlist[t])*basis(3,1)*basis(3,1).dag()
#            U1 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(Eq[1])*tlist[t])*basis(3,1)*basis(3,1).dag()
#            UT = tensor(U0,U1)
            UT = (1j*H0*tlist[t]).expm()
            opx0 = U.dag()*sx[0]*U
            opy0 = U.dag()*sy[0]*U
            opz0 = sz[0]
            opx1 = U.dag()*sx[1]*U
            opy1 = U.dag()*sy[1]*U
            opz1 = sz[1]
            n_x0.append(expect(opx0,result.states[t]))
            n_y0.append(expect(opy0,result.states[t]))
            n_z0.append(expect(opz0,result.states[t]))
            n_x1.append(expect(opx1,result.states[t]))
            n_y1.append(expect(opy1,result.states[t]))
            n_z1.append(expect(opz1,result.states[t]))
            
        fig, axes = plt.subplots(3, 1, figsize=(10,6))
                
        axes[0].plot(tlist, n_x0, label='X');axes[0].set_ylim([-1.05,1.05])
        axes[1].plot(tlist, n_y0, label='Y');axes[1].set_ylim([-1.05,1.05])
        axes[2].plot(tlist, n_z0, label='Z');axes[2].set_ylim([-1.05,1.05])
        
        fig, axes = plt.subplots(3, 1, figsize=(10,6))
                
        axes[0].plot(tlist, n_x1, label='X');axes[0].set_ylim([-1.05,1.05])
        axes[1].plot(tlist, n_y1, label='Y');axes[1].set_ylim([-1.05,1.05])
        axes[2].plot(tlist, n_z1, label='Z');axes[2].set_ylim([-1.05,1.05])
        
        sphere = Bloch()
        sphere.add_points([n_x0 , n_y0 , n_z0])
        sphere.add_vectors([n_x0[-1],n_y0[-1],n_z0[-1]])
        sphere.make_sphere() 
        sphere = Bloch()
        sphere.add_points([n_x1 , n_y1 , n_z1])
        sphere.add_vectors([n_x1[-1],n_y1[-1],n_z1[-1]])
        sphere.make_sphere() 
        plt.show()
        
    
    finishtime=time.time()
    print( 'Time used: ', (finishtime-starttime), 's')