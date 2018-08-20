#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Oct 29 17:25:55 2017

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
    
    U1 = basis(N,0)*basis(N,0).dag()+np.exp(1j*(E[l11]-E[l01]+E[l10]-E[l00])/2*tlist[-1])*basis(N,1)*basis(N,1).dag()
    U2 = basis(N,0)*basis(N,0).dag()+np.exp(1j*(E[l11]-E[l10]+E[l01]-E[l00])/2*tlist[-1])*basis(N,1)*basis(N,1).dag()
#    U1 = basis(N,0)*basis(N,0).dag()+np.exp(1j*(E[l10]-E[l00])*tlist[-1])*basis(N,1)*basis(N,1).dag()
#    U2 = basis(N,0)*basis(N,0).dag()+np.exp(1j*(E[l01]-E[l00])*tlist[-1])*basis(N,1)*basis(N,1).dag()
    UT = tensor(U1,U2)
    
    fid = fidelity(UT*output.states[-1]*output.states[-1].dag()*UT.dag(),target)
    
    leakage = [expect(E_uc0,output.states[-1]) , expect(E_uc1,output.states[-1])]
    
    
#==============================================================================
#    n_x0 = [] ; n_y0 = [] ; n_z0 = [];
#    n_x1 = [] ; n_y1 = [] ; n_z1 = [];
#    l0 = [];l1 = [];R = []
#    for t in range(0,len(tlist)):
#        U0 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(E[l11]-E[l01]+E[l10]-E[l00])/2*tlist[t])*basis(3,1)*basis(3,1).dag()
#        U1 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(E[l11]-E[l10]+E[l01]-E[l00])/2*tlist[t])*basis(3,1)*basis(3,1).dag()
##        U0 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(E[2]-E[0])*tlist[t])*basis(3,1)*basis(3,1).dag()
##        U1 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(E[1]-E[0])*tlist[t])*basis(3,1)*basis(3,1).dag()
#        U = tensor(U0,U1)
#    #        U = (1j*H0*tlist[t]).expm()
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
#        l0.append(expect(E_uc0,output.states[t]))
#        l1.append(expect(E_uc1,output.states[t]))
#
#    n_x0 = np.array(n_x0);n_y0 = np.array(n_y0);n_z0 = np.array(n_z0);
#    n_x1 = np.array(n_x1);n_y1 = np.array(n_y1);n_z1 = np.array(n_z1);
#
#    fig ,axes = plt.subplots(2,2)
#    axes[0][0].plot(tlist,n_x0,label = 'X0');
#    axes[0][0].plot(tlist,n_y0,label = 'Y0');
#    axes[0][0].plot(tlist,n_z0,label = 'Z0');axes[0][0].set_xlabel('t');axes[0][0].set_ylabel('Population')
#    axes[0][0].legend(loc = 'upper left');plt.show()
#    axes[0][1].plot(tlist,n_x1,label = 'X1');
#    axes[0][1].plot(tlist,n_y1,label = 'Y1');
#    axes[0][1].plot(tlist,n_z1,label = 'Z1');axes[0][1].set_xlabel('t');axes[0][1].set_ylabel('Population')
#    axes[0][1].legend(loc = 'upper left');plt.show();plt.tight_layout()
#    axes[1][0].plot(tlist,l0);axes[1][0].set_xlabel('t');axes[1][0].set_ylabel('L0')
#    axes[1][1].plot(tlist,l1);axes[1][1].set_xlabel('t');axes[1][1].set_ylabel('L1')
#    sphere = Bloch()
#    sphere.add_points([n_x0 , n_y0 , n_z0])
#    sphere.add_vectors([n_x0[-1],n_y0[-1],n_z0[-1]])
#    sphere.make_sphere() 
#    sphere = Bloch()
#    sphere.add_points([n_x1 , n_y1 , n_z1])
#    sphere.add_vectors([n_x1[-1],n_y1[-1],n_z1[-1]])
#    sphere.make_sphere() 
#    plt.show() 

    
##==============================================================================
    return([fid,leakage[0],UT*output.states[-1]])
#    return(abs(np.max(n_x1)-np.min(n_x1)))
    
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
    
