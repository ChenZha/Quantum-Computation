import numpy as np
from QubitSimulation import DifferentialTransmon, Xmon,ControlWaveForm
from qutip import *
import matplotlib.pyplot as plt
hbar=1.054560652926899e-34
h = hbar*2*np.pi
e = 1.60217662e-19 
 

class XmonEnergy():
    '''
    输出的频率单位为GHz
    '''
    def __init__(self, elementParameter, *args, **kwargs):
        self.capacity, self.resistance, self.numelelectron = elementParameter
        CInv = 1/self.capacity
        self.Ej = self._R2E()
        Ec = e**2/2*CInv/hbar/1e9;self.Ec = Ec
        self.energyLevel = self._HamiltonMatrixGet()
        
    def _R2E(self):
        I0 = 280e-9
        R0 = 1000
        I = I0*R0/self.resistance
        Ej = I*hbar/2/e/hbar/1e9
        return(Ej)
    def _HamiltonMatrixGet(self):
        Nmax = 100
        nlist = np.arange(-Nmax,Nmax+1,1)
        nlist = nlist-self.numelelectron
        Hamilton = 4*self.Ec*np.diag(nlist**2)+(-self.Ej)/2*(np.diag([1]*(len(nlist)-1),k=1)+np.diag([1]*(len(nlist)-1),k=-1))
        [el,ev] = np.linalg.eig(Hamilton)
        el = np.sort(el)
        el = (el-el[0])/2/np.pi
        return(el)
class XmonEnergy1V4():
    '''
    输出的频率单位为GHz
    '''
    def __init__(self, elementParameter, *args, **kwargs):
        self.capacity, self.resistance = elementParameter
        Linv = np.ones_like(self.capacity)*1e9
        RNAN = 1e9
        RList = np.ones_like(self.capacity)*RNAN
        RList[0,0] = self.resistance[0]
        RList[1,1] = self.resistance[1]
        RList[2,2] = self.resistance[2]
        RList[3,3] = self.resistance[3]
        RList[4,4] = self.resistance[4]
        RList[5,5] = self.resistance[5]
        RList[6,6] = self.resistance[6]
        RList[7,7] = self.resistance[7]
        RList[8,8] = self.resistance[8]
        flux = np.zeros_like(self.capacity)
        SMatrix = np.diag([1]*9)
        structure = [[0],[1],[2]]
        Nlevel = [10,5,10]
        para = [self.capacity,Linv,RList,flux,SMatrix,structure,Nlevel]
        DT = DifferentialTransmon(para)
        [energyEig,stateEig] = DT.EigenGet()
        self.energyLevel = (energyEig-energyEig[0])/2/np.pi
        
        # 计算基矢对应的index
        stateNumList = [[0,0,0],[0,0,1],[1,0,0],[0,1,0],[1,0,1],[0,0,2],[2,0,0]]
        stateList = [tensor(basis(Nlevel[0],num[0]),basis(Nlevel[1],num[1]),basis(Nlevel[2],num[2])) for num in stateNumList]
        self.stateIndexList = [DT.findstate(state) for state in stateList]
        self.Ec = DT.Ec
        self.Ej = DT.Ej
        self.couplingMinus = ((stateEig[1].dag()*tensor(basis(Nlevel[0],1),basis(Nlevel[1],0),basis(Nlevel[2],0))).data.toarray()[0,0])*((stateEig[1].dag()*tensor(basis(Nlevel[0],0),basis(Nlevel[1],0),basis(Nlevel[2],1))).data.toarray()[0,0])>0
        
        couplerLeakage1 = abs((stateEig[self.stateIndexList[1]].dag()*tensor(basis(Nlevel[0],0),basis(Nlevel[1],1),basis(Nlevel[2],0))).data.toarray())**2
        couplerLeakage2 = abs((stateEig[self.stateIndexList[2]].dag()*tensor(basis(Nlevel[0],0),basis(Nlevel[1],1),basis(Nlevel[2],0))).data.toarray())**2
        self.couplerLeakage = max([couplerLeakage1[0,0],couplerLeakage2[0,0]])
