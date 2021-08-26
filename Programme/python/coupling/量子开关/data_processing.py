#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Oct 18 11:08:08 2017

@author: chen
"""
'''
处理不同时间下，最大保真度，及对应参数
'''
import matplotlib.pyplot as plt
import numpy as np
from mpl_toolkits.mplot3d import Axes3D
import random
from multiprocessing import Pool




#==============================================================================
fid = np.load('/home/chen/P0.npy')
#tp = np.arange(20,35,1)
#delta = np.arange(1.314,1.754,0.001)
#
#mt = []
#mdelta = []
#mfid = []
#
#for indext,t in enumerate(tp):
#    mfid.append(np.max(fid[indext]))
#    index = np.where(fid == np.max(fid[indext]))
#    mdelta.append(delta[index[1]])
#    mt.append(t)
#fid = np.load('/home/chen/No_CrossTalk_1_0+1.npy')
#tp = np.arange(35,150,1)   
#delta = np.arange(1.014,2.054,0.006)
#for indext,t in enumerate(tp):
#    mfid.append(np.max(fid[indext]))
#    index = np.where(fid == np.min(fid[indext]))
#    mdelta.append(delta[index[1]][0])
#    mt.append(t)
#
#
##
#figure();plot(mt,mdelta)
###figure();plot(mdelta)
#figure();plot(mt,mfid)
#==============================================================================



    
#fid = np.load('/home/chen/QS_0.16_fid.npy')
#tp = np.arange(75,200,1)
#delta = np.arange(-0.2*0.2 * 2 * np.pi,1.2*2.4048*0.2 * 2 * np.pi,0.005*2*np.pi)
#mt = []
#mdelta = []
#mfid = []
#
#for indext,t in enumerate(tp):
#    mfid.append(np.min(fid[indext][0:95]))
#    index = np.where(fid == np.min(fid[indext][0:95]))
#    mdelta.append(delta[index[1]])
#    mt.append(t)
#    
#ax = subplot(111,projection = '3d')
#ax.plot(mt,mdelta,mfid);xlabel('t');ylabel('delta')
#figure();plot(mt,mfid);xlabel('t');ylabel('fidelity')
#figure();plot(mt,mdelta);xlabel('t');ylabel('delta')
