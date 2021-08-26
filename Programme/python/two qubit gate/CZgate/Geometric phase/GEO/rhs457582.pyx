# This file is generated automatically by QuTiP.
# (C) 2011 and later, QuSTaR

import numpy as np
cimport numpy as np
cimport cython

from qutip.cy.spmatfuncs cimport spmvpy
from qutip.cy.interpolate cimport interp, zinterp
from qutip.cy.math cimport erf
cdef double pi = 3.14159265358979323

include '/home/zhachen/anaconda3/envs/qutip-env/lib/python3.6/site-packages/qutip/cy/complex_math.pxi'



@cython.boundscheck(False)
@cython.wraparound(False)
def cy_td_ode_rhs(
        double t,
        complex[::1] vec,
        complex[::1] data0,int[::1] idx0,int[::1] ptr0,
        complex[::1] data1,int[::1] idx1,int[::1] ptr1,
        float wd,
        float omega,
        float width):
    
    cdef size_t row
    cdef unsigned int num_rows = vec.shape[0]
    cdef np.ndarray[complex, ndim=1, mode='c'] out = np.zeros((num_rows),dtype=np.complex)
     
    spmvpy(&data0[0], &idx0[0], &ptr0[0], &vec[0], 1.0, &out[0], num_rows)
    spmvpy(&data1[0], &idx1[0], &ptr1[0], &vec[0], (omega/(1+np.exp(-(t-50)/width))-omega/(1+np.exp(-(t-300)/width)))*(1-np.cos(wd*t))*(0<t<=350), &out[0], num_rows)
    return out
