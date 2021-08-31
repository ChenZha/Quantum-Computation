import numpy as np
from QubitSimulation import DifferentialTransmon
from qutip import *
import matplotlib.pyplot as plt
import datetime
from multiprocessing import Pool

def IDrive(t,args):
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
        w = omega*((1-np.cos(2*np.pi/tp*t))*np.exp(1j*(wf*t-phi)))+omega*D*(2*np.pi/tp)*np.sin(2*np.pi/tp*t)/(eta_q)*np.exp(1j*(t*wf-phi-np.pi/2))
    return(np.real(w)) 

def IPulse(t,args):
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
def sweepDetuning(DT,II):
    Mx = 0.1e-12
    Mz = 1.7e-12
    node = 2
    couplingParameter = [Mx,Mz]
    couplingMode = 'Current'
    driveH = DT.DriveHamilton(node,couplingParameter,couplingMode)
    Hamilton = DT.GetHamilton()
    Nlevel = Hamilton.dims[0]

    Hdrive = [[driveH[0],IPulse],[driveH[1],IPulse]]
    args = {'T_P':60,'T_copies':101 , 'omegaI':II}
    iniState = tensor((basis(Nlevel[0],1)).unit(),(basis(Nlevel[1],0)).unit(),(basis(Nlevel[2],1)).unit())
    final = DT.QutipEvolution(drive = Hdrive , psi = iniState,  RWF = 'CpRWF', RWAFreq = 0, track_plot = False, argument = args)
    result = DT.ExpectEvolution(DT.E_e[2])
    diff = max(result)-min(result)

    return(diff)
    def MatrixPtrace(Matrix,retainNode):
        ptraceMatrix = np.zeros([2**len(retainNode),2**len(retainNode)])

        return(ptraceMatrix)

