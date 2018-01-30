import time 
import csv
import matplotlib.pyplot as plt
import matplotlib as mpl
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
import gc 
import sys




def GetOperator(Num_Q):
    cmdstr=''
    sm=[]
    for II in range(0,Num_Q):
        cmdstr=''
        for JJ in range(0,Num_Q):
            if II==JJ:
                cmdstr+='destroy(3),'
            else:
                cmdstr+='qeye(3),'
        sm.append(eval('tensor('+cmdstr+')'))

    E_uc=[]
    for II in range(0,Num_Q):
        cmdstr=''
        for JJ in range(0,Num_Q):
            if II==JJ:
                cmdstr+='basis(3,2)*basis(3,2).dag(),'
            else:
                cmdstr+='qeye(3),'
        E_uc.append(eval('tensor('+cmdstr+')'))
    
    E_e=[]
    for II in range(0,Num_Q):
        cmdstr=''
        for JJ in range(0,Num_Q):
            if II==JJ:
                cmdstr+='basis(3,1)*basis(3,1).dag(),'
            else:
                cmdstr+='qeye(3),'
        E_e.append(eval('tensor('+cmdstr+')'))
    
    E_g=[]
    for II in range(0,Num_Q):
        cmdstr=''
        for JJ in range(0,Num_Q):
            if II==JJ:
                cmdstr+='basis(3,0)*basis(3,0).dag(),'
            else:
                cmdstr+='qeye(3),'
        E_g.append(eval('tensor('+cmdstr+')'))
        
    Sn=[]
    Sx=[]
    Sy=[]
    for II in range(0,Num_Q):
        Sn.append(sm[II].dag()*sm[II])
        Sx.append(sm[II].dag()+sm[II])
        Sy.append(1j*(sm[II].dag()-sm[II]))   
        
    return sm, E_uc, E_e, E_g, Sn, Sx, Sy


def getfid(T):
    psi = T[0]
    target = T[1]
    output = mesolve(H,psi,tlist,[],[],args = args,options = options)
    
    U1 = basis(N,0)*basis(N,0).dag()+np.exp(1j*(E[l11111]-E[l01111]+E[l10111]-E[l00111])/2*tlist[-1])*basis(N,1)*basis(N,1).dag()
    U2 = basis(N,0)*basis(N,0).dag()+np.exp(1j*(E[l11111]-E[l10111]+E[l01111]-E[l00111])/2*tlist[-1])*basis(N,1)*basis(N,1).dag()
    U3 = basis(N,0)*basis(N,0).dag()+np.exp(1j*(E[l11111]-E[l11011]+E[l01111]-E[l01011])/2*tlist[-1])*basis(N,1)*basis(N,1).dag()
    U4 = basis(N,0)*basis(N,0).dag()+np.exp(1j*(E[l11111]-E[l11101]+E[l01111]-E[l01101])/2*tlist[-1])*basis(N,1)*basis(N,1).dag()
    U5 = basis(N,0)*basis(N,0).dag()+np.exp(1j*(E[l11111]-E[l11110]+E[l01111]-E[l01110])/2*tlist[-1])*basis(N,1)*basis(N,1).dag()
    
    UT = tensor(U1,U2,U3,U4,U5)
    
    fid = fidelity(UT*output.states[-1]*output.states[-1].dag()*UT.dag(),target)
    
    leakage = [expect(E_uc[i],output.states[-1]) for i in range(NumQ)]

