import numpy as np
from Qubits import Qubits
from qutip import *
import matplotlib.pyplot as plt
from multiprocessing import Pool
import os

import threading
def runnow(func):
    out = threading.Thread(target=func)
    out.start()
    return lambda:out

import time
time_now=time.time()
import sys  



def InitialState(Num_qubits,state_qubits,N_level):
    '''
    generate initial state
    '1','0'
    '+','-'
    '+i','-i'
    '''
    if len(state_qubits) != Num_qubits:
        print('number of qubits error')

    state = []
    for ii in range(Num_qubits):
        if state_qubits[ii] == '1':
            state.append(basis(N_level,1))
        elif state_qubits[ii] == '0':
            state.append(basis(N_level,0))
        elif state_qubits[ii] == '+':
            state.append((basis(N_level,0)+basis(N_level,1)).unit())
        elif state_qubits[ii] == '-':
            state.append((basis(N_level,0)-basis(N_level,1)).unit())
        elif state_qubits[ii] == '+i':
            state.append((basis(N_level,0)+1j*basis(N_level,1)).unit())
        elif state_qubits[ii] == '-i':
            state.append((basis(N_level,0)-1j*basis(N_level,1)).unit())
        else:
            print('there is no such an error')
    inistate = tensor(*state)
    return(inistate)
def generate_subsys(Num_qubits):
    '''
    generate subsystem 
    '''
    import itertools
    system = [i for i in range(Num_qubits)]
    subsys = []
    for jj in range(Num_qubits-1):
        subsys.extend(list(itertools.combinations(system,jj+1)))
    def funcfilter(x,xmap={}):
        subx = tuple([ii for ii in system if ii not in x])
        xstr = [str(x),str(subx)]
        boolin = xstr[0] in xmap or xstr[1] in xmap
        xmap[xstr[0]]=1
        xmap[xstr[1]]=1
        return (not boolin)
    subsys=list(filter(funcfilter,subsys))
    return(subsys)



def StateEvolution(qubit_chain,inistate,t_total):
    '''
    the evolution of state
    '''
    args = {'T_P':t_total,'T_copies':1.5*t_total+1 }
    psi = inistate
    QB = qubit_chain

    fianlstate = QB.evolution(drive = None , psi = psi ,  track_plot = False , RWF = 'UnCpRWF',argument = args )

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

def get_GHZ_entrpy(Num_qubits):
    '''
    generate GHZ state
    '''
    ground_L = []
    excited_L = []
    for ii in range(Num_qubits):
        ground_L.append(basis(2,0))
        excited_L.append(basis(2,1))
    ground_S = tensor(*ground_L)
    excited_S = tensor(*excited_L)
    GHZ_entrpy_state = (ground_S+excited_S).unit()
    return(GHZ_entrpy_state)

def EntropyEvolution(QBC , inistate_label , t_total , subsystem = [0] , traceplot = False):
    '''
    the evolution of global entropy
    '''
    QB = QBC
    inistate = InitialState(QB.num_qubits,inistate_label,QB.N_level)
    QB = StateEvolution(QB,inistate,t_total)
    tlist = QB.tlist
    entropylist = np.zeros([len(subsystem),len(tlist)])
    if traceplot:
        GHZ_entrpy_state = get_GHZ_entrpy(QB.num_qubits)
        GHZ_entrpy_list = np.zeros(len(subsystem))
        max_entrpy_list = np.zeros(len(subsystem))

    if type(subsystem)==np.ndarray:
        subsystem = subsystem.tolist()
    
    for ii,subsys in enumerate(subsystem):
        if traceplot:
            max_entrpy_list[ii] = len(subsys)
            GHZ_entrpy_list[ii] = dmToentropy(ptrace(GHZ_entrpy_state,subsys),2)
        for jj in range(len(tlist)):
            sub_desitymatrix = ptrace(QB.result.states[jj],subsys)
            entropylist[ii,jj] = dmToentropy(sub_desitymatrix,2)
        # print("line %s time %s"%(sys._getframe().f_lineno,time.time()-time_now))
    # print("line %s time %s"%(sys._getframe().f_lineno,time.time()-time_now))
    global_entropy = np.sum(entropylist,0)
    if traceplot:
        max_entrpy = np.ones_like(global_entropy)*np.sum(max_entrpy_list)
        GHZ_entrpy = np.ones_like(global_entropy)*np.sum(GHZ_entrpy_list)
        # fig,axes = plt.subplots(len(subsystem)+1,1)
        # for ii in range(len(subsystem)):
        #     axes[ii].plot(tlist,entropylist[ii])
        #     axes[ii].set_xlabel('t(ns)');axes[ii].set_ylabel('entropy of Q'+str(subsystem[ii]))
        # axes[len(subsystem)].plot(tlist,whole_entropy)
        # axes[len(subsystem)].set_xlabel('t(ns)');axes[len(subsystem)].set_ylabel('entropy of system')
        # plt.show()
        fig,axes = plt.subplots(1,1)
        axes.plot(tlist,global_entropy,label = 'entropy')
        axes.plot(tlist,max_entrpy,label = 'max entropy',linestyle = '--')
        axes.plot(tlist,GHZ_entrpy,label = 'GHZ entropy',linestyle = '--')
        axes.set_xlabel('t(ns)');axes.set_ylabel('entropy of system')
        handles, labels = plt.gca().get_legend_handles_labels()
        plt.legend(handles,labels)
        maxloc = np.argmax(global_entropy)
        plt.title(str(inistate_label)+',entropy='+str(global_entropy[maxloc])[0:6]+',time='+str(QB.tlist[maxloc])[0:6])
        # plt.savefig('./simulation_2/'+str(inistate_label))
        plt.show()
    print(str(inistate_label)+'evolution end')
    return(np.max(global_entropy))
    # return([entropylist,global_entropy])
