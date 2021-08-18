#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Mar 16 20:18:52 2017

@author: chen
"""
'''
Generator a Hamilton
'''

from qutip import *
import numpy as np
import matplotlib.pyplot as plt 
from pylab import *
from gate import *
from initialsetting import *

def SingleOpTime(Operator,setting = qusetting()):
    lenc = len(Operator)
    time = 0
    for inxc in range(0,lenc):
        if Operator[inxc][0]=='X':
#            w = np.sqrt((w_q[inxc]-w_c)**2+4*g[inxc]**2*(n+1))
#            t = np.floor(100*2*np.pi/w)
##            t = 2*np.pi/w 
#            print (t)
            time = np.max([time , 40])
        elif Operator[inxc][0]=='Y':
            time = np.max([time , 40])
        elif Operator[inxc][0]=='Z':
            time = np.max([time , 40])
        elif Operator[inxc][0]=='i':
            time = np.max([time , 500])
        elif Operator[inxc][0]=='H':
            time = np.max([time , 80])    
        elif Operator[inxc][0]=='C':
            if Operator[inxc][1]=='Z':
                time = np.max([time , setting.CZtime])
        elif Operator[inxc][0]=='I':
            if len(Operator[inxc]) == 1:
                time = np.max([time , 0])
            else:
                time = np.max([time , int(Operator[inxc][1:])])
    return(time)
                
                
                
                
def GenerateH(Operator , setting = qusetting()):
    t0 = 0 ;  t1 = SingleOpTime(Operator,setting)
    if setting.qtype == 1:
        
        a,sm,E_uc,E_e,E_g,sn,sx,sxm,sy,sym,sz,En = initial(setting)
        setting.En = En

    
        HCoupling = setting.g[0]*(a+a.dag())*(sm[0]+sm[0].dag()) + setting.g[1]*(a+a.dag())*(sm[1]+sm[1].dag())
#        HCoupling = setting.g[0]*(a.dag()*sm[0]+a*sm[0].dag()) + setting.g[1]*(a.dag()*sm[1]+a*sm[1].dag())
        Hc = setting.w_c * a.dag() * a 
        H_eta = setting.eta_q[0] * E_uc[0] + setting.eta_q[1] * E_uc[1]
        Hq = setting.w_q[0]*sn[0] + setting.w_q[1]*sn[1]
        H = Hq + H_eta + Hc + HCoupling

        
        lenc = len(Operator)
        args = {}
        w_t=[]
        D_t=[]
        for inxc in range(0,lenc):# import drive
            if Operator[inxc][0]=='X':
                if len(Operator[inxc])==1:
                    w_t_i,D_t_i,args_i=Gate_rx(inxc,t0,t1,setting = setting)
                else:
                    w_t_i,D_t_i,args_i=Gate_rx(inxc,t0,t1,phi=np.pi*float(Operator[inxc][1:]),setting = setting)
            elif Operator[inxc][0]=='Y':
                if len(Operator[inxc])==1:
                    w_t_i,D_t_i,args_i=Gate_ry(inxc,t0,t1,setting = setting)
                else:
                    w_t_i,D_t_i,args_i=Gate_ry(inxc,t0,t1,phi=np.pi*float(Operator[inxc][1:]),setting = setting)
            elif Operator[inxc][0]=='Z':
                if len(Operator[inxc])==1:
                    w_t_i,D_t_i,args_i=Gate_rz(inxc,t0,t1,setting = setting)
                else:
                    w_t_i,D_t_i,args_i=Gate_rz(inxc,t0,t1,phi=np.pi*float(Operator[inxc][1:]),setting = setting)
            elif Operator[inxc][0]=='i':
                w_t_i,D_t_i,args_i=Gate_iSWAP(inxc,int(Operator[inxc][5:]),t0,t1,setting = setting)
            elif Operator[inxc][0]=='H':
                w_t_i,D_t_i,args_i=Gate_H(inxc,t0,t1,setting = setting)
            elif Operator[inxc][0]=='C':
                if Operator[inxc][1]=='Z':
                    w_t_i,D_t_i,args_i=Gate_CZ(inxc,int(Operator[inxc][2:]),t0,t1,setting = setting)
            elif Operator[inxc][0]=='I':
                    w_t_i,D_t_i,args_i=Gate_i(inxc,t0,t1)
            w_t.append(w_t_i)
            D_t.append(D_t_i)
            args=dict(args,**args_i)##在args里加入args_i
        H_q0 = [sn[0] , w_t[0]]
        H_q1 = [sn[1] , w_t[1]]
        H_d0 = [sx[0] , D_t[0]] 
        H_d1 = [sx[1] , D_t[1]]
        
        
        
    elif setting.qtype == 2:
        
        sm,E_uc,E_e,E_g,sn,sx,sxm,sy,sym,sz,En = initial(setting)
        setting.En = En
        
        Delta1 = abs(setting.w_q[0]-setting.w_c)
        Delta2 = abs(setting.w_q[1]-setting.w_c)
        g_effect = 0.5*setting.g[0]*setting.g[1]*(Delta1+Delta2)/(Delta1*Delta2)
#        print(g_effect)
        HCoupling = g_effect*(sm[0]+sm[0].dag())*(sm[1]+sm[1].dag())
        H_eta = setting.eta_q[0] * E_uc[0] + setting.eta_q[1] * E_uc[1]
        Hq = setting.w_q[0]*sn[0] + setting.w_q[1]*sn[1]
        H=  Hq + H_eta + HCoupling
        

        lenc = len(Operator)
        args = {}
        w_t=[]
        D_t=[]
        for inxc in range(0,lenc):# import drive
            if Operator[inxc][0]=='X':
                w_t_i,D_t_i,args_i=Gate_rx(inxc,t0,t1,setting = setting)
            elif Operator[inxc][0]=='Y':
                w_t_i,D_t_i,args_i=Gate_ry(inxc,t0,t1,setting = setting)
            elif Operator[inxc][0]=='Z':
                w_t_i,D_t_i,args_i=Gate_rz(inxc,t0,t1)
            elif Operator[inxc][0]=='i':
                w_t_i,D_t_i,args_i=Gate_iSWAP(inxc,int(Operator[inxc][5:]),t0,t1,setting = setting)
            elif Operator[inxc][0]=='C':
                if Operator[inxc][1]=='Z':
                    w_t_i,D_t_i,args_i=Gate_CZ(inxc,int(Operator[inxc][2:]),t0,t1,setting = setting)
            elif Operator[inxc][0]=='I':
                    w_t_i,D_t_i,args_i=Gate_i(inxc,t0,t1)
            w_t.append(w_t_i)
            D_t.append(D_t_i)
            args=dict(args,**args_i)##在args里加入args_i
        H_q0 = [sn[0] , w_t[0]]
        H_q1 = [sn[1] , w_t[1]]
        H_d0 = [sx[0] , D_t[0]] 
        H_d1 = [sx[1] , D_t[1]]
        
    
    
    H = [H , H_q0 , H_q1 , H_d0 , H_d1]
    tlist = np.linspace(0,t1,(t1-t0)+1)
#    tlist = np.arange(0,t1+1)
#    print(H)
#    print(w_t[0])
#    print(args)
    return H , args , tlist 