#==============================================================================
#    n_x = np.zeros([5,len(tlist)]) ;
#    n_y = np.zeros([5,len(tlist)]) ;
#    n_z = np.zeros([5,len(tlist)]) ;
#    l = np.zeros([5,len(tlist)]);
#    for t in range(0,len(tlist)):
#        U1 = basis(N,0)*basis(N,0).dag()+np.exp(1j*(E[l11111]-E[l01111]+E[l10111]-E[l00111])/2*tlist[t])*basis(N,1)*basis(N,1).dag()
#        U2 = basis(N,0)*basis(N,0).dag()+np.exp(1j*(E[l11111]-E[l10111]+E[l01111]-E[l00111])/2*tlist[t])*basis(N,1)*basis(N,1).dag()
#        U3 = basis(N,0)*basis(N,0).dag()+np.exp(1j*(E[l11111]-E[l11011]+E[l01111]-E[l01011])/2*tlist[t])*basis(N,1)*basis(N,1).dag()
#        U4 = basis(N,0)*basis(N,0).dag()+np.exp(1j*(E[l11111]-E[l11101]+E[l01111]-E[l01101])/2*tlist[t])*basis(N,1)*basis(N,1).dag()
#        U5 = basis(N,0)*basis(N,0).dag()+np.exp(1j*(E[l11111]-E[l11110]+E[l01111]-E[l01110])/2*tlist[t])*basis(N,1)*basis(N,1).dag()
#        
#        U = tensor(U1,U2,U3,U4,U5)
#        for i in range(5):
#            n_x[i][t] = expect(U.dag()*(sm[i].dag()+sm[i])*U,output.states[t])
#            n_y[i][t] = expect(U.dag()*(1j*sm[i].dag()-1j*sm[i])*U,output.states[t])
#            n_z[i][t] = expect(U.dag()*(tensor(qeye(3),qeye(3),qeye(3),qeye(3),qeye(3))-2*sm[i].dag()*sm[i])*U,output.states[t])
#            l[i][t] = expect(E_uc[i],output.states[t])
##
##
##        
##
##
#    fig ,axes = plt.subplots(3,2)
#    axes[0][0].plot(tlist,n_x[0],label = 'X0');
#    axes[0][0].plot(tlist,n_y[0],label = 'Y0');
#    axes[0][0].plot(tlist,n_z[0],label = 'Z0');axes[0][0].set_xlabel('t');axes[0][0].set_ylabel('Population')
#    axes[0][0].legend(loc = 'upper left');plt.show()
#
#    axes[0][1].plot(tlist,n_x[1],label = 'X1');
#    axes[0][1].plot(tlist,n_y[1],label = 'Y1');
#    axes[0][1].plot(tlist,n_z[1],label = 'Z1');axes[0][1].set_xlabel('t');axes[0][1].set_ylabel('Population')
#    axes[0][1].legend(loc = 'upper left');plt.show()
#
#    axes[1][0].plot(tlist,n_x[2],label = 'X2');
#    axes[1][0].plot(tlist,n_y[2],label = 'Y2');
#    axes[1][0].plot(tlist,n_z[2],label = 'Z2');axes[1][0].set_xlabel('t');axes[1][0].set_ylabel('Population')
#    axes[1][0].legend(loc = 'upper left');plt.show()
#
#    axes[1][1].plot(tlist,n_x[3],label = 'X3');
#    axes[1][1].plot(tlist,n_y[3],label = 'Y3');
#    axes[1][1].plot(tlist,n_z[3],label = 'Z3');axes[1][1].set_xlabel('t');axes[1][1].set_ylabel('Population')
#    axes[1][1].legend(loc = 'upper left');plt.show();
#    
#    axes[2][0].plot(tlist,n_x[4],label = 'X4');
#    axes[2][0].plot(tlist,n_y[4],label = 'Y4');
#    axes[2][0].plot(tlist,n_z[4],label = 'Z4');axes[2][0].set_xlabel('t');axes[2][0].set_ylabel('Population')
#    axes[2][0].legend(loc = 'upper left');plt.show();
#    plt.tight_layout()     
#==============================================================================

    return([fid,leakage[0],UT*output.states[-1]])

def findstate(S,state):
    l = None
    e0 = eval(state[0])
    e1 = eval(state[1])
    e2 = eval(state[2])
    e3 = eval(state[3])
    e4 = eval(state[4])
    for i in range(243):
        s0 = ptrace(S[i],0)[e0][0][e0]
        s1 = ptrace(S[i],1)[e1][0][e1]
        s2 = ptrace(S[i],2)[e2][0][e2]
        s3 = ptrace(S[i],3)[e3][0][e3]
        s4 = ptrace(S[i],4)[e4][0][e4]
        if abs(s0)>=0.5 and abs(s1)>=0.5  and abs(s2)>=0.5 and abs(s3)>=0.5 and abs(s4)>=0.5:
            l = i
    if l == None:
        print('No state_'+state)
    else:
        return(l)



