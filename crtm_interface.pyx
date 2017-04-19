import numpy as np
from numpy cimport ndarray 

cdef extern int get_strlen(int *strlen);
cdef extern int init_crtm(int *nchanl, char *isis, int *iload_cloudcoeffs, int *iload_aerosolcoeffs, char *crtm_coeffs_path, int *ichannel_info);
cdef extern int print_channelinfo(int *ichannel_info);

#  When interfacing between Fortran and C, you will have to pass pointers to all
#  the variables you send to the Fortran function as arguments. Passing a variable
#  directly will probably crash Python.

def crtm_strlen():
    cdef int strlen
    get_strlen(&strlen)
    return strlen

_strlen = crtm_strlen()

def crtm_initialize(int nchanl, char *isis, int iload_cloudcoeff, int iload_aerosolcoeff, char *crtm_coeffs_path):
    cdef ndarray ichannel_info = np.empty(12, np.intc)
    init_crtm(&nchanl, isis, &iload_cloudcoeff, &iload_aerosolcoeff, crtm_coeffs_path, <int *>ichannel_info.data)
    return ichannel_info

def crtm_channelinfo_print(ndarray ichannel_info):
    print_channelinfo(<int *>ichannel_info.data)
