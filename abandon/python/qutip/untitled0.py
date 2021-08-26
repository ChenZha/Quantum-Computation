# -*- coding: utf-8 -*-
"""
Created on Fri Mar 03 17:06:35 2017

@author: Chen
"""

from qutip import *
import numpy as np
import matplotlib.pyplot as plt 
from qutip import gates

wc = 2.0  * 2 * pi  # cavity frequency
wa0 = 1.9  * 2 * pi  # atom frequency
wa1 = 1.9  * 2 * pi  # atom frequency
g  = 0.05 * 2 * pi  # coupling strength
N = 10

tlist = np.linspace(0,5000,1000)
psi0 = tensor((basis(2,1)+basis(2,0)).unit(),(basis(2,1)+basis(2,0)).unit())  # start with an excited atom

sm0 = tensor(destroy(2),qeye(2)) 
sx0 = tensor(sigmax(),qeye(2)) 
sy0 = tensor(sigmay(),qeye(2)) 
sz0 = tensor(sigmaz(),qeye(2)) 
sm1 = tensor(qeye(2),destroy(2)) 
sx1 = tensor(qeye(2),sigmax()) 
sy1 = tensor(qeye(2),sigmay()) 
sz1 = tensor(qeye(2),sigmaz()) 

E_e0 = tensor(basis(2,1)*basis(2,1).dag(),qeye(2))
E_e1 = tensor(qeye(2),basis(2,1)*basis(2,1).dag())  #激发态

E_g0 = tensor(basis(2,0)*basis(2,0).dag(),qeye(2))
E_g1 = tensor(qeye(2),basis(2,0)*basis(2,0).dag())  #基态

H = wa0*sm0.dag()*sm0+wa1*sm1.dag()*sm1

output = mesolve(H, psi0, tlist, [], [])
#n_c = output.expect[0]
#n_a = output.expect[1]
#
#fig, axes = plt.subplots(1, 1, figsize=(10,6))
#
#axes.plot(tlist, n_c, label="Cavity")
#axes.plot(tlist, n_a, label="Atom excited state")
#axes.legend(loc=1)
#axes.set_xlabel('Time')
#axes.set_ylabel('Occupation probability')
#axes.set_title('Vacuum Rabi oscillations')
nx = []
for t in range(0,len(tlist)):
#    U=(np.exp(1j*wa0*tlist[t])*E_e0+E_g0).dag()
        
    U=tensor(Qobj([[1,0],[0,np.exp(1j*wa0*tlist[t])]]),qeye(2)).dag()
    op=U*sx0*U.dag()
    nx.append(expect(op,output.states[t]))
ny = []
for t in range(0,len(tlist)):
#    U=(np.exp(1j*wa0*tlist[t])*E_e0+E_g0).dag()
    U=tensor(Qobj([[1,0],[0,np.exp(1j*wa0*tlist[t])]]),qeye(2)).dag()
    op=U*sy0*U.dag()
    ny.append(expect(op,output.states[t]))
nz = []
for t in range(0,len(tlist)):
#    U=(np.exp(1j*wa0*tlist[t])*E_e0+E_g0).dag()
    U=tensor(Qobj([[1,0],[0,np.exp(1j*wa0*tlist[t])]]),qeye(2)).dag()
    op=U*sz0*U.dag()
    nz.append(expect(op,output.states[t]))
sphere = Bloch()
sphere.add_points([nx, ny, nz])
sphere.make_sphere()
plt.show()


##wa = 1.9  * 2 * pi  # atom frequency
#wa = 1.9  * 2   # atom frequency
#tlist = np.linspace(0,5000,1000)
#
#psi0 = (basis(2,0)+basis(2,1)).unit()
#sm = destroy(2)
#sx = sigmax()
#sy = sigmay()
#sz = sigmaz()
#
#H = wa*sm.dag()*sm
#output = mesolve(H, psi0, tlist, [], [])
#
#nx = []
#for t in range(0,len(tlist)):
#            U=(Qobj([[1,0],[0,np.exp(1j*wa*tlist[t])]])).dag()
#            op=U*sx*U.dag()
#            nx.append(expect(op,output.states[t]))
#ny = []
#for t in range(0,len(tlist)):
#            U=(Qobj([[1,0],[0,np.exp(1j*wa*tlist[t])]])).dag()
#            op=U*sy*U.dag()
#            ny.append(expect(op,output.states[t]))
#nz = []
#for t in range(0,len(tlist)):
#            U=(Qobj([[1,0],[0,np.exp(1j*wa*tlist[t])]])).dag()
#            op=U*sz*U.dag()
#            nz.append(expect(op,output.states[t]))
#sphere = Bloch()
#sphere.add_points([nx, ny, nz])
#sphere.make_sphere()
#plt.show()