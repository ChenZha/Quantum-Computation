#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue May  2 17:10:06 2017

@author: chen
"""
import numpy as np
from scipy.optimize import *

def estimate(a):
    b = np.sqrt(1-a**2)
    matrix = np.array([[7.98234123e-01 +0.00000000e+00j,1.38519168e-01 -3.71963002e-01j],[1.38519168e-01 +3.71963002e-01j,1.97727992e-01 +0.00000000e+00j]])
    target = np.array([[a*np.conjugate(a),a*np.conjugate(b)],[b*np.conjugate(a),b*np.conjugate(b)]])
    dif = target-matrix
    model = 0
    for i in range(0,len(dif)):
        for j in range(0,len(dif[i])):
            model += (abs(dif[i][j]))**2
                     
    return (model)

if __name__ == '__main__':
    a = np.linspace(0,1,1000)
    est = np.frompyfunc(estimate,1,1)
    model = est(a).astype(np.float)
#    model = estimate(3.0/np.sqrt(10))
#    x = fmin(estimate,[3.0/np.sqrt(10),1.0/np.sqrt(10)],disp = True,xtol = 1e-07)
#    print(model)
    opt = a[np.where(model == min(model))]
    print(opt)
    
    