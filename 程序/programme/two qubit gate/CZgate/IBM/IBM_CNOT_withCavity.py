#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sat Nov 25 16:40:37 2017

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

def getfid(T):
    psi = T[0]
    target = T[1]
    output = mesolve(H,psi,tlist,[],[],args = args,options = options)
    
    U1 = basis(N,0)*basis(N,0).dag()+np.exp(1j*(E[2]-E[0]+E[6]-E[1])/2*tlist[-1])*basis(N,1)*basis(N,1).dag()
    U2 = basis(N,0)*basis(N,0).dag()+np.exp(1j*(E[1]-E[0]+E[6]-E[2])/2*tlist[-1])*basis(N,1)*basis(N,1).dag()
    UT = tensor(qeye(3),U1,U2)
    
    fid = fidelity(UT*output.states[-1]*output.states[-1].dag()*UT.dag(),target)
    
    leakage = [expect(E_uc0,output.states[-1]) , expect(E_uc1,output.states[-1])]
    
    
#==============================================================================
    n_x0 = [] ; n_y0 = [] ; n_z0 = [];
    n_x1 = [] ; n_y1 = [] ; n_z1 = [];
    l0 = [];l1 = [];R = []
    for t in range(0,len(tlist)):
        U0 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(E[2]-E[0]+E[6]-E[1])/2*tlist[t])*basis(3,1)*basis(3,1).dag()
        U1 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(E[1]-E[0]+E[6]-E[2])/2*tlist[t])*basis(3,1)*basis(3,1).dag()
        U = tensor(qeye(3),U0,U1)
    #        U = (1j*H0*tlist[t]).expm()
        
        opx0 = U.dag()*(sm0.dag()+sm0)*U
        opy0 = U.dag()*(1j*sm0.dag()-1j*sm0)*U
        opz0 = tensor(qeye(3),qeye(3),qeye(3))-2*sm0.dag()*sm0
        opx1 = U.dag()*(sm1.dag()+sm1)*U
        opy1 = U.dag()*(1j*sm1.dag()-1j*sm1)*U
        opz1 = tensor(qeye(3),qeye(3),qeye(3))-2*sm1.dag()*sm1
        n_x0.append(expect(opx0,output.states[t]))
        n_y0.append(expect(opy0,output.states[t]))
        n_z0.append(expect(opz0,output.states[t]))
        n_x1.append(expect(opx1,output.states[t]))
        n_y1.append(expect(opy1,output.states[t]))
        n_z1.append(expect(opz1,output.states[t]))
        l0.append(expect(E_uc0,output.states[t]))
        l1.append(expect(E_uc1,output.states[t]))

    n_x0 = np.array(n_x0);n_y0 = np.array(n_y0);n_z0 = np.array(n_z0);
    n_x1 = np.array(n_x1);n_y1 = np.array(n_y1);n_z1 = np.array(n_z1);
#    R = np.sqrt(np.square(n_x0-n_x1)+np.square(n_y0-n_y1)+np.square(n_z0-n_z1))
    fig ,axes = plt.subplots(2,2)
    axes[0][0].plot(tlist,n_x0,label = 'X0');
    axes[0][0].plot(tlist,n_y0,label = 'Y0');
    axes[0][0].plot(tlist,n_z0,label = 'Z0');axes[0][0].set_xlabel('t');axes[0][0].set_ylabel('Population')
    axes[0][0].legend(loc = 'upper left');plt.show()
    axes[0][1].plot(tlist,n_x1,label = 'X1');
    axes[0][1].plot(tlist,n_y1,label = 'Y1');
    axes[0][1].plot(tlist,n_z1,label = 'Z1');axes[0][1].set_xlabel('t');axes[0][1].set_ylabel('Population')
    axes[0][1].legend(loc = 'upper left');plt.show();plt.tight_layout()
    axes[1][0].plot(tlist,l0);axes[1][0].set_xlabel('t');axes[1][0].set_ylabel('L0')
    axes[1][1].plot(tlist,l1);axes[1][1].set_xlabel('t');axes[1][1].set_ylabel('L1')
    sphere = Bloch()
    sphere.add_points([n_x0 , n_y0 , n_z0])
    sphere.add_vectors([n_x0[-1],n_y0[-1],n_z0[-1]])
    sphere.make_sphere() 
    sphere = Bloch()
    sphere.add_points([n_x1 , n_y1 , n_z1])
    sphere.add_vectors([n_x1[-1],n_y1[-1],n_z1[-1]])
    sphere.make_sphere() 
    plt.show() 

    