def CNOT(P):
    
    tp = P[0]
    omega = P[1]

    

    global H,tlist,args,options
    
    
    f0 = (E[l11111]-E[l01111]+E[l10111]-E[l00111])/2#qubit0 X波频率
    f1 = (E[l11111]-E[l10111]+E[l01111]-E[l00111])/2#qubit1 X波频率
    f2 = (E[l11111]-E[l11011]+E[l01111]-E[l01011])/2#qubit2 X波频率
    f3 = (E[l11111]-E[l11101]+E[l01111]-E[l01101])/2#qubit3 X波频率
    f4 = (E[l11111]-E[l11110]+E[l01111]-E[l01110])/2#qubit4 X波频率
    
    
    f = np.array([f0,f1,f2,f3,f4])


    wc1 = 'omega/2*((erf((t-8)/ramp)-erf((t-tp+8)/ramp))*(np.cos(ft*t))+D*(2*np.exp(-(t-8)**2/ramp**2)/np.sqrt(np.pi)/ramp-2*np.exp(-(t-tp+8)**2/ramp**2)/np.sqrt(np.pi)/ramp)/'+str(eta_q[controlq])+'*(np.cos(ft*t-np.pi/2)))*(0<t<=tp)'
    
    wc2 = '(0.03332*2*np.pi*(np.exp(-(t-30-tp)**2/2.0/6**2)*np.cos(t*fc)+(t-30-tp)/2/6**2/'+str(eta_q[controlq])+'*np.exp(-(t-30-tp)**2/2.0/6**2)*np.cos(t*fc-np.pi/2)))*((10+tp)<t<=50+tp)'

    wc3 = 'omega/2*((erf((t-tp-60-8)/ramp)-erf((t-tp-60-tp+8)/ramp))*(np.cos(ft*t+np.pi))+D*(2*np.exp(-(t-tp-60-8)**2/ramp**2)/np.sqrt(np.pi)/ramp-2*np.exp(-(t-tp-60-tp+8)**2/ramp**2)/np.sqrt(np.pi)/ramp)/'+str(eta_q[controlq])+'*(np.cos(ft*t+np.pi-np.pi/2)))*(tp+60<t<=2*tp+60)'

    wc4 = '(0.03332*2*np.pi*(np.exp(-(t-90-2*tp)**2/2.0/6**2)*np.cos(t*fc)+(t-90-2*tp)/2/6**2/'+str(eta_q[controlq])+'*np.exp(-(t-90-2*tp)**2/2.0/6**2)*np.cos(t*fc-np.pi/2)))*((2*tp+70)<t<=2*tp+110)'
    
    index = np.arange(5)
    con = np.array([controlq,targetq])
    conlocation = np.array([i for i in range(len(index)) if index[i] in con])
    spectator = np.delete(index,conlocation)

    ws02 = '(0.03332*2*np.pi*(np.exp(-(t-tp/2)**2/2.0/6**2)*np.cos(t*fs0)+(t-tp/2)/2/6**2/'+str(eta_q[spectator[0]])+'*np.exp(-(t-tp/2)**2/2.0/6**2)*np.cos(t*fs0-np.pi/2)))*((0)<t<=tp)'

    ws04 = '(0.03332*2*np.pi*(np.exp(-(t-60-3*tp/2)**2/2.0/6**2)*np.cos(t*fs0)+(t-60-3*tp/2)/2/6**2/'+str(eta_q[spectator[0]])+'*np.exp(-(t-60-3*tp/2)**2/2.0/6**2)*np.cos(t*fs0-np.pi/2)))*(tp+60<t<=2*tp+60)'
         
    
    ws12 = '(0.03332*2*np.pi*(np.exp(-(t-tp/2)**2/2.0/6**2)*np.cos(t*fs1)+(t-tp/2)/2/6**2/'+str(eta_q[spectator[1]])+'*np.exp(-(t-tp/2)**2/2.0/6**2)*np.cos(t*fs1-np.pi/2)))*((0)<t<=tp)'

    ws14 = '(0.03332*2*np.pi*(np.exp(-(t-60-3*tp/2)**2/2.0/6**2)*np.cos(t*fs1)+(t-60-3*tp/2)/2/6**2/'+str(eta_q[spectator[1]])+'*np.exp(-(t-60-3*tp/2)**2/2.0/6**2)*np.cos(t*fs1-np.pi/2)))*(tp+60<t<=2*tp+60)'

    ws22 = '(0.03332*2*np.pi*(np.exp(-(t-tp/2)**2/2.0/6**2)*np.cos(t*fs2)+(t-tp/2)/2/6**2/'+str(eta_q[spectator[2]])+'*np.exp(-(t-tp/2)**2/2.0/6**2)*np.cos(t*fs2-np.pi/2)))*((0)<t<=tp)'

    ws24 = '(0.03332*2*np.pi*(np.exp(-(t-60-3*tp/2)**2/2.0/6**2)*np.cos(t*fs2)+(t-60-3*tp/2)/2/6**2/'+str(eta_q[spectator[2]])+'*np.exp(-(t-60-3*tp/2)**2/2.0/6**2)*np.cos(t*fs2-np.pi/2)))*(tp+60<t<=2*tp+60)'
    

    args = {'omega':omega,'tp':tp , 'ramp': 5 , 'fc':f[controlq] , 'ft':f[targetq], 'fs0':f[spectator[0]] , 'fs1':f[spectator[1]],'fs2':f[spectator[2]] , 'D':-0.5}

    
    H1 = [sm[controlq]+sm[controlq].dag(),wc1]
    H2 = [sm[controlq]+sm[controlq].dag(),wc2]
    H3 = [sm[controlq]+sm[controlq].dag(),wc3]
    H4 = [sm[controlq]+sm[controlq].dag(),wc4]
    H5 = [sm[spectator[0]]+sm[spectator[0]].dag(),ws02]
    H6 = [sm[spectator[0]]+sm[spectator[0]].dag(),ws04]
    H7 = [sm[spectator[1]]+sm[spectator[1]].dag(),ws12]
    H8 = [sm[spectator[1]]+sm[spectator[1]].dag(),ws14]
    H9 = [sm[spectator[2]]+sm[spectator[2]].dag(),ws22]
    H10 = [sm[spectator[2]]+sm[spectator[2]].dag(),ws24]
    
    H = [H0,H1,H2,H3,H4,H5,H6,H7,H8,H9,H10]


    tlist = np.arange(0,2*tp+110,0.3)

    
    options=Options()
    options.atol=1e-8
    options.rtol=1e-6
    options.first_step=0.01
    options.num_cpus=8
    options.nsteps=1e6
    options.gui='True'
    options.ntraj=1000
    options.rhs_reuse=True

    

    
    if controlq == 0:

        Phi = []
        Phi.append([tensor(basis(3,0),basis(3,0)),(tensor(basis(3,0),basis(3,0))+1j*tensor(basis(3,0),basis(3,1))).unit()])
        Phi.append([tensor(basis(3,0),basis(3,1)),(tensor(basis(3,0),basis(3,1))+1j*tensor(basis(3,0),basis(3,0))).unit()])
        Phi.append([tensor(basis(3,1),basis(3,0)),(tensor(basis(3,1),basis(3,0))-1j*tensor(basis(3,1),basis(3,1))).unit()])
        Phi.append([tensor(basis(3,1),basis(3,1)),(tensor(basis(3,1),basis(3,1))-1j*tensor(basis(3,1),basis(3,0))).unit()])
    else:
        Phi = []
        Phi.append([tensor(basis(3,0),basis(3,0)),(tensor(basis(3,0),basis(3,0))+1j*tensor(basis(3,1),basis(3,0))).unit()])
        Phi.append([tensor(basis(3,0),basis(3,1)),(tensor(basis(3,0),basis(3,1))-1j*tensor(basis(3,1),basis(3,1))).unit()])
        Phi.append([tensor(basis(3,1),basis(3,0)),(tensor(basis(3,1),basis(3,0))+1j*tensor(basis(3,0),basis(3,0))).unit()])
        Phi.append([tensor(basis(3,1),basis(3,1)),(tensor(basis(3,1),basis(3,1))-1j*tensor(basis(3,0),basis(3,1))).unit()])
    T = []
    for i in range(2):
        for j in range(2):
            for k in range(2):
                for l in range(2):
                    for q in range(2):
                        m = i*2+j
                        T.append([tensor(Phi[m][0],basis(3,k),basis(3,l),basis(3,q)),tensor(Phi[m][1],basis(3,k),basis(3,l),basis(3,q))])
                    

    fid = []
    leakage = []
    
    

    p = Pool(34)
    
    A = p.map(getfid,T)
    fid = [x[0] for x in A]
    leakage = [x[1] for x in A]
    outputstate = [x[2] for x in A]
    fid = np.array(fid)
    leakage = np.array(leakage)

        
    p.close()
    p.join()
    gc.collect()

    labels = []
    for i in range(2**5):
        index = i
        code = ''  #code of state
        for j in range(5):
            code = str(np.int(np.mod(index,2))) + code
            
            index = np.floor(index/2)

        labels.append(code)

    loc = []#各个基矢在多比特3能级系统中，能级的位置
    for c in labels:
        l = 0
        for index , i in enumerate(c):
            l+=eval(i)*3**(NumQ-1-index)
        loc.append(int(l))

        
    process = np.column_stack([outputstate[i].data.toarray() for i in range(len(outputstate))])[loc,:]
    angle = np.angle(process[0][0])
    process = process*np.exp(-1j*angle)#global phase
    
    if controlq == 0:
        targetprocess = 1/np.sqrt(2)*np.array([[1,1j,0,0],[1j,1,0,0],[0,0,1,-1j],[0,0,-1j,1]])
    else:
        targetprocess = 1/np.sqrt(2)*np.array([[1,0,1j,0],[0,1,0,-1j],[1j,0,1,0],[0,-1j,0,1]])
    
    targetprocess = tensor(Qobj(targetprocess),qeye(2),qeye(2),qeye(2))
    targetprocess = targetprocess.data.toarray()
    Ufidelity = np.abs(np.trace(np.dot(np.conjugate(np.transpose(targetprocess)),process)))/32

    

    gc.collect()

    
    
    