def Operator_View(M,lab):
    if isinstance(M, Qobj):
        # extract matrix data from Qobj
        M = M.full()

    n = np.size(M)
    xpos, ypos = np.meshgrid(range(M.shape[0]), range(M.shape[1]))
    xpos = xpos.T.flatten() - 0.5
    ypos = ypos.T.flatten() - 0.5
    zpos = np.zeros(n)
    dx = dy = 0.8 * np.ones(n)
    
    dz = np.real(M.flatten())
    z_min = min(dz)
    z_max = max(dz)
    if z_min == z_max:
        z_min -= 0.1
        z_max += 0.1
    norm = mpl.colors.Normalize(z_min, z_max)
    cmap = cm.get_cmap('jet')  # Spectral
    colors = cmap(norm(dz))
    fig = plt.figure()
    ax = Axes3D(fig, azim=-35, elev=35)
    ax.bar3d(xpos, ypos, zpos, dx, dy, dz, color=colors)
    ax.set_title(lab+'_Real')
    cax, kw = mpl.colorbar.make_axes(ax, shrink=.75, pad=.0)
    mpl.colorbar.ColorbarBase(cax, cmap=cmap, norm=norm)
    
    dz = np.imag(M.flatten())
    z_min = min(dz)
    z_max = max(dz)
    if z_min == z_max:
        z_min -= 0.1
        z_max += 0.1
    norm = mpl.colors.Normalize(z_min, z_max)
    cmap = cm.get_cmap('jet')  # Spectral
    colors = cmap(norm(dz))
    fig = plt.figure()
    ax = Axes3D(fig, azim=-35, elev=35)
    ax.bar3d(xpos, ypos, zpos, dx, dy, dz, color=colors)
    ax.set_title(lab+'_Imag')
    cax, kw = mpl.colorbar.make_axes(ax, shrink=.75, pad=.0)
    mpl.colorbar.ColorbarBase(cax, cmap=cmap, norm=norm)

def CNOT(P):
    tp = P[0]
    omega = P[1]
#    xita1 = P[2]
#    xita2 = P[3]

    

    global H,tlist,args,options
    
    f1 = (E[l11]-E[l10]+E[l01]-E[l00])/2    #CR pulse frequency
    f2 = (E[l11]-E[l01]+E[l10]-E[l00])/2    #X pulse frequency


    alpha = 0.05
    # w1 = '(-0.069066*np.pi/2*np.exp(-(t-20)**2/2.0/6**2))*(0<t<=40)'

    # w3 = '(0.03332*np.pi*(np.exp(-(t-60-tp)**2/2.0/6**2)*np.cos(t*omega3)+(t-60-tp)/2/6**2/'+str(eta_q[0])+'*np.exp(-(t-tp-60)**2/2.0/6**2)*np.cos(t*omega3-np.pi/2)))*((40+tp)<t<=80+tp)'
    
#    w1 = 'omega/2*((erf((t-8)/ramp)-erf((t-tp+8)/ramp))*(np.cos(f1*t)))*(0<t<=tp)'
    w1 = 'omega/2*((erf((t-8)/ramp)-erf((t-tp+8)/ramp))*(np.cos(f1*t))+D*(2*np.exp(-(t-8)**2/ramp**2)/np.sqrt(np.pi)/ramp-2*np.exp(-(t-tp+8)**2/ramp**2)/np.sqrt(np.pi)/ramp)/'+str(eta_q[0])+'*(np.cos(f1*t-np.pi/2)))*(0<t<=tp)'
#    w1 = 'omega*(np.exp(-(t-15)**2/2/5**2)*((0)<t<=15)+1*(15<t<=tp-15)+np.exp(-(t-tp+15)**2/2/5**2)*((tp-15)<t<=tp))*(np.cos(f1*t))'
    
    w2 = '(0.03332*2*np.pi*(np.exp(-(t-30-tp)**2/2.0/6**2)*np.cos(t*f2)+(t-30-tp)/2/6**2/'+str(eta_q[0])+'*np.exp(-(t-30-tp)**2/2.0/6**2)*np.cos(t*f2-np.pi/2)))*((10+tp)<t<=50+tp)'

    w3 = 'omega/2*((erf((t-tp-60-8)/ramp)-erf((t-tp-60-tp+8)/ramp))*(np.cos(f1*t+np.pi))+D*(2*np.exp(-(t-tp-60-8)**2/ramp**2)/np.sqrt(np.pi)/ramp-2*np.exp(-(t-tp-60-tp+8)**2/ramp**2)/np.sqrt(np.pi)/ramp)/'+str(eta_q[0])+'*(np.cos(f1*t+np.pi-np.pi/2)))*(tp+60<t<=2*tp+60)'
