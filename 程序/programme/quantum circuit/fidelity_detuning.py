from time import clock
from qutip import *
import numpy as np
import matplotlib.pyplot as plt 
from pylab import *
from gate_evolution import *
from multiprocessing import Pool
import os

def fid_detuning(detuning):
    quset = qusetting()
    Operator = ['I200'  ,  'I' ]
    quset.w_q[1] = quset.w_q[0]+detuning*2*np.pi
    psi0 = tensor(basis(quset.N,quset.n) , basis(3,1) ,  basis(3,0))
    sm,E_uc,E_e,E_g,sn,sx,sxm,sy,sym,sz,En = initial(quset)[-11:]
    result , tlist = gate_evolution(psi0 , Operator , setting = quset)
    rf0 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(En[0])*tlist[-1])*basis(3,1)*basis(3,1).dag()
    rf1 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(En[1])*tlist[-1])*basis(3,1)*basis(3,1).dag()
    U = tensor(qeye(quset.N),rf0,rf1)
    target = tensor(basis(quset.N,quset.n) , basis(3,1) ,  basis(3,0))
    fid=fidelity(U*result.states[-1]*result.states[-1].dag()*U.dag(), target)
    print(fid,quset.w_q[1]/2/np.pi)
    return([fid,detuning])

if __name__ == '__main__':
    starttime=clock()
    g = linspace(0,0.050,51)
#    g = [0.033358578617]
    p = Pool(3)
    A = p.map(fid_detuning,g)
    p.close()
    p.join()
    fid =  np.array([x[0] for x in A])
    detuning = np.array([x[1] for x in A])
    opt = detuning[np.where(fid== max(fid))]
    
    print(opt[0]  , max(fid))
    fig, axes = plt.subplots(1, 1, figsize=(10,6))
    axes.plot(detuning,fid)

    
    finishtime=clock()
    print( 'Time used: ', (finishtime-starttime), 's')