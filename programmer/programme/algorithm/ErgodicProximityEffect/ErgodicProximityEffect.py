from Qubits import Qubits
from qutip import *
import numpy as np
import matplotlib.pyplot as plt
from functools import partial
import random
from multiprocessing import Pool

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
    phi = args_para['phi']
    if t<=0 :
        w = 0
    elif t>0 and t<=t_rise:
        w = delta*(t/t_rise)+h1*np.cos(omega*t+phi)*(t/t_rise)
    elif t>t_rise and t<=t_total-t_rise:
        w = delta+h1*np.cos(omega*t+phi)
    elif t>t_total-t_rise and t<=t_total:
        w = delta/(t_rise)*(t_total-t)+h1*np.cos(omega*t+phi)/(t_rise)*(t_total-t)
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
def OTOC_traveling_wave(t,args,args_para):
    '''
    args:
        t_total
        t_rise
        t_xita
        delta
        h1
        omega
    '''
    t_drive = args_para['t_drive']
    t_rise1 = 2.5
    t_rise2 = 1
    t_xita = args_para['t_xita']
    xita = args_para['xita']
    delta = args_para['delta']
    h1 = args_para['h1']
    omega = args_para['omega']
    phi = args_para['phi']
    if t<=0 :
        w = 0
    elif t>0 and t<=t_rise1:
        w = delta*(t/t_rise1)+h1*np.cos(omega*t+phi)*(t/t_rise1)
    elif t>t_rise1 and t<=t_rise1+t_drive:
        w = delta+h1*np.cos(omega*t+phi)
    elif t>t_rise1+t_drive and t<=2*t_rise1+t_drive:
        w = delta+h1*np.cos(omega*t+phi)/(t_rise1)*(2*t_rise1+t_drive-t)
    elif t>2*t_rise1+t_drive and t<=2*t_rise1+t_rise2+t_drive:
        w = delta+(xita)/(t_rise2)*(t-(2*t_rise1+t_drive))
    elif t>2*t_rise1+t_rise2+t_drive and t<=2*t_rise1+t_rise2+t_drive+t_xita:
        w = (delta+xita)
    elif t>2*t_rise1+t_rise2+t_drive+t_xita and t<=2*t_rise1+2*t_rise2+t_drive+t_xita:
        w = delta+(xita)/(t_rise2)*(2*t_rise1+2*t_rise2+t_drive+t_xita-t)
    elif t>2*t_rise1+2*t_rise2+t_drive+t_xita and t<=3*t_rise1+2*t_rise2+t_drive+t_xita:
        w = delta-h1*np.cos(omega*(t-(2*t_rise1+2*t_rise2+t_drive+t_xita))+phi)*(t-(2*t_rise1+2*t_rise2+t_drive+t_xita))/t_rise1
    elif t>3*t_rise1+2*t_rise2+t_drive+t_xita and t<=3*t_rise1+2*t_rise2+2*t_drive+t_xita:
        w = delta-h1*np.cos(omega*(t-(2*t_rise1+2*t_rise2+t_drive+t_xita))+phi)
    elif t>3*t_rise1+2*t_rise2+2*t_drive+t_xita and t<=4*t_rise1+2*t_rise2+2*t_drive+t_xita:
        w = delta/(t_rise1)*(4*t_rise1+2*t_rise2+2*t_drive+t_xita-t)-h1*np.cos(omega*(t-(2*t_rise1+2*t_rise2+t_drive+t_xita))+phi)/(t_rise1)*(4*t_rise1+2*t_rise2+2*t_drive+t_xita-t)
    elif t>4*t_rise1+2*t_rise2+2*t_drive+t_xita:
        w = 0
    else:
        print('Time Error')
    return(float(w))
