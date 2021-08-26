#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Oct  2 14:27:44 2017

@author: chen
"""

import time 
import matplotlib.pyplot as plt
import numpy as np
from pylab import *
from qutip import *
from scipy.optimize import *
from scipy.integrate import *
from scipy import interpolate 
from scipy.special import *
from multiprocessing import Pool
import gc 

def Z_wave(t):
    tp = 100
    omega = 0.16*2*np.pi
    delta = 0.004*2*np.pi
    tlist = np.linspace(0,tp,1024)
    wg = interpolate.interp1d(tlist,delta*th,'slinear')#g
    figure();plot(tlist,wg(tlist))
    x = np.linspace(0,2.4048,1024)
    y = g*jv(0,x)
    y = (y-np.min(y))/(np.max(y)-np.min(y))
    f = interpolate.interp1d(y,x,'slinear')
        
    if t<=0 or t>=tp:
        A = 2.4048*omega
    else:
        A = f(wg(t))*omega
    return(A)

def optA(A):
    '''
    the minimum of Rabi
    '''
    
    tlist= np.linspace(0,1000,1001)
    
    

    A = A
#    print(A/2/np.pi,omega/2/np.pi,A/omega)
    H=[H0,[sm0.dag()*sm0 , Z_wave]]
    
    psi0=tensor(basis(N,1),basis(N,0))
    
    options=Options()
    args = {'A':A , 'omega':omega}
    output = mesolve(H,psi0,tlist,[],[],args = args,options = options)
    
    exp = [expect(sm0.dag() * sm0,output.states) , expect(sm1.dag() * sm1,output.states)]
    fig, axes = plt.subplots(2, 1, figsize=(10,8))
    labels=['Q0','Q1']
    for ii in range(0,2):   
        n_q = exp[ii]
        
        axes[ii].plot(tlist, n_q, label=labels[ii])
        
        axes[ii].set_ylim([-0.1,1.1])
        axes[ii].legend(loc=0)
        axes[ii].set_xlabel('Time')
        axes[ii].set_ylabel('P')
    
    Qmin = min(exp[0])
    Qmax = max(exp[0])
    
    print(A/2/np.pi , g*jn(0,A/omega)/2/np.pi,Qmax-Qmin)
    return(Qmax-Qmin)

def evolve():
    '''
    Rabi evolve
    '''
    
    tlist= np.linspace(0,1000,1001)
    
    


#    print(A/2/np.pi,omega/2/np.pi,A/omega)
    H=[H0,[sm0.dag()*sm0 , Z_wave]]
    
    psi0=tensor(basis(N,1),basis(N,0))
    
    options=Options()
    args = {'A':A , 'omega':omega}
    output = mesolve(H,psi0,tlist,[],[],args = args,options = options)
    
    exp = [expect(sm0.dag() * sm0,output.states) , expect(sm1.dag() * sm1,output.states)]
    leakage = [expect(E_uc0,output.states) , expect(E_uc1,output.states)]
    fig, axes = plt.subplots(2, 1, figsize=(10,8))
    labels=['Q0','Q1']
    for ii in range(0,2):   
        n_q = exp[ii]
        
        axes[ii].plot(tlist, n_q, label=labels[ii])
        
        axes[ii].set_ylim([-0.1,1.1])
        axes[ii].legend(loc=0)
        axes[ii].set_xlabel('Time')
        axes[ii].set_ylabel('P')
        
    fig, axes = plt.subplots(2, 1, figsize=(10,8))
    labels=['L0','L1']
    for ii in range(0,2):   
        n_q = leakage[ii]
        
        axes[ii].plot(tlist, n_q, label=labels[ii])
        
        axes[ii].set_ylim([-0.1,1.1])
        axes[ii].legend(loc=0)
        axes[ii].set_xlabel('Time')
        axes[ii].set_ylabel('P')
    

    ang = np.angle((psi0.dag()*output.states[-1])[0])[0][0]/np.pi*180
    if ang<0:
        ang = ang1+360
    print(A/2/np.pi , g*jn(0,A/omega)/2/np.pi,ang)
    return(ang)

def getangle(psi0):
    '''
    the angle of state psi0
    '''
    tlist= np.linspace(0,t,t+1)
    
#    print(A/2/np.pi,omega/2/np.pi,A/omega)
    H=[H0,[sm0.dag()*sm0 , Z_wave]]
    
    psi0=psi0
    
    options=Options()
    args = {'A':A , 'omega':omega}
    output = mesolve(H,psi0,tlist,[],[],args = args,options = options)
    
    exp = [expect(sm0.dag() * sm0,output.states) , expect(sm1.dag() * sm1,output.states)]
    leakage = [expect(E_uc0,output.states) , expect(E_uc1,output.states)]

    U1 = basis(N,0)*basis(N,0).dag()+np.exp(1j*(wq[0])*tlist[-1])*basis(N,1)*basis(N,1).dag()
    U2 = basis(N,0)*basis(N,0).dag()+np.exp(1j*(wq[1])*tlist[-1])*basis(N,1)*basis(N,1).dag()
    UT = tensor(U1,U2)
    
    
    ang = np.angle((psi0.dag()*UT*output.states[-1])[0])[0][0]/np.pi*180
#    if ang<0:
#        ang = ang+360
    print(ang , exp[0][-1] , exp[1][-1] , leakage[0][-1] , leakage[1][-1])
    return(ang)
def getanglediffence(omegap , tp):
    global omega , A , t
    
    omega = omegap
    A = 2.4048*omega
    t = tp
    
    psi = np.array([tensor(basis(N,0),basis(N,0)) , tensor(basis(N,0),basis(N,1)) , tensor(basis(N,1),basis(N,0)) , tensor(basis(N,1),basis(N,1))])
    p = Pool(2)
    
    angle = p.map(getangle,psi)
    p.close()
    p.join()
    
    shiftc = -(np.sqrt(2)*g)**2/((wq[0]+wq[1]-(2*wq[0]+eta_q[0]))) - (np.sqrt(2)*g)**2/((wq[0]+wq[1]-(2*wq[1]+eta_q[1])))
    difc = mod((abs(shiftc)*tp/np.pi*180),360)
    
    dif = (angle[3]-angle[0])-(angle[1]-angle[0])-(angle[2]-angle[0])
    print(dif , difc)
    return(dif)


def CZ(t,args):
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

def Z_pulse_CZ(t , args):
    tp = args['tp']
    omega = args['omega']
    delta = args['delta']
    tlist = np.linspace(0,tp,1024)
    wg = interpolate.interp1d(tlist,delta*th,'slinear')#g
    x = np.linspace(0,2.4048,1024)
    y = g*jv(0,x)
    y = g*(y-np.min(y))/(np.max(y)-np.min(y))
    f = interpolate.interp1d(y,x,'slinear')
    
    if t<=0 or t>=tp:
        A = 2.4048*omega*np.cos(omega*t)
    else:
        A = f(wg(t))*omega*np.cos(omega*t)
    
    return(A)
    
def findstate(S,state):
    l = None
    e0 = eval(state[0])
    e1 = eval(state[1])
    for i in range(9):
        s0 = ptrace(S[i],0)[e0][0][e0]
        s1 = ptrace(S[i],1)[e1][0][e1]
        if abs(s0)>0.5 and abs(s1)>0.5 :
            l = i
    if l == None:
        print('No state')
    else:
        return(l)
def CZgate(P):
    tp = P[0]
    delta = P[1]
    if delta>g:
        delta = g
    elif delta<0:
        delta = 0
    omega = 0.12*2*np.pi
    
    print(P[0],P[1]/2/np.pi)
    
    
    
    
    tlist= np.linspace(0,tp,2*tp+1)
    
#    H1 = [sm0.dag()*sm0 , CZ]
    H2 = [sm0.dag()*sm0 , Z_pulse_CZ]
    H=[H0,H2]
    
    psi0 = tensor(basis(N,1) , (basis(N,0)+basis(N,1)).unit())
#    psi0 = tensor((basis(3,0)+basis(N,1)).unit() , (basis(N,1)).unit())
    # psi0 = tensor(basis(N,1) , (basis(N,1)).unit())
    P11 = tensor(basis(N,1) , (basis(N,1)).unit())
    P10 = tensor(basis(N,1) , (basis(N,0)).unit())
    
    options=Options()
    args = {'tp':tp, 'omega':omega , 'delta':delta}
    output = mesolve(H,psi0,tlist,[],[],args = args,options = options)
    
    exp = [expect(sm0.dag() * sm0,output.states) , expect(sm1.dag() * sm1,output.states)]
    leakage = [expect(E_uc0,output.states[-1]) , expect(E_uc1,output.states[-1])]

    U1 = basis(N,0)*basis(N,0).dag()+np.exp(1j*(wq[0])*tlist[-1])*basis(N,1)*basis(N,1).dag()
    U2 = basis(N,0)*basis(N,0).dag()+np.exp(1j*(wq[1])*tlist[-1])*basis(N,1)*basis(N,1).dag()
    UT = tensor(U1,U2)
    
#    target = tensor(basis(N,1) , (basis(N,0)-basis(N,1)).unit())
#    target1 = tensor(basis(N,1) , (basis(N,1)).unit())
    target1 = tensor((basis(N,1)).unit(),(basis(3,0)-basis(N,1)).unit() , )
    target2 = tensor((basis(N,1)).unit(),(basis(3,0)+basis(N,1)).unit() , )
    fid1 = fidelity(UT*output.states[-1]*output.states[-1].dag()*UT.dag(),target1)
    fid2 = fidelity(UT*output.states[-1]*output.states[-1].dag()*UT.dag(),target2)
    
    
    ang1 = np.angle((P11.dag()*UT*output.states[-1])[0])[0][0]/np.pi*180
    ang0 = np.angle((P10.dag()*UT*output.states[-1])[0])[0][0]/np.pi*180
    if ang1<0:
        ang1 = ang1+360
    if ang0<0:
        ang0 = ang0+360
    ang = mod(ang1-ang0,360)
    
    
    
#==============================================================================
    l11 = []
    l20 = []
    tt = np.linspace(0,tp,resolution)
    wg = interpolate.interp1d(tt,delta*th,'slinear')#g
    x = np.linspace(0,2.4048,1024)
    y = g*jv(0,x)
    y = g*(y-np.min(y))/(np.max(y)-np.min(y))
    f = interpolate.interp1d(y,x,'slinear')
    for i,ti in enumerate(tlist):
        H1 = H0+sm0.dag()*sm0*(f(wg(ti))*omega*np.cos(omega*ti)).tolist()
        S = H1.eigenstates()[1]
        s11 = S[findstate(S,'11')]
        s20 = S[findstate(S,'20')]
        l11.append( fidelity(s11,output.states[i]) )
        l20.append( fidelity(s20,output.states[i]) )
    
#    figure();plot(tlist,l11);xlabel('t');ylabel('P11')
#    figure();plot(tlist,l20);xlabel('t');ylabel('P20')     
#==============================================================================

    print(fid1,fid2 , ang1,ang0,ang , exp[0][-1] , exp[1][-1] ,np.max(l11)-np.min(l11))
    
    
#    return([fid2,ang1,np.max(l11)-np.min(l11)])
    return(1-fid1)

    

if __name__=='__main__':
    starttime=time.time()
    
    global th
    resolution = 1024
    thf = 0.55*pi/2;
    thi = 0.05;
    lam2 = -0.18;
    lam3 = 0.04;
    resolution = 1024;
    
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
    
    global H0
    
    N = 3
    
    g = 0.004 * 2 * np.pi
    wq= np.array([5.00 , 4.65 ]) * 2 * np.pi
    eta_q=  np.array([-0.250 , -0.250]) * 2 * np.pi
    
    

    sm0=tensor(destroy(N),qeye(N))
    sm1=tensor(qeye(N),destroy(N))
    E_uc0 = tensor(basis(3,2)*basis(3,2).dag() , qeye(3)) 
    E_uc1 = tensor(qeye(3) , basis(3,2)*basis(3,2).dag())
    
    
    H0= (wq[0]) * sm0.dag()*sm0 + (wq[1]) * sm1.dag()*sm1 + eta_q[0]*E_uc0 + eta_q[1]*E_uc1 + g * (sm0.dag()+sm0) * (sm1.dag()+sm1)
#    H0= (wq[0]) * sm0.dag()*sm0 + (wq[1]) * sm1.dag()*sm1 + g * (sm0.dag()+sm0) * (sm1.dag()+sm1)
    

    

    
#    omega = 0.4*2*np.pi
#    A = 2.4048*omega
                
#    x0 = [jn_zeros(0,1)*omega ]
#    result = minimize(optA, x0, method="Nelder-Mead",options={'disp': True})
#    print(result.x/2/np.pi)
    
#    CZgate([175,1.00530965])
#    optA(A)

#    getanglediffence(0.07 * 2 * np.pi , 100)
    

    x0 = [1.5*np.pi/np.sqrt(2)/g , 0.003 * 2 * np.pi]
#    cons = ({'type': 'ineq', 'fun': lambda x:  0.004 * 2 * np.pi-x[1]},)
#    bnds = ((0, None), (0, 0.004 * 2 * np.pi))
    result = minimize(CZgate, x0, method="Nelder-Mead",options={'disp': True,})
    print(result.x[0] , result.x[1]/2/np.pi )


#    t = np.arange(75,200,1)
#    delta = np.linspace(0,g,40)
#    fid=np.zeros(shape=(len(t),len(delta)))
#    ang=np.zeros(shape=(len(t),len(delta)))
#    leakage=np.zeros(shape=(len(t),len(delta)))
#
#    p = Pool(55)
#   
#    for i in range(0,len(t)):
#        P = [[t[i],delta[j]] for j in range(0,len(delta))]
#        A = p.map(CZgate,P)
#        fid[i] = [x[0] for x in A]
#        ang[i] = [x[1] for x in A]
#        leakage[i] = [x[2] for x in A]
##        roundtime = time.time()
##        print(t[i],roundtime-starttime)
#    p.close()
#    p.join()
#    ang1 = [x[0] for x in z ]
#    ang0 = [x[1] for x in z ]
#    ang = [x[2] for x in z ]
#    figure();plot(t,ang1);title('ang1')
#    figure();plot(t,ang0);title('ang0')
#    figure();plot(t,ang);title('ang')
   
#    figure()
#    pcolormesh(delta,t,fid)
#    xlabel('delta')
#    ylabel('t')
#    title('fid')
#    plt.colorbar()
#
#    figure()
#    pcolormesh(delta,t,ang)
#    xlabel('delta')
#    ylabel('t')
#    title('ang')
#    plt.colorbar()
#          
#    figure()
#    pcolormesh(delta,t,leakage)
#    xlabel('delta')
#    ylabel('t')
#    title('leakage')
#    plt.colorbar()
#       
#    fid = np.array(fid)
#    minz = np.min(fid)
#    indexz = np.where(fid == minz)
#    print(minz,t[indexz[0]],delta[indexz[1]])
#    np.save('QS_0.16_fid',fid) 
#    np.save('QS_0.16_ang',ang) 
#    np.save('QS_0.16_leakage',leakage) 
    
    finishtime=time.time()
    print( 'Time used: ', (finishtime-starttime), 's')