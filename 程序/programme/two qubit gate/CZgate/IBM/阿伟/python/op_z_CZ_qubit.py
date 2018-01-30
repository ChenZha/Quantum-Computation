# -*- coding: utf-8 -*-
"""
Created on Tue Sep 19 19:24:41 2017

@author: Liswer
"""


import matplotlib.pyplot as plt
import numpy as np
from pylab import *
from qutip import *
from scipy.optimize import *
from scipy.integrate import *
from scipy import interpolate 
from mpl_toolkits.mplot3d import Axes3D
from scipy.special import *
from multiprocessing import Pool
from decimal import *
from math import *
import waveform_lib as waveform_lib
import response_fun1 as response_fun1
import response_fun2 as response_fun2



def H_static_fun(w01_1,w01_2,anharmonic,g_coupling):       
    #qubit和cavities的频率参数与耦合参数
    aq=destroy(3)
    w02_1=2*w01_1-anharmonic
    w02_2=2*w01_2-anharmonic
    H_qubit1=tensor(w01_1*basis(3,1)*basis(3,1).dag()+w02_1*basis(3,2)*basis(3,2).dag(),qeye(3))
    H_qubit2=tensor(qeye(3),w01_2*basis(3,1)*basis(3,1).dag()+w02_2*basis(3,2)*basis(3,2).dag())
    H_qubit_all=H_qubit1+H_qubit2
    H_interact12=g_coupling*tensor(aq+aq.dag(),aq+aq.dag())
    #总静态哈密顿量
    H_static=H_qubit_all+H_interact12
    return(H_static)
    
###############################################################################################

def prepare(H_static):
    #构造初态
    psi0_00=tensor(basis(3,0),basis(3,0))
    psi0_01=tensor(basis(3,0),basis(3,1))
    psi0_10=tensor(basis(3,1),basis(3,0))
    psi0_11=tensor(basis(3,1),basis(3,1))
    psi0_list=[psi0_00,psi0_01,psi0_10,psi0_11]
    energies=H_static.eigenenergies()/(2*np.pi)
    eigenstates=H_static.eigenstates()
    #构造标准门
    identity=tensor(qeye(3),qeye(3))
    psi_control=tensor(basis(3,1)*basis(3,1).dag(),basis(3,1)*basis(3,1).dag())
    UCZ_ideal=identity-2*psi_control
    return([UCZ_ideal,psi0_list,energies,eigenstates])

###############################################################################################
def op_phase(inner_products):
    angles=np.zeros(4)
    angles[0]=angle(inner_products[0])
    angles[1]=angle(inner_products[1])
    angles[2]=angle(inner_products[2])
    angles[3]=angle(inner_products[3])
    op_angle=np.zeros(2)
    op_angle[0]=((angles[2]-angles[0])+(angles[3]-angles[1]))/2
    op_angle[1]=((angles[1]-angles[0])+(angles[3]-angles[2]))/2
    inner_products_op=[[np.complex]*1]*len(inner_products)
    inner_products_op[0]=inner_products[0]
    inner_products_op[1]=inner_products[1]*np.exp(-1j*op_angle[1])
    inner_products_op[2]=inner_products[2]*np.exp(-1j*op_angle[0])
    inner_products_op[3]=inner_products[3]*np.exp(-1j*(op_angle[0]+op_angle[1]))
    angle0=0
    for ii in range (0,4):
        angle0=angle(inner_products_op[ii])/4+angle0
    for ii in range (0,4):
        inner_products_op[ii]=inner_products_op[ii]*np.exp(-1j*angle0)
    return ([inner_products_op,op_angle])

####################################################################################


