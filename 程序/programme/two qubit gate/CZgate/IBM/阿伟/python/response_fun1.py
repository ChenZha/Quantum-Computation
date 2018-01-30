# -*- coding: utf-8 -*-
"""
Created on Thu Dec 14 19:13:47 2017

@author: Liswer
高斯滤波函数
输入波形族类，波形参数
返回一个插值函数的函数句柄
"""

import matplotlib.pyplot as plt
import numpy as np
from math import *
from scipy import interpolate 

def band_pass_filter(w,band_width=0.3):
    amp=2**(-w/band_width)
    return amp
    
def waveform_t_fun_pass_filter(waveform_t_fun,t_gate,t_all=500,t_zero=200):
    #取0.5ns单位
    t_gate=round(t_gate*2)/2
    t_all=round(t_all*2)/2
    t_zero=round(t_zero*2)/2
    num_sample=int(round(2*t_all+1))
    num_begin=int(2*t_zero)
    num_gate=int(2*t_gate+1)
#    num_gate_point=int(round(2*t_gate+1))
#    num_gate_begin=int(round(2*t_zero+1))
    t_waveform=np.linspace(0,t_all,num_sample)
    waveform_t=np.zeros(num_sample)    
    for ii in range (num_begin,num_begin+num_gate):
        waveform_t[ii]= waveform_t_fun(t_waveform[ii]-t_zero)
    #转换到频域    
    w0=1/t_all  #GHz
    w_waveform=np.linspace(0,w0*(num_sample-1),num_sample)
    waveform_w=[[np.complex]*1]*num_sample
    for ii in range (0,num_sample):
        waveform_w[ii]=0
        for jj in range (0,num_sample-1):
            waveform_w[ii]=waveform_w[ii]+np.exp(2*pi*1j*w_waveform[ii]*t_waveform[jj])*waveform_t[jj]
        waveform_w[ii]=waveform_w[ii]/np.sqrt(num_sample-1)
    waveform_t_new=[[np.complex]*1]*num_sample
    for ii in range (0,num_sample):
        waveform_t_new[ii]=0
        for jj in range (0,num_sample-1):
            waveform_t_new[ii]=waveform_t_new[ii]+np.exp(-2*pi*1j*t_waveform[ii]*w_waveform[jj])*waveform_w[jj]*band_pass_filter(w_waveform[jj])
        waveform_t_new[ii]=waveform_t_new[ii]/np.sqrt(num_sample-1)
    waveform_t_new=np.real(waveform_t_new)
    response_fun1_back=interpolate.interp1d(t_waveform-t_zero,waveform_t_new,'cubic')
    return ([response_fun1_back,waveform_t_new,waveform_t,waveform_w,t_waveform,w_waveform])
    

def __main__(waveform_t_fun,t_gate):
    is_picture=1
    #x=np.array([36,-3.43887341e-01,4.27724242e-03,0,0,2.07079914e-02,0,2.19267040e-02])
    [response_fun1_back,waveform_t_new,waveform_t,waveform_w,t_waveform,w_waveform]=waveform_t_fun_pass_filter(waveform_t_fun,t_gate)  
    
    if(is_picture==0):
        return (response_fun1_back)
    else:
    #画图
        t_effect=np.linspace(0,t_gate,int(round(2*t_gate+1)))
        fig, axes = plt.subplots(3,2,figsize=(15, 9))
        
        axes[0][0].plot(t_waveform,np.real(waveform_t))
        axes[0][0].set_xlabel('t_waveform')
        axes[0][0].set_ylabel('waveform_t')
        
        axes[0][1].plot(w_waveform,np.real(waveform_w))
        axes[0][1].set_xlabel('w_waveform')
        axes[0][1].set_ylabel('waveform_w')
        
        axes[1][0].plot(t_waveform,np.real(waveform_t_new))
        axes[1][0].plot(t_waveform,np.real(waveform_t))
        axes[1][0].set_xlabel('t_waveform')
        axes[1][0].set_ylabel('waveform_t_new')
        axes[1][0].legend(("waveform_t_new", "waveform_t"))
        
        axes[1][1].plot(t_waveform,np.real(waveform_t_new)-np.real(waveform_t))
        axes[1][1].set_xlabel('t_waveform')
        axes[1][1].set_ylabel('delta')
        
        axes[2][0].plot(t_effect,response_fun1_back(t_effect))
        axes[2][0].plot(t_effect,waveform_t_fun(t_effect))
        axes[2][0].set_xlabel('t_effect')
        axes[2][0].set_ylabel('waveform_effect')
        axes[2][0].legend(("waveform_effect", "waveform_effect_new"))
    
        axes[2][1].plot(t_effect,response_fun1_back(t_effect)-waveform_t_fun(t_effect))
        axes[2][1].set_xlabel('t_effect')
        axes[2][1].set_ylabel('delta')
    
        return (response_fun1_back) 





