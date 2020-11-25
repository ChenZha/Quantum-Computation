
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


def X_drive(t,args,phi):
    ## 0.07853982  X/2
    tp = args['T_P']
    omega = args['omega']
    wf = args['wf']
    D = 0.5
    eta_q = args['eta_q']
    if t<0 or t>tp:
        w = 0
    else:
        # w = omega*((1-np.cos(2*np.pi/tp*t))*np.cos(wf*t-phi))
        w = omega*((1-np.cos(2*np.pi/tp*t))*np.cos(wf*t-phi))+D*omega*(2*np.pi/tp)*np.sin(2*np.pi/tp*t)/(eta_q[0])*np.cos(t*wf-phi-np.pi/2)
    return(w) 
def Y_drive(t,args):
    ## 0.07853982  Y/2
    tp = args['T_P']
    omega = args['omega']
    
    wf = args['wf']

    if t<0 or t>tp:
        w = 0
    else:
        w = omega*((1-np.cos(2*np.pi/tp*t))*np.cos(wf*t-np.pi/2))
    return(w)
def Z_drive(t,args,phiZ,frequency_sweet,phi0):
    ## 0.07853982  X/2
    tp = args['T_P']
    omega = args['omegaZ']
    wf = args['wf']
    D = -0.5
    eta_q = args['eta_q']
    if t<0 or t>tp:
        w = 0
    else:
        # w = omega*((1-np.cos(2*np.pi/tp*t))*np.cos(wf*t-phiZ))
        w = frequency_sweet*np.sqrt(np.cos(np.pi*(phi0+omega*((1-np.cos(2*np.pi/tp*t))*np.cos(wf*t-phiZ))+D*omega*(2*np.pi/tp)*np.sin(2*np.pi/tp*t)/(eta_q[0])*np.cos(t*wf-phiZ-np.pi/2))))-frequency_sweet*np.sqrt(np.cos(np.pi*phi0))
    return(w) 
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
def I_drive_real(t,args):
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
    return(np.real(w)) 
def I_pulse(t,args):
    ## 0.07853982  X/2
    ## 复数形式的输入电流 加pulse
    tp = args['T_P']
    omega = args['omegaI']
    
    if t<0 or t>tp:
        w = 0
    elif t>0 and t<3:
        w = omega/3*t
    elif t>tp-3 and t<tp:
        w = omega/3*(tp-t)
    else:
        w = omega
    return(w) 
def phix_drive(t,args,Mx):
    hbar=1.054560652926899*10**(-34);
    h = hbar*2*np.pi;
    e = 1.60217662*10**(-19); 
    phi0 = h/2/e

    II = I_drive(t,args)
    phix = 2*np.pi/phi0*Mx*II
    return(np.real(phix)) 

def phiz_drive(t,args,Mz):
    ## 0.07853982  X/2
    hbar=1.054560652926899*10**(-34);
    h = hbar*2*np.pi;
    e = 1.60217662*10**(-19); 
    phi0 = h/2/e

    II = I_drive(t,args)
    phiz = np.pi/phi0*Mz*II
    return(np.real(phiz)) 
def phix_drive_2(t,args,Mx):
    ## 0.07853982  X/2
    hbar=1.054560652926899*10**(-34);
    h = hbar*2*np.pi;
    e = 1.60217662*10**(-19); 
    phi0 = h/2/e

    II = I_drive(t,args)
    phix = 2*np.pi/phi0*Mx*II
    return(np.real(phix**2)) 
def phiz_drive_2(t,args,Mz):
    ## 0.07853982  X/2
    hbar=1.054560652926899*10**(-34);
    h = hbar*2*np.pi;
    e = 1.60217662*10**(-19); 
    phi0 = h/2/e

    II = I_drive(t,args)
    phiz = np.pi/phi0*Mz*II
    return(np.real(phiz**2)) 
