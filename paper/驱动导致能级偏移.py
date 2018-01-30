# -*- coding: utf-8 -*-
"""
Created on Sun Feb 26 15:25:11 2017

@author: lenovo
"""

from qutip import *
import numpy as np
import matplotlib.pyplot as plt 
from qutip import gates


from time import clock
starttime=clock()

wc = 6.0  * 2 * pi  # cavity frequency
wq = 5.0 * 2 * np.pi
n= 5
glist = np.linspace(0.01 , 0.1 , n) * 2 *np.pi


tlist = np.linspace(0,1,101)
energylevel = []
for g in glist:
    energy = []
    for t in tlist:
        H = -wq*sigmaz()/2 + g * np.cos(wq*t) * sigmax()
        split = H.eigenenergies()[1]-H.eigenenergies()[0]
        energy.append(split)
    energylevel.append(energy)

fig, axes = plt.subplots(1, n, figsize=(10,6))
for i in range(0,n):
    axes[i].plot(tlist, energylevel[i])


fig, axes = plt.subplots(1, 1, figsize=(10,6))
axes.plot(glist, array(energylevel)[:,0])
    
finishtime=clock()
print 'Time used: ', (finishtime-starttime), 's'