####################################################################################
def __main__(arg_input,is_picture=0):
    """
    x:[t_gate,delta1,omgh_sin,omgh_cos,omg1_sin,om12g1_cos,omg2_sin,omg2_cos]
    """
    waveform_t_fun_basis=arg_input[0]
    wave_para=arg_input[1]
    t_gate=round(wave_para[0]*2)/2 
    test_state=np.array([0,1,2,3])
    w01_1=5.3*2*np.pi
    w01_2=4.7*2*np.pi
    anharmonic=0.25*2*np.pi
    g_coupling=0.012*2*np.pi
    resolution=int(round(t_gate*2))
    #arg_H_static_fun={'w01_1':w01_1,'w01_2':w01_2,'anharmonic':anharmonic,'g_coupling':g_coupling}
    H_static=H_static_fun(w01_1,w01_2,anharmonic,g_coupling)
    #arg_prepare={'H_static':H_static}
    [UCZ_ideal,psi0_list,energies,eigenstates]=prepare(H_static)
    tlist=np.linspace(0,t_gate,resolution)
    waveform_t_fun=lambda t:waveform_t_fun_basis(t,wave_para)
    response_fun2_back=response_fun2.__main__(waveform_t_fun,t_gate)
    response_fun_back=response_fun1.__main__(response_fun2_back,t_gate)
    
    args={'t_gate':t_gate}   
    def Hq1z_coeff(t,args):
        return response_fun_back(t)*2*pi
    def Hq2z_coeff(t,args):
        if ((t>=0)&(t<=t_gate)):
            return(0)
        else:
            return(0)
    Hq1z_driven=tensor(basis(3,1)*basis(3,1).dag()+2*basis(3,2)*basis(3,2).dag(),qeye(3))
    Hq2z_driven=tensor(qeye(3),basis(3,1)*basis(3,1).dag()+2*basis(3,2)*basis(3,2).dag())
    H_total=[H_static,[Hq1z_driven,Hq1z_coeff],[Hq2z_driven,Hq2z_coeff]]
    q1_z_pulse=np.zeros(len(tlist))
    q2_z_pulse=np.zeros(len(tlist))
    for jj in range (0,len(tlist)):
        q1_z_pulse[jj]=Hq1z_coeff(tlist[jj],args)
        q2_z_pulse[jj]=Hq2z_coeff(tlist[jj],args)
    phase_q1_z_pulse=(sum(q1_z_pulse)-q1_z_pulse[0])/len(q1_z_pulse)*t_gate
    phase_q2_z_pulse=(sum(q2_z_pulse)-q2_z_pulse[0])/len(q2_z_pulse)*t_gate
    phase_gate=tensor(basis(3,0)*basis(3,0).dag()+np.exp(-1j*w01_1*t_gate-1j*phase_q1_z_pulse)*basis(3,1)*basis(3,1).dag(),basis(3,0)*basis(3,0).dag()+np.exp(-1j*w01_2*t_gate-1j*phase_q2_z_pulse)*basis(3,1)*basis(3,1).dag())
    inner_products=[[np.complex]*1]*len(psi0_list)
    for ii in range (0,len(test_state)):
        psi0=psi0_list[int(test_state[ii])]
        states_list=mesolve(H_total,psi0,tlist,[],[],args=args)  
        state_ideal=UCZ_ideal*phase_gate*psi0
        state_final=states_list.states[resolution-1]
        inner_products[ii]=(state_final.dag()*state_ideal)[0][0][0]
        #print('fidelity=',abs(inner_products[ii]),'angle=',angle(inner_products[ii])/np.pi*180,'test ii=',ii,'\n')
        if(is_picture):
            print('fidelity=',abs(inner_products[ii]),'angle=',angle(inner_products[ii])/np.pi*180,'test ii=',ii,'\n')
            P_0I_M=tensor(basis(3,0)*basis(3,0).dag(),qeye(3))
            P_1I_M=tensor(basis(3,1)*basis(3,1).dag(),qeye(3))
            P_2I_M=tensor(basis(3,2)*basis(3,2).dag(),qeye(3))
            P_I0_M=tensor(qeye(3),basis(3,0)*basis(3,0).dag())
            P_I1_M=tensor(qeye(3),basis(3,1)*basis(3,1).dag())
            P_I2_M=tensor(qeye(3),basis(3,2)*basis(3,2).dag())
            fig, axes = subplots(2,2,figsize=(15, 9))
            P_0I=expect(P_0I_M,states_list.states)
            P_1I=expect(P_1I_M,states_list.states)
            P_2I=expect(P_2I_M,states_list.states)
            P_I0=expect(P_I0_M,states_list.states)
            P_I1=expect(P_I1_M,states_list.states)
            P_I2=expect(P_I2_M,states_list.states)
            axes[0][0].plot(tlist, P_0I)
            axes[0][0].plot(tlist, P_1I)
            axes[0][0].plot(tlist, P_2I)
            axes[0][0].set_xlabel('Time')
            axes[0][0].set_ylabel('probablity of q1 state')
            axes[0][0].legend(("P_0I", "P_1I","P_2I"))
            axes[0][1].plot(tlist, P_I0)
            axes[0][1].plot(tlist, P_I1)
            axes[0][1].plot(tlist, P_I2)
            axes[0][1].set_xlabel('Time')
            axes[0][1].set_ylabel('probablity of q2 state')
            axes[0][1].legend(("P_I0", "P_I1","P_I2"))
            axes[1][0].plot(tlist, q1_z_pulse/2/np.pi)
            axes[1][0].plot(tlist, q2_z_pulse/2/np.pi)
            axes[1][0].set_xlabel('Time')
            axes[1][0].set_ylabel('detune of zbias')
            axes[1][0].legend(("q1_z_pulse", "q2_z_pulse"))
    if(len(test_state)==4):
        [inner_products_op,op_angle]=op_phase(inner_products)
        fidelity=abs(np.mean(inner_products_op))
        print('fidelity=(',fidelity,')  t_gate=',t_gate,'wave_para=',wave_para)
        return fidelity
                    
            


        
    