def OTOC_stand_wave(t,args,args_para):
    '''
    args:
        t_total
        t_rise
        t_xita
        delta
    '''
    t_drive = args_para['t_drive']
    t_rise1 = 2.
    t_rise2 = 1
    t_xita = args_para['t_xita']
    xita = args_para['xita']
    delta = args_para['delta']
    if t<=0 :
        w = 0
    elif t>0 and t<=t_rise1:
        w = delta*(t/t_rise1)
    elif t>t_rise1 and t<=t_rise1+t_drive:
        w = delta
    elif t>t_rise1+t_drive and t<=2*t_rise1+t_drive:
        w = delta
    elif t>2*t_rise1+t_drive and t<=2*t_rise1+t_rise2+t_drive:
        w = delta+(xita)/(t_rise2)*(t-(2*t_rise1+t_drive))
    elif t>2*t_rise1+t_rise2+t_drive and t<=2*t_rise1+t_rise2+t_drive+t_xita:
        w = (delta+xita)
    elif t>2*t_rise1+t_rise2+t_drive+t_xita and t<=2*t_rise1+2*t_rise2+t_drive+t_xita:
        w = delta+(xita)/(t_rise2)*(2*t_rise1+2*t_rise2+t_drive+t_xita-t)
    elif t>2*t_rise1+2*t_rise2+t_drive+t_xita and t<=3*t_rise1+2*t_rise2+t_drive+t_xita:
        w = delta
    elif t>3*t_rise1+2*t_rise2+t_drive+t_xita and t<=3*t_rise1+2*t_rise2+2*t_drive+t_xita:
        w = delta
    elif t>3*t_rise1+2*t_rise2+2*t_drive+t_xita and t<=4*t_rise1+2*t_rise2+2*t_drive+t_xita:
        w = delta/(t_rise1)*(4*t_rise1+2*t_rise2+2*t_drive+t_xita-t)
    elif t>4*t_rise1+2*t_rise2+2*t_drive+t_xita:
        w = 0
    else:
        print('Time Error')
    return(float(w))
def Drive_Hamiltonian(QBC,frequency_working,t_total,osc,N,):
    Hdrive = []
    drive_pulse = []
    central_point = int(QBC.num_qubits/2)
    for ii in range(QBC.num_qubits):
        if ii < central_point and ii >=0:
            ## Ergodic domain
            delta = frequency_working[ii]-QBC.frequency[ii]
            if osc:
                h1 = N*QBC.coupling[0]*np.cos(2*np.pi*(12-ii)/central_point)
                omega = 2*np.sqrt(8*np.pi**2*N*QBC.coupling[0]*QBC.coupling[0]/central_point**2)/3
            else:
                h1 = 0
                omega = 0
            args = {'t_total':t_total , 't_rise':5 , 'delta':delta , 'h1': h1 , 'omega':omega,'phi':-np.pi/10}
            pulse_shape = partial(traveling_wave , args_para = args)
            drive_pulse.append(pulse_shape)
            Hdrive.append([QBC.sm[ii].dag()*QBC.sm[ii],drive_pulse[ii]])
        elif ii >= central_point and ii <= QBC.num_qubits:
            ## localized domain
            delta = frequency_working[ii]-QBC.frequency[ii]
            args = {'t_total':t_total , 't_rise':5 , 'delta':delta }
            pulse_shape = partial(standing_wave , args_para = args)
            drive_pulse.append(pulse_shape)
            Hdrive.append([QBC.sm[ii].dag()*QBC.sm[ii],drive_pulse[ii]])
        else:
            print('Index Error')
    return(Hdrive)

