#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Jul 16 20:44:08 2017

@author: chen
"""
''' 寻找CZ波形参数，两个qubit的能级都要调，然后进行相位补偿，参数: (tp),delta0,delta1,xita0,xita1 '''
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

def initial_wave():
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

    return(th)

def CZ0(t,args):
    tp = args['tp']
    delta = args['delta0']

    resolution = 1024
    tlistCZ = np.linspace(0,tp,resolution)
    w = interpolate.interp1d(tlistCZ,delta*th,'slinear')
    if t<=tp and t>=0:
        w = w(t)
    else:
        w = 0
            
    return(w) 
def CZ1(t,args):
    tp = args['tp']
    delta = args['delta1']

    resolution = 1024
    tlistCZ = np.linspace(0,tp,resolution)
    w = interpolate.interp1d(tlistCZ,delta*th,'slinear')
    if t<=tp and t>=0:
        w = w(t)
    else:
        w = 0
            
    return(w) 


def getfid(T):
    psi = T[0]
    target = T[1]
    output = mesolve(H,psi,tlist,[],[],args = args,options = options)
    
    U1 = basis(N,0)*basis(N,0).dag()+np.exp(1j*(E[l10]-E[l00])*tlist[-1])*basis(N,1)*basis(N,1).dag()
    U2 = basis(N,0)*basis(N,0).dag()+np.exp(1j*(E[l01]-E[l00])*tlist[-1])*basis(N,1)*basis(N,1).dag()
    UT = tensor(U1,U2)
    
    fid = fidelity(UT*output.states[-1],target)
    
    leakage = [expect(E_uc[0],output.states[-1]) , expect(E_uc[1],output.states[-1])]
    
    return([fid,leakage,UT*output.states[-1]])
    
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
    
    global H0,E,S,l11,l10,l01,l00

    delta0 = P[0]
    delta1 = P[1]
    xita0 = P[2]
    xita1 = P[3]
    tp = 45
    
    
    H0= (wq[0]) * sn[0] + (wq[1]) * sn[1] + eta_q[0]*E_uc[0] + eta_q[1]*E_uc[1] + g * sx[0] * sx[1]
    [E,S] = H0.eigenstates()
    l11 = findstate(S,'11');l10 = findstate(S,'10');l01 = findstate(S,'01');l00 = findstate(S,'00');

    ZZ = E[l11]-E[l10]-E[l01]+E[l00]

    global H,tlist,args,options
    
    Hd0 = [sn[0],CZ0]
    Hd1 = [sn[1],CZ1]
    H = [H0,Hd0,Hd1]


    args = {'tp':tp , 'delta0':delta0 , 'delta1':delta1 , 'xita0':xita0 , 'xita1':xita1}

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

    
    # fig ,axes = plt.subplots(1,2)
    # axes[0][0].plot(tlist,np.vectorize(CZ0)(tlist,args),label = 'CZ0');axes[0][0].set_xlabel('t');axes[0][0].set_ylabel('CZ0')
    # axes[0][1].plot(tlist,np.vectorize(CZ1)(tlist,args),label = 'CZ1');axes[0][1].set_xlabel('t');axes[0][1].set_ylabel('CZ1')


    T = []
    T.append([tensor(basis(3,0),basis(3,0)),tensor(basis(3,0),basis(3,0))])
    T.append([tensor(basis(3,0),basis(3,1)),tensor(basis(3,0),basis(3,1))])
    T.append([tensor(basis(3,1),basis(3,0)),tensor(basis(3,1),basis(3,0))])
    T.append([tensor(basis(3,1),basis(3,1)),-tensor(basis(3,1),basis(3,1))])


    fid = []
    leakage0 = []
    leakage1 = []
    outputstate = []
    
    


    p = Pool(4)
   
    A = p.map(getfid,T)
    fid = [x[0] for x in A]
    leakage = [x[1] for x in A]
    outputstate = [x[2] for x in A]
    # fid = np.array(fid)
    # leakage = np.array(leakage)

        
    p.close()
    p.join()

#    for phi in T:
#        A = getfid(phi)
#        fid.append(A[0])
#        leakage0.append(A[1][0])
#        leakage1.append(A[1][1])
#        outputstate.append(A[2])
#    fid = np.array(fid)
#    leakage0 = np.array(leakage0)
#    leakage1 = np.array(leakage1)
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


    print(P[0]/2/np.pi,P[1]/2/np.pi,P[2]/np.pi*180,P[3]/np.pi*180,np.mean(fid),Ufidelity)
    return(-Ufidelity)






if __name__=='__main__':
    starttime=time.time()
    

    
    global H0,E,S,th
    
    N = 3
    
    g = 0.0138 * 2 * np.pi
    wq= np.array([4.3 , 5.18  ]) * 2 * np.pi
    eta_q=  np.array([-0.230 , -0.216]) * 2 * np.pi

    th = initial_wave()
    

    sm = np.array([tensor(destroy(3),qeye(3)) , tensor(qeye(3),destroy(3))])
    E_uc = np.array([tensor(basis(3,2)*basis(3,2).dag(),qeye(3)) , tensor(qeye(3), basis(3,2)*basis(3,2).dag())])
    E_e = np.array([tensor(basis(3,1)*basis(3,1).dag(),qeye(3)),tensor(qeye(3),basis(3,1)*basis(3,1).dag())])
    E_g = np.array([tensor(basis(3,0)*basis(3,0).dag(),qeye(3)) , tensor(qeye(3),basis(3,0)*basis(3,0).dag())])
    sn = np.array([sm[0].dag()*sm[0] , sm[1].dag()*sm[1]])
    sx = np.array([sm[0].dag()+sm[0],sm[1].dag()+sm[1]]);
    sy = np.array([1j*(sm[0].dag()-sm[0]) , 1j*(sm[1].dag()-sm[1])]);
    sz = np.array([E_g[0] - E_e[0] , E_g[1] - E_e[1]])
    

#    fid = CNOT([0.    ,     -4.15551826 , -0.15315065,-1.15565238])
    # x_l = np.array([0*2*np.pi , -0.9*2*np.pi , -np.pi , -np.pi])#delta0,delta1,xita0,xita1
    # x_u = np.array([0.9*2*np.pi , 0*2*np.pi , np.pi , np.pi])
    # de(CNOT,n = 4,m_size = 25,f = 0.9 , cr = 0.5 ,S = 1 , iterate_time = 300,x_l = x_l,x_u = x_u,inputfile = None)
    
    x0 = [0.    ,     -4.15551826 , -0.15315065,-1.15565238]
    result = minimize(CNOT , x0 , method="Nelder-Mead",options={'disp': True})
    print(result)


    endtime  = time.time()
    
    print('used time:',endtime-starttime,'s')

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
                
