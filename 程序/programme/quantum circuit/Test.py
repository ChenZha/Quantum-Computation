#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Mar 17 21:36:26 2017

@author: chen
"""

from qutip import *
import numpy as np
import matplotlib.pyplot as plt 
from pylab import *
from gate_evolution import *

from time import clock
starttime=clock()


quset = qusetting()
Operator = ['I2','I']
#Operator = ['Y'  ,  'X' ]
#Operator = ['iswap1'  ,  'I' ]
#psi0 = tensor(basis(quset.N,quset.n) , (basis(3,0)+basis(3,1)).unit() ,  (basis(3,0)-basis(3,1)).unit())
#psi0 = tensor(basis(quset.N,quset.n)  ,  basis(3,1), (basis(3,0)+basis(3,1)).unit())
#psi0 = tensor(basis(quset.N,quset.n) , (basis(3,0)+basis(3,1)).unit() ,  (basis(3,1)).unit())
psi0 = tensor(basis(quset.N,quset.n) , basis(3,0) ,  basis(3,0))
#psi0 = tensor(basis(3,1) ,  (basis(3,0)+basis(3,1)).unit())
quset.DRAG = True
#quset.omega = 0.033243043043
#quset.CZ_deltat = 323.5
#quset.CZ_deltat = 600
#quset.iswap_deltat = 20
quset.qtype = 1 
sm,E_uc,E_e,E_g,sn,sx,sxm,sy,sym,sz,En = initial(quset)[-11:]
#quset.Dis = False
result , tlist = gate_evolution(psi0 , Operator , setting = quset)
#print(ptrace(result.states[250],1))
evolutionplot(0 , result , tlist , setting = quset)
evolutionplot(1 , result , tlist , setting = quset)

#print(ptrace(result.states[450],1))
#rf01 =np.exp(1j*(w02[0])*tlist[-1])*basis(3,2)*basis(3,2).dag()
#rf02 = np.exp(1j*(En[0])*tlist[-1])*basis(3,1)*basis(3,1).dag()
rf0 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(En[0])*tlist[-1])*basis(3,1)*basis(3,1).dag()
#rf11 = np.exp(1j*(w02[1])*tlist[-1])*basis(3,2)*basis(3,2).dag()
#rf12 = np.exp(1j*(En[1])*tlist[-1])*basis(3,1)*basis(3,1).dag()
rf1 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(En[1])*tlist[-1])*basis(3,1)*basis(3,1).dag()
#U = tensor(qeye(quset.N),rf0,rf1)
U = tensor(qeye(3),rf0,rf1)

#target = sxm[0]*psi0
#target = tensor(basis(quset.N,quset.n) , (basis(3,0)-basis(3,1)).unit() ,  basis(3,1))
target = tensor(basis(quset.N,quset.n)  ,  basis(3,1), (basis(3,0)-basis(3,1)).unit())
#target = tensor(basis(quset.N,quset.n) , (basis(3,0)-basis(3,1)).unit() ,  (basis(3,0)+basis(3,1)).unit())
#target = tensor(basis(3,1), (basis(3,0)-basis(3,1)).unit())
#tar = (tensor(basis(3,0) , basis(3,0))+tensor(basis(3,1) , basis(3,0))+tensor(basis(3,0) , basis(3,1))-tensor(basis(3,1) , basis(3,1))).unit()
#target = tensor(basis(quset.N,quset.n),tar)
fid=fidelity(U*result.states[-1]*result.states[-1].dag()*U.dag(), target)
#fid1=fidelity(ptrace(U*result.states[-1],2), ptrace(target,2))
#print(fid)

##rf01 =np.exp(1j*(w02[0])*tlist[-1])*basis(3,2)*basis(3,2).dag()
#rf02 = np.exp(1j*(En[0])*tlist[-1])*basis(3,1)*basis(3,1).dag()
#rf0 = basis(3,0)*basis(3,0).dag()+rf02
##rf11 = np.exp(1j*(w02[1])*tlist[-1])*basis(3,2)*basis(3,2).dag()
#rf12 = np.exp(1j*(En[1])*tlist[-1])*basis(3,1)*basis(3,1).dag()
#rf1 = basis(3,0)*basis(3,0).dag()+rf12
#U = tensor(rf0,rf1)
#
##target = sxm[0]*sxm[1]*psi0
#target = tensor(basis(3,1) ,  (basis(3,0)-basis(3,1)).unit())
#fid0=fidelity(ptrace(U*result.states[-1],0), ptrace(target,0))
#fid1=fidelity(ptrace(U*result.states[-1],1), ptrace(target,1))
#print(fid0,fid1)


finishtime=clock()
print ('Time used: ', (finishtime-starttime), 's')