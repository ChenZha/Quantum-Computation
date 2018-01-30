#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Mar 16 21:00:37 2017

@author: chen
"""
from qutip import *
import numpy as np
import matplotlib.pyplot as plt 
from pylab import *
from initialsetting import *



#==============================================================================
def evolutionplot(target , result , tlist , setting = qusetting()):
    
    n_x = [] ; n_y = [] ; n_z = [];n_a = [];n_uc = []
    if setting.qtype == 1:
        a,sm,E_uc,E_e,E_g,sn,sx,sxm,sy,sym,sz,En = initial(setting)
        for t in range(0,len(tlist)):
            if setting.RF:
    #            -(g[1]*g[1]/(w_q[1]-w_q[0]))
    
#                rf01 =np.exp(1j*(w02[0])*tlist[t])*basis(3,2)*basis(3,2).dag()
#                rf02 = np.exp(1j*(En[0])*tlist[t])*basis(3,1)*basis(3,1).dag()
                rf0 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(En[0])*tlist[t])*basis(3,1)*basis(3,1).dag()
#                rf11 = np.exp(1j*(w02[1])*tlist[t])*basis(3,2)*basis(3,2).dag()
#                rf12 = np.exp(1j*(En[1])*tlist[t])*basis(3,1)*basis(3,1).dag()
                rf1 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(En[1])*tlist[t])*basis(3,1)*basis(3,1).dag()
                U = tensor(qeye(setting.N),rf0,rf1)
                
    #            rf01 =np.exp(1j*(2*w_q[0]-eta_q[0])*tlist[t])*basis(3,2)*basis(3,2).dag()
    #            rf02 = np.exp(1j*(w_q[0])*tlist[t])*basis(3,1)*basis(3,1).dag()
    #            rf0 = basis(3,0)*basis(3,0).dag()+rf01+rf02
    #            rf11 = np.exp(1j*(2*w_q[1]-eta_q[1])*tlist[t])*basis(3,2)*basis(3,2).dag()
    #            rf12 = np.exp(1j*(w_q[1])*tlist[t])*basis(3,1)*basis(3,1).dag()
    #            rf1 = basis(3,0)*basis(3,0).dag()+rf11+rf12
    #            U = tensor(qeye(N),rf0,rf1)
                
                opx = U.dag()*eval('sx['+str(eval('target'))+']')*U
                opy = U.dag()*eval('sy['+str(eval('target'))+']')*U
                opz = eval('1-2*sn['+str(eval('target'))+']')
                
            else:
                opx = eval('sx['+str(eval('target'))+']')
                opy = eval('sy['+str(eval('target'))+']')
                opz = eval('1-2*sn['+str(eval('target'))+']')
                
        
            n_x.append(expect(opx,result.states[t]))
            n_y.append(expect(opy,result.states[t]))
            n_z.append(expect(opz,result.states[t]))
            n_a.append(expect(a.dag()*a,result.states[t]))
            n_uc.append(expect(E_uc[eval('target')],result.states[t]))
        fig, axes = plt.subplots(4, 1, figsize=(10,6))
        
        axes[0].plot(tlist, n_x, label='X');axes[0].set_ylim([-1.05,1.05])
        axes[1].plot(tlist, n_y, label='Y');axes[1].set_ylim([-1.05,1.05])
        axes[2].plot(tlist, n_z, label='Z');axes[2].set_ylim([-1.05,1.05])
        axes[3].plot(tlist, n_a, label='N');axes[3].set_ylim([-1.05,1.05])
        
        fig,axes = plt.subplots(1,1)
        axes.plot(tlist,n_uc,label='level-2')
        
#        print(n_y)
    elif setting.qtype == 2:
        
        sm,E_uc,E_e,E_g,sn,sx,sxm,sy,sym,sz,En = initial(setting)
        
        for t in range(0,len(tlist)):
            if setting.RF:
    #            -(g[1]*g[1]/(w_q[1]-w_q[0]))
    
#                rf01 =np.exp(1j*(w02[0])*tlist[t])*basis(3,2)*basis(3,2).dag()
#                rf02 = np.exp(1j*(En[0])*tlist[t])*basis(3,1)*basis(3,1).dag()
                rf0 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(En[0])*tlist[t])*basis(3,1)*basis(3,1).dag()
#                rf11 = np.exp(1j*(En[1])*tlist[t])*basis(3,2)*basis(3,2).dag()
#                rf12 = np.exp(1j*(En[1])*tlist[t])*basis(3,1)*basis(3,1).dag()
                rf1 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(En[1])*tlist[t])*basis(3,1)*basis(3,1).dag()
                U = tensor(rf0,rf1)
                
    #            rf01 =np.exp(1j*(2*w_q[0]-eta_q[0])*tlist[t])*basis(3,2)*basis(3,2).dag()
    #            rf02 = np.exp(1j*(w_q[0])*tlist[t])*basis(3,1)*basis(3,1).dag()
    #            rf0 = basis(3,0)*basis(3,0).dag()+rf01+rf02
    #            rf11 = np.exp(1j*(2*w_q[1]-eta_q[1])*tlist[t])*basis(3,2)*basis(3,2).dag()
    #            rf12 = np.exp(1j*(w_q[1])*tlist[t])*basis(3,1)*basis(3,1).dag()
    #            rf1 = basis(3,0)*basis(3,0).dag()+rf11+rf12
    #            U = tensor(qeye(N),rf0,rf1)
                
                opx = U.dag()*eval('sx['+str(eval('target'))+']')*U
                opy = U.dag()*eval('sy['+str(eval('target'))+']')*U
                opz = eval('1-2*sn['+str(eval('target'))+']')
                
            else:
                opx = eval('sxm['+str(eval('target'))+']')
                opy = eval('sym['+str(eval('target'))+']')
                opz = eval('1-2*sn['+str(eval('target'))+']')
                
        
            n_x.append(expect(opx,result.states[t]))
            n_y.append(expect(opy,result.states[t]))
            n_z.append(expect(opz,result.states[t]))
            n_uc.append(expect(E_uc[eval('target')],result.states[t]))
#            print(ptrace(opz,1))
        fig, axes = plt.subplots(3, 1, figsize=(10,6))
        
        axes[0].plot(tlist, n_x, label='X')
        axes[1].plot(tlist, n_y, label='Y')
        axes[2].plot(tlist, n_z, label='Z')
        
        fig,axes = plt.subplots(1,1)
        axes.plot(tlist,n_uc,label='level-2')
    sphere = Bloch()
    sphere.add_points([n_x , n_y , n_z])
    sphere.add_vectors([n_x[-1],n_y[-1],n_z[-1]])
    sphere.make_sphere() 
    plt.show()
    
#==============================================================================