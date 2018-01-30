# -*- coding: utf-8 -*-
"""
Created on Wed Jan 18 22:10:52 2017

@author: Chen
"""
from qutip import *
import numpy as np
import matplotlib.pyplot as plt 
from qutip import gates
from scipy.special import sici

#==============================================================================
#parameters
N = 10

wc = 5.0 * 2 * pi
w1 = 3.0 * 2 * pi
w2 = 2.0 * 2 * pi

g1 = 0.01 * 2 * pi
g2 = 0.0125 * 2 * pi

tlist = np.linspace(0, 100, 500)

width = 0.5

# resonant SQRT iSWAP gate
T0_1 = 20
T_gate_1 = (1*pi)/(4 * g1)

# resonant iSWAP gate
T0_2 = 60
T_gate_2 = (2*pi)/(4 * g2)
#==============================================================================

#==============================================================================
# cavity operators
a = tensor(destroy(N), qeye(2), qeye(2))
n = a.dag() * a

# operators for qubit 1
sm1 = tensor(qeye(N), destroy(2), qeye(2))
sz1 = tensor(qeye(N), sigmaz(), qeye(2))
n1 = sm1.dag() * sm1

# oeprators for qubit 2
sm2 = tensor(qeye(N), qeye(2), destroy(2))
sz2 = tensor(qeye(N), qeye(2), sigmaz())
n2 = sm2.dag() * sm2

# Hamiltonian using QuTiP
Hc = a.dag() * a
H1 = - 0.5 * sz1
H2 = - 0.5 * sz2
Hc1 = g1 * (a.dag() * sm1 + a * sm1.dag())
Hc2 = g2 * (a.dag() * sm2 + a * sm2.dag())

H = wc * Hc + w1 * H1 + w2 * H2 + Hc1 + Hc2 

# initial state: start with one of the qubits in its excited state
psi0 = tensor(basis(N,0),basis(2,1),basis(2,0))
#==============================================================================


def step_t(w1, w2, t0, width, t):#有overshoot
    """
    Step function that goes from w1 to w2 at time t0
    as a function of t, with finite rise time and 
    and overshoot defined by the parameter width.
    """

    return w1 + (w2-w1) * (0.5 + sici((t-t0)/width)[0]/(pi))


def wc_t(t, args=None):
    return wc

def w1_t(t, args=None):
    return w1 + step_t(0.0, wc-w1, T0_1, width, t) - step_t(0.0, wc-w1, T0_1+T_gate_1, width, t)

def w2_t(t, args=None):
    return w2 + step_t(0.0, wc-w2, T0_2, width, t) - step_t(0.0, wc-w2, T0_2+T_gate_2, width, t)


H_t = [[Hc, wc_t], [H1, w1_t], [H2, w2_t], Hc1+Hc2]


#fig, axes = plt.subplots(1, 3, figsize=(8,2))
#axes[0].plot(tlist, [w1_t(t) for t in tlist], 'k')
#axes[1].plot(tlist, [step_t(0.0, wc-w1, T0_1, width, t) for t in tlist], 'k')
#axes[2].plot(tlist, [-step_t(0.0, wc-w1, T0_1+T_gate_1, width, t) for t in tlist], 'k')
#
#fig.tight_layout()


#==============================================================================

"""
Using tunable resonator and fixed-frequency qubits
"""
#def wc_t(t, args=None):
#    return wc - step_t(0.0, wc-w1, T0_1, width, t) + step_t(0.0, wc-w1, T0_1+T_gate_1, width, t) \
#              - step_t(0.0, wc-w2, T0_2, width, t) + step_t(0.0, wc-w2, T0_2+T_gate_2, width, t)
#
#H_t = [[Hc, wc_t], H1 * w1 + H2 * w2 + Hc1+Hc2]
#==============================================================================


#==============================================================================
# high-Q resonator but dissipative qubits
kappa  = 0.00001
gamma1 = 0.005
gamma2 = 0.005

c_ops = [sqrt(kappa) * a, sqrt(gamma1) * sm1, sqrt(gamma2) * sm2]
#==============================================================================
res = mesolve(H_t, psi0, tlist, c_ops, [])

#==============================================================================
fig, axes = plt.subplots(2, 1, sharex=True, figsize=(12,8))
#p = Pool(4)
#A = p.map([wc_t,w1_t,w2_t], tlist)
axes[0].plot(tlist, array(list(map(wc_t, tlist))) / (2*pi), 'r', linewidth=2, label="cavity")
axes[0].plot(tlist, array(list(map(w1_t, tlist))) / (2*pi), 'b', linewidth=2, label="qubit 1")
axes[0].plot(tlist, array(list(map(w2_t, tlist))) / (2*pi), 'g', linewidth=2, label="qubit 2")
axes[0].set_ylim(1, 6)
axes[0].set_ylabel("Energy (GHz)", fontsize=16)
axes[0].legend()
#p.close()
#p.join()
axes[1].plot(tlist, real(expect(n, res.states)), 'r', linewidth=2, label="cavity")
axes[1].plot(tlist, real(expect(n1, res.states)), 'b', linewidth=2, label="qubit 1")
axes[1].plot(tlist, real(expect(n2, res.states)), 'g', linewidth=2, label="qubit 2")
axes[1].set_ylim(0, 1)

axes[1].set_xlabel("Time (ns)", fontsize=16)
axes[1].set_ylabel("Occupation probability", fontsize=16)
axes[1].legend()

fig.tight_layout()

#==============================================================================

rho_final = res.states[-1]
rho_qubits = ptrace(rho_final, [1,2])
rho_qubits_ideal = ket2dm(tensor(phasegate(0), phasegate(-pi/2)) * sqrtiswap() * tensor(basis(2,1), basis(2,0)))

print "fidelity=%f"%fidelity(rho_qubits, rho_qubits_ideal)
print "concurrence(rho_qubits)=%f"%concurrence(rho_qubits)