#    Operator_View(process,'U_Simulation')
#    Operator_View(targetprocess,'U_Ideal')
#    Operator_View(np.dot(np.conjugate(np.transpose(targetprocess)),process),'U_error')


#    fid,leakage,outputstate = getfid([(T[0][0]).unit() , (T[0][1]).unit()])
#    print(P,np.mean(leakage),np.mean(fid))
    ZZ = E[l11111]-E[l01111]-E[l10000]+E[l00000]
    Ngate = np.pi/4/ZZ/(2*tp+60)

    print(P[0],P[1]/2/np.pi,g/2/np.pi,np.mean(fid),Ufidelity,Ngate)
    

    return(outputstate,process,targetprocess)
#    return(process,T)




if __name__=='__main__':
    
    starttime=time.time()
    N = 3
    NumQ = 5
    sm, E_uc, E_e, E_g, Sn, Sx, Sy = GetOperator(NumQ)

    g = 0.0006804*2*np.pi
    delta0 = 0.15056;delta1 = 0.170

    wq= np.array([5.000 , 5.0+delta0 , 5.0-delta1 , 5.0-delta0 , 5.0+delta1 ]) * 2 * np.pi
    eta_q=  np.array([-0.250 , -0.250 , -0.250 , -0.250,-0.250]) * 2 * np.pi

    controlq = 1
    targetq = 0

    H0 = 0
    HCoupling=0
    for II in range(1,NumQ):
        HCoupling+= g* (sm[II].dag()  + sm[II])* (sm[0].dag()  + sm[0]) 
    H0=HCoupling
    for II in range(0,NumQ):
        H0+= eta_q[II]*E_uc[II]+wq[II]*Sn[II]
    [E,S] = H0.eigenstates()

    l11111 = findstate(S,'11111');l01111 = findstate(S,'01111');
    l10111 = findstate(S,'10111');l00111 = findstate(S,'00111');
    l11011 = findstate(S,'11011');l01011 = findstate(S,'01011');
    l11101 = findstate(S,'11101');l01101 = findstate(S,'01101');
    l11110 = findstate(S,'11110');l01110 = findstate(S,'01110');

    l10000 = findstate(S,'10000');l00000 = findstate(S,'00000');

    fid = CNOT([163.98,0.08965*2*np.pi])
    
    
    
    
    
    
    
    
    
    
    
    finishtime=time.time()
    print( 'Time used: ', (finishtime-starttime), 's')