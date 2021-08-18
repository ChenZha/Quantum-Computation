from scipy.optimize import *
import numpy as np
from functools import partial
from Qubits import Qubits
import copy
from qutip import *
from multiprocessing import Pool

from swarmops.Timer import Timer
from swarmops.Problem import Problem
from swarmops.SuSSADE import SuSSADE
from CMAES.CMAES import CovMatAdapt

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
def getfid(P , parallel = True , limit = np.Infinity):
    

    D_cr = -0.5
    t_cr = P[0]
    omega_cr = P[1] * 2 * np.pi
    wf_cr = P[2] * 2 * np.pi
   
    xita = [P[3],P[4]]
    

    frequency = np.array([5.26 , 5.6478 , 5.11])*2*np.pi
    coupling = np.array([0.0395 , 0.04 ])*2*np.pi
    eta_q=  np.array([-0.250 , 0 , -0.250]) * 2 * np.pi
    parameter = [frequency,coupling,eta_q]
    QBE = Qubits(qubits_parameter = parameter)

    args = {'T_P':70+2*t_cr,'T_copies':1001 , 'wf_x':QBE.E_eig[QBE.first_excited[0]] , 'eta_q':QBE.eta_q , 
            't_cr': t_cr , 'wf_cr':wf_cr , 'omega_cr':omega_cr , 'D_cr':D_cr}

    H1 = [QBE.sm[0] + QBE.sm[0].dag() , CR_drive_1]
    H2 = [QBE.sm[0] + QBE.sm[0].dag() , X_drive_1]
    H3 = [QBE.sm[0] + QBE.sm[0].dag() , CR_drive_2]
    H4 = [QBE.sm[0] + QBE.sm[0].dag() , X_drive_2]
    Hdrive = [H1,H2,H3,H4]

    Psi = []
    Psi.append(tensor(basis(3,0),basis(3,0),basis(3,0)))
    Psi.append(tensor(basis(3,0),basis(3,0),basis(3,1)))
    Psi.append(tensor(basis(3,1),basis(3,0),basis(3,0)))
    Psi.append(tensor(basis(3,1),basis(3,0),basis(3,1)))
    
    # final = QBE.evolution(drive = Hdrive , psi = tensor(basis(3,0),basis(3,0),basis(3,0)) ,  track_plot = True ,argument = args)
    # print(fidelity(final , tensor(basis(3,0),basis(3,0),basis(3,0))))

    final_state = [] #基矢演化得到的末态
    if parallel:
        p = Pool()
        result_final = []
        for i in range(len(Psi)):
            result_final.append(p.apply_async(QBE.evolution , (Hdrive , Psi[i] , [] , False , args)))
        final_state = [result_final[i].get() for i in range(len(result_final))]
        p.close()
        p.join()
    else:
        for Phi in Psi:
            final_state.append(QBE.evolution(Hdrive , Phi , [] , False , argument= args))

    l000 = QBE._findstate('000');l001 = QBE._findstate('001');l100 = QBE._findstate('100');l101 = QBE._findstate('101');
    process = np.column_stack([final_state[i].data.toarray() for i in range(len(final_state))])[(l000,l001,l100,l101),:] #只取演化矩阵中二能级部分
    angle = np.angle(process[0][0])
    process = process*np.exp(-1j*angle)#消除global phase
    for index in range(2**2):
        II = index
        for JJ in range(2):
            number = np.int(np.mod(II,2))
            if number == 1:
                process[:,index] = process[:,index]*np.exp(1j*xita[-1-JJ])
            II = np.int(np.floor(II/2))

    targetprocess = 1/np.sqrt(2)*np.array([[1,-1j,0,0],[-1j,1,0,0],[0,0,1,1j],[0,0,1j,1]]) # 由于比特间的等效耦合强度为负数

    Ufidelity = np.abs(np.trace(np.dot(np.conjugate(np.transpose(targetprocess)),process)))/(2**2)


    return(1-Ufidelity)

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

    

    # P = [115.72235, 0.10597, 5.10677, 2.45946, -0.12994]
    # getfid(P)

    # NM算法
    # result = minimize(getfid, P, method="Nelder-Mead",options={'disp': True})
    # print(result)

    # CMAES
    # func = partial(getfid , parallel = False , limit = np.Infinity)
    # lower_bound = [40 , 0.02 , (5.2-0.151) ,  -np.pi , -np.pi]
    # upper_bound = [160 , 0.2 , (5.2-0.149) ,   np.pi , np.pi]
    # initial_vec = np.array([80 , 0.10 , 5.05 , 0 , 0])
    # step_size = np.array([30 , 0.05 , 0.0005 , np.pi/2 , np.pi/2])

    # optimizer = CovMatAdapt(func = func, mean_vec = initial_vec, step_size = step_size, 
    #                         lower_bound = lower_bound , upper_bound = upper_bound,
    #                         pop_size  = 20, directoryname='result_CMAES'
    #                         )
    # result = optimizer.minimize()
    # print(result)

    # swarmops
    func = partial(getfid , parallel = False , limit = np.Infinity)

    lower_bound = [40 , 0.02 , 5.106530-0.0015 ,  -np.pi , -np.pi]
    upper_bound = [ 160 , 0.2 , 5.106530+0.0015 ,   np.pi , np.pi]
    lower_init=[40 , 0.02 , 5.106530-0.0015 ,  -np.pi , -np.pi]
    upper_init=[160 , 0.2 , 5.106530+0.0015 ,   np.pi , np.pi]

    problem = Problem(name="CNOT_OPT", dim=5, fitness_min=0.0,
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
                        directoryname  = 'SuSSADE_cavity')

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