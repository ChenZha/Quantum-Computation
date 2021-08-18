# This file is generated automatically by QuTiP.
# (C) 2011 and later, P. D. Nation & J. R. Johansson

import numpy as np
cimport numpy as np
cimport cython
from qutip.cy.spmatfuncs cimport spmvpy
from qutip.cy.interpolate cimport interp, zinterp
from qutip.cy.math cimport erf
cdef double pi = 3.14159265358979323

include '/home/chen/anaconda3/lib/python3.6/site-packages/qutip/cy/complex_math.pxi'

ctypedef np.complex128_t CTYPE_t
ctypedef np.float64_t DTYPE_t


@cython.boundscheck(False)
@cython.wraparound(False)
def cy_td_ode_rhs(
        double t,
        np.ndarray[CTYPE_t, ndim=1] vec,
        np.ndarray[CTYPE_t, ndim=1] data0,np.ndarray[int, ndim=1] idx0,np.ndarray[int, ndim=1] ptr0,
        np.ndarray[CTYPE_t, ndim=1] data1,np.ndarray[int, ndim=1] idx1,np.ndarray[int, ndim=1] ptr1,
        np.ndarray[CTYPE_t, ndim=1] data2,np.ndarray[int, ndim=1] idx2,np.ndarray[int, ndim=1] ptr2,
        np.ndarray[CTYPE_t, ndim=1] data3,np.ndarray[int, ndim=1] idx3,np.ndarray[int, ndim=1] ptr3,
        np.ndarray[CTYPE_t, ndim=1] data4,np.ndarray[int, ndim=1] idx4,np.ndarray[int, ndim=1] ptr4,
        int width0_0,
        float delta0_0):
    
    cdef Py_ssize_t row
    cdef int num_rows = len(vec)
    cdef np.ndarray[CTYPE_t, ndim=1] out = np.zeros((num_rows),dtype=np.complex)
     
    spmvpy(data0, idx0, ptr0, vec, 1.0, out)
    spmvpy(data1, idx1, ptr1, vec, (delta0_0*np.exp(-(t-50-0)**2/2.0/width0_0**2))*(0<t<=100), out)
    spmvpy(data2, idx2, ptr2, vec, 0*(0<t<=100), out)
    spmvpy(data3, idx3, ptr3, vec, 0*(0<t<=100), out)
    spmvpy(data4, idx4, ptr4, vec, 0*(0<t<=100), out)
    return out
