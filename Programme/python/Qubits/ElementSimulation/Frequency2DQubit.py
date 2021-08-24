import numpy as np
from qutip import *
from BasicQubit import BasicQubit

class Frequency2DQubit(BasicQubit):
    '''
    Frequency2DQubit类, 输入二维频率矩阵，耦合矩阵，非简谐性矩阵和能级，生成Hamilton
    '''
    def __init__(self , qubitsParameter , *args , **kwargs):
        # qubitsParameter结构:frequency(频率);coupling(耦合强度);eta_q(非简谐性);Nlevel(涉及的能级)
        self.__frequency , self.__coupling , self.__etaQ , self.__Nlevel = qubitsParameter
        self.__numQubits = int(np.size(self.__frequency)) #比特数目
        self.rowQubit , self.columnQubit = np.shape(self.frequency)
        if type(self.__Nlevel) == int:
            self.__Nlevel = self.__Nlevel*np.ones_like(self.__frequency,dtype=int)
        else:
            self.__Nlevel = np.array(self.__Nlevel)
        self.__NlevelLine = self.__Nlevel.reshape(1,-1)[0]
        self.__frequencyLine = self.__frequency.reshape(1,-1)[0]
        self.__etaQLine = self.__etaQ.reshape(1,-1)[0]

        if (not np.shape(self.__frequency) == np.shape(self.__etaQ) == np.shape(self.__Nlevel)) or (not len(self.__coupling)==2*len(self.__frequency)-1) or (not np.shape(self.__coupling)[1]==np.shape(self.__frequency)[1]):
            print('dimension error')
            raise AssertionError()
        # 生成基本的operator
        self.sm,self.E_uc,self.E_phi = self._BasicHamiltonOperator()
        # 生成未加驱动的基本哈密顿量
        self.H0 = self._H0Generation()
        super(Frequency2DQubit,self).__init__(self.H0)
        
    def _BasicHamiltonOperator(self):
        '''
        生成构成哈密顿量的基本operator
        '''
        sm=[]
        for II in range(0,self.__numQubit):
            cmdstr=[destroy(self.__Nlevel[JJ]) if II==JJ else qeye(self.__Nlevel[JJ]) for JJ in range(self.__numQubit)]
            sm.append(tensor(*cmdstr))
        sm = np.array(sm).reshape((self.rowQubit,self.ColumnQubit)) 

        E_uc = []
        for II in range(0,self.__numQubit):
            if self.__Nlevel[II]>2:
                cmdstr=[basis(self.__numQubit[JJ],2)*basis(self.__numQubit[JJ],2).dag() if II==JJ else qeye(self.__Nlevel[JJ]) for JJ in range(self.__numQubit)]                  
            else:
                cmdstr=[Qobj(np.zeros([self.__numQubit[JJ],self.__numQubit[JJ]])) if II==JJ else qeye(self.__Nlevel[JJ]) for JJ in range(self.__numQubit)]
            E_uc.append(tensor(*cmdstr))
        E_uc = np.array(E_uc).reshape((self.rowQubit,self.ColumnQubit))

        E_phi=[]
        for II in range(0,self.__numQubit):
            basisMatrix = np.diag([1]*(self.__Nlevel[II]-1),1) + np.diag([1]*(self.__Nlevel[II]-1),-1)
            cmdstr=[Qobj(basisMatrix) if II==JJ else qeye(self.__Nlevel[JJ]) for JJ in range(0,self.__numQubit)]
            E_phi.append(tensor(*cmdstr))   
        E_phi = np.array(E_phi).reshape((self.rowQubit,self.ColumnQubit))  

        return([sm,E_uc,E_phi])
    def _H0Generation(self):
        '''
        根据qubit参数，生成未加驱动的基本哈密顿量
        '''
        self.rowQubit , self.columnQubit
        Hq = sum([self.__frequency[index_x,index_y]*self.sm[index_x,index_y].dag()*self.sm[index_x,index_y] + self.__etaQ[index_x,index_y]*self.E_uc[index_x,index_y] for index_x in range(self.rowQubit) for index_y in range(self.columnQubit)])
        if self.num_qubits != 1:
            HcRow = sum([self.coupling[2*index_x+1,index_y]*(self.sm[index_x,index_y]+self.sm[index_x,index_y].dag())*(self.sm[index_x+1,index_y]+self.sm[index_x+1,index_y].dag()) for index_x in range(self.rowQubit) for index_y in range(self.columnQubit) if index_x != self.rowQubit-1])
            HcColumn = sum([self.coupling[2*index_x,index_y]*(self.sm[index_x,index_y]+self.sm[index_x,index_y].dag())*(self.sm[index_x,index_y+1]+self.sm[index_x,index_y+1].dag()) for index_x in range(self.rowQubit) for index_y in range(self.columnQubit) if index_y != self.columnQubit-1])
        else:
            HcRow = 0
            HcColumn = 0
        H0 = Hq+HcRow+HcColumn
        return(H0)