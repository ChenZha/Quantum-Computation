"""
Created on Wed Aug 15 15:25:55 2018
@author: chen
"""

from qutip import *
from scipy.optimize import *
import matplotlib.pyplot as plt
import numpy as np
from multiprocessing import Pool
import matplotlib as mpl
from mpl_toolkits.mplot3d import Axes3D

class Qubits():
    # 输入比特信息，驱动哈密顿量，参数
    # 得到单态的演化结果，整体保真度Ufidelity

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


    def __init__(self , qubits_parameter , *args , **kwargs):
        # qubits_parameter结构:frequency(频率);coupling(耦合强度);eta_q(非简谐性)
        self.frequency , self.coupling , self.eta_q= qubits_parameter
        assert len(self.frequency) == len(self.coupling)+1 == len(self.eta_q)
        self.num_qubits = int(len(self.frequency)) #比特数目
        self.N_level = 3 # 能级数

        # 生成基本的operator
        self.sm,self.E_uc,self.E_e,self.E_g = self._BasicOperator()

        # 生成未加驱动的基本哈密顿量
        self.H0 = self._Generate_H0()

        #找到本征值和本征态
        [self.E_eig,self.State_eig] = self.H0.eigenstates()

        #找到基态，以及各个比特的第一激发态的位置
        self.first_excited = self._FirstExcite()

    def _BasicOperator(self):
        '''
        生成基本operator
        '''
        sm=[]
        for II in range(0,self.num_qubits):
            cmdstr=''
            for JJ in range(0,self.num_qubits):
                if II==JJ:
                    cmdstr+='destroy(self.N_level),'
                else:
                    cmdstr+='qeye(self.N_level),'
            sm.append(eval('tensor('+cmdstr+')'))

        E_uc = []
        for II in range(0,self.num_qubits):
            cmdstr=''
            for JJ in range(0,self.num_qubits):
                if II==JJ:
                    cmdstr+='basis(self.N_level,2)*basis(self.N_level,2).dag(),'
                else:
                    cmdstr+='qeye(self.N_level),'
            E_uc.append(eval('tensor('+cmdstr+')'))

        E_e=[]
        for II in range(0,self.num_qubits):
            cmdstr=''
            for JJ in range(0,self.num_qubits):
                if II==JJ:
                    cmdstr+='basis(self.N_level,1)*basis(self.N_level,1).dag(),'
                else:
                    cmdstr+='qeye(self.N_level),'
            E_e.append(eval('tensor('+cmdstr+')'))
        
        E_g=[]
        for II in range(0,self.num_qubits):
            cmdstr=''
            for JJ in range(0,self.num_qubits):
                if II==JJ:
                    cmdstr+='basis(self.N_level,0)*basis(self.N_level,0).dag(),'
                else:
                    cmdstr+='qeye(self.N_level),'
            E_g.append(eval('tensor('+cmdstr+')'))

        return([sm,E_uc,E_e,E_g])
    def _Generate_H0(self):
    
        
        '''
        根据qubit参数，生成未加驱动的基本哈密顿量
        '''
        H0 = 0
        for index in range(self.num_qubits):#添加qubit频率和非简谐性
            H0 += self.frequency[index]*self.sm[index].dag()*self.sm[index] + self.eta_q[index]*self.E_uc[index]
        if self.num_qubits != 1:
            for index in range(self.num_qubits-1):# 添加耦合
                H0 += self.coupling[index]*(self.sm[index]+self.sm[index].dag())*(self.sm[index+1]+self.sm[index+1].dag())
        return(H0)
    def _findstate(self,state):
        '''
        在self.state中找到各个态对应的位置
        '''
        index_level = None
        assert int(len(state)) == self.num_qubits
        e = np.zeros(self.num_qubits,dtype = 'int') #记录寻找的态对应每个比特上的能级
        s = np.zeros(self.num_qubits) #记录某个本征态的每个比特上相应能级的信息
        for i in range(self.num_qubits):
            e[i] = int(eval(state[i]))
        for index in range(len(self.State_eig)):
            for i in range(self.num_qubits):
                s[i] = np.abs(ptrace(self.State_eig[index],i)[e[i]][0][e[i]])
            if all(s>=0.5):
                index_level = index
        if index_level == None:
            print('No State')
            return(None)
        else:
            return(index_level)
    def _FirstExcite(self):
        '''
        找到基态，以及各个比特的第一激发态的位置
        n个比特有n+1个值，前n个为n个比特第一激发态位置，最后一个为基态位置
        '''
        first_excited = []
        for II in range(0,self.num_qubits):#各个比特第一激发态位置
            state_label=''
            for JJ in range(0,self.num_qubits):
                if II==JJ:
                    state_label+='1'
                else:
                    state_label+='0'
            first_excited.append(self._findstate(state_label))
        first_excited.append(self._findstate('0'*self.num_qubits)) #基态的位置

        return(first_excited)
    
            

    def evolution(self , drive = None , psi = basis(3,0) , collapse = [] , track_plot = False,argument = {'T_p':100,'T_copies':201} , options = default_options):
        '''
        计算当前比特在psi初态，经drive驱动，最终得到的末态final_state
        参数：
        drive:驱动哈密顿量，形式[H1,H2,H3]
        psi：初态
        collapse:退相干算符
        argument：关于演化的参数,主要是drive中的参数，必须包含总时间T_p,时间份数T_copies

        返回：
        演化的终态
        '''
        # 生成Hamilton
        self.H = self.H0
        if drive != None:
            self.H = [self.H0]
            for H_drive in drive:
                self.H.append(H_drive)

        # 初态psi 
        self.psi = psi

        # 时间序列
        self.T_p = argument['T_P']
        self.T_copies = argument['T_copies']
        self.tlist = np.linspace(0,self.T_p,self.T_copies)
        # collapse
        self.collapse = collapse

        # evolution
        self.result = mesolve(self.H , self.psi , self.tlist , c_ops = self.collapse , e_ops = [] , args = argument , options = options)

        # Rotation Frame of final state
        UF = self._RF_Generation(self.tlist[-1])

        # Final State in Rotation Frame(pure state)
        final_state = UF*self.result.states[-1]


        if track_plot:
            self._track_plot()



        return(final_state)

    def _RF_Generation(self,select_time):
        '''
        生成时间t时刻的旋转坐标系矩阵
        '''
        U = []
        for index in range(self.num_qubits):
            U.append(basis(self.N_level,0)*basis(self.N_level,0).dag()+np.exp(1j*(self.E_eig[self.first_excited[index]]-self.E_eig[self.first_excited[-1]])*select_time)*basis(self.N_level,1)*basis(self.N_level,1).dag())
        UF = tensor(*U)
        return(UF)
    def _track_plot(self):
        '''
        画出各个比特状态在Bloch球中的轨迹
        '''
        nx = np.zeros([self.num_qubits,len(self.tlist)])
        ny = np.zeros([self.num_qubits,len(self.tlist)])
        nz = np.zeros([self.num_qubits,len(self.tlist)])
        leakage = np.zeros([self.num_qubits,len(self.tlist)])
        # 各个时间点，各个比特在X,Y,Z轴上投影
        for t_index in range(len(self.tlist)):
            UF_t =  self._RF_Generation(self.tlist[t_index])
            for q_index in range(self.num_qubits):
                opx = UF_t.dag()*(self.sm[q_index].dag()+self.sm[q_index])*UF_t
                opy = UF_t.dag()*(1j*self.sm[q_index].dag()-1j*self.sm[q_index])*UF_t
                opz = UF_t.dag()*((self.E_g[q_index]+self.E_e[q_index]+self.E_uc[q_index])-2*self.sm[q_index].dag()*self.sm[q_index])*UF_t
                nx[q_index,t_index] = expect(opx,self.result.states[t_index])
                ny[q_index,t_index] = expect(opy,self.result.states[t_index])
                nz[q_index,t_index] = expect(opz,self.result.states[t_index])
                leakage[q_index,t_index] = expect(self.E_uc[q_index] , self.result.states[t_index])
        
        # 画图
        fig,axes = plt.subplots(self.num_qubits,1)
        for q_index in range(self.num_qubits):
            if self.num_qubits > 1:
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
                axes[q_index].plot(self.tlist,leakage[q_index],label = 'leakage'+str(q_index))
                axes.set_xlabel('t');axes.set_ylabel('population of qubit'+str(q_index));
                axes.legend(loc = 'upper left')

            sphere = Bloch()
            sphere.add_points([nx[q_index] , ny[q_index] , nz[q_index]])
            sphere.add_vectors([nx[q_index][-1],ny[q_index][-1],nz[q_index][-1]])
            sphere.zlabel[0] = 'qubit'+str(q_index)+'\n$\\left|0\\right>$'
            sphere.make_sphere()
        plt.show()

    def process(self , drive = None , process_plot  = False , parallel = False , argument = {'T_p':100,'T_copies':201} , options = default_options):
        '''
        对当前比特施加驱动drive，表征整个state space的演化过程(只取每个比特二能级的部分)
        参数：
        drive：驱动哈密顿量
        process_plot：是否画出演化矩阵(实部与虚部)
        parallel：是否进行并行计算(如果外部还需要并行计算，这里要去Flase)
        argument：关于演化的参数,主要是drive中的参数，必须包含总时间T_p,时间份数T_copies

        返回：
        2^n维的演化矩阵
        '''
        # 生成2^n个基矢,以及各个基矢在3能级系统中的位置
        basic , loc = self._basic_generation()
        final_state = [] #基矢演化得到的末态
        if parallel:
            p = Pool()
            result_final = []
            for i in range(len(basic)):
                result_final.append(p.apply_async(self.evolution,(drive , basic[i] , [] , False , argument , options)))
            final_state = [result_final[i].get() for i in range(len(result_final))]
            p.close()
            p.join()
        else:
            for Phi in basic:
                final_state.append(self.evolution(drive , Phi , [] , False , argument , options))

        process = np.column_stack([final_state[i].data.toarray() for i in range(len(final_state))])[loc,:] #只取演化矩阵中二能级部分
        angle = np.angle(process[0][0])
        process = process*np.exp(-1j*angle)#消除global phase

        if process_plot:
            self.Operator_View(process,'Process')

        return(process)

    def _basic_generation(self):
        '''生成2^n个基矢,以及各个基矢在3能级系统中的位置'''
        basic = []
        loc = []
        for index in range(2**self.num_qubits):
            II = index
            code = '' #转化成二进制的字符串形式
            state = [] #生成一个基矢
            l = 0 #在3能级中的位置
            for JJ in range(self.num_qubits):
                number = np.int(np.mod(II,2))
                code += str(number)
                state.insert(0,basis(self.N_level , number))
                l += number*3**JJ
                II = np.int(np.floor(II/2))
            assert len(code) == len(state) == self.num_qubits    

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
    def phase_comp(self , process , xita):
        '''
        对演化矩阵进行相位补偿，xita为每个比特的相位补偿角(弧度)
        '''
        assert len(xita) == self.num_qubits

        for index in range(2**self.num_qubits):
            II = index
            for JJ in range(self.num_qubits):
                number = np.int(np.mod(II,2))
                if number == 1:
                    process[:,index] = process[:,index]*np.exp(1j*xita[-1-JJ])
                II = np.int(np.floor(II/2))

        return(process)
            






