def Drive_Hamiltonian_OTOC(QBC,frequency_working,ZAmp,t_drive,osc,N,):
    Hdrive = []
    drive_pulse = []
    central_point = int(QBC.num_qubits/2)
    for ii in range(QBC.num_qubits):
        if ii < central_point and ii >=0:
            ## Ergodic domain
            delta = frequency_working[ii]-QBC.frequency[ii]
            if osc:
                h1 = N*QBC.coupling[0]*np.cos(2*np.pi*(12-ii)/central_point)
                omega = 2*np.sqrt(8*np.pi**2*N*QBC.coupling[0]*QBC.coupling[0]/central_point**2)/3
            else:
                h1 = 0
                omega = 0
            args = {'t_drive':t_drive , 'delta':delta , 't_xita':13, 'xita':ZAmp[ii],'h1': h1 , 'omega':omega,'phi':-np.pi/10}
            pulse_shape = partial(OTOC_traveling_wave , args_para = args)
            drive_pulse.append(pulse_shape)
            Hdrive.append([QBC.sm[ii].dag()*QBC.sm[ii],drive_pulse[ii]])
        elif ii >= central_point and ii <= QBC.num_qubits:
            ## localized domain
            delta = frequency_working[ii]-QBC.frequency[ii]
            args = {'t_drive':t_drive , 'delta':delta , 't_xita':13, 'xita':ZAmp[ii], }
            pulse_shape = partial(OTOC_stand_wave , args_para = args)
            drive_pulse.append(pulse_shape)
            Hdrive.append([QBC.sm[ii].dag()*QBC.sm[ii],drive_pulse[ii]])
        else:
            print('Index Error')
    return(Hdrive)

def StateEvolution(qubit_chain , Hdrive , inistate , t_total):
    '''
    the evolution of state
    '''
    args = {'T_P':t_total,'T_copies':2*t_total+1 }
    psi = inistate
    QB = qubit_chain

    c_op_list = []
    T1 = 30000
    T2 = 5000
    n_th = 0.01
    gamma = 1.0/T1
    gamma_phi = 1.0/T2-1/2/T1
    for ii in range(QB.num_qubits):
        c_op_list.append(np.sqrt(gamma * (1+n_th)) * QB.sm[ii])
        c_op_list.append(np.sqrt(gamma * n_th) * QB.sm[ii].dag())
        c_op_list.append(np.sqrt(2*gamma_phi) * QB.sm[ii].dag()*QB.sm[ii])

    finalstate = QB.evolution(drive = Hdrive , psi = psi , collapse = [], track_plot = False , RWF = 'NoRWF',argument = args )

    return(QB)

def initialstate(QBC,excitation = [0]):
    psi = []
    num_qubits = QBC.num_qubits
    for ii in range(num_qubits):
        if ii in excitation:
            psi.append(basis(QBC.N_level[ii],1))
        else:
            psi.append(basis(QBC.N_level[ii],0))
    psi = tensor(*psi)
    return(psi)

