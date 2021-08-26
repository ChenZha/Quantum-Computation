#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Jul 16 20:44:08 2017

@author: chen
"""

"""
观察波形参数对保真度的影响
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


def plotCZ(t,args):
    tp = args['tp']
    delta = args['delta']
    tlist = np.linspace(0,tp,resolution)
    w = interpolate.interp1d(tlist,delta*th,'slinear')
    w = w(t)
    return(w)
    
    

    

#def CZgate(P):
#    #==============================================================================
#    '''Hamilton'''
#    global Ee,H0
#    HCoupling = g*(sm[0]+sm[0].dag())*(sm[1]+sm[1].dag())
#    H_eta = eta_q[0] * E_uc[0] + eta_q[1] * E_uc[1]
#    Hq = w_q[0]*sn[0] + w_q[1]*sn[1]
#    H0 = Hq + H_eta + HCoupling
#    
#
#    E = H0.eigenstates()
#    Ee = E[0]
#    bastate = E[1]
#    
#    
#    global th , resolution
#    resolution = 1024
#    thf = P[0];
#    thi = P[1];
#    lam2 = P[2];
#    lam3 = P[3];
#    
#    
#    ti=np.linspace(0,1,resolution)
#    han2 = np.vectorize(lambda ti:(1-lam3)*(1-cos(2*pi*ti))+lam2*(1-cos(4*pi*ti))+lam3*(1-cos(6*pi*ti)))
#    han2 = han2(ti)
#    thsl=thi+(thf-thi)*han2/max(han2)
#    x = 1/np.tan(thsl);
#    x = x-x[0];
#    
#    tlu = np.cumsum(np.sin(thsl))*ti[1]
#    tlu=tlu-tlu[0]
#    ti=np.linspace(0, tlu[-1], resolution)
#    th=interpolate.interp1d(tlu,thsl,'slinear')
#    th = th(ti)
#    th=1/np.tan(th)
#    th=th-th[0]
#    th=th/min(th)
#    
#    
#    
#    Hd0 = [sn[0],CZ0]
##    Hd1 = [sn[1],CZ1]
##    H = [H0,Hd0,Hd1]
#    H = [H0,Hd0]
#    
#    
#    def opt(T):
#        tp = T[0]
#        delta = T[1]
#        args = {'tp':tp,'delta':delta}
#    
#    #==============================================================================
#        '''evolution'''
#        
#        options=Options()
#        options.atol=1e-11
#        options.rtol=1e-9
#        options.first_step=0.01
#        options.num_cpus= 4
#        options.nsteps=1e6
#        options.gui='True'
#        options.ntraj=1000
#        options.rhs_reuse=False
#        
#    
#        psi0 = (bastate[1]-bastate[4]).unit()
#    
#        
#        
#    
#    
#    
#    
#        tlist = np.linspace(0,tp,tp+1)
#    
#        result = mesolve(H,psi0,tlist,[],[],args = args,options = options)
#        
#        
#        
#        '''
#        fidelity
#        '''
#        U0 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(Ee[1]-Ee[0])*tlist[-1])*basis(3,1)*basis(3,1).dag()
#        U1 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(Ee[2]-Ee[0])*tlist[-1])*basis(3,1)*basis(3,1).dag()
#        UT = tensor(U0,U1)
#    #    UT = (1j*H0*tlist[-1]).expm()
#    
#    
#        target = (bastate[1]+bastate[4]).unit()
#
#    
#        fid = fidelity(UT*result.states[-1]*result.states[-1].dag()*UT.dag(),target)
#        
#        return(1-fid)
#
#    x0 = [np.pi/np.sqrt(2)/g+15,(w_q[1]-w_q[0]+eta_q[1])]
#    result = minimize(opt, x0, method="Nelder-Mead",)
#    fid = 1-opt([result.x[0],result.x[1]])
#    print([fid,result.x[0],result.x[1]])
#    
#    return([fid,[result.x[0],result.x[1]]])

    
    

    #==============================================================================
   
    
