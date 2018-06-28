# -*- coding: utf-8 -*-
"""
Created on Sat Dec 16 17:01:13 2017

@author: Liswer
用于波形的基矢选择
"""
import numpy as np
from scipy import interpolate 

def waveform_basis_cos_sin(t_input,wave_para,rise_time=3):
    try:
        waveform=np.zeros(len(t_input))
        ts=t_input.copy()
    except:
        waveform=np.zeros(1)
        ts=np.array([t_input])
    t_gate=round(wave_para[0]*2)/2
    t_pulse=t_gate-2*rise_time
    for ii in range (0,len(ts)):
        t=ts[ii]    
        t=t-(rise_time)
        if ((t>=0)&(t<=t_pulse)):
            waveform[ii]=wave_para[1]+wave_para[2]*np.sin(np.pi*t/t_pulse)+wave_para[3]*np.cos(np.pi*t/t_pulse)+wave_para[4]*np.sin(2*np.pi*t/t_pulse)+wave_para[5]*np.cos(2*np.pi*t/t_pulse)+wave_para[6]*np.sin(4*np.pi*t/t_pulse)+wave_para[7]*np.cos(4*np.pi*t/t_pulse)     
        else:
            waveform[ii]=0
    return waveform

def waveform_basis_1_t_point_2_cos_sin(t_input,wave_para,delay_time=6,before_time=3):
    """
    第0个参数是t_gate
    第1个参数是方波高度
    第2-7个参数是正弦余弦参数
    第8-14个参数针对上升沿优化
    第15-21个参数针对下降沿优化
    """
    try:
        waveform=np.zeros(len(t_input))
        ts=t_input.copy()
    except:
        waveform=np.zeros(1)
        ts=np.array([t_input])
    t_gate=round(wave_para[0]*2)/2
    t_pulse=t_gate-delay_time-before_time
    num_all_shape_para=8  #全局波形参数数量
    t_wave_pulse_op_points=np.zeros(2*delay_time+2)
    wave_pulse_op_points=np.zeros(2*delay_time+2)
    #定义特殊优化采样点(共4*rise_time+2=14个)
    for ii in range (0,delay_time+1):
        t_wave_pulse_op_points[ii]=ii/2+before_time
        wave_pulse_op_points[ii]=wave_para[ii+num_all_shape_para]
        t_wave_pulse_op_points[delay_time+1+ii]=t_gate-delay_time+ii/2
        wave_pulse_op_points[delay_time+1+ii]=wave_para[delay_time+1+ii+num_all_shape_para]
    wave_pulse_op_points_fun=interpolate.interp1d(t_wave_pulse_op_points,wave_pulse_op_points,'linear')
    for ii in range (0,len(ts)):
        t=ts[ii]-before_time    
        if ((t>=0)&(t<=t_pulse)):
            waveform[ii]=waveform[ii]+wave_para[1]+wave_para[2]*np.sin(np.pi*t/t_pulse)+wave_para[3]*np.cos(np.pi*t/t_pulse)+wave_para[4]*np.sin(2*np.pi*t/t_pulse)+wave_para[5]*np.cos(2*np.pi*t/t_pulse)+wave_para[6]*np.sin(4*np.pi*t/t_pulse)+wave_para[7]*np.cos(4*np.pi*t/t_pulse)
        if ((t>=0)&(t<=t_pulse+delay_time/2)):
            waveform[ii]=waveform[ii]+wave_pulse_op_points_fun(t+before_time)
    return waveform
    
    