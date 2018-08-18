import numpy as np
from functools import partial
from Qubits import Qubits
from qutip import *

def X_drive(t,args):
    tp = args['T_P']
    omega = args['omega']
    D = args['D']
    wf = args['wf']
    eta_q = args['eta_q']
    if t<0 or t>tp:
        w = 0
    else:
        w = omega*(1-np.cos(2*np.pi/tp*t))*np.cos(wf*t)+D*(2*np.pi/tp)*np.sin(2*np.pi/tp*t)/(eta_q[0])*np.cos(t*wf-np.pi/2)
    return(w)
if __name__ == '__main__':
    frequency = np.array([5.6])*2*np.pi
    coupling = np.array([])*2*np.pi
    eta_q=  np.array([-0.250 ]) * 2 * np.pi
    parameter = [frequency,coupling,eta_q]
    QB = Qubits(qubits_parameter = parameter)

    omega = 0.025078*2*np.pi
    wf = 5.6*2*np.pi
    D = -0.07805211

    args = {'T_P':20,'T_copies':101 , 'omega':omega , 'D':D , 'wf': wf , 'eta_q':QB.eta_q}
    Hdrive = [[QB.sm[0] + QB.sm[0].dag() , X_drive]]

    final  = QB.evolution(drive = Hdrive , psi = basis(3,0) ,  track_plot = True ,argument = args)
    fid = fidelity(final, basis(3,1))
    print(fid)