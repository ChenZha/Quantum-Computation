# -*- coding: utf-8 -*-
"""
Created on Fri Feb 24 16:20:57 2017

@author: Chen
"""

from qutip import *
import numpy as np
import matplotlib.pyplot as plt 
from pylab import *



from time import clock
starttime=clock()

#==============================================================================
#a = tensor(destroy(N),qeye(level),qeye(level))
#sm0 = tensor(qeye(N),Qobj([[0,1,0],[0,0,1],[0,0,0]]),qeye(level))
#sm1 = tensor(qeye(N),qeye(level),Qobj([[0,1,0],[0,0,1],[0,0,0]]))
#
#E_uc0 = tensor(qeye(N),basis(3,2)*basis(3,2).dag(),qeye(level))
#E_uc1 = tensor(qeye(N),qeye(level), basis(3,2)*basis(3,2).dag())#用以表征非简谐性的对角线最后一项(非计算能级)
##E_uc1 = tensor(qeye(N),qeye(level), Qobj([[0,0],[0,1]]))
#
#E_e0 = tensor(qeye(N),basis(3,1)*basis(3,1).dag(),qeye(level))
#E_e1 = tensor(qeye(N),qeye(level),basis(3,1)*basis(3,1).dag())  #激发态
#
#E_g0 = tensor(qeye(N),basis(3,0)*basis(3,0).dag(),qeye(level))
#E_g1 = tensor(qeye(N),qeye(level),basis(3,0)*basis(3,0).dag())  #基态
#
#sn0 = sm0.dag()*sm0
#sn1 = sm1.dag()*sm1
#
#sx0 = sm0.dag()+sm0;sxm0 = tensor(qeye(N),Qobj([[0,1,0],[1,0,0],[0,0,0]]),qeye(level))
#sx1 = sm1.dag()+sm1;sxm1 = tensor(qeye(N),qeye(level),Qobj([[0,1,0],[1,0,0],[0,0,0]]))
#
#sy0 = -1j*(sm0.dag()-sm0);sym0 = tensor(qeye(N),Qobj([[0,-1j,0],[1j,0,0],[0,0,0]]),qeye(level))
#sy1 = -1j*(sm1.dag()-sm1);sym1 = tensor(qeye(N),qeye(level),Qobj([[0,-1j,0],[1j,0,0],[0,0,0]]))
#
#sz0 = E_g0 - E_e0
#sz1 = E_g1 - E_e1
#
#Heta0 = -eta_q[0] * E_uc0
#Heta1 = -eta_q[1] * E_uc1  #非简谐项
#
#HC = w_c*a.dag()*a
#Hcoupling0 = g[0] * sx0 * (a.dag()+a) 
#Hcoupling1 = g[1] * sx1 * (a.dag()+a)
#Hcoupling = Hcoupling0 + Hcoupling1
#if level == 2:              #双能级不含非简谐项
#    Hq0 =  w_q[0]*sn0
#    Hq1 =  w_q[1]*sn1
#else:            #三能级含有非简谐项
#    Hq0 =  w_q[0]*sn0 + Heta0 
#    Hq1 =  w_q[1]*sn1 + Heta1 
#==============================================================================

#==============================================================================
'''
single qubit gate
'''
def Gate_rx(inxc,t0,t1,phi=np.pi,omega=0.033358578617,width = 6):
    args_i={}
    w_t_i='(w_t'+str(inxc)+')*('+str(t0)+'<t<='+str(t1)+')'    
    print(DRAG)
    if DRAG:
        D_t_i='(Omega'+str(inxc)+'*(np.exp(-(t-20-'+str(t0)+')**2/2.0/width'+str(inxc)+'**2)*np.cos(t*f'+str(inxc)+')+(t-20-'+str(t0)+')/2/width'+str(inxc)+'**2/'+str(eta_q[inxc])+'*np.exp(-(t-20-'+str(t0)+')**2/2.0/width'+str(inxc)+'**2)*np.cos(t*f'+str(inxc)+'+np.pi/2)))*('+str(t0)+'<t<='+str(min(t1,t0+40))+')'
#        D_t_i = 'Omega' + str(inxc) + '*np.cos(t*f'+str(inxc)+')'
    else:
        D_t_i='(Omega'+str(inxc)+'*np.exp(-(t-20-'+str(t0)+')**2/2.0/width'+str(inxc)+'**2)*np.cos(t*f'+str(inxc)+'))*('+str(t0)+'<t<='+str(min(t1,t0+40))+')'
    args_i['w_t'+str(inxc)]=w_q[inxc]
    args_i['f'+str(inxc)]=w_q[inxc]
    args_i['Omega'+str(inxc)]=omega*2*phi
    args_i['width'+str(inxc)]=width
    return w_t_i,D_t_i,args_i     

