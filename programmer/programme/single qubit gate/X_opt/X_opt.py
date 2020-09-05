
from scipy.optimize import *
import numpy as np
from functools import partial
from Qubits import Qubits
import copy

from swarmops.Problem import Problem
from swarmops.SuSSADE import SuSSADE
from swarmops.Optimize import MultiRun
from swarmops.Timer import Timer

def X_drive(t,args):
    tp = args['T_P']
    omega = args['omega']
    D = args['D']
    wf = args['wf']
    eta_q = args['eta_q']
    if t<0 or t>tp:
        w = 0
    else:
        w = omega*((1-np.cos(2*np.pi/tp*t))*np.cos(wf*t)+D*(2*np.pi/tp)*np.sin(2*np.pi/tp*t)/(eta_q[0])*np.cos(t*wf-np.pi/2))
    return(w)

def getfid(P , QB , limit = np.Infinity):
    QBE = copy.copy(QB)

    omega = P[0]
    wf = P[1]
    D = P[2]

    args = {'T_P':20,'T_copies':101 , 'omega':omega , 'D':D , 'wf': wf , 'eta_q':QBE.eta_q}
    Hdrive = [[QBE.sm[0] + QBE.sm[0].dag() , X_drive]]
    final = QBE.process(drive = Hdrive,process_plot = False,parallel = True , argument = args)
    target = np.array([[0,1],[1,0]])

    Ufidelity = np.abs(np.trace(np.dot(np.conjugate(np.transpose(target)),final)))/(2**QBE.num_qubits)

    return(1-Ufidelity)

if __name__ == '__main__':

    
    frequency = np.array([5.6])*2*np.pi
    coupling = np.array([])*2*np.pi
    eta_q=  np.array([-0.250 ]) * 2 * np.pi
    N_level= 3
    parameter = [frequency,coupling,eta_q,N_level]
    QB = Qubits(qubits_parameter = parameter)

    P = [0.08*2*np.pi,QB.frequency[0],-0.5]
    func = partial(getfid , QB=QB )
    
    # NM算法
    # result = minimize(func, P, method="Nelder-Mead",options={'disp': True})
    # print(result)
    # swarmops
    # problem = Problem(name="X_OPT", dim=3, fitness_min=0.0,
    #                                 lower_bound=[0*2*np.pi , QB.frequency[0]-0.0015*2*np.pi , -1], 
    #                                 upper_bound=[0.09*2*np.pi , QB.frequency[0]+0.0015*2*np.pi , 1],
    #                                 lower_init=[0.03*2*np.pi , QB.frequency[0]-0.0005*2*np.pi , -1], 
    #                                 upper_init=[0.06*2*np.pi , QB.frequency[0]+0.0005*2*np.pi , 0],
    #                                 func=func)
    
    # print('start')
    # optimizer = SuSSADE
    # parameters = [12, 0.3, 0.9 , 1 ]

    # # Start a timer.
    # timer = Timer()

    # # Perform a single optimization run using the optimizer
    # # where the fitness is evaluated in parallel.
    # result = optimizer(parallel=True, problem=problem,
    #                     max_evaluations=500,
    #                     display_interval=1,
    #                     trace_len=500,
    #                     StdTol = 0.0001,
    #                     directoryname  = 'resultSuSSADE')

    # # Stop the timer.
    # timer.stop()

    # print()  # Newline.
    # print("Time-Usage: {0}".format(timer))
    # print()  # Newline.

    # print("Best fitness from heuristic optimization: {0:0.5e}".format(result.best_fitness))
    # print("Best solution:")
    # print(result.best)

    # if True:
    #     print()  # Newline.
    #     print("Refining using SciPy's L-BFGS-B (this may be slow on some problems) ...")

    #     # Do the actual refinement using the L-BFGS-B optimizer.
    #     refined_fitness, refined_solution = result.refine()

    #     print("Best fitness from L-BFGS-B optimization: {0:0.4e}".format(refined_fitness))
    #     print("Best solution:")
    #     print(refined_solution)

    # # Plot the fitness trace.
    # if True > 0:
    #     result.plot_fitness_trace()