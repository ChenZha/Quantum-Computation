from scipy.optimize import *
import numpy as np
from functools import partial
from Qubits import Qubits
from multiprocessing import Pool
import copy
from qutip import *
import matplotlib.pyplot as plt

def readoutwave(t,args):
    t_start = args['t_start']
    t_end = args['t_end']
    readoutfreq = args['readoutfreq']
    intensity = args['intensity']
    t_last = t_end-t_start
    if t<t_start or t>t_end:
        w = 0
    elif t>=t_start and t<=t_end:
        w = intensity*np.cos(readoutfreq*(t-t_start))
    return(w)
def waveform(t,args):
    t_start = args['t_start']
    t_end = args['t_end']
    readoutfreq = args['readoutfreq']
    intensity = args['intensity']
    t_last = t_end-t_start
    if np.cos(readoutfreq*(t-t_start))==0:
        w = readoutwave(t,args)
    else:
        w = readoutwave(t,args)/np.cos(readoutfreq*(t-t_start))
    return(w)


if __name__ == '__main__':

    frequency = np.array([5.0 , 6.5 ])*2*np.pi
    coupling = np.array([0.05 ])*2*np.pi
    # coupling = np.array([0.0 , 0.000])*2*np.pi
    eta_q=  np.array([-0.250 , 0 ]) * 2 * np.pi
    N_level= [2,200]
    parameter = [frequency,coupling,eta_q,N_level]
    QBE = Qubits(qubits_parameter = parameter)


    t_total = 6000
    T_copies = 5*int(t_total)+1
    t_start = 0
    t_end = t_total
    readoutfreq = QBE.E_eig[QBE.first_excited[1]]
    print(readoutfreq/2/np.pi)
    intensity = 0.050*2*np.pi
    Kr = 0.3*2*np.pi

    args = {'T_P':t_total,'T_copies':T_copies , 't_start':t_start,'t_end':t_end,'readoutfreq':readoutfreq,'intensity':intensity}
    Hd = [QBE.sm[1].dag()+QBE.sm[1],readoutwave]
    Hdrive = [Hd]

    cops_list = []
    cops = np.sqrt(Kr)*QBE.sm[1]
    cops_list.append(cops)

    qubitstate = (basis(N_level[0],0)+1.5*basis(N_level[0],1)).unit()
    initial_state = tensor(qubitstate , basis(N_level[1],0))
    final = QBE.evolution(drive = Hdrive , psi = initial_state , collapse = [], RWF = 'CpRWF' , RWA_freq = 0 , track_plot = False ,argument = args)

    opx = QBE.X_m[0]
    opy = QBE.Y_m[0]
    opz = QBE.E_g[0]-QBE.E_e[0]
    nx = QBE.expect_evolution(opx);ny = QBE.expect_evolution(opy);nz = QBE.expect_evolution(opz)
    leakage = QBE.expect_evolution(QBE.E_uc[0])
    n1 = QBE.expect_evolution(QBE.sm[1].dag()*QBE.sm[1])
    
    fig,axes = plt.subplots(2,1)
    axes[0].plot(QBE.tlist,nx,label = 'x'+str(0))
    axes[0].plot(QBE.tlist,ny,label = 'y'+str(0))
    axes[0].plot(QBE.tlist,nz,label = 'z'+str(0))
    axes[0].plot(QBE.tlist,leakage,label = 'leakage'+str(0))
    axes[0].set_xlabel('t');axes[0].set_ylabel('population of qubit'+str(0));
    axes[0].legend(loc = 'upper left')
    sphere = Bloch()
    sphere.add_points([nx , ny , nz])
    sphere.add_vectors([nx[-1],ny[-1],nz[-1]])
    sphere.zlabel[0] = 'qubit'+str(0)+'\n$\\left|0\\right>$'
    sphere.make_sphere()

    axes[1].plot(QBE.tlist,n1,label = 'population'+str(1))
    axes[1].set_xlabel('t');axes[1].set_ylabel('population of resonator'+str(1));

    plt.show()
    print(ptrace(final,0))
    print(ptrace(QBE.result.states[-1],0))
    qsave(final,'final_state')