def Gate_ry(inxc,t0,t1,phi=np.pi,omega=0.033358578617,width = 6):
    args_i={}
    w_t_i='(w_t'+str(inxc)+')*('+str(t0)+'<t<='+str(t1)+')'
    if DRAG:
        D_t_i='(Omega'+str(inxc)+'*(np.exp(-(t-20-'+str(t0)+')**2/2.0/width'+str(inxc)+'**2)*np.cos(t*f'+str(inxc)+'+np.pi/2)+(t-20-'+str(t0)+')/2/width'+str(inxc)+'**2/'+str(eta_q[inxc])+'*np.exp(-(t-20-'+str(t0)+')**2/2.0/width'+str(inxc)+'**2)*np.cos(t*f'+str(inxc)+'+np.pi)))*('+str(t0)+'<t<='+str(min(t1,t0+40))+')'
    else:
        D_t_i='(Omega'+str(inxc)+'*np.exp(-(t-20-'+str(t0)+')**2/2.0/width'+str(inxc)+'**2)*np.cos(t*f'+str(inxc)+'+np.pi/2))*('+str(t0)+'<t<='+str(min(t1,t0+40))+')'
    args_i['w_t'+str(inxc)]=w_q[inxc]
    args_i['f'+str(inxc)]=w_q[inxc]
    args_i['Omega'+str(inxc)]=omega*2*phi
    args_i['width'+str(inxc)]=width
    return w_t_i,D_t_i,args_i   
def Gate_rz(inxc,t0,t1,phi=np.pi,delta=0.069641896319,width = 6):

    args_i={}
    w_t_i='(w_t'+str(inxc)+'+delta'+str(inxc)+'*np.exp(-(t-20-'+str(t0)+')**2/2.0/width'+str(inxc)+'**2))*('+str(t0)+'<t<='+str(t1)+')'
    D_t_i='0*('+str(t0)+'<t<='+str(t1)+')'
    args_i['w_t'+str(inxc)]=w_q[inxc]
    args_i['width'+str(inxc)]=width
    args_i['delta'+str(inxc)]=delta*phi
    return w_t_i,D_t_i,args_i

def Gate_i(inxc,t0,t1):
    args_i={}
    w_t_i='(w_t'+str(inxc)+')*('+str(t0)+'<t<='+str(t1)+')'
    D_t_i='0*('+str(t0)+'<t<='+str(t1)+')'
    args_i['w_t'+str(inxc)]=w_q[inxc]
    return w_t_i,D_t_i,args_i
#==============================================================================

#==============================================================================
'''
two qubits gate
'''
def Gate_iSWAP(inxc,inxt,t0,t1,phi=np.pi,deltat=361,width = 0.5):

    args_i={}
    w_t_i='(w_t'+str(inxc)+'+delta'+str(inxc)+'/(1 + np.exp(-(t-'+str(t0)+'-t'+str(inxc)+'0)/width'+str(inxc)+')) -delta'+str(inxc)+'/(1 + np.exp(-(t-'+str(t0)+'-t'+str(inxc)+'1)/width'+str(inxc)+')))*('+str(t0)+'<t<='+str(t1)+')'
    D_t_i='0*('+str(t0)+'<t<='+str(t1)+')'
    args_i['w_t'+str(inxc)]=w_q[inxc]
    args_i['width'+str(inxc)]=width
    args_i['t'+str(inxc)+'0']=2
    args_i['t'+str(inxc)+'1']=deltat
    args_i['delta'+str(inxc)]=w_q[inxt]-w_q[inxc]
    return w_t_i,D_t_i,args_i

def Gate_CZ(inxc,inxt,t0,t1,phi=np.pi,deltat=600,width = 10):

    args_i={}
    w_t_i='(w_t'+str(inxc)+'+delta'+str(inxc)+'/(1 + np.exp(-(t-'+str(t0)+'-t'+str(inxc)+'0)/width'+str(inxc)+')) -delta'+str(inxc)+'/(1 + np.exp(-(t-'+str(t0)+'-t'+str(inxc)+'1)/width'+str(inxc)+')))*('+str(t0)+'<t<='+str(t1)+')'
    D_t_i='0*('+str(t0)+'<t<='+str(t1)+')'
    args_i['w_t'+str(inxc)]=w_q[inxc]
    args_i['width'+str(inxc)]=width
    args_i['t'+str(inxc)+'0']=100
    args_i['t'+str(inxc)+'1']=deltat
    args_i['delta'+str(inxc)]=(w_q[inxt]-w_q[inxc]-eta_q[inxt])
    
#    print(w_t_i)
#    print(args_i)
    return w_t_i,D_t_i,args_i