def plot_evolution(QB,correlator,note):
    tlist = QBC.tlist[5:-5]
    tlist = tlist-tlist[0]
    qlist = [ii+1 for ii in range(QBC.num_qubits)]
    correaltion_list = [ii for ii in range(QBC.num_qubits)];correaltion_list.remove(correlator)
    '''
    Projection on Z
    '''
    Zlist = np.zeros([len(qlist),len(tlist)])
    for ii in range(len(qlist)):
        Zlist[ii] = QB.expect_evolution(QB.sm[ii].dag()*QB.sm[ii])[5:-5]
    x,y = np.meshgrid(np.r_[qlist,qlist[-1]+1],tlist)
    # x,y = np.meshgrid(qlist,tlist)
    plt.figure()
    plt.pcolor(x,y,np.transpose(Zlist),cmap='jet')
    plt.title('population_'+note)
    plt.colorbar()
    plt.xlabel('qubit');plt.ylabel('time(ns)')
    plt.xticks([i+2 for i in range(len(qlist))],[str(x) for x in qlist])
    plt.savefig('./result/population_'+str(note))
    
    '''
    spatial correlations
    '''

    XYcorrelation_list = np.zeros([len(correaltion_list),len(tlist)])
    for ii in range(len(correaltion_list)):
        XYcorrelation_list[ii] = QB.expect_evolution(QB.X_m[correlator]*QB.X_m[correaltion_list[ii]]+QB.Y_m[correlator]*QB.Y_m[correaltion_list[ii]])[5:-5]
    x,y = np.meshgrid(np.r_[qlist[1:],qlist[-1]+1],tlist)
    plt.figure()
    
    plt.pcolor(x,y,np.transpose(XYcorrelation_list),cmap='jet')
    
    plt.title('XYcorrelation_'+note)
    plt.colorbar()
    plt.xlabel('qubit');plt.ylabel('time(ns)')
    plt.xticks([i+2 for i in range(len(correaltion_list))],[str(x+1) for x in correaltion_list])
    plt.savefig('./result/XYcorrelation_'+str(note))

    '''
    ZZ correlations
    '''
    ZZcorrelation_list = np.zeros([len(qlist)-1,len(tlist)])
    for ii in range(len(qlist)-1):
        ZZcorrelation_list[ii] = (QB.expect_evolution((QB.E_g[correlator]-QB.E_e[correlator])*(QB.E_g[correaltion_list[ii]]-QB.E_e[correaltion_list[ii]]))-QB.expect_evolution((QB.E_g[correlator]-QB.E_e[correlator]))*QB.expect_evolution((QB.E_g[correaltion_list[ii]]-QB.E_e[correaltion_list[ii]])))[5:-5]
    x,y = np.meshgrid(np.r_[qlist[1:],qlist[-1]+1],tlist)
    plt.figure()
    
    plt.pcolor(x,y,np.transpose(ZZcorrelation_list),cmap='jet')
    
    plt.title('ZZcorrelation_'+note)
    plt.colorbar()
    plt.xlabel('qubit');plt.ylabel('time(ns)')
    plt.xticks([i+2 for i in range(len(correaltion_list))],[str(x+1) for x in correaltion_list])
    plt.savefig('./result/ZZcorrelation_'+str(note))
    
    savefilename = './result/'+str(note)+'.npz'
    np.savez(savefilename,Zlist = Zlist,XYcorrelation_list=XYcorrelation_list,ZZcorrelation_list = ZZcorrelation_list)
    
    # plt.show()
    return([Zlist,XYcorrelation_list,ZZcorrelation_list])
def plot_evolution_OTOC(QB,note):
    tlist = QBC.tlist
    qlist = [ii+1 for ii in range(QBC.num_qubits)]

    '''
    OTOC
    '''
    OTOClist = np.zeros([len(qlist),len(tlist)])
    for ii in range(len(qlist)):
        OTOClist[ii] = QB.expect_evolution(QB.sm[ii].dag()*QB.sm[ii])
    x,y = np.meshgrid(np.r_[qlist,qlist[-1]+1],tlist)
    # x,y = np.meshgrid(qlist,tlist)
    plt.figure()
    plt.pcolor(x,y,np.transpose(OTOClist),cmap='jet')
    plt.title('OTOClist_'+note)
    plt.colorbar()
    plt.xlabel('time(ns)');plt.ylabel('qubit')
    plt.savefig('./result/OTOClist_'+str(note))
    
    
    plt.show()
    return([OTOClist])
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
    return()

def ErgodicEffect(QBC , excitation, frequency_working,t_total ,correlator, osc , note , N ):
    ini_state = initialstate(QBC , excitation)
    Hdrive = Drive_Hamiltonian(QBC,frequency_working,t_total , osc , N)
    QB = StateEvolution(QBC , Hdrive , ini_state , t_total)

    central_point = int(QBC.num_qubits/2)
    omega = 2*np.sqrt(8*np.pi**2*QBC.coupling[0]**2/central_point**2)
    T = 2*np.pi/omega

    data_list = plot_evolution(QB,correlator,note)
    # plot_tlist = np.linspace(0,t_total,)
    return(data_list)
def ErgodicEffect_OTOC_single(QBC , excitation, frequency_working,ZAmp,t_drive , osc ,note,N ):
    ini_state = initialstate(QBC , excitation)
    Hdrive = Drive_Hamiltonian_OTOC(QBC,frequency_working ,ZAmp, t_drive  , osc , N)
    QB = StateEvolution(QBC , Hdrive , ini_state , 4*2.5+2*1+2*t_drive+13)

    # Zgate_list = []
    # for ii in range(len(xita_list)):
    #     Zgate_list.append(Qobj([[1,0],[0,np.exp(1j*1)]]))

    OTOClist = np.zeros(QBC.num_qubits)
    for ii in range(QBC.num_qubits):
        OTOClist[ii] = QB.expect_evolution(QB.sm[ii].dag()*QB.sm[ii])[-1]
    data_list = plot_evolution_OTOC(QB,note)
    plt_waveform(QB,note)
    # plot_tlist = np.linspace(0,t_total,)
    return(OTOClist)
