# -*- coding: utf-8 -*-
"""
Created on Mon Feb 06 21:18:36 2017

@author: chen
"""
from qutip import *
import numpy as np
import matplotlib.pyplot as plt 
from qutip import gates
import math
from time import clock


wd = 1.0  * 2 * pi  # drive frequency
wa = 1.0  * 2 * pi  # atom frequency
omega  = 0.05 * 2 * pi  # coupling 
fai0 = pi

#==============================================================================
def evo(t,arg = None):
    return math.cos(wd*t + fai0)    
#==============================================================================

#tlist = np.linspace(0,25,1001)
psi0 = basis(2,1)    # start with an excited atom
sm = destroy(2)


#H = omega*sigmax()/2 + (wa-wd)*sigmaz()/2
#output1 = mesolve(H, psi0, tlist, [], [sm.dag()*sm])
#
#H0 = wa*sigmaz()/2
#H1 = [omega*sigmax(),evo]
#H = [H0,H1]
#output2 = mesolve(H, psi0, tlist, [], [sm.dag()*sm])
#
#
#fig, axes = plt.subplots(1, 2, figsize=(10,6))
#axes[0].plot(tlist,output1.expect[0])
#axes[0].set_xlabel('Time')
#axes[0].set_ylabel('Occupation probability')
#axes[0].set_title('With RWA')
#axes[1].plot(tlist,output2.expect[0])
#axes[1].set_xlabel('Time')
#axes[1].set_ylabel('Occupation probability')
#axes[1].set_title('Without RWA')


#==============================================================================
'with RWA'
def evolution1(tlist):
    
    H = omega*sigmax()/2 + (wa-wd)*sigmaz()/2
    starttime1 = clock()
    
    output = mesolve(H, psi0, tlist, [], [sm.dag()*sm])
    
    finishtime1 = clock()
    duration1 = finishtime1-starttime1
    return duration1
    #print 'Time used: ', duration1, 's','\tWith RWA'
    
    #fig, axes = plt.subplots(1, 1, figsize=(10,6))
    #axes.plot(tlist,output.expect[0])
    #axes.set_xlabel('Time')
    #axes.set_ylabel('Occupation probability')
    #axes.set_title('With RWA')
#==============================================================================




#==============================================================================
'without RWA'
def evolution2(tlist):

    H0 = wa*sigmaz()/2
    H1 = [omega*sigmax(),evo]
    H = [H0,H1]
    starttime2 = clock()
    
    output = mesolve(H, psi0, tlist, [], [sm.dag()*sm])
    
    finishtime2 = clock()
    duration2 = finishtime2-starttime2
    return duration2
    #print 'Time used: ', duration2, 's','\tWithout RWA'
    
    #fig, axes = plt.subplots(1, 1, figsize=(10,6))
    #axes.plot(tlist,output.expect[0])
    #axes.set_xlabel('Time')
    #axes.set_ylabel('Occupation probability')
    #axes.set_title('Without RWA')
##==============================================================================
    
    
    
#==============================================================================
'时间变化'
duration1 = []
duration2 = []
mutiple = []
region = range(1,1000,20)
for t in region:
    tlist = np.linspace(0,t,101)
    a = evolution1(tlist)
    b = evolution2(tlist)
    duration1.append(a)
    duration2.append(b)
    mutiple.append(b/a)
    
    
    
    
fig, axes = plt.subplots(1, 3)
axes[0].plot(region,duration1)
axes[0].set_xlabel('Time')
axes[0].set_ylabel('Duration-1')
axes[0].set_title('With RWA')

axes[1].plot(region,duration2)
axes[1].set_xlabel('Time')
axes[1].set_ylabel('Duration-2')
axes[1].set_title('Without RWA')

axes[2].plot(region,mutiple)
axes[2].set_xlabel('Time')
axes[2].set_ylabel('Mutiple')
axes[2].set_title('Multiple')

#==============================================================================


#==============================================================================
'步长变化'
duration1 = []
duration2 = []
mutiple = []        
region = range(1,2001,5)
for part in region:
    tlist = np.linspace(0,10,part)
    a = evolution1(tlist)
    b = evolution2(tlist)
    duration1.append(a)
    duration2.append(b)
    mutiple.append(b/a)
    
    
    
    
fig, axes = plt.subplots(1, 3)
axes[0].plot(region,duration1)
axes[0].set_xlabel('Step')
axes[0].set_ylabel('Duration-1')
axes[0].set_title('With RWA')

axes[1].plot(region,duration2)
axes[1].set_xlabel('Step')
axes[1].set_ylabel('Duration-2')
axes[1].set_title('Without RWA')

axes[2].plot(region,mutiple)
axes[2].set_xlabel('Step')
axes[2].set_ylabel('Mutiple')
axes[2].set_title('Multiple')
#==============================================================================
