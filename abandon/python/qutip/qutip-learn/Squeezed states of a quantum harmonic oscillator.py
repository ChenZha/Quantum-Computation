# -*- coding: utf-8 -*-
"""
Created on Tue Jan 24 22:49:35 2017

@author: lenovo
"""

from qutip import *
import numpy as np
import matplotlib.pyplot as plt 
from qutip import gates
from IPython.display import HTML
from matplotlib import animation

from time import clock
starttime=clock()


N = 35
w = 1 * 2 * np.pi              # oscillator frequency
tlist = np.linspace(0, 4, 101) # periods 

# operators
a = destroy(N)
n = num(N)
x = (a + a.dag())/np.sqrt(2)
p = -1j * (a - a.dag())/np.sqrt(2)

# the quantum harmonic oscillator Hamiltonian
H = w * a.dag() * a

c_ops = []

# uncomment to see how things change when disspation is included
# c_ops = [np.sqrt(0.25) * a]


def plot_expect_with_variance(N, op_list, op_title, states):
    """
    Plot the expectation value of an operator (list of operators)
    with an envelope that describes the operators variance.
    """
    
    fig, axes = plt.subplots(1, len(op_list), figsize=(14,3))

    for idx, op in enumerate(op_list):
        
        e_op = expect(op, states)
        v_op = variance(op, states)

        axes[idx].fill_between(tlist, e_op - np.sqrt(v_op), e_op + np.sqrt(v_op), color="green", alpha=0.5);
        axes[idx].plot(tlist, e_op, label="expectation")
        axes[idx].set_xlabel('Time')
        axes[idx].set_title(op_title[idx])

    return fig, axes
    
    
from base64 import b64encode

def display_embedded_video(filename):
    video = open(filename, "rb").read()
    video_encoded = b64encode(video).decode("ascii")
    video_tag = '<video controls alt="test" src="data:video/x-m4v;base64,{0}">'.format(video_encoded)
    return HTML(video_tag)
    
psi0 = coherent(N, 2.0)
result = mesolve(H, psi0, tlist, c_ops, [])
plot_expect_with_variance(N, [n, x, p], [r'$n$', r'$x$', r'$p$'], result.states);


#fig, axes = plt.subplots(1, 2, figsize=(10,5))

#def update(n):
#    axes[0].cla()
#    plot_wigner_fock_distribution(result.states[n], fig=fig, axes=axes)
#
#anim = animation.FuncAnimation(fig, update, frames=len(result.states), blit=True)
#
#anim.save('/tmp/animation-coherent-state.mp4', fps=20, writer="avconv", codec="libx264")
#
#plt.close(fig)
#display_embedded_video("/tmp/animation-coherent-state.mp4")


#Squeezed vacuum
psi0 = squeeze(N, 1.0) * basis(N, 0)
result = mesolve(H, psi0, tlist, c_ops, [])
plot_expect_with_variance(N, [n, x, p], [r'$n$', r'$x$', r'$p$'], result.states);



#Squeezed coherent state
psi0 = displace(N, 2) * squeeze(N, 1.0) * basis(N, 0)  # first squeeze vacuum and then displace
result = mesolve(H, psi0, tlist, c_ops, [])
plot_expect_with_variance(N, [n, x, p], [r'$n$', r'$x$', r'$p$'], result.states);