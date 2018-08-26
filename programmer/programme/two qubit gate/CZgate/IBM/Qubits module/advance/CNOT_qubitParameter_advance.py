from scipy.optimize import *
import numpy as np
from functools import partial
from Qubits import Qubits
import copy
from qutip import *

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
def getfid(P , parallel = False , limit = np.Infinity):
    

    delta = P[0] # 频率
    g = P[1] #频率
    
    t_cr = P[2]
    omega_cr = P[3] * 2 * np.pi
    wf_cr = P[4] * 2 * np.pi
   

    D_cr = -0.5

    frequency = np.array([5.2 , 5.2-delta])*2*np.pi
    coupling = np.array([g])*2*np.pi
    eta_q=  np.array([-0.250 , -0.250]) * 2 * np.pi
    parameter = [frequency,coupling,eta_q]
    QBE = Qubits(qubits_parameter = parameter)

    ZZ = QBE.E_eig[QBE._findstate('11')]-QBE.E_eig[QBE._findstate('01')]-QBE.E_eig[QBE._findstate('10')]+QBE.E_eig[QBE._findstate('00')]

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

    Ufidelity = Ufidelity*np.exp(-(70+2*t_cr)/20000.0)
    N_gate = 1/ZZ/(2*t_cr+70)
    estimate = 0
    for index , II in enumerate(np.linspace(0.75,0.99,20)):
        estimate += (Ufidelity>II)*N_gate*0.02 if index !=0 else (Ufidelity>0.8)*N_gate*0.1
    for j in range(10):
        estimate += (Ufidelity>(0.99+j/2000.0))*N_gate*(0.06) if j !=0 else (Ufidelity>(0.99))*N_gate*(1)
    for jj in range(10):
        estimate += (Ufidelity>(0.995+j/2000.0))*N_gate*(0.15) if j !=0 else (Ufidelity>(0.99))*N_gate*(1)


    return(-estimate)

def refine(function , initial_x0  , bound):
    
    res = minimize(fun=function,
                    x0=initial_x0,
                    method="L-BFGS-B",
                    bounds=bound,
                    options = {'maxiter': 30,'disp':1})

    # Get best fitness and parameters.
    refined_fitness = res.fun
    refined_solution = res.x

    return (refined_fitness, refined_solution)



if __name__ == '__main__':
    '''
    不再将xita作为参数
    '''

    




    # swarmops
    func = partial(getfid , parallel = False , limit = np.Infinity)

    lower_bound = [0.03 , 0.0001 , 20 , 0.02 , 5.0 ]
    upper_bound = [0.2 , 0.008 , 150 , 0.22 , 5.17]
    lower_init=[0.03 , 0.0001 , 20 , 0.19 , 5.0 ]
    upper_init=[0.2 , 0.008 , 40 , 0.22 , 5.17]

    problem = Problem(name="CNOT_OPT", dim=5, fitness_min=-np.Inf,
                                    lower_bound=lower_bound, 
                                    upper_bound=upper_bound,
                                    lower_init=lower_init, 
                                    upper_init=upper_init,
                                    func=func)
    
    print('start')
    optimizer = SuSSADE
    parameters = [24, 0.3, 0.9 , 0.9 ]

    # Start a timer.
    timer = Timer()

    # Perform a single optimization run using the optimizer
    # where the fitness is evaluated in parallel.
    result = optimizer(parallel=True, problem=problem,
                        max_evaluations=400,
                        display_interval=1,
                        trace_len=400,
                        StdTol = 0.001,
                        directoryname  = 'result')

    # Stop the timer.
    timer.stop()

    print()  # Newline.
    print("Time-Usage: {0}".format(timer))
    print()  # Newline.

    print("Best fitness from heuristic optimization: {0:0.5e}".format(result.best_fitness))
    print("Best solution:")
    print(result.best)

    if True:
        print()  # Newline.
        print("Refining using SciPy's L-BFGS-B (this may be slow on some problems) ...")

        # Do the actual refinement using the L-BFGS-B optimizer.
        bound = list(zip(lower_bound, upper_bound))
        func = partial(getfid , parallel = True , limit = np.Infinity)
        refined_fitness, refined_solution = refine(func , result.best , bound)

        print("Best fitness from L-BFGS-B optimization: {0:0.4e}".format(refined_fitness))
        print("Best solution:")
        print(refined_solution)

    # Plot the fitness trace.
    if True > 0:
        result.plot_fitness_trace()