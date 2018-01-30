#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Mar 16 20:44:16 2017

@author: chen
"""

from qutip import *
import numpy as np
import matplotlib.pyplot as plt 
from pylab import *

#==============================================================================
class qusetting(object):
    def __init__(self):
        '''
        gate
        '''
        self.DRAG = True
        self.omega = 0.033348628532133037
        self.delta = 0.0684001
        self.iswap_deltat = 361
        self.CZ_deltat = 86.0
        self.ramp = 129
        self.CZtime = 850
#==============================================================================
        '''
        initial
        '''
        self.qtype = 1
#==============================================================================
        '''
        qubit
        '''
        self.w_c = 7.0  * 2 * np.pi  # cavity frequency
        self.w_q = np.array([ 5.0 , 5.2]) * 2 * np.pi
        self.g = np.array([0.03 , 0.03]) * 2 * np.pi
        self.eta_q = np.array([-0.25 , -0.25]) * 2 * np.pi
        self.N = 3              # number of cavity fock states
        self.n= 0
        self.level = 3  #能级数
#==============================================================================
        '''
        Plot
        '''
        self.RF = True
#==============================================================================
        '''
        system
        '''
        self.En = []
        
        '''
        dissipation
        '''
        self.Dis = False
#==============================================================================


def initial(setting = qusetting()):
    if setting.qtype == 1:#two qubits,coupled with a resonator

        
#==============================================================================
        '''
        Operators
        '''
        a = tensor(destroy(setting.N),qeye(3),qeye(3))
        sm = np.array([tensor(qeye(setting.N),destroy(3),qeye(3)) , tensor(qeye(setting.N),qeye(3),destroy(3))])
        
        E_uc = np.array([tensor(qeye(setting.N),basis(3,2)*basis(3,2).dag(),qeye(3)) , 
                         tensor(qeye(setting.N),qeye(3), basis(3,2)*basis(3,2).dag())])
        #用以表征非简谐性的对角线最后一项(非计算能级)
        #E_uc1 = tensor(qeye(N),qeye(3), Qobj([[0,0],[0,1]]))
        
        E_e = np.array([tensor(qeye(setting.N),basis(3,1)*basis(3,1).dag(),qeye(3)),tensor(qeye(setting.N),qeye(3),basis(3,1)*basis(3,1).dag())])
        #激发态
        
        E_g = np.array([tensor(qeye(setting.N),basis(3,0)*basis(3,0).dag(),qeye(3)) , tensor(qeye(setting.N),qeye(3),basis(3,0)*basis(3,0).dag())])
        #基态
        
        sn = np.array([sm[0].dag()*sm[0] , sm[1].dag()*sm[1]])
        
        sx = np.array([sm[0].dag()+sm[0],sm[1].dag()+sm[1]]);
        sxm = np.array([tensor(qeye(setting.N),Qobj([[0,1,0],[1,0,0],[0,0,0]]),qeye(3)) , tensor(qeye(setting.N),qeye(3),Qobj([[0,1,0],[1,0,0],[0,0,0]]))])
        
        
        sy = np.array([1j*(sm[0].dag()-sm[0]) , 1j*(sm[1].dag()-sm[1])]);
        sym = np.array([tensor(qeye(setting.N),Qobj([[0,-1j,0],[1j,0,0],[0,0,0]]),qeye(3)) , tensor(qeye(setting.N),qeye(3),Qobj([[0,-1j,0],[1j,0,0],[0,0,0]]))])
        
        sz = np.array([E_g[0] - E_e[0] , E_g[1] - E_e[1]])
        
#==============================================================================
#        Delta1 = abs(setting.w_q[0]-setting.w_c)
#        Delta2 = abs(setting.w_q[1]-setting.w_c)
#        g_effect = 0.5*setting.g[0]*setting.g[1]*(Delta1+Delta2)/(Delta1*Delta2)
#        print(g_effect)
        HCoupling = setting.g[0]*(a+a.dag())*(sm[0]+sm[0].dag()) + setting.g[1]*(a+a.dag())*(sm[1]+sm[1].dag())
        Hc = setting.w_c * a.dag() * a 
        H_eta = setting.eta_q[0] * E_uc[0] + setting.eta_q[1] * E_uc[1]
        Hq = setting.w_q[0]*sn[0] + setting.w_q[1]*sn[1]
        H = Hq + H_eta + Hc + HCoupling
        
        # k = H.eigenstates()
#        print(k[0][5]/2/np.pi,k[0][6]/2/np.pi)
#        print(k[1][6].dag()*H*k[1][5])
        # print(ptrace(H,[1,2]))
        
        w_f = [setting.w_q[k] for k in range(2)]
        w_f.append(setting.w_c)
        Ee = H.eigenenergies()
        E_e = Ee.tolist()
        E_index=sorted(range(2+1), key=lambda k: w_f[k])
        cloc = np.where(np.array(E_index) == 2)[0][0]
        E_e.pop(cloc+1)
        E_index.pop(cloc)
        
        En = np.zeros(2)
        for idx,i in enumerate(E_index):
            En[i] = E_e[idx+1]-E_e[0]
        
#        Ee = H.eigenenergies()
#        E_index=sorted(range(2), key=lambda k: setting.w_q[k])
#        En = np.zeros(2)
#        for idx,i in enumerate(E_index):
#            En[i] = Ee[idx+1]-Ee[0]
##        JJ = np.where(E_index == II)[0][0]
##        E_q.append(En[JJ+1]-En[0])
##        print(E_q[II]/2/np.pi)
##        print(En/2/np.pi)
#        print(En/2/np.pi)
        return(a,sm,E_uc,E_e,E_g,sn,sx,sxm,sy,sym,sz,En)
#==============================================================================        
    elif setting.qtype == 2:#two qubits,coupled directly

#==============================================================================
        '''
        Operators
        '''
        sm = np.array([tensor(destroy(3),qeye(3)) , tensor(qeye(3),destroy(3))])
        
        E_uc = np.array([tensor(basis(3,2)*basis(3,2).dag(),qeye(3)) , tensor(qeye(3), basis(3,2)*basis(3,2).dag())])
        #用以表征非简谐性的对角线最后一项(非计算能级)
        #E_uc1 = tensor(qeye(3), Qobj([[0,0],[0,1]]))
        
        E_e = np.array([tensor(basis(3,1)*basis(3,1).dag(),qeye(3)),tensor(qeye(3),basis(3,1)*basis(3,1).dag())])
        #激发态
        
        E_g = np.array([tensor(basis(3,0)*basis(3,0).dag(),qeye(3)) , tensor(qeye(3),basis(3,0)*basis(3,0).dag())])
        #基态
        
        sn = np.array([sm[0].dag()*sm[0] , sm[1].dag()*sm[1]])
        
        sx = np.array([sm[0].dag()+sm[0],sm[1].dag()+sm[1]]);
        sxm = np.array([tensor(Qobj([[0,1,0],[1,0,0],[0,0,0]]),qeye(3)) , tensor(qeye(3),Qobj([[0,1,0],[1,0,0],[0,0,0]]))])
        
        
        sy = np.array([1j*(sm[0].dag()-sm[0]) , 1j*(sm[1].dag()-sm[1])]);
        sym = np.array([tensor(Qobj([[0,-1j,0],[1j,0,0],[0,0,0]]),qeye(3)) , tensor(qeye(3),Qobj([[0,-1j,0],[1j,0,0],[0,0,0]]))])
        
        sz = np.array([E_g[0] - E_e[0] , E_g[1] - E_e[1]])
        
#==============================================================================
        Delta1 = abs(setting.w_q[0]-setting.w_c)
        Delta2 = abs(setting.w_q[1]-setting.w_c)
        g_effect = 0.5*setting.g[0]*setting.g[1]*(Delta1+Delta2)/(Delta1*Delta2)
#        print(g_effect)
        HCoupling = g_effect*(sm[0]+sm[0].dag())*(sm[1]+sm[1].dag())
        H_eta = setting.eta_q[0] * E_uc[0] + setting.eta_q[1] * E_uc[1]
        Hq = setting.w_q[0]*sn[0] + setting.w_q[1]*sn[1]
        H=  Hq + H_eta + HCoupling
        
        

        w_f = [setting.w_q[k] for k in range(2)]
        w_f.append(setting.w_c)
        Ee = H.eigenenergies()
        E_e = Ee.tolist()
        E_index=sorted(range(2+1), key=lambda k: w_f[k])
        cloc = np.where(np.array(E_index) == 2)[0][0]
        E_e.pop(cloc+1)
        E_index.pop(cloc)
        
        En = np.zeros(2)
        for idx,i in enumerate(E_index):
            En[i] = E_e[idx+1]-E_e[0]
#        JJ = np.where(E_index == II)[0][0]
#        E_q.append(En[JJ+1]-En[0])
#        print(E_q[II]/2/np.pi)
    
        
        return(sm,E_uc,E_e,E_g,sn,sx,sxm,sy,sym,sz,En)
        
        
        
        
        
    