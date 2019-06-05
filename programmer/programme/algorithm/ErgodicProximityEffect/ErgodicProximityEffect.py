from Qubits import Qubits
from qutip import *
import numpy as np
import matplotlib.pyplot as plt
from functools import partial
import random

def traveling_wave(t,args,args_para):
    '''
    args:
        t_total
        t_rise
        delta
        h1
        omega
    '''
    t_total = args_para['t_total']
    t_rise = args_para['t_rise']
    delta = args_para['delta']
    h1 = args_para['h1']
    omega = args_para['omega']
    if t<=0 :
        w = 0
    elif t>0 and t<=t_rise:
        w = delta*(t/t_rise)
    elif t>t_rise and t<=t_total-t_rise:
        w = delta+h1*np.cos(omega*t)
    elif t>t_total-t_rise and t<=t_total:
        w = delta/(t_rise)*(t_total-t)
    elif t>t_total:
        w = 0
    else:
        print('Time Error')
    return(float(w))
def standing_wave(t,args,args_para):
    '''
    args:
        t_total
        t_rise
        delta
    '''
    t_total = args_para['t_total']
    t_rise = args_para['t_rise']
    delta = args_para['delta']
    if t<=0 :
        w = 0
    elif t>0 and t<=t_rise:
        w = delta*(t/t_rise)
    elif t>t_rise and t<=t_total-t_rise:
        w = delta
    elif t>t_total-t_rise and t<=t_total:
        w = delta/(t_rise)*(t_total-t)
    elif t>t_total:
        w = 0
    else:
        print('Time Error')
    return(float(w))
def Drive_Hamiltonian(QBC,frequency_working,t_total,N,):
    Hdrive = []
    drive_pulse = []
    central_point = int(QBC.num_qubits/2)
    for ii in range(QBC.num_qubits):
        if ii < central_point and ii >=0:
            ## Ergodic domain
            delta = frequency_working[ii]-QBC.frequency[ii]
            h1 = N*QBC.coupling[0]*np.cos(2*np.pi*(10-ii)/central_point)
            omega = 2*np.sqrt(8*np.pi**2*N*coupling[0]*QBC.coupling[0]/central_point**2)
            args = {'t_total':t_total , 't_rise':1 , 'delta':delta , 'h1': h1 , 'omega':omega}
            pulse_shape = partial(traveling_wave , args_para = args)
            drive_pulse.append(pulse_shape)
            Hdrive.append([QBC.sm[ii].dag()*QBC.sm[ii],drive_pulse[ii]])
        elif ii >= central_point and ii <= QBC.num_qubits:
            ## localized domain
            delta = frequency_working[ii]-QBC.frequency[ii]
            args = {'t_total':t_total , 't_rise':1 , 'delta':delta }
            pulse_shape = partial(standing_wave , args_para = args)
            drive_pulse.append(pulse_shape)
            Hdrive.append([QBC.sm[ii].dag()*QBC.sm[ii],drive_pulse[ii]])
        else:
            print('Index Error')
    


    return(Hdrive)

def StateEvolution(qubit_chain , Hdrive , inistate , t_total):
    '''
    the evolution of state
    '''
    args = {'T_P':t_total,'T_copies':t_total+1 }
    psi = inistate
    QB = qubit_chain

    finalstate = QB.evolution(drive = Hdrive , psi = psi ,  track_plot = False , RWF = 'CpRWF',argument = args )

    return(QB)

def initialstate(QBC):
    psi = []
    num_qubits = QBC.num_qubits
    for ii in range(num_qubits):
        if ii == int(num_qubits/2)-1:
            psi.append(basis(QBC.N_level[ii],1))
        else:
            psi.append(basis(QBC.N_level[ii],0))
    psi = tensor(*psi)
    return(psi)

