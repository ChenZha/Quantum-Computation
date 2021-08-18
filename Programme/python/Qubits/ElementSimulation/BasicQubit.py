from operator import index
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
        self.E_uc,self.E_e,self.E_g,self.X_m,self.Y_m= self._BasicMeasurementOperator()
        #找到本征值和本征态
        [self.energyEig,self.stateEig] = self.__Hamilton.eigenstates()
      

    def _BasicMeasurementOperator(self):
        '''
        生成构成用于测量的基本operator
        '''
        Nlevel = self.__Hamilton.dims[0]
        numQubit = len(Nlevel)
        E_uc = []
        for II in range(0,numQubit):
            if Nlevel[II]>2:
                cmdstr=[basis(numQubit[JJ],2)*basis(numQubit[JJ],2).dag() if II==JJ else qeye(Nlevel[JJ]) for JJ in range(numQubit)]                  
            else:
                cmdstr=[Qobj(np.zeros([numQubit[JJ],numQubit[JJ]])) if II==JJ else qeye(Nlevel[JJ]) for JJ in range(numQubit)]
            E_uc.append(tensor(*cmdstr))

        E_e=[]
        for II in range(0,numQubit):
            cmdstr=[basis(Nlevel[JJ],1)*basis(Nlevel[JJ],1).dag() if II==JJ else qeye(Nlevel[JJ]) for JJ in range(0,numQubit)]
            E_e.append(tensor(*cmdstr))
        
        E_g=[]
        for II in range(0,numQubit):
            cmdstr=[basis(Nlevel[JJ],0)*basis(Nlevel[JJ],0).dag() if II==JJ else qeye(Nlevel[JJ]) for JJ in range(0,numQubit)]
            E_g.append(tensor(*cmdstr))

        X_m=[]
        for II in range(0,numQubit):
            basisMatrix = np.zeros([Nlevel[II],Nlevel[II]])
            basisMatrix[0,1] = 1;basisMatrix[1,0] = 1
            cmdstr=[Qobj(basisMatrix) if II==JJ else qeye(Nlevel[JJ]) for JJ in range(0,numQubit)]
            X_m.append(tensor(*cmdstr))    

        Y_m=[]
        for II in range(0,numQubit):
            basisMatrix = np.zeros([Nlevel[II],Nlevel[II]])
            basisMatrix[0,1] = -1j;basisMatrix[1,0] = 1j
            cmdstr=[Qobj(basisMatrix) if II==JJ else qeye(Nlevel[JJ]) for JJ in range(0,numQubit)] 
            Y_m.append(tensor(*cmdstr))  

        return([E_uc,E_e, E_g , X_m, Y_m]) 
    def _strTostate(self,state):
        '''
        将0,1字符串转换为量子态
        '''
        Nlevel = self.__Hamilton.dims[0]
        qustate = [basis(Nlevel[ii],int(eval(state[ii]))) for ii in range(len(state))]
        qustate = tensor(*qustate)
        return(qustate)
    def _numTostate(self,state):
        '''
        将0,1 int list 转换为量子态
        '''
        Nlevel = self.__Hamilton.dims[0]
        qustate = [basis(Nlevel[ii],int(state[ii])) for ii in range(len(state))]
        qustate = tensor(*qustate)
        return(qustate)
    def findstate(self,state,searchSpace='full',mark = 'string'):
        '''
        在self.stateEig中找到state对应的index,对于简并的态，01探测到的是01+10，10探测到的是01-10
        '''
        Nlevel = self.__Hamilton.dims[0]
        numQubit = len(Nlevel)
        indexLevel = None
        assert int(len(state.dims[0])) == numQubit

        if searchSpace == 'full':
            searchLen=len(self.State_eig)
        elif searchSpace == 'brev':
            searchLen=min(4*numQubit,len(self.stateEig))
        else:
            print('search space error')

        threshold = 0.08
        probeResult = [expect(ket2dm(self.stateEig[ii]),state) for ii in range(searchLen)]
        probeResultSorted = sorted(probeResult, reverse=True)
        isDegenerated = abs(probeResultSorted[0]-probeResultSorted[1])<threshold
    
        if isDegenerated:
            expect1 = (self.stateEig[probeResult.index(probeResultSorted[0])].dag()*state).data.toarray()[0][0]
            expect2 = (self.stateEig[probeResult.index(probeResultSorted[1])].dag()*state).data.toarray()[0][0]
            if expect1*expect2>0:
                return(probeResult.index(probeResultSorted[0]))
            else:
                return(probeResult.index(probeResultSorted[1]))
        else:
            return(probeResult.index(probeResultSorted[0]))
            

