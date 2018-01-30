# -*- coding: utf-8 -*-
"""
Created on Mon Feb 20 13:32:45 2017

@author: lenovo
"""

from qutip import *
import numpy as np
import matplotlib.pyplot as plt 
from qutip import gates


from time import clock
starttime=clock()

wc = 3.0  * 2 * pi  # cavity frequency
wa = 3.0  * 2 * pi  # atom frequency

g  = 0.2 * 2 * pi  # coupling strength

N = 3               # number of cavity fock states
n = 0               # number of photon
level = 2
#==============================================================================
omega = 0.02*2*np.pi
width = 10
t0 = 0
t1 = 40
#==============================================================================
tlist = np.linspace(0,40,500)
psi0 = tensor(basis(N,n), basis(level,1))    # start with an excited atom
a  = tensor(destroy(N), qeye(2))
sm = tensor(qeye(N), destroy(2))
sx = tensor(qeye(N),sigmax())
sy = tensor(qeye(N),sigmay())
sz = tensor(qeye(N),sigmaz())
#==============================================================================
def evo(t,args = None):
    return(np.cos(wc*t))
#==============================================================================
def evo1(t,args = None):
    return omega*np.exp(-(t-20)**2/2.0/width**2)
#==============================================================================
def rotation(tlist , state, phi = 0 , args = None):
    '''
    从旋转坐标系转回来
    '''
    rostate = array(state)-array(state)
    rostate = rostate.tolist()
    lenc = len(tlist)
    for i in range(0,lenc):
        M = tensor(qeye(N),Qobj([[np.exp(1j*(wc*tlist[i]+phi)/2),0],[0,np.exp(-1j*(wc*tlist[i]+phi)/2)]]))
#        print(M)
        rostate[i] = M*state[i]
        
    return(rostate)
#==============================================================================
#H0 = wa*sm.dag()*sm 
#H1 = [ g*(sm.dag()+sm),evo]
#H = [H0,H1]
#
#result = mesolve(H,psi0,tlist,[],[sx,sy,sz,sm.dag()*sm,a.dag()*a])
#sphere = Bloch()
#sphere.add_points([result.expect[0], result.expect[1], result.expect[2]])
#sphere.make_sphere()
#plt.show()
#fig, axes = plt.subplots(1, 5, figsize=(10,6))
#axes[0].plot(tlist, result.expect[0])
#axes[1].plot(tlist, result.expect[1])
#axes[2].plot(tlist, result.expect[2])
#axes[3].plot(tlist, result.expect[3])
#axes[4].plot(tlist, result.expect[4])
#axes[0].set_title('X')
#axes[1].set_title('Y')
#axes[2].set_title('Z')
#axes[3].set_title('N_a')
#axes[4].set_title('N_c')


#H = g*(sm.dag()+sm)/2

#result = mesolve(H,psi0,tlist,[],[])
#resultl = rotation(tlist,result.states)
#ex = []
#ex.append(expect(sx,resultl))
#ex.append(expect(sy,resultl))
#ex.append(expect(sz,resultl))
#ex.append(expect(sm.dag()*sm,resultl))
#ex.append(expect(a.dag()*a,resultl))
#sphere = Bloch()
#sphere.add_points([ex[0], ex[1], ex[2]])
#sphere.make_sphere()
#plt.show()
#fig, axes = plt.subplots(1, 5, figsize=(10,6))
#axes[0].plot(tlist, ex[0])
#axes[1].plot(tlist, ex[1])
#axes[2].plot(tlist, ex[2])
#axes[3].plot(tlist, ex[3])
#axes[4].plot(tlist, ex[4])
#axes[0].set_title('X')
#axes[1].set_title('Y')
#axes[2].set_title('Z')
#axes[3].set_title('N_a')
#axes[4].set_title('N_c')

H1 = [(sm.dag()+sm),evo1]
H = [H1]
#H = g*(sm.dag()+sm)/2+wa*sm.dag()*sm 
#result = mesolve(H,psi0,tlist,[],[sx,sy,sz,sm.dag()*sm,a.dag()*a])
result = mesolve(H,psi0,tlist,[],[sx,sy,sz,sm.dag()*sm,a.dag()*a])
sphere = Bloch()
sphere.add_points([result.expect[0], result.expect[1], result.expect[2]])
sphere.make_sphere()
plt.show()
fig, axes = plt.subplots(1, 5, figsize=(10,6))
axes[0].plot(tlist, result.expect[0])
axes[1].plot(tlist, result.expect[1])
axes[2].plot(tlist, result.expect[2])
axes[3].plot(tlist, result.expect[3])
axes[4].plot(tlist, result.expect[4])
axes[0].set_title('X')
axes[1].set_title('Y')
axes[2].set_title('Z')
axes[3].set_title('N_a')
axes[4].set_title('N_c')

finishtime=clock()
print 'Time used: ', (finishtime-starttime), 's'