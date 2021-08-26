import matplotlib.pyplot as plt
import numpy as np
from functools import partial
from Qubits import Qubits
import copy
import multiprocessing as mp


def X_drive_1(t,args):
    tx = 20
    omega = 0.025078*2*np.pi
    D = -0.49548826
    wf = args['wf_x']
    eta_q = args['eta_q']
    t_cr = args['t_cr']

    if t<(10+t_cr) or t>(30+t_cr):
        w = 0
    else:
        w = omega*((1-np.cos(2*np.pi/tx*(t-10-t_cr)))*np.cos(wf*t)+D*(2*np.pi/tx)*np.sin(2*np.pi/tx*(t-10-t_cr))/(eta_q[0])*np.cos(t*wf-np.pi/2))
    return(w)
def X_drive_2(t,args):
    tx = 20
    omega = 0.025078*2*np.pi
    D = -0.49548826
    wf = args['wf_x']
    eta_q = args['eta_q']
    t_cr = args['t_cr']
    if t<(50+2*t_cr) or t>(70+2*t_cr):
        w = 0
    else:
        w = omega*((1-np.cos(2*np.pi/tx*(t-50-2*t_cr)))*np.cos(wf*t)+D*(2*np.pi/tx)*np.sin(2*np.pi/tx*(t-50-2*t_cr))/(eta_q[0])*np.cos(t*wf-np.pi/2))
    return(w)


def CR_drive_1(t,args):
    wf = args['wf_cr']
    eta_q = args['eta_q']
    t_cr = args['t_cr']
    omega = args['omega_cr']
    D = args['D_cr']
    if t<(0) or t>(t_cr):
        w = 0
    else:
        w = omega*((1-np.cos(2*np.pi/t_cr*(t)))*np.cos(wf*t)+D*(2*np.pi/t_cr)*np.sin(2*np.pi/t_cr*(t))/(eta_q[0])*np.cos(t*wf-np.pi/2))
    return(w)

def CR_drive_2(t,args):
    wf = args['wf_cr']
    eta_q = args['eta_q']
    t_cr = args['t_cr']
    omega = args['omega_cr']
    D = args['D_cr']
    
    if t<(t_cr+40) or t>(2*t_cr+40):
        w = 0
    else:
        w = omega*((1-np.cos(2*np.pi/t_cr*(t-t_cr-40)))*np.cos(wf*t+np.pi)+D*(2*np.pi/t_cr)*np.sin(2*np.pi/t_cr*(t-t_cr-40))/(eta_q[0])*np.cos(t*wf+np.pi-np.pi/2))
    return(w)
def getfid(P , parallel = False , limit = np.Infinity):
    

    delta = 0.20 # 频率
    g = 0.00015 #频率
    D_cr = -0.5
    t_cr = P[0]
    omega_cr = P[1] * 2 * np.pi
    wf_cr = P[2] * 2 * np.pi
   

    frequency = np.array([5.2 , 5.2-delta])*2*np.pi
    coupling = np.array([g])*2*np.pi
    eta_q=  np.array([-0.250 , -0.250]) * 2 * np.pi
    parameter = [frequency,coupling,eta_q]
    QBE = Qubits(qubits_parameter = parameter)

    args = {'T_P':70+2*t_cr,'T_copies':1001 , 'wf_x':QBE.frequency[0] , 'eta_q':QBE.eta_q , 
            't_cr': t_cr , 'wf_cr':wf_cr , 'omega_cr':omega_cr , 'D_cr':D_cr}

    H1 = [QBE.sm[0] + QBE.sm[0].dag() , CR_drive_1]
    H2 = [QBE.sm[0] + QBE.sm[0].dag() , X_drive_1]
    H3 = [QBE.sm[0] + QBE.sm[0].dag() , CR_drive_2]
    H4 = [QBE.sm[0] + QBE.sm[0].dag() , X_drive_2]
    Hdrive = [H1,H2,H3,H4]



    final = QBE.process(drive = Hdrive,process_plot = False , parallel = parallel , argument = args)
    xita0 = -np.angle(final[2][2])
    xita1 = -np.angle(final[1][1])
    final = QBE.phase_comp(final , [xita0 , xita1])
    targetprocess = 1/np.sqrt(2)*np.array([[1,1j,0,0],[1j,1,0,0],[0,0,1,-1j],[0,0,-1j,1]])

    Ufidelity = np.abs(np.trace(np.dot(np.conjugate(np.transpose(targetprocess)),final)))/(2**QBE.num_qubits)

    fid = Ufidelity*np.exp(-(70+2*t_cr)/20000.0)

    return(Ufidelity , fid)



if __name__ == '__main__':
    '''
    输入最优参数，得到参数各个分量的鲁棒性
    '''

    func = partial(getfid , parallel = False , limit = np.Infinity)

    best = [150.00000 , 0.21581 , 5.00000]
    candidate_size = 20
    candidate = np.array([best for i in range(candidate_size)])
    fig , ax = plt.subplots(len(best) , 2)
    p = mp.Pool()
    for i in range(len(best)):
        best_parameter = best[i]
        test_parameter = np.linspace(0.95*best_parameter , 1.05*best_parameter , candidate_size)#测试参数从最优值的0.95变化到1.05
        parameter = copy.copy(candidate)
        parameter[:,i] = test_parameter
        A = p.map(func, parameter)
        Ufidelity_list = [x[0] for x in A]
        fid_list = [x[1] for x in A]
        ax[i][0].plot(test_parameter , Ufidelity_list)
        ax[i][1].plot(test_parameter , fid_list)
    plt.show()
    plt.savefig('robust_advance.png')
    p.close()
    p.join()


    