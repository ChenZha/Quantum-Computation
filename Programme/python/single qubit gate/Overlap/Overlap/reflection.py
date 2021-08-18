#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Aug  9 15:42:29 2017

@author: chen
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


def X1(t,arg):
    Omega = arg['omega']
    tp = arg['tp']
#    Omega=0.03332*2*np.pi/2
    
    if t>=0 and t<=tp:
        
        D = (Omega*(np.exp(-(t-20)**2/2.0/6**2)*np.cos(t*w_q)+(t-20)/2/6**2/eta_q*np.exp(-(t-20)**2/2.0/6**2)*np.cos(t*w_q-np.pi/2)))
    else:
        D = 0
    return(D)


def X2(t,arg):
    
    Omega = arg['omega']
    
    delta = arg['delta']
    tp = arg['tp']
    height = arg['height']
    
    if t>=0 and t<=tp:
        
        D = (Omega*(np.exp(-(t-20)**2/2.0/6**2)*np.cos(t*w_q)+(t-20)/2/6**2/eta_q*np.exp(-(t-20)**2/2.0/6**2)*np.cos(t*w_q-np.pi/2)))
        D = D+(height*Omega*(np.exp(-(t-20-delta)**2/2.0/6**2)*np.cos((t-delta)*w_q)+(t-20-delta)/2/6**2/eta_q*np.exp(-(t-20-delta)**2/2.0/6**2)*np.cos((t-delta)*w_q-np.pi/2)))
#    D = D+(Omega*(np.exp(-(t-20-delta)**2/2.0/6**2)*np.cos(t*w_q-np.pi/2)+(t-20-delta)/2/6**2/eta_q*np.exp(-(t-20-delta)**2/2.0/6**2)*np.cos(t*w_q)))
    else:
        D = 0
    return(D)


def getfid1(X):
    H_eta = eta_q * E_uc
    Hq = w_q*sn
    H0 = Hq + H_eta 
    
    Hd = [sx,X1]
    H = [H0,Hd]
    
    args = {}
    tp = 60
    tlist = np.linspace(0,tp,2*tp+1)

    args['omega'] = X*2*np.pi
    args['delta'] = 10
    args['tp'] = tp
       
    
    
    psi0=basis(3,1)
    target = basis(3,0)
    
    result = mesolve(H,psi0,tlist,[],[],args)
    
    U = basis(3,0)*basis(3,0).dag()+np.exp(1j*(w_q)*tlist[-1])*basis(3,1)*basis(3,1).dag()
    
    fid = fidelity(U*result.states[-1]*result.states[-1].dag()*U.dag(), target)
#    print(fid)
    return(1-fid)
def getfid2(X):
    H_eta = eta_q * E_uc
    Hq = w_q*sn
    H0 = Hq + H_eta 
    
    Hd = [sx,X2]
    H = [H0,Hd]
    
    args = {}
    tp = 60
    tlist = np.linspace(0,tp,2*tp+1)
    
    args['omega'] = X[0]*2*np.pi
    args['delta'] = X[1]
    args['tp'] = tp
    args['height'] = 0.08
       
    
    
    psi0=basis(3,1)
    target = basis(3,0)
    
    result = mesolve(H,psi0,tlist,[],[],args)
    
    U = basis(3,0)*basis(3,0).dag()+np.exp(1j*(w_q)*tlist[-1])*basis(3,1)*basis(3,1).dag()
    
    fid = fidelity(U*result.states[-1]*result.states[-1].dag()*U.dag(), target)
#    print(fid)
    return(1-fid)

def opt2(height):
    fun = lambda x:getfid2([x,height])
    xopt2=fminbound(fun,0.033301-0.015,0.033301+0.015, xtol=1e-07,disp=0,full_output=True)
    return([xopt2[0],1-xopt2[1]])
    
    
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
    



    xopt1=fminbound(getfid1,0.02,0.04, xtol=1e-07,disp=3,full_output=True)

    h = np.linspace(0,10,11)
#    for height in h:
#        fun = lambda x:getfid2([x,height])
#        xopt2=fminbound(fun,0.033301-0.015,0.033301+0.015, xtol=1e-07,disp=0,full_output=True)
#        val.append(xopt2[1])
#        opt.append(xopt2[0])
    

    p = Pool(16)
    A = p.map(opt2,h)
    p.close()
    p.join()

    opt =  np.array([x[0] for x in A])
    val = np.array([x[1] for x in A])
        
    figure();plot(h,val);ylabel('Fidelity')
    figure();plot(h,opt);ylabel('Opt')
#    print(xopt1[0],xopt2[0]) 
#    x0 = [0.03332]
#    result1 = minimize(getfid1, x0, method="Nelder-Mead",options={'disp': True})
#    
#    x0 = [0.03332]
#    result2 = minimize(getfid2, x0, method="Nelder-Mead",options={'disp': True})
#    
#    print(result1.x,result2.x) 
    

    
    
#    H_eta = eta_q * E_uc
#    Hq = w_q*sn
#    H0 = Hq + H_eta 
#    
#    Hd = [sx,X2]
#    H = [H0,Hd]
#    
#    args = {}
#    tp = 40
#    tlist = np.linspace(0,tp,2*tp+1)
#    
#    args['omega'] = 0.03332*2*np.pi
#    args['delta'] = 5
#    args['tp'] = tp
#       
#    
#    
#    psi0=basis(3,1)
#    target = basis(3,0)
##    psi0 = target
#    
#
#    D = []
#    for t in tlist:
#        D.append(X2(t,args))
#    figure();plot(tlist,D)
#    
#    result = mesolve(H,psi0,tlist,[],[],args)
#    
#    
#    n_x0 = [] ; n_y0 = [] ; n_z0 = [];
#    for t in range(0,len(tlist)):
#        U = basis(3,0)*basis(3,0).dag()+np.exp(1j*(w_q)*tlist[t])*basis(3,1)*basis(3,1).dag()
#    #    U = (1j*H0*tlist[t]).expm()
#        opx0 = U.dag()*sx*U
#        opy0 = U.dag()*sy*U
#        opz0 = sz
#        
#        n_x0.append(expect(opx0,result.states[t]))
#        n_y0.append(expect(opy0,result.states[t]))
#        n_z0.append(expect(opz0,result.states[t]))
#        
#        
#        
#    sphere = Bloch()
#    sphere.add_points([n_x0 , n_y0 , n_z0])
#    sphere.add_vectors([n_x0[-1],n_y0[-1],n_z0[-1]])
#    sphere.make_sphere() 
#    
#    
#    fid = fidelity(U*result.states[-1]*result.states[-1].dag()*U.dag(), target)
#    print(fid)
    
    
    
    
    
    
    
    
    
    
    
    
    finishtime=time.time()
    print( 'Time used: ', (finishtime-starttime), 's')