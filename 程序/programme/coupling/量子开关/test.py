#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Oct  2 22:35:42 2017

@author: chen
"""

from scipy.special import jn,  jn_zeros
from scipy.optimize import *
import matplotlib.pyplot as plt
import numpy as np
from qutip import *
from pylab import *
import time


def Z_wave(t,args):
    A = args['A']
    omega = args['omega']
    w = A*np.cos(omega*t)
    return(w)

N = 2
wq = 5.0*2*np.pi
wc = 5.0*2*np.pi
g = 0.005*2*np.pi

a = tensor(destroy(N) , qeye(2))
sm = tensor(qeye(N) , destroy(2))

H0 = wq*sm.dag()*sm + wc*a.dag()*a + g * ( sm.dag() + sm ) * ( a.dag() + a )

tlist = np.linspace(0,2000,2001)

omega = 0.7 * 2 * np.pi
A = jn_zeros(0,1)*omega


H = [H0 , [sm.dag()*sm , Z_wave]]

psi0 = tensor(basis(N,0) , basis(2,1))

options=Options()
args = {'A':A,'omega':omega}

output = mesolve(H,psi0,tlist,[],[],args = args,options = options)

exp = [expect(a.dag() * a,output.states),expect(sm.dag() * sm,output.states) , ]


fig, axes = plt.subplots(2, 1, figsize=(10,8))
labels=['cavity','Q1']
for ii in range(0,2):   
    n_q = exp[ii]
    
    axes[ii].plot(tlist, n_q, label=labels[ii])
    
    axes[ii].set_ylim([-0.1,1.1])
    axes[ii].legend(loc=0)
    axes[ii].set_xlabel('Time')
    axes[ii].set_ylabel('P')
