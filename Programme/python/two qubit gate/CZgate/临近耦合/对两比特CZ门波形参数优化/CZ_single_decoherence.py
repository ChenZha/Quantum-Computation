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
    tlist = np.linspace(0,tp,resolution)
    w = interpolate.interp1d(tlist,delta*th,'slinear')
    if t<=tp and t>=0:
        w = w(t)
    else:
        w = 0
            
    return(w) 
def CZ1(t,args):
    tp = args['tp']
    delta = args['delta1']

    resolution = 1024
    tlist = np.linspace(0,tp,resolution)
    w = interpolate.interp1d(tlist,delta*th,'slinear')
    if t<=tp and t>=0:
        w = w(t)
    else:
        w = 0
            
    return(w) 
    
    

    

def CZgate(P):
    #==============================================================================
    '''Hamilton'''
    global Ee,H0
    H0 = 0
    HCoupling = g*(sm[0]+sm[0].dag())*(sm[1]+sm[1].dag())
    H_eta = eta_q[0] * E_uc[0] + eta_q[1] * E_uc[1]
    Hq = w_q[0]*sn[0] + w_q[1]*sn[1]
    H0 = Hq + H_eta + HCoupling
    
    
    E = H0.eigenstates()
    Ee = E[0]
    bastate = E[1]
    
    delta0 = P[0]
    delta1 = P[1]
    xita0 = P[2]
    xita1 = P[3]
    tp = 45
    
    Hd0 = [sn[0],CZ0]
    Hd1 = [sn[1],CZ1]
    H = [H0,Hd0,Hd1]

    args = {'tp':tp,'delta0':delta0,'delta1':delta1}
    
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
    options.rhs_reuse=True
    

    

    psi0 = tensor( (basis(3,0)).unit() , (basis(3,0)+basis(3,1)).unit())
#    psi0 = tensor( (basis(3,0)+basis(3,1)).unit() , (basis(3,0)+basis(3,1)).unit())




    tlist = np.linspace(0,tp,2*tp+1)

    result = mesolve(H,psi0,tlist,[],[],args = args,options = options)


#==============================================================================
#    n_x0 = [] ; n_y0 = [] ; n_z0 = [];
#    n_x1 = [] ; n_y1 = [] ; n_z1 = [];
#    for t in range(0,len(tlist)):
#        U0 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(Ee[1]-Ee[0])*tlist[t])*basis(3,1)*basis(3,1).dag()
#        U1 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(Ee[2]-Ee[0])*tlist[t])*basis(3,1)*basis(3,1).dag()
#        U = tensor(U0,U1)
##        U = (1j*H0*tlist[t]).expm()
#        
#        opx0 = U.dag()*sx[0]*U
#        opy0 = U.dag()*sy[0]*U
#        opz0 = sz[0]
#        opx1 = U.dag()*sx[1]*U
#        opy1 = U.dag()*sy[1]*U
#        opz1 = sz[1]
#        n_x0.append(expect(opx0,result.states[t]))
#        n_y0.append(expect(opy0,result.states[t]))
#        n_z0.append(expect(opz0,result.states[t]))
#        n_x1.append(expect(opx1,result.states[t]))
#        n_y1.append(expect(opy1,result.states[t]))
#        n_z1.append(expect(opz1,result.states[t]))
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
    
    '''
    fidelity
    '''
    U0 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(Ee[1]-Ee[0])*tlist[-1])*basis(3,1)*basis(3,1).dag()
    U1 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(Ee[2]-Ee[0])*tlist[-1])*basis(3,1)*basis(3,1).dag()
    UT = tensor(U0,U1)

    


    target = tensor( (basis(3,0)).unit() , (basis(3,0)+basis(3,1)).unit())
#    target = (tensor(basis(3,0),basis(3,0))+tensor(basis(3,0),basis(3,1))+tensor(basis(3,1),basis(3,0))-tensor(basis(3,1),basis(3,1))).unit()
    
    compen = tensor(Qobj([[1,0,0],[0,np.exp(1j*xita0),0],[0,0,np.exp(1j*2*xita0)]]) , Qobj([[1,0,0],[0,np.exp(1j*xita1),0],[0,0,np.exp(1j*2*xita1)]]))
    
    fid = fidelity(compen*UT*result.states[-1],target)


    print('fidelity = ',fid,P)

    #==============================================================================
    return(fid,UT,result.states[-1],UT*result.states[-1])
    
    
def decoherence(T):
    T1 = T[0]
    T2 = T[1]
    n_th = 0.01
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
    
    tp = 45
    delta0 = 0
    delta1 = -4.15551826
    xita0 = -0.15315065
    xita1 = -1.15565238
    
    Hd0 = [sn[0],CZ0]
    Hd1 = [sn[1],CZ1]
    H = [H0,Hd0,Hd1]

    args = {'tp':tp,'delta0':delta0,'delta1':delta1}
    
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
    

    
    

