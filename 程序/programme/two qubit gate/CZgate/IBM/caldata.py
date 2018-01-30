#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Dec  4 16:30:23 2017

@author: chen
"""

import matplotlib.pyplot as plt
import numpy as np
from pylab import *
from qutip import *
def sysceho(*a,**k):
    # print(*a,**k)
    # return()
    def fprint(a = a,k = k):
        
        with open('print.out','a') as fid:
            k['file'] = fid
            print(*a,**k)
    fprint(a,k)
process = np.load('process_0.npy')
targetprocess = 1/np.sqrt(2)*np.array([[1,1j,0,0],[1j,1,0,0],[0,0,1,-1j],[0,0,-1j,1]])
targetprocess = tensor(qeye(2),Qobj(targetprocess),qeye(2))
targetprocess = targetprocess.data.toarray()

p = np.dot(np.conjugate(np.transpose(targetprocess)),process)

angle = []
fid = []
for i in range(len(p)):
    angle.append(np.angle(p[i][i]))
    fid.append(np.abs(p[i][i]))

angle = np.array(angle)
fid = np.array(fid)
figure();plot(angle/np.pi*180);xlabel('state');ylabel('angle(degree)');title('RF_0')
figure();plot(fid);xlabel('state');ylabel('fid');title('RF_0')