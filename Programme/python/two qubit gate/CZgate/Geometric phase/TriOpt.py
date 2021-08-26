#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Jun  1 14:55:24 2017

@author: chen
"""

from qutip import *
import numpy as np
import matplotlib.pyplot as plt 
from pylab import *
from time import clock
from scipy.special import *
from scipy.optimize import *
from multiprocessing import Pool


def CreateBasicOperator(Num_Q):
    N = 16
    cmdstr=''
    for II in range(0,Num_Q):
        cmdstr+='qeye(3),'
    a= eval('tensor(destroy(N),'+cmdstr+')')

    sm=[]
    for II in range(0,Num_Q):
        cmdstr=''
        for JJ in range(0,Num_Q):
            if II==JJ:
                cmdstr+='destroy(3),'
            else:
                cmdstr+='qeye(3),'
        sm.append(eval('tensor(qeye(N),'+cmdstr+')'))

    smm=[]
    for II in range(0,Num_Q):
        cmdstr=''
        for JJ in range(0,Num_Q):
            if II==JJ:
                cmdstr+='basis(3,2)*basis(3,2).dag(),'
            else:
                cmdstr+='qeye(3),'
        smm.append(eval('tensor(qeye(N),'+cmdstr+')'))
    
    E_e=[]
    for II in range(0,Num_Q):
        cmdstr=''
        for JJ in range(0,Num_Q):
            if II==JJ:
                cmdstr+='basis(3,1)*basis(3,1).dag(),'
            else:
                cmdstr+='qeye(3),'
        E_e.append(eval('tensor(qeye(N),'+cmdstr+')'))
    
    E_g=[]
    for II in range(0,Num_Q):
        cmdstr=''
        for JJ in range(0,Num_Q):
            if II==JJ:
                cmdstr+='basis(3,0)*basis(3,0).dag(),'
            else:
                cmdstr+='qeye(3),'
        E_g.append(eval('tensor(qeye(N),'+cmdstr+')'))
        
    sn=[]
    sx=[]
    sy=[]
    for II in range(0,Num_Q):
        sn.append(sm[II].dag()*sm[II])
        sx.append(sm[II].dag()+sm[II])
        sy.append(1j*(sm[II].dag()-sm[II]))   
        
    return a, sm, smm, E_e, E_g, sn, sx, sy
def Two_GeoCZ_0(d):
    ome = 10.1831
    width = 29.0594713763
#    print(ome,width)
    #==============================================================================
    w_c = 5.1  * 2 * np.pi  # cavity frequency
    w_q = np.array([ 5.84 , 5.94,6.04]) * 2 * np.pi      
    deltaw = np.array([ 0.019 ,0.041,0.40]) * 2 * np.pi
    g = np.array([0.028 , 0.027,0.024]) * 2 * np.pi
    eta_q = np.array([-0.400 , -0.440,-0.480]) * 2 * np.pi
    #    w_q12 = deltaw+w_c
    #    w_q = deltaw+w_c-eta_q
    N = 16             # number of cavity fock states
    n= 0
    
#    w_c = 5.1  * 2 * np.pi  # cavity frequency
#    w_q = np.array([ 5.84 , 5.94,6.04]) * 2 * np.pi      
#    deltaw = np.array([ 0.019 ,0.041,0.46]) * 2 * np.pi
#    g = np.array([0.024 , 0.024,0.024]) * 2 * np.pi
#    eta_q = np.array([-0.440 , -0.460,-0.480]) * 2 * np.pi
                    
#    w_c = 5.1  * 2 * np.pi  # cavity frequency
#    w_q = np.array([ 5.84 , 5.94,6.04]) * 2 * np.pi      
#    deltaw = np.array([ 0.019 ,0.041,0.30]) * 2 * np.pi
#    g = np.array([0.028 , 0.027,0.024]) * 2 * np.pi
#    eta_q = np.array([-0.440 , -0.460,-0.380]) * 2 * np.pi
    #==============================================================================
    
    
    delta = 0.004 * 2 * np.pi
    omega = 0.001 * 2 * np.pi*np.sqrt(ome)
    
    
    #==============================================================================
    a, sm, E_uc, E_e, E_g, sn, sx, sy = CreateBasicOperator(3)
    
#    w_q[0] =  5.7911  * 2 * pi
#    eta_q[0] = -0.3911* 2 * pi
#    g[0] = 0.035* 2 * np.pi
#    HCoupling = g[0]*(a+a.dag())*(sm[0]+sm[0].dag())
#    Hc = w_c * a.dag() * a 
#    H_eta = eta_q[0] * E_uc[0] 
#    Hq = w_q[0]*sn[0]
#    H = Hq + H_eta + Hc + HCoupling
#    E = H.eigenstates()
#    Ee = E[0]
#    bastate = E[1]
#    return(Ee,bastate)
    #==============================================================================
    '''Hamilton'''
    
    HCoupling = g[0]*(a+a.dag())*(sm[0]+sm[0].dag()) + g[1]*(a+a.dag())*(sm[1]+sm[1].dag())+g[2]*(a+a.dag())*(sm[2]+sm[2].dag())
    Hc = w_c * a.dag() * a 
    H_eta = eta_q[0] * E_uc[0] + eta_q[1] * E_uc[1]+eta_q[2] * E_uc[2]
    Hq = w_q[0]*sn[0] + w_q[1]*sn[1] + w_q[2]*sn[2]
    H = Hq + H_eta + Hc + HCoupling
    
    Ee = H.eigenenergies()
    w_q = (Ee[1]-Ee[0])+deltaw-eta_q  #调控w_q
    HCoupling = g[0]*(a+a.dag())*(sm[0]+sm[0].dag()) + g[1]*(a+a.dag())*(sm[1]+sm[1].dag())+g[2]*(a+a.dag())*(sm[2]+sm[2].dag())
    Hc = w_c * a.dag() * a 
    H_eta = eta_q[0] * E_uc[0] + eta_q[1] * E_uc[1]+eta_q[2] * E_uc[2]
    Hq = w_q[0]*sn[0] + w_q[1]*sn[1] + w_q[2]*sn[2]
    H = Hq + H_eta + Hc + HCoupling
    HU = H
    
    E = H.eigenstates()
    Ee = E[0]
    bastate = E[1]
#    return(Ee,bastate)

    wd = (Ee[1]-Ee[0])-d+delta

    # w = 'omega*(1-np.cos(wd*t)) ' 
    # w = '0*(0<t<=50) + omega*(1-np.cos(wd*t))*(50<t<=300) + 0*(300<t<=350)'   #8.84185
#    w = '0*(0<t<=50) + omega*np.sin(wd*t)*(50<t<=300) + 0*(300<t<=350)'  
#    w = '(omega*np.exp(-(t-175)**2/2.0/45**2))*(1-np.cos(wd*t))*(0<t<=350)'
#    w = '(omega*(np.exp(-(t-125)**2/2.0/10**2)*np.sin(wd*t)+(t-125)/10**2*np.exp(-(t-125)**2/2.0/10**2)*np.sin(wd*t+np.pi/2)))*(0<t<=250)'
    w = '(omega/(1+np.exp(-(t-50)/width))-omega/(1+np.exp(-(t-300)/width)))*(1-np.cos(wd*t))*(0<t<=350)'
    # w = '(omega/2*(erf((t-50)/25.0)-erf((t-300)/25.0)))*(1-np.cos(wd*t))*(0<t<=350)'

    Hd = [2*(a+a.dag()),w]
    H = [H,Hd]
    args = {'wd':wd,'omega':omega,'width':width}
    
    #==============================================================================
    '''dissipation'''
    Q = 35000
    kappa = 1/13000.0
#    print(kappa)
#    kappa_phi = w_c/Q
    gamma = np.array([1.0/14.8 , 1.0/10]) *1e-3
    gamma_phi = np.array([1.0/10-1.0/2.0/14.8 , 1.0/10-1.0/2.0/10]) *1e-3
    n_th = 0.01
    cops = []
#     for ii in range(2):
        
#        cops.append(np.sqrt(gamma[ii] * (1+n_th)) * sm[ii])
#        cops.append(np.sqrt(gamma[ii] * n_th) * sm[ii].dag())
#        cops.append(np.sqrt(gamma_phi[ii]) * sm[ii].dag()*sm[ii])
#    cops.append(np.sqrt(kappa * (1+n_th)) * a)
#    cops.append(np.sqrt(kappa * n_th) * a.dag())
#    cops.append(np.sqrt(kappa_phi) * a.dag()*a)
    #==============================================================================
    '''evolution'''
    
    options=Options()
    options.atol=1e-11
    options.rtol=1e-9
    options.first_step=0.01
    options.num_cpus= 4
    options.nsteps=1e6
    options.gui='True'
    options.ntraj=1000
    options.rhs_reuse=False
    
    psi0 = (bastate[0]+bastate[2]).unit()
#    psi0 = (bastate[4]+bastate[14]).unit()
#    psi0 = bastate[0]
    
    
#    psi0 = tensor(basis(N,n) , (basis(3,0)+basis(3,1)).unit() , (basis(3,0)+basis(3,1)).unit())
#    psi0 = tensor(basis(N,n) , (basis(3,0)).unit() , (basis(3,0)+basis(3,1)).unit())
#    psi0 = tensor(basis(N,n) , (basis(3,0)+basis(3,1)).unit() , (basis(3,0)).unit())
#    psi0 = tensor(basis(N,n) , (basis(3,0)).unit() , (basis(3,1)).unit())

    tlist = np.linspace(0,350,351)


    result = mesolve(H,psi0,tlist,cops,[],args = args,options = options)
    
    #==============================================================================
    Plot = True
    
    '''
    PLot
    '''
    if Plot :
        
        n_x0 = [] ; n_y0 = [] ; n_z0 = [];n_a = [];nax = [];nay = [];
        n_x1 = [] ; n_y1 = [] ; n_z1 = [];
        
        for t in range(0,len(tlist)):
            U = 'basis(N,0)*basis(N,0).dag()'
            for i in range(1,N):
                U = U+'+np.exp(1j*'+str(i)+'*wd*tlist[t])*basis(N,'+str(i)+')*basis(N,'+str(i)+').dag()'      
            U = eval(U)
#            RF1 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(Ee[2]-Ee[0])*tlist[t])*basis(3,1)*basis(3,1).dag()+np.exp(1j*(Ee[7]-Ee[0])*tlist[t])*basis(3,2)*basis(3,2).dag()
#            RF2 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(Ee[3]-Ee[0])*tlist[t])*basis(3,1)*basis(3,1).dag()+np.exp(1j*(Ee[9]-Ee[0])*tlist[t])*basis(3,2)*basis(3,2).dag()
#            U = tensor(U,RF1,RF2)

#            RF = ptrace(bastate[0],[1,2])+np.exp(1j*(Ee[2]-Ee[0])*tlist[t])*ptrace(bastate[2],[1,2])+np.exp(1j*(Ee[3]-Ee[0])*tlist[t])*ptrace(bastate[3],[1,2])+np.exp(1j*(Ee[9]-Ee[0])*tlist[t])*ptrace(-bastate[9],[1,2])
#            U = tensor(U,RF)

#            U = (1j*HU*tlist[t]).expm()


            RF1 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(Ee[2]-Ee[0])*tlist[t])*basis(3,1)*basis(3,1).dag()
            RF2 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(Ee[3]-Ee[0])*tlist[t])*basis(3,1)*basis(3,1).dag()
            RF3 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(Ee[4]-Ee[0])*tlist[t])*basis(3,1)*basis(3,1).dag()
            U = tensor(U,RF1,RF2,RF3)
            
            opx0 = U.dag()*sx[0]*U
            opy0 = U.dag()*sy[0]*U
            opz0 = 1-sn[0]*2
            opx1 = U.dag()*sx[1]*U
            opy1 = U.dag()*sy[1]*U
            opz1 = 1-sn[1]*2
            opnx = U.dag()*(a+a.dag())*U/2
            opny = U.dag()*(a-a.dag())/2/1J*U
            n_x0.append(expect(opx0,result.states[t]))
            n_y0.append(expect(opy0,result.states[t]))
            n_z0.append(expect(opz0,result.states[t]))
            n_x1.append(expect(opx1,result.states[t]))
            n_y1.append(expect(opy1,result.states[t]))
            n_z1.append(expect(opz1,result.states[t]))
            n_a.append(expect(a.dag()*a,result.states[t]))
            nax.append(expect(opnx,result.states[t]))
            nay.append(expect(opny,result.states[t]))
            
            
#        fig, axes = plt.subplots(3, 1, figsize=(10,6))
#                
#        axes[0].plot(tlist, n_x0, label='X');axes[0].set_ylim([-1.05,1.05])
#        axes[1].plot(tlist, n_y0, label='Y');axes[1].set_ylim([-1.05,1.05])
#        axes[2].plot(tlist, n_z0, label='Z');axes[2].set_ylim([-1.05,1.05])
#        
#        fig, axes = plt.subplots(3, 1, figsize=(10,6))
#                
#        axes[0].plot(tlist, n_x1, label='X');axes[0].set_ylim([-1.05,1.05])
#        axes[1].plot(tlist, n_y1, label='Y');axes[1].set_ylim([-1.05,1.05])
#        axes[2].plot(tlist, n_z1, label='Z');axes[2].set_ylim([-1.05,1.05])
        
        
        fig, axes = plt.subplots(1, 2, figsize=(10,6))
        axes[0].plot(nax, nay);
        axes[1].plot(tlist, n_a, label='N');
        
        
        sphere = Bloch()
        sphere.add_points([n_x0 , n_y0 , n_z0])
        sphere.add_vectors([n_x0[-1],n_y0[-1],n_z0[-1]])
        sphere.make_sphere() 
        sphere = Bloch()
        sphere.add_points([n_x1 , n_y1 , n_z1])
        sphere.add_vectors([n_x1[-1],n_y1[-1],n_z1[-1]])
        sphere.make_sphere() 
        plt.show()
    #==============================================================================
    #==============================================================================
    '''
    fidelity
    '''
    U = 'basis(N,0)*basis(N,0).dag()'
    for i in range(1,N):
        U = U+'+np.exp(1j*'+str(i)+'*wd*tlist[-1])*basis(N,'+str(i)+')*basis(N,'+str(i)+').dag()'      
    U = eval(U)
    RF1 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(Ee[2]-Ee[0])*tlist[-1])*basis(3,1)*basis(3,1).dag()
    RF2 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(Ee[3]-Ee[0])*tlist[-1])*basis(3,1)*basis(3,1).dag()
    RF3 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(Ee[4]-Ee[0])*tlist[-1])*basis(3,1)*basis(3,1).dag()
    U = tensor(U,RF1,RF2,RF3)
    
#    U = (1j*HU*tlist[-1]).expm()
    
#    RF = ptrace(bastate[0],[1,2,3])+np.exp(1j*(Ee[2]-Ee[0])*tlist[-1])*ptrace(bastate[2],[1,2,3])+np.exp(1j*(Ee[3]-Ee[0])*tlist[-1])*ptrace(bastate[3],[1,2,3])+np.exp(1j*(Ee[11]-Ee[0])*tlist[-1])*ptrace(-bastate[1],[1,2,3])
#    U = tensor(U,RF)
#    print(U*U.dag())

    
    
#    tar = (-tensor(basis(3,0) , basis(3,0))+tensor(basis(3,1) , basis(3,0))+tensor(basis(3,0) , basis(3,1))+tensor(basis(3,1) , basis(3,1))).unit()
#    target = tensor(basis(N,n) , tar)
#    target = tensor(basis(N,n) , (basis(3,0)).unit() , (-basis(3,0)+basis(3,1)).unit())
#    target = tensor(basis(N,n) , (-basis(3,0)+basis(3,1)).unit() , (basis(3,0)).unit())
#    target = tensor(basis(N,n) , (basis(3,0)).unit() , (basis(3,1)).unit())
#    fid = fidelity(U*result.states[-1]*result.states[-1].dag()*U.dag(),target)
#    print('fidelity = ',fid)
    
#    target = (-bastate[0]+bastate[2]+bastate[3]-bastate[9]).unit()
    target = (-bastate[0]+bastate[2]).unit()
#    target = (-bastate[4]+bastate[14]).unit()
#    target = bastate[0]
    
    a0  = expect(a.dag()*a,target)
    a1  = expect(a.dag()*a,U*result.states[-1])
#    fid = fidelity(result.states[-1]*result.states[-1].dag(),target)
    fid = fidelity(U*result.states[-1]*result.states[-1].dag()*U.dag(),target)
    print('fidelity = ',fid)
    print('angle = ',angle((psi0.dag()*U*result.states[-1])[0][0])/np.pi*180)
    print('shift = ',(Ee[10]-Ee[4]-(Ee[1]-Ee[0]))/2/np.pi)
    print('deltaN = ',a1-a0)
    #==============================================================================
    return(fid)
def Two_GeoCZ_1(d):
    ome = 10.1831
    width = 29.0594713763
#    print(ome,width)
    #==============================================================================
    w_c = 5.1  * 2 * np.pi  # cavity frequency
    w_q = np.array([ 5.84 , 5.94,6.04]) * 2 * np.pi      
    deltaw = np.array([ 0.019 ,0.041,0.40]) * 2 * np.pi
    g = np.array([0.028 , 0.027,0.024]) * 2 * np.pi
    eta_q = np.array([-0.400 , -0.440,-0.480]) * 2 * np.pi
    #    w_q12 = deltaw+w_c
    #    w_q = deltaw+w_c-eta_q
    N = 16             # number of cavity fock states
    n= 0
    
#    w_c = 5.1  * 2 * np.pi  # cavity frequency
#    w_q = np.array([ 5.84 , 5.94,6.04]) * 2 * np.pi      
#    deltaw = np.array([ 0.019 ,0.041,0.46]) * 2 * np.pi
#    g = np.array([0.024 , 0.024,0.024]) * 2 * np.pi
#    eta_q = np.array([-0.440 , -0.460,-0.480]) * 2 * np.pi
                    
#    w_c = 5.1  * 2 * np.pi  # cavity frequency
#    w_q = np.array([ 5.84 , 5.94,6.04]) * 2 * np.pi      
#    deltaw = np.array([ 0.019 ,0.041,0.30]) * 2 * np.pi
#    g = np.array([0.028 , 0.027,0.024]) * 2 * np.pi
#    eta_q = np.array([-0.440 , -0.460,-0.380]) * 2 * np.pi
    #==============================================================================
    
    
    delta = 0.004 * 2 * np.pi
    omega = 0.001 * 2 * np.pi*np.sqrt(ome)
    
    
    #==============================================================================
    a, sm, E_uc, E_e, E_g, sn, sx, sy = CreateBasicOperator(3)
    
#    w_q[0] =  5.7911  * 2 * pi
#    eta_q[0] = -0.3911* 2 * pi
#    g[0] = 0.035* 2 * np.pi
#    HCoupling = g[0]*(a+a.dag())*(sm[0]+sm[0].dag())
#    Hc = w_c * a.dag() * a 
#    H_eta = eta_q[0] * E_uc[0] 
#    Hq = w_q[0]*sn[0]
#    H = Hq + H_eta + Hc + HCoupling
#    E = H.eigenstates()
#    Ee = E[0]
#    bastate = E[1]
#    return(Ee,bastate)
    #==============================================================================
    '''Hamilton'''
    
    HCoupling = g[0]*(a+a.dag())*(sm[0]+sm[0].dag()) + g[1]*(a+a.dag())*(sm[1]+sm[1].dag())+g[2]*(a+a.dag())*(sm[2]+sm[2].dag())
    Hc = w_c * a.dag() * a 
    H_eta = eta_q[0] * E_uc[0] + eta_q[1] * E_uc[1]+eta_q[2] * E_uc[2]
    Hq = w_q[0]*sn[0] + w_q[1]*sn[1] + w_q[2]*sn[2]
    H = Hq + H_eta + Hc + HCoupling
    
    Ee = H.eigenenergies()
    w_q = (Ee[1]-Ee[0])+deltaw-eta_q  #调控w_q
    HCoupling = g[0]*(a+a.dag())*(sm[0]+sm[0].dag()) + g[1]*(a+a.dag())*(sm[1]+sm[1].dag())+g[2]*(a+a.dag())*(sm[2]+sm[2].dag())
    Hc = w_c * a.dag() * a 
    H_eta = eta_q[0] * E_uc[0] + eta_q[1] * E_uc[1]+eta_q[2] * E_uc[2]
    Hq = w_q[0]*sn[0] + w_q[1]*sn[1] + w_q[2]*sn[2]
    H = Hq + H_eta + Hc + HCoupling
    HU = H
    
    E = H.eigenstates()
    Ee = E[0]
    bastate = E[1]
#    return(Ee,bastate)

    wd = (Ee[1]-Ee[0])-d+delta

    # w = 'omega*(1-np.cos(wd*t)) ' 
    # w = '0*(0<t<=50) + omega*(1-np.cos(wd*t))*(50<t<=300) + 0*(300<t<=350)'   #8.84185
#    w = '0*(0<t<=50) + omega*np.sin(wd*t)*(50<t<=300) + 0*(300<t<=350)'  
#    w = '(omega*np.exp(-(t-175)**2/2.0/45**2))*(1-np.cos(wd*t))*(0<t<=350)'
#    w = '(omega*(np.exp(-(t-125)**2/2.0/10**2)*np.sin(wd*t)+(t-125)/10**2*np.exp(-(t-125)**2/2.0/10**2)*np.sin(wd*t+np.pi/2)))*(0<t<=250)'
    w = '(omega/(1+np.exp(-(t-50)/width))-omega/(1+np.exp(-(t-300)/width)))*(1-np.cos(wd*t))*(0<t<=350)'
    # w = '(omega/2*(erf((t-50)/25.0)-erf((t-300)/25.0)))*(1-np.cos(wd*t))*(0<t<=350)'

    Hd = [2*(a+a.dag()),w]
    H = [H,Hd]
    args = {'wd':wd,'omega':omega,'width':width}
    
    #==============================================================================
    '''dissipation'''
    Q = 35000
    kappa = 1/13000.0
#    print(kappa)
#    kappa_phi = w_c/Q
    gamma = np.array([1.0/14.8 , 1.0/10]) *1e-3
    gamma_phi = np.array([1.0/10-1.0/2.0/14.8 , 1.0/10-1.0/2.0/10]) *1e-3
    n_th = 0.01
    cops = []
#     for ii in range(2):
        
#        cops.append(np.sqrt(gamma[ii] * (1+n_th)) * sm[ii])
#        cops.append(np.sqrt(gamma[ii] * n_th) * sm[ii].dag())
#        cops.append(np.sqrt(gamma_phi[ii]) * sm[ii].dag()*sm[ii])
#    cops.append(np.sqrt(kappa * (1+n_th)) * a)
#    cops.append(np.sqrt(kappa * n_th) * a.dag())
#    cops.append(np.sqrt(kappa_phi) * a.dag()*a)
    #==============================================================================
    '''evolution'''
    
    options=Options()
    options.atol=1e-11
    options.rtol=1e-9
    options.first_step=0.01
    options.num_cpus= 4
    options.nsteps=1e6
    options.gui='True'
    options.ntraj=1000
    options.rhs_reuse=False
    
#    psi0 = (bastate[0]-bastate[2]).unit()
    psi0 = (bastate[4]+bastate[13]).unit()
#    psi0 = bastate[0]
    
    
#    psi0 = tensor(basis(N,n) , (basis(3,0)+basis(3,1)).unit() , (basis(3,0)+basis(3,1)).unit())
#    psi0 = tensor(basis(N,n) , (basis(3,0)).unit() , (basis(3,0)+basis(3,1)).unit())
#    psi0 = tensor(basis(N,n) , (basis(3,0)+basis(3,1)).unit() , (basis(3,0)).unit())
#    psi0 = tensor(basis(N,n) , (basis(3,0)).unit() , (basis(3,1)).unit())

    tlist = np.linspace(0,350,351)


    result = mesolve(H,psi0,tlist,cops,[],args = args,options = options)
    
    #==============================================================================
    Plot = True
    
    '''
    PLot
    '''
    if Plot :
        
        n_x0 = [] ; n_y0 = [] ; n_z0 = [];n_a = [];nax = [];nay = [];
        n_x1 = [] ; n_y1 = [] ; n_z1 = [];
        
        for t in range(0,len(tlist)):
            U = 'basis(N,0)*basis(N,0).dag()'
            for i in range(1,N):
                U = U+'+np.exp(1j*'+str(i)+'*wd*tlist[t])*basis(N,'+str(i)+')*basis(N,'+str(i)+').dag()'      
            U = eval(U)
#            RF1 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(Ee[2]-Ee[0])*tlist[t])*basis(3,1)*basis(3,1).dag()+np.exp(1j*(Ee[7]-Ee[0])*tlist[t])*basis(3,2)*basis(3,2).dag()
#            RF2 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(Ee[3]-Ee[0])*tlist[t])*basis(3,1)*basis(3,1).dag()+np.exp(1j*(Ee[9]-Ee[0])*tlist[t])*basis(3,2)*basis(3,2).dag()
#            U = tensor(U,RF1,RF2)

#            RF = ptrace(bastate[0],[1,2])+np.exp(1j*(Ee[2]-Ee[0])*tlist[t])*ptrace(bastate[2],[1,2])+np.exp(1j*(Ee[3]-Ee[0])*tlist[t])*ptrace(bastate[3],[1,2])+np.exp(1j*(Ee[9]-Ee[0])*tlist[t])*ptrace(-bastate[9],[1,2])
#            U = tensor(U,RF)

#            U = (1j*HU*tlist[t]).expm()


            RF1 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(Ee[2]-Ee[0])*tlist[t])*basis(3,1)*basis(3,1).dag()
            RF2 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(Ee[3]-Ee[0])*tlist[t])*basis(3,1)*basis(3,1).dag()
            RF3 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(Ee[4]-Ee[0])*tlist[t])*basis(3,1)*basis(3,1).dag()
            U = tensor(U,RF1,RF2,RF3)
            
            opx0 = U.dag()*sx[0]*U
            opy0 = U.dag()*sy[0]*U
            opz0 = 1-sn[0]*2
            opx1 = U.dag()*sx[1]*U
            opy1 = U.dag()*sy[1]*U
            opz1 = 1-sn[1]*2
            opnx = U.dag()*(a+a.dag())*U/2
            opny = U.dag()*(a-a.dag())/2/1J*U
            n_x0.append(expect(opx0,result.states[t]))
            n_y0.append(expect(opy0,result.states[t]))
            n_z0.append(expect(opz0,result.states[t]))
            n_x1.append(expect(opx1,result.states[t]))
            n_y1.append(expect(opy1,result.states[t]))
            n_z1.append(expect(opz1,result.states[t]))
            n_a.append(expect(a.dag()*a,result.states[t]))
            nax.append(expect(opnx,result.states[t]))
            nay.append(expect(opny,result.states[t]))
            
            
#        fig, axes = plt.subplots(3, 1, figsize=(10,6))
#                
#        axes[0].plot(tlist, n_x0, label='X');axes[0].set_ylim([-1.05,1.05])
#        axes[1].plot(tlist, n_y0, label='Y');axes[1].set_ylim([-1.05,1.05])
#        axes[2].plot(tlist, n_z0, label='Z');axes[2].set_ylim([-1.05,1.05])
#        
#        fig, axes = plt.subplots(3, 1, figsize=(10,6))
#                
#        axes[0].plot(tlist, n_x1, label='X');axes[0].set_ylim([-1.05,1.05])
#        axes[1].plot(tlist, n_y1, label='Y');axes[1].set_ylim([-1.05,1.05])
#        axes[2].plot(tlist, n_z1, label='Z');axes[2].set_ylim([-1.05,1.05])
        
        
        fig, axes = plt.subplots(1, 2, figsize=(10,6))
        axes[0].plot(nax, nay);
        axes[1].plot(tlist, n_a, label='N');
        
        
        sphere = Bloch()
        sphere.add_points([n_x0 , n_y0 , n_z0])
        sphere.add_vectors([n_x0[-1],n_y0[-1],n_z0[-1]])
        sphere.make_sphere() 
        sphere = Bloch()
        sphere.add_points([n_x1 , n_y1 , n_z1])
        sphere.add_vectors([n_x1[-1],n_y1[-1],n_z1[-1]])
        sphere.make_sphere() 
        plt.show()
    #==============================================================================
    #==============================================================================
    '''
    fidelity
    '''
    U = 'basis(N,0)*basis(N,0).dag()'
    for i in range(1,N):
        U = U+'+np.exp(1j*'+str(i)+'*wd*tlist[-1])*basis(N,'+str(i)+')*basis(N,'+str(i)+').dag()'      
    U = eval(U)
    RF1 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(Ee[2]-Ee[0])*tlist[-1])*basis(3,1)*basis(3,1).dag()
    RF2 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(Ee[3]-Ee[0])*tlist[-1])*basis(3,1)*basis(3,1).dag()
    RF3 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(Ee[4]-Ee[0])*tlist[-1])*basis(3,1)*basis(3,1).dag()
    U = tensor(U,RF1,RF2,RF3)
    
#    U = (1j*HU*tlist[-1]).expm()
    
#    RF = ptrace(bastate[0],[1,2,3])+np.exp(1j*(Ee[2]-Ee[0])*tlist[-1])*ptrace(bastate[2],[1,2,3])+np.exp(1j*(Ee[3]-Ee[0])*tlist[-1])*ptrace(bastate[3],[1,2,3])+np.exp(1j*(Ee[11]-Ee[0])*tlist[-1])*ptrace(-bastate[1],[1,2,3])
#    U = tensor(U,RF)
#    print(U*U.dag())

    
    
#    tar = (-tensor(basis(3,0) , basis(3,0))+tensor(basis(3,1) , basis(3,0))+tensor(basis(3,0) , basis(3,1))+tensor(basis(3,1) , basis(3,1))).unit()
#    target = tensor(basis(N,n) , tar)
#    target = tensor(basis(N,n) , (basis(3,0)).unit() , (-basis(3,0)+basis(3,1)).unit())
#    target = tensor(basis(N,n) , (-basis(3,0)+basis(3,1)).unit() , (basis(3,0)).unit())
#    target = tensor(basis(N,n) , (basis(3,0)).unit() , (basis(3,1)).unit())
#    fid = fidelity(U*result.states[-1]*result.states[-1].dag()*U.dag(),target)
#    print('fidelity = ',fid)
    
#    target = (-bastate[0]+bastate[2]+bastate[3]-bastate[9]).unit()
#    target = (-bastate[0]-bastate[2]).unit()
    target = (-bastate[4]+bastate[13]).unit()
#    target = bastate[0]
    
    a0  = expect(a.dag()*a,target)
    a1  = expect(a.dag()*a,U*result.states[-1])
#    fid = fidelity(result.states[-1]*result.states[-1].dag(),target)
    fid = fidelity(U*result.states[-1]*result.states[-1].dag()*U.dag(),target)
    print('fidelity = ',fid)
    print('angle = ',angle((psi0.dag()*U*result.states[-1])[0][0])/np.pi*180)
    print('shift = ',(Ee[10]-Ee[4]-(Ee[1]-Ee[0]))/2/np.pi)
    print('deltaN = ',a1-a0)
    #==============================================================================
    return(fid)


def Two_GeoCZ_01(d):
    ome = 10.1831
    width = 29.0594713763
#    print(ome,width)
    #==============================================================================
    w_c = 5.1  * 2 * np.pi  # cavity frequency
    w_q = np.array([ 5.84 , 5.94,6.04]) * 2 * np.pi      
    deltaw = np.array([ 0.019 ,0.041,0.40]) * 2 * np.pi
    g = np.array([0.028 , 0.027,0.024]) * 2 * np.pi
    eta_q = np.array([-0.400 , -0.440,-0.480]) * 2 * np.pi
    #    w_q12 = deltaw+w_c
    #    w_q = deltaw+w_c-eta_q
    N = 16             # number of cavity fock states
    n= 0
    
#    w_c = 5.1  * 2 * np.pi  # cavity frequency
#    w_q = np.array([ 5.84 , 5.94,6.04]) * 2 * np.pi      
#    deltaw = np.array([ 0.019 ,0.041,0.46]) * 2 * np.pi
#    g = np.array([0.024 , 0.024,0.024]) * 2 * np.pi
#    eta_q = np.array([-0.440 , -0.460,-0.480]) * 2 * np.pi
                    
#    w_c = 5.1  * 2 * np.pi  # cavity frequency
#    w_q = np.array([ 5.84 , 5.94,6.04]) * 2 * np.pi      
#    deltaw = np.array([ 0.019 ,0.041,0.30]) * 2 * np.pi
#    g = np.array([0.028 , 0.027,0.024]) * 2 * np.pi
#    eta_q = np.array([-0.440 , -0.460,-0.380]) * 2 * np.pi
    #==============================================================================
    
    
    delta = 0.004 * 2 * np.pi
    omega = 0.001 * 2 * np.pi*np.sqrt(ome)
    
    
    #==============================================================================
    a, sm, E_uc, E_e, E_g, sn, sx, sy = CreateBasicOperator(3)
    
#    w_q[0] =  5.7911  * 2 * pi
#    eta_q[0] = -0.3911* 2 * pi
#    g[0] = 0.035* 2 * np.pi
#    HCoupling = g[0]*(a+a.dag())*(sm[0]+sm[0].dag())
#    Hc = w_c * a.dag() * a 
#    H_eta = eta_q[0] * E_uc[0] 
#    Hq = w_q[0]*sn[0]
#    H = Hq + H_eta + Hc + HCoupling
#    E = H.eigenstates()
#    Ee = E[0]
#    bastate = E[1]
#    return(Ee,bastate)
    #==============================================================================
    '''Hamilton'''
    
    HCoupling = g[0]*(a+a.dag())*(sm[0]+sm[0].dag()) + g[1]*(a+a.dag())*(sm[1]+sm[1].dag())+g[2]*(a+a.dag())*(sm[2]+sm[2].dag())
    Hc = w_c * a.dag() * a 
    H_eta = eta_q[0] * E_uc[0] + eta_q[1] * E_uc[1]+eta_q[2] * E_uc[2]
    Hq = w_q[0]*sn[0] + w_q[1]*sn[1] + w_q[2]*sn[2]
    H = Hq + H_eta + Hc + HCoupling
    
    Ee = H.eigenenergies()
    w_q = (Ee[1]-Ee[0])+deltaw-eta_q  #调控w_q
    HCoupling = g[0]*(a+a.dag())*(sm[0]+sm[0].dag()) + g[1]*(a+a.dag())*(sm[1]+sm[1].dag())+g[2]*(a+a.dag())*(sm[2]+sm[2].dag())
    Hc = w_c * a.dag() * a 
    H_eta = eta_q[0] * E_uc[0] + eta_q[1] * E_uc[1]+eta_q[2] * E_uc[2]
    Hq = w_q[0]*sn[0] + w_q[1]*sn[1] + w_q[2]*sn[2]
    H = Hq + H_eta + Hc + HCoupling
    HU = H
    
    E = H.eigenstates()
    Ee = E[0]
    bastate = E[1]
#    return(Ee,bastate)

    wd = (Ee[1]-Ee[0])-d+delta

    # w = 'omega*(1-np.cos(wd*t)) ' 
    # w = '0*(0<t<=50) + omega*(1-np.cos(wd*t))*(50<t<=300) + 0*(300<t<=350)'   #8.84185
#    w = '0*(0<t<=50) + omega*np.sin(wd*t)*(50<t<=300) + 0*(300<t<=350)'  
#    w = '(omega*np.exp(-(t-175)**2/2.0/45**2))*(1-np.cos(wd*t))*(0<t<=350)'
#    w = '(omega*(np.exp(-(t-125)**2/2.0/10**2)*np.sin(wd*t)+(t-125)/10**2*np.exp(-(t-125)**2/2.0/10**2)*np.sin(wd*t+np.pi/2)))*(0<t<=250)'
    w = '(omega/(1+np.exp(-(t-50)/width))-omega/(1+np.exp(-(t-300)/width)))*(1-np.cos(wd*t))*(0<t<=350)'
    # w = '(omega/2*(erf((t-50)/25.0)-erf((t-300)/25.0)))*(1-np.cos(wd*t))*(0<t<=350)'

    Hd = [2*(a+a.dag()),w]
    H = [H,Hd]
    args = {'wd':wd,'omega':omega,'width':width}
    
    #==============================================================================
    '''dissipation'''
    Q = 35000
    kappa = 1/13000.0
#    print(kappa)
#    kappa_phi = w_c/Q
    gamma = np.array([1.0/14.8 , 1.0/10]) *1e-3
    gamma_phi = np.array([1.0/10-1.0/2.0/14.8 , 1.0/10-1.0/2.0/10]) *1e-3
    n_th = 0.01
    cops = []
#     for ii in range(2):
        
#        cops.append(np.sqrt(gamma[ii] * (1+n_th)) * sm[ii])
#        cops.append(np.sqrt(gamma[ii] * n_th) * sm[ii].dag())
#        cops.append(np.sqrt(gamma_phi[ii]) * sm[ii].dag()*sm[ii])
#    cops.append(np.sqrt(kappa * (1+n_th)) * a)
#    cops.append(np.sqrt(kappa * n_th) * a.dag())
#    cops.append(np.sqrt(kappa_phi) * a.dag()*a)
    #==============================================================================
    '''evolution'''
    
    options=Options()
    options.atol=1e-11
    options.rtol=1e-9
    options.first_step=0.01
    options.num_cpus= 4
    options.nsteps=1e6
    options.gui='True'
    options.ntraj=1000
    options.rhs_reuse=False
    
    
    psi0 = (bastate[0]+bastate[2]+bastate[4]+bastate[13]).unit()
#    psi0 = (bastate[0]-bastate[2]).unit()
#    psi0 = (bastate[4]+bastate[13]).unit()
#    psi0 = bastate[0]
    
    
#    psi0 = tensor(basis(N,n) , (basis(3,0)+basis(3,1)).unit() , (basis(3,0)+basis(3,1)).unit())
#    psi0 = tensor(basis(N,n) , (basis(3,0)).unit() , (basis(3,0)+basis(3,1)).unit())
#    psi0 = tensor(basis(N,n) , (basis(3,0)+basis(3,1)).unit() , (basis(3,0)).unit())
#    psi0 = tensor(basis(N,n) , (basis(3,0)).unit() , (basis(3,1)).unit())

    tlist = np.linspace(0,350,351)


    result = mesolve(H,psi0,tlist,cops,[],args = args,options = options)
    
    #==============================================================================
    Plot = True
    
    '''
    PLot
    '''
    if Plot :
        
        n_x0 = [] ; n_y0 = [] ; n_z0 = [];n_a = [];nax = [];nay = [];
        n_x1 = [] ; n_y1 = [] ; n_z1 = [];
        
        for t in range(0,len(tlist)):
            U = 'basis(N,0)*basis(N,0).dag()'
            for i in range(1,N):
                U = U+'+np.exp(1j*'+str(i)+'*wd*tlist[t])*basis(N,'+str(i)+')*basis(N,'+str(i)+').dag()'      
            U = eval(U)
#            RF1 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(Ee[2]-Ee[0])*tlist[t])*basis(3,1)*basis(3,1).dag()+np.exp(1j*(Ee[7]-Ee[0])*tlist[t])*basis(3,2)*basis(3,2).dag()
#            RF2 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(Ee[3]-Ee[0])*tlist[t])*basis(3,1)*basis(3,1).dag()+np.exp(1j*(Ee[9]-Ee[0])*tlist[t])*basis(3,2)*basis(3,2).dag()
#            U = tensor(U,RF1,RF2)

#            RF = ptrace(bastate[0],[1,2])+np.exp(1j*(Ee[2]-Ee[0])*tlist[t])*ptrace(bastate[2],[1,2])+np.exp(1j*(Ee[3]-Ee[0])*tlist[t])*ptrace(bastate[3],[1,2])+np.exp(1j*(Ee[9]-Ee[0])*tlist[t])*ptrace(-bastate[9],[1,2])
#            U = tensor(U,RF)

#            U = (1j*HU*tlist[t]).expm()


            RF1 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(Ee[2]-Ee[0])*tlist[t])*basis(3,1)*basis(3,1).dag()
            RF2 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(Ee[3]-Ee[0])*tlist[t])*basis(3,1)*basis(3,1).dag()
            RF3 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(Ee[4]-Ee[0])*tlist[t])*basis(3,1)*basis(3,1).dag()
            U = tensor(U,RF1,RF2,RF3)
            
            opx0 = U.dag()*sx[0]*U
            opy0 = U.dag()*sy[0]*U
            opz0 = 1-sn[0]*2
            opx1 = U.dag()*sx[1]*U
            opy1 = U.dag()*sy[1]*U
            opz1 = 1-sn[1]*2
            opnx = U.dag()*(a+a.dag())*U/2
            opny = U.dag()*(a-a.dag())/2/1J*U
            n_x0.append(expect(opx0,result.states[t]))
            n_y0.append(expect(opy0,result.states[t]))
            n_z0.append(expect(opz0,result.states[t]))
            n_x1.append(expect(opx1,result.states[t]))
            n_y1.append(expect(opy1,result.states[t]))
            n_z1.append(expect(opz1,result.states[t]))
            n_a.append(expect(a.dag()*a,result.states[t]))
            nax.append(expect(opnx,result.states[t]))
            nay.append(expect(opny,result.states[t]))
            
            
#        fig, axes = plt.subplots(3, 1, figsize=(10,6))
#                
#        axes[0].plot(tlist, n_x0, label='X');axes[0].set_ylim([-1.05,1.05])
#        axes[1].plot(tlist, n_y0, label='Y');axes[1].set_ylim([-1.05,1.05])
#        axes[2].plot(tlist, n_z0, label='Z');axes[2].set_ylim([-1.05,1.05])
#        
#        fig, axes = plt.subplots(3, 1, figsize=(10,6))
#                
#        axes[0].plot(tlist, n_x1, label='X');axes[0].set_ylim([-1.05,1.05])
#        axes[1].plot(tlist, n_y1, label='Y');axes[1].set_ylim([-1.05,1.05])
#        axes[2].plot(tlist, n_z1, label='Z');axes[2].set_ylim([-1.05,1.05])
        
        
        fig, axes = plt.subplots(1, 2, figsize=(10,6))
        axes[0].plot(nax, nay);
        axes[1].plot(tlist, n_a, label='N');
        
        
        sphere = Bloch()
        sphere.add_points([n_x0 , n_y0 , n_z0])
        sphere.add_vectors([n_x0[-1],n_y0[-1],n_z0[-1]])
        sphere.make_sphere() 
        sphere = Bloch()
        sphere.add_points([n_x1 , n_y1 , n_z1])
        sphere.add_vectors([n_x1[-1],n_y1[-1],n_z1[-1]])
        sphere.make_sphere() 
        plt.show()
    #==============================================================================
    #==============================================================================
    '''
    fidelity
    '''
    U = 'basis(N,0)*basis(N,0).dag()'
    for i in range(1,N):
        U = U+'+np.exp(1j*'+str(i)+'*wd*tlist[-1])*basis(N,'+str(i)+')*basis(N,'+str(i)+').dag()'      
    U = eval(U)
    RF1 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(Ee[2]-Ee[0])*tlist[-1])*basis(3,1)*basis(3,1).dag()
    RF2 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(Ee[3]-Ee[0])*tlist[-1])*basis(3,1)*basis(3,1).dag()
    RF3 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(Ee[4]-Ee[0])*tlist[-1])*basis(3,1)*basis(3,1).dag()
    U = tensor(U,RF1,RF2,RF3)
    
#    U = (1j*HU*tlist[-1]).expm()
    
#    RF = ptrace(bastate[0],[1,2,3])+np.exp(1j*(Ee[2]-Ee[0])*tlist[-1])*ptrace(bastate[2],[1,2,3])+np.exp(1j*(Ee[3]-Ee[0])*tlist[-1])*ptrace(bastate[3],[1,2,3])+np.exp(1j*(Ee[11]-Ee[0])*tlist[-1])*ptrace(-bastate[1],[1,2,3])
#    U = tensor(U,RF)
#    print(U*U.dag())

    
    
#    tar = (-tensor(basis(3,0) , basis(3,0))+tensor(basis(3,1) , basis(3,0))+tensor(basis(3,0) , basis(3,1))+tensor(basis(3,1) , basis(3,1))).unit()
#    target = tensor(basis(N,n) , tar)
#    target = tensor(basis(N,n) , (basis(3,0)).unit() , (-basis(3,0)+basis(3,1)).unit())
#    target = tensor(basis(N,n) , (-basis(3,0)+basis(3,1)).unit() , (basis(3,0)).unit())
#    target = tensor(basis(N,n) , (basis(3,0)).unit() , (basis(3,1)).unit())
#    fid = fidelity(U*result.states[-1]*result.states[-1].dag()*U.dag(),target)
#    print('fidelity = ',fid)
    
    
    target = (-bastate[0]+bastate[2]-bastate[4]+bastate[13]).unit()
#    target = (-bastate[0]+bastate[2]+bastate[3]-bastate[9]).unit()
#    target = (-bastate[0]-bastate[2]).unit()
#    target = (-bastate[4]+bastate[13]).unit()
#    target = bastate[0]
    
    a0  = expect(a.dag()*a,target)
    a1  = expect(a.dag()*a,U*result.states[-1])
#    fid = fidelity(result.states[-1]*result.states[-1].dag(),target)
    fid = fidelity(U*result.states[-1]*result.states[-1].dag()*U.dag(),target)
    print('fidelity = ',fid)
    print('angle = ',angle((psi0.dag()*U*result.states[-1])[0][0])/np.pi*180)
    print('shift = ',(Ee[10]-Ee[4]-(Ee[1]-Ee[0]))/2/np.pi)
    print('deltaN = ',a1-a0)
    #==============================================================================
    return(fid)
    
    
def opt(d):
    fid0 = Two_GeoCZ_0(d)
    fid1 = Two_GeoCZ_1(d)
    fid01 = Two_GeoCZ_01(d)
    ave2 = np.mean([fid0,fid1])
    ave3 = np.mean([fid0,fid1,fid01])
    std2 = np.std([fid0,fid1])
    std3 = np.std([fid0,fid1,fid01])
    return([fid0,fid1,fid01,ave2,ave3,std2,std3])
if __name__ == '__main__':
    

    starttime = clock()
#    fid = Two_GeoCZ(0)
#    fid = Two_GeoCZ(ome = 10.1831)
#    fid=fminbound(Two_GeoCZ,6.0,13.0, xtol=1e-07,disp=3)
#    x0 = [8.0,10]
#    result = minimize(Two_GeoCZ, x0, method="powell",options={'disp': True})
    
#    g = linspace(0.01,0.03,41)*2*np.pi
#    p = Pool(6)
#    A = p.map(opt,g)
#    p.close()
#    p.join()
#    time =  np.array([x[0] for x in A])
#    fid = np.array([x[1] for x in A])
#    np.savetxt('g_time.txt',time)
#    np.savetxt('g_fid.txt',fid)

#    g = np.linspace(0.0,0.0006,60)*2*np.pi
#    p = Pool(3)
#    A = p.map(Two_GeoCZ,g)
#    p.close()
#    p.join()
#    delta =  np.array([x[0] for x in A])
#    fid = np.array([x[1] for x in A])
#    plot(delta,fid)

    g = linspace(0.00,0.0015458,200)*2*np.pi
    p = Pool(16)
    A = p.map(opt,g)
    p.close()
    p.join()
    fid0 = np.array([x[0] for x in A])
    fid1 = np.array([x[1] for x in A])
    fid01 = np.array([x[2] for x in A])
    ave2 = np.array([x[3] for x in A])
    ave3 = np.array([x[4] for x in A])
    std2 = np.array([x[5] for x in A])
    std3 = np.array([x[6] for x in A])
    
    fig, axes = plt.subplots(1, 3, figsize=(10,8))
    axes[0].plot(g, fid0);axes[1].plot(g, fid1);axes[2].plot(g, fid01);
    fig, axes = plt.subplots(1, 2, figsize=(10,8))
    axes[0].plot(g, ave2);axes[1].plot(g, ave3)
    fig, axes = plt.subplots(1, 2, figsize=(10,8))
    axes[0].plot(g, std2);axes[1].plot(g, std3)
    
    endtime = clock()
    print('Time used :',endtime-starttime,'s' )

























