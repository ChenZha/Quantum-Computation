#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Feb  7 22:29:10 2017

@author: qubits0
"""

#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Feb  7 21:14:06 2017

@author: qubits0
"""

# -*- coding: utf-8 -*-
"""
Created on Tue Nov 01 14:56:12 2016

@author: Logmay
"""

from time import clock
starttime=clock()

import csv
import matplotlib.pyplot as plt
import numpy as np
from qutip import *
from scipy.optimize import *
from mpl_toolkits.mplot3d import Axes3D

N=3

g0 = 0.03 * 2 * np.pi
g1 = 0.03 * 2 * np.pi
g2 = 0.03 * 2 * np.pi
g3 = 0.03 * 2 * np.pi
g4 = 0.03 * 2 * np.pi

w_q= np.array([ 5.1 , 5.2 , 5.3 , 5.4 , 5.5 ]) * 2 * np.pi
#print(w_q)

w_qa_0= 0.25 * 2 * np.pi
w_qa_1= 0.25 * 2 * np.pi
w_qa_2= 0.25 * 2 * np.pi
w_qa_3= 0.25 * 2 * np.pi
w_qa_4= 0.25 * 2 * np.pi#非简谐项

w_ref=w_q[0]

w_c= 6.5 * 2 * np.pi  #cavity

a= tensor(qeye(3),qeye(3),qeye(3),qeye(3),qeye(3),destroy(N))
sm0=tensor(destroy(3),qeye(3),qeye(3),qeye(3),qeye(3),qeye(N))
sm1=tensor(qeye(3),destroy(3),qeye(3),qeye(3),qeye(3),qeye(N))
sm2=tensor(qeye(3),qeye(3),destroy(3),qeye(3),qeye(3),qeye(N))
sm3=tensor(qeye(3),qeye(3),qeye(3),destroy(3),qeye(3),qeye(N))
sm4=tensor(qeye(3),qeye(3),qeye(3),qeye(3),destroy(3),qeye(N))
smm0=tensor(basis(3,2)*basis(3,2).dag(),qeye(3),qeye(3),qeye(3),qeye(3),qeye(N))
smm1=tensor(qeye(3),basis(3,2)*basis(3,2).dag(),qeye(3),qeye(3),qeye(3),qeye(N))
smm2=tensor(qeye(3),qeye(3),basis(3,2)*basis(3,2).dag(),qeye(3),qeye(3),qeye(N))
smm3=tensor(qeye(3),qeye(3),qeye(3),basis(3,2)*basis(3,2).dag(),qeye(3),qeye(N))
smm4=tensor(qeye(3),qeye(3),qeye(3),qeye(3),basis(3,2)*basis(3,2).dag(),qeye(N))


HCoupling= g0 * (a * sm0.dag() + a.dag() * sm0) + g1 * (a * sm1.dag() + a.dag() * sm1)  + g2 * (a * sm2.dag() + a.dag() * sm2) + g3 * (a * sm3.dag() + a.dag() * sm3)  + g4 * (a * sm4.dag() + a.dag() * sm4) 
Hc=w_c * a.dag() * a

Sz0=sm0.dag()*sm0    
Sz1=sm1.dag()*sm1  
Sz2=sm2.dag()*sm2  
Sz3=sm3.dag()*sm3  
Sz4=sm4.dag()*sm4             

H0a=-w_qa_0*smm0.dag()*smm0
H1a=-w_qa_1*smm1.dag()*smm1
H2a=-w_qa_2*smm2.dag()*smm2
H3a=-w_qa_3*smm3.dag()*smm3
H4a=-w_qa_4*smm4.dag()*smm4

Sx0=sm0.dag()+sm0
Sx1=sm1.dag()+sm1
Sx2=sm2.dag()+sm2
Sx3=sm3.dag()+sm3
Sx4=sm4.dag()+sm4
Sy0=-1j*(sm0.dag()-sm0)
Sy1=-1j*(sm1.dag()-sm1)
Sy2=-1j*(sm2.dag()-sm2)
Sy3=-1j*(sm3.dag()-sm3)
Sy4=-1j*(sm4.dag()-sm4)


#print g1*g2/(w_q1_0-w_c)/(w_q2_0-w_c)*(w_q1_0-w_c+w_q2_0-w_c)/(2*np.pi)*1000
#print H0.eigenenergies()/2/pi

