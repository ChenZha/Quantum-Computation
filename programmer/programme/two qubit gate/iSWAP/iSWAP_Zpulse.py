from scipy.optimize import *
import numpy as np
from functools import partial
from Qubits import Qubits
import copy
from qutip import *
import matplotlib.pyplot as plt

from swarmops.Timer import Timer
from swarmops.Problem import Problem
from swarmops.SuSSADE import SuSSADE

def Z_pulse(t,args):

    delta = args['delta']
    T = args['T_P']

    if t<0:
        w = 0
    elif t>=0 and t<=3:
        w = delta/2*(1-np.cos(np.pi/3*t))
    elif t>3 and t<T-3:
        w = delta
    elif t>=T-3 and t<=T:
        w = delta/2*(1+np.cos(np.pi/3*(t-T+3)))
    else:
        w = 0
    return(w)
def getfid(P , parallel = True, limit = np.Infinity):
    T = P[0]
    xita0 = P[1]
    xita1 = P[2]


    frequency = np.array([5.7 , 5.1])*2*np.pi
    coupling = np.array([0.012])*2*np.pi
    eta_q=  np.array([-0.250 , -0.250]) * 2 * np.pi
    parameter = [frequency,coupling,eta_q]
    QBE = Qubits(qubits_parameter = parameter)

    args = {'T_P':T,'T_copies':1001 , 'delta':QBE.E_eig[QBE.first_excited[0]]-QBE.E_eig[QBE.first_excited[1]]}

    H1 = [QBE.sm[1].dag()*QBE.sm[1],Z_pulse]
    Hdrive = [H1]

    # final = QBE.evolution(drive = Hdrive , psi = tensor(basis(3,0),(basis(3,0)+basis(3,1)).unit()) ,  track_plot = True ,argument = args)

    final = QBE.process(drive = Hdrive,process_plot = False , parallel = parallel , argument = args)
    final = QBE.phase_comp(final , [xita0 , xita1])
    targetprocess = np.array([[1,0,0,0],[0,0,-1j,0],[0,-1j,0,0],[0,0,0,1]])
    Ufidelity = np.abs(np.trace(np.dot(np.conjugate(np.transpose(targetprocess)),final)))/(2**QBE.num_qubits)
    print(P,Ufidelity)

    return(1-Ufidelity)




if __name__ == '__main__':
    

    # NM算法
    func = partial(getfid , parallel = True, limit = np.Infinity)
    P = [1/4/0.012,0,0]
    result = minimize(func, P, method="Nelder-Mead",options={'disp': True})
    print(result)

    # swarmops
    func = partial(getfid , parallel = False , limit = np.Infinity)

    lower_bound = [1/4/0.012-5 ,-np.pi , -np.pi]
    upper_bound = [1/4/0.012+5 ,  np.pi , np.pi]
    lower_init=[1/4/0.012-5 ,  -np.pi , -np.pi]
    upper_init=[1/4/0.012+5,   np.pi , np.pi]

    problem = Problem(name="iSWAP_OPT", dim=3, fitness_min=0.0,
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
                        max_evaluations=400,
                        display_interval=1,
                        trace_len=400,
                        StdTol = 0.00001,
                        directoryname  = 'iSWAP')

    # Stop the timer.
    timer.stop()

    print()  # Newline.
    print("Time-Usage: {0}".format(timer))
    print()  # Newline.

    print("Best fitness from heuristic optimization: {0:0.5e}".format(result.best_fitness))
    print("Best solution:")
    print(result.best)