if __name__ == '__main__':
    
    # %% 
    # 生成比特
    CJ=8e-15;     SRatio=6.5;     
    C24=1.34e-15;     
    C12=1.38e-15+CJ;     
    C23=20.58e-15;  
    C34=20.58e-15;   
    C1=150e-15-C12-C24;     
    C2=150e-15-C12-C24;     
    C3=107e-15+SRatio*CJ-2*C23
    R=8000
    
    Capa = np.array([
        [C1,C12,0,0,0],
        [C12,C2,C23,C24,0],
        [0,C23,C3,C34,0],
        [0,C24,C34,C2,C12],
        [0,0,0,C12,C1],
    ])
    Linv = np.ones_like(Capa)*1e9
    RNAN = 1e9
    RList = np.array([
        [RNAN,R,RNAN,RNAN,RNAN],
        [R,RNAN,RNAN,RNAN,RNAN],
        [RNAN,RNAN,R/SRatio,RNAN,RNAN],
        [RNAN,RNAN,RNAN,RNAN,R],
        [RNAN,RNAN,RNAN,R,RNAN],
    ])
    flux = np.zeros_like(Capa)
    flux[4,3] = 0.2
    flux[3,4] = 0.2
    SMatrix = np.array([
        [1,-1,0,0,0],
        [1,1,0,0,0],
        [0,0,1,0,0],
        [0,0,0,1,-1],
        [0,0,0,1,1],
    ])
    structure = [[0,1],[2],[3,4]]
    Nlevel = [6,6,6]
    para = [Capa,Linv,RList,flux,SMatrix,structure,Nlevel]
    DT = DifferentialTransmon(para)
    energyLevel = DT.energyEig-DT.energyEig[0]

    # %% 
    # 生成驱动哈密顿量
    Mx = 0.1e-12
    Mz = 1.7e-12
    node = 2
    couplingParameter = [Mx,Mz]
    couplingMode = 'Current'
    driveH = DT.DriveHamilton(node,couplingParameter,couplingMode)
    ptrace(tensor(basis(Nlevel[0],0),basis(Nlevel[1],0),basis(Nlevel[2],0)),0)

    # %% 
    # 单比特驱动演化
    # Hdrive = [[driveH[0],IDrive],[driveH[1],IDrive]]
    # startTime = datetime.datetime.now()
    # w001 = energyLevel[DT.findstate(tensor(basis(Nlevel[0],0),basis(Nlevel[1],0),basis(Nlevel[2],1)))]
    # w002 = energyLevel[DT.findstate(tensor(basis(Nlevel[0],0),basis(Nlevel[1],0),basis(Nlevel[2],2)))]
    # wf = w001
    # eta_q = w002-2*w001
    # args = {'T_P':60,'T_copies':101 , 'omegaI':7.48269480e-06/3*2 ,'phiI':0, 'wf': wf,'eta_q':eta_q}
    # iniState = tensor(basis(Nlevel[0],0),basis(Nlevel[1],0),(basis(Nlevel[2],0)-basis(Nlevel[2],1)).unit())
    # final = DT.QutipEvolution(drive = Hdrive , psi = iniState,  RWF = 'CpRWF', RWAFreq = 0, track_plot = True, argument = args)
    # endTime = datetime.datetime.now()
    # print((endTime-startTime).seconds)

    # %% 
    # 单比特门保真度
    # Hdrive = [[driveH[0],IDrive],[driveH[1],IDrive]]
    # startTime = datetime.datetime.now()
    # w001 = energyLevel[DT.findstate(tensor(basis(Nlevel[0],0),basis(Nlevel[1],0),basis(Nlevel[2],1)))]
    # w002 = energyLevel[DT.findstate(tensor(basis(Nlevel[0],0),basis(Nlevel[1],0),basis(Nlevel[2],2)))]
    # wf = w001
    # eta_q = w002-2*w001
    # args = {'T_P':60,'T_copies':101 , 'omegaI':7.48269480e-06/3*2 ,'phiI':0, 'wf': wf,'eta_q':eta_q}
    # processTomo = DT.process(drive = Hdrive , retainNode = [0,2], processPlot  = False , RWF = 'CpRWF' , RWAFreq = 0.0 ,parallel = True , argument = args)
    # targetMatrix = tensor(qeye(2),sigmax())
    # Ufidelity = np.abs(np.trace(processTomo.dag()*targetMatrix))/(np.shape(targetMatrix.full())[0])
    # endTime = datetime.datetime.now()
    # print(Ufidelity)
    # print((endTime-startTime).seconds)

    # %% 
    # 双比特门驱动演化
    # Hdrive = [[driveH[0],IPulse],[driveH[1],IPulse]]
    # startTime = datetime.datetime.now()
    # args = {'T_P':120,'T_copies':101 , 'omegaI':-71.4e-6}
    # iniState = tensor((basis(Nlevel[0],1)).unit(),(basis(Nlevel[1],0)).unit(),(basis(Nlevel[2],1)).unit())
    # final = DT.QutipEvolution(drive = Hdrive , psi = iniState,  RWF = 'CpRWF', RWAFreq = 0, track_plot = True, argument = args)
    # endTime = datetime.datetime.now()
    # print((endTime-startTime).seconds)

    # %% 
    # 双比特门保真度
    Hdrive = [[driveH[0],IPulse],[driveH[1],IPulse]]
    startTime = datetime.datetime.now()
    args = {'T_P':60,'T_copies':101 , 'omegaI':-71.4e-6}
    processTomo = DT.process(drive = Hdrive , retainNode = [0,2], processPlot  = False , RWF = 'CpRWF' , RWAFreq = 0.0 ,parallel = True , argument = args)
    targetMatrix =  Qobj(np.array([[1,0,0,0],[0,1,0,0],[0,0,1,0],[0,0,0,-1]]), dims=processTomo.dims)
    theta = [-np.angle(processTomo.full()[2,2]),-np.angle(processTomo.full()[1,1])]
    processTomo = DT.phase_comp(processTomo,theta)
    Ufidelity = np.abs(np.trace(processTomo.dag()*targetMatrix))/(np.shape(targetMatrix.full())[0])
    endTime = datetime.datetime.now()
    print(Ufidelity)
    print((endTime-startTime).seconds) 

    # %% 
    # 双比特sweepI  -71.4e-6
    # p = Pool()
    # sweepI = np.linspace(-72,-70,21)*1e-6
    # result_final = [p.apply_async(sweepDetuning,(DT , II)) for II in sweepI ]
    # finalState = np.array([result_final[i].get() for i in range(len(result_final))])
    # p.close()
    # p.join()
    # fig = plt.figure()
    # plt.plot(sweepI,finalState)
    # plt.show()