class SingleFloatingTransmon():
    '''
    输出的频率单位为GHz
    '''
    def __init__(self, elementParameter, *args, **kwargs):
        self.capacity, self.resistance,self.numelelectronDiff = elementParameter
        SMatrix = np.array([[1,-1],[1,1]])
        SMatrixInv = np.linalg.inv(SMatrix)
        Capa = -np.array(self.capacity)
        for ii in range(np.shape(Capa)[0]):
            Capa[ii][ii] = -sum(Capa[ii])
        Capa = np.dot(np.transpose(SMatrixInv),np.dot(Capa,SMatrixInv))
        CInv = np.linalg.inv(Capa)
        CInvSelect = CInv[0,0]
        
        self.Ej = self._R2E()
        Ec = e**2/2*CInvSelect/hbar/1e9;self.Ec = Ec
        self.energyLevel = self._HamiltonMatrixGet()
        
    def _R2E(self):
        I0 = 280e-9
        R0 = 1000
        I = I0*R0/self.resistance
        Ej = I*hbar/2/e/hbar/1e9
        return(Ej)
    def _HamiltonMatrixGet(self):
        Nmax = 100
        nlist = np.arange(-Nmax,Nmax+1,1)
        nlist = nlist-self.numelelectronDiff
        Hamilton = 4*self.Ec*np.diag(nlist**2)+(-self.Ej)/2*(np.diag([1]*(len(nlist)-1),k=1)+np.diag([1]*(len(nlist)-1),k=-1))
        [el,ev] = np.linalg.eig(Hamilton)
        el = np.sort(el)
        el = (el-el[0])/2/np.pi
        return(el)
        
class TwoFloatingTransmonWithGroundedCoupler():#TwoFloatingTransmonWithGroundedCoupler
    '''
    输出的频率单位为GHz
    '''
    def __init__(self, elementParameter, *args, **kwargs):
        self.capacity, self.resistance = elementParameter
        Linv = np.ones_like(self.capacity)*1e9
        RNAN = 1e9
        RList = np.array([
            [RNAN,self.resistance[0],RNAN,RNAN,RNAN],
            [self.resistance[0],RNAN,RNAN,RNAN,RNAN],
            [RNAN,RNAN,self.resistance[1],RNAN,RNAN],
            [RNAN,RNAN,RNAN,RNAN,self.resistance[2]],
            [RNAN,RNAN,RNAN,self.resistance[2],RNAN],
        ])
        flux = np.zeros_like(self.capacity)
        SMatrix = np.array([
            [1,1,0,0,0],
            [-1,1,0,0,0],
            [0,0,1,0,0],
            [0,0,0,1,-1],
            [0,0,0,1,1],
        ])
        structure = [[1,0],[2],[3,4]]
        Nlevel = [10,5,10]
        para = [self.capacity,Linv,RList,flux,SMatrix,structure,Nlevel]
        DT = DifferentialTransmon(para)
        [energyEig,stateEig] = DT.EigenGet()
        self.energyLevel = (energyEig-energyEig[0])/2/np.pi
        
        # 计算基矢对应的index
        stateNumList = [[0,0,0],[0,0,1],[1,0,0],[0,1,0],[1,0,1],[0,0,2],[2,0,0]]
        stateList = [tensor(basis(Nlevel[0],num[0]),basis(Nlevel[1],num[1]),basis(Nlevel[2],num[2])) for num in stateNumList]
        self.stateIndexList = [DT.findstate(state) for state in stateList]
        self.Ec = DT.Ec
        self.Ej = DT.Ej
        self.couplingMinus = ((stateEig[1].dag()*tensor(basis(Nlevel[0],1),basis(Nlevel[1],0),basis(Nlevel[2],0))).data.toarray()[0,0])*((stateEig[1].dag()*tensor(basis(Nlevel[0],0),basis(Nlevel[1],0),basis(Nlevel[2],1))).data.toarray()[0,0])>0

        couplerLeakage1 = abs((stateEig[self.stateIndexList[1]].dag()*tensor(basis(Nlevel[0],0),basis(Nlevel[1],1),basis(Nlevel[2],0))).data.toarray())**2
        couplerLeakage2 = abs((stateEig[self.stateIndexList[2]].dag()*tensor(basis(Nlevel[0],0),basis(Nlevel[1],1),basis(Nlevel[2],0))).data.toarray())**2
        self.couplerLeakage = max([couplerLeakage1[0,0],couplerLeakage2[0,0]])

