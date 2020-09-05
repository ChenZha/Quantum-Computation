
import numpy as np
from functools import partial
from Qubits import Qubits
from qutip import *
from multiprocessing import Pool
import matplotlib.pyplot as plt
import copy
from scipy.linalg import sqrtm
from scipy.optimize import *
import scipy.io as scio
from scipy.linalg import expm
from multiprocessing import Pool

def I_drive(t,args):
    ## 0.07853982  X/2
    ## 复数形式的输入电流 加drive
    tp = args['T_P']
    omega = args['omegaI']
    phi = args['phiI']
    wf = args['wf']
    eta_q = args['eta_q']
    D = -0.5
    if t<0 or t>tp:
        w = 0
    else:
        # w = omega*((1-np.cos(2*np.pi/tp*t))*np.exp(1j*(wf*t-phi)))
        w = omega*((1-np.cos(2*np.pi/tp*t))*np.exp(1j*(wf*t-phi)))+omega*D*(2*np.pi/tp)*np.sin(2*np.pi/tp*t)/(eta_q[0])*np.exp(1j*(t*wf-phi-np.pi/2))
    return(w) 

def phix_drive(t,args,Mx):
    hbar=1.054560652926899*10**(-34);
    h = hbar*2*np.pi;
    e = 1.60217662*10**(-19); 
    phi0 = h/2/e

    II = I_drive(t,args)
    phix = 2*np.pi/phi0*Mx*II
    return(np.real(phix)) 
def I_cross(t,args):
    ## 0.07853982  X/2
    ## 复数形式的输入电流 串扰到比特的crosstalk
    tp = args['T_P']
    omega = args['omega_cross']
    phi = args['phi_cross']
    wf = args['wf_cross']
    eta_q = args['eta_q']
    D = -0.5
    if t<0 or t>tp:
        w = 0
    else:
        # w = omega*((1-np.cos(2*np.pi/tp*t))*np.exp(1j*(wf*t-phi)))
        w = omega*((1-np.cos(2*np.pi/tp*t))*np.exp(1j*(wf*t-phi)))+omega*D*(2*np.pi/tp)*np.sin(2*np.pi/tp*t)/(eta_q[0])*np.exp(1j*(t*wf-phi-np.pi/2))
    return(w) 
def phix_cross(t,args,Mx):
    hbar=1.054560652926899*10**(-34);
    h = hbar*2*np.pi;
    e = 1.60217662*10**(-19); 
    phi0 = h/2/e

    II = I_cross(t,args)
    phix = 2*np.pi/phi0*Mx*II
    return(np.real(phix)) 
def getfid(P , limit = np.Infinity):
    Ec = 0.240 * 2 * np.pi
    Ej = 20 * 2 * np.pi
    phi_s = np.pi*0.00

    el = EL_qubit(Ej,Ec,phi_s)

    frequency = np.array([el[1]-el[0]])
    coupling = np.array([])*2*np.pi
    eta_q=  np.array([(el[2]-el[1])-(el[1]-el[0])]) 
    N_level= 3
    parameter = [frequency,coupling,eta_q,N_level]
    QB = Qubits(qubits_parameter = parameter)

    phi = (2*Ec/Ej/np.cos(phi_s))**(1/4)*(QB.sm[0].dag()+QB.sm[0])
    nn = 1j*(Ej*np.cos(phi_s)/2/Ec)**(1/4)*(QB.sm[0].dag()-QB.sm[0])/2
    cos_phi = -phi**2/2+phi**4/24
    sin_phi = phi-phi**3/6
    
    ## 电感驱动
    Mx = 0.1*10**(-12)
    Mz = 1.7*10**(-12)    

    driveX = partial(phix_drive,Mx = Mx)
    H1 = [Ej*np.cos(phi_s)*sin_phi,driveX] 
    Hdrive = [H1]

    X = np.array([[0,1],[1,0]])
    Y = np.array([[0,-1j],[1j,0]])
    phi_x = 0
    gate =  expm(-1j*np.pi/4*(np.cos(phi_x)*X+np.sin(phi_x)*Y))

    args = {'T_P':25,'T_copies':51 , 'omegaI':P[0] ,'phiI':0, 'wf': P[1],'eta_q':eta_q}
    process = QB.process(drive = Hdrive, process_plot  = False , RWF = 'UnCpRWF' , RWA_freq = 0.0 ,parallel = True ,argument = args)
    Ufidelity = np.abs(np.trace(np.dot(np.conjugate(np.transpose(gate)),process)))/(2**QB.num_qubits)
    # print(process)
    print(P)
    print(Ufidelity)

    return(1-Ufidelity)