#    w3 = 'omega/2*(er f((t-tp-60-8)/ramp)-erf((t-tp-60-tp+8)/ramp))*(np.cos(f1*t+np.pi))*(tp+60<t<=2*tp+60)'
#    w3 = 'omega*(np.exp(-(t-tp-75)**2/2/5**2)*(t                                                                                                                                p+60<t<=tp+75)+1*(tp+75<t<=2*tp+45)+np.exp(-(t-2*tp-45)**2/2/5**2)*((2*tp+45)<t<=2*tp+60))*(np.cos(f1*t+np.pi))'

    w4 = '(0.03332*2*np.pi*(np.exp(-(t-90-2*tp)**2/2.0/6**2)*np.cos(t*f2)+(t-90-2*tp)/2/6**2/'+str(eta_q[0])+'*np.exp(-(t-90-2*tp)**2/2.0/6**2)*np.cos(t*f2-np.pi/2)))*((2*tp+70)<t<=2*tp+110)'
    
          
    w5 = 'alpha*omega/2*(erf((t-8)/ramp)-erf((t-tp+8)/ramp))*(np.cos(f1*t)+np.cos(f1*t-np.pi/2))*((0)<t<=tp)'

#    w6 = 'alpha*omega/2*(erf((t-8)/5)-erf((t-tp+8)/5))*(np.cos(f1*t+0.5*np.pi))*((0)<t<=tp)'
    w6 = 'alpha*(0.03332*2*np.pi*(np.exp(-(t-30-tp)**2/2.0/6**2)*np.cos(t*f2)+(t-30-tp)/2/6**2/'+str(eta_q[0])+'*np.exp(-(t-30-tp)**2/2.0/6**2)*np.cos(t*f2-np.pi/2)))*((10+tp)<t<=50+tp)'

    w7 = 'alpha*omega/2*(erf((t-tp-60-8)/ramp)-erf((t-tp-60-tp+8)/ramp))*(np.cos(f1*t+np.pi)+np.cos(f1*t+np.pi/2))*(tp+60<t<=2*tp+60)'

#    w8 = 'alpha*omega/2*(erf((t-tp-60-8)/5)-erf((t-tp-60-tp+8)/5))*(np.cos(f1*t+np.pi+0.5*np.pi))*(tp+60<t<=2*tp+60)'
    w8 = 'alpha*(0.03332*2*np.pi*(np.exp(-(t-90-2*tp)**2/2.0/6**2)*np.cos(t*f2)+(t-90-2*tp)/2/6**2/'+str(eta_q[0])+'*np.exp(-(t-90-2*tp)**2/2.0/6**2)*np.cos(t*f2-np.pi/2)))*((2*tp+70)<t<=2*tp+110)'

    args = {'omega':omega,'tp':tp , 'ramp': 5 , 'f1':f1 , 'f2':f2, 'alpha':alpha , 'D':1.274}

    
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
    T.append([tensor(basis(3,0),basis(3,0)),(tensor(basis(3,0),basis(3,0))+1j*tensor(basis(3,0),basis(3,1))).unit()])
    T.append([tensor(basis(3,0),basis(3,1)),(tensor(basis(3,0),basis(3,1))+1j*tensor(basis(3,0),basis(3,0))).unit()])
    T.append([tensor(basis(3,1),basis(3,0)),(tensor(basis(3,1),basis(3,0))-1j*tensor(basis(3,1),basis(3,1))).unit()])
    T.append([tensor(basis(3,1),basis(3,1)),(tensor(basis(3,1),basis(3,1))-1j*tensor(basis(3,1),basis(3,0))).unit()])
#    T.append([s00,(s00-1j*s01).unit()])
#    T.append([s01,(s01-1j*s00).unit()])
#    T.append([s10,(s10+1j*s11).unit()])
#    T.append([s11,(s11+1j*s10).unit()])

    fid = []
    leakage = []
    
    


    p = Pool(4)
    
    A = p.map(getfid,T)
    fid = [x[0] for x in A]
    leakage = [x[1] for x in A]
    outputstate = [x[2] for x in A]
    fid = np.array(fid)
    leakage = np.array(leakage)

        
    p.close()
    p.join()
#    print(P,np.mean(leakage),fid,np.mean(fid))
    gc.collect()
##    
#    
    process = np.column_stack([outputstate[i].data.toarray() for i in range(len(outputstate))])[(0,1,3,4),:]
    targetprocess = 1/np.sqrt(2)*np.array([[1,1j,0,0],[1j,1,0,0],[0,0,1,-1j],[0,0,-1j,1]])
    
    Error = np.dot(np.conjugate(np.transpose(targetprocess)),process)
    angle = np.angle(Error[0][0])
    Error = Error*np.exp(-1j*angle)#global phase