class FloatingTransmonWithGroundedCoupler1V4():#TwoFloatingTransmonWithGroundedCoupler
    '''
    输出的频率单位为GHz
    '''
    def __init__(self, elementParameter, *args, **kwargs):
        self.capacity, self.resistance = elementParameter
        Linv = np.ones_like(self.capacity)*1e9
        RNAN = 1e9
        RList = np.ones_like(self.capacity)*RNAN
        RList[0,1] = self.resistance[0];RList[1,0] = self.resistance[0]
        RList[2,2] = self.resistance[1]
        RList[3,4] = self.resistance[2];RList[4,3] = self.resistance[2]
        RList[5,5] = self.resistance[3];RList[6,6] = self.resistance[4]
        RList[7,7] = self.resistance[5]
        RList[8,8] = self.resistance[6];RList[9,9] = self.resistance[7]
        RList[10,10] = self.resistance[8]
        flux = np.zeros_like(self.capacity)
        SMatrix = np.array([
            [1,1,0,0,0,0,0,0,0,0,0],
            [-1,1,0,0,0,0,0,0,0,0,0],
            [0,0,1,0,0,0,0,0,0,0,0],
            [0,0,0,1,-1,0,0,0,0,0,0],
            [0,0,0,1, 1,0,0,0,0,0,0],
            [0,0,0,0,0,1,0,0,0,0,0],
            [0,0,0,0,0,0,1,0,0,0,0],
            [0,0,0,0,0,0,0,1,0,0,0],
            [0,0,0,0,0,0,0,0,1,0,0],
            [0,0,0,0,0,0,0,0,0,1,0],
            [0,0,0,0,0,0,0,0,0,0,1],
        ])
        structure = [[1,0],[2],[3,4]]
        Nlevel = [10,5,10]
        para = [self.capacity,Linv,RList,flux,SMatrix,structure,Nlevel]
        DT = DifferentialTransmon(para)
        [energyEig,stateEig] = DT.EigenGet()
        self.energyLevel = (energyEig-energyEig[0])/2/np.pi
        
        # 计算基矢对应的index
        stateNumList = [[0,0,0],[0,0,1],[1,0,0],[0,1,0],[1,0,1],[0,0,2],[2,0,0]]
        stateList = [tensor(basis(Nlevel[0],num[0]),basis(Nlevel[1],num[1]),basis(Nlevel[2],num[2])) for num in stateNumList]
        self.stateIndexList = [DT.findstate(state) for state in stateList]
        self.Ec = DT.Ec
        self.Ej = DT.Ej
        self.couplingMinus = ((stateEig[1].dag()*tensor(basis(Nlevel[0],1),basis(Nlevel[1],0),basis(Nlevel[2],0))).data.toarray()[0,0])*((stateEig[1].dag()*tensor(basis(Nlevel[0],0),basis(Nlevel[1],0),basis(Nlevel[2],1))).data.toarray()[0,0])>0

        couplerLeakage1 = abs((stateEig[self.stateIndexList[1]].dag()*tensor(basis(Nlevel[0],0),basis(Nlevel[1],1),basis(Nlevel[2],0))).data.toarray())**2
        couplerLeakage2 = abs((stateEig[self.stateIndexList[2]].dag()*tensor(basis(Nlevel[0],0),basis(Nlevel[1],1),basis(Nlevel[2],0))).data.toarray())**2
        self.couplerLeakage = max([couplerLeakage1[0,0],couplerLeakage2[0,0]])