n_th=0.01
gamma0 =1./10000         # atom dissipation rate
gamma1 =1./10000         # atom dissipation rate
gamma2 =1./10000         # atom dissipation rate
gamma3 =1./10000         # atom dissipation rate
gamma4 =1./10000         # atom dissipation rate
gamma_phi_0 = 1./10000      # atom dissipation daphsaing rate
gamma_phi_1 = 1./10000      # atom dissipation daphsaing rate
gamma_phi_2 = 1./10000      # atom dissipation daphsaing rate
gamma_phi_3 = 1./10000      # atom dissipation daphsaing rate
gamma_phi_4 = 1./10000      # atom dissipation daphsaing rate
c_op_list = []

c_op_list.append(np.sqrt(gamma0 * (1+n_th)) * sm0)
c_op_list.append(np.sqrt(gamma0 * n_th) * sm0.dag())
c_op_list.append(np.sqrt(gamma_phi_0) * sm0.dag()*sm0)
c_op_list.append(np.sqrt(gamma1 * (1+n_th)) * sm1)
c_op_list.append(np.sqrt(gamma1 * n_th) * sm1.dag())
c_op_list.append(np.sqrt(gamma_phi_1) * sm1.dag()*sm1)
c_op_list.append(np.sqrt(gamma2 * (1+n_th)) * sm2)
c_op_list.append(np.sqrt(gamma2 * n_th) * sm2.dag())
c_op_list.append(np.sqrt(gamma_phi_2) * sm2.dag()*sm2)
c_op_list.append(np.sqrt(gamma3 * (1+n_th)) * sm3)
c_op_list.append(np.sqrt(gamma3 * n_th) * sm3.dag())
c_op_list.append(np.sqrt(gamma_phi_3) * sm3.dag()*sm3)
c_op_list.append(np.sqrt(gamma4 * (1+n_th)) * sm4)
c_op_list.append(np.sqrt(gamma4 * n_th) * sm4.dag())
c_op_list.append(np.sqrt(gamma_phi_4) * sm4.dag()*sm4)

#==============================================================================
'''
wave shape
'''
def step_t_F(w1, w2, t0, t, width=0.5, w_ref=0):
    """
    Step function that goes from w1 to w2 at time t0
    as a function of t, with finite rise time defined
    by the parameter width.
    """
    return w1 + (w2 - w1) / (1 + exp(-(t-t0)/width)) - w_ref
    
def step_t_I(w1, w2, t0, t, width=0.5, w_ref=0):
    """
    Step function that goes from w1 to w2 at time t0
    as a function of t. 
    """
    return w1 + (w2 - w1) * (t > t0) - w_ref
#==============================================================================


#==============================================================================
    'wave shape of gates'
    '''
    w_t_i:返回qubit现在的频率
    D_t_i : gate施加的Hgate的时间演化规律
    args_i:时间演化中的参数
    '''
def Gate_rx(inxc,phi=np.pi):
    args_i={}
    w_t_i=('w_t'+str(inxc))
    args_i['w_t'+str(inxc)]=w_q[inxc]
    D_t_i=('Omega'+str(inxc)+'*np.exp(-(t-20)**2/2.0/width'+str(inxc)+'**2)*np.cos(t*f'+str(inxc)+')')
    args_i['f'+str(inxc)]=w_q[inxc]
    args_i['Omega'+str(inxc)]=0.02*2*phi
    args_i['width'+str(inxc)]=10 
    return w_t_i,D_t_i,args_i     
       
def Gate_ry(inxc,phi=np.pi):
    args_i={}
    w_t_i=('w_t'+str(inxc))
    args_i['w_t'+str(inxc)]=w_q[inxc]
    D_t_i=('Omega'+str(inxc)+'*np.exp(-(t-20)**2/2.0/width'+str(inxc)+'**2)*np.cos(t*f'+str(inxc)+'+np.pi/2)')
    args_i['f'+str(inxc)]=w_q[inxc]
    args_i['Omega'+str(inxc)]=0.02*2*phi
    args_i['width'+str(inxc)]=10    
    return w_t_i,D_t_i,args_i