def plot_evolution(QB,note):
    tlist = QBC.tlist
    qlist = [ii+1 for ii in range(QBC.num_qubits)]

    '''
    Projection on Z
    '''
    Zlist = np.zeros([len(qlist),len(tlist)])
    for ii in range(len(qlist)):
        Zlist[ii] = QB.expect_evolution(QB.sm[ii].dag()*QB.sm[ii])
    x,y = np.meshgrid(tlist,np.r_[qlist,qlist[-1]+1])
    # x,y = np.meshgrid(qlist,tlist)
    plt.figure()
    plt.pcolor(x,y,Zlist)
    plt.title('population_'+note)
    plt.colorbar()
    plt.xlabel('time(ns)');plt.ylabel('qubit')
    plt.savefig('./result/population_'+str(note))
    
    '''
    spatial correlations
    '''
    XYcorrelation_list = np.zeros([len(qlist)-1,len(tlist)])
    for ii in range(len(qlist)-1):
        XYcorrelation_list[ii] = QB.expect_evolution(QB.X_m[-1]*QB.X_m[ii]+QB.Y_m[-1]*QB.Y_m[ii])
    x,y = np.meshgrid(tlist,np.r_[qlist[1:],qlist[-1]+1])
    plt.figure()
    plt.pcolor(x,y,XYcorrelation_list)
    plt.title('XYcorrelation_'+note)
    plt.colorbar()
    plt.xlabel('time(ns)');plt.ylabel('qubit')
    plt.savefig('./result/XYcorrelation_'+str(note))

    '''
    ZZ correlations
    '''
    ZZcorrelation_list = np.zeros([len(qlist)-1,len(tlist)])
    for ii in range(len(qlist)-1):
        ZZcorrelation_list[ii] = QB.expect_evolution((QB.E_g[-1]-QB.E_e[-1])*(QB.E_g[ii]-QB.E_e[ii]))-QB.expect_evolution((QB.E_g[-1]-QB.E_e[-1]))*QB.expect_evolution((QB.E_g[ii]-QB.E_e[ii]))
    x,y = np.meshgrid(tlist,np.r_[qlist[1:],qlist[-1]+1])
    plt.figure()
    plt.pcolor(x,y,ZZcorrelation_list)
    plt.title('ZZcorrelation_'+note)
    plt.colorbar()
    plt.xlabel('time(ns)');plt.ylabel('qubit')
    plt.savefig('./result/ZZcorrelation_'+str(note))
    

    
    # plt.show()
    return([Zlist,XYcorrelation_list,ZZcorrelation_list])
def plt_waveform(QBC,note):
    fig,axes = plt.subplots(1,1)
    tlist  = QBC.tlist
    drive_pulse = [A[1] for A in QBC.H[1:]]
    args = {'T_P':QBC.tlist[-1],'T_copies':QBC.tlist[-1]+1 }
    for ii in range(len(drive_pulse)):
        axes.plot(tlist,(QBC.frequency[ii]+np.vectorize((drive_pulse[ii]))(tlist,args))/2/np.pi,label = 'q'+str(ii))

    handles, labels = plt.gca().get_legend_handles_labels()
    plt.legend(handles,labels)
    plt.xlabel('time(ns)');plt.ylabel('frequency(GHz)');plt.title('waveform_'+note)
    plt.savefig('./result/waveform_'+str(note))
    plt.show()

def ErgodicEffect(QBC,frequency_working,t_total,note , N ):
    ini_state = initialstate(QBC)
    Hdrive = Drive_Hamiltonian(QBC,frequency_working,t_total , N)
    QB = StateEvolution(QBC , Hdrive , ini_state , t_total)

    central_point = int(QBC.num_qubits/2)
    omega = 2*np.sqrt(8*np.pi**2*QBC.coupling[0]**2/central_point**2)
    T = 2*np.pi/omega

    data_list = plot_evolution(QB,note)
    # plot_tlist = np.linspace(0,t_total,)
    return(data_list)


    
if  __name__ == '__main__':
    Num_qubits = 10
    frequency = np.array([4.08996 ,	4.58001 ,	4.00001 ,	4.61999 ,	3.93988 ,	4.44001 ,	4.04027 ,	4.63499 ,	3.95999 ,	4.39998  ])* 2*np.pi
    coupling = np.ones(Num_qubits-1) * 0.0115 * 2*np.pi
    eta_q=  np.ones(Num_qubits) * (-0.25) * 2*np.pi
    N_level= 2
    parameter = [frequency,coupling,eta_q,N_level]
    QBC = Qubits(qubits_parameter = parameter)

    # frequency_working = np.array([4.43650 ,	4.42855 ,	4.41570 ,	4.41570 ,	4.42855 ,	4.43650 ,	4.42855 ,	4.41570 ,	4.41570 ,	4.42855 ])* 2*np.pi
    # # frequency_working = np.array([4.43650 ,	4.42855 ,	4.41570 ,	4.41570 ,	4.42855 ,	4.43082 ,	4.40897 ,	4.45854 ,	4.41848 ,	4.39802 ])* 2*np.pi
    # frequency_working = np.array([4.43650 ,	4.42855 ,	4.41570 ,	4.41570 ,	4.42855 ,	4.42504 ,	4.40879 ,	4.50660 ,	4.33894 ,	4.37505 ])* 2*np.pi
    
    N = 1
    h0 = N*coupling[0]
    frequency_working = (4.425)*2*np.pi+h0*np.cos(2*np.pi*(10-np.arange(10))/5)
    # frequency_working = (4.425)*2*np.pi+h0*np.cos(2*np.pi*(10-np.arange(10))/5)+random.uniform(-5*coupling[0],5*coupling[0])
    # frequency_working = (4.425)*2*np.pi+h0*np.cos(2*np.pi*(10-np.arange(10))/5)+random.uniform(-10*coupling[0],10*coupling[0])

    t_total = 500
    note = 'No disorder With Osc N = 1'
    data_list = ErgodicEffect(QBC,frequency_working,t_total,note = note,N = N)
    plt_waveform(QBC,note = note)
    