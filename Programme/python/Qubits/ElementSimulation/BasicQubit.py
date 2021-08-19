from operator import index
import numpy as np
from qutip import *
import matplotlib.pyplot as plt
from multiprocessing import Pool

class BasicQubit():
    '''
    最原始的qubit类，输入qubit的哈密顿量，
    方法包含基础测量operator的生成,比特状态寻址, 态的演化，process tomography, 态演化的画图
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
    def findstate(self,state,searchSpace='full',mark = 'string'):
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
            searchLen=len(self.StatenergyEig)
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
        firstExcited.append(self.findstate(self._numTostate([0]*numQubit),search_space='brev')) #基态的位置index
        for II in range(0,numQubit):
            stateNum = [0]*numQubit
            stateNum[II] = 1
            firstExcited.append(self.findstate(self._numTostate(stateNum),search_space='brev')) #各第一激发态位置index
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
            self.evolutionH = [self.H0]
            for H_drive in drive:
                self.evolutionH.append(H_drive)

        # 初态psi 
        self.iniPsi = psi

        # 时间序列
        T_p = argument['T_P']
        T_copies = argument['T_copies']
        self.tlist = np.linspace(0,self.T_p,self.T_copies)
        # collapse
        self.collapse = collapse
        # evolution
        self.result = mesolve(self.evolutionH , self.iniPsi , self.tlist , c_ops = self.collapse , e_ops = [] , args = argument , options = options)
        
        # RWF
        self.RWF = RWF
        self.RWAFreq = RWAFreq
        # Rotation Frame of final state
        UF = self._RFGeneration(self.tlist[-1])
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
    def DifferentialEvolution():
        pass
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
            nx[q_index] = self.expect_evolution(opx)
            ny[q_index] = self.expect_evolution(opy)
            nz[q_index] = self.expect_evolution(opz)
            nn[q_index] = self.expect_evolution(opn)
            leakage[q_index] = self.expect_evolution(self.E_uc[q_index])
        
        
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

    def process(self , drive = None , processPlot  = False , RWF = 'CpRWF' , RWAFreq = 0.0 ,parallel = False , argument = {'T_p':100,'T_copies':201} , options = default_options):
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
        # 生成2^n个基矢,以及各个基矢在3能级系统中的位置
        basic , loc = self._basic_generation()
        finalState = [] #基矢演化得到的末态
        if parallel:
            p = Pool()
            result_final = [p.apply_async(self.QutipEvolution,(drive , basic[i] , [] , False , RWF, RWA_freq,argument , options)) for i in range(len(basic)) ]
            finalState = np.array([result_final[i].get() for i in range(len(result_final))])
            p.close()
            p.join()
        else:
            finalState = [self.QutipEvolution(drive , Phi , [] , False , RWF ,RWA_freq,argument , options) for Phi in basic]


        process = np.column_stack([finalState[i].data.toarray() for i in range(len(finalState))])[loc,:] #只取演化矩阵中二能级部分
        angle = np.angle(process[0][0])
        process = process*np.exp(-1j*angle)#消除global phase

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
        Nlevel = self.__Hamilton.dims[0]
        numQubit = len(Nlevel)
        assert len(theta) == numQubit
        for index in range(2**numQubit):
            II = index
            for JJ in range(numQubit):
                number = np.int(np.mod(II,2))
                if number == 1:
                    process[:,index] = process[:,index]*np.exp(1j*xita[-1-JJ])
                II = np.int(np.floor(II/2))
        return(process)