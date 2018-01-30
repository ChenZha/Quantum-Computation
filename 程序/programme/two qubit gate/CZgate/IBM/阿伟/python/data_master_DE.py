# -*- coding: utf-8 -*-
"""
Created on Thu Dec 21 17:10:26 2017

@author: Administrator
"""


import numpy as np
import scipy.io as sio
import strategy_lib as strategy_lib
import waveform_lib as waveform_lib
import measure_lib as measure_lib
import data_analyse_lib as data_analyse_lib
import time as time
import random

if __name__ == '__main__':
    
    #程序参数设置
    is_load=0
    file_name='fidelity'+time.strftime('%Y%m%d__%H%M%S',time.localtime(time.time()))
    filename_load='fidelity20171217__001346'
    generation=10
    population=64
    n_dim=22
    para=np.array([0.8,0.4])
    wave_para=np.array([39.5,-6.7e-01,4.27724242e-03,6.68727052e-03,-5.48211328e-03,2.07079914e-02,1.66219824e-04,2.19267040e-02,   0,0,0,0,0,0,0,0,0,0,0,0,0,0])
    x_l=wave_para-np.array([3,2e-1,2e-1,2e-1,2e-1,2e-1,2e-1,2e-1,6e-1,5e-1,4e-1,3e-1,2e-1,2e-1,2e-1,6e-1,5e-1,4e-1,3e-1,2e-1,2e-1,2e-1])
    x_u=wave_para+np.array([4,2e-1,2e-1,2e-1,2e-1,2e-1,2e-1,2e-1,6e-1,5e-1,4e-1,3e-1,2e-1,2e-1,2e-1,6e-1,5e-1,4e-1,3e-1,2e-1,2e-1,2e-1])
    
    #定义数据格式
    data=data_analyse_lib.data_record(generation,population,n_dim)
    
    #第0代初始化
    if(is_load):    
        print('随机初始参数')
    else:
        print('随机初始参数')
        for i in range(population):
            data.x_all[0][i] = x_l+(random.random()/3+1/3)*(x_u-x_l)
    data.v_all[0]=data.x_all[0]
    waveform_fun=waveform_lib.waveform_basis_1_t_point_2_cos_sin
    measure_fun=measure_lib.CZ_gate_error_simulation
    error_exp=measure_fun(waveform_fun,data.x_all[0])
    data.x_fun_value[0]=error_exp
    data.v_fun_value[0]=data.x_fun_value[0]
    data.best_x[0] = data.x_all[0][np.argmin(data.x_fun_value[0])]
    data.best_x_fun_value[0]=np.min(data.x_fun_value[0])
     #初始化结果输出
    print('差分进化算法初始化完成')
    print('寻优参数个数为',n_dim,'优化区间分别为：\n',x_l,'\n',x_u)
    print('x_fun_value=',data.x_fun_value[0])
    print('**********best_fidelity=(',1-data.best_x_fun_value[0],')**********\n    best_fun_value=',data.best_x_fun_value[0],'mean_fun_value=',np.mean(data.x_fun_value[0]))
    print('best_x=',data.best_x[0])
            
    #第n代迭代        
    for g in range(generation-1):
        print('\n第',g+1,'代开始演化')
        strategy_fun=strategy_lib.DE_algorithm
        waveform_fun=waveform_lib.waveform_basis_1_t_point_2_cos_sin
        measure_fun=measure_lib.CZ_gate_error_simulation
        
        x_exp=strategy_fun(data.x_all[g],para,x_u,x_l)
        error_exp=measure_fun(waveform_fun,x_exp)
        
        data.DE_next_generation(error_exp,x_exp,g)
        
        print('x_fun_value=',data.x_fun_value[g+1])
        print('v_fun_value=',data.v_fun_value[g+1])
        print('**********best_fidelity=(',1-data.best_x_fun_value[g+1],')**********\n    best_fun_value=',data.best_x_fun_value[g+1],'mean_fun_value=',np.mean(data.x_fun_value[g+1]))
        print('best_x=',data.best_x[g+1])
        sio.savemat(file_name, {'x_all':data.x_all,'v_all':data.v_all,'x_fun_value':data.x_fun_value,'v_fun_value':data.v_fun_value,'best_x':data.best_x,'best_x_fun_value':data.best_x_fun_value})
    
    print('done')

        