#==============================================================================

#==============================================================================
def GenerateH(Operator):
    lenc = len(Operator)
    HCoupling = g[0]*(a*sm0.dag() + sm0*a.dag()) + g[1]*(a*sm1.dag() + sm1*a.dag())
    Hc = w_c * a.dag() * a 
    H_eta = -eta_q[0] * E_uc0 - eta_q[1] * E_uc1
    H= Hc + H_eta + HCoupling
    lenc = len(Operator)
    args = {}
    w_t=[]
    D_t=[]
    for inxc in range(0,lenc):
        if Operator[inxc][0]=='X':
            w_t_i,D_t_i,args_i=Gate_rx(inxc,t0,t1)
        elif Operator[inxc][0]=='Y':
            w_t_i,D_t_i,args_i=Gate_ry(inxc,t0,t1)
        elif Operator[inxc][0]=='Z':
            w_t_i,D_t_i,args_i=Gate_rz(inxc,t0,t1)
        elif Operator[inxc][0]=='i':
            w_t_i,D_t_i,args_i=Gate_iSWAP(inxc,float(Operator[inxc][5:]),t0,t1)
        elif Operator[inxc][0]=='C':
            if Operator[inxc][1]=='Z':
                w_t_i,D_t_i,args_i=Gate_CZ(inxc,float(Operator[inxc][2:]),t0,t1)
        elif Operator[inxc][0]=='I':
                w_t_i,D_t_i,args_i=Gate_i(inxc,t0,t1)
        w_t.append(w_t_i)
        D_t.append(D_t_i)
        args=dict(args,**args_i)##在args里加入args_i
    H_q0 = [sn0 , w_t[0]]
    H_q1 = [sn1 , w_t[1]]
    H_d0 = [sx0 , D_t[0]] 
    H_d1 = [sx1 , D_t[1]]
    H = [H , H_q0 , H_q1 , H_d0 , H_d1]
    return H , args
    
    
#==============================================================================


#==============================================================================
#fig, axes = plt.subplots(2, 6, figsize=(10,6))
#axes[0][0].plot(tlist, result.expect[0])
#axes[0][1].plot(tlist, result.expect[1])
#axes[0][2].plot(tlist, result.expect[2])
#axes[0][3].plot(tlist, result.expect[3])
#axes[0][4].plot(tlist, result.expect[9])
#axes[0][5].plot(tlist, result.expect[4])
#axes[0][0].set_title('X1')
#axes[0][1].set_title('Y1')
#axes[0][2].set_title('Z1')
#axes[0][3].set_title('N_a1')
#axes[0][4].set_title('N_c')
#axes[0][5].set_title('N_uc0')
#axes[1][0].plot(tlist, result.expect[5])
#axes[1][1].plot(tlist, result.expect[6])
#axes[1][2].plot(tlist, result.expect[7])
#axes[1][3].plot(tlist, result.expect[8])
#axes[1][4].plot(tlist, result.expect[9])
#axes[1][5].plot(tlist, result.expect[10])
#axes[1][0].set_title('X2')
#axes[1][1].set_title('Y2')
#axes[1][2].set_title('Z2')
#axes[1][3].set_title('N_a2')
#axes[1][4].set_title('N_c')
#axes[1][5].set_title('N_uc1')
#sphere = Bloch()
#sphere.add_points([result.expect[0] , result.expect[1] , result.expect[2]])
#sphere.make_sphere()
#plt.show()
#sphere = Bloch()
#sphere.add_points([result.expect[5] , result.expect[6] , result.expect[7]])
#sphere.make_sphere()
#plt.show()
#==============================================================================

#==============================================================================
def evolutionplot(target,result):
    n_x = [] ; n_y = [] ; n_z = []
    for t in range(0,len(tlist)):
        if RF:
            U = (np.exp(1j*(2*w_q[target]-eta_q[target])*tlist[t])*eval('E_uc'+str(eval('target')))+np.exp(1j*w_q[target]*tlist[t])*eval('E_e'+str(eval('target')))+eval('E_g'+str(eval('target')))).dag()
            opx = U*eval('sxm'+str(eval('target')))*U.dag()
            opy = U*eval('sym'+str(eval('target')))*U.dag()
            opz = U*eval('sz'+str(eval('target')))*U.dag()
            
        else:
            opx = eval('sxm'+str(eval('target')))
            opy = eval('sym'+str(eval('target')))
            opz = eval('sz'+str(eval('target')))
            
    
        n_x.append(expect(opx,result.states[t]))
        n_y.append(expect(opy,result.states[t]))
        n_z.append(expect(opz,result.states[t]))
    fig, axes = plt.subplots(1, 3, figsize=(10,6))
    
    axes[0].plot(tlist, n_x, label='X')
    axes[1].plot(tlist, n_y, label='Y')
    axes[2].plot(tlist, n_z, label='Z')
    sphere = Bloch()
    sphere.add_points([n_x , n_y , n_z])
    sphere.make_sphere() 
    plt.show()
