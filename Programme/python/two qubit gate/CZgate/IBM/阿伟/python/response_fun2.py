# -*- coding: utf-8 -*-
"""
Created on Sat Dec 16 22:14:18 2017

@author: Liswer
指数相应
输入波形族类，波形参数
返回一个插值函数的函数句柄
"""
import matplotlib.pyplot as plt
import numpy as np
from math import *
from scipy import interpolate 

def waveform_delay_exponential(waveform_t_fun,t_gate,t_before_pulse=50,t_delay_index=2):
    t_all=t_before_pulse+t_before_pulse
    t_point_all=int(round(2*t_all+1))
    t_point_before_pulse=int(round(2*t_before_pulse))
    waveform_t=np.zeros(t_point_all)
    waveform_t_new=np.zeros(t_point_all)
    t_waveform=np.linspace(0,t_all,t_point_all)
    for ii in range (0,t_point_before_pulse):
        waveform_t[ii]=0
    for ii in range (t_point_before_pulse,t_point_all):
        waveform_t[ii]=waveform_t_fun(ii/2-t_before_pulse)
    #衰减卷积
    for ii in range (t_point_before_pulse,t_point_all):
        waveform_t_new[ii]=waveform_t[ii]+np.exp(-0.5/t_delay_index)*(waveform_t_new[ii-1]-waveform_t[ii])
    response_fun2_back=interpolate.interp1d(t_waveform-t_before_pulse,waveform_t_new,'linear')
    return ([response_fun2_back,waveform_t_new,waveform_t,t_waveform])

def __main__(waveform_t_fun,t_gate):
    is_picture=1
    [response_fun2_back,waveform_t_new,waveform_t,t_waveform]=waveform_delay_exponential(waveform_t_fun,t_gate)
    if(is_picture==0):
        return (response_fun2_back)
    else:
        t_effect=np.linspace(0,t_gate,int(round(2*t_gate+1)))
        fig, axes = plt.subplots(3,2,figsize=(15, 9))
        
        axes[0][0].plot(t_waveform,np.real(waveform_t))
        axes[0][0].set_xlabel('t_waveform')
        axes[0][0].set_ylabel('waveform_t')
        
        axes[1][0].plot(t_waveform,np.real(waveform_t))
        axes[1][0].plot(t_waveform,np.real(waveform_t_new))        
        axes[1][0].set_xlabel('t_waveform')
        axes[1][0].set_ylabel('waveform_t_new')
        axes[1][0].legend(("waveform_t", "waveform_t_new"))
        
        axes[1][1].plot(t_waveform,np.real(waveform_t_new)-np.real(waveform_t))
        axes[1][1].set_xlabel('t_waveform')
        axes[1][1].set_ylabel('delta')
        
        axes[2][0].plot(t_effect,waveform_t_fun(t_effect))
        axes[2][0].plot(t_effect,response_fun2_back(t_effect))    
        axes[2][0].set_xlabel('t_effect')
        axes[2][0].set_ylabel('waveform_effect')
        axes[2][0].legend(("waveform_effect", "waveform_effect_new"))
    
        axes[2][1].plot(t_effect,response_fun2_back(t_effect)-waveform_t_fun(t_effect))
        axes[2][1].set_xlabel('t_effect')
        axes[2][1].set_ylabel('delta')
    
        return (response_fun2_back)
    
    