from scipy.optimize import *
import numpy as np
from functools import partial
from Qubits import Qubits
import copy

from swarmops.Timer import Timer
from swarmops.Problem import Problem
from swarmops.SuSSADE import SuSSADE

def X_drive_1(t,args):
    tp = 20
    omega = 0.025078*2*np.pi
    D = -0.07805211
    wf = args['wf_x']
    eta_q = args['eta_q_x']
    if t< or t>tp:
        w = 0
    else:
        w = omega*(1-np.cos(2*np.pi/tp*t))*np.cos(wf*t)+D*(2*np.pi/tp)*np.sin(2*np.pi/tp*t)/(eta_q[0])*np.cos(t*wf-np.pi/2)
    return(w)
def X_drive_2(t,args):
    tp = 20
    omega = 0.025078*2*np.pi
    D = -0.07805211
    wf = args['wf_x']
    eta_q = args['eta_q_x']
    if t<0 or t>tp:
        w = 0
    else:
        w = omega*(1-np.cos(2*np.pi/tp*t))*np.cos(wf*t)+D*(2*np.pi/tp)*np.sin(2*np.pi/tp*t)/(eta_q[0])*np.cos(t*wf-np.pi/2)
    return(w)
def getfid(P , limit = np.Infinity):
    

    delta = P[0]
    g = P[1]
    t_cr = P[2]
    omega_cr = P[3]
    wf_cr = P[4]

    frequency = np.array([5.2 , 5.2-delta])*2*np.pi
    coupling = np.array([g])*2*np.pi
    eta_q=  np.array([-0.250 , -0.250]) * 2 * np.pi
    parameter = [frequency,coupling,eta_q]
    QB = Qubits(qubits_parameter = parameter)

    args = {'T_P':20,'T_copies':101 , 'omega':omega , 'D':D , 'wf': wf , 'eta_q':QBE.eta_q}
    Hdrive = [[QBE.sm[0] + QBE.sm[0].dag() , X_drive]]
    final = QBE.process(drive = Hdrive,process_plot = False,parallel = False , argument = args)
    target = np.array([[0,1],[1,0]])

    Ufidelity = np.abs(np.trace(np.dot(np.conjugate(np.transpose(target)),final)))/(2**QBE.num_qubits)

    return(1-Ufidelity)



if __name__ == '__main__':