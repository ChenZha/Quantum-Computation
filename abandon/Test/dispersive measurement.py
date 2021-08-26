# -*- coding: utf-8 -*-
"""
Created on Sun Feb 19 08:49:52 2017

@author: Chen
"""
'''
可能信号太小，测量Nc和Na是否共振信号太小，只能用phase shift
'''

from qutip import *
import numpy as np
import matplotlib.pyplot as plt 
from qutip import gates


from time import clock
starttime=clock()


wc = 2.0  * 2 * pi  # cavity frequency
wa = 3.0  * 2 * pi  # atom frequency
wd = 2.04 * 2 * pi
g  = 0.05 * 2 * pi  # coupling strength
omega = 0  * 2 * pi
N = 15              # number of cavity fock states
n = 8

tlist = np.linspace(0,10,101)
psi0 = tensor(basis(N,n), basis(2,0))    # start with an excited atom
a  = tensor(destroy(N), qeye(2))
sm = tensor(qeye(N), destroy(2))

#==============================================================================
def evo(t,args=None):
    return np.cos(wd*t) 
#==============================================================================
H0 = wc * a.dag() * a + wa * sm.dag() * sm + g * (a.dag() + a) * (sm + sm.dag())
H1 = [omega*(sm+sm.dag()),evo]
H = [H0,H1]


output = mesolve(H, psi0, tlist, [], [a.dag()*a,sm.dag()*sm])
n_c = output.expect[0]
n_a = output.expect[1]

fig, axes = plt.subplots(1, 1, figsize=(10,6))

axes.plot(tlist, n_c, label="Cavity")
axes.plot(tlist, n_a, label="Atom excited state")
axes.legend(loc=1)
axes.set_xlabel('Time')
axes.set_ylabel('Occupation probability')
axes.set_title('Vacuum Rabi oscillations')

finishtime=clock()
print 'Time used: ', (finishtime-starttime), 's'
