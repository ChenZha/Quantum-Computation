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
class TwoFloatingTransmonWithGroundedCoupler():
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
            [1,-1,0,0,0],
            [1,1,0,0,0],
            [0,0,1,0,0],
            [0,0,0,1,-1],
            [0,0,0,1,1],
        ])
        structure = [[0,1],[2],[3,4]]
        Nlevel = [10,10,10]
        para = [self.capacity,Linv,RList,flux,SMatrix,structure,Nlevel]
        DT = DifferentialTransmon(para)
        Hamilton = DT.GetHamilton()
        [energyEig,stateEig] = Hamilton.eigenstates()
        self.energyLevel = (energyEig-energyEig[0])/2/np.pi
        
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
            [1,-1,0,0,0],
            [1,1,0,0,0],
            [0,0,1,0,0],
            [0,0,0,1,-1],
            [0,0,0,1,1],
        ])
        structure = [[0,1],[2],[3,4]]
        Nlevel = [6,6,6]
        para = [self.capacity,Linv,RList,flux,SMatrix,structure,Nlevel]
        DT = DifferentialTransmon(para)
        Hamilton = DT.GetHamilton()
        [energyEig,stateEig] = Hamilton.eigenstates()
        self.energyLevel = (energyEig-energyEig[0])/2/np.pi
        
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
            [1,-1,0,0,0,0],
            [1, 1,0,0,0,0],
            [0,0,1,-1,0,0],
            [0,0,1, 1,0,0],
            [0,0,0,0,1,-1],
            [0,0,0,0,1, 1],
        ])
        structure = [[0,1],[2,3],[4,5]]
        Nlevel = [6,6,6]
        para = [self.capacity,Linv,RList,flux,SMatrix,structure,Nlevel]
        DT = DifferentialTransmon(para)
        Hamilton = DT.GetHamilton()
        [energyEig,stateEig] = Hamilton.eigenstates()
        self.energyLevel = (energyEig-energyEig[0])/2/np.pi
  
        
    