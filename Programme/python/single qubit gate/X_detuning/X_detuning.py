# -*- coding: utf-8 -*-
"""
Created on Wed Sep 13 17:19:58 2017

@author: Chen
"""



"""
X微波频率detuning对fid影响
"""

import time 
import csv
import matplotlib.pyplot as plt
import numpy as np
from pylab import *
from qutip import *
from scipy.optimize import *
from scipy.integrate import *
from scipy import interpolate 
from mpl_toolkits.mplot3d import Axes3D
from scipy.special import *
from multiprocessing import Pool
from decimal import *
from math import *
import gc 
import sys


def X(t,arg):
    Omega=0.03332*2*np.pi
    
    w_f = arg['w_f']
#    if t>=0 and t<=tp:
        
    D = (Omega*(np.exp(-(t-20)**2/2.0/6**2)*np.cos(t*w_f)+(t-20)/2/6**2/eta_q*np.exp(-(t-20)**2/2.0/6**2)*np.cos(t*w_f-np.pi/2)))
#    D = D+(Omega*(np.exp(-(t-20-delta)**2/2.0/6**2)*np.cos((t)*w_q)+(t-20-delta)/2/6**2/eta_q*np.exp(-(t-20-delta)**2/2.0/6**2)*np.cos((t)*w_q-np.pi/2)))
#    D = D+(Omega*(np.exp(-(t-20-delta)**2/2.0/6**2)*np.cos(t*w_q-np.pi/2)+(t-20-delta)/2/6**2/eta_q*np.exp(-(t-20-delta)**2/2.0/6**2)*np.cos(t*w_q)))
#    else:
#        D = 0
    return(D)
if __name__ == '__main__':
    
    starttime=time.time()
    
    
    
    
    w_q = 5.22  * 2 * np.pi    
    eta_q = -0.25 * 2 * np.pi
    
    sm = destroy(3)
    
    E_uc = basis(3,2)*basis(3,2).dag()
    E_e = basis(3,1)*basis(3,1).dag()
    E_g = basis(3,0)*basis(3,0).dag()
    sn = sm.dag()*sm
    
    sx = sm.dag()+sm
    sxm = Qobj([[0,1,0],[1,0,0],[0,0,0]])
    
    
    sy = 1j*(sm.dag()-sm)
    sym = Qobj([[0,-1j,0],[1j,0,0],[0,0,0]])
    
    sz = E_g - E_e
    
    H_eta = eta_q * E_uc
    Hq = w_q*sn
    H0 = Hq + H_eta 
    
    Hd = [sx,X]
    H = [H0,Hd]
    
    args = {}
    tp = 60
    tlist = np.linspace(0,tp,2*tp+1)
    
    psi0=basis(3,1)
    target = (basis(3,0)).unit()
#    psi0 = target
    
#    D = X(tlist,args);figure();plot(tlist,D)
    res = []
    detuning = np.linspace(-0.0002,0.0002,3)*2*np.pi
    for d in detuning:
        
        w_f = w_q+d
        args = {'w_f':w_f}
        
        result = mesolve(H,psi0,tlist,[],[],args)
        
        
        U = basis(3,0)*basis(3,0).dag()+np.exp(1j*(w_q)*tlist[-1])*basis(3,1)*basis(3,1).dag()
        
        
        fid = fidelity(U*result.states[-1]*result.states[-1].dag()*U.dag(), target)
        res.append(fid)
    fig = plt.figure(1)
    ax = fig.add_subplot(1,1,1)
    ax.plot(detuning,res)
    ax.set_xlabel('detuning')
    ax.set_ylabel('fid')
    plt.show()
    
    
    
    
    
    
    
    
    
    
    
    finishtime=time.time()
    print( 'Time used: ', (finishtime-starttime), 's')