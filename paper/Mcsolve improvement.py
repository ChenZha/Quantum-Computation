# -*- coding: utf-8 -*-
"""
Created on Wed Feb 15 19:19:33 2017

@author: Chen
"""
from qutip import *
import numpy as np
import matplotlib.pyplot as plt 
from qutip import gates



#==============================================================================
#def copy(states):
#    '''
#    dims如何复制
#    '''
#    lenc = len(states)
#    lenr = len(states[0])
#    outputstates = [[Qobj(zeros(states[i][j].shape).tolist) for i in range(0,lenc)] for j in range(0,lenr)]
    
def MCkettodm(states):
    '''
    from ket to density matrix for Mcsolve
    '''
    outputstate = states-states
    lenc = len(states)
    lenr = len(states[0])
    for i in range(0,lenc):
        for j in range(0,lenr):
            outputstate[i][j] = ket2dm(states[i][j])
            
    return outputstate
    
   
def MCaverage(inputstates):   
    '''
    输入为Mcsolve计算结果的state output.states
    输出为单一路径不同时间的density matrix
    ''' 
    states = MCkettodm(inputstates)
    outputstate = states[0]-states[0]
    lenc = len(states)
    lenr = len(states[0])
    for j in range(0,lenr):
        for i in range(0,lenc):
            outputstate[j] += states[i][j]
        outputstate[j] = outputstate[j]/lenc
    
    return outputstate
        
#==============================================================================
#==============================================================================
#def MEkettodm(states):
#    outputstate = states
#    lenr = len(states)
#    for i in range(0,lenr):
#        outputstate[i] = ket2dm(states[i])
#            
#    return outputstate
#==============================================================================

if __name__ == '__main__':
    wc = 1.0  * 2 * pi  # cavity frequency
    wa = 2.0  * 2 * pi  # atom frequency
    g  = 0.05 * 2 * pi  # coupling strength
    kappa = 0.005       # cavity dissipation rate
    gamma = 0.05        # atom dissipation rate
    N = 2              # number of cavity fock states
    n_th_a = 0.0        # avg number of thermal bath excitation
    use_rwa = False
    
    tlist = np.linspace(0,25,20)
    
    psi0 = tensor(basis(N,0), basis(2,1))    # start with an excited atom
    a  = tensor(destroy(N), qeye(2))
    sm = tensor(qeye(N), destroy(2))
    
    H = wc * a.dag() * a + wa * sm.dag() * sm + g * (a.dag() * sm + a * sm.dag())
    
#==============================================================================
    c_ops = []
     # cavity relaxation
    rate = kappa * (1 + n_th_a)
    if rate > 0.0:
        c_ops.append(sqrt(rate) * a)
     
     # cavity excitation, if temperature > 0
    rate = kappa * n_th_a
    if rate > 0.0:
        c_ops.append(sqrt(rate) * a.dag())
     
     # qubit relaxation
    rate = gamma
    if rate > 0.0:
        c_ops.append(sqrt(rate) * sm)
#==============================================================================
    
    
#==============================================================================
    ntraj = 100
    output = mcsolve(H, psi0, tlist, c_ops, [],ntraj = ntraj)
    averagedm = MCaverage(output.states)
#==============================================================================
    
    
    
    
#==============================================================================
    result = mesolve(H, psi0, tlist, c_ops, [])
#    resultdm = MEkettodm(result.states)
#==============================================================================
#    for i in range(0,len(averagedm)):
#        F = fidelity(averagedm[i],result.states[i])
#        print('fidelity=',F)
