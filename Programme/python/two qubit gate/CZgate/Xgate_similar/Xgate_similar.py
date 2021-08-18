import time 
import matplotlib.pyplot as plt
import numpy as np
from pylab import *
from qutip import *
from scipy.optimize import *
from scipy import interpolate 
from multiprocessing import Pool
import gc 

def CZgate(P):
    #==============================================================================
    '''Hamilton'''
    global Ee,H0
    HCoupling = g*(sm[0]+sm[0].dag())*(sm[1]+sm[1].dag())
    H_eta = eta_q[0] * E_uc[0] + eta_q[1] * E_uc[1]
    Hq = w_q[0]*sn[0] + w_q[1]*sn[1]
    H0 = Hq + H_eta + HCoupling
    
    
    E = H0.eigenstates()
    Ee = E[0]
    bastate = E[1]
    
    tp = P[0]
    delta = P[1]
    
    Hd0 = [sn[0],CZ0]
#    Hd1 = [sn[1],CZ1]
#    H = [H0,Hd0,Hd1]
    H = [H0,Hd0]
    args = {'tp':tp,'delta':delta}
    
    #==============================================================================
    '''evolution'''
    
    options=Options()
    options.atol=1e-8
    options.rtol=1e-6
    options.first_step=0.01
    options.num_cpus= 4
    options.nsteps=1e6
    options.gui='True'
    options.ntraj=1000
    options.rhs_reuse=False
    
#    psi0 = (bastate[0]+bastate[2]+bastate[3]-bastate[9]).unit()
#    psi0 = (bastate[1]-bastate[4]).unit()
#    psi0 = bastate[1]
    
    
#    psi0 = tensor( (basis(3,0)+basis(3,1)).unit() , (basis(3,0)+basis(3,1)).unit())
    psi0 = tensor( (basis(3,0)).unit() , (basis(3,0)+basis(3,1)).unit())
#    psi0 = tensor( (basis(3,0)+basis(3,1)).unit() , (basis(3,0)).unit())
#    psi0 = tensor( (basis(3,0)).unit() , (basis(3,1)).unit())



    tlist = np.linspace(0,tp,tp+1)

    result = mesolve(H,psi0,tlist,[],[],args = args,options = options)


#==============================================================================
#    n_x0 = [] ; n_y0 = [] ; n_z0 = [];
#    n_x1 = [] ; n_y1 = [] ; n_z1 = [];
#    for t in range(0,len(tlist)):
#        U0 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(Ee[1]-Ee[0])*tlist[t])*basis(3,1)*basis(3,1).dag()
#        U1 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(Ee[2]-Ee[0])*tlist[t])*basis(3,1)*basis(3,1).dag()
#        U = tensor(U0,U1)
##        U = (1j*H0*tlist[t]).expm()
#        
#        opx0 = U.dag()*sx[0]*U
#        opy0 = U.dag()*sy[0]*U
#        opz0 = sz[0]
#        opx1 = U.dag()*sx[1]*U
#        opy1 = U.dag()*sy[1]*U
#        opz1 = sz[1]
#        n_x0.append(expect(opx0,result.states[t]))
#        n_y0.append(expect(opy0,result.states[t]))
#        n_z0.append(expect(opz0,result.states[t]))
#        n_x1.append(expect(opx1,result.states[t]))
#        n_y1.append(expect(opy1,result.states[t]))
#        n_z1.append(expect(opz1,result.states[t]))
#
#    
#    
#    sphere = Bloch()
#    sphere.add_points([n_x0 , n_y0 , n_z0])
#    sphere.add_vectors([n_x0[-1],n_y0[-1],n_z0[-1]])
#    sphere.make_sphere() 
#    sphere = Bloch()
#    sphere.add_points([n_x1 , n_y1 , n_z1])
#    sphere.add_vectors([n_x1[-1],n_y1[-1],n_z1[-1]])
#    sphere.make_sphere() 
#    plt.show()


#==============================================================================
    
    '''
    fidelity
    '''
    U0 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(Ee[1]-Ee[0])*tlist[-1])*basis(3,1)*basis(3,1).dag()
    U1 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(Ee[2]-Ee[0])*tlist[-1])*basis(3,1)*basis(3,1).dag()
    UT = tensor(U0,U1)
#    UT = (1j*H0*tlist[-1]).expm()
    

#    target = (bastate[1]+bastate[4]).unit()
#    target = (bastate[4]).unit()
    target = tensor( (basis(3,0)).unit() , (basis(3,0)+basis(3,1)).unit())
    
    fid = fidelity(UT*result.states[-1]*result.states[-1].dag()*UT.dag(),target)
    angle = np.angle((psi0.dag()*UT*result.states[-1])[0])
    print('fidelity = ',fid,P,angle/np.pi*180)
    
#    psi0 = bastate[4]    
#    tlist = np.linspace(0,tp,tp+1)
#    result = mesolve(H,psi0,tlist,[],[],args = args,options = options)
#    U0 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(Ee[1]-Ee[0])*tlist[-1])*basis(3,1)*basis(3,1).dag()
#    U1 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(Ee[2]-Ee[0])*tlist[-1])*basis(3,1)*basis(3,1).dag()
#    UT = tensor(U0,U1)
##    UT = (1j*H0*tlist[-1]).expm()
#    target = (bastate[4]).unit()
#    fid = fidelity(UT*result.states[-1]*result.states[-1].dag()*UT.dag(),target)
#    angle = np.angle((psi0.dag()*UT*result.states[-1])[0])
#    print('fidelity = ',fid,P,angle/np.pi*180)
    #==============================================================================
    return(fid,UT*result.states[-1])



if __name__=='__main__':
    
    starttime  = time.time()

    sm = np.array([tensor(destroy(3),qeye(3)) , tensor(qeye(3),destroy(3))])
    E_uc = np.array([tensor(basis(3,2)*basis(3,2).dag(),qeye(3)) , tensor(qeye(3), basis(3,2)*basis(3,2).dag())])
    E_e = np.array([tensor(basis(3,1)*basis(3,1).dag(),qeye(3)),tensor(qeye(3),basis(3,1)*basis(3,1).dag())])
    E_g = np.array([tensor(basis(3,0)*basis(3,0).dag(),qeye(3)) , tensor(qeye(3),basis(3,0)*basis(3,0).dag())])
    sn = np.array([sm[0].dag()*sm[0] , sm[1].dag()*sm[1]]) 
    sx = np.array([sm[0].dag()+sm[0],sm[1].dag()+sm[1]]);
    sxm = np.array([tensor(Qobj([[0,1,0],[1,0,0],[0,0,0]]),qeye(3)) , tensor(qeye(3),Qobj([[0,1,0],[1,0,0],[0,0,0]]))])
    sy = np.array([1j*(sm[0].dag()-sm[0]) , 1j*(sm[1].dag()-sm[1])]);
    sym = np.array([tensor(Qobj([[0,-1j,0],[1j,0,0],[0,0,0]]),qeye(3)) , tensor(qeye(3),Qobj([[0,-1j,0],[1j,0,0],[0,0,0]]))])
    sz = np.array([E_g[0] - E_e[0] , E_g[1] - E_e[1]])