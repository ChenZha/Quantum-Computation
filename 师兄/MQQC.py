#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Feb 16 04:04:14 2017

@author: qubits0
"""

#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Feb  7 22:29:10 2017

@author: qubits0
"""

#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Feb  7 21:14:06 2017

@author: qubits0
"""

# -*- coding: utf-8 -*-
"""
Created on Tue Nov 01 14:56:12 2016

@author: Logmay
"""

import time 
import csv
import matplotlib.pyplot as plt
import numpy as np
from pylab import *
from qutip import *
from scipy.optimize import *
from mpl_toolkits.mplot3d import Axes3D
from scipy import interpolate 
from scipy.special import *
from multiprocessing import Pool
from decimal import *
from math import *
import gc 
import sys
import os
import random

def CreateBasicOperator(APRType=0):
    print('APRType:'+str(APRType))
    if APRType==0:
        cmdstr=''
        for II in range(0,Num_Q):
            cmdstr+='qeye(3),'
        a= eval('tensor(destroy(N),'+cmdstr+')')
    
        sm=[]
        for II in range(0,Num_Q):
            cmdstr=''
            for JJ in range(0,Num_Q):
                if II==JJ:
                    cmdstr+='destroy(3),'
                else:
                    cmdstr+='qeye(3),'
            sm.append(eval('tensor(qeye(N),'+cmdstr+')'))
    
        smm=[]
        for II in range(0,Num_Q):
            cmdstr=''
            for JJ in range(0,Num_Q):
                if II==JJ:
                    cmdstr+='basis(3,2)*basis(3,2).dag(),'
                else:
                    cmdstr+='qeye(3),'
            smm.append(eval('tensor(qeye(N),'+cmdstr+')'))
        
        E_e=[]
        for II in range(0,Num_Q):
            cmdstr=''
            for JJ in range(0,Num_Q):
                if II==JJ:
                    cmdstr+='basis(3,1)*basis(3,1).dag(),'
                else:
                    cmdstr+='qeye(3),'
            E_e.append(eval('tensor(qeye(N),'+cmdstr+')'))
        
        E_g=[]
        for II in range(0,Num_Q):
            cmdstr=''
            for JJ in range(0,Num_Q):
                if II==JJ:
                    cmdstr+='basis(3,0)*basis(3,0).dag(),'
                else:
                    cmdstr+='qeye(3),'
            E_g.append(eval('tensor(qeye(N),'+cmdstr+')'))
        
    elif APRType==1:
        cmdstr=''
        for II in range(0,Num_Q):
            cmdstr+='qeye(3),'
        a= eval('tensor('+cmdstr+')')
    
        sm=[]
        for II in range(0,Num_Q):
            cmdstr=''
            for JJ in range(0,Num_Q):
                if II==JJ:
                    cmdstr+='destroy(3),'
                else:
                    cmdstr+='qeye(3),'
            sm.append(eval('tensor('+cmdstr+')'))
    
        smm=[]
        for II in range(0,Num_Q):
            cmdstr=''
            for JJ in range(0,Num_Q):
                if II==JJ:
                    cmdstr+='basis(3,2)*basis(3,2).dag(),'
                else:
                    cmdstr+='qeye(3),'
            smm.append(eval('tensor('+cmdstr+')'))
        
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
        
    elif APRType==2:
        cmdstr=''
        for II in range(0,Num_Q):
            cmdstr+='qeye(2),'
        a= eval('tensor(destroy(N),'+cmdstr+')')
    
        sm=[]
        for II in range(0,Num_Q):
            cmdstr=''
            for JJ in range(0,Num_Q):
                if II==JJ:
                    cmdstr+='destroy(2),'
                else:
                    cmdstr+='qeye(2),'
            sm.append(eval('tensor(qeye(N),'+cmdstr+')'))
        
        smm=[]
        
        E_e=[]
        for II in range(0,Num_Q):
            E_e.append(sm[II].dag()*sm[II])
        E_g=[]
        for II in range(0,Num_Q):
            E_g.append(sm[II]*sm[II].dag())
    
    elif APRType==3:
        cmdstr=''
        for II in range(0,Num_Q):
            cmdstr+='qeye(2),'
        a= eval('tensor('+cmdstr+')')
    
        sm=[]
        for II in range(0,Num_Q):
            cmdstr=''
            for JJ in range(0,Num_Q):
                if II==JJ:
                    cmdstr+='destroy(2),'
                else:
                    cmdstr+='qeye(2),'
            sm.append(eval('tensor('+cmdstr+')'))
        
        smm=[]
        
        E_e=[]
        for II in range(0,Num_Q):
            E_e.append(sm[II].dag()*sm[II])
        E_g=[]
        for II in range(0,Num_Q):
            E_g.append(sm[II]*sm[II].dag())
            
    elif APRType==4:
        cmdstr=''
        a = []
        sm=[]
        for II in range(0,Num_Q):
            cmdstr=''
            for JJ in range(0,Num_Q):
                if II==JJ:
                    cmdstr+='destroy(3),'
                else:
                    cmdstr+='qeye(3),'
            sm.append(eval('tensor('+cmdstr+')'))
    
        smm=[]
        for II in range(0,Num_Q):
            cmdstr=''
            for JJ in range(0,Num_Q):
                if II==JJ:
                    cmdstr+='basis(3,2)*basis(3,2).dag(),'
                else:
                    cmdstr+='qeye(3),'
            smm.append(eval('tensor('+cmdstr+')'))
        
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
    elif APRType==5:
        cmdstr=''
        a = []
        sm=[]
        for II in range(0,Num_Q):
            cmdstr=''
            for JJ in range(0,Num_Q):
                if II==JJ:
                    cmdstr+='destroy(2),'
                else:
                    cmdstr+='qeye(2),'
            sm.append(eval('tensor('+cmdstr+')'))
        
        smm=[]
        
        E_e=[]
        for II in range(0,Num_Q):
            E_e.append(sm[II].dag()*sm[II])
        E_g=[]
        for II in range(0,Num_Q):
            E_g.append(sm[II]*sm[II].dag())
            
        
    
    Sz=[]
    Sx=[]
    Sy=[]
    for II in range(0,Num_Q):
        Sz.append(sm[II].dag()*sm[II])
        Sx.append(sm[II].dag()+sm[II])
        Sy.append(1j*(sm[II].dag()-sm[II]))   
        
    return a, sm, smm, E_e, E_g, Sz, Sx, Sy

def GenerateDissipation(Dis=False):
    c_op_list = []
    
    if Dis==True:
        for II in range(0,Num_Q):
            c_op_list.append(np.sqrt(gamma[II] * (1+n_th)) * sm[II])
            c_op_list.append(np.sqrt(gamma[II] * n_th) * sm[II].dag())
            c_op_list.append(np.sqrt(gamma_phi[II]) * sm[II].dag()*sm[II])
            
    return c_op_list

def Gate_rx(inxc,t0,t1,index,phi=np.pi,omega=0.03332):
    if TG:
        omega=fx
    args_i={}
    w_t_i='0*('+str(t0)+'<t<='+str(t1)+')'
#    args_i['w_t'+str(inxc)+'_'+str(index)]=0
    if DRAG:
        D_t_i='(Omega'+str(inxc)+'_'+str(index)+'*(np.exp(-(t-20-'+str(t0)+')**2/2.0/width'+str(inxc)+'_'+str(index)+'**2)*np.cos(t*f'+str(inxc)+'_'+str(index)+')-(t-20-'+str(t0)+')/2/width'+str(inxc)+'_'+str(index)+'**2/'+str(w_qa[inxc])+'*np.exp(-(t-20-'+str(t0)+')**2/2.0/width'+str(inxc)+'_'+str(index)+'**2)*np.cos(t*f'+str(inxc)+'_'+str(index)+'-np.pi/2)))*('+str(t0)+'<t<='+str(min(t1,t0+40))+')'
    else:
        D_t_i='(Omega'+str(inxc)+'_'+str(index)+'*np.exp(-(t-20-'+str(t0)+')**2/2.0/width'+str(inxc)+'_'+str(index)+'**2)*np.cos(t*f'+str(inxc)+'_'+str(index)+'))*('+str(t0)+'<t<='+str(min(t1,t0+40))+')'
    args_i['f'+str(inxc)+'_'+str(index)]=E_q[inxc]
    args_i['Omega'+str(inxc)+'_'+str(index)]=omega*2*phi
    args_i['width'+str(inxc)+'_'+str(index)]=6
    return w_t_i,D_t_i,args_i     
         
def Gate_ry(inxc,t0,t1,index,phi=np.pi,omega=0.03332):
    if TG:
        omega=fx
    args_i={}
    w_t_i='0*('+str(t0)+'<t<='+str(t1)+')'
#    args_i['w_t'+str(inxc)+'_'+str(index)]=0
    if DRAG:
        D_t_i='(Omega'+str(inxc)+'_'+str(index)+'*(np.exp(-(t-20-'+str(t0)+')**2/2.0/width'+str(inxc)+'_'+str(index)+'**2)*np.cos(t*f'+str(inxc)+'_'+str(index)+'-np.pi/2)+(t-20-'+str(t0)+')/2/width'+str(inxc)+'_'+str(index)+'**2/'+str(w_qa[inxc])+'*np.exp(-(t-20-'+str(t0)+')**2/2.0/width'+str(inxc)+'_'+str(index)+'**2)*np.cos(t*f'+str(inxc)+'_'+str(index)+')))*('+str(t0)+'<t<='+str(min(t1,t0+40))+')'
    else:
        D_t_i='(Omega'+str(inxc)+'_'+str(index)+'*np.exp(-(t-20-'+str(t0)+')**2/2.0/width'+str(inxc)+'_'+str(index)+'**2)*np.cos(t*f'+str(inxc)+'_'+str(index)+'-np.pi/2))*('+str(t0)+'<t<='+str(min(t1,t0+40))+')'
    args_i['f'+str(inxc)+'_'+str(index)]=E_q[inxc]
    args_i['Omega'+str(inxc)+'_'+str(index)]=omega*2*phi
    args_i['width'+str(inxc)+'_'+str(index)]=6 
    return w_t_i,D_t_i,args_i

def Gate_H(inxc,t0,t1,index):
    w_t_i1,D_t_i1,args_i1=Gate_ry(inxc,t0,t0+40,index+100000,phi=np.pi/2)
    w_t_i2,D_t_i2,args_i2=Gate_rx(inxc,t0+40,t1,index+110000,phi=np.pi)
    args_i=dict(args_i1,**args_i2)
    w_t_i=w_t_i1+'+'+w_t_i2
    D_t_i=D_t_i1+'+'+D_t_i2
    return w_t_i,D_t_i,args_i


#==============================================================================
# def Gate_rz(inxc,t0,t1,index,phi=np.pi):
#     args_i={}
#     w_t_i='(w_t'+str(inxc)+'_'+str(index)+'+delta'+str(inxc)+'_'+str(index)+'/(1 + np.exp(-(t-'+str(t0)+'-t'+str(inxc)+'_'+str(index)+'0)/width'+str(inxc)+'_'+str(index)+')) -delta'+str(inxc)+'_'+str(index)+'/(1 + np.exp(-(t-'+str(t0)+'-t'+str(inxc)+'_'+str(index)+'1)/width'+str(inxc)+'_'+str(index)+')))*('+str(t0)+'<t<='+str(t1)+')'
#     args_i['w_t'+str(inxc)+'_'+str(index)]=w_q[inxc]
#     args_i['width'+str(inxc)+'_'+str(index)]=0.5
#     args_i['t'+str(inxc)+'_'+str(index)+'0']=2
#     args_i['t'+str(inxc)+'_'+str(index)+'1']=38
#     args_i['delta'+str(inxc)+'_'+str(index)]=0.0293*phi
#     D_t_i='0*('+str(t0)+'<t<='+str(t1)+')'
#     return w_t_i,D_t_i,args_i
#==============================================================================

def Gate_rz(inxc,t0,t1,index,phi=np.pi,delta=0.069066):
#    if TG:
#        delta=fx
    args_i={}
    w_t_i='(delta'+str(inxc)+'_'+str(index)+'*np.exp(-(t-20-'+str(t0)+')**2/2.0/width'+str(inxc)+'_'+str(index)+'**2))*('+str(t0)+'<t<='+str(t1)+')'
#    args_i['w_t'+str(inxc)+'_'+str(index)]=w_q[inxc]
    args_i['width'+str(inxc)+'_'+str(index)]=6
    args_i['delta'+str(inxc)+'_'+str(index)]=delta*phi
    D_t_i='0*('+str(t0)+'<t<='+str(t1)+')'
    return w_t_i,D_t_i,args_i

def Gate_iSWAP(inxc,inxt,t0,t1,index,phi=np.pi,deltat=500):
    if TG:
        deltat=fx
    args_i={}
    w_t_i='(delta'+str(inxc)+'_'+str(index)+'/(1 + np.exp(-(t-'+str(t0)+'-t'+str(inxc)+'_'+str(index)+'0)/width'+str(inxc)+'_'+str(index)+')) -delta'+str(inxc)+'_'+str(index)+'/(1 + np.exp(-(t-'+str(t0)+'-t'+str(inxc)+'_'+str(index)+'1)/width'+str(inxc)+'_'+str(index)+')))*('+str(t0)+'<t<='+str(t1)+')'
#    args_i['w_t'+str(inxc)+'_'+str(index)]=w_q[inxc]
    args_i['width'+str(inxc)+'_'+str(index)]=0.5
    args_i['t'+str(inxc)+'_'+str(index)+'0']=2
    args_i['t'+str(inxc)+'_'+str(index)+'1']=deltat
    args_i['delta'+str(inxc)+'_'+str(index)]=E_q[inxt]-E_q[inxc]
    D_t_i='0*('+str(t0)+'<t<='+str(t1)+')'
    return w_t_i,D_t_i,args_i

#def Gate_CZ_pre(inxc,inxt,t0,t1,index,phi=np.pi,deltat=750.90909):
##    if TG:
##        deltat=fx[0]
#    
#    args_i={}
#    w_t_i='(delta'+str(inxc)+'_'+str(index)+'/(1 + np.exp(-(t-'+str(t0)+'-t'+str(inxc)+'_'+str(index)+'_0)/width'+str(inxc)+'_'+str(index)+')) -delta'+str(inxc)+'_'+str(index)+'/(1 + np.exp(-(t-'+str(t0)+'-t'+str(inxc)+'_'+str(index)+'_1)/width'+str(inxc)+'_'+str(index)+')))*('+str(t0)+'<t<='+str(t1)+')'
#    args_i['width'+str(inxc)+'_'+str(index)]=10
#    args_i['t'+str(inxc)+'_'+str(index)+'_0']=50
#    args_i['t'+str(inxc)+'_'+str(index)+'_1']=deltat
#    args_i['delta'+str(inxc)+'_'+str(index)]=(w_q[inxt]-w_q[inxc]-w_qa[inxt])
#    D_t_i='0*('+str(t0)+'<t<='+str(t1)+')'
#
#    return w_t_i,D_t_i,args_i

#def Gate_CZ_pre(inxc,inxt,t0,t1,index,tp = 38.0,ramp=8.08,Am = 0):
#    args_i={}
#    w_t_i='delta'+str(inxc)+'_'+str(index)+'/2*(erf((t-'+str(t0)+'-t'+str(inxc)+'_'+str(index)+'ramp/2)/np.sqrt(2)/sigma'+str(inxc)+'_'+str(index)+')-erf((t-'+str(t0)+'-t'+str(inxc)+'_'+str(index)+'gate+t'+str(inxc)+'_'+str(index)+'ramp/2)/np.sqrt(2)/sigma'+str(inxc)+'_'+str(index)+'))*('+str(t0)+'<t<='+str(t1)+')'
#    args_i['t'+str(inxc)+'_'+str(index)+'ramp']=ramp
#    args_i['sigma'+str(inxc)+'_'+str(index)]=ramp/4/np.sqrt(2)
#    args_i['t'+str(inxc)+'_'+str(index)+'gate']=tp-t0  
#    if RE:
#        Am = Am
#    else:
#        Am = (E_q[inxt]-E_q[inxc]-w_qa[inxt])
#    args_i['delta'+str(inxc)+'_'+str(index)]=Am
#    D_t_i='0*('+str(t0)+'<t<='+str(t1)+')'
#    return w_t_i,D_t_i,args_i
#
#def Gate_CZ(inxc,inxt,t0,t1,index,tp = 38.0,ramp=8.08,phi = np.pi,Am = 0):
#    if TG:
#        tp = fx[0]
#        ramp = fx[1]
#        phi = fx[2]
#
#    w_t_i1,D_t_i1,args_i1=Gate_CZ_pre(inxc,inxt,t0,t0+tp,index+100000,tp,ramp,Am)
#    w_t_i2,D_t_i2,args_i2=Gate_rz(inxc,t0+tp,t0+tp+40,index+110000,phi,delta=0.069066)
#    args_i=dict(args_i1,**args_i2)
#    w_t_i=w_t_i1+'+'+w_t_i2
#    D_t_i=D_t_i1+'+'+D_t_i2
#
#    return w_t_i,D_t_i,args_i

def Gate_CZ_pre(inxc,inxt,t0,t1,index,tp=50,Am = -0.19):
    if TG:
        tp=fx[0]
        Am = fx[1]
        
    
    args_i={}
    
#    w_t_i = '(np.cos(t))*('+str(t0)+'<t<='+str(t1)+')'
    w_t_i = '(np.interp( t , np.linspace('+str(t0)+','+str(t0)+'+tp'+str(inxc)+'_'+str(index)+',1024) , delta'+str(inxc)+'_'+str(index)+'*th))*('+str(t0)+'<t<='+str(t1)+')'
               
    args_i['tp'+str(inxc)+'_'+str(index)]=tp 
    args_i['th']=th 
#    args_i['w'+str(inxc)+'_'+str(index)]= interpolate.interp1d(np.linspace(t0,t0+tp,1024) , delta*th,'slinear')
           
    args_i['delta'+str(inxc)+'_'+str(index)]=Am
#    print(args_i)
#    print(w_t_i)
#    print(tp,t1)
    D_t_i='0*('+str(t0)+'<t<='+str(t1)+')'

    return w_t_i,D_t_i,args_i

def Gate_CZ(inxc,inxt,t0,t1,index,tp=50,Am = -0.16,phi=-1.71848):
    if TG:
        tp=fx[0]
        Am = fx[1]
        phi = fx[2]
        
#    print(fx)
#    print(deltat,phi)
    w_t_i1,D_t_i1,args_i1=Gate_CZ_pre(inxc,inxt,t0,t0+tp,index+100000,tp,Am)
    w_t_i2,D_t_i2,args_i2=Gate_rz(inxc,t0+tp,t1,index+110000,phi,delta=0.069066)
    args_i=dict(args_i1,**args_i2)
    w_t_i=w_t_i1+'+'+w_t_i2
    D_t_i=D_t_i1+'+'+D_t_i2
#    print(args_i)
    return w_t_i,D_t_i,args_i


def Gate_i(inxc,t0,t1,index):
    args_i={}
    w_t_i='0*('+str(t0)+'<t<='+str(t1)+')'
#    args_i['w_t'+str(inxc)+'_'+str(index)]=0
    D_t_i='0*('+str(t0)+'<t<='+str(t1)+')'
    return w_t_i,D_t_i,args_i

def GetLen(Operator):
    lenc=len(Operator)
    LenSingleOperator=0
    for inxc in range(0,lenc):
        if Operator[inxc][0]=='X':
            LenSingleOperator=np.max([LenSingleOperator,40])
        elif Operator[inxc][0]=='Y':
            LenSingleOperator=np.max([LenSingleOperator,40])
        elif Operator[inxc][0]=='Z':
            LenSingleOperator=np.max([LenSingleOperator,40])
        elif Operator[inxc][0]=='H':
            LenSingleOperator=np.max([LenSingleOperator,80])    
        elif Operator[inxc][0]=='i':
            LenSingleOperator=np.max([LenSingleOperator,500])
        elif Operator[inxc][0]=='C':
            if Operator[inxc][1]=='Z':
                if TG==1:
                    LenSingleOperator=np.max([LenSingleOperator,fx[0]+40])
                else:
                    if len(Operator[inxc])==3:
                        LenSingleOperator=np.max([LenSingleOperator,78.0])
                    else:
                        loc1 = Operator[inxc].find('_')
                        loc2 = Operator[inxc].find('=')
                        LenSingleOperator=np.max([LenSingleOperator,float(Operator[inxc][loc1+1:loc2])+40])
            elif Operator[inxc][1]=='P':
                loc1 = Operator[inxc].find('_')
                loc2 = Operator[inxc].find('-')
                LenSingleOperator=np.max([LenSingleOperator,float(Operator[inxc][loc1+1:loc2])])
 
        elif Operator[inxc][0]=='I':
            if len(Operator[inxc])==1:
                LenSingleOperator=np.max([LenSingleOperator,0])
            else:
                LenSingleOperator=np.max([LenSingleOperator,int(Operator[inxc][1:])])      
    return LenSingleOperator

def GenerateH(Operators, APRType=0):
    global E_q
    global H0
    
    if APRType==0 or APRType==2:
        HCoupling=0
        for II in range(0,Num_Q):
            HCoupling+= g[II] * (a * sm[II].dag() + a.dag() * sm[II]) 
#            HCoupling+= g[II] * (a + a.dag())* (sm[II].dag()  + sm[II]) 
        Hc=w_c * a.dag() * a 
        H=HCoupling+Hc
    elif APRType==1 or APRType==3:
        HCoupling=0
        for II in range(0,Num_Q):
            for JJ in range(II,Num_Q):
                if II != JJ:
                    HCoupling+= 0.5*abs(g[II]*g[JJ]/(w_q[II]-w_c)/(w_q[JJ]-w_c)*(w_q[II]-w_c+w_q[JJ]-w_c)) * (sm[II].dag() * sm[JJ]+sm[JJ].dag() * sm[II])                    
        H=HCoupling
    elif APRType==4 or APRType==5:
        HCoupling=0
        for II in range(0,Num_Q-1):
            HCoupling+= g[II]* (sm[II].dag()  + sm[II])* (sm[II+1].dag()  + sm[II+1]) 
        H=HCoupling
        
    
    if APRType==0 or APRType==1 or APRType==4:    
        for II in range(0,Num_Q):
            H+=-w_qa[II]*smm[II].dag()*smm[II]
    
    for II in range(0,Num_Q):
        H+=(Sz[II])*w_q[II]
        
    
    w_f = [w_q[k] for k in range(Num_Q)]
    
    if APRType==0 or APRType==2:
        w_f.append(w_c)
        
        H0 = H
        En= (H0.eigenenergies())
    
        E_n = En.tolist()
    
        E_index=sorted(range(Num_Q+1), key=lambda k: w_f[k])
        
        cloc = np.where(np.array(E_index) == Num_Q)[0][0]
        E_n.pop(cloc+1)
        E_index.pop(cloc)
    else:
        H0 = H
        En= (H0.eigenenergies())
    
        E_n = En.tolist()
    
        E_index=sorted(range(Num_Q), key=lambda k: w_f[k])

    
    E_q = np.zeros(Num_Q)
    for idx , II in enumerate(E_index):
        E_q[II] = E_n[idx+1]-E_n[0]
        
#    print(E_q/2/np.pi)

    H=[H]
    
    t0=0
    args={}
    for JJ in range(0,len(Operators)):
        Operator=Operators[JJ]           
        lenc=Num_Q
        
        LenSingleOperator=GetLen(Operator)
        t1=t0+LenSingleOperator
        
        w_t=[]
        D_t=[]
        
        for inxc in range(0,lenc):
            if Operator[inxc][0]=='X':
                if len(Operator[inxc])==1:
                    w_t_i,D_t_i,args_i=Gate_rx(inxc,t0,t1,JJ)
                else:
                    w_t_i,D_t_i,args_i=Gate_rx(inxc,t0,t1,JJ,phi=np.pi*float(Operator[inxc][1:]))
            elif Operator[inxc][0]=='Y':
                if len(Operator[inxc])==1:
                    w_t_i,D_t_i,args_i=Gate_ry(inxc,t0,t1,JJ)
                else:
                    w_t_i,D_t_i,args_i=Gate_ry(inxc,t0,t1,JJ,phi=np.pi*float(Operator[inxc][1:]))
            elif Operator[inxc][0]=='Z':
                if len(Operator[inxc])==1:
                    w_t_i,D_t_i,args_i=Gate_rz(inxc,t0,t1,JJ)
                else:
                    w_t_i,D_t_i,args_i=Gate_rz(inxc,t0,t1,JJ,phi=np.pi*float(Operator[inxc][1:]))
            elif Operator[inxc][0]=='H':
                w_t_i,D_t_i,args_i=Gate_H(inxc,t0,t1,JJ)
            elif Operator[inxc][0]=='i':
                w_t_i,D_t_i,args_i=Gate_iSWAP(inxc,int(Operator[inxc][5:]),t0,t1,JJ)
            elif Operator[inxc][0]=='C':
                if Operator[inxc][1]=='Z':
                    if len(Operator[inxc])==3:
                        w_t_i,D_t_i,args_i=Gate_CZ(inxc,int(Operator[inxc][2:]),t0,t1,JJ)
                    else:
                        loc1 = Operator[inxc].find('_')
                        loc2 = Operator[inxc].find('=')
                        loc3 = Operator[inxc].find('+')##CZt_tp=Am+Phi
                        w_t_i,D_t_i,args_i=Gate_CZ(inxc,int(Operator[inxc][2:loc1]),t0,t1,JJ,tp = float(Operator[inxc][loc1+1:loc2]),Am = float(Operator[inxc][loc2+1:loc3]) , phi = float(Operator[inxc][loc3+1:]))
                elif Operator[inxc][1]=='P':
                    if len(Operator[inxc])==3:
                        w_t_i,D_t_i,args_i=Gate_CZ_pre(inxc,int(Operator[inxc][2:]),t0,t1,JJ)
                    else:
                        loc1 = Operator[inxc].find('_')
                        loc2 = Operator[inxc].find('-')
                        w_t_i,D_t_i,args_i=Gate_CZ_pre(inxc,int(Operator[inxc][2:loc1]),t0,t1,JJ,tp = float(Operator[inxc][loc1+1:loc2]),Am = float(Operator[inxc][loc2+1:]))
            elif Operator[inxc][0]=='I':
                w_t_i,D_t_i,args_i=Gate_i(inxc,t0,t1,JJ)
            w_t.append(w_t_i)
            D_t.append(D_t_i)
            args=dict(args,**args_i)
        
        W=[]
        D=[]
        for II in range(0,Num_Q):
            W.append([Sz[II],w_t[II]])   
            D.append([Sx[II],D_t[II]])
            H.append(W[II])
            H.append(D[II])
            
        t0=t1
        
#        print(H)
#    print(len(args))
    return H,args,t1,E_q

def getExpValue(states,tlist,E_q):
    
    expect_z=[]
    for ii in range(0,Num_Q):
        n_z = np.real(expect(1-Sz[ii]*2,states))
        n_z=n_z.tolist()
        expect_z.append(n_z)
        
    U=[]
    for ii in range(0,Num_Q):
        for t in range(0,len(tlist)):
            U.append((np.exp(1j*(E_q[ii])*tlist[t])*E_e[ii]+E_g[ii]).dag())
    
    expect_x=[]
    for ii in range(0,Num_Q):
        n_x=[]
        for t in range(0,len(tlist)):
            Ui=U[(ii)*len(tlist)+t]
            op=Ui*Sx[ii]*Ui.dag()
            n_x.append(expect(op,states[t]))
        expect_x.append(n_x)
            
    expect_y=[]
    for ii in range(0,Num_Q):
        n_y=[]
        for t in range(0,len(tlist)):
            Ui=U[(ii)*len(tlist)+t]
            op=Ui*Sy[ii]*Ui.dag()
            n_y.append(expect(op,states[t]))
        expect_y.append(n_y)
    
    return expect_x,expect_y,expect_z

def plotstate(states,tlist,E_q,PlotPts=1000):
    
    if np.size(tlist)>PlotPts:
        states=states[np.round(np.linspace(0,size(tlist),PlotPts))]
        tlist=tlist[np.round(np.linspace(0,size(tlist),PlotPts))]  
        
    expect_x,expect_y,expect_z = getExpValue(states,tlist,E_q)
        
    fig, axes = plt.subplots(max(Num_Q,2), 1, figsize=(10,8))
    for ii in range(0,Num_Q):
        axes[ii].plot(tlist, expect_z[ii], label='Q'+str(ii)+'Z')
        axes[ii].set_ylim([-1.05,1.05])
        axes[ii].legend(loc=0)
        axes[ii].set_xlabel('Time')
        axes[ii].set_ylabel('P')
        plt.show()
        
    fig, axes = plt.subplots(max(Num_Q,2), 1, figsize=(10,8))
    for ii in range(0,Num_Q):
        axes[ii].plot(tlist, expect_x[ii], label='Q'+str(ii)+'X')
        axes[ii].set_ylim([-1.05,1.05])
        axes[ii].legend(loc=0)
        axes[ii].set_xlabel('Time')
        axes[ii].set_ylabel('P')
        plt.show()
    
    fig, axes = plt.subplots(max(Num_Q,2), 1, figsize=(10,8))
    for ii in range(0,Num_Q):
        axes[ii].plot(tlist, expect_y[ii], label='Q'+str(ii)+'Y')
        axes[ii].set_ylim([-1.05,1.05])
        axes[ii].legend(loc=0)
        axes[ii].set_xlabel('Time')
        axes[ii].set_ylabel('P')
        plt.show()
    
    for ii in range(0,Num_Q):
        b=Bloch()
        b.add_points([expect_x[ii],expect_y[ii],expect_z[ii]])
        b.add_vectors([expect_x[ii][-1],expect_y[ii][-1],expect_z[ii][-1]])
        b.show()
        if SD:
            b.save('./saved results/Bloch_Q'+str(ii),'png')
            
    return states,tlist, expect_x,expect_y,expect_z

def savedata(psi_total, tlist_total, expect_x,expect_y,expect_z):
    if os.path.exists('./saved results') == False:
        os.makedirs('./saved results')
    for ii in range(0,Num_Q):
        data_xyz=np.array([tlist_total.tolist(),expect_x[ii],expect_y[ii],expect_z[ii]])
        file_data_store('./saved results/data_xyz_Q'+str(ii)+'.csv',data_xyz,sep=',',numformat='exp')
    file_data_store('./saved results/data_dm.csv',psi_total[-1],sep=',',numformat='exp')

def MCaverage(inputstates):   
    states = inputstates
    outputstate = states-states
    lenc = len(states)
    lenr = len(states[0])
    for j in range(0,lenc):
        states1=states[j]
        for ii in range(0,lenr):
            states1[ii]=ket2dm(states[j][ii])
        outputstate[j] = np.mean(states1)
    
    return outputstate

def Measure(state,target):
    exp1 = expect(E_e[target],state)    #probability of excited state
    exp0 = expect(E_g[target],state)    #probability of ground state
#    print(exp1,exp0)
    measurestate1 = E_e[target]*state*state.dag()*E_e[target].dag()/exp1 #state with 1
    measurestate0 = E_g[target]*state*state.dag()*E_g[target].dag()/exp0 #state with 0
                       
    return([[exp0,measurestate0],[exp1,measurestate1]])

def prob_measure(psi):
    '''
    不同基矢下的测量结果(概率)
    the probability of differe eigenvector
    '''
    level = ['E_g','E_e']
    population = []
    labels = []
    for i in range(2**(Num_Q)):
        index = i
        code = ''  #code of state
        Measure = '' #measurement of state
        for j in range(Num_Q):
            code = str(np.int(np.mod(index,2))) + code
            Measure = '*'+level[np.int(np.mod(index,2))] +'['+str(j)+']' + Measure
            index = np.floor(index/2)
        Measure = eval('1'+Measure)
        population.append(expect(Measure,psi))
        labels.append(code)
        
    theory = np.zeros(2**(Num_Q));theory[0] = 0.5;theory[-1] = 0.5;
    error = np.sum(np.abs(theory-population))/2
    figure();plt.bar(range(len(population)),population,tick_label = labels);plt.title('ErrorRate = '+str(error));
    for x,y in zip(range(len(population)),population):
        plt.text(x,y+0.01,'%.3f'%y,ha = 'center',va = 'bottom')
    return(population)
def density_matrix(psi):
    '''
    密度矩阵的实部与虚部
    the real part and imaginary part of density matrix 
    '''
    level = ['E_g','E_e']
    population = []
    labels = []
    for i in range(2**(Num_Q)):
        index = i
        code = ''  #code of state
        Measure = '' #measurement of state
        for j in range(Num_Q):
            code = str(np.int(np.mod(index,2))) + code
            Measure = '*'+level[np.int(np.mod(index,2))] +'['+str(j)+']' + Measure
            index = np.floor(index/2)
        Measure = eval('1'+Measure)
        population.append(expect(Measure,psi))
        labels.append(code)
        
    loc = []#各个基矢在多比特3能级系统中，能级的位置
    for c in labels:
        l = 0
        for index , i in enumerate(c):
            l+=eval(i)*3**(Num_Q-1-index)
        loc.append(l)
    mtr = psi.data.toarray()[meshgrid(loc,loc)]
    re = np.real(mtr)
    im = np.imag(mtr)

    fig = plt.figure()
    ax1 = fig.add_subplot(111, projection='3d')
    x = range(len(population))
    y = range(len(population))
    x,y = meshgrid(x,y)

    x = x.flatten('F')
    y = y.flatten('F')
    z = np.zeros_like(x)

    dx = 0.5*np.ones_like(x)
    dy = 0.5*np.ones_like(y)
    dz1 = re.flatten('F')
    ax1.bar3d(x,y,z,dx,dy,dz1);ax1.set_title('Real');ax1.set_zlim(-0.6,0.6)

    dz2 = im.flatten('F')
    fig = plt.figure()
    ax2 = fig.add_subplot(111, projection='3d')
    ax2.bar3d(x,y,z,dx,dy,dz2);ax2.set_title('Imag');ax2.set_zlim(-0.6,0.6)
    

def EvolveCircuits(Operators,psi):
    
    #List of Gates: 'I','X','Y', 'Z', 'H', 'CX', 'CY', 'CZ', 'CNOT', 'SWAP', 'iSWAP', 'CSWAP', 'CCNOT', 'sSWAP', 'siSWAP', 'sNOT'
    
    if APRType==0 or APRType==2:
        if np.size(psi0.dims[0])>Num_Q+1:
            lst=np.arange(0,Num_Q+1).tolist()
        elif np.size(psi0.dims[0])==Num_Q+1:
            lst=[]
        elif np.size(psi0.dims[0])<Num_Q+1:
            raise NameError('Initial state size too short!')
    else:
        if np.size(psi0.dims[0])>Num_Q:
            lst=np.arange(0,Num_Q).tolist()
        elif np.size(psi0.dims[0])==Num_Q:
            lst=[]
        elif np.size(psi0.dims[0])<Num_Q:
            raise NameError('Initial state size too short!')
    if lst!=[]:
        psi=psi.ptrace(lst)
    
    H,args,t1,E_q=GenerateH(Operators,APRType)
      

    tlist=np.arange(0,t1+1)
    if MC:
        output=mcsolve(H,psi,tlist,c_op_list,[],args=args,options=options)
        states=MCaverage2(output.states)
    else:
        
        output=mesolve(H,psi,tlist,c_op_list,[],args=args,options=options)
        states=output.states
          
    return states, tlist

def onedimvar(arg):
    measureobj = arg[0][0]
    target = arg[0][1]
    psi0 = arg[0][2]
    var1 = arg[0][3]
    var1range = arg[0][4]
    ii = arg[0][5]
    dateTime = arg[0][6]
         
    cmeasure=measureobj.replace(var1,str(var1range[ii]))
    cmeasureobj=eval(cmeasure)
    psi_total, tlist_total=EvolveCircuits(cmeasureobj,psi0)
    
    qsave(psi_total[-1]*psi_total[-1].dag(),'./Re_'+dateTime+'/'+var1+str(var1range[ii]))
    
    measureresult = Measure(psi_total[-1],target)
    return(measureresult[1][0])

def twodimvar(arg):
    measureobj = arg[0][0]
    target = arg[0][1]
    psi0 = arg[0][2]
    var1 = arg[0][3]
    var1range = arg[0][4]
    var2 = arg[0][5]
    var2range = arg[0][6]
    ii = arg[0][7]
    jj = arg[0][8]
    dateTime = arg[0][9]
    cmeasure=measureobj.replace(var1,str(var1range[ii]))
    cmeasure=cmeasure.replace(var2,str(var2range[jj]))
    cmeasureobj=eval(cmeasure)
#    print(cmeasureobj)
    psi_total, tlist_total=EvolveCircuits(cmeasureobj,psi0)
    
    qsave(psi_total[-1]*psi_total[-1].dag(),'./Re_'+dateTime+'/'+var1+str(var1range[ii])+var2+str(var2range[jj]))
    
    measureresult = Measure(psi_total[-1],target)
#    print(measureresult[1][0])
    return(measureresult[1][0])

def RunExperiment(measureobj,target,psi0,var1,var1range,var2=[],var2range=[]):
    now = int(time.time())
    timeArray = time.localtime(now)
    dateTime = time.strftime("%Y-%m-%d %H:%M:%S", timeArray)
    if os.path.exists('./Re_'+dateTime) == False:
        os.makedirs('./Re_'+dateTime)

    p = Pool(2)
    if var2==[]:
        
        xlabel(var1)
        ylabel('Z')
        z=np.zeros(shape=(len(var1range)))
        arg = []
#        c =  np.arange(0,len(var1range)).tolist()
        for i in range(len(var1range)):
            arg.append([[measureobj,target,psi0,var1,var1range,i,dateTime]])             
        z = p.map(onedimvar,arg)
        
        figure()
        plot(var1range,z)    
    else:
        xlabel(var2)
        ylabel(var1)
        z=np.zeros(shape=(len(var1range),len(var2range)))
        for ii in range(0,len(var1range)):
            arg = []
#            c =  np.arange(0,len(var2range)).tolist()
            for jj in range(len(var2range)):
                arg.append([[measureobj,target,psi0,var1,var1range,var2,var2range,ii,jj,dateTime]]) 
            
            z[ii] = p.map(twodimvar,arg)
            del arg 
            gc.collect()
#            for jj in range(0,len(var2range)):
#                z[ii][jj] = p.apply(twodimvar,(measureobj,target,psi0,var1,var1range,var2,var2range,ii,jj,))
                # cmeasure=measureobj.replace(var1,str(var1range[ii]))
                # cmeasure=cmeasure.replace(var2,str(var2range[jj]))
                # cmeasureobj=eval(cmeasure)
                # psi_total, tlist_total=EvolveCircuits(cmeasureobj,psi0)
                # measureresult = Measure(psi_total[-1],target)
                # z[ii][jj]=(measureresult[1][0])
#                cla()
        figure()
        pcolormesh(var2range,var1range,z) 
        plt.colorbar()
#        print(z)
    p.close()
    p.join()
    z = np.array(z)
    mz = np.max(z)
    indexz = np.where(z == mz)
    return(mz,indexz,dateTime)
    
def TestGate():
    #List of Gates: 'I','X','Y', 'Z', 'H', 'CX', 'CY', 'CZ', 'CNOT', 'SWAP', 'iSWAP', 'CSWAP', 'CCNOT', 'sSWAP', 'siSWAP', 'sNOT'
        
    psi0=tensor((basis(3,0)+basis(3,1)).unit(),basis(3,1), )
#    psi0=tensor(basis(N,0), (basis(3,0)+basis(3,1)).unit(),basis(3,1))
    
    Operators=[
        ['Z','I','I','I','I'],
        ] 
    
#    psi_target=tensor(basis(N,0),basis(3,1),(basis(3,0)-basis(3,1)).unit())
    psi_target=tensor((basis(3,0)-basis(3,1)).unit(),basis(3,1), )
    
    def getfid(m):
        global fx
        fx=m
        
        psi_total, tlist_total=EvolveCircuits(Operators,psi0)
        
        U0 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(E_q[0])*tlist_total[-1])*basis(3,1)*basis(3,1).dag()
        U1 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(E_q[1])*tlist_total[-1])*basis(3,1)*basis(3,1).dag()
        UT = tensor(U0,U1)
        fid=fidelity(UT*psi_total[-1]*psi_total[-1].dag()*UT.dag(), psi_target)
#        fid=fidelity(psi_total[-1],psi_target)
        print(fid)
#        print(m[0],m[1],fid)
        return (1-fid)
    
    fid=fminbound(getfid,-np.pi,np.pi, xtol=1e-07,disp=3)
#    x0 = [500,-0.19]
#    result = minimize(getfid, x0, method="Nelder-Mead",options={'disp': True})
    
#    print(fid)
#    print(result.x)
    
    
def TestCZ():
    if APRType==0 or APRType==2:
        psi0=tensor(basis(N,0),basis(3,1), (basis(3,0)+basis(3,1)).unit())
        psi_target=tensor(basis(N,0),basis(3,1),(basis(3,0)-basis(3,1)).unit())
    else:
        psi0=tensor(basis(3,1), (basis(3,0)+basis(3,1)).unit())
        psi_target=tensor(basis(3,1),(basis(3,0)-basis(3,1)).unit())
    
    Operators=[
        ['CZ1','I','I','I','I'],
        ] 
    

    
    def getfid1(m):
        global fx
        fx = np.zeros(3)
        fx[0]=m[0]
        fx[1]=m[1]
        fx[2]=-1.71848
        
        psi_total, tlist_total=EvolveCircuits(Operators,psi0)
        
        if CRF:
            UT = (1j*H0*tlist_total[-1]).expm()
        else:
            if APRType==0 or APRType==2:
                U0 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(E_q[0])*tlist_total[-1])*basis(3,1)*basis(3,1).dag()
                U1 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(E_q[1])*tlist_total[-1])*basis(3,1)*basis(3,1).dag()
                UT = tensor(qeye(3),U0,U1)
            else:
                U0 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(E_q[0])*tlist_total[-1])*basis(3,1)*basis(3,1).dag()
                U1 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(E_q[1])*tlist_total[-1])*basis(3,1)*basis(3,1).dag()
                UT = tensor(U0,U1)
        
        fid=fidelity(UT*psi_total[-1]*psi_total[-1].dag()*UT.dag(), psi_target)

        print(fid,fx)
        return (1-fid)
    
    x0 = [2*np.pi/np.sqrt(2)/g[0],w_q[1]-(w_q[0]-w_qa[0])]
#    x0 = [2*np.pi/np.sqrt(2)/g[0],w_q[1]-w_qa[1]-(w_q[0])]
    result = minimize(getfid1, x0, method="Nelder-Mead",options={'disp': True})
    
    print(result.x) 

    if APRType==0 or APRType==2:
        psi0=tensor(basis(N,0),(basis(3,0)+basis(3,1)).unit(),basis(3,1))
        psi_target=tensor(basis(N,0),(basis(3,0)-basis(3,1)).unit(),basis(3,1))
    else:
        psi0=tensor((basis(3,0)+basis(3,1)).unit(),basis(3,1))
        psi_target=tensor((basis(3,0)-basis(3,1)).unit(),basis(3,1))
    
    
    def getfid2(m):
        global fx
        fx = np.zeros(3)
        fx[0]=result.x[0]
        fx[1]=result.x[1]
        fx[2]=m

        
        psi_total, tlist_total=EvolveCircuits(Operators,psi0)
        
        if CRF:
            UT = (1j*H0*tlist_total[-1]).expm()
        else:
            if APRType==0 or APRType==2:
                U0 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(E_q[0])*tlist_total[-1])*basis(3,1)*basis(3,1).dag()
                U1 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(E_q[1])*tlist_total[-1])*basis(3,1)*basis(3,1).dag()
                UT = tensor(qeye(3),U0,U1)
            else:
                U0 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(E_q[0])*tlist_total[-1])*basis(3,1)*basis(3,1).dag()
                U1 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(E_q[1])*tlist_total[-1])*basis(3,1)*basis(3,1).dag()
                UT = tensor(U0,U1)
        
        fid=fidelity(UT*psi_total[-1]*psi_total[-1].dag()*UT.dag(), psi_target)

        print(fid)
        return(1-fid)
        
    xopt=fminbound(getfid2,-np.pi,np.pi, xtol=1e-07,disp=3,full_output=True)

    print(result.x[0],result.x[1],xopt[0])
        
    def getfid3(m):
        global fx
        fx = np.zeros(3)
        fx[0]=m[0]
        fx[1]=m[1]
        fx[2]=m[2]
        
        
        if APRType==0 or APRType==2:
            psi0=tensor(basis(N,0),basis(3,1), (basis(3,0)+basis(3,1)).unit())
            psi_target=tensor(basis(N,0),basis(3,1),(basis(3,0)-basis(3,1)).unit())
        else:
            psi0=tensor(basis(3,1), (basis(3,0)+basis(3,1)).unit())
            psi_target=tensor(basis(3,1),(basis(3,0)-basis(3,1)).unit())
        
        psi_total, tlist_total=EvolveCircuits(Operators,psi0)
        
        if CRF:
            UT = (1j*H0*tlist_total[-1]).expm()
        else:
            if APRType==0 or APRType==2:
                U0 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(E_q[0])*tlist_total[-1])*basis(3,1)*basis(3,1).dag()
                U1 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(E_q[1])*tlist_total[-1])*basis(3,1)*basis(3,1).dag()
                UT = tensor(qeye(3),U0,U1)
            else:
                U0 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(E_q[0])*tlist_total[-1])*basis(3,1)*basis(3,1).dag()
                U1 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(E_q[1])*tlist_total[-1])*basis(3,1)*basis(3,1).dag()
                UT = tensor(U0,U1)
                
        fid1=fidelity(UT*psi_total[-1]*psi_total[-1].dag()*UT.dag(), psi_target)

        if APRType==0 or APRType==2:
            psi0=tensor(basis(N,0),(basis(3,0)+basis(3,1)).unit(),basis(3,1))
            psi_target=tensor(basis(N,0),(basis(3,0)-basis(3,1)).unit(),basis(3,1))
        else:
            psi0=tensor((basis(3,0)+basis(3,1)).unit(),basis(3,1))
            psi_target=tensor((basis(3,0)-basis(3,1)).unit(),basis(3,1))
        psi_total, tlist_total=EvolveCircuits(Operators,psi0)
        
        if CRF:
            UT = (1j*H0*tlist_total[-1]).expm()
        else:
            if APRType==0 or APRType==2:
                U0 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(E_q[0])*tlist_total[-1])*basis(3,1)*basis(3,1).dag()
                U1 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(E_q[1])*tlist_total[-1])*basis(3,1)*basis(3,1).dag()
                UT = tensor(qeye(3),U0,U1)
            else:
                U0 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(E_q[0])*tlist_total[-1])*basis(3,1)*basis(3,1).dag()
                U1 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(E_q[1])*tlist_total[-1])*basis(3,1)*basis(3,1).dag()
                UT = tensor(U0,U1)
                
                
        fid2=fidelity(UT*psi_total[-1]*psi_total[-1].dag()*UT.dag(), psi_target)
        
        
        if APRType==0 or APRType==2:
            psi0=tensor(basis(N,0),(basis(3,0)+basis(3,1)).unit(),(basis(3,0)+basis(3,1)).unit())
            tar = (tensor(basis(3,0),basis(3,0))+tensor(basis(3,0),basis(3,1))+tensor(basis(3,1),basis(3,0))-tensor(basis(3,1),basis(3,1))).unit()
            psi_target=tensor(basis(N,0),tar)
        else:
            psi0=tensor((basis(3,0)+basis(3,1)).unit(),(basis(3,0)+basis(3,1)).unit())
            tar = (tensor(basis(3,0),basis(3,0))+tensor(basis(3,0),basis(3,1))+tensor(basis(3,1),basis(3,0))-tensor(basis(3,1),basis(3,1))).unit()
            psi_target=tar
        
        
        
        psi_total, tlist_total=EvolveCircuits(Operators,psi0)
        
        if CRF:
            UT = (1j*H0*tlist_total[-1]).expm()
        else:
            if APRType==0 or APRType==2:
                U0 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(E_q[0])*tlist_total[-1])*basis(3,1)*basis(3,1).dag()
                U1 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(E_q[1])*tlist_total[-1])*basis(3,1)*basis(3,1).dag()
                UT = tensor(qeye(3),U0,U1)
            else:
                U0 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(E_q[0])*tlist_total[-1])*basis(3,1)*basis(3,1).dag()
                U1 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(E_q[1])*tlist_total[-1])*basis(3,1)*basis(3,1).dag()
                UT = tensor(U0,U1)
        fid3=fidelity(UT*psi_total[-1]*psi_total[-1].dag()*UT.dag(), psi_target)
        
        fid = (fid1+fid2+fid3)/3.0
        print(fx,fid1,fid2,fid3,fid)
        
        
        return (1-fid)
    
    x0 = [result.x[0],result.x[1],xopt[0]]
    res = minimize(getfid3, x0, method="Nelder-Mead",options={'disp': True})

    
    print(res.x[0],res.x[1],res.x[2])
    
    
def metrology(f):
    psi0=tensor(basis(3,0), (basis(3,0)+basis(3,1)).unit(), basis(3,0))
    
    Operators=[
        ['H','I','H'],
        ['CZ1_62.98=-1.3619+2.7996','I','I'],
        ['I','I','CZ1_61.00=-1.69456+0.10245'],
        ['H','I','H'],
        ['Z'+str(f),'Z'+str(f),'Z'+str(f)],
        ['H','I','H'],
        ['CZ1_62.98=-1.3619+2.7996','I','I'],
        ['I','I','CZ1_61.00=-1.69456+0.10245'],
        ['H','I','H'],
        ['I','H','I'],
        ]  
    psi_total, tlist_total=EvolveCircuits(Operators,psi0)
    measureresult = Measure(psi_total[-1],1)
    P0 = measureresult[0][0]
    P1 = measureresult[1][0]
    # ###
    # '''
    # MC
    # '''
    # P = random.random()
    # if P < P0:
    #     return(0)
    # else:
    #     return(1)
        

    # ###
    print([measureresult[0][0],measureresult[1][0]])
    return([measureresult[0][0],measureresult[1][0]])
    


if __name__=='__main__':
    starttime=time.time()
    
    ## Approximation Type{ 0: Consider Cavity but no direct coupling between qubits; 1: No cavity but consider direct coupling between qubits; 2: two level system; 3: two level system without cavity; 4:directly coupled with three levels; 5:directly coupled with two levels}
    APRType=4
    
    ## Qubit number
    Num_Q=4
    
    ## Cavity Ladder Number
    N=3
    
    ## Savedata 
    SD=False
    
    ## PlotData
    PLT=False
    
    ## Test Gate mode
    TG= 0
    ## Test CZ Gate
    TCZ = 0
    ## Coupled Rotation Frame
    CRF = 0
    ## Run experiment
    RE=0
    
    ## add dissipation
    Dis=False
    
    ## Drag
    DRAG=True
    
    ## Use monte-carlo solver
    MC=False
    
    if Dis==False:
        MC=False
    
    ## Cavity Frequency
    w_c= 5.5 * 2 * np.pi
    
    ## Qubits frequency
#    w_q = np.array([ 5.27 ,4.73, 5.15 , 4.68 , 5.28 , 5.8 , 5.7 , 5.6 , 5.5 , 5.4 , 5.3]) * 2 * np.pi
    w_q = np.array([ 5.27 ,4.73, 5.32 , 4.78 , 5.37 , 5.8 , 5.7 , 5.6 , 5.5 , 5.4 , 5.3]) * 2 * np.pi
#    w_q = np.array([  5.37, 4.78 ,   5.8 , 5.7 , 5.6 , 5.5 , 5.4 , 5.3]) * 2 * np.pi

    
    ## Coupling Strength
    g = np.array([0.0125, 0.0125, 0.0125, 0.0125, 0.0125, 0.02, 0.02, 0.02, 0.02, 0.02]) * 2 * np.pi
    
    ## Qubits Anharmonicity
    w_qa=  np.array([0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25]) * 2 * np.pi
    
    ## Base Temperature(K)
    n_th=0.01
    
    ## 1/T_1
    gamma = np.array([1./10 , 1./10 , 1./10 , 1./10 , 1./10 , 1./10 , 1./10 , 1./10 , 1./10 , 1./10 ]) * 1e-3    
        
    ## 1/T_phi                
    gamma_phi = np.array([1./10 , 1./10 , 1./10 , 1./10 , 1./10 , 1./10 , 1./10 , 1./10 , 1./10 , 1./10 ]) * 1e-3  
                
    ## Define Circuit
    Operators=[
#        ['CZ2_61=-1.69457+0.102458','CZ2_57.94037=2.050536+-1.618522','I','I'],
#        ['CZ1_62.98=-1.3619+2.7996','I','I','X','Y','Y','I','X','Y','Z'],

#         ['H','H'],
#         ['CZ1_61=-1.69457+0.102458','I'],
#         ['I','H'],
         
#         ['H','H','I'],
#         ['CZ1_61=-1.69457+0.102458','I','I',],
#         ['I','H','H'],
#         ['CZ2_60=1.69457+0.0244367','CZ2_57.94037=2.050536+-1.618522','I'],
#         ['I','I','H'],
#
         ['H','H','I','I'],
         ['CZ1_61=-1.69457+0.102458','I','I','I'],
         ['I','H','H','I'],
         ['CZ2_60=1.69457+0.0244367','CZ2_57.94037=2.050536+-1.618522','I','I'],
         ['I','I','H','H'],
         ['I','I','I','CZ2_57.99937811=1.72206004+-3.13181605'],
         ['I','I','I','H'],
         
#         ['H','H','I','I','I'],
#         ['CZ1_61=-1.69457+0.102458','I','I','I','I'],
#         ['I','H','H','I','I'],
#         ['CZ0_61=1.69457+0.0244367','CZ2_57.94037=2.050536+-1.618522','I','I','I'],
#         ['I','I','H','H','I'],
#         ['I','I','I','CZ2_57.99937811=1.72206004+-3.13181605','CZ4_59.99467425=2.024895+0.00280193'],
#         ['I','I','I','H','H'],
#         ['I','I','I','I','CZ2_59.99467425=-2.024895+3.95580538'],
#         ['I','I','I','I','H'],
        ]                    
    
    if APRType==0:
        psi0=tensor(basis(N,0), (basis(3,0)).unit(), (basis(3,0)+basis(3,1)).unit(), (basis(3,0)+basis(3,1)).unit(), basis(3,0) ,basis(3,1))
    elif APRType==1:
        
        psi0=tensor(basis(3,1), (basis(3,1)).unit(), basis(3,0), basis(3,0) ,basis(3,0),basis(3,0),basis(3,0),basis(3,0)) 
    elif APRType==2:
        psi0=tensor(basis(N,0), (basis(2,0)+basis(2,1)).unit(), (basis(2,0)+basis(2,1)).unit())#,basis(2,0) ,basis(2,0) ,(basis(2,0)+basis(2,1)).unit())
    elif APRType==3:
        psi0=tensor((basis(2,0)+basis(2,1)).unit(), (basis(2,0)+basis(2,1)).unit())  
    elif APRType==4:
        psi0=tensor((basis(3,0)).unit(), (basis(3,0)).unit(), basis(3,0), basis(3,0) ,basis(3,0),basis(3,0),basis(3,0),basis(3,0),basis(3,0)) 
    elif APRType==5:
        psi0=tensor(basis(2,0), basis(2,0), basis(2,0), basis(2,0) ,basis(2,1),basis(2,0),basis(2,0),basis(2,0),basis(2,0)) 
            
    ### Effective Coupling Strength                    
    #g_eff=g[0]*g[1]/(w_q[0]-w_c)/(w_q[1]-w_c)*(w_q[0]-w_c+w_q[1]-w_c)
    #print(g_eff/(2*np.pi)*1000)
    
    
    options=Options()
    options.atol=1e-8
    options.rtol=1e-6
    options.first_step=0.01
    options.num_cpus=8
    options.nsteps=1e6
    options.gui='True'
    options.ntraj=1000
    options.rhs_reuse=False
    
    ## Create Basic Operator
    a, sm, smm, E_e, E_g, Sz, Sx, Sy=CreateBasicOperator(APRType)             
    
    ## Create Dissipation Term
    c_op_list=GenerateDissipation(Dis)

#    H,args,t1,E_q,En = GenerateH(Operators, APRType=0)

    global th
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
    x = 1/np.tan(thsl);
    x = x-x[0];
    
    tlu = np.cumsum(np.sin(thsl))*ti[1]
    tlu=tlu-tlu[0]
    ti=np.linspace(0, tlu[-1], resolution)
    th=interpolate.interp1d(tlu,thsl,'slinear')
    th = th(ti)
    th=1/np.tan(th)
    th=th-th[0]
    th=th/min(th)
    
    ## Test Gate
    if TG:
        PLT=False
        if TCZ:
            TestCZ()
        else:
            TestGate()
#        
    ## Do Evolution
    elif RE:
        PLT=False
        tl=np.arange(30,80,5)
#        Am = np.arange(20,40,10)
#        measureobj='[["CP1_t-Am","I"],["I","Y-0.5"]]'

        measureobj='[["It","I","I","I","I","I","I","I","I","I"]]'
        
        maxm,indexm,dateTime  = RunExperiment(measureobj,1,psi0,'t',tl,[])
#        print(maxm,tl[indexm[0]],Am[indexm[1]])

        if os.path.exists('./Re_'+dateTime) == False:
            print('No Files')
        else:
            c04 = [];c14 = [];c24 = [];c34 = [];
            for t in tl:
                state = qload('t'+str(i))
                for i in [0,1,2,3]:
                    s1 = ptrace(Sy[i]*Sy[4]*state*Sy[i]*Sy[4],[i,4])
                    s2 = ptrace(state,[i,4])
                    R = (s2.sqrtm()*s1*s2.sqrtm()).sqrtm()
                    l = R.eigenenergies()
                    eval('c'+str(i)+'4').append(max([0,l[3]-l[2]-l[1]-l[0]]))
                
                
            figure()
            plot(tl,c04);plot(tl,c14);plot(tl,c24);plot(tl,c34);
            legend()
    else:
        # f = np.linspace(0,6*np.pi,90)
        # t = np.linspace(0,135,136)
#        t = 100
#        B = 0.01*2*np.pi
#        pointnum = 300
#        f = np.zeros(pointnum)
#        for i in range(pointnum):
#            f[i] = t*(1+(random.random()*0.002-0.001))*B
#            
#
#        # f = t*B
#        p = Pool(50)
#   
#        A = p.map(metrology,f)
#        p0 = np.array([x[0] for x in A])
#        p1 = np.array([x[1] for x in A])
#        p.close()
#        p.join()
#        # figure();plot(t,p0);xlabel('t');ylabel('P0');title('No Noise')
#        # figure();plot(t,p1);xlabel('t');ylabel('P1');title('No Noise')        
#        np.save('P0',np.array(p0))  
#        np.save('P1',np.array(p1))  
#
#        figure();plt.hist(p0,55);plt.xlabel('P0');plt.ylabel('frequency');plt.title('P0_'+str(t))
#        figure();plt.boxplot(p0);plt.title('P0_'+str(t))
#        std0 = np.std(p0)
#        figure();plt.hist(p1,55);plt.xlabel('P1');plt.ylabel('frequency');plt.title('P1_'+str(t))
#        figure();plt.boxplot(p1);plt.title('P1_'+str(t))
#        std1 = np.std(p1)
#        print(std0,std1)




        
        psi_total, tlist_total=EvolveCircuits(Operators,psi0)
#        measureresult = Measure(psi_total[-1],1)
#        print(measureresult[1][0])
#        tar = tensor(basis(3,0), (basis(3,0)-basis(3,1)).unit(), basis(3,1))
        psi_target = (tensor(basis(3,0), basis(3,0)  , basis(3,0) , basis(3,0)) + tensor( basis(3,1) , basis(3,1) , basis(3,1) , basis(3,1)) ).unit()
        
        U0 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(E_q[0])*tlist_total[-1])*basis(3,1)*basis(3,1).dag()
        U1 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(E_q[1])*tlist_total[-1])*basis(3,1)*basis(3,1).dag()
        U2 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(E_q[2])*tlist_total[-1])*basis(3,1)*basis(3,1).dag()
        U3 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(E_q[3])*tlist_total[-1])*basis(3,1)*basis(3,1).dag()
#        U4 = basis(3,0)*basis(3,0).dag()+np.exp(1j*(E_q[4])*tlist_total[-1])*basis(3,1)*basis(3,1).dag()
        if APRType==0 or APRType==2:
            UT = tensor(qeye(3),U0,U1)
        else:
            UT = tensor(U0,U1,U2,U3)
            
#        fid=fidelity(psi_total[-1], psi_target)
        fid=fidelity(UT*psi_total[-1]*psi_total[-1].dag()*UT.dag(), psi_target)
        print(fid)
        qsave(psi_total[-1],'4qubit')
        qsave(UT,'4UT')
        np.save('4tlist',tlist_total)
        
        
        
        expect_x=[]
        expect_y=[]
        expect_z=[]
        
        if PLT:
            psi_total,tlist_total, expect_x,expect_y,expect_z=plotstate(psi_total,tlist_total,E_q)
            psi=psi_total[-1]
            
        if SD:
            savedata(psi_total, tlist_total, expect_x,expect_y,expect_z)
    
    
#    H,args,t1,E_q,En = GenerateH(Operators, APRType=0)
    finishtime=time.time()
    print( 'Time used: ', (finishtime-starttime), 's')

