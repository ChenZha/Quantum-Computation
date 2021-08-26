import numpy as np
from qutip import *
import math
from BasicQubit import BasicQubit

class TransmonQubit(BasicQubit):
    '''
    TransmonQubit类, 输入等效节点电容逆矩阵，等效节点电感逆矩阵，等效节点Ej矩阵，各个节点能级，生成Hamilton
    要求每个节点对地都构成一个类谐振子的比特，或者构成一个谐振子，以此对算符phi进行谐振子展开，进一步计算Hamilton，否则不满足这个类的条件
    计算所需的Ec，Ej均以GHz为单位
    '''
    def __init__(self , qubitsParameter , *args , **kwargs):
        self.__capacityInv, self.__inductanceInv, self.__EjMatrix,  self.__Nlevel = qubitsParameter #输入节点电容矩阵，电感矩阵，电阻矩阵，能级数目
        self.__numQubit = len(self.__Nlevel)
        self.sm,self.E_phi = self._BasicHamiltonOperator()
        Hamilton = self._H0Generation()
        super(TransmonQubit,self).__init__(Hamilton)

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
        # 固定参数
        hbar=1.054560652926899e-34
        h = hbar*2*np.pi
        e = 1.60217662e-19
        # 计算Cinv
        CInv = self.__capacityInv
        Ec = e**2/2*CInv/h

        # 计算Linv
        LInv = self.__inductanceInv
        EL = (hbar/2/e)**2*LInv/h
        # 计算EU
        EjMatrix = self.__EjMatrix
        Ej = np.diag(np.diag(EjMatrix))
        EU = EL + Ej

        # 谐振子展开
        alpha = np.diag(EU)
        beta = 8*np.diag(Ec)
        sm = self.sm
        smd = [op.dag() for op in sm]
        sn = [op.dag()*op for op in sm]
        XX = [(op+op.dag())/2 for op in sm]
        YY = [(-1j)*(op-op.dag())/2 for op in sm]
        phi = [np.sqrt(2)*(beta[ii]/alpha[ii])**(1/4)*XX[ii] for ii in range(len(alpha))]
        nn = [np.sqrt(2)*(alpha[ii]/beta[ii])**(1/4)*YY[ii] for ii in range(len(alpha))]

        H0 = sum([np.sqrt(alpha[ii]*beta[ii])*sn[ii] for ii in range(np.shape(Ec)[0])])
        Heta = sum([-Ej[ii,ii]*(phi[ii]**4/24-phi[ii]**6/math.factorial(6)+phi[ii]**8/math.factorial(8)) for ii in range(np.shape(Ec)[0])])
        Hc = sum([4*Ec[ii,jj]*nn[ii]*nn[jj]+1/2*EU[ii,jj]*phi[ii]*phi[jj]-EjMatrix[ii][jj]*((-phi[ii]**2/2+phi[ii]**4/24)*(-phi[jj]**2/2+phi[jj]**4/24)+(phi[ii]-phi[ii]**3/6)*(phi[jj]-phi[jj]**3/6)) for ii in range(np.shape(Ec)[0]) for jj in range(np.shape(Ec)[1]) if ii!=jj])

        Hamilton = H0+Heta+Hc
        return(Hamilton)
        