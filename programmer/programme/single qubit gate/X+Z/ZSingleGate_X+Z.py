from Qubits import Qubits
from qutip import *
import numpy as np
import matplotlib.pyplot as plt
from functools import partial
import random
from multiprocessing import Pool
from scipy.optimize import *

def Zgate_X_drive(t,args):
    tp = args['T_P']
    delta = args['delta']
    t_rise = args['t_rise']
    ratio = args['ratio']
    if t<=0 :
        w = 0
    elif t>0 and t<=t_rise:
        w = ratio*delta*(t/t_rise)
    elif t>t_rise and t<=tp-t_rise:
        w = ratio*delta
    elif t>tp-t_rise and t<=tp:
        w = ratio*delta/(t_rise)*(tp-t)
    elif t>tp:
        w = 0
    else:
        print('Time Error')
    return(float(w))

def Zgate_Z_drive(t,args):
    tp = args['T_P']
    delta = args['delta']
    t_rise = args['t_rise']
    
    if t<=0 :
        w = 0
    elif t>0 and t<=t_rise:
        w = delta*(t/t_rise)
    elif t>t_rise and t<=tp-t_rise:
        w = delta
    elif t>tp-t_rise and t<=tp:
        w = delta/(t_rise)*(tp-t)
    elif t>tp:
        w = 0
    else:
        print('Time Error')
    return(float(w))

def getfid_Zgate(P , ratio , QB):
    '''
    在对比特进行Z偏置时,对比特的XY施加一个形式相同,幅度不同的偏置
    '''
    delta = P[0]
    ratio = ratio
    args = {'T_P':40,'T_copies':101 , 't_rise':2.5,'delta':delta , 'ratio':ratio}
    Hdrive = [[QB.sm[0] + QB.sm[0].dag() , Zgate_X_drive],[QB.sm[0].dag()*QB.sm[0],Zgate_Z_drive]]
    final = QB.process(drive = Hdrive,process_plot = False,parallel = False , argument = args)
    target = np.array([[1,0],[0,-1]])

    # QB.evolution(drive = Hdrive , psi = (basis(3,0)+1j*basis(3,1)).unit() , collapse = [], track_plot = True , RWF = 'CpRWF',argument = args )

    Ufidelity = np.abs(np.trace(np.dot(np.conjugate(np.transpose(target)),final)))/(2**QB.num_qubits)
    print(delta,Ufidelity)
    return(1-Ufidelity)
    
def opt_Zgate(ratio,QB):
    P = 0.013330077962892*2*np.pi
    func = partial(getfid_Zgate , ratio = ratio , QB=QB )
    result = minimize(func, P, method="Nelder-Mead",options={'disp': False})

    return([result.x,1-result.fun])

    
if  __name__ == '__main__':
    frequency = np.array([5.5])* 2*np.pi
    coupling = np.array([])*2*np.pi
    eta_q=  np.array([-0.250 ]) * 2 * np.pi
    N_level= 3
    parameter = [frequency,coupling,eta_q,N_level]
    QBC = Qubits(qubits_parameter = parameter)

    P = [0.03*2*np.pi,QBC.frequency[0],-0.5]
    func = partial(opt_Zgate , ratio = 0,QB=QBC )

    # NM算法  [  0.23724056,  34.55760448,  -0.43552389]
    # result = minimize(func, P, method="Nelder-Mead",options={'disp': True})
    # print(result.x)
    # print(1-result.fun)
    # func(20)
    # ratio_list = np.linspace(-1,50,1020)
    # fid_list = np.zeros_like(ratio_list)
    # for ii in range(len(ratio_list)):
    #     fid_list[ii] = func(ratio_list[ii]) 

    # plt.figure()
    # plt.plot(ratio_list,fid_list)
    # plt.title('Frequency Oscilation in X gate')
    # plt.xlabel('ratio_list');plt.ylabel('fidelity')
    # plt.savefig('./Frequency Oscilation in X gate')

    # savefilename = './Frequency Oscilation in X gate'
    # np.savez(savefilename,ratio_list = ratio_list,fid_list=fid_list)
    # plt.show()


    ratio_list = np.linspace(-1,1000,1001)
    p = Pool()
    result = []
    for ii in range(len(ratio_list)):
        result.append(p.apply_async(opt_Zgate,(ratio_list[ii], QBC)))
    resultdata = np.array([result[i].get() for i in range(len(result))])
    p.close()
    p.join()
    Zgate_para = [resultdata[i][0] for i in range(len(resultdata))]
    fid_list = [resultdata[i][1] for i in range(len(resultdata))]

    plt.figure()
    plt.plot(ratio_list,fid_list)
    plt.title('Frequency Oscilation in Z gate long sacle')
    plt.xlabel('ratio_list');plt.ylabel('fidelity')
    plt.savefig('./Frequency Oscilation in Z gate long sacle')

    savefilename = './Frequency Oscilation in Z gate long sacle'
    np.savez(savefilename,ratio_list = ratio_list,fid_list=fid_list,Zgate_para = Zgate_para)
    plt.show()
    