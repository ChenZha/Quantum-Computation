#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Oct  2 14:27:44 2017

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
from DE_improvement import *



def wave(t):
    tp = 150
    delta = 0.02*2*np.pi
    tlist = np.linspace(0,tp,resolution)
    g = interpolate.interp1d(tlist,delta*th,'slinear')
    g = g(t)
            
    return(g)

def g_pulse(t,args):
    tp = args['tp']
    delta = args['delta']
    tlist = np.linspace(0,tp,resolution)
    g = interpolate.interp1d(tlist,delta*th,'slinear')
    if t<=tp and t>=0:
        g = g(t)
    else:
        g = 0
            
    return(g)



def initial_wave():
    global resolution

    thf = 0.55*pi/2;
    thi = 0.05;
    lam2 = -0.18;
    lam3 = -0.04;
    resolution = 1024;
    
    '''
    Hx
    '''
    ti=np.linspace(0,1,resolution)
    han2 = np.vectorize(lambda ti:(1-lam3)*(1-np.cos(2*np.pi*ti))+lam2*(1-np.cos(4*np.pi*ti))+lam3*(1-np.cos(6*np.pi*ti)))
    han2 = han2(ti)
    thsl=thi+(thf-thi)*han2/np.max(han2)   
    tlu = np.cumsum(np.cos(thsl))*ti[1]
    tlu=tlu-tlu[0]
    ti=np.linspace(0, tlu[-1], resolution)
    th=interpolate.interp1d(tlu,thsl,'slinear')
    th = th(ti)
    th=np.tan(th)
    th=th-th[0]
    th=th/np.max(th)

    return(th)
def getfid(T):
    psi = T[0]
    target = T[1]
    cops = T[2]
    output = mesolve(H,psi,tlist,[],cops,args = args,options = options)
    
    U1 = basis(N,0)*basis(N,0).dag()+np.exp(1j*(E[l10]-E[l00])*tlist[-1])*basis(N,1)*basis(N,1).dag()
    U2 = basis(N,0)*basis(N,0).dag()+np.exp(1j*(E[l01]-E[l00])*tlist[-1])*basis(N,1)*basis(N,1).dag()
    UT = tensor(U1,U2)
    if output.states[-1].isket:
        fid = fidelity(UT*output.states[-1],target)
        return([fid,UT*output.states[-1]])
    else:
        fid = fidelity(UT*output.states[-1]*UT.dag(),target)
        return([fid,UT*output.states[-1]*UT.dag()])
    
    
    
    
def findstate(S,state):
    l = None
    e0 = eval(state[0])
    e1 = eval(state[1])
    for i in range(9):
        s0 = ptrace(S[i],0)[e0][0][e0]
        s1 = ptrace(S[i],1)[e1][0][e1]
        if abs(s0)>=0.5 and abs(s1)>=0.5 :
            l = i
    if l == None:
        print('No state')
    else:
        return(l)
def CZgate(P):
    
    global H0,E,S,l11,l10,l01,l00

    delta = P[0]
    xita0 = P[1]
    xita1 = P[2]
    tp = 30
    fluc = 0.01
    
    
    H0= (wq[0]) * sn[0] + (wq[1]) * sn[1] + eta_q[0]*E_uc[0] + eta_q[1]*E_uc[1]
    [E,S] = H0.eigenstates()
    l11 = findstate(S,'11');l10 = findstate(S,'10');l01 = findstate(S,'01');l00 = findstate(S,'00');


    global H,tlist,args,options
    
    Hg = [(sm[0]+sm[0].dag())*(sm[1]+sm[1].dag()),g_pulse]
    
    H = [H0,Hg]


    args = {'tp':tp ,'delta':delta }

    tlist = np.linspace(0,tp,2*tp+1)

    options=Options()
    options.atol=1e-8
    options.rtol=1e-6
    options.first_step=0.01
    options.num_cpus=8
    options.nsteps=1e6
    options.gui='True'
    options.ntraj=1000
    options.rhs_reuse=True

    cops = []

    T = []
    T.append([tensor(basis(3,0),basis(3,0)),tensor(basis(3,0),basis(3,0)),cops])
    T.append([tensor(basis(3,0),basis(3,1)),tensor(basis(3,0),basis(3,1)),cops])
    T.append([tensor(basis(3,1),basis(3,0)),tensor(basis(3,1),basis(3,0)),cops])
    T.append([tensor(basis(3,1),basis(3,1)),-tensor(basis(3,1),basis(3,1)),cops])


    fid = []
    outputstate = []
    
    


    p = Pool(4)
   
    A = p.map(getfid,T)
    fid = [x[0] for x in A]
    outputstate = [x[1] for x in A]
    fid = np.array(fid)
    outputstate = np.array(outputstate)

        
    p.close()
    p.join()

