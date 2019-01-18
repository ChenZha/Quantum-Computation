from scipy.optimize import *
import numpy as np
from functools import partial
from Qubits import Qubits
from multiprocessing import Pool
import copy
from qutip import *
import matplotlib.pyplot as plt

# from swarmops.Timer import Timer
# from swarmops.Problem import Problem
# from swarmops.SuSSADE import SuSSADE

def Z_pulse(t,args):

    delta = args['delta']
    T = args['T_P']
    k = -0.61394;b = 2.87164*10**4;c = -delta*10**9;
    x = (-b+np.sqrt(b**2-4*k*c))/2/k
    if t<0:
        w = 0
    elif t>=0 and t<=3:
        w = delta/2*(1-np.cos(np.pi/3*t))

    # elif t>3 and t<=100:
    #     w = delta
    # elif t>100 and t<=150:
    #     w = 1.01*delta
    # elif t>150 and t<=T-3:
    #     w = delta

    elif t>3 and t<=T-3:
        xt = x+0.005*x*np.cos(2*np.pi/50*t)
        w = (k*xt**2+b*x)/10**9
        
        # w = delta

    elif t>T-3 and t<=T:
        w = delta/2*(1+np.cos(np.pi/3*(t-T+3)))
    else:
        w = 0
    return(w)
def getfid(P , parallel = True, limit = np.Infinity):
    T = P[0]
    xita0 = P[1]
    xita1 = P[2]


    frequency = np.array([4.8 , 5.358])*2*np.pi
    coupling = np.array([0.012])*2*np.pi
    eta_q=  np.array([-0.250 , -0.250]) * 2 * np.pi
    N_level = 3
    parameter = [frequency,coupling,eta_q,N_level]
    QBE = Qubits(qubits_parameter = parameter)

    args = {'T_P':T,'T_copies':1001 , 'delta':0.0*2*np.pi}

    H1 = [QBE.sm[1].dag()*QBE.sm[1],Z_pulse]
    Hdrive = [H1]

    final = QBE.evolution(drive = Hdrive , psi = tensor(basis(3,0),(basis(3,0)+basis(3,1)).unit()) ,  RWF = 'CpRWF' , track_plot = True ,argument = args)

    # final = QBE.process(drive = Hdrive,process_plot = False , parallel = parallel , argument = args)
    # final = QBE.phase_comp(final , [xita0 , xita1])
    # targetprocess = np.array([[1,0,0,0],[0,0,-1j,0],[0,-1j,0,0],[0,0,0,1]])
    # Ufidelity = np.abs(np.trace(np.dot(np.conjugate(np.transpose(targetprocess)),final)))/(2**QBE.num_qubits)
    # print(P,Ufidelity)

    return(final)
def spec_evolution(QBC,psi,delta,T_P,T_copies):
    QBE = QBC
    args = {'T_P':T_P,'T_copies':T_copies , 'delta':delta}

    H1 = [QBE.sm[1].dag()*QBE.sm[1],Z_pulse]
    Hdrive = [H1]

    final = QBE.evolution(drive = Hdrive , psi = psi ,  track_plot = False ,argument = args)

    state_length = len(QBE.result.states)
    evo_list = np.zeros(state_length)
    for ii in range(state_length):
        evo_list[ii] = expect(QBE.E_e[0],QBE.result.states[ii])
    return(evo_list)
def spectrum(delta_list,psi,T_P,T_copies):

    frequency = np.array([4.8 , 5.358])*2*np.pi
    coupling = np.array([0.012])*2*np.pi
    eta_q=  np.array([-0.250 , -0.250]) * 2 * np.pi
    N_level = 3
    parameter = [frequency,coupling,eta_q,N_level]
    QBE = Qubits(qubits_parameter = parameter)

    delta_list_lenght = len(delta_list)

    p = Pool()
    result_final = []
    for ii in range(delta_list_lenght):
        result_final.append(p.apply_async(spec_evolution,(QBE,psi,delta_list[ii],T_P,T_copies)))
    evo_spec = np.array([result_final[i].get() for i in range(len(result_final))])

    evo_spec = evo_spec.transpose()
    print('evolution end')
    tlist = np.linspace(0,T_P,T_copies)
    xx, yy =np.meshgrid((frequency+delta_list)/2/np.pi, tlist)
    plt.figure()
    plt.pcolor(xx, yy,evo_spec)
    plt.colorbar()
    plt.show()

    return(evo_spec)



if __name__ == '__main__':


    # getfid([100,0,0])
    

    psi = tensor(basis(3,0),basis(3,1))
    delta_list = np.linspace(4.7,4.9,101)*2*np.pi-5.358*2*np.pi
    T_P = 250
    T_copies = T_P+1
    
    
    evo_spec = spectrum(delta_list,psi,T_P,T_copies)

    tlist = np.linspace(0,T_P,1001);
    args = {'T_P':T_P, 'delta':-0.5}
    wavelist = np.vectorize(Z_pulse)(tlist,args)
    plt.figure();plt.plot(tlist,wavelist);plt.show()
    
    
    
    
    
    
    
    # # NM算法
    # func = partial(getfid , parallel = True, limit = np.Infinity)
    # P = [1/4/0.012,0,0]
    # result = minimize(func, P, method="Nelder-Mead",options={'disp': True})
    # print(result)

    # # swarmops
    # func = partial(getfid , parallel = False , limit = np.Infinity)

    # lower_bound = [1/4/0.012-5 ,-np.pi , -np.pi]
    # upper_bound = [1/4/0.012+5 ,  np.pi , np.pi]
    # lower_init=[1/4/0.012-5 ,  -np.pi , -np.pi]
    # upper_init=[1/4/0.012+5,   np.pi , np.pi]

    # problem = Problem(name="iSWAP_OPT", dim=3, fitness_min=0.0,
    #                                 lower_bound=lower_bound, 
    #                                 upper_bound=upper_bound,
    #                                 lower_init=lower_init, 
    #                                 upper_init=upper_init,
    #                                 func=func)
    
    # print('start')
    # optimizer = SuSSADE
    # parameters = [20, 0.3, 0.9 , 0.9 ]

    # # Start a timer.
    # timer = Timer()

    # # Perform a single optimization run using the optimizer
    # # where the fitness is evaluated in parallel.
    # result = optimizer(parallel=True, problem=problem,
    #                     max_evaluations=400,
    #                     display_interval=1,
    #                     trace_len=400,
    #                     StdTol = 0.00001,
    #                     directoryname  = 'iSWAP')

    # # Stop the timer.
    # timer.stop()

    # print()  # Newline.
    # print("Time-Usage: {0}".format(timer))
    # print()  # Newline.

    # print("Best fitness from heuristic optimization: {0:0.5e}".format(result.best_fitness))
    # print("Best solution:")
    # print(result.best)