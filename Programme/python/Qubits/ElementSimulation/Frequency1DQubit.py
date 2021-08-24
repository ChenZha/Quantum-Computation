import numpy as np
from qutip import *
from BasicQubit import BasicQubit

class Frequency1DQubit(BasicQubit):
    '''
    Frequency1DQubit类, 输入频率矩阵，耦合矩阵，非简谐性矩阵和能级，生成Hamilton
    '''
    def __init__(self , qubitsParameter , *args , **kwargs):
        # qubitsParameter结构:frequency(频率);coupling(耦合强度);eta_q(非简谐性);Nlevel(涉及的能级)
        self.__frequency , self.__coupling , self.__etaQ , self.__Nlevel = qubitsParameter #输入节点频率矩阵，耦合矩阵，非简谐性矩阵，能级数目
        self.__numQubit = len(self.__Nlevel)
        if type(self.__Nlevel) == int:
                self.__Nlevel = [self.__Nlevel]*self.__numQubit
        if not len(self.__frequency) == len(self.__coupling)+1 == len(self.__etaQ) == len(self.__Nlevel):
            print('dimension error')
            raise AssertionError()
        # 生成基本的operator
        self.sm,self.E_uc,self.E_phi = self._BasicHamiltonOperator()
        # 生成未加驱动的基本哈密顿量
        self.H0 = self._H0Generation()
        super(Frequency1DQubit,self).__init__(self.H0)
        
    def _BasicHamiltonOperator(self):
        '''
        生成构成哈密顿量的基本operator
        '''
        sm=[]
        for II in range(0,self.__numQubit):
            cmdstr=[destroy(self.__Nlevel[JJ]) if II==JJ else qeye(self.__Nlevel[JJ]) for JJ in range(self.__numQubit)]
            sm.append(tensor(*cmdstr))

        E_uc = []
        for II in range(0,self.__numQubit):
            if self.__Nlevel[II]>2:
                cmdstr=[basis(self.__numQubit[JJ],2)*basis(self.__numQubit[JJ],2).dag() if II==JJ else qeye(self.__Nlevel[JJ]) for JJ in range(self.__numQubit)]                  
            else:
                cmdstr=[Qobj(np.zeros([self.__numQubit[JJ],self.__numQubit[JJ]])) if II==JJ else qeye(self.__Nlevel[JJ]) for JJ in range(self.__numQubit)]
            E_uc.append(tensor(*cmdstr))

        E_phi=[]
        for II in range(0,self.__numQubit):
            basisMatrix = np.diag([1]*(self.__Nlevel[II]-1),1) + np.diag([1]*(self.__Nlevel[II]-1),-1)
            cmdstr=[Qobj(basisMatrix) if II==JJ else qeye(self.__Nlevel[JJ]) for JJ in range(0,self.__numQubit)]
            E_phi.append(tensor(*cmdstr))    

        return([sm,E_uc,E_phi])
    def _H0Generation(self):
        '''
        根据qubit参数，生成未加驱动的基本哈密顿量
        '''
        Hq = sum([self.__frequency[index]*self.sm[index].dag()*self.sm[index] + self.__etaQ[index]*self.E_uc[index]  for index in range(self.__numQubit)])
        if self.num_qubits != 1:
            Hc = sum([self.__coupling[index]*(self.sm[index]+self.sm[index].dag())*(self.sm[index+1]+self.sm[index+1].dag()) for index in range(self.__numQubit-1)])
        else:
            Hc = 0
        H0 = Hq+Hc
        return(H0)