def Gate_rz(inxc,phi=np.pi):
    args_i={}
    w_t_i='w_t'+str(inxc)+'+delta'+str(inxc)+'/(1 + np.exp(-(t-t'+str(inxc)+'0)/width'+str(inxc)+')) -delta'+str(inxc)+'/(1 + np.exp(-(t-t'+str(inxc)+'1)/width'+str(inxc)+')) '
    args_i['w_t'+str(inxc)]=w_q[inxc]
    args_i['width'+str(inxc)]=0.5
    args_i['t'+str(inxc)+'0']=2
    args_i['t'+str(inxc)+'1']=38
    args_i['delta'+str(inxc)]=0.02*phi
    D_t_i='0'
    return w_t_i,D_t_i,args_i

def Gate_i(inxc):
    args_i={}
    w_t_i='w_t'+str(inxc)
    args_i['w_t'+str(inxc)]=w_q[inxc]
    D_t_i='0'
    return w_t_i,D_t_i,args_i
#==============================================================================


def GetLen(Operator): #Operator演化时间，有X，Y，Z演化时间为40，只有I则演化时间为0
    lenc=len(Operator)
    LenSingleOperator=0
    for inxc in range(0,lenc):
        if Operator[inxc]=='X':
            LenSingleOperator=np.max([LenSingleOperator,40])
        elif Operator[inxc]=='Y':
            LenSingleOperator=np.max([LenSingleOperator,40])
        elif Operator[inxc]=='Z':
            LenSingleOperator=np.max([LenSingleOperator,40])
        elif Operator[inxc]=='I':
            LenSingleOperator=np.max([LenSingleOperator,0])
            
            
    return LenSingleOperator

def EvolveSingleStep(Operator,psi): #5qubit进行一步的演化
    H,args=GenerateH(Operator)
    
    LenSingleOperator=GetLen(Operator)
    tlist=np.arange(0,LenSingleOperator+1)
    
    c_op_list=[]
    
    options=Options()
    options.nsteps=1e6
    
    output=mesolve(H,psi,tlist,c_op_list,[],args=args,options=options)
    return output.states,tlist

def GenerateH(Operator):  #通过Operator生成作用的H
    lenc=len(Operator)
    w_t=[]
    D_t=[]
    args={}
    for inxc in range(0,lenc):
        if Operator[inxc]=='X':
            w_t_i,D_t_i,args_i=Gate_rx(inxc)
            w_t.append(w_t_i)
            D_t.append(D_t_i)
            args=dict(args,**args_i)
        elif Operator[inxc]=='Y':
            w_t_i,D_t_i,args_i=Gate_ry(inxc)
            w_t.append(w_t_i)
            D_t.append(D_t_i)
            args=dict(args,**args_i)
        elif Operator[inxc]=='Z':
            w_t_i,D_t_i,args_i=Gate_rz(inxc)
            w_t.append(w_t_i)
            D_t.append(D_t_i)
            args=dict(args,**args_i)
        elif Operator[inxc]=='I':
            w_t_i,D_t_i,args_i=Gate_i(inxc)
            w_t.append(w_t_i)
            D_t.append(D_t_i)
            args=dict(args,**args_i)
            
    H0=[Sz0,w_t[0]]
    H1=[Sz1,w_t[1]]
    H2=[Sz2,w_t[2]]
    H3=[Sz3,w_t[3]]
    H4=[Sz4,w_t[4]]
    D0=[Sx0,D_t[0]]
    D1=[Sx1,D_t[1]]
    D2=[Sx2,D_t[2]]
    D3=[Sx3,D_t[3]]
    D4=[Sx4,D_t[4]]
    H=[HCoupling,Hc,H0a,H1a,H2a,H3a,H4a,H0,H1,H2,H3,H4,D0,D1,D2,D3,D4]   
    return H,args
    

