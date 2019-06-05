import numpy as np
from Qubits import Qubits
from qutip import *
import matplotlib.pyplot as plt
from multiprocessing import Pool
import os
import matlab.engine
import math

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
            state.append(basis(N_level[ii],1))
        elif state_qubits[ii] == '0':
            state.append(basis(N_level[ii],0))
        elif state_qubits[ii] == '+':
            state.append((basis(N_level[ii],0)+basis(N_level[ii],1)).unit())
        elif state_qubits[ii] == '-':
            state.append((basis(N_level[ii],0)-basis(N_level[ii],1)).unit())
        elif state_qubits[ii] == '+i':
            state.append((basis(N_level[ii],0)+1j*basis(N_level[ii],1)).unit())
        elif state_qubits[ii] == '-i':
            state.append((basis(N_level[ii],0)-1j*basis(N_level[ii],1)).unit())
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
    args = {'T_P':t_total,'T_copies':t_total+1 }
    psi = inistate
    QB = qubit_chain

    finalstate = QB.evolution(drive = None , psi = psi ,  track_plot = False , RWF = 'UnCpRWF',argument = args )

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
        ground_L.append(basis(3,0))
        excited_L.append(basis(3,1))
    ground_S = tensor(*ground_L)
    excited_S = tensor(*excited_L)
    GHZ_entrpy_state = (ground_S+excited_S).unit()
    return(GHZ_entrpy_state)
def get_GME(state):
    eng = matlab.engine.start_matlab()
    imput_state = matlab.double(ket2dm(state).data.toarray().tolist(),is_complex=True)
    GME_output = eng.fdecwit(imput_state)
    if math.isnan(GME_output):
        GME_output = 20
    return(GME_output)
def EntropyEvolution(QBC , inistate_label , t_total , subsystem = [0] , traceplot = False , GME = True):
    '''
    the evolution of global entropy
    '''
    QB = QBC
    inistate = InitialState(QB.num_qubits,inistate_label,QB.N_level)
    QB = StateEvolution(QB,inistate,t_total);#print("line %s time %s"%(sys._getframe().f_lineno,time.time()-time_now))

    ##
    tlist = QB.tlist
    entropylist = np.zeros([len(subsystem),len(tlist)],dtype = complex)
    if traceplot:
        GHZ_entrpy_state = get_GHZ_entrpy(QB.num_qubits)
        GHZ_entrpy_list = np.zeros(len(subsystem),dtype = complex)
        max_entrpy_list = np.zeros(len(subsystem),dtype = complex)
        
    if GME:
        GME_list = np.zeros(len(tlist))
        p = Pool()
        result = []
        for i in range(len(tlist)):
            result.append(p.apply_async(get_GME,(QBC.result.states[i],)))
        GME_list = np.array([result[i].get() for i in range(len(result))])
        p.close()
        p.join()    


    if type(subsystem)==np.ndarray:
        subsystem = subsystem.tolist()
    
    for ii,subsys in enumerate(subsystem):
        if traceplot:
            max_entrpy_list[ii] = len(subsys)
            GHZ_entrpy_list[ii] = np.abs(dmToentropy(ptrace(GHZ_entrpy_state,subsys),2))
        for jj in range(len(tlist)):
            sub_desitymatrix = ptrace(QB.result.states[jj],subsys)
            entropylist[ii,jj] = np.abs(dmToentropy(sub_desitymatrix,2))
        # print("line %s time %s"%(sys._getframe().f_lineno,time.time()-time_now))
    print("line %s time %s"%(sys._getframe().f_lineno,time.time()-time_now))
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
            if GME:
                below_threshold = GME_list<-1e-8
                plt.scatter(tlist[below_threshold], global_entropy[below_threshold], color='red') 
        
            maxloc = np.argmax(global_entropy)
            plt.title(str(inistate_label)+',entropy='+str(global_entropy[maxloc])[1:6]+',time='+str(QB.tlist[maxloc])[0:6])
            plt.savefig('./simulation_2level/'+str(inistate_label))
            plt.show()

    print(str(inistate_label)+'evolution end')
    return([global_entropy,tlist])
    # return(np.max(global_entropy))
    # return([entropylist,global_entropy])