def ErgodicEffect_OTOC(QBC , excitation, frequency_working,ZAmp,t_drive , t_xita ,  osc , note , N ):
    qlist = [ii+1 for ii in range(QBC.num_qubits)]
    tlist = np.linspace(0,t_drive,41)
    '''
    OTOC
    '''
    p = Pool()
    result = []
    for i in range(len(tlist)):
        result.append(p.apply_async(ErgodicEffect_OTOC_single,(QBC , excitation, frequency_working,ZAmp,tlist[i] ,  2 , osc ,note,N )))
    OTOClist = np.array([result[i].get() for i in range(len(result))])
    OTOClist = np.transpose(OTOClist)
    p.close()
    p.join()

    # ErgodicEffect_OTOC_single(QBC , excitation, frequency_working, ZAmp ,t_drive , osc ,N )
    x,y = np.meshgrid(tlist,np.r_[qlist,qlist[-1]+1])
    # x,y = np.meshgrid(qlist,tlist)
    plt.figure()
    plt.pcolor(x,y,OTOClist,cmap='jet')
    plt.title('OTOClist_'+note)
    plt.colorbar()
    plt.xlabel('time(ns)');plt.ylabel('qubit')
    plt.savefig('./result/OTOClist_'+str(note))

    # plt.show()
    return(OTOClist)

def frequency_working_setup(frequency_working,disorder):
    size = np.size(frequency_working)
    for ii in range(int(size/2),size):
        frequency_working[ii] = frequency_working[ii]+random.uniform(-disorder,disorder)
    return(frequency_working)
    
