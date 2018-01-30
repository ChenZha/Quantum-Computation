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
import random
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
    return([fid,leakage[0],leakage[1],UT*output.states[-1]])

    
    
    

    

def CZgate(pulse):
    #==============================================================================
    '''Hamilton'''
    global H0,l11,l01,l10,l00
    HCoupling = g*(sm[0]+sm[0].dag())*(sm[1]+sm[1].dag())
    H_eta = eta_q[0] * E_uc[0] + eta_q[1] * E_uc[1]
    Hq = w_q[0]*sn[0] + w_q[1]*sn[1]
    H0 = Hq + H_eta + HCoupling
    [E,S] = H0.eigenstates()
    l11 = findstate(S,'11');l10 = findstate(S,'10');l01 = findstate(S,'01');l00 = findstate(S,'00');
    
    P = np.reshape(pulse,(2,-1))
    P1 = P[0]
    P2 = P[1]
    Hd0 = [sn[0],P1]
    Hd1 = [sn[1],P2]

    H = [H0,Hd0,Hd1]

    
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
    
    T = []
    T.append([tensor(basis(3,0),basis(3,0)),tensor(basis(3,0),basis(3,0))])
    T.append([tensor(basis(3,0),basis(3,1)),tensor(basis(3,0),basis(3,1))])
    T.append([tensor(basis(3,1),basis(3,0)),tensor(basis(3,1),basis(3,0))])
    T.append([tensor(basis(3,1),basis(3,1)),np.exp(1j*np.pi)*tensor(basis(3,1),basis(3,1))])



    tlist = np.linspace(0,tp,tp+1)

    
    p = Pool(4)
    
    A = p.map(getfid,T)
    fid = [x[0] for x in A]
    leakage0 = [x[1] for x in A]
    leakage1 = [x[2] for x in A]
    outputstate = [x[3] for x in A]
    fid = np.array(fid)
    leakage0 = np.array(leakage0)
    leakage1 = np.array(leakage1)

        
    p.close()
    p.join()
    gc.collect()
##    
#    
    process = np.column_stack([outputstate[i].data.toarray() for i in range(len(outputstate))])[(0,1,3,4),:]
    targetprocess = 1/np.sqrt(2)*np.array([[1,0,0,0],[0,1,0,0],[0,0,1,0],[0,0,0,-1]])
    
    Error = np.dot(np.conjugate(np.transpose(targetprocess)),process)
    angle = np.angle(Error[0][0])
    Error = Error*np.exp(-1j*angle)#global phase

    Ufidelity = np.abs(np.trace(Error))/4

    print(leakage0,leakage1,np.mean(fid),Ufidelity)

    gc.collect()
    #==============================================================================
    return(1-Ufidelity)
    
    
def 
    
def de(n = 4, m_size = 20 , f = 0.5 , cr = 0.3 , iterate_time = 100 , x_l = np.array([0,1,0,2]),x_u = np.array([5,6,8,4]) ):
    #初始化
    x_all = np.zeros((iterate_time , m_size , n))#m_size为population ，n为dimension
    value = np.zeros((iterate_time , m_size ))
    f_list = np.zeros(iterate_time);f_list[0] = f
    cr_list = np.zeros(iterate_time);cr_list[0] = cr 
    for i in range(m_size):
        x_all[0][i] = x_l + random.random()*(x_u-x_l)
        value[0][i] = evaluate_func(x_all[0][i])

    print('差分进化算法初始化完成')
    print('寻优参数维度为',n)
    for g in range(iterate_time-1):
        print('第',g,'代')
        for i in range(m_size):
            #变异操作，对第g代随机抽取三个组成一个新的个体，对于第i个新个体来说，原来的第i个个体与它没有关系
            x_g_without_i = np.delete(x_all[g],i,0)
            np.random.shuffle(x_g_without_i)
            h_i = x_g_without_i[1]+f*(x_g_without_i[2]-x_g_without_i[3])
            #变异操作后，h_i个体可能会过上下限区间，为了保证在区间以内对超过区间外的值赋值为相邻的边界值
            #先处理上边界，如果h_i[item]大于x_u则取x_u，如果小于则取h_i[item]
            h_i = [h_i[item] if h_i[item]<x_u[item] else x_u[item] for item in range(n)] 
            h_i = [h_i[item] if h_i[item]>x_l[item] else x_l[item] for item in range(n)] 

            #交叉操作，对变异后的个体，根据随机数与交叉阈值确定最后的个体
            # print(h_i)
            v_i = np.array([x_all[g][i][j] if (random.random() > cr) else h_i[j] for j in range(n) ])
            #根据评估函数确定是否更新新的个体
            if CZgate(x_all[g][i])>CZgate(v_i):
                x_all[g+1][i] = v_i
            else:
                x_all[g+1][i] = x_all[g][i]
    evaluate_result = [CZgate(x_all[iterate_time-1][i]) for i in range(m_size)]
    best_x_i = x_all[iterate_time-1][np.argmin(evaluate_result)]
    print(evaluate_result)
    print(np.min(evaluate_result))
    print(best_x_i)
        
    
    
    
    
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
    

    endtime  = time.time()
    
    print('used time:',endtime-starttime,'s')
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
                