def generate_all_state(Num_qubits):
    '''
    从0,1,+,-,+i,-i中选择,组成各种初始态,镜像的算一种态
    '''

    all_inistate = []
    Num_qubits = int(Num_qubits)
    number_basis= 6

    for ii in range(number_basis**Num_qubits):
        state_ii = []
        index = ii
        for jj in range(Num_qubits):
            codenum = np.int(np.mod(index,number_basis))
            if codenum == 0:
                state_ii.insert(0,'0')
            elif codenum == 1:
                state_ii.insert(0,'1')
            elif codenum == 2:
                state_ii.insert(0,'+')
            elif codenum == 3: 
                state_ii.insert(0,'-')
            elif codenum == 4: 
                state_ii.insert(0,'+i')
            elif codenum == 5: 
                state_ii.insert(0,'-i')
            else:   
                print('no such state')
            index = np.int(np.floor(index/number_basis))
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
    '''
    获得某个比特数目下的最大的renyi entropy及对应的态
    '''
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
    max_list = np.abs(np.array([result[i].get() for i in range(len(result))]))
    p.close()
    p.join()
    ##
    loc = np.argmax(max_list)

    return(all_ini_state[loc],max_list[loc])

def get_all_evolution(Num_qubits):
    '''
    获得某个比特数目下所有比特初态编码的演化
    '''
    frequency = np.ones(Num_qubits) * 5.0 * 2*np.pi
    coupling = np.ones(Num_qubits-1) * 0.0125 * 2*np.pi
    eta_q=  np.ones(Num_qubits) * (-0.250) * 2*np.pi
    N_level= 3
    parameter = [frequency,coupling,eta_q,N_level]
    QBC = Qubits(qubits_parameter = parameter)

    all_ini_state = generate_all_state(Num_qubits)
    t_total = 150
    plot_list = np.arange(0,t_total,10)#需要画出来的时间节点


    subsystem = generate_subsys(Num_qubits)

    ##
    p = Pool()
    result = []
    for i in range(len(all_ini_state)):
        result.append(p.apply_async(EntropyEvolution,(QBC , all_ini_state[i] , t_total , subsystem , False,)))
    evo_list = np.abs(np.array([result[i].get()[0] for i in range(len(result))]))
    tlist = result[0].get()[1]
    p.close()
    p.join()
    ##
    evo_list = evo_list.transpose()
    for T_node in plot_list:
        node_list = evo_list[np.where(np.abs(tlist-T_node)<=0.0001)][0]
        # plot and save
        fig,axes = plt.subplots(1,1)
        axes.plot(np.arange(len(all_ini_state)),node_list,label = 'entropy')
        axes.set_xlabel('code of state');axes.set_ylabel('entropy of system')
        handles, labels = plt.gca().get_legend_handles_labels()
        plt.legend(handles,labels)
        maxloc = np.argmax(node_list)
        plt.title(str(T_node)+',state='+str(all_ini_state[maxloc])+',max entropy='+str(node_list[maxloc])[0:6])
        if not os.path.exists('./one dimension_'+str(Num_qubits)):
            os.mkdir('./one dimension_'+str(Num_qubits))   
        plt.savefig('./one dimension_'+str(Num_qubits)+'/t='+str(T_node))

    

    # plt.figure()
    # # plt.pcolor(np.r_[np.arange(len(all_ini_state)),3], np.r_[tlist,3],evo_list)
    # plt.pcolor(np.r_[np.arange(len(all_ini_state)),len(all_ini_state)], tlist,evo_list)
    # plt.colorbar()
    # plt.show()
    return([evo_list,all_ini_state])
def dec2bin(number,digit):
    '''
    10进制转2进制(str)
    '''
    number = int(number)
    digit = int(digit)
    assert 2**digit>number
    bin_number = ''
    for ii in range(digit):
        remainder = np.int(np.mod(number,2))
        bin_number = str(remainder) + bin_number
        number = np.int(np.floor(number/2))
    return(bin_number)