if  __name__ == '__main__':
    Num_qubits = 12
    frequency = np.array([3.9750 ,	4.50500 ,	4.07000 ,	4.54800 ,	4.03000 ,	4.66400 ,	3.96400 ,	4.46000 ,	4.00400 ,	4.50000 ,	4.06000 ,	4.57000  ])* 2*np.pi
    coupling = np.ones(Num_qubits-1) * 0.0115 * 2*np.pi
    eta_q=  np.ones(Num_qubits) * (-0.25) * 2*np.pi
    N_level= 2
    parameter = [frequency,coupling,eta_q,N_level]
    QBC = Qubits(qubits_parameter = parameter)

    # frequency_working = np.array([4.43650 ,	4.42855 ,	4.41570 ,	4.41570 ,	4.42855 ,	4.43650 ,	4.42855 ,	4.41570 ,	4.41570 ,	4.42855 ])* 2*np.pi
    # # frequency_working = np.array([4.43650 ,	4.42855 ,	4.41570 ,	4.41570 ,	4.42855 ,	4.43082 ,	4.40897 ,	4.45854 ,	4.41848 ,	4.39802 ])* 2*np.pi
    # frequency_working = np.array([4.43650 ,	4.42855 ,	4.41570 ,	4.41570 ,	4.42855 ,	4.42504 ,	4.40879 ,	4.50660 ,	4.33894 ,	4.37505 ])* 2*np.pi
    
    N = 3
    h0 = N*coupling[0]
    frequency_working = (4.335)*2*np.pi+h0*np.cos(2*np.pi*(12-np.arange(12))/6)
    frequency_working = np.array([4.3695 ,	4.35225 ,	4.31775 , 4.30050 ,	4.31775 ,	4.35225 ,	4.3695,	4.3235,	4.32695,	4.27300 ,	4.35400 ,	4.3010  ])* 2*np.pi
    # frequency_working = np.array([4.3695 ,	4.35225 ,	4.31775 ,	4.30050 ,	4.31775 ,	4.35225 ,	4.37025 ,	4.21300 ,	4.40900 ,	4.27100 ,	4.21400 ,	4.2810 ])* 2*np.pi
    # frequency_working = frequency_working_setup(frequency_working,5*coupling[0])
    # frequency_working = frequency_working_setup(frequency_working,10*coupling[0])

    # plt.figure();plt.plot(frequency_working/2/np.pi);plt.savefig('./result/frequency_working_No');plt.show()

    parameter = [frequency_working,coupling,eta_q,N_level]
    QB = Qubits(qubits_parameter = parameter)
    # frequency_working = (4.335)*2*np.pi+h0*np.cos(2*np.pi*(12-np.arange(12))/6)
    frequency_working = np.ones(12)*4.298*10**9
    for excitation in [9]:
        t_total = 110
        # t_xita = 30
        excitation = [excitation]
        correlator = 6
        note = 'No disorder, N =  '+str(N)+',excitation='+str(excitation[0]+1)+',correlator='+str(correlator+1)
        data_list = ErgodicEffect(QBC , excitation , frequency_working,t_total,correlator = correlator , osc = False , note = note , N = N)
        plt_waveform(QBC,note = note)

    # frequency_working = np.array([4.3695 ,	4.35225 ,	4.31775 , 4.30050 ,	4.31775 ,	4.35225 ,	4.3695,	4.3235,	4.32695,	4.27300 ,	4.35400 ,	4.3010  ])* 2*np.pi

    # for excitation in [1]:
    #     t_total = 210
    #     # t_xita = 30
    #     excitation = [excitation]
    #     correlator = 6
    #     note = 'Moderate disorder, N =  '+str(N)+',excitation='+str(excitation[0]+1)+',correlator='+str(correlator+1)
    #     data_list = ErgodicEffect(QBC , excitation , frequency_working,t_total,correlator = correlator , osc = True , note = note , N = N)
    #     plt_waveform(QBC,note = note)

    # frequency_working = np.array([4.3695 ,	4.35225 ,	4.31775 ,	4.30050 ,	4.31775 ,	4.35225 ,	4.37025 ,	4.21300 ,	4.40900 ,	4.27100 ,	4.21400 ,	4.2810 ])* 2*np.pi

    # for excitation in [1]:
    #     t_total = 210
    #     # t_xita = 30
    #     excitation = [excitation]
    #     correlator = 6
    #     note = 'Strong disorder, N =  '+str(N)+',excitation='+str(excitation[0]+1)+',correlator='+str(correlator+1)
    #     data_list = ErgodicEffect(QBC , excitation , frequency_working,t_total,correlator = correlator , osc = True , note = note , N = N)
    #     plt_waveform(QBC,note = note)


    # pi = np.pi
    # excitation = [5]
    # note = 'j = 6,No disorder  With Osc N =  '+str(N)+',excitation='+str(excitation[0]+1)+',t_xita='+str(15)
    # TargetPhase = np.array([2*pi,-3*pi,4*pi,-3*pi,2*pi,-3*pi,6*pi,-pi,6*pi,-5*pi,2*pi,-3*pi])
    # ZAmp = TargetPhase/(-15.0)
    # # ZAmp = np.array([-0.062415696716072 ,  0.122537354380784 , -0.134373411112656  , 0.117378648740031 , -0.064363781459242  , 0.156914016028379 , -0.162927383267175 , 0.044216812699949 , -0.201286696595737 ,  0.194024995971759 , -0.056849629849301 ,  0.151930816207425])*2*np.pi
    # ErgodicEffect_OTOC_single(QBC , excitation, frequency_working, ZAmp ,50 , osc = True , note = note , N = N)

    
    # note = 'j = 6,No disorder  With Osc N =  '+str(N)+',excitation='+str(excitation+1)+',t_xita='+str(15)
    # data_list = ErgodicEffect_OTOC(QBC , excitation , frequency_working,t_total ,t_xita, osc = True ,  note = note , N = N)
    # plt_waveform(QBC,note = note)
    