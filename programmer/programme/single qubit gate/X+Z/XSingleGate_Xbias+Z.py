from Qubits import Qubits
from qutip import *
import numpy as np
import matplotlib.pyplot as plt
from functools import partial
import random
from multiprocessing import Pool
from scipy.optimize import *
def Xgate_X_drive(t,args):
    tp = args['T_P']
    omega = args['omega']
    D = args['D']
    wf = args['wf']
    eta_q = args['eta_q']
    if t<0 or t>tp:
        w = 0
    else:
        w = 0+omega*((1-np.cos(2*np.pi/tp*t))*np.cos(wf*t)+D*(2*np.pi/tp)*np.sin(2*np.pi/tp*t)/(eta_q[0])*np.cos(t*wf-np.pi/2))
    return(w)

def Xgate_Z_drive(t,args):
    tp = args['T_P']
    omega = args['omega']
    D = args['D']
    wf = args['wf']
    eta_q = args['eta_q']
    ratio = args['ratio']
    w_q = args['w_q']
    if t<0 or t>tp:
        w = 0
    else:
        # w = ratio*omega*((1-np.cos(2*np.pi/tp*t))*np.cos(wf*t)+D*(2*np.pi/tp)*np.sin(2*np.pi/tp*t)/(eta_q[0])*np.cos(t*wf-np.pi/2))
        # w = w_q*np.cos(np.pi*ratio*0.005*((1-np.cos(2*np.pi/tp*t))*np.cos(wf*t)+D*(2*np.pi/tp)*np.sin(2*np.pi/tp*t)/(eta_q[0])*np.cos(t*wf-np.pi/2)))-w_q
        w = 0.0*2*np.pi
    return(w)

def getfid_Xgate(P , ratio , QB):
    '''
    在对比特进行XY驱动时,对比特的Z施加一个形式相同,幅度不同的驱动
    '''
    omega = P[0]
    wf = P[1]
    D = P[2]
    ratio = ratio
    args = {'T_P':40,'T_copies':101 , 'omega':omega , 'D':D , 'wf': wf , 'eta_q':QB.eta_q,'ratio':ratio,'w_q':QB.frequency[0]}
    Hdrive = [[QB.sm[0] + QB.sm[0].dag() , Xgate_X_drive],[QB.sm[0].dag()*QB.sm[0],Xgate_Z_drive]]
    final = QB.process(drive = Hdrive,process_plot = False,parallel = True , argument = args)


    target_state = QB.State_eig[QB.first_excited[1]]*QB.State_eig[QB.first_excited[0]].dag()+QB.State_eig[QB.first_excited[0]]*QB.State_eig[QB.first_excited[1]].dag()
    target = target_state.data.toarray()[0:2,0:2]

    # QB.evolution(drive = Hdrive , psi = (basis(3,0)+1j*basis(3,1)).unit() , collapse = [], track_plot = True , RWF = 'CpRWF',argument = args )

    Ufidelity = np.abs(np.trace(np.dot(np.conjugate(np.transpose(target)),final)))/(2**QB.num_qubits)
    print(Ufidelity)
    return(1-Ufidelity)
def opt_Xgate(ratio,QB):
    P = [  0.23724056,  34.55760448,  -0.43552389]
    func = partial(getfid_Xgate , ratio = ratio , QB=QB )
    result = minimize(func, P, method="Nelder-Mead",options={'disp': True})

    return([result.x,1-result.fun])

    
if  __name__ == '__main__':
    frequency = np.array([5.5])* 2*np.pi
    coupling = np.array([])*2*np.pi
    eta_q=  np.array([-0.250 ]) * 2 * np.pi
    N_level= 3
    parameter = [frequency,coupling,eta_q,N_level]
    QBC = Qubits(qubits_parameter = parameter)

    H0 = QBC.H0
    X_bias = 0.8*2*np.pi
    H0 = H0+X_bias*(QBC.sm[0] + QBC.sm[0].dag())
    QBC.H0 = H0
    [QBC.E_eig,QBC.State_eig] = QBC.H0.eigenstates()
    QBC.first_excited = QBC._FirstExcite()

    print(opt_Xgate(0,QBC))
    # P = [0.03*2*np.pi*4,QBC.frequency[0],-0.5]
    # func = partial(getfid_Xgate , ratio = 0,QB=QBC )

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


    # ratio_list = np.linspace(-1,1000,1001)
    # p = Pool()
    # result = []
    # for ii in range(len(ratio_list)):
    #     result.append(p.apply_async(opt_Xgate,(ratio_list[ii], QBC)))
    # resultdata = np.array([result[i].get() for i in range(len(result))])
    # p.close()
    # p.join()
    # Xgate_para = [resultdata[i][0] for i in range(len(resultdata))]
    # fid_list = [resultdata[i][1] for i in range(len(resultdata))]

    # plt.figure()
    # plt.plot(ratio_list,fid_list)
    # plt.title('Frequency Oscilation in X gate large scale')
    # plt.xlabel('ratio_list');plt.ylabel('fidelity')
    # plt.savefig('./Frequency Oscilation in X gate large scale')

    # savefilename = './Frequency Oscilation in X gate large scale'
    # np.savez(savefilename,ratio_list = ratio_list,fid_list=fid_list,Xgate_para = Xgate_para)
    # plt.show()
    