def find_initial(QBC,level):
    '''
    找到QBC中某个能级对应0,1初态
    '''
    for ii in range(2**QBC.num_qubits):
        state = dec2bin(ii,QBC.num_qubits)
        location = QBC._findstate(state)
        if int(location)==level:
            return(state)
    print('No state')
    return(None)
def Z_pulse_generator(QBC,freq_target):
    freq = QBC.frequency
    mean_freq = np.mean(freq)
    Z_pulse = []
    for ii in range(QBC.num_qubits):
        delta = freq_target-freq[ii]
        Z_pulse.append(str(delta)+'/2*(1-np.cos(np.pi/t_rise*t))*(0<=t<=t_rise)+'+str(delta)+'*(t_rise<t<T_P-t_rise)+'+str(delta)+'/2*(1+np.cos(np.pi/t_rise*(t-T_P+t_rise)))*(T_P-t_rise<=t<=T_P)')
    
    return(Z_pulse)

def EigStateAdiabatic(level,t_rise,t_total,freq_target,traceplot = False):
    '''
    '''
    qubit_row=2;qubit_column=2
    frequency = np.array([5.28 , 5.43 , 5.11 , 5.26   ],
                        )* 2*np.pi
    coupling = np.ones(len(frequency)-1) * 0.0030 * 2*np.pi
    eta_q=  np.ones(len(frequency)) * (-0.250) * 2*np.pi
    N_level= 2
    parameter = [frequency,coupling,eta_q,N_level]
    QBC_2 = Qubits(qubits_parameter = parameter)
    state = find_initial(QBC_2,level)
    

    N_level= 3
    parameter = [frequency,coupling,eta_q,N_level]
    QBC_3 = Qubits(qubits_parameter = parameter)
    initial_state = InitialState(QBC_3.num_qubits,[i for i in state],QBC_3.N_level)
    state_loc = QBC_3._findstate(state)
    # initial_state = QBC_3.State_eig[level]

    print(state,fidelity(initial_state,QBC_3.State_eig[state_loc]))

    args = {'T_P':t_total,'T_copies':int(t_total/5)+1, 't_rise':t_rise}
    Z_pulse = Z_pulse_generator(QBC_3,freq_target)
    # print(Z_pulse[0][0])
    H1 = []
    for ii in range(QBC_3.num_qubits):
            H1.append([QBC_3.sm[ii].dag()*QBC_3.sm[ii],Z_pulse[ii]])

    finalstate = QBC_3.evolution(drive = H1 , psi = initial_state ,  track_plot = False , RWF = 'UnCpRWF',argument = args )


    tlist = QBC_3.tlist
    subsystem = generate_subsys(QBC_3.num_qubits)
    entropylist = np.zeros([len(subsystem),len(tlist)],dtype = complex)
    
    if traceplot:
        GHZ_entrpy_state = get_GHZ_entrpy(QBC_3.num_qubits)
        GHZ_entrpy_list = np.zeros(len(subsystem),dtype = complex)
        max_entrpy_list = np.zeros(len(subsystem),dtype = complex)

    if type(subsystem)==np.ndarray:
        subsystem = subsystem.tolist()
    for ii,subsys in enumerate(subsystem):
        if traceplot:
            max_entrpy_list[ii] = len(subsys)
            GHZ_entrpy_list[ii] = np.abs(dmToentropy(ptrace(GHZ_entrpy_state,subsys),2))
        for jj in range(len(tlist)):
            sub_desitymatrix = ptrace(QBC_3.result.states[jj],subsys)
            entropylist[ii,jj] = np.abs(dmToentropy(sub_desitymatrix,2))
    global_entropy = np.sum(entropylist,0)

    fid1 = fidelity(finalstate,QBC_3.State_eig[state_loc])
    fid2 = fidelity(finalstate,initial_state)

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

        


        plt.rcParams['figure.figsize'] = (6.0, 4.0) # 设置figure_size尺寸
        fig,axes = plt.subplots(1,1)
        axes.plot(tlist,global_entropy,label = 'entropy')
        axes.plot(tlist,max_entrpy,label = 'max entropy',linestyle = '--')
        axes.plot(tlist,GHZ_entrpy,label = 'GHZ entropy',linestyle = '--')
        axes.set_xlabel('t(ns)');axes.set_ylabel('entropy of system')
        handles, labels = plt.gca().get_legend_handles_labels()
        plt.legend(handles,labels)
        maxloc = np.argmax(global_entropy)
        plt.tight_layout()
        plt.title(str(N_level)+'level='+str(level)+',t_rise='+str(t_rise)+',t_total='+str(t_total)+',entropy='+str(global_entropy[maxloc])[1:6]+',time='+str(QBC_3.tlist[maxloc])[0:6])
        plt.savefig('./adiabatic/'+str(N_level)+'level_t_rise='+str(t_rise)+',t_total='+str(t_total)+',level='+str(level))


        plt.show()
    print('evolution end')
    print([fid1,fid2])
    # return([global_entropy,tlist,[fid1,fid2]])
    return(fid1)

