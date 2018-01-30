#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Mar 20 22:33:10 2017

@author: chen
"""

from time import clock
from qutip import *
import numpy as np
import matplotlib.pyplot as plt 
from pylab import *
from gate_evolution import *
from multiprocessing import Pool
import os

def Opt_CZ_deltat(deltat):
    
    
    
    quset = qusetting()
    Operator = ['CZ1'  ,  'I' ]
    qtype = 1
    quset.qtype = qtype
    if quset.qtype == 1:
        a,sm,E_uc,E_e,E_g,sn,sx,sxm,sy,sym,sz,En = initial(quset)
        psi0 = tensor(basis(quset.N,quset.n) , (basis(3,0)+basis(3,1)).unit(),  (basis(3,0)+basis(3,1)).unit())
        psi0 = tensor(basis(quset.N,quset.n) , (basis(3,1)).unit(),  (basis(3,0)+basis(3,1)).unit())
        
        target = tensor(basis(quset.N,quset.n) , basis(3,1) ,  (basis(3,0)-basis(3,1)).unit())
#        tar = (tensor(basis(3,0) , basis(3,0))+tensor(basis(3,1) , basis(3,0))+tensor(basis(3,0) , basis(3,1))-tensor(basis(3,1) , basis(3,1))).unit()
#        target = tensor(basis(quset.N,quset.n),tar)

        quset.CZ_deltat = deltat
#        quset.ramp = deltat
        result , tlist = gate_evolution(psi0,Operator,setting = quset)
        

        rf0 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(En[0])*tlist[-1])*basis(3,1)*basis(3,1).dag()
        rf1 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(En[1])*tlist[-1])*basis(3,1)*basis(3,1).dag()
        U = tensor(qeye(quset.N),rf0,rf1)
        
        fid=fidelity(U*result.states[-1]*result.states[-1].dag()*U.dag(), target)
    elif quset.qtype == 2:
        sm,E_uc,E_e,E_g,sn,sx,sxm,sy,sym,sz,En = initial(quset)
        psi0 = (tensor(basis(3,0) , basis(3,0))+tensor(basis(3,1) , basis(3,0))+tensor(basis(3,0) , basis(3,1))+tensor(basis(3,1) , basis(3,1))).unit()
        target = (tensor(basis(3,0) , basis(3,0))+tensor(basis(3,1) , basis(3,0))+tensor(basis(3,0) , basis(3,1))-tensor(basis(3,1) , basis(3,1))).unit()
        quset.ramp = deltat
        result , tlist = gate_evolution(psi0,Operator,setting = quset)
        
#        rf01 = np.exp(1j*(w02[0])*tlist[-1])*basis(3,2)*basis(3,2).dag()
#        rf02 = np.exp(1j*(En[0])*tlist[-1])*basis(3,1)*basis(3,1).dag()
        rf0 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(En[0])*tlist[-1])*basis(3,1)*basis(3,1).dag()
#        rf11 = np.exp(1j*(w02[1])*tlist[-1])*basis(3,2)*basis(3,2).dag()
        rf1 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(En[1])*tlist[-1])*basis(3,1)*basis(3,1).dag()
        U = tensor(rf0,rf1)
        fid=fidelity(U*result.states[-1]*result.states[-1].dag()*U.dag(), target)
        
    
    
    
    return([fid,deltat])

if __name__ == '__main__':
    starttime=clock()
    g = linspace(1,200,200)
#    g = [0.033358578617]
    p = Pool(16)
    A = p.map(Opt_CZ_deltat,g)
    p.close()
    p.join()
    fid =  np.array([x[0] for x in A])
    CZ_deltat = np.array([x[1] for x in A])
    opt = CZ_deltat[np.where(fid== max(fid))]
    
    print(opt[0]  , max(fid))
    

    
    finishtime=clock()
    print( 'Time used: ', (finishtime-starttime), 's')