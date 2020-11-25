#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Jul 16 20:44:08 2017

@author: chen
"""
''' 
寻找CZ波形参数，两个qubit的能级都要调，然后进行相位补偿，参数: (tp),delta0,delta1,xita0,xita1 
'''

import scipy 
import numpy as np
from functools import partial
from Qubits import Qubits
import copy
from qutip import *




def CZ(t,args):
    tp = args['T_P']
    amp = args['amp']
    if t>0 and t<= tp :
        w = amp*np.sin(np.pi*t/tp)
    else:
        w = 0
    return(w) 




if __name__=='__main__':
    
    Num_qubits = 3
    frequency = np.array([5.27 , 6.74 , 4.62 ])*2*np.pi
    coupling = np.array([0.122,0.105])*2*np.pi
    eta_q=  np.array([-0.210 , -0.37, -0.24]) * 2 * np.pi
    N_level= 3
    parameter = [frequency,coupling,eta_q,N_level]
    QBE = Qubits(qubits_parameter = parameter)
    couple_qq = 0.012*2*np.pi
    QBE.H0 = QBE.H0 + couple_qq*(QBE.sm[0].dag()+QBE.sm[0])*(QBE.sm[2].dag()+QBE.sm[2])
    
    
    
    Hd0 = [QBE.sm[1].dag()*QBE.sm[1],CZ]
    Hdrive = [Hd0]

    amp = -1.5*2*np.pi
    psi = tensor((basis(3,1)).unit(),(basis(3,0)).unit(),(basis(3,0)+basis(3,1)).unit())
    args = {'T_P':30,'T_copies':101 , 'amp':amp}

    final = QBE.evolution(drive = Hdrive , psi = psi ,  RWF = 'CpRWF' , RWA_freq = 0,track_plot = True ,argument = args)
