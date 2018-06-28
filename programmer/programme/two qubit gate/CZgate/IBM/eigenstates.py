#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Nov 26 00:48:59 2017

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

g = 0.004 * 2 * np.pi
wq= np.array([5.110 , 5.042  ]) * 2 * np.pi
eta_q=  np.array([-0.2907 , -0.2915]) * 2 * np.pi
#wq= np.array([5.114 , 4.914  ]) * 2 * np.pi
#eta_q=  np.array([-0.330 , -0.330]) * 2 * np.pi
omega = 0.060 * 2 * np.pi
                
sm0=tensor(destroy(3),qeye(3))
sm1=tensor(qeye(3),destroy(3))
E_uc0 = tensor(basis(3,2)*basis(3,2).dag() , qeye(3)) 
E_uc1 = tensor(qeye(3) , basis(3,2)*basis(3,2).dag())

H = (wq[0]-wq[1])*sm0.dag()*sm0+eta_q[0]*E_uc0 + eta_q[1]*E_uc1+omega/2*(sm0+sm0.dag())+g/2*((sm0+sm0.dag())*(sm1+sm1.dag())+(1j*sm0.dag()-1j*sm0)*(1j*sm1.dag()-1j*sm1))

[E,S] = H.eigenstates()
print((E[8]-E[7])/2/np.pi,(E[6]-E[5])/2/np.pi)
print(np.pi/2/(E[8]-E[7]+E[6]-E[5]))

#wq= np.array([4.914 , 5.114 ]) * 2 * np.pi
#eta_q=  np.array([-0.33 , -0.33]) * 2 * np.pi
#H = (wq[0]-wq[1])*sm0.dag()*sm0+eta_q[0]*E_uc0 + eta_q[1]*E_uc1+omega/2*(sm0+sm0.dag())+g/2*((sm0+sm0.dag())*(sm1+sm1.dag())+(1j*sm0.dag()-1j*sm0)*(1j*sm1.dag()-1j*sm1))
#[E,S] = H.eigenstates()
#print((E[8]-E[7])/2/np.pi,(E[6]-E[5])/2/np.pi)
#print(E[8]-E[7]+E[6]-E[5])

#g = 0.004 * 2 * np.pi
#A = 0.030*2*np.pi
#delta = 0.2*2*np.pi
#g1 = A*g/2*(1/(delta)+1/delta)
#g2 = 2*A*g/2*(1/(-delta-eta_q[0])+1/(-delta-eta_q[1]))
#print(2*g1/2/np.pi,2*g2/2/np.pi,2*(g1+g2)/2/np.pi)
#
#g = 0.004 * 2 * np.pi
#A = 0.030*2*np.pi
#delta = -0.2*2*np.pi
#g1 = A*g/2*(1/(delta)+1/delta)
#g2 = 2*A*g/2*(1/(-delta-eta_q[0])+1/(-delta-eta_q[1]))
#print(2*g1/2/np.pi,2*g2/2/np.pi,2*(g1+g2)/2/np.pi)
