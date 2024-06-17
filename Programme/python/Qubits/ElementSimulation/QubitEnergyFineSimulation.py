import numpy as np
from QubitSimulation import DifferentialTransmon, ControlWaveForm
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
        self.energyLevel,self.energyLevelIndex,self.energyLevelVector,self.cosPhi,self.sinPhi = self._HamiltonMatrixGet()
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
        elIndex = np.argsort(el)
        el = (el-el[0])/2/np.pi
        cosPhi = 1/2*(np.diag([1]*(len(nlist)-1),k=1)+np.diag([1]*(len(nlist)-1),k=-1))
        sinPhi = 1/2*(np.diag([1]*(len(nlist)-1),k=1)-np.diag([1]*(len(nlist)-1),k=-1))
        return(el,elIndex,ev,cosPhi,sinPhi)
class XmonEnergy1V4():
    '''
    输出的频率单位为GHz
    '''
    def __init__(self, elementParameter, *args, **kwargs):
        self.capacity, self.resistance = elementParameter
        Linv = np.ones_like(self.capacity)*1e9
        RNAN = 1e9
        RList = np.ones_like(self.capacity)*RNAN
        row,col = np.diag_indices_from(RList)
        RList[row,col] = self.resistance
        flux = np.zeros_like(self.capacity)
        SMatrix = np.diag(v=[1]*9)
        structure = [[0],[1],[2]]
        Nlevel = [8,4,8]
        para = [self.capacity,Linv,RList,flux,SMatrix,structure,Nlevel]
        DT = DifferentialTransmon(para)
        [energyEig,stateEig] = DT.EigenGet()
        self.energyLevel = (energyEig-energyEig[0])/2/np.pi
        
        # 计算基矢对应的index
        stateNumList = [[0,0,0],[0,0,1],[1,0,0],[0,1,0],[1,0,1],[0,0,2],[2,0,0]]
        stateList = [tensor(basis(Nlevel[0],num[0]),basis(Nlevel[1],num[1]),basis(Nlevel[2],num[2])) for num in stateNumList]
        self.stateIndexList = [DT.findstate(state,searchSpace='full') for state in stateList]
        id = [1,2,3]
        if self.stateIndexList[3] in id:
            id.remove(self.stateIndexList[3])
            self.stateIndexList[1] = id[0];self.stateIndexList[2] = id[1]
        else:
            id.remove(3)
        self.Ec = DT.Ec
        self.Ej = DT.Ej
        self.couplingMinus = abs(((stateEig[1].dag()*tensor(basis(Nlevel[0],1),basis(Nlevel[1],0),basis(Nlevel[2],0))))*((stateEig[1].dag()*tensor(basis(Nlevel[0],0),basis(Nlevel[1],0),basis(Nlevel[2],1)))))>0
        
        couplerLeakage1 = abs((stateEig[self.stateIndexList[1]].dag()*tensor(basis(Nlevel[0],0),basis(Nlevel[1],1),basis(Nlevel[2],0))))**2
        couplerLeakage2 = abs((stateEig[self.stateIndexList[2]].dag()*tensor(basis(Nlevel[0],0),basis(Nlevel[1],1),basis(Nlevel[2],0))))**2
        self.couplerLeakage = (couplerLeakage1+couplerLeakage2)/2
        
        self.QCCoupling = abs((tensor(basis(Nlevel[0],0),basis(Nlevel[1],1),basis(Nlevel[2],0)).dag()*DT.GetHamilton()*tensor(basis(Nlevel[0],1),basis(Nlevel[1],0),basis(Nlevel[2],0)))/2/np.pi)
        self.QQDirectCoupling = abs((tensor(basis(Nlevel[0],1),basis(Nlevel[1],0),basis(Nlevel[2],0)).dag()*DT.GetHamilton()*tensor(basis(Nlevel[0],0),basis(Nlevel[1],0),basis(Nlevel[2],1)))/2/np.pi)
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
        self.couplingMinus = ((stateEig[1].dag()*tensor(basis(Nlevel[0],1),basis(Nlevel[1],0),basis(Nlevel[2],0))))*((stateEig[1].dag()*tensor(basis(Nlevel[0],0),basis(Nlevel[1],0),basis(Nlevel[2],1))))>0

        couplerLeakage1 = abs((stateEig[self.stateIndexList[1]].dag()*tensor(basis(Nlevel[0],0),basis(Nlevel[1],1),basis(Nlevel[2],0))))**2
        couplerLeakage2 = abs((stateEig[self.stateIndexList[2]].dag()*tensor(basis(Nlevel[0],0),basis(Nlevel[1],1),basis(Nlevel[2],0))))**2
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
        RList[11,11] = self.resistance[9]
        RList[12,12] = self.resistance[10]
        RList[13,13] = self.resistance[11]
        RList[14,14] = self.resistance[12]
        RList[15,15] = self.resistance[13]
        RList[16,16] = self.resistance[14]
        flux = np.zeros_like(self.capacity)
        SMatrix = np.array([
            [1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
            [-1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
            [0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
            [0,0,0,1,-1,0,0,0,0,0,0,0,0,0,0,0,0],
            [0,0,0,1, 1,0,0,0,0,0,0,0,0,0,0,0,0],
            [0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0],
            [0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0],
            [0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0],
            [0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0],
            [0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0],
            [0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0],
            [0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0],
            [0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0],
            [0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0],
            [0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0],
            [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0],
            [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
        ])
        structure = [[1,0],[2],[3,4]]
        Nlevel = [8,4,8]

        para = [self.capacity,Linv,RList,flux,SMatrix,structure,Nlevel]
        DT = DifferentialTransmon(para)
        [energyEig,stateEig] = DT.EigenGet()
        self.energyLevel = (energyEig-energyEig[0])/2/np.pi
        
        # 计算基矢对应的index
        # stateNumList = [[0,0,0],[0,0,1],[1,0,0],[0,1,0],[1,0,1],[0,0,2],[2,0,0],[0,2,0]]
        stateNumList = [[0,0,0],[0,0,1],[1,0,0],[0,1,0],[1,0,1],[0,0,2],[2,0,0]]

        stateList = [tensor(basis(Nlevel[0],num[0]),basis(Nlevel[1],num[1]),basis(Nlevel[2],num[2])) for num in stateNumList]
        stateIndexList = [DT.findstate(state,'full') for state in stateList]
        idxList = []
        for idx in stateIndexList:
            if isinstance(idx,list):
                if idx[0] in idxList:
                    idxList.append(idx[1])
                else:
                    idxList.append(idx[0])
            else:
                idxList.append(idx)
        self.stateIndexList = idxList
        id = [1,2,3];
        if self.stateIndexList[3] in id:
            id.remove(self.stateIndexList[3])
            self.stateIndexList[1] = id[0];self.stateIndexList[2] = id[1]
        else:
            id.remove(3)
        self.Ec = DT.Ec
        self.Ej = DT.Ej
        
        idxmin = min([self.stateIndexList[1],self.stateIndexList[2]])
        self.couplingMinus = ((stateEig[self.stateIndexList[idxmin]].dag()*tensor(basis(Nlevel[0],1),basis(Nlevel[1],0),basis(Nlevel[2],0))))*((stateEig[self.stateIndexList[idxmin]].dag()*tensor(basis(Nlevel[0],0),basis(Nlevel[1],0),basis(Nlevel[2],1))))>0

        couplerLeakage1 = abs((stateEig[self.stateIndexList[1]].dag()*tensor(basis(Nlevel[0],0),basis(Nlevel[1],1),basis(Nlevel[2],0))))**2
        couplerLeakage2 = abs((stateEig[self.stateIndexList[2]].dag()*tensor(basis(Nlevel[0],0),basis(Nlevel[1],1),basis(Nlevel[2],0))))**2
        self.couplerLeakage = (couplerLeakage1[0,0]+couplerLeakage2[0,0])/2
        
        self.QCCoupling = abs((tensor(basis(Nlevel[0],0),basis(Nlevel[1],1),basis(Nlevel[2],0)).dag()*DT.GetHamilton()*tensor(basis(Nlevel[0],1),basis(Nlevel[1],0),basis(Nlevel[2],0)))/2/np.pi)
        self.QQDirectCoupling = abs((tensor(basis(Nlevel[0],1),basis(Nlevel[1],0),basis(Nlevel[2],0)).dag()*DT.GetHamilton()*tensor(basis(Nlevel[0],0),basis(Nlevel[1],0),basis(Nlevel[2],1)))/2/np.pi)
class FloatingTransmonWithGroundedCouplerAndCapacitor1V4():
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
        RList[3,3] = RNAN
        RList[4,5] = self.resistance[2];RList[5,4] = self.resistance[2]
        RList[6,6] = self.resistance[3];RList[7,7] = RNAN
        RList[8,8] = self.resistance[4];RList[9,9] = RNAN
        RList[10,10] = self.resistance[5];RList[11,11] = RNAN
        RList[12,12] = self.resistance[6];RList[13,13] = RNAN
        RList[14,14] = self.resistance[7];RList[15,15] = RNAN
        RList[16,16] = self.resistance[8];RList[17,17] = RNAN

        flux = np.zeros_like(self.capacity)
        SMatrix = np.diag([1]*len(np.diag(self.capacity)))
        SMatrix[0][1] = 1;SMatrix[1][0] = -1
        SMatrix[4][5] = -1;SMatrix[5][4] = 1
        
        structure = [[1,0],[2],[4,5]]
        Nlevel = [8,8,8]
        para = [self.capacity,Linv,RList,flux,SMatrix,structure,Nlevel]
        DT = DifferentialTransmon(para)
        [energyEig,stateEig] = DT.EigenGet()
        self.energyLevel = (energyEig-energyEig[0])/2/np.pi
        
        # 计算基矢对应的index
        # stateNumList = [[0,0,0],[0,0,1],[1,0,0],[0,1,0],[1,0,1],[0,0,2],[2,0,0],[0,2,0]]
        stateNumList = [[0,0,0],[0,0,1],[1,0,0],[0,1,0],[1,0,1],[0,0,2],[2,0,0]]

        stateList = [tensor(basis(Nlevel[0],num[0]),basis(Nlevel[1],num[1]),basis(Nlevel[2],num[2])) for num in stateNumList]
        self.stateIndexList = [DT.findstate(state,'full') for state in stateList]
        id = [1,2,3];
        if self.stateIndexList[3] in id:
            id.remove(self.stateIndexList[3])
            self.stateIndexList[1] = id[0];self.stateIndexList[2] = id[1]
        else:
            id.remove(3)
        self.Ec = DT.Ec
        self.Ej = DT.Ej
        self.couplingMinus = ((stateEig[1].dag()*tensor(basis(Nlevel[0],1),basis(Nlevel[1],0),basis(Nlevel[2],0))))*((stateEig[1].dag()*tensor(basis(Nlevel[0],0),basis(Nlevel[1],0),basis(Nlevel[2],1))))>0

        couplerLeakage1 = abs((stateEig[self.stateIndexList[1]].dag()*tensor(basis(Nlevel[0],0),basis(Nlevel[1],1),basis(Nlevel[2],0))))**2
        couplerLeakage2 = abs((stateEig[self.stateIndexList[2]].dag()*tensor(basis(Nlevel[0],0),basis(Nlevel[1],1),basis(Nlevel[2],0))))**2
        self.couplerLeakage = (couplerLeakage1[0,0]+couplerLeakage2[0,0])/2
        
        self.QCCoupling = abs((tensor(basis(Nlevel[0],0),basis(Nlevel[1],1),basis(Nlevel[2],0)).dag()*DT.GetHamilton()*tensor(basis(Nlevel[0],1),basis(Nlevel[1],0),basis(Nlevel[2],0)))/2/np.pi)
        self.QQDirectCoupling = abs((tensor(basis(Nlevel[0],1),basis(Nlevel[1],0),basis(Nlevel[2],0)).dag()*DT.GetHamilton()*tensor(basis(Nlevel[0],0),basis(Nlevel[1],0),basis(Nlevel[2],1)))/2/np.pi)
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
        self.couplingMinus = ((stateEig[1].dag()*tensor(basis(Nlevel[0],1),basis(Nlevel[1],0),basis(Nlevel[2],0))))*((stateEig[1].dag()*tensor(basis(Nlevel[0],0),basis(Nlevel[1],0),basis(Nlevel[2],1))))>0

        couplerLeakage1 = abs((stateEig[self.stateIndexList[1]].dag()*tensor(basis(Nlevel[0],0),basis(Nlevel[1],1),basis(Nlevel[2],0))))**2
        couplerLeakage2 = abs((stateEig[self.stateIndexList[2]].dag()*tensor(basis(Nlevel[0],0),basis(Nlevel[1],1),basis(Nlevel[2],0))))**2
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
        Nlevel = [8,8,8]
        para = [self.capacity,Linv,RList,flux,SMatrix,structure,Nlevel]
        DT = DifferentialTransmon(para)
        self.DT = DT
        [energyEig,stateEig] = DT.EigenGet()
        self.energyLevel = (energyEig-energyEig[0])/2/np.pi
        
        # 计算基矢对应的index
        stateNumList = [[0,0,0],[0,0,1],[1,0,0],[0,1,0],[1,0,1],[0,0,2],[2,0,0]]

        stateList = [tensor(basis(Nlevel[0],num[0]),basis(Nlevel[1],num[1]),basis(Nlevel[2],num[2])) for num in stateNumList]
        stateIndexList = [DT.findstate(state,'full') for state in stateList]
        idxList = []
        for idx in stateIndexList:
            if isinstance(idx,list):
                if idx[0] in idxList:
                    idxList.append(idx[1])
                else:
                    idxList.append(idx[0])
            else:
                idxList.append(idx)
        self.stateIndexList = idxList
        
        # id = [1,2,3];
        # if self.stateIndexList[3] in id:
        #     id.remove(self.stateIndexList[3])
        #     self.stateIndexList[1] = id[0];self.stateIndexList[2] = id[1]
        # else:
        #     id.remove(3)
            
        self.Ec = DT.Ec
        self.Ej = DT.Ej 
        
        idxmin = min([self.stateIndexList[1],self.stateIndexList[2]])
        self.couplingMinus = ((stateEig[self.stateIndexList[idxmin]].dag()*tensor(basis(Nlevel[0],1),basis(Nlevel[1],0),basis(Nlevel[2],0))))*((stateEig[self.stateIndexList[idxmin]].dag()*tensor(basis(Nlevel[0],0),basis(Nlevel[1],0),basis(Nlevel[2],1))))>0

        couplerLeakage1 = abs((stateEig[self.stateIndexList[1]].dag()*tensor(basis(Nlevel[0],0),basis(Nlevel[1],1),basis(Nlevel[2],0))))**2
        couplerLeakage2 = abs((stateEig[self.stateIndexList[2]].dag()*tensor(basis(Nlevel[0],0),basis(Nlevel[1],1),basis(Nlevel[2],0))))**2
        self.couplerLeakage = (couplerLeakage1[0,0]+couplerLeakage2[0,0])/2
        
        self.QCCoupling = abs((tensor(basis(Nlevel[0],0),basis(Nlevel[1],1),basis(Nlevel[2],0)).dag()*DT.GetHamilton()*tensor(basis(Nlevel[0],1),basis(Nlevel[1],0),basis(Nlevel[2],0)))/2/np.pi)
        self.QQDirectCoupling = abs((tensor(basis(Nlevel[0],1),basis(Nlevel[1],0),basis(Nlevel[2],0)).dag()*DT.GetHamilton()*tensor(basis(Nlevel[0],0),basis(Nlevel[1],0),basis(Nlevel[2],1)))/2/np.pi)
        
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
        Nlevel = [8,4,8]
        para = [self.capacity,Linv,RList,flux,SMatrix,structure,Nlevel]
        DT = DifferentialTransmon(para)
        self.DT = DT
        [energyEig,stateEig] = DT.EigenGet()
        self.energyLevel = (energyEig-energyEig[0])/2/np.pi
        self.stateEig = stateEig
        
        # 计算基矢对应的index
        # stateNumList = [[0,0,0],[0,0,1],[1,0,0],[0,1,0],[1,0,1],[0,0,2],[2,0,0],[0,2,0]]
        stateNumList = [[0,0,0],[0,0,1],[1,0,0],[0,1,0],[1,0,1],[0,0,2],[2,0,0]]

        stateList = [tensor(basis(Nlevel[0],num[0]),basis(Nlevel[1],num[1]),basis(Nlevel[2],num[2])) for num in stateNumList]
        stateIndexList = [DT.findstate(state,'full') for state in stateList]
        idxList = []
        for idx in stateIndexList:
            if isinstance(idx,list):
                if idx[0] in idxList:
                    idxList.append(idx[1])
                else:
                    idxList.append(idx[0])
            else:
                idxList.append(idx)
        self.stateIndexList = idxList
        id = [1,2,3];
        if self.stateIndexList[3] in id:
            id.remove(self.stateIndexList[3])
            self.stateIndexList[1] = id[0];self.stateIndexList[2] = id[1]
        else:
            id.remove(3)
        self.Ec = DT.Ec
        self.Ej = DT.Ej
        
        idxmin = min([self.stateIndexList[1],self.stateIndexList[2]])
        self.couplingMinus = ((stateEig[self.stateIndexList[idxmin]].dag()*tensor(basis(Nlevel[0],1),basis(Nlevel[1],0),basis(Nlevel[2],0))))*((stateEig[self.stateIndexList[idxmin]].dag()*tensor(basis(Nlevel[0],0),basis(Nlevel[1],0),basis(Nlevel[2],1))))>0

        couplerLeakage1 = abs((stateEig[self.stateIndexList[1]].dag()*tensor(basis(Nlevel[0],0),basis(Nlevel[1],1),basis(Nlevel[2],0))))**2
        couplerLeakage2 = abs((stateEig[self.stateIndexList[2]].dag()*tensor(basis(Nlevel[0],0),basis(Nlevel[1],1),basis(Nlevel[2],0))))**2
        self.couplerLeakage = (couplerLeakage1[0,0]+couplerLeakage2[0,0])/2
        
        self.QCCoupling = abs((tensor(basis(Nlevel[0],0),basis(Nlevel[1],1),basis(Nlevel[2],0)).dag()*DT.GetHamilton()*tensor(basis(Nlevel[0],1),basis(Nlevel[1],0),basis(Nlevel[2],0)))/2/np.pi)
        self.QQDirectCoupling = abs((tensor(basis(Nlevel[0],1),basis(Nlevel[1],0),basis(Nlevel[2],0)).dag()*DT.GetHamilton()*tensor(basis(Nlevel[0],0),basis(Nlevel[1],0),basis(Nlevel[2],1)))/2/np.pi)

class GroundedTransmonWithGroundCoupler():
    '''
    输出的频率单位为GHz
    '''
    def __init__(self, elementParameter, *args, **kwargs):
        self.capacity, self.resistance = elementParameter
        Linv = np.ones_like(self.capacity)*1e9
        RNAN = 1e9
        RList = np.ones([len(self.resistance),len(self.resistance)])*RNAN
        row,col = np.diag_indices_from(RList)
        RList[row,col] = self.resistance
        
        flux = np.zeros_like(RList)
        SMatrix = np.diag([1]*np.shape(self.capacity)[0])
        structure = [[0],[1],[2]]
        Nlevel = [8,4,8]
        para = [self.capacity,Linv,RList,flux,SMatrix,structure,Nlevel]
        DT = DifferentialTransmon(para)
        [energyEig,stateEig] = DT.EigenGet()
        self.energyLevel = (energyEig-energyEig[0])/2/np.pi
        
        # 计算基矢对应的index
        stateNumList = [[0,0,0],[0,0,1],[1,0,0],[0,1,0],[1,0,1],[0,0,2],[2,0,0]]
        stateList = [tensor(basis(Nlevel[0],num[0]),basis(Nlevel[1],num[1]),basis(Nlevel[2],num[2])) for num in stateNumList]
        self.stateIndexList = [DT.findstate(state,searchSpace='full') for state in stateList]
        id = [1,2,3]
        if self.stateIndexList[3] in id:
            id.remove(self.stateIndexList[3])
            self.stateIndexList[1] = id[0];self.stateIndexList[2] = id[1]
        else:
            id.remove(3)
        self.Ec = DT.Ec
        self.Ej = DT.Ej
        self.couplingMinus = ((stateEig[1].dag()*tensor(basis(Nlevel[0],1),basis(Nlevel[1],0),basis(Nlevel[2],0))))*((stateEig[1].dag()*tensor(basis(Nlevel[0],0),basis(Nlevel[1],0),basis(Nlevel[2],1))))>0
        
        couplerLeakage1 = abs((stateEig[self.stateIndexList[1]].dag()*tensor(basis(Nlevel[0],0),basis(Nlevel[1],1),basis(Nlevel[2],0))))**2
        couplerLeakage2 = abs((stateEig[self.stateIndexList[2]].dag()*tensor(basis(Nlevel[0],0),basis(Nlevel[1],1),basis(Nlevel[2],0))))**2
        self.couplerLeakage = (couplerLeakage1[0,0]+couplerLeakage2[0,0])/2
        
        self.QCCoupling = abs((tensor(basis(Nlevel[0],0),basis(Nlevel[1],1),basis(Nlevel[2],0)).dag()*DT.GetHamilton()*tensor(basis(Nlevel[0],1),basis(Nlevel[1],0),basis(Nlevel[2],0)))/2/np.pi)
        self.QQDirectCoupling = abs((tensor(basis(Nlevel[0],1),basis(Nlevel[1],0),basis(Nlevel[2],0)).dag()*DT.GetHamilton()*tensor(basis(Nlevel[0],0),basis(Nlevel[1],0),basis(Nlevel[2],1)))/2/np.pi)
    