def phiz_x_drive(t,args,Mx,Mz):
    ## 0.07853982  X/2
    hbar=1.054560652926899*10**(-34);
    h = hbar*2*np.pi;
    e = 1.60217662*10**(-19); 
    phi0 = h/2/e

    II = I_drive(t,args)
    phix = 2*np.pi/phi0*Mx*II
    phiz = np.pi/phi0*Mz*II
    return(np.real(phix*phiz)) 
def getfid(P , limit = np.Infinity):
    Ec = 0.240 * 2 * np.pi
    Ej = 20 * 2 * np.pi
    phi_s = np.pi*0.05
    ## 互感
    ## 3.07432332e-07 3.73621922e+01 0.0  
    Mx = 0.1*10**(-12)
    Mz = 1.7*10**(-12)    
    ##
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
    driveX = partial(phix_drive,Mx = Mx)
    driveZ = partial(phiz_drive,Mz = Mz)
    driveXX = partial(phix_drive_2,Mx = Mx)
    driveZZ = partial(phiz_drive_2,Mz = Mz)
    driveXZ = partial(phiz_x_drive,Mx = Mx,Mz = Mz)
    H1 = [Ej*np.cos(phi_s)*sin_phi,driveX] 
    H2 = [Ej*np.sin(phi_s)*cos_phi,driveZ]
    H3 = [Ej*np.cos(phi_s)/2*cos_phi,driveXX]
    H4 = [Ej*np.cos(phi_s)/2*cos_phi,driveZZ]
    H5 = [-Ej*np.sin(phi_s)*sin_phi,driveXZ]
    Hdrive = [H1,H2,H3,H4,H5]
    ## 电容驱动
    # Cc = 30e-18;
    # C = 80e-15;
    # e = 1.60217662*10**(-19); 
    # Z0 = 50;
    # hbar=1.054560652926899*10**(-34);
    # H1 = [2*Cc*Z0/(C+Cc)*e/hbar*nn/10**9,I_drive_real] 
    # Hdrive = [H1]
    ##

    
    X = np.array([[0,1],[1,0]])
    Y = np.array([[0,-1j],[1j,0]])
    phi_x = 0
    gate =  expm(-1j*np.pi/4*(np.cos(phi_x)*X+np.sin(phi_x)*Y))

    args = {'T_P':20,'T_copies':101 , 'omegaI':P[0] ,'phiI':0, 'wf': P[1],'eta_q':eta_q}
    # final = QB.evolution(drive = Hdrive , psi = basis(2,0),  RWF = 'UnCpRWF' , RWA_freq = 0,track_plot = True ,argument = args);
    process = QB.process(drive = Hdrive, process_plot  = False , RWF = 'UnCpRWF' , RWA_freq = 0.0 ,parallel = False ,argument = args)
    Ufidelity = np.abs(np.trace(np.dot(np.conjugate(np.transpose(gate)),process)))/(2**QB.num_qubits)
    # print(process)
    print(P)
    print(Ufidelity)

    return(1-Ufidelity)


def EL_qubit(Ej,Ec,phi_s):
    # phi_s偏置下的比特频率
    N =180
    H = 4*Ec*np.diag(np.arange(-N,N+1,1)**2)-Ej/2*np.cos(phi_s)*(np.diag(np.ones(2*N),1)+np.diag(np.ones(2*N),-1))
    el = np.linalg.eig(H)
    el = np.sort(el[0])
    return(el)


