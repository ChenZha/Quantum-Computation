import numpy as np
import math
import matplotlib.pyplot as plt
from qutip import *
import functools
from multiprocessing import Pool
from functools import reduce
import matplotlib as mpl
from mpl_toolkits.mplot3d import Axes3D

class BasicQubit():
    '''
    最原始的qubit类，输入qubit的哈密顿量，
    方法包含基础测量operator的生成,比特状态寻址, 态的演化，平均值的演化，process tomography, 态演化的画图
    '''
    # default evolution parameter
    default_options=Options()
    default_options.atol=1e-8
    default_options.rtol=1e-6
    default_options.first_step=0.01
    default_options.num_cpus=8
    default_options.nsteps=1e6
    default_options.gui='True'
    default_options.ntraj=1000
    default_options.rhs_reuse=True

    def __init__(self , Hamilton , *args , **kwargs):
        self.__Hamilton = Hamilton #输入节点电容矩阵，电感矩阵，电阻矩阵，能级数目
        # 生成基本的测量operator
        self.E_uc,self.E_e,self.E_g,self.X_m,self.Y_m= self._BasicMeasurementOperator()
        #找到本征值和本征态
        [self.energyEig,self.stateEig] = self.__Hamilton.eigenstates()
        self.firstExcited = self._FirstExcite()
    def GetHamilton(self):
        return(self.__Hamilton)

    def _BasicMeasurementOperator(self):
        '''
        生成构成用于测量的基本operator
        输入：
            无
        输出：
            [E_uc, E_e, E_g, X_m, Y_m]：Qobj list
        '''
        Nlevel = self.__Hamilton.dims[0]
        numQubit = len(Nlevel)
        E_uc = []
        for II in range(0,numQubit):
            if Nlevel[II]>2:
                cmdstr=[basis(Nlevel[JJ],2)*basis(Nlevel[JJ],2).dag() if II==JJ else qeye(Nlevel[JJ]) for JJ in range(numQubit)]                  
            else:
                cmdstr=[Qobj(np.zeros([Nlevel[JJ],Nlevel[JJ]])) if II==JJ else qeye(Nlevel[JJ]) for JJ in range(numQubit)]
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
            basisMatrix = np.zeros([Nlevel[II],Nlevel[II]],dtype=complex)
            basisMatrix[0,1] = 1;basisMatrix[1,0] = 1
            cmdstr=[Qobj(basisMatrix) if II==JJ else qeye(Nlevel[JJ]) for JJ in range(0,numQubit)]
            X_m.append(tensor(*cmdstr))    

        Y_m=[]
        for II in range(0,numQubit):
            basisMatrix = np.zeros([Nlevel[II],Nlevel[II]],dtype=complex)
            basisMatrix[0,1] = -1j;basisMatrix[1,0] = 1j
            cmdstr=[Qobj(basisMatrix) if II==JJ else qeye(Nlevel[JJ]) for JJ in range(0,numQubit)] 
            Y_m.append(tensor(*cmdstr))  

        return([E_uc, E_e, E_g, X_m, Y_m]) 
    def _strTostate(self,state):
        '''
        将0,1字符串转换为量子态
        输入：
            state：string
        输出：
            state：Qobj
        '''
        Nlevel = self.__Hamilton.dims[0]
        qustate = [basis(Nlevel[ii],int(eval(state[ii]))) for ii in range(len(state))]
        qustate = tensor(*qustate)
        return(qustate)
    def _numTostate(self,state):
        '''
        将0,1 int list 转换为量子态
        输入：
            state：int list
        输出：
            state：Qobj
        '''
        Nlevel = self.__Hamilton.dims[0]
        qustate = [basis(Nlevel[ii],int(state[ii])) for ii in range(len(state))]
        qustate = tensor(*qustate)
        return(qustate)
    def findstate(self,state,searchSpace='brev'):
        '''
        在self.stateEig中找到state对应的index,对于简并的态，01探测到的是01+10，10探测到的是01-10
        输入：
            state：Qobj
        输出：
            index：int
        '''
        Nlevel = self.__Hamilton.dims[0]
        numQubit = len(Nlevel)
        indexLevel = None
        assert int(len(state.dims[0])) == numQubit

        if searchSpace == 'full':
            searchLen=len(self.stateEig)
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
    def _FirstExcite(self):
        '''
        找到基态，以及各个比特的第一激发态的位置
        n个比特有n+1个值，第一个为基态位置index,后面n个为n个比特第一激发态位置index
        '''
        Nlevel = self.__Hamilton.dims[0]
        numQubit = len(Nlevel)
        firstExcited = []
        firstExcited.append(self.findstate(self._numTostate([0]*numQubit),searchSpace='brev')) #基态的位置index
        for II in range(0,numQubit):
            stateNum = [0]*numQubit
            stateNum[II] = 1
            firstExcited.append(self.findstate(self._numTostate(stateNum),searchSpace='brev')) #各第一激发态位置index
        return(firstExcited)
    def QutipEvolution(self , drive = None , psi = basis(3,0) , collapse = [] , track_plot = False , RWF = 'CpRWF' , RWAFreq = 0.0 , argument = {'T_p':100,'T_copies':201} , options = default_options):
        '''
        计算当前比特在psi初态，经drive驱动，最终得到的末态finalState
        参数：
        drive:驱动哈密顿量，形式[H1,H2,H3]
        psi：初态
        collapse:退相干算符
        RWF:旋转坐标系的种类
        RWA_freq:使用custom_RWF种类时,与CpRWA频率相差的频率
        argument：关于演化的参数,主要是drive中的参数，必须包含总时间T_p,时间份数T_copies

        返回：
        演化的终态
        '''
        # 生成演化Hamilton
        self.evolutionH = self.__Hamilton
        if drive != None:
            self.evolutionH = [self.__Hamilton]
            for H_drive in drive:
                self.evolutionH.append(H_drive)

        # 初态psi 
        self.iniPsi = psi

        # 时间序列
        T_p = argument['T_P']
        T_copies = argument['T_copies']
        self.tlist = np.linspace(0,T_p,T_copies)
        # collapse
        self.collapse = collapse
        # evolution
        self.result = mesolve(self.evolutionH , self.iniPsi , self.tlist , c_ops = self.collapse , e_ops = [] , args = argument , options = options)
        
        # RWF
        self.RWF = RWF
        self.RWAFreq = RWAFreq
        # Rotation Frame of final state
        UF = self._RF_Generation(self.tlist[-1])
        # Final State in Rotation Frame(pure state)
        stateType = self.result.states[-1].type
        if stateType == 'ket':
            finalState = UF*self.result.states[-1]
        elif stateType == 'oper':
            finalState = UF*self.result.states[-1]*UF.dag()
        else:
            print('statetype error')
        if track_plot:
            self._TrackPlot()
        return(finalState)
    def DifferentialEvolution(self, drive = None , psi = basis(3,0) , collapse = [] , track_plot = False , RWF = 'CpRWF' , RWAFreq = 0.0 , argument = {'T_p':100,'T_copies':201}):
        self.iniPsi = psi
        self.collapse = collapse
        self.RWF = RWF
        self.RWAFreq = RWAFreq
        self.evolutionDH = drive
        
        self.tList = np.linspace(0,argument['T_p'],argument['T_copies'])
        numslice = 30
        timeStep = np.linspace(self.tList[1],self.tList[-1],numslice*(len(self.tList)-1)+1)
        stateStep = []
        stateStep.append(self.iniPsi)
        HamiltonTimeList = np.diff(timeStep)/2+timeStep[0:-1-1]
        HamiltonList = []
        if len(collapse)==0:
            for ii in range(len(HamiltonTimeList)):#生成不同时间点时的哈密顿量
                HamiltonListTemp=self.__Hamilton
                if len(drive)>1:
                    for jj in range(1,len(drive)):
                        timefunction = drive[jj][1]
                        HamiltonListTemp = HamiltonListTemp + drive[jj][0]*timefunction(HamiltonTimeList[ii])
                HamiltonList.append(HamiltonListTemp)
                stateStepNew = stateStep[ii]+HamiltonListTemp*stateStep[ii]*(timeStep[ii+1]-timeStep[ii])/(1j)
                stateStep.append(stateStepNew)

        else:
            for ii in range(len(HamiltonTimeList)):#生成不同时间点时的哈密顿量
                HamiltonListTemp=self.__Hamilton
                if len(drive)>1:
                    for jj in range(1,len(drive)):
                        timefunction = drive[jj][1]
                        HamiltonListTemp = HamiltonListTemp+drive[jj][0]*timefunction(HamiltonTimeList[ii])
                HamiltonList.append(HamiltonListTemp)
                stateStepTemp = -1j*((HamiltonListTemp*stateStep[ii])-(stateStep[ii]*HamiltonListTemp))
                for jj in range(len(collapse)):
                    stateStepTemp = stateStepTemp + collapse[jj]*(stateStep[ii])*(collapse[jj].dag())-(collapse[jj].dag()*(collapse[jj])*(stateStep[ii])+stateStep[ii]*(collapse[jj].dag())*(collapse[jj]))/2
                stateStepNew = stateStep[ii]+stateStepTemp*(timeStep[ii+1]-timeStep[ii])
                stateStep.append(stateStepNew)

        self.result = stateStep[1:-1:numslice]
        
        if track_plot:
            self._TrackPlot()
        return(self.result)
    def _RF_Generation(self,select_time):
        '''
        生成时间t时刻的旋转坐标系矩阵
        '''
        Nlevel = self.__Hamilton.dims[0]
        numQubit = len(Nlevel)
        U = []
        if self.RWF=='CpRWF':
            for index in range(numQubit):
                mat = np.diag(np.ones(Nlevel[index],dtype = complex))
                mat[1,1] = np.exp(1j*(self.energyEig[self.firstExcited[index+1]]-self.energyEig[self.firstExcited[0]])*select_time)
                RW = Qobj(mat)
                U.append(RW)
        elif self.RWF=='NoRWF':
            for index in range(numQubit):
                U.append(qeye(Nlevel[index]))
        elif self.RWF=='custom_RWF':
            for index in range(numQubit):
                if type(self.RWAFreq) == float or type(self.RWAFreq) == int:
                    self.RWAFreq = [self.RWAFreq]*self.numQubit
                mat = np.diag(np.ones(self.Nlevel[index],dtype = complex))
                mat[1,1] = np.exp(1j*(self.energyEig[self.firstExcited[index+1]]-self.energyEig[self.firstExcited[0]]+self.RWAFreq[index])*select_time)
                RW = Qobj(mat)
                U.append(RW)
        else:
            raise ValueError('RWF ERROR')
        UF = tensor(*U)
        return(UF)
    def ExpectEvolution(self, operator):
        '''
        得到某个operator的随时间演化序列
        '''
        evolutionList = np.zeros(len(self.tlist))
        evolutionList = np.array([expect(self._RF_Generation(self.tlist[t_index]).dag()*(operator)*self._RF_Generation(self.tlist[t_index]),self.result.states[t_index]) for t_index in range(len(self.tlist))])
        return(evolutionList)
    def _TrackPlot(self):
        '''
        画出各个比特状态在Bloch球中的轨迹
        '''
        Nlevel = self.__Hamilton.dims[0]
        numQubit = len(Nlevel)
        nx = np.zeros([numQubit,len(self.tlist)])
        ny = np.zeros([numQubit,len(self.tlist)])
        nz = np.zeros([numQubit,len(self.tlist)])
        nn = np.zeros([numQubit,len(self.tlist)])
        leakage = np.zeros([numQubit,len(self.tlist)])
        # 各个时间点，各个比特在X,Y,Z轴上投影
        
        for q_index in range(numQubit):
            opx = self.X_m[q_index]
            opy = self.Y_m[q_index]
            opz = self.E_g[q_index]-self.E_e[q_index]
            opn = self.E_e[q_index]
            nx[q_index] = self.ExpectEvolution(opx)
            ny[q_index] = self.ExpectEvolution(opy)
            nz[q_index] = self.ExpectEvolution(opz)
            nn[q_index] = self.ExpectEvolution(opn)
            leakage[q_index] = self.ExpectEvolution(self.E_uc[q_index])
        
        
        # 画图
        fig,axes = plt.subplots(numQubit,1)
        for q_index in range(numQubit):
            if numQubit > 1:
                axes[q_index].plot(self.tlist,nx[q_index],label = 'x'+str(q_index))
                axes[q_index].plot(self.tlist,ny[q_index],label = 'y'+str(q_index))
                axes[q_index].plot(self.tlist,nz[q_index],label = 'z'+str(q_index))
                axes[q_index].plot(self.tlist,leakage[q_index],label = 'leakage'+str(q_index))
                axes[q_index].set_xlabel('t');axes[q_index].set_ylabel('population of qubit'+str(q_index));
                axes[q_index].legend(loc = 'upper left')
            else:
                axes.plot(self.tlist,nx[q_index],label = 'x'+str(q_index))
                axes.plot(self.tlist,ny[q_index],label = 'y'+str(q_index))
                axes.plot(self.tlist,nz[q_index],label = 'z'+str(q_index))
                axes.plot(self.tlist,leakage[q_index],label = 'leakage'+str(q_index))
                axes.set_xlabel('t');axes.set_ylabel('population of qubit'+str(q_index));
                axes.legend(loc = 'upper left')
            sphere = Bloch()
            sphere.add_points([nx[q_index] , ny[q_index] , nz[q_index]])
            sphere.add_vectors([nx[q_index][-1],ny[q_index][-1],nz[q_index][-1]])
            sphere.zlabel[0] = 'qubit'+str(q_index)+'\n$\\left|0\\right>$'
            sphere.make_sphere()

        xx,yy = np.meshgrid([i+1 for i in range(numQubit+1)],self.tlist)
        fig, ax = plt.subplots()
        c = ax.pcolormesh(xx,yy,nn.T,cmap='jet')
        fig.colorbar(c, ax=ax)
        plt.show()

    def process(self , drive = None ,  retainNode = [0,2], processPlot  = False , RWF = 'CpRWF' , RWAFreq = 0.0 ,parallel = False , argument = {'T_p':100,'T_copies':201} , options = default_options):
        '''
        对当前比特施加驱动drive，表征整个state space的演化过程(只取每个比特二能级的部分)
        参数：
        drive：驱动哈密顿量
        process_plot：是否画出演化矩阵(实部与虚部)
        RWF:旋转坐标系的种类
        RWA_freq:使用custom_RWF种类时,与CpRWA频率相差的频率
        parallel：是否进行并行计算(如果外部还需要并行计算，这里要去Flase)
        argument：关于演化的参数,主要是drive中的参数，必须包含总时间T_p,时间份数T_copies

        返回：
        2^n维的演化矩阵
        '''
        Nlevel = self.__Hamilton.dims[0]
        numQubit = len(Nlevel)
        self.retainNode = retainNode
        # 生成2^n个基矢,以及各个基矢在多能级系统中的位置
        basic , loc = self._basic_generation()
        # 只取保留的node的基矢，抛弃的node保持在0态
        abandonNode = list(set(np.arange(numQubit)) - set(retainNode))

        retainIndex = [ii for ii in range(len(loc)) if [bin(ii)[2:].zfill(numQubit)[jj] for jj in abandonNode] == ['0']*len(abandonNode)]
        basic = [basic[ii] for ii in retainIndex]
        loc = [loc[ii] for ii in retainIndex]

        finalState = [] #基矢演化得到的末态
        if parallel:
            p = Pool()
            result_final = [p.apply_async(self.QutipEvolution,(drive , basic[i] , [] , False , RWF, RWAFreq,argument , options)) for i in range(len(basic)) ]
            finalState = [result_final[i].get() for i in range(len(result_final))]
            p.close()
            p.join()
        else:
            finalState = [self.QutipEvolution(drive , Phi , [] , False , RWF ,RWAFreq,argument , options) for Phi in basic]


        process = np.column_stack([finalState[i].data.toarray() for i in range(len(finalState))])[loc,:] #只取演化矩阵中二能级部分
        angle = np.angle(process[0][0])
        process = process*np.exp(-1j*angle)#消除global phase
        process = Qobj(process, dims=[[2]*len(retainNode),[2]*len(retainNode)])

        if processPlot:
            self.Operator_View(process,'Process')

        return(process)

    def _basic_generation(self):
        '''生成2^n个基矢,以及各个基矢在多能级系统中的位置'''
        Nlevel = self.__Hamilton.dims[0]
        numQubit = len(Nlevel)
        basic = []
        loc = []
        for index in range(2**numQubit):
            II = index
            code = '' #转化成二进制的字符串形式
            state = [] #生成一个基矢
            l = 0 #在3能级中的位置
            for JJ in range(numQubit):
                number = np.int(np.mod(II,2))
                code = str(number)+code
                state.insert(0,basis(Nlevel[JJ] , number))
                if JJ == 0:
                    l += number
                else:
                    mullist = Nlevel[-1:-1-JJ:-1]
                    mulval = reduce(lambda x,y:x*y,mullist)
                    l += number*mulval
                II = np.int(np.floor(II/2))
            assert len(code) == len(state) == numQubit    
            basic.append(tensor(*state))
            loc.append(l)    
        return(basic,loc)
    def Operator_View(self,M,lab):
        '''
        将一个矩阵可视化，标题为lab
        '''
        if isinstance(M, Qobj):
            # extract matrix data from Qobj
            M = M.full()

        n = np.size(M)
        xpos, ypos = np.meshgrid(range(M.shape[0]), range(M.shape[1]))
        xpos = xpos.T.flatten() - 0.5
        ypos = ypos.T.flatten() - 0.5
        zpos = np.zeros(n)
        dx = dy = 0.8 * np.ones(n)
        
        dz = np.real(M.flatten())
        z_min = min(dz)
        z_max = max(dz)
        if z_min == z_max:
            z_min -= 0.1
            z_max += 0.1
        norm = mpl.colors.Normalize(z_min, z_max)
        cmap = mpl.cm.get_cmap('jet')  # Spectral
        colors = cmap(norm(dz))
        fig = plt.figure()
        ax = Axes3D(fig, azim=-35, elev=35)
        ax.bar3d(xpos, ypos, zpos, dx, dy, dz, color=colors)
        ax.set_title(lab+'_Real')
        cax, kw = mpl.colorbar.make_axes(ax, shrink=.75, pad=.0)
        mpl.colorbar.ColorbarBase(cax, cmap=cmap, norm=norm)
        
        dz = np.imag(M.flatten())
        z_min = min(dz)
        z_max = max(dz)
        if z_min == z_max:
            z_min -= 0.1
            z_max += 0.1
        norm = mpl.colors.Normalize(z_min, z_max)
        cmap = mpl.cm.get_cmap('jet')  # Spectral
        colors = cmap(norm(dz))
        fig = plt.figure()
        ax = Axes3D(fig, azim=-35, elev=35)
        ax.bar3d(xpos, ypos, zpos, dx, dy, dz, color=colors)
        ax.set_title(lab+'_Imag')
        cax, kw = mpl.colorbar.make_axes(ax, shrink=.75, pad=.0)
        mpl.colorbar.ColorbarBase(cax, cmap=cmap, norm=norm)
        plt.show()
    def phase_comp(self , process , theta):
        '''
        对演化矩阵进行相位补偿，theta为每个比特的相位补偿角(弧度)
        '''
        numRetainQubit = len(self.retainNode)
        assert len(theta) == numRetainQubit
        for ii in range(numRetainQubit):
            op = tensor(*[Qobj(np.array([[1,0],[0,np.exp(1j*theta[ii])]])) if ii==jj else qeye(2) for jj in range(numRetainQubit)])
            process = op*process
        return(process)
        # for index in range(2**numRetainQubit):
        #     II = index
        #     for JJ in range(numRetainQubit):
        #         number = np.int(np.mod(II,2))
        #         if number == 1:
        #             process[:,index] = process[:,index]*np.exp(1j*theta[-1-JJ])
        #         II = np.int(np.floor(II/2))
        # return(process)

