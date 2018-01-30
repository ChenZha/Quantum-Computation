#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Feb 16 04:04:14 2017

@author: qubits0
"""

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
import csv
import matplotlib.pyplot as plt
import numpy as np
from qutip import *
from scipy.optimize import *
from mpl_toolkits.mplot3d import Axes3D




def CreateBasicOperator(APRType=0):
    print(APRType)
    if APRType==0:
        a= tensor(qeye(3),qeye(3),qeye(3),qeye(3),qeye(3),destroy(N))
    
        sm=[]
        sm.append(tensor(destroy(3),qeye(3),qeye(3),qeye(3),qeye(3),qeye(N)))
        sm.append(tensor(qeye(3),destroy(3),qeye(3),qeye(3),qeye(3),qeye(N)))
        sm.append(tensor(qeye(3),qeye(3),destroy(3),qeye(3),qeye(3),qeye(N)))
        sm.append(tensor(qeye(3),qeye(3),qeye(3),destroy(3),qeye(3),qeye(N)))
        sm.append(tensor(qeye(3),qeye(3),qeye(3),qeye(3),destroy(3),qeye(N)))
        smm=[]
        smm.append(tensor(basis(3,2)*basis(3,2).dag(),qeye(3),qeye(3),qeye(3),qeye(3),qeye(N)))
        smm.append(tensor(qeye(3),basis(3,2)*basis(3,2).dag(),qeye(3),qeye(3),qeye(3),qeye(N)))
        smm.append(tensor(qeye(3),qeye(3),basis(3,2)*basis(3,2).dag(),qeye(3),qeye(3),qeye(N)))
        smm.append(tensor(qeye(3),qeye(3),qeye(3),basis(3,2)*basis(3,2).dag(),qeye(3),qeye(N)))
        smm.append(tensor(qeye(3),qeye(3),qeye(3),qeye(3),basis(3,2)*basis(3,2).dag(),qeye(N)))
        
        E_e=[]
        E_e.append(tensor(basis(3,1)*basis(3,1).dag(),qeye(3),qeye(3),qeye(3),qeye(3),qeye(N)))
        E_e.append(tensor(qeye(3),basis(3,1)*basis(3,1).dag(),qeye(3),qeye(3),qeye(3),qeye(N)))
        E_e.append(tensor(qeye(3),qeye(3),basis(3,1)*basis(3,1).dag(),qeye(3),qeye(3),qeye(N)))
        E_e.append(tensor(qeye(3),qeye(3),qeye(3),basis(3,1)*basis(3,1).dag(),qeye(3),qeye(N)))
        E_e.append(tensor(qeye(3),qeye(3),qeye(3),qeye(3),basis(3,1)*basis(3,1).dag(),qeye(N)))
        E_g=[]
        E_g.append(tensor(basis(3,0)*basis(3,0).dag(),qeye(3),qeye(3),qeye(3),qeye(3),qeye(N)))
        E_g.append(tensor(qeye(3),basis(3,0)*basis(3,0).dag(),qeye(3),qeye(3),qeye(3),qeye(N)))
        E_g.append(tensor(qeye(3),qeye(3),basis(3,0)*basis(3,0).dag(),qeye(3),qeye(3),qeye(N)))
        E_g.append(tensor(qeye(3),qeye(3),qeye(3),basis(3,0)*basis(3,0).dag(),qeye(3),qeye(N)))
        E_g.append(tensor(qeye(3),qeye(3),qeye(3),qeye(3),basis(3,0)*basis(3,0).dag(),qeye(N)))
        
    elif APRType==1:
        a= tensor(qeye(3),qeye(3),qeye(3),qeye(3),qeye(3))
    
        sm=[]
        sm.append(tensor(destroy(3),qeye(3),qeye(3),qeye(3),qeye(3)))
        sm.append(tensor(qeye(3),destroy(3),qeye(3),qeye(3),qeye(3)))
        sm.append(tensor(qeye(3),qeye(3),destroy(3),qeye(3),qeye(3)))
        sm.append(tensor(qeye(3),qeye(3),qeye(3),destroy(3),qeye(3)))
        sm.append(tensor(qeye(3),qeye(3),qeye(3),qeye(3),destroy(3)))
        smm=[]
        smm.append(tensor(basis(3,2)*basis(3,2).dag(),qeye(3),qeye(3),qeye(3),qeye(3)))
        smm.append(tensor(qeye(3),basis(3,2)*basis(3,2).dag(),qeye(3),qeye(3),qeye(3)))
        smm.append(tensor(qeye(3),qeye(3),basis(3,2)*basis(3,2).dag(),qeye(3),qeye(3)))
        smm.append(tensor(qeye(3),qeye(3),qeye(3),basis(3,2)*basis(3,2).dag(),qeye(3)))
        smm.append(tensor(qeye(3),qeye(3),qeye(3),qeye(3),basis(3,2)*basis(3,2).dag()))
        
        E_e=[]
        E_e.append(tensor(basis(3,1)*basis(3,1).dag(),qeye(3),qeye(3),qeye(3),qeye(3)))
        E_e.append(tensor(qeye(3),basis(3,1)*basis(3,1).dag(),qeye(3),qeye(3),qeye(3)))
        E_e.append(tensor(qeye(3),qeye(3),basis(3,1)*basis(3,1).dag(),qeye(3),qeye(3)))
        E_e.append(tensor(qeye(3),qeye(3),qeye(3),basis(3,1)*basis(3,1).dag(),qeye(3)))
        E_e.append(tensor(qeye(3),qeye(3),qeye(3),qeye(3),basis(3,1)*basis(3,1).dag()))
        E_g=[]
        E_g.append(tensor(basis(3,0)*basis(3,0).dag(),qeye(3),qeye(3),qeye(3),qeye(3)))
        E_g.append(tensor(qeye(3),basis(3,0)*basis(3,0).dag(),qeye(3),qeye(3),qeye(3)))
        E_g.append(tensor(qeye(3),qeye(3),basis(3,0)*basis(3,0).dag(),qeye(3),qeye(3)))
        E_g.append(tensor(qeye(3),qeye(3),qeye(3),basis(3,0)*basis(3,0).dag(),qeye(3)))
        E_g.append(tensor(qeye(3),qeye(3),qeye(3),qeye(3),basis(3,0)*basis(3,0).dag()))
    
    Sz=[]
    Sx=[]
    Sy=[]
    for II in range(0,Num_Q):
        Sz.append(sm[II].dag()*sm[II])
        Sx.append(sm[II].dag()+sm[II])
        Sy.append(-1j*(sm[II].dag()-sm[II]))   
        
    return a, sm, smm, E_e, E_g, Sz, Sx, Sy

def GenerateDissipation(Dis=False):
    c_op_list = []
    
    if Dis==True:
        for II in range(0,5):
            c_op_list.append(np.sqrt(gamma[II] * (1+n_th)) * sm[II])
            c_op_list.append(np.sqrt(gamma[II] * n_th) * sm[II].dag())
            c_op_list.append(np.sqrt(gamma_phi[II]) * sm[II].dag()*sm[II])
            
    return c_op_list

def Gate_rx(inxc,t0,t1,index,phi=np.pi):
    args_i={}
    w_t_i='(w_t'+str(inxc)+'_'+str(index)+')*('+str(t0)+'<t<='+str(t1)+')'
    args_i['w_t'+str(inxc)+'_'+str(index)]=w_q[inxc]
    D_t_i='(Omega'+str(inxc)+'_'+str(index)+'*np.exp(-(t-20-'+str(t0)+')**2/2.0/width'+str(inxc)+'_'+str(index)+'**2)*np.cos(t*f'+str(inxc)+'_'+str(index)+'))*('+str(t0)+'<t<='+str(min(t1,t0+40))+')'
    args_i['f'+str(inxc)+'_'+str(index)]=w_q[inxc]
    args_i['Omega'+str(inxc)+'_'+str(index)]=0.021*2*phi
    args_i['width'+str(inxc)+'_'+str(index)]=10
    return w_t_i,D_t_i,args_i     
         
def Gate_ry(inxc,t0,t1,index,phi=np.pi):
    args_i={}
    w_t_i='(w_t'+str(inxc)+'_'+str(index)+')*('+str(t0)+'<t<='+str(t1)+')'
    args_i['w_t'+str(inxc)+'_'+str(index)]=w_q[inxc]
    D_t_i='(Omega'+str(inxc)+'_'+str(index)+'*np.exp(-(t-20-'+str(t0)+')**2/2.0/width'+str(inxc)+'_'+str(index)+'**2)*np.cos(t*f'+str(inxc)+'_'+str(index)+'+np.pi/2))*('+str(t0)+'<t<='+str(min(t1,t0+40))+')'
    args_i['f'+str(inxc)+'_'+str(index)]=w_q[inxc]
    args_i['Omega'+str(inxc)+'_'+str(index)]=0.021*2*phi
    args_i['width'+str(inxc)+'_'+str(index)]=10 
    return w_t_i,D_t_i,args_i

def Gate_rz(inxc,t0,t1,index,phi=np.pi):
    args_i={}
    w_t_i='(w_t'+str(inxc)+'_'+str(index)+'+delta'+str(inxc)+'_'+str(index)+'/(1 + np.exp(-(t-'+str(t0)+'-t'+str(inxc)+'_'+str(index)+'0)/width'+str(inxc)+'_'+str(index)+')) -delta'+str(inxc)+'_'+str(index)+'/(1 + np.exp(-(t-'+str(t0)+'-t'+str(inxc)+'_'+str(index)+'1)/width'+str(inxc)+'_'+str(index)+')))*('+str(t0)+'<t<='+str(t1)+')'
    args_i['w_t'+str(inxc)+'_'+str(index)]=w_q[inxc]
    args_i['width'+str(inxc)+'_'+str(index)]=0.5
    args_i['t'+str(inxc)+'_'+str(index)+'0']=2
    args_i['t'+str(inxc)+'_'+str(index)+'1']=38
    args_i['delta'+str(inxc)+'_'+str(index)]=0.0293*phi
    D_t_i='0*('+str(t0)+'<t<='+str(t1)+')'
    return w_t_i,D_t_i,args_i

def Gate_i(inxc,t0,t1,index):
    args_i={}
    w_t_i='(w_t'+str(inxc)+'_'+str(index)+')*('+str(t0)+'<t<='+str(t1)+')'
    args_i['w_t'+str(inxc)+'_'+str(index)]=w_q[inxc]
    D_t_i='0*('+str(t0)+'<t<='+str(t1)+')'
    return w_t_i,D_t_i,args_i

def GetLen(Operator):
    lenc=len(Operator)
    LenSingleOperator=0
    for inxc in range(0,lenc):
        if Operator[inxc]=='X':
            LenSingleOperator=np.max([LenSingleOperator,40])
        elif Operator[inxc]=='Y':
            LenSingleOperator=np.max([LenSingleOperator,40])
        elif Operator[inxc]=='Z':
            LenSingleOperator=np.max([LenSingleOperator,40])
        elif Operator[inxc][0]=='I':
            if len(Operator[inxc])==1:
                LenSingleOperator=np.max([LenSingleOperator,0])
            else:
                LenSingleOperator=np.max([LenSingleOperator,int(Operator[inxc][1:])])
            
    return LenSingleOperator

def GenerateH(Operators, APRType=0):
        
    if APRType==0:
        HCoupling=0
        for II in range(0,Num_Q):
            HCoupling+= g[II] * (a * sm[II].dag() + a.dag() * sm[II]) 
        Hc=w_c * a.dag() * a 
        H=[HCoupling,Hc]   
    elif APRType==1:
        HCoupling=0
        for II in range(0,Num_Q):
            for JJ in range(II,Num_Q):
                HCoupling+= g[II]*g[JJ]/(w_q[II]-w_c)/(w_q[JJ]-w_c)*(w_q[II]-w_c+w_q[JJ]-w_c) * (sm[II].dag() * sm[JJ] + sm[II] * sm[JJ].dag())
        H=HCoupling
        
    for II in range(0,Num_Q):
        H.append(-w_qa[II]*smm[II].dag()*smm[II])
            
    t0=0
    args={}
    for JJ in range(0,len(Operators)):
        Operator=Operators[JJ]           
        lenc=len(Operator)
        
        LenSingleOperator=GetLen(Operator)
        t1=t0+LenSingleOperator
        
        w_t=[]
        D_t=[]
        
        for inxc in range(0,lenc):
            if Operator[inxc][0]=='X':
                if len(Operator[inxc])==1:
                    w_t_i,D_t_i,args_i=Gate_rx(inxc,t0,t1,JJ)
                else:
                    w_t_i,D_t_i,args_i=Gate_rx(inxc,t0,t1,JJ,phi=np.pi*float(Operator[inxc][1:]))
            elif Operator[inxc][0]=='Y':
                if len(Operator[inxc])==1:
                    w_t_i,D_t_i,args_i=Gate_ry(inxc,t0,t1,JJ)
                else:
                    w_t_i,D_t_i,args_i=Gate_ry(inxc,t0,t1,JJ,phi=np.pi*float(Operator[inxc][1:]))
            elif Operator[inxc][0]=='Z':
                if len(Operator[inxc])==1:
                    w_t_i,D_t_i,args_i=Gate_rz(inxc,t0,t1,JJ)
                else:
                    w_t_i,D_t_i,args_i=Gate_rz(inxc,t0,t1,JJ,phi=np.pi*float(Operator[inxc][1:]))
            elif Operator[inxc][0]=='I':
                w_t_i,D_t_i,args_i=Gate_i(inxc,t0,t1,JJ)
            w_t.append(w_t_i)
            D_t.append(D_t_i)
            args=dict(args,**args_i)
        
        W=[]
        D=[]
        for II in range(0,Num_Q):
            W.append([Sz[II],w_t[II]])   
            D.append([Sx[II],D_t[II]])
            H.append(W[II])
            H.append(D[II])
            
        t0=t1
        
    return H,args,t1
    

def plotstate(states,tlist):
    
    expect_z=[]
    fig, axes = plt.subplots(Num_Q, 1, figsize=(10,8))
    for ii in range(0,Num_Q):
        n_z = np.real(expect(1-Sz[ii]*2,states))
#        n_z = np.real(expect(Sz[ii],states))
        n_z=n_z.tolist()
        axes[ii].plot(tlist, n_z, label='Q'+str(ii)+'Z')
        axes[ii].set_ylim([-1.05,1.05])
        axes[ii].legend(loc=0)
        axes[ii].set_xlabel('Time')
        axes[ii].set_ylabel('P')
        plt.show()
        
        expect_z.append(n_z)
    
    expect_x=[]
    fig, axes = plt.subplots(Num_Q, 1, figsize=(10,8))
    for ii in range(0,Num_Q):
        n_x=[]
        for t in range(0,len(tlist)):
            U=(np.exp(1j*w_q[ii]*tlist[t])*E_e[ii].dag()+E_g[ii]).dag()
            op=U*Sx[ii]*U.dag()
            n_x.append(expect(op,states[t]))
        axes[ii].plot(tlist, n_x, label='Q'+str(ii)+'X')
        axes[ii].set_ylim([-1.05,1.05])
        axes[ii].legend(loc=0)
        axes[ii].set_xlabel('Time')
        axes[ii].set_ylabel('P')
        plt.show()
        
        expect_x.append(n_x)
    
    expect_y=[]
    fig, axes = plt.subplots(Num_Q, 1, figsize=(10,8))
    for ii in range(0,Num_Q):
        n_y=[]
        for t in range(0,len(tlist)):
            U=(np.exp(1j*w_q[ii]*tlist[t])*E_e[ii].dag()+E_g[ii]).dag()
            op=U*Sy[ii]*U.dag()
            n_y.append(expect(op,states[t]))
        axes[ii].plot(tlist, n_y, label='Q'+str(ii)+'Y')
        axes[ii].set_ylim([-1.05,1.05])
        axes[ii].legend(loc=0)
        axes[ii].set_xlabel('Time')
        axes[ii].set_ylabel('P')
        plt.show()
        
        expect_y.append(n_y)
    
    for ii in range(0,Num_Q):
        b=Bloch()
        b.add_points([expect_x[ii],expect_y[ii],expect_z[ii]])
        b.show()
        if SD:
            b.save('./saved results/Bloch_Q'+str(ii),'png')
    
    return expect_x,expect_y,expect_z

def savedata(psi_total, tlist_total, expect_x,expect_y,expect_z):
    for ii in range(0,Num_Q):
        data_xyz=np.array([tlist_total.tolist(),expect_x[ii],expect_y[ii],expect_z[ii]])
        file_data_store('./saved results/data_xyz_Q'+str(ii)+'.csv',data_xyz,sep=',',numformat='exp')

def MCkettodm(states):
    outputstate = states
    lenc = len(states)
    lenr = len(states[0])
    for i in range(0,lenc):
        for j in range(0,lenr):
            outputstate[i][j] = ket2dm(states[i][j])
            
    return outputstate
    
   
def MCaverage(inputstates):   
    states = MCkettodm(inputstates)
    outputstate = states[0]-states[0]
    lenc = len(states)
    lenr = len(states[0])
    for j in range(0,lenr):
        for i in range(0,lenc):
            outputstate[j] += states[i][j]
        outputstate[j] = outputstate[j]/lenc
    
    return outputstate

def MCaverage2(inputstates):   
    states = inputstates
    outputstate = states-states
    lenc = len(states)
    lenr = len(states[0])
    for j in range(0,lenc):
        states1=states[j]
        for ii in range(0,lenr):
            states1[ii]=ket2dm(states[j][ii])
        outputstate[j] = np.mean(states1)
    
    return outputstate
    
def EvolveCircuits(Operators):
    
    #List of Gates: 'I','X','Y', 'Z', 'H', 'CX', 'CY', 'CZ', 'CNOT', 'SWAP', 'iSWAP', 'CSWAP', 'CCNOT', 'sSWAP', 'siSWAP', 'sNOT'
    
    if APRType==0:
        psi0=tensor(basis(3,0),basis(3,0) ,(basis(3,0)+basis(3,1)).unit(),basis(3,0) ,basis(3,0),basis(N,0))
    elif APRType==1:
        psi0=tensor(basis(3,0),basis(3,0) ,(basis(3,0)+basis(3,1)).unit(),basis(3,0) ,basis(3,0))
        
        
    psi=psi0
    
    H,args,t1=GenerateH(Operators)
    
    
#    print(H)
#    print(args)
    
    tlist=np.arange(0,t1+1)
    if MC:
        output=mcsolve(H,psi,tlist,c_op_list,[],args=args,options=options)
        states=MCaverage2(output.states)
    else:
        output=mesolve(H,psi,tlist,c_op_list,[],args=args,options=options)
        states=output.states
          
    
    expect_x=[]
    expect_y=[]
    expect_z=[]
    expect_x,expect_y,expect_z=plotstate(states,tlist)
    
    return states, tlist, expect_x,expect_y,expect_z
    
    
def TestGate():
    #List of Gates: 'I','X','Y', 'Z', 'H', 'CX', 'CY', 'CZ', 'CNOT', 'SWAP', 'iSWAP', 'CSWAP', 'CCNOT', 'sSWAP', 'siSWAP', 'sNOT'
    
    psi0=tensor(basis(3,0),basis(3,0) ,basis(3,0),basis(3,0) ,basis(3,0),basis(N,0))
    psi1=tensor(basis(3,1),basis(3,0) ,basis(3,0),basis(3,0) ,basis(3,0),basis(N,0))
    psi2=tensor((basis(3,0)+basis(3,1)).unit(),basis(3,0) ,basis(3,0),basis(3,0) ,basis(3,0),basis(N,0))
    psi3=tensor((basis(3,0)+1j*basis(3,1)).unit(),basis(3,0) ,basis(3,0),basis(3,0) ,basis(3,0),basis(N,0))
        
    H,args=GenerateH(Operators)
    LenSingleOperator=GetLen(Operators)
        
    tlist=np.arange(0,LenSingleOperator+1)
    
    
    
    Us = propagator(H, tlist, [],options=options,args=args)
    U_e=Us[-1]
    print(U_e)

if __name__=='__main__':
    starttime=clock()
    
    ## Approximation Type{ 0: Consider Cavity but no direct coupling between qubits; 1: No cavity but consider direct coupling between qubits}
    APRType=1
    
    ## Qubit number
    Num_Q=5
    
    ## Savedata 
    SD=False
    
    ## add dissipation
    Dis=False
    
    ## Use monte-carlo solver
    MC=False
    
    if Dis==False:
        MC=False
    
    ## Cavity Frequency
    w_c= 6.5 * 2 * np.pi
    
    ## Qubits frequency
    w_q = np.array([ 5.0 , 5.1 , 5.2 , 5.3 , 5.4 ]) * 2 * np.pi
    
    ## Coupling Strength
    g = np.array([0.0, 0.0, 0.0, 0.0, 0.0]) * 2 * np.pi
#    g = np.array([0.03, 0.03, 0.03, 0.03, 0.03]) * 2 * np.pi
    
    ## Qubits Anharmonicity
    w_qa=  np.array([0.25, 0.25, 0.25, 0.25, 0.25]) * 2 * np.pi
    
    ## Base Temperature(K)
    n_th=0.01
    
    ## 1/T_1
    gamma = np.array([1./10 , 1./10 , 1./10 , 1./10 , 1./10 ]) * 1e-3    
        
    ## 1/T_phi                
    gamma_phi = np.array([1./10 , 1./10 , 1./10 , 1./10 , 1./10 ]) * 1e-3
                
    ## Define Circuit
    Operators=[
        ['X4','Y4','Z4','I60','X4'],
#        ['Y','Z','I','X','Y'],
#        ['Z','I','X','Y','Z'],
        ]                    
                        
    ### Effective Coulping Strength                    
    #g_eff=g[0]*g[1]/(w_q[0]-w_c)/(w_q[1]-w_c)*(w_q[0]-w_c+w_q[1]-w_c)
    #print(g_eff/(2*np.pi)*1000)
    
    ## Cavity Ladder Number
    N=3
    
    options=Options()
    #options.atol=1e-12
    #options.rtol=1e-10
    options.first_step=0.01
    options.num_cpus=8
    options.nsteps=1e6
    options.gui='True'
    options.ntraj=1000
    options.rhs_reuse=False
    
    ## Create Basic Operator
    a, sm, smm, E_e, E_g, Sz, Sx, Sy=CreateBasicOperator(APRType)             
    
    ## Create Dissipation Term
    c_op_list=GenerateDissipation(Dis)
    
    ## Do Evolution
    psi_total, tlist_total, expect_x,expect_y,expect_z=EvolveCircuits(Operators)
    
    ## save data
    if SD:
        savedata(psi_total, tlist_total, expect_x,expect_y,expect_z)

    finishtime=clock()
    print( 'Time used: ', (finishtime-starttime), 's')