if __name__ == '__main__':

    Ec = 0.240 * 2 * np.pi
    Ej = 20 * 2 * np.pi
    phi_s = np.pi*0.25
 

    Mx = 0.1*10**(-12)
    Mz = 1.7*10**(-12)    
    ##
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
    
    ##
    driveX = partial(phix_drive,Mx = Mx)
    driveZ = partial(phiz_drive,Mz = Mz)
    driveXX = partial(phix_drive_2,Mx = Mx)
    driveZZ = partial(phiz_drive_2,Mz = Mz)
    driveXZ = partial(phiz_x_drive,Mx = Mx,Mz = Mz)
    H1 = [Ej*np.cos(phi_s)*sin_phi,driveX] 
    H2 = [Ej*np.sin(phi_s)*cos_phi,driveZ]
    H3 = [Ej*np.cos(phi_s)/2*cos_phi,driveXX]
    H4 = [Ej*np.cos(phi_s)/2*cos_phi,driveZZ]
    H5 = [-Ej*np.sin(phi_s)*sin_phi,driveXZ]
    # Hdrive = [H2]
    Hdrive = [H1,H2,H3,H4,H5]

    ##
    # Cc = 30e-18;
    # C = 80e-15;
    # e = 1.60217662*10**(-19); 
    # Z0 = 50;
    # hbar=1.054560652926899*10**(-34);
    # H1 = [2*Cc*Z0/(C+Cc)*e/hbar*nn/10**9,I_drive_real] 
    # Hdrive = [H1]

    # args = {'T_P':40,'T_copies':101 , 'omegaI':3.07432332e-06 ,'phiI':0, 'wf': frequency[0],'eta_q':eta_q}
    args = {'T_P':20,'T_copies':101 , 'omegaI':7.48269480e-06 ,'phiI':0, 'wf': 3.11532822e+01,'eta_q':eta_q}

    # f = np.vectorize(partial(I_drive,args = args));
    # ff = np.vectorize(partial(phix_drive,args = args,Mx = Mx));
    # fff = np.vectorize(partial(phiz_drive,args = args,Mz = Mz))
    # tlist = np.linspace(0,20,1001)
    # plt.figure();plt.plot(tlist,f(tlist));plt.ylabel('I')
    # plt.figure();plt.plot(tlist,ff(tlist));plt.ylabel('phi_x')
    # plt.figure();plt.plot(tlist,fff(tlist));plt.ylabel('phi_z')

    # phiz_list = fff(tlist)
    # freq_list = []
    # for phiz in phiz_list:
    #     phi_s_1 = phi_s+phiz
    #     el = EL_qubit(Ej,Ec,phi_s_1)
    #     freq_list.append((el[1]-el[0])/2/np.pi)
    # # plt.figure();plt.plot(tlist,phiz_list);
    # plt.figure();plt.plot(tlist,freq_list);plt.ylabel('freq');plt.show()



    
    # X = np.array([[0,1],[1,0]])
    # Y = np.array([[0,-1j],[1j,0]])
    # phi_x = 0
    # gate =  expm(-1j*np.pi/4*(np.cos(phi_x)*X+np.sin(phi_x)*Y))

    psi = (basis(3,0)+1j*basis(3,1)).unit()
    final = QB.evolution(drive = Hdrive , psi = psi,  RWF = 'UnCpRWF' , RWA_freq = 0,track_plot = True ,argument = args);
    # process = QB.process(drive = Hdrive, process_plot  = False , RWF = 'UnCpRWF' , RWA_freq = 0.0 ,parallel = True ,argument = args)
    # Ufidelity = np.abs(np.trace(np.dot(np.conjugate(np.transpose(gate)),process)))/(2**QB.num_qubits)
    # print(Ufidelity)

    ##  计算保真度
    # Inductance 0.25 7.48269480e-06, 3.11532822e+01  X/2 0.9999824644020315 Y/2 0.9999824664145123
    # Inductance 0.0  5.23797395e-06, 3.73621165e+01  X/2 0.999999657158705 Y/2 0.9999996533515667
    # Capacity 0.25 1.18554640e-06,   3.11530482e+01  X/2 0.999999203533 Y/2 0.999999396484



    # driveX = partial(phix_drive,Mx = Mx)
    # driveZ = partial(phiz_drive,Mz = Mz)
    # driveXX = partial(phix_drive_2,Mx = Mx)
    # driveZZ = partial(phiz_drive_2,Mz = Mz)
    # driveXZ = partial(phiz_x_drive,Mx = Mx,Mz = Mz)
    # H1 = [Ej*np.cos(phi_s)*sin_phi,driveX] 
    # H2 = [Ej*np.sin(phi_s)*cos_phi,driveZ]
    # H3 = [Ej*np.cos(phi_s)/2*cos_phi,driveXX]
    # H4 = [Ej*np.cos(phi_s)/2*cos_phi,driveZZ]
    # H5 = [-Ej*np.sin(phi_s)*sin_phi,driveXZ]
    # Hdrive = [H1,H2]
    # Hdrive = [H1,H2,H3,H4,H5]

    # X = np.array([[0,1],[1,0]])
    # Y = np.array([[0,-1j],[1j,0]])
    # phi_x = np.pi/2
    # gate =  expm(-1j*np.pi/4*(np.cos(phi_x)*X+np.sin(phi_x)*Y))

    # args = {'T_P':20,'T_copies':101 , 'omegaI':7.48269480e-06 ,'phiI':phi_x, 'wf': 3.11532822e+01,'eta_q':eta_q}
    # process = QB.process(drive = Hdrive, process_plot  = False , RWF = 'UnCpRWF' , RWA_freq = 0.0 ,parallel = True ,argument = args)
    # Ufidelity = np.abs(np.trace(np.dot(np.conjugate(np.transpose(gate)),process)))/(2**QB.num_qubits)
    # print(Ufidelity)

    # omega_list = np.linspace(0.9*7.48269480e-06,1.1*7.48269480e-06,101)
    # fid_omega_list = []
    # for ii in omega_list:
    #     X = np.array([[0,1],[1,0]])
    #     Y = np.array([[0,-1j],[1j,0]])
    #     phi_x = np.pi/2
    #     gate =  expm(-1j*np.pi/4*(np.cos(phi_x)*X+np.sin(phi_x)*Y))

    #     args = {'T_P':20,'T_copies':101 , 'omegaI':ii ,'phiI':phi_x, 'wf': 3.11532822e+01,'eta_q':eta_q}
    #     process = QB.process(drive = Hdrive, process_plot  = False , RWF = 'UnCpRWF' , RWA_freq = 0.0 ,parallel = True ,argument = args)
    #     Ufidelity = np.abs(np.trace(np.dot(np.conjugate(np.transpose(gate)),process)))/(2**QB.num_qubits)
    #     fid_omega_list.append(Ufidelity)

    # w_list = np.linspace(0.995*3.11532446e+01,1.005*3.11532446e+01,101)
    # fid_w_list = []
    # for ii in w_list:
    #     X = np.array([[0,1],[1,0]])
    #     Y = np.array([[0,-1j],[1j,0]])
    #     phi_x = np.pi/2
    #     gate =  expm(-1j*np.pi/4*(np.cos(phi_x)*X+np.sin(phi_x)*Y))

    #     args = {'T_P':20,'T_copies':101 , 'omegaI':7.48269480e-06 ,'phiI':phi_x, 'wf': ii,'eta_q':eta_q}
    #     process = QB.process(drive = Hdrive, process_plot  = False , RWF = 'UnCpRWF' , RWA_freq = 0.0 ,parallel = True ,argument = args)
    #     Ufidelity = np.abs(np.trace(np.dot(np.conjugate(np.transpose(gate)),process)))/(2**QB.num_qubits)
    #     fid_w_list.append(Ufidelity)
    # plt.figure();plt.plot((omega_list-7.48269480e-06)*10**6,fid_omega_list);plt.ylabel('fidelity');plt.xlabel('delta_Omega')
    # plt.figure();plt.plot((w_list-3.11532446e+01),fid_w_list);plt.ylabel('fidelity');plt.xlabel('delta_w')
    # # np.savez('M_single',omega_list,fid_omega_list,w_list,fid_w_list)
    # scio.savemat('M_single.mat',mdict = {'omega_list':omega_list,'fid_omega_list':fid_omega_list,'w_list':w_list,'fid_w_list':fid_w_list})



    # Cc = 30e-18;
    # C = 80e-15;
    # e = 1.60217662*10**(-19); 
    # Z0 = 50;
    # hbar=1.054560652926899*10**(-34);
    # H1 = [2*Cc*Z0/(C+Cc)*e/hbar*nn/10**9,I_drive_real] 
    # Hdrive = [H1]

    # X = np.array([[0,1],[1,0]])
    # Y = np.array([[0,-1j],[1j,0]])
    # phi_x = np.pi/2
    # gate =  expm(-1j*np.pi/4*(np.cos(phi_x)*X+np.sin(phi_x)*Y))

    # args = {'T_P':20,'T_copies':101 , 'omegaI':1.18554640e-06 ,'phiI':phi_x-np.pi/2, 'wf': 3.11530482e+01,'eta_q':eta_q}
    # process = QB.process(drive = Hdrive, process_plot  = False , RWF = 'UnCpRWF' , RWA_freq = 0.0 ,parallel = True ,argument = args)
    # Ufidelity = np.abs(np.trace(np.dot(np.conjugate(np.transpose(gate)),process)))/(2**QB.num_qubits)
    # print(Ufidelity)

    # omega_list = np.linspace(0.9*1.18554640e-06,1.1*1.18554640e-06,101)
    # fid_omega_list = []
    # for ii in omega_list:
    #     X = np.array([[0,1],[1,0]])
    #     Y = np.array([[0,-1j],[1j,0]])
    #     phi_x = np.pi/2
    #     gate =  expm(-1j*np.pi/4*(np.cos(phi_x)*X+np.sin(phi_x)*Y))

    #     args = {'T_P':20,'T_copies':101 , 'omegaI':ii ,'phiI':phi_x-np.pi/2, 'wf': 3.11530482e+01,'eta_q':eta_q}
    #     process = QB.process(drive = Hdrive, process_plot  = False , RWF = 'UnCpRWF' , RWA_freq = 0.0 ,parallel = True ,argument = args)
    #     Ufidelity = np.abs(np.trace(np.dot(np.conjugate(np.transpose(gate)),process)))/(2**QB.num_qubits)
    #     fid_omega_list.append(Ufidelity)

    # w_list = np.linspace(0.995*3.11530482e+01,1.005*3.11530482e+01,101)
    # fid_w_list = []
    # for ii in w_list:
    #     X = np.array([[0,1],[1,0]])
    #     Y = np.array([[0,-1j],[1j,0]])
    #     phi_x = np.pi/2
    #     gate =  expm(-1j*np.pi/4*(np.cos(phi_x)*X+np.sin(phi_x)*Y))

    #     args = {'T_P':20,'T_copies':101 , 'omegaI':1.18554640e-06 ,'phiI':phi_x-np.pi/2, 'wf': ii,'eta_q':eta_q}
    #     process = QB.process(drive = Hdrive, process_plot  = False , RWF = 'UnCpRWF' , RWA_freq = 0.0 ,parallel = True ,argument = args)
    #     Ufidelity = np.abs(np.trace(np.dot(np.conjugate(np.transpose(gate)),process)))/(2**QB.num_qubits)
    #     fid_w_list.append(Ufidelity)
    # plt.figure();plt.plot((omega_list-1.18554640e-06)*10**6,fid_omega_list);plt.ylabel('fidelity');plt.xlabel('delta_Omega')
    # plt.figure();plt.plot((w_list-3.11530482e+01),fid_w_list);plt.ylabel('fidelity');plt.xlabel('delta_w')
    
    # # np.savez('M_single',omega_list,fid_omega_list,w_list,fid_w_list)
    # scio.savemat('C_single.mat',mdict = {'omega_list':omega_list,'fid_omega_list':fid_omega_list,'w_list':w_list,'fid_w_list':fid_w_list})
    # plt.show()



    # # NM算法
    # P = [6.11269480e-06,frequency[0]]
    # func = getfid
    # result = minimize(func, P, method="Nelder-Mead",options={'disp': True})
    # print(result)