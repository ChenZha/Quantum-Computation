# -*- coding: utf-8 -*-
"""
Created on Sun Jun 19 20:15:23 2016

@author: Logmay
"""
from time import clock
starttime=clock()
#print(starttime)

import matplotlib.pyplot as plt
import numpy as np
from qutip import *

#import os
#os.system("taskset -p 0xff %d" % os.getpid())

N=4

g1 = 0.03 * 2 * np.pi
g2 = 0.03 * 2 * np.pi
g12 = -0.01 * 2 * np.pi

w_q1= 5 * 2 * np.pi
w_q2= 5 * 2 * np.pi
w_c= 6 * 2 * np.pi
w_d=5.025*2*np.pi

#Omega1=0.002*2*np.pi
w_r=5 * 2 * np.pi

a= tensor(qeye(2),qeye(2),destroy(N))
sm1=tensor(destroy(2),qeye(2),qeye(N))
sz1=tensor(sigmaz(),qeye(2),qeye(N))
sm2=tensor(qeye(2),destroy(2),qeye(N))
sz2=tensor(qeye(2),sigmaz(),qeye(N))

#print g1*g2/(w_q1-w_c)/(w_q2-w_c)*(w_q1-w_c+w_q2-w_c)/(2*np.pi)*1000

H0= (w_c - w_r) * a.dag() * a + (w_q1 - w_r) * sm1.dag()*sm1 + (w_q2 - w_r) * sm2.dag()*sm2 + g1 * (a * sm1.dag() + a.dag() * sm1)  + g2 * (a * sm2.dag() + a.dag() * sm2)  + g12 * (sm1 * sm2.dag() + sm1.dag() * sm2) 

H1=sz1
H2=sz2

tlist= np.linspace(0,2000,2001)


A1=0.5*1.2*2*np.pi
omega1=0.5*2*np.pi
A2=0.00*1.2*2*np.pi
omega2=0.06*2*np.pi
H=[H0,[H1,A1*np.cos(omega1*tlist)],[H2,A2*np.cos(omega2*tlist)],
#  -(w_d-w_r)*sz1,Omega1*(sm1.dag()+sm1)
  ]

#print H
#args={'A1':0.05*1.2*2*np.pi,'omega1':0.05*2*np.pi,'A2':0.06*1.2*2*np.pi,'omega2':0.06*2*np.pi,'Omega1':0.002*2*np.pi,'w_d':5.025*2*np.pi,'w_r':5*2*np.pi}    

n_th=0.01
gamma =1./450000         # atom dissipation rate
gamma_phi = 1./100000      # atom dissipation daphsaing rate
c_op_list = []

c_op_list.append(np.sqrt(gamma * (1+n_th)) * sm1)
c_op_list.append(np.sqrt(gamma * n_th) * sm1.dag())
c_op_list.append(np.sqrt(gamma_phi) * sz1)
c_op_list.append(np.sqrt(gamma * (1+n_th)) * sm2)
c_op_list.append(np.sqrt(gamma * n_th) * sm2.dag())
c_op_list.append(np.sqrt(gamma_phi) * sz2)



#Dynamical Evolution
psi0=tensor(basis(2,1),basis(2,0),basis(N,0))

opt=Options()
#opt.atol=1e-3
#opt.rtol=1e-3
##opt.method='bdf'
##opt.order=8
#opt.num_cpus=16
#opt.rhs_reuse='True'
##opt.nsteps=500
#opt.gui='True'
#opt.ntraj=100

output = mesolve(H, psi0, tlist, [], [sm1.dag() * sm1,sm2.dag()*sm2,a.dag()*a],options=opt)
#output = propagator(H, tlist, [],args=args)
#print(output)


fig, axes = plt.subplots(3, 1, figsize=(10,8))
labels=['Q1','Q2','Cavity']
for ii in range(0,3):   
    n_q = output.expect[ii]
    
    axes[ii].plot(tlist, n_q, label=labels[ii])
    
    axes[ii].set_ylim([-0.1,1.1])
    axes[ii].legend(loc=0)
    axes[ii].set_xlabel('Time')
    axes[ii].set_ylabel('P')

plt.show()


"""
psi0=tensor(basis(2,1),basis(2,0),basis(N,0))
tlist= np.linspace(0,1000,1001)
P_shiftr=np.linspace(4.8,5.2,401)
resultmatrix=[]
for P_shift in P_shiftr[0:-1]:
    print P_shift
    args={'A1':0.1*1.2*2*np.pi,'omega1':0.1*2*np.pi,'A2':0.12*1.2*2*np.pi,'omega2':0.12*2*np.pi,'Omega1':0.005*2*np.pi,'w_d':P_shift*2*np.pi,'w_r':5*2*np.pi}    
    output = mesolve(H, psi0, tlist, [], [sm1.dag() * sm1],args=args)  
    dd=output.expect[0]
    resultmatrix.append(dd)
fig,axes = plt.subplots(1, 1, figsize=(10,8))
axes.pcolormesh(tlist,P_shiftr,resultmatrix)
axes.set_xlabel('Time (ns)')
axes.set_ylabel('Driven Freq (GHz)')
axes.set_title('2 dispersive coupled qubit, both QS on with diff mod, test drive Q1 on sideband')
"""

finishtime=clock()
#print(finishtime)
print('Time used: ', (finishtime-starttime), 's')