def plotstate(states,tlist): #画出在X，Y，Z方向投影的平均值
    
    expt=[Sz0,Sz1,Sz2,Sz3,Sz4]
    labels=['Q0 Z','Q1 Z','Q2 Z','Q3 Z','Q4 Z']
    
    fig, axes = plt.subplots(5, 1, figsize=(10,8))
    for ii in range(0,5):
        n_q = real(expect(expt[ii],states))
            
        axes[ii].plot(tlist, n_q, label=labels[ii])
            
        axes[ii].set_ylim([-0.05,1.05])
        axes[ii].legend(loc=0)
        axes[ii].set_xlabel('Time')
        axes[ii].set_ylabel('P')
        
        plt.show()
    
    expt=[Sx0,Sx1,Sx2,Sx3,Sx4]
    labels=['Q0 X','Q1 X','Q2 X','Q3 X','Q4 X']
    
    fig, axes = plt.subplots(5, 1, figsize=(10,8))
    for ii in range(0,5):
        n_q = real(expect(expt[ii],states))
            
        axes[ii].plot(tlist, n_q, label=labels[ii])
            
        axes[ii].set_ylim([-1.05,1.05])
        axes[ii].legend(loc=0)
        axes[ii].set_xlabel('Time')
        axes[ii].set_ylabel('P')
        
        plt.show()
    
    expt=[Sy0,Sy1,Sy2,Sy3,Sy4]
    labels=['Q0 Y','Q1 Y','Q2 Y','Q3 Y','Q4 Y']
    
    fig, axes = plt.subplots(5, 1, figsize=(10,8))
    for ii in range(0,5):
        n_q = real(expect(expt[ii],states))
            
        axes[ii].plot(tlist, n_q, label=labels[ii])
            
        axes[ii].set_ylim([-1.05,1.05])
        axes[ii].legend(loc=0)
        axes[ii].set_xlabel('Time')
        axes[ii].set_ylabel('P')
        
        plt.show()
    
    
def EvolveCircuits(): #多步Operator 线路演化
    global timestep
    Operators=[
    ['X','Y','Z','I','X'],
    ['Y','Z','I','X','Y'],
    ['Z','I','X','Y','Z'],
    ]
    #List of Gates: 'I','X','Y', 'Z', 'H', 'CX', 'CY', 'CZ', 'CNOT', 'SWAP', 'iSWAP', 'CSWAP', 'CCNOT', 'sSWAP', 'siSWAP', 'sNOT'
    
    timestep=0.001
    psi0=tensor(basis(3,0),basis(3,0) ,basis(3,0),basis(3,0) ,basis(3,0),basis(N,0))
    psi1=tensor(basis(3,1),basis(3,0) ,basis(3,0),basis(3,0) ,basis(3,0),basis(N,0))
    psi2=tensor((basis(3,0)+basis(3,1)).unit(),basis(3,0) ,basis(3,0),basis(3,0) ,basis(3,0),basis(N,0))
    psi3=tensor((basis(3,0)+1j*basis(3,1)).unit(),basis(3,0) ,basis(3,0),basis(3,0) ,basis(3,0),basis(N,0))
        
    psi=psi0
    psi_total=[]
    tlist_total=[]
    lenr=len(Operators) #Operator有几步
    for inxr in range(0,lenr): #每一步演化
        print(Operators[inxr])
        psi,tlist=EvolveSingleStep(Operators[inxr],psi)
        #几步演化总时间tlist和总态演化psi的拼合
        if len(tlist_total)==0:
            tlist_total=tlist
            psi_total=psi
        else:
            tlist_total=np.append(tlist_total,tlist[1:]+tlist_total[-1])
            psi_total=psi_total+psi[1:]
        psi=psi[-1]
        
    plotstate(psi_total,tlist_total)
    
def TestGate():
    Operator=['X','I','I','I','I']
    #List of Gates: 'I','X','Y', 'Z', 'H', 'CX', 'CY', 'CZ', 'CNOT', 'SWAP', 'iSWAP', 'CSWAP', 'CCNOT', 'sSWAP', 'siSWAP', 'sNOT'
    
    psi0=tensor(basis(3,0),basis(3,0) ,basis(3,0),basis(3,0) ,basis(3,0),basis(N,0))
    psi1=tensor(basis(3,1),basis(3,0) ,basis(3,0),basis(3,0) ,basis(3,0),basis(N,0))
    psi2=tensor((basis(3,0)+basis(3,1)).unit(),basis(3,0) ,basis(3,0),basis(3,0) ,basis(3,0),basis(N,0))
    psi3=tensor((basis(3,0)+1j*basis(3,1)).unit(),basis(3,0) ,basis(3,0),basis(3,0) ,basis(3,0),basis(N,0))
        
    H,args=GenerateH(Operator)
    LenSingleOperator=GetLen(Operator)
        
    tlist=np.arange(0,LenSingleOperator+1)
    
    options=Options()
    options.num_cpus=4
    options.nsteps=1e8
    options.gui='True'
    options.ntraj=100
    
    Us = propagator(H, tlist, [],options=options,args=args)
    U_e=Us[-1]
    print(U_e)
          
EvolveCircuits()

finishtime=clock()
print( 'Time used: ', (finishtime-starttime), 's')