##==============================================================================
    return([fid,leakage[0],output.states[-1]])
#    return(abs(np.max(n_x1)-np.min(n_x1)))
    
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

def CNOT(P):
    tp = P[0]
    omega = P[1]
#    D = P
#    tp = 400
#    omega = 0.060*2*np.pi
    

    global H,tlist,args,options
    
    f1 = (E[1]-E[0]+E[6]-E[2])/2
    f2 = (E[2]-E[0]+E[6]-E[1])/2
#    f1 = E[1]-E[0]#CR驱动频率
#    f2 = E[2]-E[0]#X波频率
    alpha = 0.05
    # w1 = '(-0.069066*np.pi/2*np.exp(-(t-20)**2/2.0/6**2))*(0<t<=40)'

    # w3 = '(0.03332*np.pi*(np.exp(-(t-60-tp)**2/2.0/6**2)*np.cos(t*omega3)+(t-60-tp)/2/6**2/'+str(eta_q[0])+'*np.exp(-(t-tp-60)**2/2.0/6**2)*np.cos(t*omega3-np.pi/2)))*((40+tp)<t<=80+tp)'
    
#    w1 = 'omega/2*((erf((t-8)/ramp)-erf((t-tp+8)/ramp))*(np.cos(f1*t)))*(0<t<=tp)'
    w1 = 'omega/2*((erf((t-8)/ramp)-erf((t-tp+8)/ramp))*(np.cos(f1*t))+D*(2*np.exp(-(t-8)**2/ramp**2)/np.sqrt(np.pi)/ramp-2*np.exp(-(t-tp+8)**2/ramp**2)/np.sqrt(np.pi)/ramp)/'+str(eta_q[0])+'*(np.cos(f1*t-np.pi/2)))*(0<t<=tp)'
#    w1 = 'omega*(np.exp(-(t-15)**2/2/5**2)*((0)<t<=15)+1*(15<t<=tp-15)+np.exp(-(t-tp+15)**2/2/5**2)*((tp-15)<t<=tp))*(np.cos(f1*t))'
    
    w2 = '(0.03332*2*np.pi*(np.exp(-(t-30-tp)**2/2.0/6**2)*np.cos(t*f2)+(t-30-tp)/2/6**2/'+str(eta_q[0])+'*np.exp(-(t-30-tp)**2/2.0/6**2)*np.cos(t*f2-np.pi/2)))*((10+tp)<t<=50+tp)'

    w3 = 'omega/2*((erf((t-tp-60-8)/ramp)-erf((t-tp-60-tp+8)/ramp))*(np.cos(f1*t+np.pi))+D*(2*np.exp(-(t-tp-60-8)**2/ramp**2)/np.sqrt(np.pi)/ramp-2*np.exp(-(t-tp-60-tp+8)**2/ramp**2)/np.sqrt(np.pi)/ramp)/'+str(eta_q[0])+'*(np.cos(f1*t+np.pi-np.pi/2)))*(tp+60<t<=2*tp+60)'
#    w3 = 'omega/2*(erf((t-tp-60-8)/ramp)-erf((t-tp-60-tp+8)/ramp))*(np.cos(f1*t+np.pi))*(tp+60<t<=2*tp+60)'
#    w3 = 'omega*(np.exp(-(t-tp-75)**2/2/5**2)*(tp+60<t<=tp+75)+1*(tp+75<t<=2*tp+45)+np.exp(-(t-2*tp-45)**2/2/5**2)*((2*tp+45)<t<=2*tp+60))*(np.cos(f1*t+np.pi))'

    w4 = '(0.03332*2*np.pi*(np.exp(-(t-90-2*tp)**2/2.0/6**2)*np.cos(t*f2)+(t-90-2*tp)/2/6**2/'+str(eta_q[0])+'*np.exp(-(t-90-2*tp)**2/2.0/6**2)*np.cos(t*f2-np.pi/2)))*((2*tp+70)<t<=2*tp+110)'
    
          
    w5 = 'alpha*omega/2*(erf((t-8)/ramp)-erf((t-tp+8)/ramp))*(np.cos(f1*t)+np.cos(f1*t-np.pi/2))*((0)<t<=tp)'