if __name__ == '__main__':

    # t_total = np.linspace(5,1005,21)
    # fid_list = []
    # for t in t_total:
    #     finalstate = EigStateAdiabatic(7,t,6000,5.0*2*np.pi,traceplot=False)
    #     fid_list.append(finalstate)
    # plt.figure();plt.plot(t_total,fid_list)
    # plt.xlabel('time(ns)');plt.ylabel('fidelity')
    # plt.show()
    
    # np.savez("fid_trise",fid_list = fid_list , t_total = t_total)
    data = np.load('./adiabatic/fid_trise.npz')
    t_total = data['t_total'];fid_list = data['fid_list']
    plt.figure();plt.plot(t_total,fid_list)
    plt.xlabel('time(ns)');plt.ylabel('fidelity')
    plt.show()
    
    # evo_list,all_ini_state = get_all_evolution(2)
    # # print(evo_list)
    # Num_qubits = 5
    # frequency = np.ones(Num_qubits) * 5.0 * 2*np.pi
    # # frequency = np.array([1,1]) * 5.0 * 2*np.pi
    # coupling = np.ones(Num_qubits-1) * 0.0125 * 2*np.pi
    # eta_q=  np.ones(Num_qubits) * (-0.25) * 2*np.pi
    # N_level= 2
    # parameter = [frequency,coupling,eta_q,N_level]
    # QBC = Qubits(qubits_parameter = parameter)

    # args = {'T_P':100,'T_copies':2*100+1 }
    # psi = tensor((basis(N_level,1)+basis(N_level,0)).unit(),basis(N_level,1))
    

    # finalstate = QBC.evolution(drive = None , psi = psi ,  track_plot = True , RWF = 'UnCpRWF',argument = args )


    
    # inistate_label = ['+', '-', '-', '-', '+']
    # t_total = 300

    # subsystem = generate_subsys(Num_qubits)

    # inistate = InitialState(QBC.num_qubits,inistate_label,QBC.N_level)
    # QB = StateEvolution(QBC,inistate,t_total)
    # state = QB.result.states
    # GME = []
    # for ii in range(len(state)):
    #     time1 = time.time()
    #     imput_state = matlab.double(ket2dm(state[ii]).data.toarray().tolist(),is_complex=True)
    #     # imput_state = matlab.double(ket2dm(tensor(basis(2,0),basis(2,0))).data.toarray().tolist(),is_complex=True)
    #     GME_output = eng.fdecwit(imput_state)
    #     time2 = time.time()
    #     print(time2-time1)
    #     if math.isnan(GME_output):
    #         GME_output = 20
    #     GME.append(GME_output)
    #     print(GME_output)
    # fig,axes = plt.subplots(1,1)
    # axes.plot(GME)
    # plt.show()


    
    # global_entropy = EntropyEvolution(QBC,inistate_label,t_total,subsystem,traceplot=True,GME = True)
    # print(global_entropy)


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