#    for phi in T:
#        A = getfid(phi)
#        fid.append(A[0])
#        outputstate.append(A[1])
#    fid = np.array(fid)
#    outputstate = np.array(outputstate)

    gc.collect()


    process = np.column_stack([outputstate[i].data.toarray() for i in range(len(outputstate))])[(0,1,3,4),:]
    targetprocess = np.array([[1,0,0,0],[0,1,0,0],[0,0,1,0],[0,0,0,-1]])
    compensation = np.array([[1,0,0,0],[0,np.exp(1j*xita1),0,0],[0,0,np.exp(1j*xita0),0],[0,0,0,np.exp(1j*(xita0+xita1))]])
    process = np.dot(compensation,process)
    Error = np.dot(np.conjugate(np.transpose(targetprocess)),process)
    angle = np.angle(Error[0][0])
    Error = Error*np.exp(-1j*angle)#global phase
   
    Ufidelity = np.abs(np.trace(Error))/4


    gc.collect()
    
    
#    psi = [(tensor(basis(3,0),basis(3,0))+tensor(basis(3,1),basis(3,1))),(tensor(basis(3,0),basis(3,0))+1j*tensor(basis(3,0),basis(3,1))+tensor(basis(3,1),basis(3,1))-1j*tensor(basis(3,1),basis(3,0))).unit()]
#    fid,leakage,outputstate = getfid(psi)
    # print(tp,omega/2/np.pi,(E[l10]-E[l01])/2/np.pi,g/2/np.pi,np.mean(fid),Ufidelity)

#    Operator_View(process,'U_Simulation')


    print(P[0]/2/np.pi,P[1]/np.pi*180,P[2]/np.pi*180,np.mean(fid),Ufidelity)
    return(-Ufidelity)






if __name__=='__main__':
    starttime=time.time()
    

    
    global H0,E,S,th
    
    N = 3
    wq= np.array([5.00 , 4.78 ]) * 2 * np.pi
    eta_q=  np.array([-0.250 , -0.250]) * 2 * np.pi
    
    
    sm = np.array([tensor(destroy(3),qeye(3)) , tensor(qeye(3),destroy(3))])
    E_uc = np.array([tensor(basis(3,2)*basis(3,2).dag(),qeye(3)) , tensor(qeye(3), basis(3,2)*basis(3,2).dag())])
    E_e = np.array([tensor(basis(3,1)*basis(3,1).dag(),qeye(3)),tensor(qeye(3),basis(3,1)*basis(3,1).dag())])
    E_g = np.array([tensor(basis(3,0)*basis(3,0).dag(),qeye(3)) , tensor(qeye(3),basis(3,0)*basis(3,0).dag())])
    sn = np.array([sm[0].dag()*sm[0] , sm[1].dag()*sm[1]])
    sx = np.array([sm[0].dag()+sm[0],sm[1].dag()+sm[1]]);
    sy = np.array([1j*(sm[0].dag()-sm[0]) , 1j*(sm[1].dag()-sm[1])]);
    sz = np.array([E_g[0] - E_e[0] , E_g[1] - E_e[1]])
    
    

    th = initial_wave()
    

    
    

#    fid = CZgate([0.    ,     -4.15551826 , -0.15315065,-1.15565238])
#    x_l = np.array([0*2*np.pi , -np.pi , -np.pi])#delta0,delta1,xita0,xita1
#    x_u = np.array([0.1*2*np.pi ,  np.pi , np.pi])
#    de(CZgate,n = 3,m_size = 18,f = 0.9 , cr = 0.5 ,S = 1 , iterate_time = 300,x_l = x_l,x_u = x_u,inputfile = None)
    
    x0 = [0.055*2*np.pi,   0 , 0]
    result = minimize(CZgate , x0 , method="Nelder-Mead",options={'disp': True})
    print(result)


    endtime  = time.time()
    
    print('used time:',endtime-starttime,'s')

        
        
        