import matplotlib.pyplot as plt
import time
import numpy as np

from qutip import *
from qutip.control import *



T = 1
times = np.linspace(0, T, 100)

theta, phi = np.random.rand(2)


# target unitary transformation (random single qubit rotation)
U = rz(phi) * rx(theta); 



R = 150
H_ops = [sigmax(), sigmay(), sigmaz()]

H_labels = [r'$u_{x}$',
            r'$u_{y}$',
            r'$u_{z}$',
        ]


H0 = 0 * np.pi * sigmaz()


from qutip.control.grape import plot_grape_control_fields, _overlap
from qutip.control.cy_grape import cy_overlap
from qutip.control.grape import cy_grape_unitary, grape_unitary_adaptive

from scipy.interpolate import interp1d
from qutip.ui.progressbar import TextProgressBar

u0 = np.array([np.random.rand(len(times)) * 2 * np.pi * 0.005 for _ in range(len(H_ops))])

u0 = [np.convolve(np.ones(10)/10, u0[idx,:], mode='same') for idx in range(len(H_ops))]


result = cy_grape_unitary(U, H0, H_ops, R, times, u_start=u0, eps=2*np.pi/T, phase_sensitive=False,
                          progress_bar=TextProgressBar())

plot_grape_control_fields(times, result.u[:,:,:] / (2 * np.pi), H_labels, uniform_axes=True);