#==============================================================================
if __name__=='__main__':
    options=Options()
    #options.atol=1e-12
    #options.rtol=1e-10
    options.first_step=0.01
    options.num_cpus= 4
    options.nsteps=1e6
    options.gui='True'
    options.ntraj=1000
    options.rhs_reuse=False
#==============================================================================    
    '''
    qubit's parameters
    '''
    w_c = 7.0  * 2 * np.pi  # cavity frequency
    w_q = np.array([ 5.0 , 5.0 ]) * 2 * np.pi
    g = np.array([0.01 , 0.01]) * 2 * np.pi
    eta_q = np.array([0.2 , 0.2]) * 2 * np.pi
    N = 3              # number of cavity fock states
    n= 0
    level = 3  #能级数
#==============================================================================
    psi0 = tensor(basis(N,n) , basis(level,0) ,  basis(level,0))
    tlist = np.linspace(0,41,201)
#==============================================================================

#==============================================================================
    '''
    Operators
    '''
    a = tensor(destroy(N),qeye(level),qeye(level))
    sm0 = tensor(qeye(N),destroy(level),qeye(level))
    sm1 = tensor(qeye(N),qeye(level),destroy(level))
    
    E_uc0 = tensor(qeye(N),basis(3,2)*basis(3,2).dag(),qeye(level))
    E_uc1 = tensor(qeye(N),qeye(level), basis(3,2)*basis(3,2).dag())#用以表征非简谐性的对角线最后一项(非计算能级)
    #E_uc1 = tensor(qeye(N),qeye(level), Qobj([[0,0],[0,1]]))
    
    E_e0 = tensor(qeye(N),basis(3,1)*basis(3,1).dag(),qeye(level))
    E_e1 = tensor(qeye(N),qeye(level),basis(3,1)*basis(3,1).dag())  #激发态
    
    E_g0 = tensor(qeye(N),basis(3,0)*basis(3,0).dag(),qeye(level))
    E_g1 = tensor(qeye(N),qeye(level),basis(3,0)*basis(3,0).dag())  #基态
    
    sn0 = sm0.dag()*sm0
    sn1 = sm1.dag()*sm1
    
    sx0 = sm0.dag()+sm0;sxm0 = tensor(qeye(N),Qobj([[0,1,0],[1,0,0],[0,0,0]]),qeye(level))
    sx1 = sm1.dag()+sm1;sxm1 = tensor(qeye(N),qeye(level),Qobj([[0,1,0],[1,0,0],[0,0,0]]))
    
    sy0 = -1j*(sm0.dag()-sm0);sym0 = tensor(qeye(N),Qobj([[0,-1j,0],[1j,0,0],[0,0,0]]),qeye(level))
    sy1 = -1j*(sm1.dag()-sm1);sym1 = tensor(qeye(N),qeye(level),Qobj([[0,-1j,0],[1j,0,0],[0,0,0]]))
    
    sz0 = E_g0 - E_e0
    sz1 = E_g1 - E_e1
    
#    Heta0 = -eta_q[0] * E_uc0
#    Heta1 = -eta_q[1] * E_uc1  #非简谐项
#    
#    HC = w_c*a.dag()*a
#    Hcoupling0 = g[0] * sx0 * (a.dag()+a) 
#    Hcoupling1 = g[1] * sx1 * (a.dag()+a)
#    Hcoupling = Hcoupling0 + Hcoupling1
#    if level == 2:              #双能级不含非简谐项
#        Hq0 =  w_q[0]*sn0
#        Hq1 =  w_q[1]*sn1
#    else:            #三能级含有非简谐项
#        Hq0 =  w_q[0]*sn0 + Heta0 
#        Hq1 =  w_q[1]*sn1 + Heta1 
#==============================================================================
    t0 = 0 ;  t1 = 40      
    DRAG = True
    RF = True
    Operator = ['Y'  ,  'X' ]
    #H = HC + Hq0 + Hq1 + Hcoupling
    H , args = GenerateH(Operator)
    
    
        
    #result = mesolve(H,psi0,tlist,[],[sxm0,sym0,sz0,sn0,E_uc0,sxm1,sym1,sz1,sn1,a.dag()*a,E_uc1])
    result = mesolve(H,psi0,tlist,[],[],args = args,options = options)
    
    evolutionplot(0 , result)
    evolutionplot(1 , result)

#==============================================================================  

finishtime=clock()
print ('Time used: ', (finishtime-starttime), 's')
