#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Jul 16 20:44:08 2017

@author: chen
"""
''' 
寻找CZ波形参数，两个qubit的能级都要调，然后进行相位补偿，参数: (tp),delta0,delta1,xita0,xita1 
'''

import scipy 
import numpy as np
from functools import partial
from Qubits import Qubits
import copy
from qutip import *


def initial_wave():
    
    resolution = 1024
    thf = 0.55*np.pi/2;
    thi = 0.05;
    lam2 = -0.18;
    lam3 = 0.04;
    resolution = 1024;
    
    ti=np.linspace(0,1,resolution)
    han2 = np.vectorize(lambda ti:(1-lam3)*(1-np.cos(2*np.pi*ti))+lam2*(1-np.cos(4*np.pi*ti))+lam3*(1-np.cos(6*np.pi*ti)))
    han2 = han2(ti)
    thsl=thi+(thf-thi)*han2/max(han2)
    x = 1/np.tan(thsl);
    x = x-x[0];
    
    tlu = np.cumsum(np.sin(thsl))*ti[1]
    tlu=tlu-tlu[0]
    ti=np.linspace(0, tlu[-1], resolution)
    th=scipy.interpolate.interp1d(tlu,thsl,'slinear')
    th = th(ti)
    th=1/np.tan(th)
    th=th-th[0]
    th=th/min(th)

    return(th)

def CZ0(t,args):
    tp = args['T_P']
    delta = args['delta0']
    compen_1 = args['compen0_1']
    compen_2 = args['compen0_2']
    resolution = 1024
    th = initial_wave()
    tlistCZ = np.linspace(0,tp,resolution)
    w = scipy.interpolate.interp1d(tlistCZ,delta*th,'slinear')
    if t>=0 and t<=0.15*tp:
        w = w(t)
    elif t>0.15*tp and t<= 0.85*tp:
        w = w(t)+compen_1*np.cos(2*np.pi/(0.7*tp)*t)+compen_2*np.cos(2*2*np.pi/(0.7*tp)*t)
    elif t>0.85*tp and t<=tp:
        w = w(t)
    else:
        w = 0
            
    return(w) 
def CZ1(t,args):
    tp = args['T_P']
    delta = args['delta1']
    compen_1 = args['compen1_1']
    compen_2 = args['compen1_2']
    th = initial_wave()
    resolution = 1024
    tlistCZ = np.linspace(0,tp,resolution)
    w = scipy.interpolate.interp1d(tlistCZ,delta*th,'slinear')
    if t>=0 and t<=0.15*tp:
        w = w(t)
    elif t>0.15*tp and t<= 0.85*tp:
        w = w(t)+compen_1*np.cos(2*np.pi/(0.7*tp)*t)+compen_2*np.cos(2*2*np.pi/(0.7*tp)*t)
    elif t>0.85*tp and t<=tp:
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
    
    fid = fidelity(UT*output.states[-1]*output.states[-1].dag()*UT.dag(),target)
    
    leakage = [expect(E_uc[0],output.states[-1]) , expect(E_uc[1],output.states[-1])]
    
    return([fid,leakage,UT*output.states[-1]])
    


def CNOT(P):
    
    
    delta0 = P[0]
    delta1 = P[1]
    xita0 = P[2]
    xita1 = P[3]
    compen0_1 = P[4]
    compen0_2 = P[5]
    compen1_1 = P[6]
    compen1_2 = P[7]

    N_level = 3
    coupling = np.array([0.0138]) * 2 * np.pi
    frequency= np.array([4.3 , 5.18  ]) * 2 * np.pi
    eta_q=  np.array([-0.230 , -0.216]) * 2 * np.pi
    parameter = [frequency,coupling,eta_q,N_level]
    QBE = Qubits(qubits_parameter = parameter)
    
    
    
    
    Hd0 = [QBE.sm[0].dag()*QBE.sm[0],CZ0]
    Hd1 = [QBE.sm[1].dag()*QBE.sm[1],CZ1]
    Hdrive = [Hd0,Hd1]


    args = {'T_P':45,'T_copies':1001 , 'delta0':delta0 , 'delta1':delta1 , 'xita0':xita0 , 'xita1':xita1,'compen0_1':compen0_1,'compen0_2':compen0_2,'compen1_1':compen1_1,'compen1_2':compen1_2}

    final = QBE.process(drive = Hdrive,process_plot = False , parallel = True , argument = args)
    final = QBE.phase_comp(final , [xita0 , xita1])
    # targetprocess = np.array([[1,0,0,0],[0,1,0,0],[0,0,1,0],[0,0,0,-1]])

    # Ufidelity = np.abs(np.trace(np.dot(np.conjugate(np.transpose(targetprocess)),final)))/(2**QBE.num_qubits)
    # print(P , Ufidelity)
    np.savetxt('evolution _3.txt',final,fmt='%.8f',delimiter=',', newline='a',)
    return(final)

    







if __name__=='__main__':
    
    process = CNOT([ 3.28223493,-0.87506933,2.98331095,1.829626,-0.14838399,0.10973198, -0.14125958,0.15415665])
    print('a')