#    psi0 = tensor( (basis(3,1)).unit() , (basis(3,0)+basis(3,1)).unit())
    psi0 = tensor( (basis(3,0)+basis(3,1)).unit() , (basis(3,0)+basis(3,1)).unit())


    c_op_list = []
    gamma = 1.0/T1
    gamma_phi = 1.0/T2-1/2/T1
    c_op_list.append(np.sqrt(gamma * (1+n_th)) * sm[0])
    c_op_list.append(np.sqrt(gamma * n_th) * sm[0].dag())
    c_op_list.append(np.sqrt(2*gamma_phi) * sm[0].dag()*sm[0])
    c_op_list.append(np.sqrt(gamma * (1+n_th)) * sm[1])
    c_op_list.append(np.sqrt(gamma * n_th) * sm[1].dag())
    c_op_list.append(np.sqrt(2*gamma_phi) * sm[1].dag()*sm[1])
    
    tlist = np.linspace(0,tp,tp+1)

    result = mesolve(H,psi0,tlist,c_op_list,[],args = args,options = options)


#==============================================================================
#    n_x0 = [] ; n_y0 = [] ; n_z0 = [];
#    n_x1 = [] ; n_y1 = [] ; n_z1 = [];
#    for t in range(0,len(tlist)):
#        U0 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(Ee[1]-Ee[0])*tlist[t])*basis(3,1)*basis(3,1).dag()
#        U1 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(Ee[2]-Ee[0])*tlist[t])*basis(3,1)*basis(3,1).dag()
#        U = tensor(U0,U1)
##        U = (1j*H0*tlist[t]).expm()
#        
#        opx0 = U.dag()*sx[0]*U
#        opy0 = U.dag()*sy[0]*U
#        opz0 = sz[0]
#        opx1 = U.dag()*sx[1]*U
#        opy1 = U.dag()*sy[1]*U
#        opz1 = sz[1]
#        n_x0.append(expect(opx0,result.states[t]))
#        n_y0.append(expect(opy0,result.states[t]))
#        n_z0.append(expect(opz0,result.states[t]))
#        n_x1.append(expect(opx1,result.states[t]))
#        n_y1.append(expect(opy1,result.states[t]))
#        n_z1.append(expect(opz1,result.states[t]))
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
    
    '''
    fidelity
    '''
    U0 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(Ee[1]-Ee[0])*tlist[-1])*basis(3,1)*basis(3,1).dag()
    U1 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(Ee[2]-Ee[0])*tlist[-1])*basis(3,1)*basis(3,1).dag()
    UT = tensor(U0,U1)

    

#    target = tensor( (basis(3,1)).unit() , (basis(3,0)-basis(3,1)).unit())
    target = (tensor(basis(3,0),basis(3,0))+tensor(basis(3,0),basis(3,1))+tensor(basis(3,1),basis(3,0))-tensor(basis(3,1),basis(3,1))).unit()

    compen = tensor(Qobj([[1,0,0],[0,np.exp(1j*xita0),0],[0,0,np.exp(1j*2*xita0)]]) , Qobj([[1,0,0],[0,np.exp(1j*xita1),0],[0,0,np.exp(1j*2*xita1)]]))
    
    fid = fidelity(compen*UT*result.states[-1]*UT.dag()*compen.dag(),target)

    print('fidelity = ',fid,T)
    

    #==============================================================================
    return(fid)
    
    
    

    
    
    
    
    
    
    
    
if __name__=='__main__':
    
    starttime  = time.time()
    
    
    global th
    th = initial_wave()
    
    
    N = 3
    g = 0.0138 * 2 * np.pi
    w_q= np.array([4.3 , 5.18  ]) * 2 * np.pi
    eta_q=  np.array([-0.230 , -0.216]) * 2 * np.pi
    n= 0
    
    #==============================================================================
    sm = np.array([tensor(destroy(3),qeye(3)) , tensor(qeye(3),destroy(3))])
    E_uc = np.array([tensor(basis(3,2)*basis(3,2).dag(),qeye(3)) , tensor(qeye(3), basis(3,2)*basis(3,2).dag())])
    E_e = np.array([tensor(basis(3,1)*basis(3,1).dag(),qeye(3)),tensor(qeye(3),basis(3,1)*basis(3,1).dag())])
    E_g = np.array([tensor(basis(3,0)*basis(3,0).dag(),qeye(3)) , tensor(qeye(3),basis(3,0)*basis(3,0).dag())])
    sn = np.array([sm[0].dag()*sm[0] , sm[1].dag()*sm[1]])
    sx = np.array([sm[0].dag()+sm[0],sm[1].dag()+sm[1]]);
    sy = np.array([1j*(sm[0].dag()-sm[0]) , 1j*(sm[1].dag()-sm[1])]);
    sz = np.array([E_g[0] - E_e[0] , E_g[1] - E_e[1]])
    
    
    
#    E = CZgate([98,1.272])
    
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


#    fid = CZgate([ 0.    ,     -4.15551826 , -0.15315065 ,-1.15565238 ])
#    decoherence([10*1000,20*1000])

    a = np.linspace(0.05,1,16)*1000
    b = np.linspace(1,8,12)*1000
    T2 = np.append(a,b)
    T = [[20*1000,T2[i]] for i in range(0,len(T2))]
    p = Pool(14)
    

    z = p.map(decoherence,T)
    p.close()
    p.join()
    figure();plot(T2,z);xlabel('T2');ylabel('fidelity');title('++  T1 = 20')


    endtime  = time.time()
    
    print('used time:',endtime-starttime,'s')
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
                
