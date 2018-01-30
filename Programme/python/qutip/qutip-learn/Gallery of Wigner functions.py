# -*- coding: utf-8 -*-
"""
Created on Sat Feb 11 17:03:10 2017

@author: Chen
"""

import matplotlib.pyplot as plt
import numpy as np
from qutip import *

N = 20

#==============================================================================
def plot_wigner_2d_3d(psi):
    #fig, axes = plt.subplots(1, 2, subplot_kw={'projection': '3d'}, figsize=(12, 6))
    fig = plt.figure(figsize=(17, 8))
    
    ax = fig.add_subplot(1, 2, 1)
    plot_wigner(psi, fig=fig, ax=ax, alpha_max=6);

    ax = fig.add_subplot(1, 2, 2, projection='3d')
    plot_wigner(psi, fig=fig, ax=ax, projection='3d', alpha_max=6);
    
#    plt.close(fig)
    return fig
#==============================================================================
psi = (coherent(N, -2.0) + coherent(N, 2.0)).unit()
plot_wigner_2d_3d(psi)

