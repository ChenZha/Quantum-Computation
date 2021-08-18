import numpy as np
from qutip import *
from multiprocessing import Pool

class BasicQubit():
    '''
    最原始的qubit类，输入qubit的哈密顿量，
    方法包含基础测量operator的生成,比特状态寻址, 态的演化，process tomography, 态演化的画图
    '''
    def __init__(self , Hamilton , *args , **kwargs):
        self.__Hamilton = Hamilton #输入节点电容矩阵，电感矩阵，电阻矩阵，能级数目
    # 生成基本的测量operator
        self.sm,self.E_uc,self.E_e,self.E_g,self.X_m,self.Y_m,self.E_phi= self._BasicOperator()
      

    def _BasicMeasurementOperator(self):
        '''
        生成构成哈密顿量的基本operator
        '''
        E_uc = []
        for II in range(0,self.__numQubit):
            if self.__Nlevel[II]>2:
                cmdstr=[basis(self.__numQubit[JJ],2)*basis(self.__numQubit[JJ],2).dag() if II==JJ else qeye(self.__Nlevel[JJ]) for JJ in range(self.__numQubit)]                  
            else:
                cmdstr=[Qobj(np.zeros([self.__numQubit[JJ],self.__numQubit[JJ]])) if II==JJ else qeye(self.__Nlevel[JJ]) for JJ in range(self.__numQubit)]
            E_uc.append(tensor(*cmdstr))

        E_e=[]
        for II in range(0,self.__numQubit):
            cmdstr=[basis(self.__Nlevel[JJ],1)*basis(self.__Nlevel[JJ],1).dag() if II==JJ else qeye(self.__Nlevel[JJ]) for JJ in range(0,self.__numQubit)]
            E_e.append(tensor(*cmdstr))
        
        E_g=[]
        for II in range(0,self.__numQubit):
            cmdstr=[basis(self.__Nlevel[JJ],0)*basis(self.__Nlevel[JJ],0).dag() if II==JJ else qeye(self.__Nlevel[JJ]) for JJ in range(0,self.__numQubit)]
            E_g.append(tensor(*cmdstr))

        X_m=[]
        for II in range(0,self.__numQubit):
            basisMatrix = np.zeros([self.__Nlevel[II],self.__Nlevel[II]])
            basisMatrix[0,1] = 1;basisMatrix[1,0] = 1
            cmdstr=[Qobj(basisMatrix) if II==JJ else qeye(self.__Nlevel[JJ]) for JJ in range(0,self.__numQubit)]
            X_m.append(tensor(*cmdstr))    

        Y_m=[]
        for II in range(0,self.__numQubit):
            basisMatrix = np.zeros([self.__Nlevel[II],self.__Nlevel[II]])
            basisMatrix[0,1] = -1j;basisMatrix[1,0] = 1j
            cmdstr=[Qobj(basisMatrix) if II==JJ else qeye(self.__Nlevel[JJ]) for JJ in range(0,self.__numQubit)] 
            Y_m.append(tensor(*cmdstr))  

        return([E_uc,E_e, E_g , X_m, Y_m])
    
    def _strTostate(self,state):
        '''
        将0,1字符串转换为量子态
        '''
        qustate = [basis(self.__Nlevel[ii],int(eval(state[ii]))) for ii in range(len(state))]
        qustate = tensor(*qustate)
        return(qustate)
    def _numTostate(self,state):
        '''
        将0,1 int list 转换为量子态
        '''
        qustate = [basis(self.__Nlevel[ii],int(state[ii])) for ii in range(len(state))]
        qustate = tensor(*qustate)
        return(qustate)
    def _findstate(self,state,searchSpace='full',mark = 'string'):
        '''
        在self.state中找到各个态对应的位置
        '''
        indexLevel = None
        assert int(len(state)) == self.num_qubits

        # e = np.zeros(self.num_qubits,dtype = 'int') #记录寻找的态对应每个比特上的能级
        # s = np.zeros(self.num_qubits) #记录某个本征态的每个比特上相应能级的信息
        # for i in range(self.num_qubits):
        #     e[i] = int(eval(state[i]))

        if search_space == 'full':
            search_len=len(self.State_eig)
        elif search_space == 'brev':
            search_len=min(3*self.num_qubits,len(self.State_eig))
        else:
            print('search space error')
        if mark == 'string':
            qustate = self._strTostate(state)
            for index in range(search_len):
                exp = expect(ket2dm(self.State_eig[index]),qustate)
                if exp>0.5:
                    index_level = index
                    return(index_level)
                # for i in range(self.num_qubits):
                #     s[i] = np.abs(ptrace(self.State_eig[index],i)[e[i]][0][e[i]])
                # if all(s>=0.5):
                #     index_level = index
                #     return(index_level)
        elif mark == 'number':
            qustate = self._numTostate(state)
            for index in range(search_len):
                exp = expect(ket2dm(self.State_eig[index]),qustate)
                if exp>0.5:
                    index_level = index
                    return(index_level)
        else:
            print('Wrong Mark')



        print('No State')
        return(None)

