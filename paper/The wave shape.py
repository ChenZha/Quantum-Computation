# -*- coding: utf-8 -*-
"""
Created on Tue Feb 14 20:34:30 2017

@author: Chen
"""

import matplotlib.pyplot as plt
import numpy as np

#==============================================================================
Omega = 0.021*2*np.pi
width = 10
t0 = 0
t1 = 40
wa = 5.0  * 2 * np.pi  # atom frequency
#==============================================================================
def step_t_F(w1, w2, t0, t, width=0.5, w_ref=0):
    """
    Step function that goes from w1 to w2 at time t0
    as a function of t, with finite rise time defined
    by the parameter width.
    """
    return w1 + (w2 - w1) / (1 + np.exp(-(t-t0)/width)) - w_ref
    
def step_t_I(w1, w2, t0, t, width=0.5, w_ref=0):
    """
    Step function that goes from w1 to w2 at time t0
    as a function of t. 
    """
    return w1 + (w2 - w1) * (t > t0) - w_ref
    
    
def rx(t,omega=0.02*2*np.pi,width=10,f=5.2*2*np.pi):
    return omega*np.exp(-(t-20)**2/2.0/width**2)*np.cos(t*f)

    
def ry(t,omega=0.02*2*np.pi,width=10,f=5.2*2*np.pi):
    return omega*np.exp(-(t-20)**2/2.0/width**2)*np.cos(t*f+np.pi/2)
    
def rz(t,wt=5.2*2*np.pi,width=0.5,t0=2,t1=38,delta=0.02*np.pi):
    return wt+delta/(1+np.exp(-(t-t0)/width))-delta/(1+np.exp(-(t-t1)/width))

def evo1(t,args = None):
#    return(Omega*np.exp(-(t-20-t0)**2/2.0/width**2)*np.cos(t*wa)*(t0<t<=min(t1,t0+40)))
    return(t0<t<=min(t1,t0+40))
    
tlist = np.linspace(0,40,100)
#wave_shape1 = step_t_F(1, 4, 10, tlist, width=0.5, w_ref=0)
#wave_shape2 = step_t_I(1, 4, 10, tlist, width=0.5, w_ref=0)

waveshape = ry(tlist)

fig,axes = plt.subplots(1,1)
#axes[0].plot(tlist,wave_shape1)
#axes[0].set_xlabel('Time')
#axes[0].set_ylim(0, 5)
#axes[0].set_title('step_t_F')
#axes[1].plot(tlist,wave_shape2)
#axes[1].set_xlabel('Time')
#axes[1].set_ylim(0, 5)
#axes[1].set_title('step_t_I')

axes.plot(tlist,waveshape)
axes.set_xlabel('Time')
axes.set_title('wave shape of RZ')
#axes.set_ylim(0, 5)