def getfid_cross(omega_cross, wf_cross, limit = np.Infinity):
    Ec = 0.240 * 2 * np.pi
    Ej = 20 * 2 * np.pi
    phi_s = np.pi*0.00

    el = EL_qubit(Ej,Ec,phi_s)

    frequency = np.array([el[1]-el[0]])
    coupling = np.array([])*2*np.pi
    eta_q=  np.array([(el[2]-el[1])-(el[1]-el[0])]) 
    N_level= 3
    parameter = [frequency,coupling,eta_q,N_level]
    QB = Qubits(qubits_parameter = parameter)

    phi = (2*Ec/Ej/np.cos(phi_s))**(1/4)*(QB.sm[0].dag()+QB.sm[0])
    nn = 1j*(Ej*np.cos(phi_s)/2/Ec)**(1/4)*(QB.sm[0].dag()-QB.sm[0])/2
    cos_phi = -phi**2/2+phi**4/24
    sin_phi = phi-phi**3/6
    
    ## 单比特驱动参数 驱动强度4.53561162e-06 驱动频率3.73621365e+01 
    ## 电感驱动
    Mx = 0.1*10**(-12)
    Mz = 1.7*10**(-12)    
    driveX = partial(phix_drive,Mx = Mx)
    H1 = [Ej*np.cos(phi_s)*sin_phi,driveX] 
    crossX = partial(phix_cross,Mx = Mx)
    H2 = [Ej*np.cos(phi_s)*sin_phi,crossX] 
    Hdrive = [H1,H2]

    X = np.array([[0,1],[1,0]])
    Y = np.array([[0,-1j],[1j,0]])
    phi_x = 0
    gate =  expm(-1j*np.pi/4*(np.cos(phi_x)*X+np.sin(phi_x)*Y))

    omegaI = 4.53561162e-06
    wf = 3.73621365e+01 

    # omega_cross = P[0]
    # wf_cross = P[1]

    args = {'T_P':25,'T_copies':51 , 'omegaI':omegaI ,'phiI':0,'wf': wf,'omega_cross':omega_cross,'phi_cross':0,'wf_cross':wf_cross,'eta_q':eta_q}
    process = QB.process(drive = Hdrive, process_plot  = False , RWF = 'UnCpRWF' , RWA_freq = 0.0 ,parallel = False ,argument = args)
    Ufidelity = np.abs(np.trace(np.dot(np.conjugate(np.transpose(gate)),process)))/(2**QB.num_qubits)
    return(Ufidelity)

def EL_qubit(Ej,Ec,phi_s):
    # phi_s偏置下的比特频率
    N =180
    H = 4*Ec*np.diag(np.arange(-N,N+1,1)**2)-Ej/2*np.cos(phi_s)*(np.diag(np.ones(2*N),1)+np.diag(np.ones(2*N),-1))
    el = np.linalg.eig(H)
    el = np.sort(el[0])
    return(el)


