'''
利用纵场来做CZ门，在上升沿和下降沿利用纵场开关关闭耦合，近似共振后，再打开耦合
'''

import time 
import matplotlib.pyplot as plt
import numpy as np
from pylab import *
from qutip import *
from scipy.optimize import *
from scipy import interpolate 
from scipy.special import *
from multiprocessing import Pool
from DE_improvement import *
import gc 
import os
import functools
def initial_wave_z():
    resolution = 1024
    thf = 0.55*pi/2;
    thi = 0.05;
    lam2 = -0.18;
    lam3 = 0.04;
    resolution = 1024;
    
    ti=np.linspace(0,1,resolution)
    han2 = np.vectorize(lambda ti:(1-lam3)*(1-cos(2*pi*ti))+lam2*(1-cos(4*pi*ti))+lam3*(1-cos(6*pi*ti)))
    han2 = han2(ti)
    thsl=thi+(thf-thi)*han2/max(han2)
    
    tlu = np.cumsum(np.sin(thsl))*ti[1]
    tlu=tlu-tlu[0]
    ti=np.linspace(0, tlu[-1], resolution)
    th=interpolate.interp1d(tlu,thsl,'slinear')
    th = th(ti)
    th=1/np.tan(th)
    th=th-th[0]
    th=th/min(th)

    return(th)
def initial_wave_g():
    resolution = 1024
    thf = 0.55*pi/2;
    thi = 0.05;
    lam2 = -0.18;
    lam3 = 0.04;
    resolution = 1024;
    
    ti=np.linspace(0,1,resolution)
    han2 = np.vectorize(lambda ti:(1-lam3)*(1-np.cos(2*np.pi*ti))+lam2*(1-np.cos(4*np.pi*ti))+lam3*(1-np.cos(6*np.pi*ti)))
    han2 = han2(ti)
    thsl=thi+(thf-thi)*han2/np.max(han2)   
    tlu = np.cumsum(np.cos(thsl))*ti[1]
    tlu=tlu-tlu[0]
    ti=np.linspace(0, tlu[-1], resolution)
    th=interpolate.interp1d(tlu,thsl,'slinear')
    th = th(ti)
    th=np.tan(th)
    th=th-th[0]
    th=th/np.max(th)

    return(th)

def CZpulse(t,args):
    delta = args['delta']#能级调节跨度
    t_ramp_ratio = args['t_ramp_ratio']#上升沿时间比例
    t_total = args['t_total']#总时间
    omega = args['omega']#纵场频率
    g_shift = args['g_shift']#在中心稳定区域，调高的耦合强度g
    t_ramp = t_ramp_ratio*t_total

    
    tlist = np.linspace(0,t_total,1024)
    w = interpolate.interp1d(tlist,delta*thz,'slinear')
    
    if t>=0 and t< t_ramp:#上升沿
        pulse = w(t)
        pulse = pulse + 2.404825*omega*np.sin(omega*t)
    elif t>=t_ramp and t<=t_total-t_ramp:#中心稳定区域
        pulse = w(t)

        tlistQS = np.linspace(t_ramp,t_total-t_ramp,1024)
        wg = interpolate.interp1d(tlistQS,g_shift*thg,'slinear')#g
        x = np.linspace(0,2.4048,1024)
        y = g*jv(0,x)
        y = g*(y-np.min(y))/(np.max(y)-np.min(y))
        f = interpolate.interp1d(y,x,'slinear')

        pulse = pulse + f(wg(t))*omega*np.sin(omega*(t-t_ramp))
    elif t>t_total-t_ramp and t<=t_total:
        pulse = w(t)
        pulse = pulse + 2.404825*omega*np.sin(omega*(t-t_total))
    else:
        pulse = 0
    
    return(pulse)

def getfid(T):
    psi = T[0]
    target = T[1]
    output = mesolve(H,psi,tlist,[],[],args = args,options = options)
    
    U1 = basis(N,0)*basis(N,0).dag()+np.exp(1j*(E[l10]-E[l00])*tlist[-1])*basis(N,1)*basis(N,1).dag()
    U2 = basis(N,0)*basis(N,0).dag()+np.exp(1j*(E[l01]-E[l00])*tlist[-1])*basis(N,1)*basis(N,1).dag()
    UT = tensor(U1,U2)
    
    fid = fidelity(UT*output.states[-1],target)
    leakage = [expect(E_uc[0],output.states[-1]) , expect(E_uc[1],output.states[-1])]
    return([fid,leakage,UT*output.states[-1]])

def findstate(S,state):
    l = None
    e0 = eval(state[0])
    e1 = eval(state[1])
    for i in range(9):
        s0 = ptrace(S[i],0)[e0][0][e0]
        s1 = ptrace(S[i],1)[e1][0][e1]
        if abs(s0)>=0.5 and abs(s1)>=0.5 :
            l = i
    if l == None:
        print('No state')
    else:
        return(l)

