#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Jul 16 20:44:08 2017

@author: chen
"""

import time 
import csv
import matplotlib.pyplot as plt
import numpy as np
from pylab import *
from qutip import *
from scipy.optimize import *
from scipy.integrate import *
from scipy import interpolate 
from mpl_toolkits.mplot3d import Axes3D
from scipy.special import *
from multiprocessing import Pool
from decimal import *
from math import *
import gc 
import sys


def CZ0(t,args):
    tp = args['tp']
    delta = args['delta']
    tlist = np.linspace(0,tp,resolution)
#    print(t,tlist[-1])
    w = interpolate.interp1d(tlist,delta*th,'slinear')
    if t<=tp and t>=0:
        w = w(t)
    else:
        w = 0
            
    return(w)
def CZ1(t,args):
    tp = args['tp']
    delta = 0.1*args['delta']
    tlist = np.linspace(0,tp,resolution)
#    print(t,tlist[-1])
    w = interpolate.interp1d(tlist,delta*th,'slinear')
    if t<=tp and t>=0:
        w = w(t)
    else:
        w = 0
            
    return(w)
    
def evolution(psi):
    psi0 = psi[0]
    target = psi[1]
#    print(fx,psi0,target)
#==============================================================================
    
    
    tp = fx[0]
    delta = fx[1]
    
    Hd0 = [sn[0],CZ0]
    Hd1 = [sn[1],CZ1]
    H = [H0,Hd0,Hd1]
    #    H = [H0.Hd0]
    args = {'tp':tp,'delta':delta}
#==============================================================================
    
    options=Options()
    options.atol=1e-11
    options.rtol=1e-9
    options.first_step=0.01
    options.num_cpus= 4
    options.nsteps=1e6
    options.gui='True'
    options.ntraj=1000
    options.rhs_reuse=False
    
    tlist = np.linspace(0,tp,tp+1)
    result = mesolve(H,psi0,tlist,[],[],args = args,options = options)
    
#    U0 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(Ee[2]-Ee[0])*tlist[-1])*basis(3,1)*basis(3,1).dag()
#    U1 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(Ee[1]-Ee[0])*tlist[-1])*basis(3,1)*basis(3,1).dag()
#    UT = tensor(U0,U1)
    UT = (1j*H0*tlist[-1]).expm()
    
#    print(target)
#    print(psi0)
    fid = fidelity(UT*result.states[-1]*result.states[-1].dag()*UT.dag(),target)
    
#    print(fid)
    
    

    return(fid)

def CZgate(P):
    #==============================================================================
    '''Hamilton'''
    global fx
    fx = P
#    print(fx)
    global Ee,H0
    HCoupling = g*(sm[0]+sm[0].dag())*(sm[1]+sm[1].dag())
    H_eta = eta_q[0] * E_uc[0] + eta_q[1] * E_uc[1]
    Hq = w_q[0]*sn[0] + w_q[1]*sn[1]
    H0 = Hq + H_eta + HCoupling
    
    E = H0.eigenstates()
    Ee = E[0]
    bastate = E[1]
    
    #==============================================================================
    '''evolution'''
    

    
#    psi0 = (bastate[0]+bastate[2]+bastate[3]-bastate[9]).unit()
#    psi0 = (bastate[2]-bastate[4]).unit()
#    psi0 = bastate[0]
    
    
#    psi0 = tensor( (basis(3,0)+basis(3,1)).unit() , (basis(3,0)+basis(3,1)).unit())
#    psi0 = tensor( (basis(3,1)).unit() , (basis(3,0)+basis(3,1)).unit())
#    psi0 = tensor( (basis(3,0)+basis(3,1)).unit() , (basis(3,0)).unit())
#    psi0 = tensor( (basis(3,0)).unit() , (basis(3,1)).unit())


    psi = []
    
    psi.append([(bastate[0]).unit(),(bastate[0]).unit()])
    psi.append([(bastate[1]).unit(),(bastate[1]).unit()])
    psi.append([(bastate[2]).unit(),(bastate[2]).unit()])
    psi.append([(bastate[4]).unit(),-(bastate[4]).unit()])
    psi.append([(bastate[0]-bastate[1]).unit(),(bastate[0]-bastate[1]).unit()])
    psi.append([(bastate[0]-1j*bastate[1]).unit(),(bastate[0]-1j*bastate[1]).unit()])
    psi.append([(bastate[2]-bastate[4]).unit(),(bastate[2]+bastate[4]).unit()])
    psi.append([(bastate[2]-1j*bastate[4]).unit(),(bastate[2]+1j*bastate[4]).unit()])



    


    
    
    psi = np.array(psi)
    
    p = Pool(16)
    A = p.map(evolution,psi)
    p.close()
    p.join()
    fid = mean(A)
    print(fid)
    print(A)


#==============================================================================
#    
#    '''
#    fidelity
#    '''
#    U0 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(Ee[2]-Ee[0])*tlist[-1])*basis(3,1)*basis(3,1).dag()
#    U1 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(Ee[1]-Ee[0])*tlist[-1])*basis(3,1)*basis(3,1).dag()
#    UT = tensor(U0,U1)
#    
#    
#    target = (bastate[2]+bastate[4]).unit()
##    target = tensor( (basis(3,1)).unit() , (basis(3,0)-basis(3,1)).unit())
#    
#    fid = fidelity(UT*result.states[-1]*result.states[-1].dag()*UT.dag(),target)
#    print('fidelity = ',fid,P)
    #==============================================================================
    return(1-fid)
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
if __name__=='__main__':
    
    starttime  = time.time()
    
    
    global th
    resolution = 1024
    thf = 0.55*pi/2;
    thi = 0.05;
    lam2 = -0.18;
    lam3 = 0.04;
    resolution = 1024;
    
    ti=np.linspace(0,1,resolution)
    han2 = np.vectorize(lambda ti:(1-lam3)*(1-cos(2*pi*ti))+lam2*(1-cos(4*pi*ti))+lam3*(1-cos(6*pi*ti)))
    han2 = han2(ti)
    thsl=thi+(thf-thi)*han2/max(han2)
    x = 1/np.tan(thsl);
    x = x-x[0];
    
    tlu = np.cumsum(np.sin(thsl))*ti[1]
    tlu=tlu-tlu[0]
    ti=np.linspace(0, tlu[-1], resolution)
    th=interpolate.interp1d(tlu,thsl,'slinear')
    th = th(ti)
    th=1/np.tan(th)
    th=th-th[0]
    th=th/min(th)
    
    w_q = np.array([ 5.22 , 4.73]) * 2 * np.pi      
    g = 0.0125 * 2 * np.pi
    eta_q = np.array([-0.25 , -0.25]) * 2 * np.pi
    n= 0
    
    #==============================================================================
    sm = np.array([tensor(destroy(3),qeye(3)) , tensor(qeye(3),destroy(3))])
    
    E_uc = np.array([tensor(basis(3,2)*basis(3,2).dag(),qeye(3)) , tensor(qeye(3), basis(3,2)*basis(3,2).dag())])
    
    E_e = np.array([tensor(basis(3,1)*basis(3,1).dag(),qeye(3)),tensor(qeye(3),basis(3,1)*basis(3,1).dag())])
    
    E_g = np.array([tensor(basis(3,0)*basis(3,0).dag(),qeye(3)) , tensor(qeye(3),basis(3,0)*basis(3,0).dag())])
      
    sn = np.array([sm[0].dag()*sm[0] , sm[1].dag()*sm[1]])
    
    sx = np.array([sm[0].dag()+sm[0],sm[1].dag()+sm[1]]);
    sxm = np.array([tensor(Qobj([[0,1,0],[1,0,0],[0,0,0]]),qeye(3)) , tensor(qeye(3),Qobj([[0,1,0],[1,0,0],[0,0,0]]))])
    
    
    sy = np.array([1j*(sm[0].dag()-sm[0]) , 1j*(sm[1].dag()-sm[1])]);
    sym = np.array([tensor(Qobj([[0,-1j,0],[1j,0,0],[0,0,0]]),qeye(3)) , tensor(qeye(3),Qobj([[0,-1j,0],[1j,0,0],[0,0,0]]))])
    
    sz = np.array([E_g[0] - E_e[0] , E_g[1] - E_e[1]])
    
    
    
    
#    E = CZgate([38.68574872,-4.74773091])
    
    x0 = [np.pi/np.sqrt(2)/g+15,(w_q[1]-w_q[0]+eta_q[1])]
    result = minimize(CZgate, x0, method="Nelder-Mead",options={'disp': True})
    print(result.x[0],result.x[1])








    endtime  = time.time()
    
    print('used time:',endtime-starttime,'s')
                