if __name__ == '__main__':

    # Ec = 0.240 * 2 * np.pi
    # Ej = 20 * 2 * np.pi
    # phi_s = np.pi*0.00

    # el = EL_qubit(Ej,Ec,phi_s)

    # frequency = np.array([el[1]-el[0]])
    # coupling = np.array([])*2*np.pi
    # eta_q=  np.array([(el[2]-el[1])-(el[1]-el[0])]) 
    # N_level= 3
    # parameter = [frequency,coupling,eta_q,N_level]
    # QB = Qubits(qubits_parameter = parameter)

    # phi = (2*Ec/Ej/np.cos(phi_s))**(1/4)*(QB.sm[0].dag()+QB.sm[0])
    # nn = 1j*(Ej*np.cos(phi_s)/2/Ec)**(1/4)*(QB.sm[0].dag()-QB.sm[0])/2
    # cos_phi = -phi**2/2+phi**4/24
    # sin_phi = phi-phi**3/6
    
    # ## 单比特驱动参数 驱动强度4.53561162e-06 驱动频率3.73621365e+01 
   

    # ## 电感驱动
    # Mx = 0.1*10**(-12)
    # Mz = 1.7*10**(-12)    

    # driveX = partial(phix_drive,Mx = Mx)
    # H1 = [Ej*np.cos(phi_s)*sin_phi,driveX] 
    # crossX = partial(phix_cross,Mx = Mx)
    # H2 = [Ej*np.cos(phi_s)*sin_phi,crossX] 
    # Hdrive = [H1,H2]

    # X = np.array([[0,1],[1,0]])
    # Y = np.array([[0,-1j],[1j,0]])
    # phi_x = 0
    # gate =  expm(-1j*np.pi/4*(np.cos(phi_x)*X+np.sin(phi_x)*Y))

    # omegaI = 4.53561162e-06
    # wf = 3.73621365e+01 


    # omega_cross = 2*4.53561162e-06
    # wf_cross = 3.73621365e+01

    # args = {'T_P':25,'T_copies':51 , 'omegaI':omegaI ,'phiI':0,'wf': wf,'omega_cross':omega_cross,'phi_cross':0,'wf_cross':wf_cross,'eta_q':eta_q}
    # process = QB.process(drive = Hdrive, process_plot  = False , RWF = 'UnCpRWF' , RWA_freq = 0.0 ,parallel = True ,argument = args)
    # Ufidelity = np.abs(np.trace(np.dot(np.conjugate(np.transpose(gate)),process)))/(2**QB.num_qubits)
    # print(Ufidelity)

    omegaI = 4.53561162e-06
    wf = 3.73621365e+01

    attenuator = np.linspace(20,45,26)
    omega_cross_list = omegaI*10**(-attenuator/20)
    detuning_list = np.linspace(0,60,31)
    wf_cross_list = wf-detuning_list/1000*2*np.pi
    fid_list = np.zeros([len(omega_cross_list),len(wf_cross_list)])

    p = Pool()
    for ii in range(len(omega_cross_list)):
        result = []
        for jj in range(len(wf_cross_list)):
            result.append(p.apply_async(getfid_cross,(omega_cross_list[ii],wf_cross_list[jj])))
        fid_list[ii] = np.array([result[i].get() for i in range(len(result))])

    p.close()
    p.join()
    
    scio.savemat('single_crosstalk.mat',mdict = {'attenuator':attenuator,'detuning_list':detuning_list,'fid_list':fid_list})

    xx, yy =np.meshgrid(detuning_list, attenuator)
    plt.figure()
    plt.contourf(xx, yy,(1-fid_list)*1000)
    plt.xlabel('detunning')
    plt.ylabel('attenuator')
    plt.colorbar()
    plt.show()





    # # np.savez('M_single',omega_list,fid_omega_list,w_list,fid_w_list)
    # scio.savemat('C_single.mat',mdict = {'omega_list':omega_list,'fid_omega_list':fid_omega_list,'w_list':w_list,'fid_w_list':fid_w_list})
    # plt.show()



    # # NM算法
    # P = [6.11269480e-06,frequency[0]]
    # func = getfid
    # result = minimize(func, P, method="Nelder-Mead",options={'disp': True})
    # print(result)