#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Oct 30 13:18:50 2017

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

N = 3
    
    
wq= np.array([4.914 , 5.114 ]) * 2 * np.pi
eta_q=  np.array([-0.130 , -0.330]) * 2 * np.pi

omega = 0.1*2*np.pi
tp = 100

sm0=tensor(destroy(N),qeye(N))
sm1=tensor(qeye(N),destroy(N))
E_uc0 = tensor(basis(3,2)*basis(3,2).dag() , qeye(3)) 
E_uc1 = tensor(qeye(3) , basis(3,2)*basis(3,2).dag())


H0= (wq[0]) * sm0.dag()*sm0 + eta_q[0]*E_uc0 
#w = omega*np.exp((t-15)**2/2/)
#w = 'omega/2*(erf((t-8)/ramp)-erf((t-tp+8)/ramp))*(np.cos(f1*t))*((0)<t<=tp)'
w = 'omega/2*((erf((t-8)/ramp)-erf((t-tp+8)/ramp))*(np.cos(f1*t))-(2*np.exp(-(t-8)**2/(ramp)**2)/(ramp)/np.sqrt(pi)/('+str(eta_q[0])+')-2*np.exp(-(t-tp+8)**2/(ramp)**2)/(ramp)/np.sqrt(pi)/('+str(eta_q[0])+'))*np.cos(f1 * t-np.pi/2))*((0)<t<=tp)'
#w = 'omega*(np.cos(f1*t))*((0)<t<=tp)'
H1 = [sm0+sm0.dag(),w]
H = [H0,H1]
args = {'omega' : omega,'tp':tp , 'f1':wq[0],'ramp':5}

tlist = np.arange(0,tp,0.1)
psi0 = tensor(basis(3,1),basis(3,1))

result = mesolve(H,psi0,tlist,[],[sm0.dag()*sm0,E_uc0],args = args)
figure();plot(tlist,result.expect[0]);xlabel('t');ylabel('P1')
figure();plot(tlist,result.expect[1]);xlabel('t');ylabel('P2')