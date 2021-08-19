import numpy as np
from qutip import *
from BasicQubit import BasicQubit

class TransmonQubit(BasicQubit):
    '''
    TransmonQubit类, 输入电容矩阵，电感矩阵，电阻矩阵和能级，生成Hamilton
    '''
    def __init__(self , qubitsParameter , *args , **kwargs):
        self.__capacity, self.__inductance, self.__resistance, self.__Nlevel = qubitsParameter #输入节点电容矩阵，电感矩阵，电阻矩阵，能级数目
        self.__numQubit = len(self.__Nlevel)
    
    def _BasicHamiltonOperator(self):
        '''
        生成构成哈密顿量的基本operator
        '''
        sm=[]
        for II in range(0,self.__numQubit):
            cmdstr=[destroy(self.__Nlevel[JJ]) if II==JJ else qeye(self.__Nlevel[JJ]) for JJ in range(self.__numQubit)]
            sm.append(tensor(*cmdstr))

        E_phi=[]
        for II in range(0,self.__numQubit):
            basisMatrix = np.diag([1]*(self.__Nlevel[II]-1),1) + np.diag([1]*(self.__Nlevel[II]-1),-1)
            cmdstr=[Qobj(basisMatrix) if II==JJ else qeye(self.__Nlevel[JJ]) for JJ in range(0,self.__numQubit)]
            E_phi.append(tensor(*cmdstr))    

        return([sm,E_phi])
    def _H0Generation(self):
        