#==============================================================================
def CZgate(P):
    
    #==============================================================================
    '''Hamilton'''
    global Ee,H0
    HCoupling = g*(sm[0]+sm[0].dag())*(sm[1]+sm[1].dag())
    H_eta = eta_q[0] * E_uc[0] + eta_q[1] * E_uc[1]
    Hq = w_q[0]*sn[0] + w_q[1]*sn[1]
    H0 = Hq + H_eta + HCoupling
    

    E = H0.eigenstates()
    Ee = E[0]
    bastate = E[1]
    
    
    global th , resolution
    resolution = 1024
    thf = P[0];
    thi = P[1];
    lam2 = P[2];
    lam3 = P[3];
    
    
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
    
    
    
    Hd0 = [sn[0],CZ0]
#    Hd1 = [sn[1],CZ1]
#    H = [H0,Hd0,Hd1]
    H = [H0,Hd0]
    
    

    tp = 46
    delta = 1.722
    args = {'tp':tp,'delta':delta}

#==============================================================================
    '''evolution'''
    
    options=Options()
    options.atol=1e-8
    options.rtol=1e-6
    options.first_step=0.01
    options.num_cpus= 4
    options.nsteps=1e6
    options.gui='True'
    options.ntraj=1000
    options.rhs_reuse=False
    

    psi0 = (bastate[1]-bastate[4]).unit()

    
    




    tlist = np.linspace(0,tp,tp+1)

    result = mesolve(H,psi0,tlist,[],[],args = args,options = options)
    
    
    
    '''
    fidelity
    '''
    U0 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(Ee[1]-Ee[0])*tlist[-1])*basis(3,1)*basis(3,1).dag()
    U1 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(Ee[2]-Ee[0])*tlist[-1])*basis(3,1)*basis(3,1).dag()
    UT = tensor(U0,U1)
#    UT = (1j*H0*tlist[-1]).expm()


    target = (bastate[1]+bastate[4]).unit()


    fid = fidelity(UT*result.states[-1]*result.states[-1].dag()*UT.dag(),target)
    
    return(fid)

#==============================================================================
    
    
    
    
def test(P):
    a = P[0]
    b = P[1]
    return(a+b)
    
    
    
    
    
    
    
    
if __name__=='__main__':
    
    starttime  = time.time()
    
    
    
    
    w_q = np.array([ 4.73 , 5.22]) * 2 * np.pi      
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
    
#    x0 = [np.pi/np.sqrt(2)/g+15,(w_q[1]-w_q[0]+eta_q[1])]
#    result = minimize(CZgate, x0, method="Nelder-Mead",options={'disp': True})
#    print(result.x[0],result.x[1])

#==============================================================================
#    t = np.arange(35,150,1)
#    Am = np.arange(1.014,2.054,0.006)
#    z=np.zeros(shape=(len(t),len(Am)))
#    
#    p = Pool(45)
#    
#    for i in range(0,len(t)):
#        P = [[t[i],Am[j]] for j in range(0,len(Am))]
#        z[i] = p.map(CZgate,P)
#        roundtime = time.time()
#        print(t[i],roundtime-starttime)
#    p.close()
#    p.join()
#    
#    
#    figure()
#    pcolormesh(Am,t,z)
#    xlabel('Am')
#    ylabel('t')
#    plt.colorbar()
#    
#    z = np.array(z)
#    mz = np.max(z)
#    indexz = np.where(z == mz)
#    print(mz,t[indexz[0]],Am[indexz[1]])
#    np.save('No_CrossTalk_1_0+1',z)    
#==============================================================================
    thf = 0.55*np.pi/2#np.linspace(0.8*0.55*np.pi/2,1.3*0.55*np.pi/2,51);
    thi = 0.05#np.linspace(0.8*0.05,1.3*0.05,51);
    lam2 = -0.18#np.linspace(-0.18*1.3,-0.18*0.5,81);
    lam3 = np.linspace(0.8*0.04,1.6*0.04,81);
    
    z = np.zeros(shape = (1,len(lam3)))

    
    p = Pool(8)
    
    P = [[thf,thi,lam2,lam3[j]] for j in range(0,len(lam3))]
    z = p.map(CZgate,P)
    p.close()
    p.join()
    
#    z =  np.array([x[0] for x in A])
#    para = np.array([x[1] for x in A])


    figure()
    plot(lam3,z)
    xlabel('lam3_46')
    plt.savefig('lam3_46.png')


    z = np.array(z)
    mz = np.max(z)
    indexz = np.where(z == mz)
#    print(mz,lam3[indexz],para[indexz])
    print(mz,lam3[indexz])
    np.save('lam3_46',z)

    





    endtime  = time.time()
    
    print('used time:',endtime-starttime,'s')
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
                
