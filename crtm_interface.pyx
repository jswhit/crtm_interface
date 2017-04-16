cimport numpy as cnp
import numpy as np
from libc.stdlib cimport malloc, free

cdef extern from "src/pycrtm_interface.h":
    void get_strlen(int *strlen);
    void init_crtm(int *init_pass, int *mype_diaghdr, int *mype, int *nchanl, char *isis, int *nchar_isis, int *iload_cloudcoeffs, int *iload_aerosolcoeffs, char *crtm_coeffs_path, int *nchar_path, int *n_channels, char *sensor_id, int *sensor_type, int *wmo_sat_id, int *wmo_sensor_id, void*process_channel, void*sensor_channel,void *channel_index);

#  When interfacing between Fortran and C, you will have to pass pointers to all
#  the variables you send to the Fortran function as arguments. Passing a variable
#  directly will probably crash Python.

def crtm_strlen():
    cdef int strlen
    get_strlen(&strlen)
    return strlen

_strlen = crtm_strlen()

def crtm_initialize(int init_pass, int mype_diaghdr, int mype, int nchanl, char *isis, int iload_cloudcoeff, int iload_aerosolcoeff, char *crtm_coeffs_path):
    cdef int nchar_isis, nchar_path
    cdef int n_channels, sensor_type, wmo_sat_id, wmo_sensor_id
    cdef char *sensor_id
    cdef void *process_channel
    cdef void *sensor_channel
    cdef void *channel_index
    sensor_id = <char *>malloc(sizeof(char) * _strlen)
    print 'in c'
    print init_pass,mype_diaghdr,mype,nchanl
    print isis
    print crtm_coeffs_path
    nchar_isis = len(isis)
    nchar_path = len(crtm_coeffs_path)
    print nchar_isis, nchar_path
    init_crtm(&init_pass, &mype_diaghdr, &mype, &nchanl, isis, &nchar_isis, &iload_cloudcoeff, &iload_aerosolcoeff, crtm_coeffs_path, &nchar_path, &n_channels, sensor_id, &sensor_type, &wmo_sat_id, &wmo_sensor_id, process_channel, sensor_channel, channel_index)
    return sensor_id,sensor_type,wmo_sat_id,wmo_sensor_id
