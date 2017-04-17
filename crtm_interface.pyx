import numpy as np
from numpy cimport ndarray as ndarr
from libc.stdlib cimport malloc, free

cdef extern from "src/pycrtm_interface.h":
    int get_strlen(int *strlen);
    int init_crtm(int *nchanl, char *isis, int *nchar_isis, int *iload_cloudcoeffs, int *iload_aerosolcoeffs, char *crtm_coeffs_path, int *nchar_path, int *sensor_type, int *wmo_sat_id, int *wmo_sensor_id, char *process_channel, int *sensor_channel, int *channel_index);

#  When interfacing between Fortran and C, you will have to pass pointers to all
#  the variables you send to the Fortran function as arguments. Passing a variable
#  directly will probably crash Python.

def crtm_strlen():
    cdef int strlen
    get_strlen(&strlen)
    return strlen

_strlen = crtm_strlen()

def crtm_initialize(int nchanl, char *isis, int iload_cloudcoeff, int iload_aerosolcoeff, char *crtm_coeffs_path):
    cdef int nchar_isis, nchar_path
    cdef int sensor_type, wmo_sat_id, wmo_sensor_id
    cdef ndarr process_channel = np.empty(nchanl,np.bool_)
    cdef ndarr sensor_channel = np.empty(nchanl,np.intc)
    cdef ndarr channel_index = np.empty(nchanl,np.intc)
    print 'in c'
    print isis
    print crtm_coeffs_path
    nchar_isis = len(isis)
    nchar_path = len(crtm_coeffs_path)
    print nchar_isis, nchar_path
    init_crtm(&nchanl, isis, &nchar_isis, &iload_cloudcoeff, &iload_aerosolcoeff, crtm_coeffs_path, &nchar_path, &sensor_type, &wmo_sat_id, &wmo_sensor_id, <char *>process_channel.data, <int *>sensor_channel.data, <int *>channel_index.data)
    print process_channel
    print sensor_channel
    print channel_index
    return sensor_type,wmo_sat_id,wmo_sensor_id