class TransmonQubit(BasicQubit):
    '''
    TransmonQubit类：
        代表一个transmon链
        每个节点对地都构成一个类谐振子的比特，或者构成一个谐振子，以此对算符phi进行谐振子展开，进一步计算Hamilton，否则不满足这个类的条件
        这是一个通用的类，其他transmon类型都是该类的子类，需要转化到这种TransmonQubit类型(需要手动解出变化形式)
    输入：
        等效节点电容逆矩阵，等效节点电感逆矩阵，等效节点顶点Ej矩阵，磁通偏置矩阵，各个节点能级，生成Hamilton
        计算所需的Ec，Ej均以GHz*2pi为单位
    需要定义TransmonQubit的方法：
        __init__:如何从电容矩阵，电感矩阵，节电阻矩阵，SQUID磁通，能级矩阵 转化成 等效节点电容逆矩阵，等效节点电感逆矩阵，等效节点Ej矩阵，能级矩阵
        驱动：通过电路参数，生成驱动哈密顿量
    '''
    def __init__(self , qubitsParameter , *args , **kwargs):
        self.__capacityInv, self.__inductanceInv, self.__EjMatrixTop, self.__flux, self.__Nlevel = qubitsParameter #输入节点电容矩阵，电感矩阵，电阻矩阵，能级数目
        self.__numQubit = len(self.__Nlevel)
        self.sm,self.E_phi = self._BasicHamiltonOperator()
        Hamilton = self._H0Generation()
        super(TransmonQubit,self).__init__(Hamilton, *args , **kwargs)

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
        Ec = e**2/2*CInv/hbar/1e9

        # 计算Linv
        LInv = self.__inductanceInv
        EL = (hbar/2/e)**2*LInv/hbar/1e9
        # 计算EU
        EjMatrixTop = self.__EjMatrixTop
        flux = self.__flux
        EjMatrix = EjMatrixTop*np.cos(np.pi*flux)
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
        self.phi = [np.sqrt(2)*(beta[ii]/alpha[ii])**(1/4)*XX[ii] for ii in range(len(alpha))]
        self.nn = [np.sqrt(2)*(alpha[ii]/beta[ii])**(1/4)*YY[ii] for ii in range(len(alpha))]
        self.phid = [sum([(hbar/2/e)**2*CInv[ii,jj]*hbar*self.nn[jj] for jj in range(np.shape(CInv)[1])]) for ii in range(len(self.nn))] 

        H0 = sum([np.sqrt(alpha[ii]*beta[ii])*sn[ii] for ii in range(np.shape(Ec)[0])])
        Heta = sum([-Ej[ii,ii]*(self.phi[ii]**4/24-self.phi[ii]**6/math.factorial(6)+self.phi[ii]**8/math.factorial(8)) for ii in range(np.shape(Ec)[0])])
        Hc = sum([4*Ec[ii,jj]*self.nn[ii]*self.nn[jj]+1/2*EU[ii,jj]*self.phi[ii]*self.phi[jj]-EjMatrix[ii][jj]*((-self.phi[ii]**2/2+self.phi[ii]**4/24)*(-self.phi[jj]**2/2+self.phi[jj]**4/24)+(self.phi[ii]-self.phi[ii]**3/6)*(self.phi[jj]-self.phi[jj]**3/6)) for ii in range(np.shape(Ec)[0]) for jj in range(np.shape(Ec)[1]) if ii!=jj])

        Hamilton = H0+Heta+Hc
        return(Hamilton)

    def DriveHamilton(self,node,couplingParameter,couplingMode = 'Current'):
        hbar=1.054560652926899e-34
        h = hbar*2*np.pi
        e = 1.60217662e-19 
        phi0 = h/2/e
        if couplingMode == 'Voltage':
            # couplingParameter为耦合电容
            dirveH = 1/2*couplingParameter*hbar/2/e*self.phid[node]/hbar
        elif couplingMode == 'Current':
            # couplingParameter为[做驱动的与大loop的互感，做detune的与DC-SQUID的互感]
            Mx,Mz = couplingParameter
            drive = self.__EjMatrixTop[node,node]*np.cos(np.pi*self.__flux[node,node]) * 2 *np.pi*Mx/phi0 * (self.phi[node]-self.phi[node]**3/6)
            detune = self.__EjMatrixTop[node,node]*np.sin(np.pi*self.__flux[node,node]) * np.pi*Mz/phi0 * (-self.phi[node]**2/2+self.phi[node]**4/24)
            dirveH = [drive, detune]
        else:
            raise ValueError('couplingMode error')
        return(dirveH)

