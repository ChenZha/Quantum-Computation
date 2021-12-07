import numpy as np
from QubitSimulation import DifferentialTransmon, ControlWaveForm
from qutip import *
import matplotlib.pyplot as plt
import datetime
from multiprocessing import Pool
import functools
from scipy import signal, interpolate

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
    return(w)
def RealIDrive(t,args):
    return(np.real(IDrive(t,args)))
def SquareIDrive(t,args):
    return(np.real(IDrive(t,args))**2)

 

def IPulse(t,args):
    tp = args['T_P']
    omega = args['omegaI']
    rise = 3 # 上升沿
    edge = 5 # 前后平的部分

    if t<=edge or t>=tp-edge:
        w = 0.0
    elif t>edge and t<rise+edge:
        w = omega/rise*(t-edge)
    elif t>tp-rise-edge and t<tp-edge:
        w = omega/rise*(tp-edge-t)
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
    couplingMode = 'Current_1st'
    driveH = DT.DriveHamilton(node,couplingParameter,couplingMode)

    # %% 
    # 单比特驱动演化
    # realIDrive = lambda t,args: np.real(IDrive(t,args))
    # Hdrive = [[driveH[0],realIDrive],[driveH[1],realIDrive]]
    # startTime = datetime.datetime.now()
    # w001 = energyLevel[DT.findstate(tensor(basis(Nlevel[0],0),basis(Nlevel[1],0),basis(Nlevel[2],1)))]
    # w002 = energyLevel[DT.findstate(tensor(basis(Nlevel[0],0),basis(Nlevel[1],0),basis(Nlevel[2],2)))]
    # wf = w001
    # eta_q = w002-2*w001
    # args = {'T_P':60,'T_copies':101 , 'omegaI':7.48269480e-06 ,'phiI':0, 'wf': wf,'eta_q':eta_q}
    # c_ops = []
    # c_ops.append(np.sqrt(1/6000) * DT.sm[2])
    # iniState = tensor(basis(Nlevel[0],0),basis(Nlevel[1],0),(basis(Nlevel[2],0)).unit())
    # final = DT.QutipEvolution(drive = Hdrive , psi = iniState,  collapse = c_ops,RWF = 'CpRWF', RWAFreq = 0, track_plot = True, argument = args)
    # endTime = datetime.datetime.now()
    # print((endTime-startTime).seconds)

    # %% 
    # 单比特门保真度
    # Hdrive = [[driveH[0],RealIDrive],[driveH[1],RealIDrive]]
    # Hdrive = [[sum(driveH),RealIDrive]]
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
    # Hdrive = [[driveH[0],IPulse],[driveH[1],IPulse]]
    # startTime = datetime.datetime.now()
    # args = {'T_P':60,'T_copies':101 , 'omegaI':-71.4e-6}
    # processTomo = DT.process(drive = Hdrive , retainNode = [0,2], processPlot  = False , RWF = 'CpRWF' , RWAFreq = 0.0 ,parallel = True , argument = args)
    # targetMatrix =  Qobj(np.array([[1,0,0,0],[0,1,0,0],[0,0,1,0],[0,0,0,-1]]), dims=processTomo.dims)
    # theta = [-np.angle(processTomo.full()[2,2]),-np.angle(processTomo.full()[1,1])]
    # processTomo = DT.phase_comp(processTomo,theta)
    # Ufidelity = np.abs(np.trace(processTomo.dag()*targetMatrix))/(np.shape(targetMatrix.full())[0])
    # endTime = datetime.datetime.now()
    # print(Ufidelity)
    # print((endTime-startTime).seconds) 

    # %% 
    # 双比特sweepI  -71.4e-6
    # p = Pool()
    # sweepI = np.linspace(-72,-70,21)*1e-6
    # result_final = [p.apply_async(sweepDetuning,(DT , II)) for II in sweepI ]
    # finalState = np.array([result_final[i].get() for i in range(len(result_final))])
    # p.close()    # p.join()
    # fig = plt.figure()
    # plt.plot(sweepI,finalState)
    # plt.show()
    # %%
    # drive shape
    args = {'T_P':120,'T_copies':101 , 'omegaI':-71.4e-6}
    time = np.linspace(-10,args['T_P']+10,1000*args['T_P']+1)
    inputFilter = signal.butter(8, 0.5, 'lowpass')
    func = ControlWaveForm(IPulse, inputFilter, 'pulse', args)
    # plt.figure()
    # plt.plot(time, [func(t,args) for t in time])
    # plt.show()
    a = func(10,args)
    Hdrive1 = [[driveH[0],func],[driveH[1],func]]
    Hdrive2 = [[driveH[0],IPulse],[driveH[1],IPulse]]
    Hdrive3 = [[sum(driveH),IPulse]]
    iniState = tensor((basis(Nlevel[0],1)).unit(),(basis(Nlevel[1],0)).unit(),(basis(Nlevel[2],1)).unit())
    startTime1 = datetime.datetime.now()
    final = DT.QutipEvolution(drive = Hdrive1 , psi = iniState,  RWF = 'CpRWF', RWAFreq = 0, track_plot = False, argument = args)
    endTime1 = datetime.datetime.now()
    print((endTime1-startTime1).seconds)

    
    # startTime2 = datetime.datetime.now()
    # final = DT.QutipEvolution(drive = Hdrive2 , psi = iniState,  RWF = 'CpRWF', RWAFreq = 0, track_plot = False, argument = args)
    # endTime2 = datetime.datetime.now()
    # print((endTime2-startTime2).seconds)

    # startTime3 = datetime.datetime.now()
    # final = DT.QutipEvolution(drive = Hdrive3 , psi = iniState,  RWF = 'CpRWF', RWAFreq = 0, track_plot = False, argument = args)
    # endTime3 = datetime.datetime.now()
    # print((endTime3-startTime3).seconds)

    # %%
    # timeSampling = np.linspace(0,args['T_P'],10*args['T_P']+1) # 2G采样率
    # SamlingFunction = np.vectorize(functools.partial(IPulse, args = args))
    # dataSampling = SamlingFunction(timeSampling)
    # filtedData = signal.filtfilt(inputFilter[0], inputFilter[1], dataSampling)  #data为要过滤的信号
    # interFunction = interpolate.interp1d(timeSampling,filtedData,kind ='linear')

    # startTime = datetime.datetime.now()
    # a = [interFunction(5) for t in time]
    # endTime = datetime.datetime.now()
    # print((endTime-startTime).microseconds)
    # startTime = datetime.datetime.now()
    # a = [1e-5 for t in time]
    # endTime = datetime.datetime.now()
    # print((endTime-startTime).microseconds)