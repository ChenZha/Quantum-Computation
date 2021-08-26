#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Apr 18 22:45:33 2017

@author: chen
"""
from qutip import *
import numpy as np
import matplotlib.pyplot as plt 
from pylab import *
from gate import *
from initialsetting import *

def dissipation(setting = qusetting()):
    c_op_list = []
    ## Base Temperature(K)
    n_th=0.01
    ## 1/T_1
    gamma = np.array([1./10 , 1./10 , 1./10 , 1./10 , 1./10 , 1./10 , 1./10 , 1./10 , 1./10 , 1./10 ]) * 1e-3    
        
    ## 1/T_phi          
    gamma_phi = np.array([1./10 , 1./10 , 1./10 , 1./10 , 1./10 , 1./10 , 1./10 , 1./10 , 1./10 , 1./10 ]) * 1e-3  
                        
    if setting.Dis==True:
        sm,E_uc,E_e,E_g,sn,sx,sxm,sy,sym,sz,En = initial(setting)[-11:]
        for II in range(0,2):
            c_op_list.append(np.sqrt(gamma[II] * (1+n_th)) * sm[II])
            c_op_list.append(np.sqrt(gamma[II] * n_th) * sm[II].dag())
            c_op_list.append(np.sqrt(gamma_phi[II]) * sm[II].dag()*sm[II])
            
    return (c_op_list)