def QS_gate(P):
    
    global H0,E,S,l11,l10,l01,l00

    delta = P[0]#能级调节跨度
    t_ramp_ratio = P[1]#上升沿时间比例
    t_total = P[2]#总时间
    omega = P[3]#纵场频率
    g_shift = P[4]

    xita0 = P[5]
    xita1 = P[6]

    H0= (wq[0]) * sn[0] + (wq[1]) * sn[1] + eta_q[0]*E_uc[0] + eta_q[1]*E_uc[1] + g * sx[0] * sx[1]
    [E,S] = H0.eigenstates()
    l11 = findstate(S,'11');l10 = findstate(S,'10');l01 = findstate(S,'01');l00 = findstate(S,'00');

    global H,tlist,args,options

    Hd0 = [sn[0],CZpulse]
    H = [H0,Hd0]

    args = {'delta':delta , 't_ramp_ratio': t_ramp_ratio , 't_total': t_total , 'omega':omega , 'g_shift': g_shift}

    tlist = np.linspace(0,t_total,2*t_total+1)
    options=Options()
    options.atol=1e-8
    options.rtol=1e-6
    options.first_step=0.01
    options.num_cpus=8
    options.nsteps=1e6
    options.gui='True'
    options.ntraj=1000
    options.rhs_reuse=True

    fid = []
    leakage0 = []
    leakage1 = []
    outputstate = []

    T = []
    T.append([tensor(basis(3,0),basis(3,0)),tensor(basis(3,0),basis(3,0))])
    T.append([tensor(basis(3,0),basis(3,1)),tensor(basis(3,0),basis(3,1))])
    T.append([tensor(basis(3,1),basis(3,0)),tensor(basis(3,1),basis(3,0))])
    T.append([tensor(basis(3,1),basis(3,1)),-tensor(basis(3,1),basis(3,1))])

    p = Pool(4)
    A = p.map(getfid,T)
    fid = [x[0] for x in A]
    leakage = [x[1] for x in A]
    outputstate = [x[2] for x in A]
    p.close()
    p.join()

    for phi in T:
        A = getfid(phi)
        fid.append(A[0])
        leakage0.append(A[1][0])
        leakage1.append(A[1][1])
        outputstate.append(A[2])
    fid = np.array(fid)
    leakage0 = np.array(leakage0)
    leakage1 = np.array(leakage1)
    outputstate = np.array(outputstate)

    gc.collect()


    process = np.column_stack([outputstate[i].data.toarray() for i in range(len(outputstate))])[(0,1,3,4),:]
    targetprocess = np.array([[1,0,0,0],[0,1,0,0],[0,0,1,0],[0,0,0,-1]])
    compensation = np.array([[1,0,0,0],[0,np.exp(1j*xita1),0,0],[0,0,np.exp(1j*xita0),0],[0,0,0,np.exp(1j*(xita0+xita1))]])
    process = np.dot(compensation,process)
    Error = np.dot(np.conjugate(np.transpose(targetprocess)),process)
    angle = np.angle(Error[0][0])
    Error = Error*np.exp(-1j*angle)#global phase
    Ufidelity = np.abs(np.trace(Error))/4

    print(Ufidelity,P[0]/2/np.pi,P[1],P[2],P[3]/2/np.pi,P[4]/2/np.pi)
    return(-Ufidelity)


if __name__=='__main__':
    starttime=time.time()
    
    global thg,thz
    thg = initial_wave_g()
    thz = initial_wave_z()

    g = 10
    sm = np.array([tensor(destroy(3),qeye(3)) , tensor(qeye(3),destroy(3))])
    E_uc = np.array([tensor(basis(3,2)*basis(3,2).dag(),qeye(3)) , tensor(qeye(3), basis(3,2)*basis(3,2).dag())])
    E_e = np.array([tensor(basis(3,1)*basis(3,1).dag(),qeye(3)),tensor(qeye(3),basis(3,1)*basis(3,1).dag())])
    E_g = np.array([tensor(basis(3,0)*basis(3,0).dag(),qeye(3)) , tensor(qeye(3),basis(3,0)*basis(3,0).dag())])
    sn = np.array([sm[0].dag()*sm[0] , sm[1].dag()*sm[1]])
    sx = np.array([sm[0].dag()+sm[0],sm[1].dag()+sm[1]]);
    sy = np.array([1j*(sm[0].dag()-sm[0]) , 1j*(sm[1].dag()-sm[1])]);
    sz = np.array([E_g[0] - E_e[0] , E_g[1] - E_e[1]])


    N = 3
    g = 0.0138 * 2 * np.pi
    wq= np.array([4.3 , 5.18  ]) * 2 * np.pi
    eta_q=  np.array([-0.230 , -0.216]) * 2 * np.pi

    DE = 1
    if DE == 1:
        x_l = np.array([0.45*2*np.pi , 0.01 , 20 , 0.001*2*np.pi , 0.0001*2*np.pi,-np.pi,-np.pi])#delta, t_ramp_ratio,t_total,omega,g_shift,xita0,xita1
        x_u = np.array([0.75*2*np.pi , 0.49 , 80 , 0.2*2*np.pi , g , np.pi , np.pi])
        de(QS_gate,n = 7,m_size = 32,f = 0.9 , cr = 0.5 ,S = 1 , iterate_time = 400,x_l = x_l,x_u = x_u,inputfile = None , process= 35)
    else:
        x0 = [0.664*2*np.pi , 0.15 , 40 , 0.1*2*np.pi , g , 0 , 0]

        result = minimize(QS_gate , x0 , method="Nelder-Mead",options={'disp': True})
        print(result)

        bnds = [(0.45*2*np.pi,0.75*2*np.pi) , (0.01,0.49) , (20,80) , ( 0.001*2*np.pi , 0.2*2*np.pi),(0.0001*2*np.pi,g),(-np.pi,np.pi),(-np.pi,np.pi)]
        res = minimize(QS_gate, x0, method='SLSQP', bounds=bnds)
        print(res)
       
