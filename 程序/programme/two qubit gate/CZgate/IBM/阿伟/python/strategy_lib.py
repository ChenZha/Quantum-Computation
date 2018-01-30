# -*- coding: utf-8 -*-
"""
Created on Thu Dec 21 16:35:19 2017

@author: Liswer
用于生成下一步测量参数
输入：data(或它的部分),策略参数
输出：下次测量的测量参数
"""

import numpy as np
import random

def DE_algorithm(x_old,para,x_u,x_l):
    """
    x_old是父代优化空间矢量
    x_new是子代优化空间矢量
    para是DE算法参数
    x_u,x_l是空间上下界
    """
    f=para[0]
    cr=para[1]
    m_size=np.size(x_old,0)
    n=np.size(x_old,1)
    v_new=np.zeros((m_size , n))
    for i in range(m_size):
        #变异操作，对第g代随机抽取三个组成一个新的个体，对于第i个新个体来说，原来的第i个个体与它没有关系
        x_g_without_i = np.delete(x_old,i,0)
        random.shuffle(x_g_without_i)
        h_i = x_g_without_i[1]+f*(x_g_without_i[2]-x_g_without_i[3])
        #变异操作后，h_i个体可能会过上下限区间，为了保证在区间以内对超过区间外的值赋值为相邻的边界值
        #先处理上边界，如果h_i[item]大于x_u则取x_u，如果小于则取h_i[item]
        h_i = [h_i[item] if h_i[item]<x_u[item] else x_u[item] for item in range(n)] 
        h_i = [h_i[item] if h_i[item]>x_l[item] else x_l[item] for item in range(n)] 
        #交叉操作，对变异后的个体，根据随机数与交叉阈值确定最后的个体
        #print(h_i)
        v_i = np.array([x_old[i][j] if (random.random() > cr) else h_i[j] for j in range(n) ])
        v_new[i]=v_i
    return v_new

def SUSSADE_algorithm(x_old,para,x_u,x_l,cr,f):
    """
    x_old是父代优化空间矢量
    x_new是子代优化空间矢量
    para是DE算法参数
    x_u,x_l是空间上下界
    cr,f传的是指针
    """
    k1=para[0]
    k2=para[1]
    uu=para[2]
    ul=para[3]
    Su=para[4]
    m_size=np.size(x_old,0)
    n=np.size(x_old,1)
    v_new=np.zeros((m_size , n))
    for i in range(m_size):
        #变异操作，对第g代随机抽取三个组成一个新的个体，对于第i个新个体来说，原来的第i个个体与它没有关系
        if (random.random()<k1):
            f[i]=ul+random.random()*uu
        if (random.random()<k2):
            cr[i]=random.random()
        x_g_without_i = np.delete(x_old,i,0)
        random.shuffle(x_g_without_i)
        h_i = x_g_without_i[1]+f[i]*(x_g_without_i[2]-x_g_without_i[3])
        #变异操作后，h_i个体可能会过上下限区间，为了保证在区间以内对超过区间外的值赋值为相邻的边界值
        #先处理上边界，如果h_i[item]大于x_u则取x_u，如果小于则取h_i[item]
        h_i = [h_i[item] if h_i[item]<x_u[item] else x_u[item] for item in range(n)] 
        h_i = [h_i[item] if h_i[item]>x_l[item] else x_l[item] for item in range(n)] 
        #交叉操作，对变异后的个体，根据随机数与交叉阈值确定最后的个体
        #print(h_i)
        if (random.random()<Su):
            v_i = np.array([x_old[i][j] if (random.random() > cr[i]) else h_i[j] for j in range(n) ])
        else:
            v_i=x_old[i]
        r_change=random.randint(0,n-1)
        v_i[r_change]=h_i[r_change]
        v_new[i]=v_i
    return v_new

def Nelder_Mead_algorithm(x_old,x_append,para):
    '''
    x_append:[x0,xr,xe,xc]
    para:[pype,afa,gam,rho,sgm]
    '''
    Nelder_Mead_type=para[0]
    afa=para[1]
    gma=para[2]
    rho=para[3]
    sgm=para[4]
    n_dim=len(x_old)-1
    if(Nelder_Mead_type==0):
        xr=x_append[0]+afa*(x_append[0]-x_old[n_dim])
        return [xr]
    if(Nelder_Mead_type==1):
        xe=x_append[0]+gma*(x_append[1]-x_append[0])
        return [xe]
    if(Nelder_Mead_type==2):
        xc=x_append[0]+rho*(x_old[n_dim]-x_append[0])
        return [xc]
    if(Nelder_Mead_type==3):
        v_i=np.zeros((n_dim,n_dim))
        for ii in range (0,n_dim):
            v_i[ii]=x_append[0]+sgm*(x_old[ii+1]-x_old[0])
        return v_i
    