#    for i in range(2**2):
#        index = i
#        code = ''  #code of state
#        for j in range(2):
#            code = str(np.int(np.mod(index,2))) + code
#            index = np.floor(index/2)
#        if code[0] == '1':
#            Error[:,i] = Error[:,i]*np.exp(1j*xita1);
#        if code[1] == '1':
#            Error[:,i] = Error[:,i]*np.exp(1j*xita2);      
    Ufidelity = np.abs(np.trace(Error))/4


    gc.collect()
    
    
#    psi = [T[0][0],T[0][1]]
#    psi = [(s00+s10).unit(),(s00-1j*s01+s10+1j*s11).unit()]
#    psi = [tensor(basis(3,0),basis(3,0)),(tensor(basis(3,0),basis(3,0))+1j*tensor(basis(3,0),basis(3,1))).unit()]
#    fid,leakage,outputstate = getfid(psi)
    print(tp,omega/2/np.pi,(wq[0]-wq[1])/2/np.pi,g/2/np.pi,fid,np.mean(fid),Ufidelity)

#    Operator_View(process,'U_Simulation')

    ZZ = (E[l11]-E[l10]-(E[l01]+E[l00]))
#    ZZ = 2*g**2/(wq[0]-wq[1])/((wq[0]-wq[1])/(2*eta_q[1])-eta_q[1]/2/(wq[0]-wq[1]))
    test = np.pi/4/ZZ/(2*tp+60)
    print(ZZ/2/np.pi,test)
    
#
#    return(1-np.mean(Ufidelity))
#    return(Error)
    return(-Ufidelity)


if __name__=='__main__':
    starttime=time.time()
    

    
    global H0,E,S
    
    N = 3
    
    g = 0.0006804 * 2 * np.pi
    wq= np.array([5.100 , 5.02 ]) * 2 * np.pi
    eta_q=  np.array([-0.250 , -0.250]) * 2 * np.pi
#    wq= np.array([5.115 , 5.253  ]) * 2 * np.pi
#    eta_q=  np.array([-0.2876 , -0.2984]) * 2 * np.pi

                     
#    delta = 0.08047*2*np.pi
#    wq[1] = wq[0]-delta
    

    sm0=tensor(destroy(N),qeye(N))
    sm1=tensor(qeye(N),destroy(N))
    E_uc0 = tensor(basis(3,2)*basis(3,2).dag() , qeye(3)) 
    E_uc1 = tensor(qeye(3) , basis(3,2)*basis(3,2).dag())
    
    
    H0= (wq[0]) * sm0.dag()*sm0 + (wq[1]) * sm1.dag()*sm1 + eta_q[0]*E_uc0 + eta_q[1]*E_uc1 + g * (sm0.dag()+sm0) * (sm1.dag()+sm1)
    [E,S] = H0.eigenstates()
    l11 = findstate(S,'11');l10 = findstate(S,'10');l01 = findstate(S,'01');l00 = findstate(S,'00');
    
#    ZZ = 2*g**2/(wq[0]-wq[1])/(delta/2/eta_q[0]-eta_q[0]/2/delta)
#    ZZ = 2*g**2*(1/(delta-eta_q[0])-1/(delta+eta_q[0]))
#    ZZ = (E[l11]-E[l10]-(E[l01]+E[l00]))
#    test = np.pi/4/ZZ/(2*163.98+60)
#    print(test)

    
    
#    tplist = np.linspace(163.98-5,163.98+5,100)
#    fide = [];
#    for tp in tplist:
#        fide.append(CNOT([tp  , 0.08965*2*np.pi]))
#    figure();plot(2*tplist+60,fide);xlabel('T');ylabel('fidelity')
#    omegalist = np.linspace(0.08965-0.005,0.08965+0.005,101)*2*np.pi
#    fide = [];
#    for omega in omegalist:
#        fide.append(CNOT([163.98  , omega]))
#    figure();plot(omegalist/2/np.pi,fide);xlabel('omega');ylabel('fidelity')
    
#    fid = CNOT([51.35037378 ,  0.53879866,0,0])
#    fid = CNOT([196.88  , 0.09756*2*np.pi])
#    fid = CNOT([99.732])
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
    
    x0 = [100,0.09*2*np.pi]
    result = minimize(CNOT, x0, method="Nelder-Mead",options={'disp': True})
    print(result.x)
    
#    x0 = [50,0.060*2*np.pi]
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