class FluxmonQubit(BasicQubit):
    '''
    FluxmonQubit类, 输入电容矩阵，电感矩阵，电阻矩阵和能级，生成Hamilton
    '''
    def __init__(self , qubitsParameter , *args , **kwargs):
        self.__capacity, self.__inductance, self.__resistance, self.__Nlevel = qubitsParameter #输入节点电容矩阵，电感矩阵，电阻矩阵，能级数目
        self.__numQubit = len(self.__Nlevel)
        Hamilton = self._H0Generation()
        super(FluxmonQubit,self).__init__(Hamilton, *args , **kwargs)

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
        pass

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
        Hamilton = self._H0Generation()
        super(Frequency1DQubit,self).__init__(Hamilton, *args , **kwargs)
        
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
        Hamilton = self._H0Generation()
        super(Frequency2DQubit,self).__init__(Hamilton, *args , **kwargs)
        
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

class Xmon(TransmonQubit):
    '''
    最简单的transmon变种,从Xmon到Transmon的变化其实是手动的。
    需要定义Xmon的方法：
    __init__:如何从电容矩阵，电感矩阵，节电阻矩阵，SQUID磁通，能级矩阵 转化成 等效节点电容逆矩阵，等效节点电感逆矩阵，等效节点顶点Ej矩阵，SQUID磁通矩阵，能级矩阵
    '''
    def __init__(self, elementParameter, *args, **kwargs):
        self.__capacity, self.__inductance, self.__resistance, self.__flux, self.__Nlevel = elementParameter

        # 计算Cinv
        Capa = -np.array(self.__capacity)
        for ii in range(np.shape(Capa)[0]):
            Capa[ii][ii] = -sum(self.__capacity[ii])
        CInv = np.linalg.inv(Capa)
        # 计算Linv
        LInv = -1/np.array(self.__inductance)
        for ii in range(np.shape(LInv)[0]):
            LInv[ii][ii] = -np.sum(LInv[ii])
        # 计算EjMatrix
        R2E = np.vectorize(self._R2E)
        EjMatrixTop = R2E(np.array(self.__resistance))
        qubitsParameter = [CInv,LInv,EjMatrixTop,self.__flux, self.__Nlevel]
        super().__init__(qubitsParameter, *args, **kwargs)
    def _R2E(self,R):
        hbar=1.054560652926899e-34
        h = hbar*2*np.pi
        e = 1.60217662e-19 
        I0 = 280e-9
        R0 = 1000
        I = I0*R0/R
        Ej = I*hbar/2/e/hbar/1e9
        return(Ej)

