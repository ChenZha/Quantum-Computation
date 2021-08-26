# -*- coding: utf-8 -*-
"""
Created on Tue Feb 21 09:04:25 2017

@author: Chen
"""
from qutip import *
import numpy as np
import matplotlib.pyplot as plt 
from qutip import gates


from time import clock
starttime=clock()

wc = 6.0  * 2 * pi  # cavity frequency
wa1 = 5.0  * 2 * pi  # atom frequency
wa2 = 5.0  * 2 * pi  # atom frequency
g1  = 0.1 * 2 * pi  # coupling strength
g2  = 0.1 * 2 * pi  # coupling strength
g = 0.05 * 2 * pi
delta = 0.0 * 2 *pi #anharmonicity

N = 10              # number of cavity fock states
n= 5
level = 3

tlist = np.linspace(0,30,4001)

psi0 = tensor(basis(N,0), basis(3,0), basis(3,2))    # start with an excited atom
a  = tensor(destroy(N), qeye(3), qeye(3))
sm1 = tensor(qeye(N), destroy(3), qeye(3))
sm2 = tensor(qeye(N), qeye(3), destroy(3))
sx1 = tensor(qeye(N),jmat(1,'x'), qeye(3))
sy1 = tensor(qeye(N),jmat(1,'y'), qeye(3))
sz1 = tensor(qeye(N),jmat(1,'z'), qeye(3))
sx2 = tensor(qeye(N), qeye(3),jmat(1,'x'))
sy2 = tensor(qeye(N), qeye(3),jmat(1,'y'))
sz2 = tensor(qeye(N), qeye(3),jmat(1,'z'))

#==============================================================================
def threelevel(wa,delta):
    M = zeros([3,3])
    M[1,1] = wa
    M[2,2] = 2*wa - delta
    return(Qobj(M))
#==============================================================================
qulevel1 = tensor(qeye(N), threelevel(wa1,delta), qeye(3))
qulevel2 = tensor(qeye(N), qeye(3), threelevel(wa2,delta))
#==============================================================================
'''
通过腔耦合
'''
#H = wc * a.dag() * a + wa1 * sm1.dag() * sm1 + g1 * (a.dag() + a) * (sm1 + sm1.dag()) + wa2 * sm2.dag() * sm2 + g2 * (a.dag() + a) * (sm2 + sm2.dag())
#
#result = mesolve(H,psi0,tlist,[],[sx1,sy1,sz1,sm1.dag()*sm1,sx2,sy2,sz2,sm2.dag()*sm2,a.dag()*a])
#
#sphere = Bloch()
#sphere.add_points([result.expect[0], result.expect[1], result.expect[2]])
#sphere.make_sphere()
#plt.show()
#sphere = Bloch()
#sphere.add_points([result.expect[4], result.expect[5], result.expect[6]])
#sphere.make_sphere()
#plt.show()
#fig, axes = plt.subplots(2, 5, figsize=(10,6))
#axes[0][0].plot(tlist, result.expect[0])
#axes[0][1].plot(tlist, result.expect[1])
#axes[0][2].plot(tlist, result.expect[2])
#axes[0][3].plot(tlist, result.expect[3])
#axes[0][4].plot(tlist, result.expect[8])
#axes[0][0].set_title('X1')
#axes[0][1].set_title('Y1')
#axes[0][2].set_title('Z1')
#axes[0][3].set_title('N_a1')
#axes[0][4].set_title('N_c')
#axes[1][0].plot(tlist, result.expect[4])
#axes[1][1].plot(tlist, result.expect[5])
#axes[1][2].plot(tlist, result.expect[6])
#axes[1][3].plot(tlist, result.expect[7])
#axes[1][4].plot(tlist, result.expect[8])
#axes[1][0].set_title('X2')
#axes[1][1].set_title('Y2')
#axes[1][2].set_title('Z2')
#axes[1][3].set_title('N_a2')
#axes[1][4].set_title('N_c')
#==============================================================================


#==============================================================================
'''
直接耦合
'''
#H = wa1 * sm1.dag() * sm1 + wa2 * sm2.dag() * sm2 + g*sy1*sy2
#result = mesolve(H,psi0,tlist,[],[sx1,sy1,sz1,sm1.dag()*sm1,sx2,sy2,sz2,sm2.dag()*sm2,a.dag()*a])
#sphere = Bloch()
#sphere.add_points([result.expect[0], result.expect[1], result.expect[2]])
#sphere.make_sphere()
#plt.show()
#sphere = Bloch()
#sphere.add_points([result.expect[4], result.expect[5], result.expect[6]])
#sphere.make_sphere()
#plt.show()
#fig, axes = plt.subplots(2, 5, figsize=(10,6))
#axes[0][0].plot(tlist, result.expect[0])
#axes[0][1].plot(tlist, result.expect[1])
#axes[0][2].plot(tlist, result.expect[2])
#axes[0][3].plot(tlist, result.expect[3])
#axes[0][4].plot(tlist, result.expect[8])
#axes[0][0].set_title('X1')
#axes[0][1].set_title('Y1')
#axes[0][2].set_title('Z1')
#axes[0][3].set_title('N_a1')
#axes[0][4].set_title('N_c')
#axes[1][0].plot(tlist, result.expect[4])
#axes[1][1].plot(tlist, result.expect[5])
#axes[1][2].plot(tlist, result.expect[6])
#axes[1][3].plot(tlist, result.expect[7])
#axes[1][4].plot(tlist, result.expect[8])
#axes[1][0].set_title('X2')
#axes[1][1].set_title('Y2')
#axes[1][2].set_title('Z2')
#axes[1][3].set_title('N_a2')
#axes[1][4].set_title('N_c')
#==============================================================================

#==============================================================================
H = qulevel1 + qulevel2 * sm2 + g*sy1*sy2
result = mesolve(H,psi0,tlist,[],[sx1,sy1,sz1,sm1.dag()*sm1,sx2,sy2,sz2,sm2.dag()*sm2,a.dag()*a])
sphere = Bloch()
sphere.add_points([result.expect[0], result.expect[1], result.expect[2]])
sphere.make_sphere()
plt.show()
sphere = Bloch()
sphere.add_points([result.expect[4], result.expect[5], result.expect[6]])
sphere.make_sphere()
plt.show()
fig, axes = plt.subplots(2, 5, figsize=(10,6))
axes[0][0].plot(tlist, result.expect[0])
axes[0][1].plot(tlist, result.expect[1])
axes[0][2].plot(tlist, result.expect[2])
axes[0][3].plot(tlist, result.expect[3])
axes[0][4].plot(tlist, result.expect[8])
axes[0][0].set_title('X1')
axes[0][1].set_title('Y1')
axes[0][2].set_title('Z1')
axes[0][3].set_title('N_a1')
axes[0][4].set_title('N_c')
axes[1][0].plot(tlist, result.expect[4])
axes[1][1].plot(tlist, result.expect[5])
axes[1][2].plot(tlist, result.expect[6])
axes[1][3].plot(tlist, result.expect[7])
axes[1][4].plot(tlist, result.expect[8])
axes[1][0].set_title('X2')
axes[1][1].set_title('Y2')
axes[1][2].set_title('Z2')
axes[1][3].set_title('N_a2')
axes[1][4].set_title('N_c')
#==============================================================================

finishtime=clock()
print 'Time used: ', (finishtime-starttime), 's'