#    w6 = 'alpha*omega/2*(erf((t-8)/5)-erf((t-tp+8)/5))*(np.cos(f1*t+0.5*np.pi))*((0)<t<=tp)'
    w6 = 'alpha*(0.03332*2*np.pi*(np.exp(-(t-30-tp)**2/2.0/6**2)*np.cos(t*f2)+(t-30-tp)/2/6**2/'+str(eta_q[0])+'*np.exp(-(t-30-tp)**2/2.0/6**2)*np.cos(t*f2-np.pi/2)))*((10+tp)<t<=50+tp)'

    w7 = 'alpha*omega/2*(erf((t-tp-60-8)/ramp)-erf((t-tp-60-tp+8)/ramp))*(np.cos(f1*t+np.pi)+np.cos(f1*t+np.pi/2))*(tp+60<t<=2*tp+60)'

#    w8 = 'alpha*omega/2*(erf((t-tp-60-8)/5)-erf((t-tp-60-tp+8)/5))*(np.cos(f1*t+np.pi+0.5*np.pi))*(tp+60<t<=2*tp+60)'
    w8 = 'alpha*(0.03332*2*np.pi*(np.exp(-(t-90-2*tp)**2/2.0/6**2)*np.cos(t*f2)+(t-90-2*tp)/2/6**2/'+str(eta_q[0])+'*np.exp(-(t-90-2*tp)**2/2.0/6**2)*np.cos(t*f2-np.pi/2)))*((2*tp+70)<t<=2*tp+110)'

    args = {'omega':omega,'tp':tp , 'ramp': 5 , 'f1':f1 , 'f2':f2, 'alpha':alpha , 'D':0.8}

    
    H1 = [sm0+sm0.dag(),w1]
    H2 = [sm0+sm0.dag(),w2]
    H3 = [sm0+sm0.dag(),w3]
    H4 = [sm0+sm0.dag(),w4]
    H5 = [sm1+sm1.dag(),w5]
    H6 = [sm1+sm1.dag(),w6]
    H7 = [sm1+sm1.dag(),w7]
    H8 = [sm1+sm1.dag(),w8]
    # H = [H0,H1,H2,H3,H4,H5,H6,H7,H8]
    H =  [H0,H1,H2,H3,H4]

    tlist = np.arange(0,2*tp+110,0.1)
#    tlist = np.arange(0,tp,0.1)
    options=Options()
    options.atol=1e-8
    options.rtol=1e-6
    options.first_step=0.01
    options.num_cpus=8
    options.nsteps=1e6
    options.gui='True'
    options.ntraj=1000
    options.rhs_reuse=False

    

    s00 = S[findstate(S,'00')]
    s01 = S[findstate(S,'01')]
    s10 = S[findstate(S,'10')]
    s11 = S[findstate(S,'11')]

    T = []
    T.append([tensor(basis(3,0),basis(3,0),basis(3,0)),(tensor(basis(3,0),basis(3,0),basis(3,0))+1j*tensor(basis(3,0),basis(3,0),basis(3,1))).unit()])
    T.append([tensor(basis(3,0),basis(3,0),basis(3,1)),(tensor(basis(3,0),basis(3,0),basis(3,1))+1j*tensor(basis(3,0),basis(3,0),basis(3,0))).unit()])
    T.append([tensor(basis(3,0),basis(3,1),basis(3,0)),(tensor(basis(3,0),basis(3,1),basis(3,0))-1j*tensor(basis(3,0),basis(3,1),basis(3,1))).unit()])
    T.append([tensor(basis(3,0),basis(3,1),basis(3,1)),(tensor(basis(3,0),basis(3,1),basis(3,1))-1j*tensor(basis(3,0),basis(3,1),basis(3,0))).unit()])
#    T.append([s00,(s00-1j*s01).unit()])
#    T.append([s01,(s01-1j*s00).unit()])
#    T.append([s10,(s10+1j*s11).unit()])
#    T.append([s11,(s11+1j*s10).unit()])

    fid = []
    leakage = []
    
    
#    for psi in T:
#        fid.append(getfid(psi)[0])
#        leakage.append(getfid(psi)[1])
#    fid = np.array(fid)
#    leakage = np.array(leakage)

