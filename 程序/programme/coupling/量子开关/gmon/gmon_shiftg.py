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
    
    
    
    
    tlist= np.linspace(0,tp,4*tp+1)
    
#    figure();plot(tlist,np.vectorize(wave)(tlist))
    
    H2 = [(sm0.dag()+sm0) * (sm1.dag()+sm1) , g_pulse]
    H=[H0,H2]
    
#    psi0 = tensor(basis(N,1) , (basis(N,0)+basis(N,1)).unit())
#    psi0 = tensor((basis(3,0)+basis(N,1)).unit() , (basis(N,1)).unit())
    psi0 = tensor(basis(N,1) , (basis(N,1)).unit())
    
    P11 = tensor(basis(N,1) , (basis(N,1)).unit())
    
    options=Options()
    args = {'tp':tp ,  'delta':delta}
    output = mesolve(H,psi0,tlist,[],[],args = args,options = options)
    
    exp = [expect(sm0.dag() * sm0,output.states) , expect(sm1.dag() * sm1,output.states)]
    leakage = [expect(E_uc0,output.states[-1]) , expect(E_uc1,output.states[-1])]

    U1 = basis(N,0)*basis(N,0).dag()+np.exp(1j*(wq[0])*tlist[-1])*basis(N,1)*basis(N,1).dag()
    U2 = basis(N,0)*basis(N,0).dag()+np.exp(1j*(wq[1])*tlist[-1])*basis(N,1)*basis(N,1).dag()
    UT = tensor(U1,U2)
    
#    target = tensor(basis(N,1) , (basis(N,0)-basis(N,1)).unit())
    target1 = tensor(basis(N,1) , (basis(N,1)).unit())
#    target1 = tensor((basis(N,1)).unit(),(basis(3,0)-basis(N,1)).unit() , )
    target2 = tensor((basis(N,1)).unit(),(basis(3,0)-basis(N,1)).unit() , )
    fid1 = fidelity(UT*output.states[-1]*output.states[-1].dag()*UT.dag(),target1)
    fid2 = fidelity(UT*output.states[-1]*output.states[-1].dag()*UT.dag(),target2)
    
    ang1 = np.angle((P11.dag()*UT*output.states[-1])[0])[0][0]/np.pi*180
    if ang1<0:
        ang1 = ang1+360
    
    

    
    
    
#==============================================================================
#    n_x0 = [] ; n_y0 = [] ; n_z0 = [];
#    n_x1 = [] ; n_y1 = [] ; n_z1 = [];
#    for t in range(0,len(tlist)):
#        U0 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(wq[0])*tlist[t])*basis(3,1)*basis(3,1).dag()
#        U1 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(wq[1])*tlist[t])*basis(3,1)*basis(3,1).dag()
#        U = tensor(U0,U1)
##        U = (1j*H0*tlist[t]).expm()
#        
#        opx0 = U.dag()*(sm0.dag()+sm0)*U
#        opy0 = U.dag()*(1j*sm0.dag()-1j*sm0)*U
#        opz0 = tensor(qeye(3),qeye(3))-2*sm0.dag()*sm0
#        opx1 = U.dag()*(sm1.dag()+sm1)*U
#        opy1 = U.dag()*(1j*sm1.dag()-1j*sm1)*U
#        opz1 = tensor(qeye(3),qeye(3))-2*sm1.dag()*sm1
#        n_x0.append(expect(opx0,output.states[t]))
#        n_y0.append(expect(opy0,output.states[t]))
#        n_z0.append(expect(opz0,output.states[t]))
#        n_x1.append(expect(opx1,output.states[t]))
#        n_y1.append(expect(opy1,output.states[t]))
#        n_z1.append(expect(opz1,output.states[t]))
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
#==============================================================================
#==============================================================================
    l11_c = []
    l20_c = []
    l02_c = []
    l11_uc = []
    l20_uc = []
    l02_uc = []
    tt = np.linspace(0,tp,resolution)
    gt = interpolate.interp1d(tt,delta*th,'slinear')
    for i,ti in enumerate(tlist):
        H1 = H0+(sm0.dag()+sm0) * (sm1.dag()+sm1)*((gt(ti)).tolist())

        S = H1.eigenstates()[1]
        s11 = S[findstate(S,'11')]
        s20 = S[findstate(S,'20')]
        s02 = S[findstate(S,'02')]
            
            
 
        l11_c.append( fidelity(s11,output.states[i]) )
        l20_c.append( fidelity(s20,output.states[i]) )
        l02_c.append( fidelity(s02,output.states[i]) )
        l11_uc.append( fidelity(tensor(basis(3,1),basis(3,1)),output.states[i]) )
        l20_uc.append( fidelity(tensor(basis(3,2),basis(3,0)),output.states[i]) )
        l02_uc.append( fidelity(tensor(basis(3,0),basis(3,2)),output.states[i]) )
    