def generate_all_state(Num_qubits):

    all_inistate = []
    Num_qubits = int(Num_qubits)
    num_inistate_start = 4**(Num_qubits-1)
    num_inistate_end = 4**Num_qubits

    for ii in range(num_inistate_start,num_inistate_end):
        state_ii = []
        index = ii
        while index != 0:
            codenum = np.int(np.mod(index,4))
            if codenum == 0:
                state_ii.insert(0,'0')
            elif codenum == 1:
                state_ii.insert(0,'1')
            elif codenum == 2:
                state_ii.insert(0,'+')
            elif codenum == 3: 
                state_ii.insert(0,'-')
            # elif codenum == 4: 
            #     state_ii.insert(0,'+i')
            # elif codenum == 5: 
            #     state_ii.insert(0,'-i')
            else:   
                print('no such state')
            index = np.int(np.floor(index/4))
        all_inistate.append(state_ii)

    def funcfilter(x,xmap={}):
        xstr = [''.join(x),''.join(x[::-1])]

        boolin = xstr[0] in xmap or xstr[1] in xmap
        xmap[xstr[0]]=1
        xmap[xstr[1]]=1
        return (not boolin)
    all_inistate=list(filter(funcfilter,all_inistate))
    return(all_inistate)



def get_max_entropy(Num_qubits):
    
    frequency = np.ones(Num_qubits) * 5.0 * 2*np.pi
    coupling = np.ones(Num_qubits-1) * 0.0125 * 2*np.pi
    eta_q=  np.ones(Num_qubits) * (-0.250) * 2*np.pi
    N_level= 3
    parameter = [frequency,coupling,eta_q,N_level]
    QBC = Qubits(qubits_parameter = parameter)

    all_ini_state = generate_all_state(Num_qubits)
    t_total = 150

    subsystem = generate_subsys(Num_qubits)

    ##
    p = Pool()
    result = []
    for i in range(len(all_ini_state)):
        result.append(p.apply_async(EntropyEvolution,(QBC , all_ini_state[i] , t_total , subsystem , False,)))
    max_list = np.array([result[i].get() for i in range(len(result))])
    p.close()
    p.join()
    ##
    loc = np.argmax(max_list)

    return(all_ini_state[loc],max_list[loc])


if __name__ == '__main__':
    

    Num_qubits = 3
    frequency = np.ones(Num_qubits) * 5.0 * 2*np.pi
    # frequency = np.array([1,1.25]) * 5.0 * 2*np.pi
    coupling = np.ones(Num_qubits-1) * 0.0125 * 2*np.pi
    eta_q=  np.ones(Num_qubits) * (-0.250) * 2*np.pi
    N_level= 3
    parameter = [frequency,coupling,eta_q,N_level]
    QBC = Qubits(qubits_parameter = parameter)

    inistate_label = ['+', '-', '+']
    t_total = 150

    subsystem = generate_subsys(Num_qubits)
    global_entropy = EntropyEvolution(QBC,inistate_label,t_total,subsystem,traceplot=True)
    print(global_entropy)


    # for root, dirs, files in os.walk('simulation'):
    #     for file in files:  
    #         inistate_label = eval(os.path.splitext(file)[0])
    #         Num_qubits = len(inistate_label)
        
    #         frequency = np.ones(Num_qubits) * 5.0 * 2*np.pi
    #         # frequency = np.array([1,1.25]) * 5.0 * 2*np.pi
    #         coupling = np.ones(Num_qubits-1) * 0.0125 * 2*np.pi
    #         eta_q=  np.ones(Num_qubits) * (-0.250) * 2*np.pi
    #         N_level= 2
    #         parameter = [frequency,coupling,eta_q,N_level]
    #         QBC = Qubits(qubits_parameter = parameter)

    #         t_total = 150

    #         subsystem = generate_subsys(Num_qubits)
    #         global_entropy = EntropyEvolution(QBC,inistate_label,t_total,subsystem,traceplot=True)
    #         print(global_entropy)

    
    # max_num = 6
    # max_state = []
    # max_entropy = []
    # for ii in range(2,max_num+1):
    #     state,entropy = get_max_entropy(ii)
    #     endtime = time.time()
    #     print('%d qubits,max entropy=%f,state=%s,time:%s'%(ii,entropy,str(state),endtime-time_now))

    #     file_handle = open('result.txt',mode = 'a+')
    #     file_handle.write('%d qubits,\t max entropy=%f,\t state=%s,\t time:%s \n'%(ii,entropy,str(state),endtime-time_now))
    #     file_handle.close()

    #     time_now = endtime

    #     max_state.append(state)
    #     max_entropy.append(entropy)
    
    # print(max_state)   
    # print(max_entropy) 

