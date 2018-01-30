#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Sep 21 15:20:25 2017

@author: chen
"""
'''
q1~q2~q3（q1，q2间施加CZ门）
CZ fidelity changes with different detuning of q3 from others,
and the 0 or 1's effect of q3  on CZ fidelity
'''


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

def findstate(S,state):
    l = None
    e0 = eval(state[0])
    e1 = eval(state[1])
    e2 = eval(state[2])
    for i in range(20):
        s0 = ptrace(S[i],0)[e0][0][e0]
        s1 = ptrace(S[i],1)[e1][0][e1]
        s2 = ptrace(S[i],2)[e2][0][e2]
        if abs(s0)>0.5 and abs(s1)>0.5 and abs(s2)>0.5:
            l = i
    if l == None:
        print('No state')
    else:
        return(l)
        
        
        
    
    

    

def CZgate(P):
    #==============================================================================
    '''Hamilton'''
    global Ee,H0
    HCoupling = g[0]*(sm[0]+sm[0].dag())*(sm[1]+sm[1].dag())+g[1]*(sm[1]+sm[1].dag())*(sm[2]+sm[2].dag())
    H_eta = eta_q[0] * E_uc[0] + eta_q[1] * E_uc[1]+eta_q[2] * E_uc[2]
    Hq = w_q[0]*sn[0] + w_q[1]*sn[1] + w_q[2]*sn[2]
    H0 = Hq + H_eta + HCoupling
        
        
    E = H0.eigenstates()
    Ee = E[0]
    bastate = E[1]
    
    tp = P[0]
    delta = P[1]
    
    Hd0 = [sn[1],CZ0]

    H = [H0,Hd0]
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
    
    S010 = bastate[findstate(bastate,'010')]
    S011 = bastate[findstate(bastate,'011')]
    S110 = bastate[findstate(bastate,'110')]
    S111 = bastate[findstate(bastate,'111')]
    psi0 = (S010+S110).unit()

    tlist = np.linspace(0,tp,tp+1)
    result = mesolve(H,psi0,tlist,[],[],args = args,options = options)


#==============================================================================


#==============================================================================
    
    '''
    fidelity
    '''
    rank = np.array(sorted(range(3), key=lambda k: w_q[k]))
    U0 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(Ee[np.where(rank==0)[0][0]+1]-Ee[0])*tlist[-1])*basis(3,1)*basis(3,1).dag()
    U1 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(Ee[np.where(rank==1)[0][0]+1]-Ee[0])*tlist[-1])*basis(3,1)*basis(3,1).dag()
    U2 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(Ee[np.where(rank==2)[0][0]+1]-Ee[0])*tlist[-1])*basis(3,1)*basis(3,1).dag()
    UT = tensor(U0,U1,U2)
#    UT = (1j*H0*tlist[-1]).expm()
    ang0 = np.angle((S010.dag()*UT*result.states[-1])[0])[0][0]/np.pi*180
    if ang0<0:
        ang0 = ang0+360
    ang1 = np.angle((S110.dag()*UT*result.states[-1])[0])[0][0]/np.pi*180
    if ang1<0:
        ang1 = ang1+360
    
    angle0 = abs(ang1-ang0)
    
    

    target = (S010+S110).unit()
    fid0 = fidelity(UT*result.states[-1]*result.states[-1].dag()*UT.dag(),target)



    psi0 = (S011+S111).unit()
    tlist = np.linspace(0,tp,tp+1)
    result = mesolve(H,psi0,tlist,[],[],args = args,options = options)
    target = (S011+S111).unit()
    U0 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(Ee[np.where(rank==0)[0][0]+1]-Ee[0])*tlist[-1])*basis(3,1)*basis(3,1).dag()
    U1 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(Ee[np.where(rank==1)[0][0]+1]-Ee[0])*tlist[-1])*basis(3,1)*basis(3,1).dag()
    U2 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(Ee[np.where(rank==2)[0][0]+1]-Ee[0])*tlist[-1])*basis(3,1)*basis(3,1).dag()
    UT = tensor(U0,U1,U2)
    ang0 = np.angle((S011.dag()*UT*result.states[-1])[0])[0][0]/np.pi*180
    if ang0<0:
        ang0 = ang0+360
    ang1 = np.angle((S111.dag()*UT*result.states[-1])[0])[0][0]/np.pi*180
    if ang1<0:
        ang1 = ang1+360
    
    angle1 = abs(ang1-ang0)
    fid1 = fidelity(UT*result.states[-1]*result.states[-1].dag()*UT.dag(),target)

    diffid = fid0-fid1
    difangle = angle0-angle1
    print('fidelity = ',fid0 , fid1 , diffid , angle0 , angle1 , difangle , w_q[2]/2/np.pi)
    
    

    #==============================================================================
    return([fid0,fid1,diffid, angle0 , angle1 , difangle ])
    
    
    
    
    
    
def test(P):
    a = P[0]
    b = P[1]
    return(a+b)
    
def detuning(a):
    w_q[2] = a
    A = CZgate([63.200007 , -1.3812304])
    return(A)
    
    
    
    
    
    
if __name__=='__main__':
    
    starttime  = time.time()
    
    
    global th,w_q
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
    
    w_q = np.array([ 4.73 , 5.22 , 3.38]) * 2 * np.pi      
    g = np.array([ 0.0125 , 0.0125]) * 2 * np.pi
    eta_q = np.array([-0.25 , -0.25 , -0.25]) * 2 * np.pi
    n= 0
    
    #==============================================================================
    sm = np.array([tensor(destroy(3),qeye(3),qeye(3)) , tensor(qeye(3),destroy(3),qeye(3)) , tensor(qeye(3),qeye(3),destroy(3))])
    
    E_uc = np.array([tensor(basis(3,2)*basis(3,2).dag(),qeye(3),qeye(3)) , tensor(qeye(3),basis(3,2)*basis(3,2).dag(),qeye(3)) , tensor(qeye(3),qeye(3),basis(3,2)*basis(3,2).dag())])
    
    E_e = np.array([tensor(basis(3,1)*basis(3,1).dag(),qeye(3),qeye(3)) , tensor(qeye(3),basis(3,1)*basis(3,1).dag(),qeye(3)) , tensor(qeye(3),qeye(3),basis(3,1)*basis(3,1).dag())])

    
    E_g = np.array([tensor(basis(3,0)*basis(3,0).dag(),qeye(3),qeye(3)) , tensor(qeye(3),basis(3,0)*basis(3,0).dag(),qeye(3)) , tensor(qeye(3),qeye(3),basis(3,0)*basis(3,0).dag())])

      
    sn = np.array([sm[0].dag()*sm[0] , sm[1].dag()*sm[1],sm[2].dag()*sm[2]])
    
    sx = np.array([sm[0].dag()+sm[0],sm[1].dag()+sm[1],sm[2].dag()+sm[2]]);
#    sxm = np.array([tensor(Qobj([[0,1,0],[1,0,0],[0,0,0]]),qeye(3)) , tensor(qeye(3),Qobj([[0,1,0],[1,0,0],[0,0,0]]))])
    
    
    sy = np.array([1j*(sm[0].dag()-sm[0]) , 1j*(sm[1].dag()-sm[1]) , 1j*(sm[2].dag()-sm[2])]);
#    sym = np.array([tensor(Qobj([[0,-1j,0],[1j,0,0],[0,0,0]]),qeye(3)) , tensor(qeye(3),Qobj([[0,-1j,0],[1j,0,0],[0,0,0]]))])
    
    sz = np.array([E_g[0] - E_e[0] , E_g[1] - E_e[1] , E_g[2] - E_e[2]])
    
    
    
    
#    E = CZgate([38.68574872,-4.74773091])
    
#    x0 = [2*np.pi/np.sqrt(2)/g[0],(w_q[0]-w_q[1]-eta_q[1])]
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
#    t = 46
#    Am = np.linspace(-5*1.72199,1.3*1.72199,32)
#    z = np.zeros(shape = (1,len(Am)))
#
##    t = np.linspace(0.9*98,1.1*98,201)
##    Am = 1.272
##    z = np.zeros(shape = (1,len(t)))
#    
#    p = Pool(2)
#    
#    P = [[t,Am[j]] for j in range(0,len(Am))]
##    P = [[t[j],Am] for j in range(0,len(t))]
#    z = p.map(CZgate,P)
#    p.close()
#    p.join()
#
#
#    
##    plot(t,z)
##    xlabel('t')
#
#    z = np.array(z)
#    mz = np.max(z)
#    indexz = np.where(z == mz)
#    print(mz,Am[indexz])
#    np.save('Am',z)
##    print(mz,t[indexz])
##    np.save('t',z)  
#    
#    figure()
#    plot((Am-Am[indexz])/2/np.pi,z)
#    xlabel('detuning')
#    A = np.linspace(3.97,4.97,11)*2*np.pi
#    fid = []
#    for a in A:
#        w_q[0] = a
#        P = np.array([98,0])
#        f = CZgate(P)
#        fid.append(f)
#    
#    figure()
#    plot((A - 4.97*2*np.pi)/2/np.pi,fid)

#    A = CZgate([63.200007 , -1.3812304])
    w = np.linspace(3.73,4.728,201)*2*np.pi
    p = Pool(41)
    
    
    A = p.map(detuning,w)
    p.close()
    p.join()
    
    fid0 = [x[0] for x in A]
    fid1 = [x[1] for x in A]
    diffid = [x[2] for x in A]
    angle0 = [x[3] for x in A]
    angle1 = [x[4] for x in A]
    difangle = [x[5] for x in A]
    
    
    figure()
    plot((w - 4.73*2*np.pi)/2/np.pi,fid0)
    plot((w - 4.73*2*np.pi)/2/np.pi,fid1);title('Fidelity');xlabel('detuning');ylabel('fidelity')
    legend()
    figure()
    plot((w - 4.73*2*np.pi)/2/np.pi,diffid);xlabel('detuning');ylabel('fid0-fid1')
    figure()
    plot((w - 4.73*2*np.pi)/2/np.pi,angle0);
    plot((w - 4.73*2*np.pi)/2/np.pi,angle1);title('Angle');xlabel('detuning');ylabel('angle')
    figure()
    plot((w - 4.73*2*np.pi)/2/np.pi,difangle);xlabel('detuning');ylabel('ang0-ang1')

    np.save('fid0',fid0)
    np.save('fid1',fid1)
    np.save('diffid',diffid)
#    


    endtime  = time.time()
    
    print('used time:',endtime-starttime,'s')
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
                
