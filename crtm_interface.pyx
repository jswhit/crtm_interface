import numpy as np
from numpy cimport ndarray 

cdef extern int get_strlen(int *strlen);
cdef extern int init_crtm(int *nchanl, char *isis, int *iload_cloudcoeffs, int *iload_aerosolcoeffs, char *crtm_coeffs_path, int *ichannel_info);
cdef extern int print_channelinfo(int *ichannel_info);
cdef extern int set_n_channels(int *ichannel_info, int *n_Channels);
cdef extern int get_n_channels(int *ichannel_info, int *n_Channels);
cdef extern int get_sensor_id(int *ih, char *name);
cdef extern int set_sensor_id(int *ih, char *name);

cdef extern from 'crtm_interface.h':
   enum: CRTM_STRLEN

#  When interfacing between Fortran and C, you will have to pass pointers to all
#  the variables you send to the Fortran function as arguments. Passing a variable
#  directly will probably crash Python.

def crtm_strlen():
    cdef int strlen
    get_strlen(&strlen)
    return strlen

_crtm_strlen = crtm_strlen()
if _crtm_strlen != CRTM_STRLEN:
    raise ValueError('inconsistent value of CRTM_STRLEN')

cdef class Channel_Info:
    cdef ndarray ptr
    cdef int nchanl
    def __init__(self, int nchanl, char *isis, int iload_cloudcoeff, int iload_aerosolcoeff, char *crtm_coeffs_path):
        cdef ndarray ichannel_info = np.empty(12, np.intc)
        self.nchanl = nchanl
        init_crtm(&nchanl, isis, &iload_cloudcoeff, &iload_aerosolcoeff, crtm_coeffs_path, <int *>ichannel_info.data)
        self.ptr = ichannel_info
    def show(self):
        print_channelinfo(<int *>self.ptr.data)
    property n_Channels:
        """get and set n_Channels member of derived type"""
        def __get__(self):
            cdef int i
            get_n_channels(<int *>self.ptr.data, &i)
            return i
        def __set__(self,int value):
            set_n_channels(<int *>self.ptr.data, &value)
    property Sensor_ID:
        """get and set Sensor_ID member of derived type"""
        def __get__(self):
            cdef char name[CRTM_STRLEN+1] # null char will be added
            get_sensor_id(<int *>self.ptr.data, name)
            return name
        def __set__(self,char *value):
            set_sensor_id(<int *>self.ptr.data, value)
    #property iarr:
    #    """get and set iarr member of derived type"""
    #    def __get__(self):
    #        cdef ndarray iarr = np.empty(5,np.intc)
    #        get_iarr(<int *>self.ptr.data, <int *>iarr.data, &self.iarr_len)
    #        return iarr
    #    def __set__(self,ndarray value):
    #        value = value.astype(np.intc)
    #        if value.size != self.iarr_len:
    #            raise ValueError('cannot change the size of iarr member')
    #        set_iarr(<int *>self.ptr.data, <int *>value.data, &self.iarr_len)
    #def __dealloc__(self):
    #    destroy(<int *>self.ptr.data)