class TwoFloatingTransmonWithFloatingCoupler():
    '''
    输出的频率单位为GHz
    '''
    def __init__(self, elementParameter, *args, **kwargs):
        self.capacity, self.resistance = elementParameter

        Linv = np.ones_like(self.capacity)*1e9
        RNAN = 1e9
        RList = np.array([
            [RNAN,self.resistance[0],RNAN,RNAN,RNAN,RNAN],
            [self.resistance[0],RNAN,RNAN,RNAN,RNAN,RNAN],
            [RNAN,RNAN,RNAN,self.resistance[1],RNAN,RNAN],
            [RNAN,RNAN,self.resistance[1],RNAN,RNAN,RNAN],
            [RNAN,RNAN,RNAN,RNAN,RNAN,self.resistance[2]],
            [RNAN,RNAN,RNAN,RNAN,self.resistance[2],RNAN],
        ])
        flux = np.zeros_like(self.capacity)
        SMatrix = np.array([
            [1,1,0,0,0,0],
            [-1,1,0,0,0,0],
            [0,0,1,-1,0,0],
            [0,0,1, 1,0,0],
            [0,0,0,0,1,-1],
            [0,0,0,0,1, 1],
        ])
        structure = [[1,0],[2,3],[4,5]]
        Nlevel = [10,5,10]
        para = [self.capacity,Linv,RList,flux,SMatrix,structure,Nlevel]
        DT = DifferentialTransmon(para)
        [energyEig,stateEig] = DT.EigenGet()
        self.energyLevel = (energyEig-energyEig[0])/2/np.pi
        
        # 计算基矢对应的index
        stateNumList = [[0,0,0],[0,0,1],[1,0,0],[0,1,0],[1,0,1],[0,0,2],[2,0,0]]
        stateList = [tensor(basis(Nlevel[0],num[0]),basis(Nlevel[1],num[1]),basis(Nlevel[2],num[2])) for num in stateNumList]
        self.stateIndexList = [DT.findstate(state) for state in stateList]
        self.Ec = DT.Ec
        self.Ej = DT.Ej
        self.couplingMinus = ((stateEig[1].dag()*tensor(basis(Nlevel[0],1),basis(Nlevel[1],0),basis(Nlevel[2],0))).data.toarray()[0,0])*((stateEig[1].dag()*tensor(basis(Nlevel[0],0),basis(Nlevel[1],0),basis(Nlevel[2],1))).data.toarray()[0,0])>0

        couplerLeakage1 = abs((stateEig[self.stateIndexList[1]].dag()*tensor(basis(Nlevel[0],0),basis(Nlevel[1],1),basis(Nlevel[2],0))).data.toarray())**2
        couplerLeakage2 = abs((stateEig[self.stateIndexList[2]].dag()*tensor(basis(Nlevel[0],0),basis(Nlevel[1],1),basis(Nlevel[2],0))).data.toarray())**2
        self.couplerLeakage = max([couplerLeakage1[0,0],couplerLeakage2[0,0]])

class FloatingTransmonWithFloatingCoupler1V4():
    '''
    输出的频率单位为GHz
    '''
    def __init__(self, elementParameter, *args, **kwargs):
        self.capacity, self.resistance = elementParameter
        Linv = np.ones_like(self.capacity)*1e9
        RNAN = 1e9
        RList = np.ones_like(self.capacity)*RNAN
        SMatrix = np.zeros_like(self.capacity)
        flux = np.zeros_like(self.capacity)
        for ii in range(len(self.resistance)):
            RList[2*ii,2*ii+1] = self.resistance[ii];RList[2*ii+1,2*ii] = self.resistance[ii]
            SMatrix[2*ii,2*ii+1]=-1;SMatrix[2*ii,2*ii]=1;SMatrix[2*ii+1,2*ii+1]=1;SMatrix[2*ii+1,2*ii]=1;
        SMatrix[0,1] = 1;SMatrix[1,0] = -1
        structure = [[1,0],[2,3],[4,5]]
        Nlevel = [10,5,10]
        para = [self.capacity,Linv,RList,flux,SMatrix,structure,Nlevel]
        DT = DifferentialTransmon(para)
        [energyEig,stateEig] = DT.EigenGet()
        self.energyLevel = (energyEig-energyEig[0])/2/np.pi
        
        # 计算基矢对应的index
        stateNumList = [[0,0,0],[0,0,1],[1,0,0],[0,1,0],[1,0,1],[0,0,2],[2,0,0]]
        stateList = [tensor(basis(Nlevel[0],num[0]),basis(Nlevel[1],num[1]),basis(Nlevel[2],num[2])) for num in stateNumList]
        self.stateIndexList = [DT.findstate(state) for state in stateList]
        self.Ec = DT.Ec
        self.Ej = DT.Ej
        self.couplingMinus = ((stateEig[1].dag()*tensor(basis(Nlevel[0],1),basis(Nlevel[1],0),basis(Nlevel[2],0))).data.toarray()[0,0])*((stateEig[1].dag()*tensor(basis(Nlevel[0],0),basis(Nlevel[1],0),basis(Nlevel[2],1))).data.toarray()[0,0])>0

        couplerLeakage1 = abs((stateEig[self.stateIndexList[1]].dag()*tensor(basis(Nlevel[0],0),basis(Nlevel[1],1),basis(Nlevel[2],0))).data.toarray())**2
        couplerLeakage2 = abs((stateEig[self.stateIndexList[2]].dag()*tensor(basis(Nlevel[0],0),basis(Nlevel[1],1),basis(Nlevel[2],0))).data.toarray())**2
        self.couplerLeakage = max([couplerLeakage1[0,0],couplerLeakage2[0,0]])
        
