import numpy as np
from Qubits import Qubits
from qutip import *
import matplotlib.pyplot as plt

import threading
def runnow(func):
    out = threading.Thread(target=func)
    out.start()
    return lambda:out

import time
timezero=time.time()
import sys  



def InitialState(Num_qubits,state_qubits):
    '''
    generate initial state
    '1','0'
    '+','-'
    '+i','-i'
    '''
    assert len(state_qubits) == Num_qubits 

    state = []
    for ii in range(Num_qubits):
        if state_qubits[ii] == '1':
            state.append(basis(3,1))
        elif state_qubits[ii] == '0':
            state.append(basis(3,0))
        elif state_qubits[ii] == '+':
            state.append((basis(3,0)+basis(3,1)).unit())
        elif state_qubits[ii] == '-':
            state.append((basis(3,0)-basis(3,1)).unit())
        elif state_qubits[ii] == '+i':
            state.append((basis(3,0)+1j*basis(3,1)).unit())
        elif state_qubits[ii] == '-i':
            state.append((basis(3,0)-1j*basis(3,1)).unit())
        else:
            print('there is no such an error')
    inistate = tensor(*state)
    return(inistate)


def StateEvolution(qubit_chain,inistate,t_total):
    '''
    the evolution of state
    '''
    args = {'T_P':t_total,'T_copies':6*t_total+1 }
    psi = inistate
    QB = qubit_chain

    fianlstate = QB.evolution(drive = None , psi = psi , track_plot = False , RWF = 'UnCpRWF',argument = args )

    return(QB)
def dmToentropy(dm,alpha):
    '''
    calculate Renyi Entropy through density matrix
    '''
    alpha = int(alpha)
    temp = dm**alpha
    dmdata = temp.data.toarray()
    SA = np.log2(np.trace(dmdata))/(1-alpha)
    return(SA)

def EntropyEvolution(QBC , subsystem = [0] , traceplot = False):
    QB = QBC
    tlist = QB.tlist
    subsystem = np.array(subsystem)
    entropylist = np.zeros([QB.num_qubits,len(tlist)])
    for ii in range(QB.num_qubits):
        for jj in range(len(tlist)):
            entropylist[ii,jj] = dmToentropy(ptrace(QB.result.states[jj],ii),2)
    
    whole_entropy = np.sum(entropylist,0)/(QB.num_qubits)
    
    if traceplot:

        fig,axes = plt.subplots(QB.num_qubits+1,1)
        for ii in range(QB.num_qubits):
            axes[ii].plot(tlist,entropylist[ii])
            axes[ii].set_xlabel('t(ns)');axes[ii].set_ylabel('entropy of Q'+str(ii))
        axes[QB.num_qubits].plot(tlist,whole_entropy)
        axes[QB.num_qubits].set_xlabel('t(ns)');axes[QB.num_qubits].set_ylabel('entropy of system')
        plt.show()
            

    return([entropylist,whole_entropy])


if __name__ == '__main__':

    Num_qubits = 6
    frequency = np.ones(Num_qubits) * 5.0 * 2*np.pi
    coupling = np.ones(Num_qubits-1) * 0.012 * 2*np.pi
    eta_q=  np.ones(Num_qubits) * (-0.250) * 2*np.pi
    N_level= 3
    parameter = [frequency,coupling,eta_q,N_level]
    QBC = Qubits(qubits_parameter = parameter)

    inistate = InitialState(Num_qubits,['1','0','+','-','+i','-i'])
    t_total = 200

    QBC = StateEvolution(QBC , inistate , t_total)
  
    entropy,sumentropy = EntropyEvolution(QBC,traceplot=True)
    print(sumentropy)

