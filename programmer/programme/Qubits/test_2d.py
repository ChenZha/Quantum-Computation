import numpy as np
from Qubits_2d import Qubits_2d
from qutip import *
import matplotlib.pyplot as plt

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

def readoutwave(t,args):
    # t_start = args['t_start']
    # t_end = args['t_end']
    readoutfreq = args['readoutfreq']
    # intensity = args['intensity']
    w = 0.1*2*np.pi*np.cos(readoutfreq*(t))
    return(w)

if __name__ == '__main__':
    
    frequency = np.array([
        [5.1 , 5.1],
        [5.1 , 5.1],
    ])*2*np.pi

    coupling = np.array([
        [0 , 0],
        [0 , 0] ,
        [0.012 , 0],
    ])*2*np.pi

    eta_q=  np.array([
        [-0.250 , -0.250],
        [-0.250 , -0.250],
    ])*2*np.pi

    N_level= [
        [3 , 3],
        [3 , 3],
    ]

    parameter = [frequency,coupling,eta_q,N_level]
    QBE = Qubits_2d(qubits_parameter = parameter)
    print(QBE)

    args = {'T_P':100,'T_copies':101 , 'readoutfreq':frequency[0,0]}
    H1 = [QBE.sm[0,0].dag()+QBE.sm[0,0],readoutwave]
    Hdrive = [H1]

    final = QBE.evolution(drive = Hdrive , psi = tensor((basis(3,0)).unit(),(basis(3,1)).unit(),(basis(3,1)).unit(),(basis(3,0)).unit()) ,  RWF = 'UnCpRWF' , RWA_freq = 0,track_plot = True ,argument = args)
    print(final)
    # final = QBE.process(drive = Hdrive,process_plot = True , RWF = 'custom_RWF' , RWA_freq = 0.0 , parallel = True , argument = args)