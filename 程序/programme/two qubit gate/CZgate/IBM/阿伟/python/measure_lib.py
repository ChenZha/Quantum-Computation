# -*- coding: utf-8 -*-
"""
Created on Thu Dec 21 17:57:30 2017

@author:Liswer
用于下一步测量方案
输入：波形种类，波形参数，波形数目
输出：每种波形的测量结果
"""

import op_z_CZ_qubit as op_z_CZ_qubit
import multiprocessing
import numpy as np

def CZ_gate_error_simulation(waveform_fun,wave_para):
    num_cpu=4
    num_measure=len(wave_para)
    errors=np.zeros(num_measure)
    pool = multiprocessing.Pool(processes=num_cpu)
    results=[]
    arg_input=[]
    for ii in range (0,num_measure):
        arg_input.append([waveform_fun]+[wave_para[ii]])
    for ii in range (0,num_measure):
        results.append(pool.apply_async(op_z_CZ_qubit.__main__, (arg_input[ii],)))
    pool.close()
    pool.join()
    for ii in range (0,num_measure):
        errors[ii]=1-results[ii].get()
    return(errors)
        
        