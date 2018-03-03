


import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
import numpy as np
from pylab import *
from qutip import *
from scipy.optimize import *
from multiprocessing import Pool
import gc 
import os
def T1fit(t,T1):
    y = np.exp(-t/T1)
    return(y)

def T2fit1(t,T2):
    y = np.exp(-t/T2)*np.sin(0.1*2*np.pi*t+np.pi)
    return(y)
    
def T2fit2(t,T1,T2):
    y = np.exp(-t/T1-(t/T2)**2)*np.sin(0.1*2*np.pi*t+np.pi)
    return(y)

def Ramsey(P):
    tp = P[0]
    gamma_phi = P[1]
    T1 = P[2]
    n_th = 0.00

    options=Options()
    options.atol=1e-8
    options.rtol=1e-6
    options.first_step=0.01
    options.num_cpus= 4
    options.nsteps=1e6
    options.gui='True'
    options.ntraj=1000
    options.rhs_reuse=True


    c_op_list = []
    gamma = 1/T1
    gamma_phi = gamma_phi
    c_op_list.append(np.sqrt(gamma * (1+n_th)) * sm)
    c_op_list.append(np.sqrt(gamma * n_th) * sm.dag())
    c_op_list.append(np.sqrt(gamma_phi) * sm.dag()*sm)
    
    tlist = np.linspace(0,tp,2*tp+1)
#    psi0 = basis(3,1)
    psi0 = (basis(3,1)+basis(3,0)).unit()

    result = mesolve(H,psi0,tlist,c_op_list,[sm+sm.dag(),1j*sm.dag()-1j*sm ,basis(3,1)*basis(3,1).dag()],options = options)
    parameter,cov = curve_fit(T2fit2,tlist,result.expect[1],[T1,1/(0.5*gamma_phi)])
    print(parameter,cov)
    
    
    fig ,axes = plt.subplots(3,1)
    axes[0].plot(tlist,result.expect[0],label = 'X');axes[0].plot(tlist,1/np.exp(1)*np.ones_like(tlist));
    axes[1].plot(tlist,result.expect[1],label = 'Y');axes[1].plot(tlist,1/np.exp(1)*np.ones_like(tlist));
    axes[2].plot(tlist,result.expect[2],label = 'Z');axes[2].plot(tlist,1/np.exp(1)*np.ones_like(tlist));
    axes[1].plot(tlist,np.vectorize(T2fit2)(tlist,parameter[0],parameter[1]),label = 'Fitting')
    plt.show()

    return(parameter)
if __name__ == '__main__':
    
    wq = 0.1*2*np.pi
    etaq = -0.25*2*np.pi
    sm = destroy(3)
    H  = wq*sm.dag()*sm+etaq*basis(3,2)*basis(3,2).dag()
    
    T = 0.4 * 1000
    T1 = 10 * 1000
    T2t = 0.3 * 1000
    gamma_phi = 1.0/T2t 
    P = [T , gamma_phi , T1]
    Ramsey(P)

#    gamma_phi = 1.0/(np.linspace(0.1,3,32)*1000)
##    T1 = np.linspace(0.1,3,16)*1000
#    P = np.array([[3000,i,100*1000] for i in gamma_phi])
##    P = np.array([[3000,1/100/1000,i] for i in T1])
##    P = np.array([[3000,i,j] for i in gamma_phi for j in T1])
#    
#    p = Pool(16)
#    T2para = []
#    for i in range(len(P)):
#        T2para.append(p.apply_async(Ramsey,(P[i],)))
#    para = np.array([T2para[i].get() for i in range(len(T2para))])
#    paraT1 = np.array([i[0] for i in para])
#    paraT2 = np.array([i[1] for i in para])
##    para = para.reshape(len(T1),len(gamma_phi))
#    p.close()
#    p.join()
#    
#    figure();plot(gamma_phi,1/paraT1);xlabel('gamma_phi');ylabel('1/T1_fitting')
#    plt.show()
#    print(np.polyfit(gamma_phi,1/paraT1,1))
#    figure();plot(gamma_phi,1/paraT2);xlabel('gamma_phi');ylabel('1/T2_fitting')
#    plt.show()
#    print(np.polyfit(gamma_phi,1/paraT2,1))
    
#    figure();plot(1/T1,1/paraT1);xlabel('1/T1');ylabel('1/T1_fitting')
#    plt.show()
#    print(np.polyfit(1/T1,1/paraT1,1))
#    figure();plot(1/T1,1/paraT2);xlabel('1/T1');ylabel('1/T2_fitting')
#    plt.show()
#    print(np.polyfit(1/T1,1/paraT2,1))

#    X,Y = np.meshgrid(1/T1,gamma_phi)
#    fig = plt.figure()
#    ax = Axes3D(fig)
#    ax.plot_surface(X,Y,1/para)
    
    
    

