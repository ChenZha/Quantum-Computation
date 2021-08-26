#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Nov 10 20:17:32 2017

@author: chen
"""

import matplotlib.pyplot as plt
import numpy as np
from pylab import *
from qutip import *

def Xdetuning(detuning):
    
    wq = 5 * 2 * np.pi
    eta = -0.25 *2 * np.pi
    
    a = destroy(2)
    
    H0 = -wq/2*sigmaz()
    w = '(0.03332*2*np.pi*(np.exp(-(t-20)**2/2.0/6**2)*np.cos(t*f)))*(0<=t<=40)'
    args = {'f':wq+detuning}
    H1 = [a+a.dag(),w]
    H = [H0,H1]
    
    psi = basis(2,0)
    tlist = np.linspace(0,40,121)
    
    result = mesolve(H,psi,tlist,[],[],args = args)
    
    U = np.exp(-1j*(wq)*tlist[-1]/2)*basis(2,0)*basis(2,0).dag()+np.exp(1j*(wq)*tlist[-1]/2)*basis(2,1)*basis(2,1).dag()
    target = basis(2,1)
    fid = fidelity(U*target,result.states[-1])
    print(fid)
    
#    n_x0 = [] ; n_y0 = [] ; n_z0 = [];
#    
#    for t in range(0,len(tlist)):
#        U = np.exp(-1j*(wq)*tlist[t]/2)*basis(2,0)*basis(2,0).dag()+np.exp(1j*(wq)*tlist[t]/2)*basis(2,1)*basis(2,1).dag()
#        
#    #        U = (1j*H0*tlist[t]).expm()
#        
#        opx0 = U.dag()*(sigmax())*U
#        opy0 = U.dag()*(sigmay())*U
#        opz0 = sigmaz()
#        
#        n_x0.append(expect(opx0,result.states[t]))
#        n_y0.append(expect(opy0,result.states[t]))
#        n_z0.append(expect(opz0,result.states[t]))
#        
#    
#       
#    fig ,axes = plt.subplots(3,1)
#    axes[0].plot(tlist,n_x0);axes[0].set_xlabel('t');axes[0].set_ylabel('X0')
#    axes[1].plot(tlist,n_y0);axes[1].set_xlabel('t');axes[1].set_ylabel('Y0')
#    axes[2].plot(tlist,n_z0);axes[2].set_xlabel('t');axes[2].set_ylabel('Z0')
#    sphere = Bloch()
#    sphere.add_points([n_x0 , n_y0 , n_z0])
#    sphere.add_vectors([n_x0[-1],n_y0[-1],n_z0[-1]])
#    sphere.make_sphere() 
#    plt.show()
    
    return(fid)
if __name__ == '__main__':
    fid = []
    detuning = np.linspace(-0.004,0.004,161)*2*np.pi
    for i in detuning:
        fid.append(Xdetuning(i))
        
    figure();plot(detuning/2/np.pi,fid);xlabel('detuning');ylabel('fidelity')
    
#    fid = Xdetuning(0.002*2*np.pi)
        
    
