# This file is generated automatically by QuTiP.
# (C) Paul D. Nation & J. R. Johansson

from numpy import *
cimport libc.math as cmath

import numpy as np
cimport numpy as np
cimport cython
from qutip.cy.spmatfuncs import spmv_csr, spmvpy

ctypedef np.complex128_t CTYPE_t
ctypedef np.float64_t DTYPE_t



@cython.boundscheck(False)
@cython.wraparound(False)

def cy_td_ode_rhs(double t, np.ndarray[CTYPE_t, ndim=1] vec, np.ndarray[CTYPE_t, ndim=1] data0, np.ndarray[int, ndim=1] idx0, np.ndarray[int, ndim=1] ptr0, np.ndarray[CTYPE_t, ndim=1] data1, np.ndarray[int, ndim=1] idx1, np.ndarray[int, ndim=1] ptr1, np.ndarray[CTYPE_t, ndim=1] data2, np.ndarray[int, ndim=1] idx2, np.ndarray[int, ndim=1] ptr2, np.ndarray[CTYPE_t, ndim=1] data3, np.ndarray[int, ndim=1] idx3, np.ndarray[int, ndim=1] ptr3, np.ndarray[CTYPE_t, ndim=1] data4, np.ndarray[int, ndim=1] idx4, np.ndarray[int, ndim=1] ptr4, np.ndarray[CTYPE_t, ndim=1] data5, np.ndarray[int, ndim=1] idx5, np.ndarray[int, ndim=1] ptr5, np.ndarray[CTYPE_t, ndim=1] data6, np.ndarray[int, ndim=1] idx6, np.ndarray[int, ndim=1] ptr6, np.ndarray[CTYPE_t, ndim=1] data7, np.ndarray[int, ndim=1] idx7, np.ndarray[int, ndim=1] ptr7, np.ndarray[CTYPE_t, ndim=1] data8, np.ndarray[int, ndim=1] idx8, np.ndarray[int, ndim=1] ptr8, np.ndarray[CTYPE_t, ndim=1] data9, np.ndarray[int, ndim=1] idx9, np.ndarray[int, ndim=1] ptr9, np.ndarray[CTYPE_t, ndim=1] data10, np.ndarray[int, ndim=1] idx10, np.ndarray[int, ndim=1] ptr10, np.ndarray[CTYPE_t, ndim=1] data11, np.ndarray[int, ndim=1] idx11, np.ndarray[int, ndim=1] ptr11, np.ndarray[CTYPE_t, ndim=1] data12, np.ndarray[int, ndim=1] idx12, np.ndarray[int, ndim=1] ptr12, np.ndarray[CTYPE_t, ndim=1] data13, np.ndarray[int, ndim=1] idx13, np.ndarray[int, ndim=1] ptr13, np.ndarray[CTYPE_t, ndim=1] data14, np.ndarray[int, ndim=1] idx14, np.ndarray[int, ndim=1] ptr14, np.ndarray[CTYPE_t, ndim=1] data15, np.ndarray[int, ndim=1] idx15, np.ndarray[int, ndim=1] ptr15, np.ndarray[CTYPE_t, ndim=1] data16, np.ndarray[int, ndim=1] idx16, np.ndarray[int, ndim=1] ptr16, np.float64_t f0, np.float64_t f1, np.float_t delta2, np.float64_t f4, np.float_t width2, np.int_t width0, np.int_t width1, np.float_t Omega4, np.int_t t21, np.int_t width4, np.int_t t20, np.float64_t w_t2, np.float64_t w_t3, np.float64_t w_t0, np.float64_t w_t1, np.float_t Omega1, np.float_t Omega0, np.float64_t w_t4):
    
    cdef Py_ssize_t row
    cdef int num_rows = len(vec)
    cdef np.ndarray[CTYPE_t, ndim=1] out = np.zeros((num_rows),dtype=np.complex)
     
    spmvpy(data0, idx0, ptr0, vec, 1.0, out)
    spmvpy(data1, idx1, ptr1, vec, 1.0, out)
    spmvpy(data2, idx2, ptr2, vec, 1.0, out)
    spmvpy(data3, idx3, ptr3, vec, 1.0, out)
    spmvpy(data4, idx4, ptr4, vec, 1.0, out)
    spmvpy(data5, idx5, ptr5, vec, 1.0, out)
    spmvpy(data6, idx6, ptr6, vec, 1.0, out)
    spmvpy(data7, idx7, ptr7, vec, w_t0, out)
    spmvpy(data8, idx8, ptr8, vec, w_t1, out)
    spmvpy(data9, idx9, ptr9, vec, w_t2+delta2/(1 + np.exp(-(t-t20)/width2)) -delta2/(1 + np.exp(-(t-t21)/width2)) , out)
    spmvpy(data10, idx10, ptr10, vec, w_t3, out)
    spmvpy(data11, idx11, ptr11, vec, w_t4, out)
    spmvpy(data12, idx12, ptr12, vec, Omega0*np.exp(-(t-20)**2/2.0/width0**2)*np.cos(t*f0), out)
    spmvpy(data13, idx13, ptr13, vec, Omega1*np.exp(-(t-20)**2/2.0/width1**2)*np.cos(t*f1+np.pi/2), out)
    spmvpy(data14, idx14, ptr14, vec, 0, out)
    spmvpy(data15, idx15, ptr15, vec, 0, out)
    spmvpy(data16, idx16, ptr16, vec, Omega4*np.exp(-(t-20)**2/2.0/width4**2)*np.cos(t*f4), out)
    return out