#    figure();plot(tlist,l11_c);xlabel('t');ylabel('P11_c')
#    figure();plot(tlist,l20_c);xlabel('t');ylabel('P20_c')  
#    figure();plot(tlist,l02_c);xlabel('t');ylabel('P02_c')  
#    figure();plot(tlist,l11_uc);xlabel('t');ylabel('P11_uc')
#    figure();plot(tlist,l20_uc);xlabel('t');ylabel('P20_uc')  
#    figure();plot(tlist,l02_uc);xlabel('t');ylabel('P02_uc')  
#==============================================================================
#    
    print(P[0],P[1]/2/np.pi, fid1 , ang1,leakage[0],leakage[1],np.max(l11_c)-np.min(l11_c) )
    return([fid1,ang1,np.max(l11_c)-np.min(l11_c)])
#    return(1-fid1+(ang1-180)/180+leakage[0]+leakage[1]+np.max(l11_c)-np.min(l11_c))

if __name__=='__main__':
    starttime=time.time()
    
    global th
    resolution = 1024
    thf = 0.55*pi/2;
    thi = 0.05;
    lam2 = -0.18;
    lam3 = -0.04;
    resolution = 1024;
    
    '''
    Hx
    '''
#    ti=np.linspace(0,1,resolution)
#    han2 = np.vectorize(lambda ti:(1-lam3)*(1-np.cos(2*np.pi*ti))+lam2*(1-np.cos(4*np.pi*ti))+lam3*(1-np.cos(6*np.pi*ti)))
#    han2 = han2(ti)
#    thsl=thi+(thf-thi)*han2/np.max(han2)   
#    tlu = np.cumsum(np.cos(thsl))*ti[1]
#    tlu=tlu-tlu[0]
#    ti=np.linspace(0, tlu[-1], resolution)
#    th=interpolate.interp1d(tlu,thsl,'slinear')
#    th = th(ti)
#    th=np.tan(th)
#    th=th-th[0]
#    th=th/np.max(th)
    
    '''
    Hz
    '''
    ti=np.linspace(0,1,resolution)
    han2 = np.vectorize(lambda ti:(1-lam3)*(1-cos(2*pi*ti))+lam2*(1-cos(4*pi*ti))+lam3*(1-cos(6*pi*ti)))
    han2 = han2(ti)
    thsl=thi+(thf-thi)*han2/max(han2)
    tlu = np.cumsum(np.sin(thsl))*ti[1]
    tlu=tlu-tlu[0]
    ti=np.linspace(0, tlu[-1], resolution)
    th=interpolate.interp1d(tlu,thsl,'slinear')
    th = th(ti)
    th=1/np.tan(th)
    th=th-th[0]
    th=th/min(th)
    
    global H0
    
    N = 3
    
#    g = 0.004 * 2 * np.pi
    wq= np.array([5.00 , 4.62 ]) * 2 * np.pi
    eta_q=  np.array([-0.250 , -0.250]) * 2 * np.pi
    
    

    sm0=tensor(destroy(N),qeye(N))
    sm1=tensor(qeye(N),destroy(N))
    E_uc0 = tensor(basis(3,2)*basis(3,2).dag() , qeye(3)) 
    E_uc1 = tensor(qeye(3) , basis(3,2)*basis(3,2).dag())
    
    
    H0= (wq[0]) * sm0.dag()*sm0 + (wq[1]) * sm1.dag()*sm1 + eta_q[0]*E_uc0 + eta_q[1]*E_uc1
    
#    fid = CZgate([50, 0.055*2*np.pi])
#    x0 = [30 , 0.055*2*np.pi ]
#    result = minimize(CZgate, x0, method="Nelder-Mead",options={'disp': True})
#    print(result.x[0] , result.x[1]/2/np.pi)

#==============================================================================
    t = np.arange(25,80,1)
    delta = np.arange(0,0.060*2*np.pi,0.001*2*np.pi)
    fid=np.zeros(shape=(len(t),len(delta)))
    ang=np.zeros(shape=(len(t),len(delta)))
    leakage=np.zeros(shape=(len(t),len(delta)))
    
    p = Pool(24)
    
    for i in range(0,len(t)):
        P = [[t[i],delta[j]] for j in range(0,len(delta))]
        A = p.map(CZgate,P)
        fid[i] = [x[0] for x in A]
        ang[i] = [x[1] for x in A]
        leakage[i] = [x[2] for x in A]
        
    p.close()
    p.join()
    
    
    figure()
    pcolormesh(delta/2/np.pi,t,fid)
    xlabel('delta')
    ylabel('t')
    title('fidz')
    plt.colorbar()
    
    figure()
    pcolormesh(delta/2/np.pi,t,ang)
    xlabel('delta')
    ylabel('t')
    title('angz')
    plt.colorbar()
    
    figure()
    pcolormesh(delta/2/np.pi,t,leakage)
    xlabel('delta')
    ylabel('t')
    title('leakagez')
    plt.colorbar()
    
    leakage = np.array(leakage)
    minleakage = np.min(leakage)
    indexleakage = np.where(leakage == minleakage)
    print(minleakage,t[indexleakage[0]],delta[indexleakage[1]])
    fid = np.array(fid)
    maxfid = np.max(fid)
    indexfid = np.where(fid == maxfid)
    print(maxfid,t[indexfid[0]],delta[indexfid[1]])
    np.save('gmonz_4.62_fid',fid) 
    np.save('gmonz_4.62_ang',ang) 
    np.save('gmonz_4.62_leakage',leakage) 
#==============================================================================




    finishtime=time.time()
    print( 'Time used: ', (finishtime-starttime), 's')
        
        
        