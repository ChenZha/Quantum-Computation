# This file is generated automatically by QuTiP.
# (C) 2011 and later, QuSTaR

import numpy as np
cimport numpy as np
cimport cython
np.import_array()
cdef extern from "numpy/arrayobject.h" nogil:
    void PyDataMem_NEW_ZEROED(size_t size, size_t elsize)
    void PyArray_ENABLEFLAGS(np.ndarray arr, int flags)

from qutip.cy.spmatfuncs cimport spmvpy
from qutip.cy.interpolate cimport interp, zinterp
from qutip.cy.math cimport erf
cdef double pi = 3.14159265358979323

include 'C:/Users/qmeas/AppData/Local/conda/conda/envs/qutip-env/lib/site-packages/qutip/cy/complex_math.pxi'



@cython.cdivision(True)
@cython.boundscheck(False)
@cython.wraparound(False)
def cy_td_ode_rhs(
        double t,
        complex[::1] vec,
        complex[::1] data0,int[::1] idx0,int[::1] ptr0,
        complex[::1] data1,int[::1] idx1,int[::1] ptr1,
        complex[::1] data2,int[::1] idx2,int[::1] ptr2,
        complex[::1] data3,int[::1] idx3,int[::1] ptr3,
        complex[::1] data4,int[::1] idx4,int[::1] ptr4,
        float T_P,
        int T_copies,
        int t_rise):
    
    cdef size_t row
    cdef unsigned int num_rows = vec.shape[0]
    cdef double complex * out = <complex *>PyDataMem_NEW_ZEROED(num_rows,sizeof(complex))
     
    spmvpy(&data0[0], &idx0[0], &ptr0[0], &vec[0], 1.0, out, num_rows)
    spmvpy(&data1[0], &idx1[0], &ptr1[0], &vec[0], -1.75929188601/2*(1-np.cos(np.pi/t_rise*t))*(0<=t<=t_rise)+-1.75929188601*(t_rise<t<T_P-t_rise)+-1.75929188601/2*(1+np.cos(np.pi/t_rise*(t-T_P+t_rise)))*(T_P-t_rise<=t<=T_P), out, num_rows)
    spmvpy(&data2[0], &idx2[0], &ptr2[0], &vec[0], -2.70176968209/2*(1-np.cos(np.pi/t_rise*t))*(0<=t<=t_rise)+-2.70176968209*(t_rise<t<T_P-t_rise)+-2.70176968209/2*(1+np.cos(np.pi/t_rise*(t-T_P+t_rise)))*(T_P-t_rise<=t<=T_P), out, num_rows)
    spmvpy(&data3[0], &idx3[0], &ptr3[0], &vec[0], -0.69115038379/2*(1-np.cos(np.pi/t_rise*t))*(0<=t<=t_rise)+-0.69115038379*(t_rise<t<T_P-t_rise)+-0.69115038379/2*(1+np.cos(np.pi/t_rise*(t-T_P+t_rise)))*(T_P-t_rise<=t<=T_P), out, num_rows)
    spmvpy(&data4[0], &idx4[0], &ptr4[0], &vec[0], -1.63362817987/2*(1-np.cos(np.pi/t_rise*t))*(0<=t<=t_rise)+-1.63362817987*(t_rise<t<T_P-t_rise)+-1.63362817987/2*(1+np.cos(np.pi/t_rise*(t-T_P+t_rise)))*(T_P-t_rise<=t<=T_P), out, num_rows)
    cdef np.npy_intp dims = num_rows
    cdef np.ndarray[complex, ndim=1, mode='c'] arr_out = np.PyArray_SimpleNewFromData(1, &dims, np.NPY_COMPLEX128, out)
    PyArray_ENABLEFLAGS(arr_out, np.NPY_OWNDATA)
    return arr_out   