class GroundedTransmonWithFloatingCoupler1V4():
    '''
    输出的频率单位为GHz
    '''
    def __init__(self, elementParameter, *args, **kwargs):
        self.capacity, self.resistance = elementParameter
        Linv = np.ones_like(self.capacity)*1e9
        RNAN = 1e9
        RList = np.ones_like(self.capacity)*RNAN
        SMatrix = np.zeros_like(self.capacity)
        flux = np.zeros_like(self.capacity)
        RList[0,0]=self.resistance[0]
        RList[1,2]=self.resistance[1];RList[2,1]=self.resistance[1]
        RList[3,3]=self.resistance[2]
        SMatrix[0,0]=1
        SMatrix[1,1]=1;SMatrix[2,1]=-1;SMatrix[1,2]=1;SMatrix[2,2]=1
        SMatrix[3,3]=1
        for ii in range(3,len(self.resistance)):
            RList[2*ii-2,2*ii-1] = self.resistance[ii];RList[2*ii-1,2*ii-2] = self.resistance[ii]
            SMatrix[2*ii-2,2*ii-1]=-1;SMatrix[2*ii-2,2*ii-2]=1;SMatrix[2*ii-1,2*ii-1]=1;SMatrix[2*ii-1,2*ii-2]=1;
        structure = [[0],[2,1],[3]]
        Nlevel = [10,5,10]
        para = [self.capacity,Linv,RList,flux,SMatrix,structure,Nlevel]
        DT = DifferentialTransmon(para)
        [energyEig,stateEig] = DT.EigenGet()
        self.energyLevel = (energyEig-energyEig[0])/2/np.pi
        
        # 计算基矢对应的index
        stateNumList = [[0,0,0],[0,0,1],[1,0,0],[0,1,0],[1,0,1],[0,0,2],[2,0,0]]
        stateList = [tensor(basis(Nlevel[0],num[0]),basis(Nlevel[1],num[1]),basis(Nlevel[2],num[2])) for num in stateNumList]
        self.stateIndexList = [DT.findstate(state) for state in stateList]
        self.Ec = DT.Ec
        self.Ej = DT.Ej
        self.couplingMinus = ((stateEig[1].dag()*tensor(basis(Nlevel[0],1),basis(Nlevel[1],0),basis(Nlevel[2],0))).data.toarray()[0,0])*((stateEig[1].dag()*tensor(basis(Nlevel[0],0),basis(Nlevel[1],0),basis(Nlevel[2],1))).data.toarray()[0,0])>0

        couplerLeakage1 = abs((stateEig[self.stateIndexList[1]].dag()*tensor(basis(Nlevel[0],0),basis(Nlevel[1],1),basis(Nlevel[2],0))).data.toarray())**2
        couplerLeakage2 = abs((stateEig[self.stateIndexList[2]].dag()*tensor(basis(Nlevel[0],0),basis(Nlevel[1],1),basis(Nlevel[2],0))).data.toarray())**2
        self.couplerLeakage = max([couplerLeakage1[0,0],couplerLeakage2[0,0]])

    