#    p = Pool(4)
#    
#    A = p.map(getfid,T)
#    fid = [x[0] for x in A]
#    leakage = [x[1] for x in A]
#    outputstate = [x[2] for x in A]
#    fid = np.array(fid)
#    leakage = np.array(leakage)
#
#        
#    p.close()
#    p.join()
##    print(P,np.mean(leakage),fid,np.mean(fid))
#    gc.collect()
    
    
#    process = np.column_stack([outputstate[i].data.toarray() for i in range(len(outputstate))])[(0,1,3,4),:]
#    targetprocess = 1/np.sqrt(2)*np.array([[1,-1j,0,0],[-1j,1,0,0],[0,0,1,1j],[0,0,1j,1]])
#    Ufidelity = np.abs(np.trace(np.dot(np.conjugate(np.transpose(process)),targetprocess)))/4
#    Ufidelity = np.abs(np.real(np.trace(np.dot(process,targetprocess))))  
#    fidelity = np.sum(np.abs(process-targetprocess))
    

    
    psi = [tensor(basis(3,0),basis(3,0),basis(3,0)),(tensor(basis(3,0),basis(3,0),basis(3,0))-1j*tensor(basis(3,0),basis(3,0),basis(3,1))).unit()]
#    psi = [(s00+s10).unit(),(s00-1j*s01+s10+1j*s11).unit()]
    fid,leakage,outputstate = getfid(psi)
    print(P,np.mean(leakage),fid,np.mean(fid))


#    x = getfid(psi)
#    print(x)
#    gc.collect()


    
#
    return(1-np.mean(fid))
#    return(process,outputstate)
#
def opt(radio):
    global D
    D = radio
    x0 = [40,0.14*2*np.pi]
    result = minimize(CNOT, x0, method="Nelder-Mead",options={'disp': True})
    print(result.fun,result.x[0],result.x[1])
    return([1-result.fun,result.x[0],result.x[1]])


if __name__=='__main__':
    starttime=time.time()
    

    
    global H0,E,S
    
    N = 3
    wc = 6.31*2*np.pi
    g = 0.075 * 2 * np.pi
    wq= np.array([5.114 , 4.914 ]) * 2 * np.pi
    eta_q=  np.array([-0.330 , -0.330]) * 2 * np.pi
    
    
    a = tensor(destroy(N),qeye(3),qeye(N))
    sm0=tensor(qeye(3),destroy(N),qeye(N))
    sm1=tensor(qeye(3),qeye(N),destroy(N))
    E_uc0 = tensor(qeye(3),basis(3,2)*basis(3,2).dag() , qeye(3)) 
    E_uc1 = tensor(qeye(3),qeye(3) , basis(3,2)*basis(3,2).dag())
    
    
    H0= wc*a.dag()*a+(wq[0]) * sm0.dag()*sm0 + (wq[1]) * sm1.dag()*sm1 + eta_q[0]*E_uc0 + eta_q[1]*E_uc1 + g * (sm0.dag()+sm0) * (a+a.dag())+g * (sm1.dag()+sm1) * (a+a.dag())
    [E,S] = H0.eigenstates()


#    fid = CNOT([70.1805137306,1.10522763])
#    fid = CNOT([104.7520927  ,   0.83144823])
    fid = CNOT([57,0.060*2*np.pi])
#    print(fid)

#    D = np.linspace(-10,10,1000)
#    p = Pool(14)
#
#    A = p.map(CNOT,D)
#
#        
#    p.close()
#    p.join()
#    figure();plot(D,A);xlabel('D');ylabel('delta_x')
    
#    x0 = [50]
#    result = minimize(CNOT, x0, method="Nelder-Mead",options={'disp': True})
#    print(result.x[0],result.x[1])


#    radio = np.linspace(-1.1,1,42)
#    p = Pool(42)
#    
#    A = p.map(opt,radio)
#    fid = [x[0] for x in A]
#    tp = [x[1] for x in A]
#    omega = [x[2] for x in A]
#    fid = np.array(fid)
#    tp = np.array(tp)
#    omega = np.array(omega)
#
#        
#    p.close()
#    p.join()
#    figure();plot(radio,fid);xlabel('D');ylabel('fidelity')
#    figure();plot(radio,tp);xlabel('D');ylabel('tp')
#    figure();plot(radio,omega);xlabel('D');ylabel('oemga')
#
#    maxfid = np.max(fid)
#    indexfid = np.argmax(fid)
#    print(maxfid,radio[indexfid])


    finishtime=time.time()
    print( 'Time used: ', (finishtime-starttime), 's')