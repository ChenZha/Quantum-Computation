#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Nov 26 15:21:58 2017

@author: chen
"""

import time 
import csv
import matplotlib.pyplot as plt
import matplotlib as mpl
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


def GetOperator(Num_Q):
    cmdstr=''
    sm=[]
    for II in range(0,Num_Q):
        cmdstr=''
        for JJ in range(0,Num_Q):
            if II==JJ:
                cmdstr+='destroy(3),'
            else:
                cmdstr+='qeye(3),'
        sm.append(eval('tensor('+cmdstr+')'))

    E_uc=[]
    for II in range(0,Num_Q):
        cmdstr=''
        for JJ in range(0,Num_Q):
            if II==JJ:
                cmdstr+='basis(3,2)*basis(3,2).dag(),'
            else:
                cmdstr+='qeye(3),'
        E_uc.append(eval('tensor('+cmdstr+')'))
    
    E_e=[]
    for II in range(0,Num_Q):
        cmdstr=''
        for JJ in range(0,Num_Q):
            if II==JJ:
                cmdstr+='basis(3,1)*basis(3,1).dag(),'
            else:
                cmdstr+='qeye(3),'
        E_e.append(eval('tensor('+cmdstr+')'))
    
    E_g=[]
    for II in range(0,Num_Q):
        cmdstr=''
        for JJ in range(0,Num_Q):
            if II==JJ:
                cmdstr+='basis(3,0)*basis(3,0).dag(),'
            else:
                cmdstr+='qeye(3),'
        E_g.append(eval('tensor('+cmdstr+')'))
        
    Sn=[]
    Sx=[]
    Sy=[]
    for II in range(0,Num_Q):
        Sn.append(sm[II].dag()*sm[II])
        Sx.append(sm[II].dag()+sm[II])
        Sy.append(1j*(sm[II].dag()-sm[II]))   
        
    return sm, E_uc, E_e, E_g, Sn, Sx, Sy

def getfid(T):
    psi = T[0]
    target = T[1]
    output = mesolve(H,psi,tlist,[],[],args = args,options = options)
    
    U1 = basis(N,0)*basis(N,0).dag()+np.exp(1j*(E[l1111]-E[l0111]+E[l1011]-E[l0011])/2*tlist[-1])*basis(N,1)*basis(N,1).dag()
    U2 = basis(N,0)*basis(N,0).dag()+np.exp(1j*(E[l1111]-E[l1011]+E[l0101]-E[l0001])/2*tlist[-1])*basis(N,1)*basis(N,1).dag()
    U3 = basis(N,0)*basis(N,0).dag()+np.exp(1j*(E[l1111]-E[l1101]+E[l1010]-E[l1000])/2*tlist[-1])*basis(N,1)*basis(N,1).dag()
    U4 = basis(N,0)*basis(N,0).dag()+np.exp(1j*(E[l1111]-E[l1110]+E[l1101]-E[l1100])/2*tlist[-1])*basis(N,1)*basis(N,1).dag()
    
    UT = tensor(U1,U2,U3,U4)
    
    fid = fidelity(UT*output.states[-1]*output.states[-1].dag()*UT.dag(),target)
    
    leakage = [expect(E_uc[0],output.states[-1]) , expect(E_uc[1],output.states[-1])]
    
    
#==============================================================================
#    n_x = np.zeros([4,len(tlist)]) ;
#    n_y = np.zeros([4,len(tlist)]) ;
#    n_z = np.zeros([4,len(tlist)]) ;
#    l = np.zeros([4,len(tlist)]);
#    for t in range(0,len(tlist)):
#        U1 = basis(N,0)*basis(N,0).dag()+np.exp(1j*(E[l1111]-E[l0111]+E[l1011]-E[l0011])/2*tlist[t])*basis(N,1)*basis(N,1).dag()
#        U2 = basis(N,0)*basis(N,0).dag()+np.exp(1j*(E[l1111]-E[l1011]+E[l0101]-E[l0001])/2*tlist[t])*basis(N,1)*basis(N,1).dag()
#        U3 = basis(N,0)*basis(N,0).dag()+np.exp(1j*(E[l1111]-E[l1101]+E[l1010]-E[l1000])/2*tlist[t])*basis(N,1)*basis(N,1).dag()
#        U4 = basis(N,0)*basis(N,0).dag()+np.exp(1j*(E[l1111]-E[l1110]+E[l1101]-E[l1100])/2*tlist[t])*basis(N,1)*basis(N,1).dag()
#        U = tensor(U1,U2,U3,U4)
#        for i in range(4):
#            n_x[i][t] = expect(U.dag()*(sm[i].dag()+sm[i])*U,output.states[t])
#            n_y[i][t] = expect(U.dag()*(1j*sm[i].dag()-1j*sm[i])*U,output.states[t])
#            n_z[i][t] = expect(U.dag()*(tensor(qeye(3),qeye(3),qeye(3),qeye(3))-2*sm[i].dag()*sm[i])*U,output.states[t])
#            l[i][t] = expect(E_uc[i],output.states[t])
##
##
##        
##
##
#    fig ,axes = plt.subplots(2,2)
#    axes[0][0].plot(tlist,n_x[0],label = 'X0');
#    axes[0][0].plot(tlist,n_y[0],label = 'Y0');
#    axes[0][0].plot(tlist,n_z[0],label = 'Z0');axes[0][0].set_xlabel('t');axes[0][0].set_ylabel('Population')
#    axes[0][0].legend(loc = 'upper left');plt.show()
#
#    axes[0][1].plot(tlist,n_x[1],label = 'X1');
#    axes[0][1].plot(tlist,n_y[1],label = 'Y1');
#    axes[0][1].plot(tlist,n_z[1],label = 'Z1');axes[0][1].set_xlabel('t');axes[0][1].set_ylabel('Population')
#    axes[0][1].legend(loc = 'upper left');plt.show()
#
#    axes[1][0].plot(tlist,n_x[2],label = 'X2');
#    axes[1][0].plot(tlist,n_y[2],label = 'Y2');
#    axes[1][0].plot(tlist,n_z[2],label = 'Z2');axes[1][0].set_xlabel('t');axes[1][0].set_ylabel('Population')
#    axes[1][0].legend(loc = 'upper left');plt.show()
#
#    axes[1][1].plot(tlist,n_x[3],label = 'X3');
#    axes[1][1].plot(tlist,n_y[3],label = 'Y3');
#    axes[1][1].plot(tlist,n_z[3],label = 'Z3');axes[1][1].set_xlabel('t');axes[1][1].set_ylabel('Population')
#    axes[1][1].legend(loc = 'upper left');plt.show();plt.tight_layout()
##
##    fig ,axes = plt.subplots(2,2)
##    axes[0][0].plot(tlist,l[0]);axes[0][0].set_xlabel('t');axes[0][0].set_ylabel('L0')
##    axes[0][1].plot(tlist,l[1]);axes[0][1].set_xlabel('t');axes[0][1].set_ylabel('L1')
##    axes[1][0].plot(tlist,l[2]);axes[1][0].set_xlabel('t');axes[1][0].set_ylabel('L2')
##    axes[1][1].plot(tlist,l[3]);axes[1][1].set_xlabel('t');axes[1][1].set_ylabel('L3')
##
#    sphere = Bloch()
#    sphere.add_points([n_x[0] , n_y[0] , n_z[0]])
#    sphere.add_vectors([n_x[0][-1],n_y[0][-1],n_z[0][-1]])
#    sphere.make_sphere() 
#    sphere = Bloch()
#    sphere.add_points([n_x[1] , n_y[1] , n_z[1]])
#    sphere.add_vectors([n_x[1][-1],n_y[1][-1],n_z[1][-1]])
#    sphere.make_sphere() 
#    sphere = Bloch()
#    sphere.add_points([n_x[2] , n_y[2] , n_z[2]])
#    sphere.add_vectors([n_x[2][-1],n_y[2][-1],n_z[2][-1]])
#    sphere.make_sphere() 
#    sphere = Bloch()
#    sphere.add_points([n_x[3] , n_y[3] , n_z[3]])
#    sphere.add_vectors([n_x[3][-1],n_y[3][-1],n_z[3][-1]])
#    sphere.make_sphere() 
#    plt.show() 
    
##==============================================================================
    return([fid,leakage[0],UT*output.states[-1]])

    
def findstate(S,state):
    l = None
    e0 = eval(state[0])
    e1 = eval(state[1])
    e2 = eval(state[2])
    e3 = eval(state[3])
    for i in range(81):
        s0 = ptrace(S[i],0)[e0][0][e0]
        s1 = ptrace(S[i],1)[e1][0][e1]
        s2 = ptrace(S[i],2)[e2][0][e2]
        s3 = ptrace(S[i],3)[e3][0][e3]
        if abs(s0)>=0.5 and abs(s1)>=0.5  and abs(s2)>=0.5 and abs(s3)>=0.5:
            l = i
    if l == None:
        print('No state_'+state)
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
    xita1 = P[2]
    xita2 = P[3]

    

    global H,tlist,args,options
    
    
    f1 = (E[l1111]-E[l0111]+E[l1011]-E[l0011])/2#qubit1 X波频率
    f2 = (E[l1111]-E[l1011]+E[l0101]-E[l0001])/2#qubit2 X波频率
    f3 = (E[l1111]-E[l1101]+E[l1010]-E[l1000])/2#qubit3 X波频率
    f4 = (E[l1111]-E[l1110]+E[l1101]-E[l1100])/2#qubit4 X波频率
    

   
#    w21 = 'omega/2*((erf((t-8)/ramp)-erf((t-tp+8)/ramp))*(np.cos(f3*t)))*(0<t<=tp)'
    w21 = 'omega/2*((erf((t-8)/ramp)-erf((t-tp+8)/ramp))*(np.cos(f3*t))+D*(2*np.exp(-(t-8)**2/ramp**2)/np.sqrt(np.pi)/ramp-2*np.exp(-(t-tp+8)**2/ramp**2)/np.sqrt(np.pi)/ramp)/'+str(eta_q[0])+'*(np.cos(f3*t-np.pi/2)))*(0<t<=tp)'
#    w21 = 'omega*(np.exp(-(t-15)**2/2/5**2)*((0)<t<=15)+1*(15<t<=tp-15)+np.exp(-(t-tp+15)**2/2/5**2)*((tp-15)<t<=tp))*(np.cos(f3*t))'
    
    w22 = '(0.03332*2*np.pi*(np.exp(-(t-30-tp)**2/2.0/6**2)*np.cos(t*f2)+(t-30-tp)/2/6**2/'+str(eta_q[1])+'*np.exp(-(t-30-tp)**2/2.0/6**2)*np.cos(t*f2-np.pi/2)))*((10+tp)<t<=50+tp)'

    w23 = 'omega/2*((erf((t-tp-60-8)/ramp)-erf((t-tp-60-tp+8)/ramp))*(np.cos(f3*t+np.pi))+D*(2*np.exp(-(t-tp-60-8)**2/ramp**2)/np.sqrt(np.pi)/ramp-2*np.exp(-(t-tp-60-tp+8)**2/ramp**2)/np.sqrt(np.pi)/ramp)/'+str(eta_q[0])+'*(np.cos(f3*t+np.pi-np.pi/2)))*(tp+60<t<=2*tp+60)'
#    w23 = 'omega/2*(erf((t-tp-60-8)/ramp)-erf((t-tp-60-tp+8)/ramp))*(np.cos(f3*t+np.pi))*(tp+60<t<=2*tp+60)'
#    w23 = 'omega*(np.exp(-(t-tp-75)**2/2/5**2)*(tp+60<t<=tp+75)+1*(tp+75<t<=2*tp+45)+np.exp(-(t-2*tp-45)**2/2/5**2)*((2*tp+45)<t<=2*tp+60))*(np.cos(f3*t+np.pi))'

    w24 = '(0.03332*2*np.pi*(np.exp(-(t-90-2*tp)**2/2.0/6**2)*np.cos(t*f2)+(t-90-2*tp)/2/6**2/'+str(eta_q[1])+'*np.exp(-(t-90-2*tp)**2/2.0/6**2)*np.cos(t*f2-np.pi/2)))*((2*tp+70)<t<=2*tp+110)'
    
           
#    w12 = '(0.03332*2*np.pi*(np.exp(-(t-30-tp)**2/2.0/6**2)*np.cos(t*f1)+(t-30-tp)/2/6**2/'+str(eta_q[0])+'*np.exp(-(t-30-tp)**2/2.0/6**2)*np.cos(t*f1-np.pi/2)))*((10+tp)<t<=50+tp)'
    w12 = '(0.03332*2*np.pi*(np.exp(-(t-tp/2)**2/2.0/6**2)*np.cos(t*f1)+(t-tp/2)/2/6**2/'+str(eta_q[0])+'*np.exp(-(t-tp/2)**2/2.0/6**2)*np.cos(t*f1-np.pi/2)))*((0)<t<=tp)'

#    w14 = '(0.03332*2*np.pi*(np.exp(-(t-90-2*tp)**2/2.0/6**2)*np.cos(t*f1)+(t-90-2*tp)/2/6**2/'+str(eta_q[0])+'*np.exp(-(t-90-2*tp)**2/2.0/6**2)*np.cos(t*f1-np.pi/2)))*((2*tp+70)<t<=2*tp+110)'
    w14 = '(0.03332*2*np.pi*(np.exp(-(t-60-3*tp/2)**2/2.0/6**2)*np.cos(t*f1)+(t-60-3*tp/2)/2/6**2/'+str(eta_q[0])+'*np.exp(-(t-60-3*tp/2)**2/2.0/6**2)*np.cos(t*f1-np.pi/2)))*(tp+60<t<=2*tp+60)'
         
    
#    w42 = '(0.03332*2*np.pi*(np.exp(-(t-30-tp)**2/2.0/6**2)*np.cos(t*f4)+(t-30-tp)/2/6**2/'+str(eta_q[3])+'*np.exp(-(t-30-tp)**2/2.0/6**2)*np.cos(t*f4-np.pi/2)))*((10+tp)<t<=50+tp)'
    w42 = '(0.03332*2*np.pi*(np.exp(-(t-tp/2)**2/2.0/6**2)*np.cos(t*f4)+(t-tp/2)/2/6**2/'+str(eta_q[3])+'*np.exp(-(t-tp/2)**2/2.0/6**2)*np.cos(t*f4-np.pi/2)))*((0)<t<=tp)'

#    w44 = '(0.03332*2*np.pi*(np.exp(-(t-90-2*tp)**2/2.0/6**2)*np.cos(t*f4)+(t-90-2*tp)/2/6**2/'+str(eta_q[3])+'*np.exp(-(t-90-2*tp)**2/2.0/6**2)*np.cos(t*f4-np.pi/2)))*((2*tp+70)<t<=2*tp+110)'
    w44 = '(0.03332*2*np.pi*(np.exp(-(t-60-3*tp/2)**2/2.0/6**2)*np.cos(t*f4)+(t-60-3*tp/2)/2/6**2/'+str(eta_q[3])+'*np.exp(-(t-60-3*tp/2)**2/2.0/6**2)*np.cos(t*f4-np.pi/2)))*(tp+60<t<=2*tp+60)'
    

    args = {'omega':omega,'tp':tp , 'ramp': 5 , 'f1':f1 , 'f2':f2, 'f3':f3 , 'f4':f4 , 'D':-0.5}

    
    H1 = [sm[1]+sm[1].dag(),w21]
    H2 = [sm[1]+sm[1].dag(),w22]
    H3 = [sm[1]+sm[1].dag(),w23]
    H4 = [sm[1]+sm[1].dag(),w24]
    H5 = [sm[0]+sm[0].dag(),w12]
    H6 = [sm[0]+sm[0].dag(),w14]
    H7 = [sm[3]+sm[3].dag(),w42]
    H8 = [sm[3]+sm[3].dag(),w44]
    
    H = [H0,H1,H2,H3,H4,H5,H6,H7,H8]
#    H =  [H0,H1,H2,H3,H4]

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

    

    

    Phi = []
    Phi.append([tensor(basis(3,0),basis(3,0)),(tensor(basis(3,0),basis(3,0))+1j*tensor(basis(3,0),basis(3,1))).unit()])
    Phi.append([tensor(basis(3,0),basis(3,1)),(tensor(basis(3,0),basis(3,1))+1j*tensor(basis(3,0),basis(3,0))).unit()])
    Phi.append([tensor(basis(3,1),basis(3,0)),(tensor(basis(3,1),basis(3,0))-1j*tensor(basis(3,1),basis(3,1))).unit()])
    Phi.append([tensor(basis(3,1),basis(3,1)),(tensor(basis(3,1),basis(3,1))-1j*tensor(basis(3,1),basis(3,0))).unit()])
    T = []
    for i in range(2):
        for j in range(2):
            for k in range(2):
                for l in range(2):
                    m = j*2+k
                    T.append([tensor(basis(3,i),Phi[m][0],basis(3,l)),tensor(basis(3,i),Phi[m][1],basis(3,l))])
                    

    fid = []
    leakage = []
    
    

    p = Pool(16)
    
    A = p.map(getfid,T)
    fid = [x[0] for x in A]
    leakage = [x[1] for x in A]
    outputstate = [x[2] for x in A]
    fid = np.array(fid)
    leakage = np.array(leakage)

        
    p.close()
    p.join()
    gc.collect()

    labels = []
    for i in range(2**4):
        index = i
        code = ''  #code of state
        for j in range(4):
            code = str(np.int(np.mod(index,2))) + code
            
            index = np.floor(index/2)

        labels.append(code)
        
    loc = []#各个基矢在多比特3能级系统中，能级的位置
    for c in labels:
        l = 0
        for index , i in enumerate(c):
            l+=eval(i)*3**(3-index)
        loc.append(l)
        
        
    process = np.column_stack([outputstate[i].data.toarray() for i in range(len(outputstate))])[loc,:]
    angle = np.angle(process[0][0])
    process = process*np.exp(-1j*angle)#global phase
    
    for i in range(2**4):
        index = i
        code = ''  #code of state
        for j in range(4):
            code = str(np.int(np.mod(index,2))) + code
            index = np.floor(index/2)
        if code[1] == '1':
            process[:,i] = process[:,i]*np.exp(1j*xita1);
        if code[2] == '1':
            process[:,i] = process[:,i]*np.exp(1j*xita2);           
        
#    process[:,2] = process[:,2]*np.exp(1j*xita1);process[:,3] = process[:,3]*np.exp(1j*xita1)#qubit 0 relative phase
#    process[:,1] = process[:,1]*np.exp(1j*xita2);process[:,3] = process[:,3]*np.exp(1j*xita2)#qubit 1 relative phase
    
    targetprocess = 1/np.sqrt(2)*np.array([[1,1j,0,0],[1j,1,0,0],[0,0,1,-1j],[0,0,-1j,1]])
    targetprocess = tensor(qeye(2),Qobj(targetprocess),qeye(2))
    targetprocess = targetprocess.data.toarray()
    Ufidelity = np.abs(np.trace(np.dot(np.conjugate(np.transpose(targetprocess)),process)))/16

    

    gc.collect()

    
    
    
#    Operator_View(process,'U_Simulation')
#    Operator_View(targetprocess,'U_Ideal')
#    Operator_View(np.dot(np.conjugate(np.transpose(targetprocess)),process),'U_error')


#    fid,leakage,outputstate = getfid([(T[0][0]+T[1][0]).unit() , (T[0][1]+T[1][1]).unit()])
#    print(P,np.mean(leakage),np.mean(fid))


    print(P[0],P[1]/2/np.pi,g/2/np.pi,(np.diff(wq))/2/np.pi,np.mean(fid),Ufidelity)
    

    return(Ufidelity)
#    return(process,T)



if __name__=='__main__':
    starttime=time.time()
    N = 3
    NumQ = 4
    sm, E_uc, E_e, E_g, Sn, Sx, Sy = GetOperator(NumQ)
    
    global H0,E,S
    
    wrange = np.linspace(4.990,5.030,15)*2*np.pi
    wfid = []
    for w in wrange:
        g = np.array([0.0017 , 0.0017 , 0.0017]) * 2 * np.pi
        wq= np.array([5.200 , 5.100 , 4.930 , 3.900 ]) * 2 * np.pi
        eta_q=  np.array([-0.250 , -0.250 , -0.250 , -0.250]) * 2 * np.pi
        
        wq[0] = w

        HCoupling=0
        for II in range(0,NumQ-1):
            HCoupling+= g[II]* (sm[II].dag()  + sm[II])* (sm[II+1].dag()  + sm[II+1]) 
        H0=HCoupling
        for II in range(0,NumQ):
            H0+= eta_q[II]*E_uc[II]+wq[II]*Sn[II]
        [E,S] = H0.eigenstates()
        
        l1111 = findstate(S,'1111');l0111 = findstate(S,'0111');l1011 = findstate(S,'1011');l0011 = findstate(S,'0011');
        l1111 = findstate(S,'1111');l1011 = findstate(S,'1011');l0101 = findstate(S,'0101');l0001 = findstate(S,'0001');
        l1111 = findstate(S,'1111');l1101 = findstate(S,'1101');l1010 = findstate(S,'1010');l1000 = findstate(S,'1000');
        l1111 = findstate(S,'1111');l1110 = findstate(S,'1110');l1101 = findstate(S,'1101');l1100 = findstate(S,'1100');
                         
                         
        fid = CNOT([108.19,0.4*(wq[1]-wq[2]),0,0])
        wfid.append(fid)
        gc.collect()
    figure();plot(wrange/2/np.pi,wfid);xlabel('wq0');ylabel('fidelity');title(str((wq[1]-wq[2])/2/np.pi))
        
#    g = np.array([0.0017 , 0.0017 , 0.0017]) * 2 * np.pi
#    wq= np.array([3.800 , 5.100 , 5.00 , 3.155 ]) * 2 * np.pi
#    eta_q=  np.array([-0.250 , -0.250 , -0.250 , -0.250]) * 2 * np.pi
#    HCoupling=0
#    for II in range(0,NumQ-1):
#        HCoupling+= g[II]* (sm[II].dag()  + sm[II])* (sm[II+1].dag()  + sm[II+1]) 
#    H0=HCoupling
#    for II in range(0,NumQ):
#        H0+= eta_q[II]*E_uc[II]+wq[II]*Sn[II]
#    [E,S] = H0.eigenstates()
#    
#    l1111 = findstate(S,'1111');l0111 = findstate(S,'0111');l1011 = findstate(S,'1011');l0011 = findstate(S,'0011');
#    l1111 = findstate(S,'1111');l1011 = findstate(S,'1011');l0101 = findstate(S,'0101');l0001 = findstate(S,'0001');
#    l1111 = findstate(S,'1111');l1101 = findstate(S,'1101');l1010 = findstate(S,'1010');l1000 = findstate(S,'1000');
#    l1111 = findstate(S,'1111');l1110 = findstate(S,'1110');l1101 = findstate(S,'1101');l1100 = findstate(S,'1100');
                         
    
    
    
    
    
    

    
#    fid = CNOT([70.1805137306,1.10522763])
#    fid = CNOT([134.069  , 0.04666*2*np.pi,0,0])
#    fid = CNOT([86.0,0.07483*2*np.pi,0,0])
#    print(fid)


    
#    x0 = [120,0.045*2*np.pi,0,0]
#    result = minimize(CNOT, x0, method="Nelder-Mead",options={'disp': True})
#    print(result.x[0],result.x[1])


    

    finishtime=time.time()
    print( 'Time used: ', (finishtime-starttime), 's')