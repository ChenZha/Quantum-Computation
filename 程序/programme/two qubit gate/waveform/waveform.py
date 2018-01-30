#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Oct 27 22:43:22 2017

@author: chen
"""

import numpy as np
from scipy.optimize import *
from scipy.integrate import quad
from scipy import interpolate 
import matplotlib.pyplot as plt
from pylab import *



def CalPs(dthsh,ti,w):
    
    Int = np.sum(dthsh*np.exp(-1j*w*ti[0:-1])*ti[1]);
    P = (np.abs(Int))**2;
    return(P)

def SwI(lamda,thi,thf):
    resolution = 1024;
    k = np.zeros(3);
    k[0] = 1-lamda[1];k[1] = lamda[0];k[2] = lamda[1];
    ti=np.linspace(0,1,resolution);
    han2 = k[0]*(1-np.cos(2*np.pi*ti))+k[1]*(1-np.cos(4*np.pi*ti))+k[2]*(1-np.cos(6*np.pi*ti));
    thsl=thi+(thf-thi)*han2/np.max(han2);
    
    dthsh = np.diff(thsl)/np.diff(ti);
    CalP = lambda w: CalPs(dthsh,ti,w);
    
    wmin = 2.3*2*np.pi;wmax = np.inf;
    S = quad(CalP,wmin,wmax);#PSD积分
    print(lamda,S[0])
    return(S[0])





if __name__=='__main__':
    thi = 0.0;
    thf = 0.55*np.pi/2
    
    
    f = lambda lamda:SwI(lamda,thi,thf);
    x0 = [-0.19 , 0 ]
    result = minimize(f, x0, method="Nelder-Mead",options={'disp': True})
    
    
    lam2 = result.x[0];
    lam3 = result.x[1];
    resolution = 1024;
    
    ti=np.linspace(0,1,resolution)
    han2 = np.vectorize(lambda ti:(1-lam3)*(1-np.cos(2*np.pi*ti))+lam2*(1-np.cos(4*np.pi*ti))+lam3*(1-np.cos(6*np.pi*ti)))
    han2 = han2(ti)
    thsl=thi+(thf-thi)*han2/np.max(han2)   
    tlu = np.cumsum(np.cos(thsl))*ti[1]
    tlu=tlu-tlu[0]
    ti=np.linspace(0, tlu[-1], resolution)
    th=interpolate.interp1d(tlu,thsl,'slinear')
    th = th(ti)
    th=np.tan(th)
    th=th-th[0]
    th=th/np.max(th)
    figure();plot(ti,th)