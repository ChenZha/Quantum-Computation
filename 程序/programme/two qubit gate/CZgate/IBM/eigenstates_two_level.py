#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Nov 26 11:09:35 2017

@author: chen
"""

from qutip import *

g = 0.0038 * 2 * np.pi
wq= np.array([5.114 , 4.9914 ]) * 2 * np.pi
eta_q=  np.array([-0.330 , -0.330]) * 2 * np.pi
omega = 0.060 * 2 * np.pi
                
sm0=tensor(destroy(2),qeye(2))
sm1=tensor(qeye(2),destroy(2))
E_uc0 = tensor(basis(3,2)*basis(3,2).dag() , qeye(3)) 
E_uc1 = tensor(qeye(3) , basis(3,2)*basis(3,2).dag())

H = (wq[0]-wq[1])*sm0.dag()*sm0 + omega/2*(sm0+sm0.dag())+g*((sm0+sm0.dag())*(sm1+sm1.dag())-(1j*sm0.dag()-1j*sm0)*(1j*sm1.dag()-1j*sm1))

[E,S] = H.eigenstates()