
import numpy as np
from functools import partial
from Qubits import Qubits
import copy
import matplotlib.pyplot as plt
import scipy.io as sio

from swarmops.Timer import Timer
from swarmops.Problem import Problem
from swarmops.SuSSADE import SuSSADE

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
def getfid(P ,  QB , parallel = False , limit = np.Infinity):
    

    D_cr = -0.5
    t_cr = P[0]
    omega_cr = P[1] * 2 * np.pi
    wf_cr = P[2] * 2 * np.pi
   
    xita0 = P[3]
    xita1 = P[4]

    QBE = copy.copy(QB)

    args = {'T_P':70+2*t_cr,'T_copies':1001 , 'wf_x':QBE.frequency[0] , 'eta_q':QBE.eta_q , 
            't_cr': t_cr , 'wf_cr':wf_cr , 'omega_cr':omega_cr , 'D_cr':D_cr}

    H1 = [QBE.sm[0] + QBE.sm[0].dag() , CR_drive_1]
    H2 = [QBE.sm[0] + QBE.sm[0].dag() , X_drive_1]
    H3 = [QBE.sm[0] + QBE.sm[0].dag() , CR_drive_2]
    H4 = [QBE.sm[0] + QBE.sm[0].dag() , X_drive_2]
    Hdrive = [H1,H2,H3,H4]


    final = QBE.process(drive = Hdrive,process_plot = False , parallel = parallel , argument = args)
    final = QBE.phase_comp(final , [xita0 , xita1])
    targetprocess = 1/np.sqrt(2)*np.array([[1,1j,0,0],[1j,1,0,0],[0,0,1,-1j],[0,0,-1j,1]])

    Ufidelity = np.abs(np.trace(np.dot(np.conjugate(np.transpose(targetprocess)),final)))/(2**QBE.num_qubits)

    return(1-Ufidelity)

    # fid = Ufidelity*(1-(70+2*t_cr)/40000.0)
    # return(1-fid)








if __name__ == '__main__':

    fid_list = []
    t_list = []
    N_list = []
    estimate_list = []
    ZZ_list = []

    glist = np.array([0.0005 , 0.0008 , 0.001 , 0.0015 , 0.002 , 0.0025 , 0.003 , 0.004 , 0.008 , 0.01 , ])
    for index , g in enumerate(glist):
        frequency = np.array([5.2 , 5.05])*2*np.pi
        coupling = np.array([g])*2*np.pi
        eta_q=  np.array([-0.250 , -0.250]) * 2 * np.pi
        parameter = [frequency,coupling,eta_q]
        QB = Qubits(qubits_parameter = parameter)

        ZZ = QB.E_eig[QB._findstate('11')]-QB.E_eig[QB._findstate('01')]-QB.E_eig[QB._findstate('10')]+QB.E_eig[QB._findstate('00')]
        # swarmops
        func = partial(getfid , QB = QB , parallel = False , limit = np.Infinity)

        lower_bound = [20 , 0.02 , (5.2-0.152) ,  -np.pi , -np.pi]
        upper_bound = [150 , 0.40 , (5.2-0.148) ,   np.pi , np.pi]
        lower_init=[20 , 0.02 , (5.2-0.152) ,  -np.pi , -np.pi]
        upper_init=[150 , 0.40 , (5.2-0.148) ,   np.pi , np.pi]

        problem = Problem(name="CNOT_OPT_"+str(index), dim=5, fitness_min=0.0,
                                        lower_bound=lower_bound, 
                                        upper_bound=upper_bound,
                                        lower_init=lower_init, 
                                        upper_init=upper_init,
                                        func=func)
        
        print('start')
        optimizer = SuSSADE
        parameters = [20, 0.3, 0.9 , 0.9 ]

        # Start a timer.
        timer = Timer()

        # Perform a single optimization run using the optimizer
        # where the fitness is evaluated in parallel.
        result = optimizer(parallel=True, problem=problem,
                            max_evaluations=500,
                            display_interval=1,
                            trace_len=500,
                            StdTol = 0.00001,
                            directoryname  = 'resultSuSSADE_'+str(g))

        # Stop the timer.
        timer.stop()

        print()  # Newline.
        print("Time-Usage: {0}".format(timer))
        print()  # Newline.
        print('coupling = '+str(g))
        print()
        print("Best fitness from heuristic optimization: {0:0.5e}".format(result.best_fitness))
        print("Best solution:")
        print(result.best)

        fid = 1-result.best_fitness
        fid_list.append(fid)
        t_list.append(result.best[0])
        N_gate = 1/ZZ/(2*result.best[0]+70)
        N_list.append(N_gate)
        ZZ_list.append(ZZ)

        estimate = 0
        for j in range(20):
            estimate += (fid>(0.99+j/2000.0))*N_gate*(0.05) if j !=0 else (fid>(0.99))*N_gate*(1)
        estimate_list.append(estimate)


    fid_list = np.array(fid_list)
    t_list = np.array(t_list)
    N_list = np.array(N_list)
    estimate_list = np.array(estimate_list)
    ZZ_list = np.array(ZZ_list)

    sio.savemat('CNOT_g.mat',{'fid_list':fid_list,'t_list':t_list,
                'N_list':N_list,'estimate_list':estimate_list,'glist':glist,'ZZ_list':ZZ_list})


    fig,axes = plt.subplots(5,1)
    axes[0].plot(glist,fid_list);axes[0].set_xlabel('g');axes[0].set_ylabel('fid');
    axes[1].plot(glist,t_list);axes[1].set_xlabel('g');axes[1].set_ylabel('t');
    axes[2].plot(glist,N_list);axes[2].set_xlabel('g');axes[2].set_ylabel('Ngate');
    axes[3].plot(glist,estimate_list);axes[3].set_xlabel('g');axes[3].set_ylabel('estimate');
    axes[4].plot(glist,ZZ_list);axes[4].set_xlabel('g');axes[4].set_ylabel('ZZ');
    plt.savefig('CNOT_g.png')
    plt.show()
    
    

