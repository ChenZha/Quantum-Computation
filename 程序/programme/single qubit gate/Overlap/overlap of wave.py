#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Jul 18 12:05:24 2017

@author: chen
"""

"""
X波形叠加对保真度影响，两个波形无联系，相位无关联，是独立的两个波
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
    Omega=0.03332*2*np.pi/2
    
    delta = 12
#    if t>=0 and t<=tp:
        
    D = (Omega*(np.exp(-(t-20)**2/2.0/6**2)*np.cos(t*w_q)+(t-20)/2/6**2/eta_q*np.exp(-(t-20)**2/2.0/6**2)*np.cos(t*w_q-np.pi/2)))
#    D = D+(Omega*(np.exp(-(t-20-delta)**2/2.0/6**2)*np.cos((t)*w_q)+(t-20-delta)/2/6**2/eta_q*np.exp(-(t-20-delta)**2/2.0/6**2)*np.cos((t)*w_q-np.pi/2)))
    D = D+(Omega*(np.exp(-(t-20-delta)**2/2.0/6**2)*np.cos(t*w_q-np.pi/2)+(t-20-delta)/2/6**2/eta_q*np.exp(-(t-20-delta)**2/2.0/6**2)*np.cos(t*w_q)))
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
    tp = 110
    tlist = np.linspace(0,tp,2*tp+1)
    
    psi0=basis(3,1)
    target = (basis(3,0)).unit()
#    psi0 = target
    
    D = X(tlist,args);figure();plot(tlist,D)

    
    result = mesolve(H,psi0,tlist,[],[],args)
    
    
    n_x0 = [] ; n_y0 = [] ; n_z0 = [];
    for t in range(0,len(tlist)):
        U = basis(3,0)*basis(3,0).dag()+np.exp(1j*(w_q)*tlist[t])*basis(3,1)*basis(3,1).dag()
    #    U = (1j*H0*tlist[t]).expm()
        opx0 = U.dag()*sx*U
        opy0 = U.dag()*sy*U
        opz0 = sz
        
        n_x0.append(expect(opx0,result.states[t]))
        n_y0.append(expect(opy0,result.states[t]))
        n_z0.append(expect(opz0,result.states[t]))
        
        
        
    sphere = Bloch()
    sphere.add_points([n_x0 , n_y0 , n_z0])
    sphere.add_vectors([n_x0[-1],n_y0[-1],n_z0[-1]])
    sphere.make_sphere() 
    
    
    fid = fidelity(U*result.states[-1]*result.states[-1].dag()*U.dag(), target)
    print(fid)
    
    
    
    
    
    
    
    
    
    
    
    finishtime=time.time()
    print( 'Time used: ', (finishtime-starttime), 's')