class DifferentialTransmon(TransmonQubit):
    '''
    电容浮地的transmon变种,从DifferentialTransmon到Transmon的变化是手动的。
    需要定义DifferentialTransmon的方法：
    __init__:如何从电容矩阵，电感矩阵，节电阻矩阵，SQUID磁通，能级矩阵 转化成 等效节点电容逆矩阵，等效节点电感逆矩阵，等效节点顶点Ej矩阵，SQUID磁通矩阵，能级矩阵
    '''
    def __init__(self, elementParameter, *args, **kwargs):
        self.__capacity, self.__inductance, self.__resistance, self.__flux, self.__SMatrix, self.__structure, self.__Nlevel = elementParameter
        retainNode = [b[0] for b in self.__structure]
        SMatrix = self.__SMatrix
        SMatrixInv = np.linalg.inv(SMatrix)
        # 计算Cinv
        Capa = -np.array(self.__capacity)
        for ii in range(np.shape(Capa)[0]):
            Capa[ii][ii] = -sum(Capa[ii])
        Capa = np.dot(np.transpose(SMatrixInv),np.dot(Capa,SMatrixInv))
        CInv = np.linalg.inv(Capa)
        CInv = CInv[retainNode,:]
        CInv = CInv[:,retainNode]
        # 计算Linv
        LInv = -1/np.array(self.__inductance)
        for ii in range(np.shape(LInv)[0]):
            LInv[ii][ii] = -np.sum(LInv[ii])
        LInv = np.dot(np.transpose(SMatrixInv),np.dot(LInv,SMatrixInv))
        LInv = LInv[retainNode,:]
        LInv = LInv[:,retainNode]
        # 计算EjMatrix
        R2E = np.vectorize(self._R2E)
        # 计算EjMatrix
        EjMatrixTop = R2E(np.array(self.__resistance))
        fluxMatrix = self.__flux
        EjMatrixTopN = np.diag([EjMatrixTop[self.__structure[ii][0]][self.__structure[ii][1]] if len(self.__structure[ii])==2 else EjMatrixTop[self.__structure[ii][0]][self.__structure[ii][0]] for ii in range(len(retainNode))])
        fluxMatrixN = np.diag([fluxMatrix[self.__structure[ii][0]][self.__structure[ii][1]] if len(self.__structure[ii])==2 else fluxMatrix[self.__structure[ii][0]][self.__structure[ii][0]] for ii in range(len(retainNode))])
        qubitsParameter = [CInv,LInv,EjMatrixTopN,fluxMatrixN, self.__Nlevel]
        super().__init__(qubitsParameter, *args, **kwargs)
    def _R2E(self,R):
        hbar=1.054560652926899e-34
        h = hbar*2*np.pi
        e = 1.60217662e-19 
        I0 = 280e-9
        R0 = 1000
        I = I0*R0/R
        Ej = I*hbar/2/e/hbar/1e9
        return(Ej)
        