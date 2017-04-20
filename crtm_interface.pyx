import numpy as np
from numpy cimport ndarray 

cdef extern int get_strlen(int *strlen);
cdef extern int init_crtm(int *nchanl, char *isis, int *iload_cloudcoeffs, int *iload_aerosolcoeffs, char *crtm_coeffs_path, int *ichannel_info);
cdef extern int destroy_channelinfo(int *ichannel_info);
cdef extern int print_channelinfo(int *ichannel_info);
cdef extern int set_n_channels(int *ichannel_info, int *n);
cdef extern int get_n_channels(int *ichannel_info, int *n);
cdef extern int set_sensor_index(int *ichannel_info, int *n);
cdef extern int get_sensor_index(int *ichannel_info, int *n);
cdef extern int set_sensor_type(int *ichannel_info, int *n);
cdef extern int get_sensor_type(int *ichannel_info, int *n);
cdef extern int set_wmo_satellite_id(int *ichannel_info, int *n);
cdef extern int get_wmo_satellite_id(int *ichannel_info, int *n);
cdef extern int set_wmo_sensor_id(int *ichannel_info, int *n);
cdef extern int get_wmo_sensor_id(int *ichannel_info, int *n);
cdef extern int get_sensor_id(int *ih, char *name);
cdef extern int set_sensor_id(int *ih, char *name);
cdef extern int get_sensor_channel(int *ichannel_info, int *value, int *nchanl);
cdef extern int set_sensor_channel(int *icahnnel_info, int *value, int *nchanl);
cdef extern int get_channel_index(int *ichannel_info, int *value, int *nchanl);
cdef extern int set_channel_index(int *icahnnel_info, int *value, int *nchanl);
cdef extern int get_process_channel(int *ichannel_info, int *value, int *nchanl);
cdef extern int set_process_channel(int *icahnnel_info, int *value, int *nchanl);

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
    property Sensor_Type:
        """get and set Sensor_Type member of derived type"""
        def __get__(self):
            cdef int i
            get_sensor_type(<int *>self.ptr.data, &i)
            return i
        def __set__(self,int value):
            set_sensor_type(<int *>self.ptr.data, &value)
    property WMO_Satellite_ID:
        """get and set WMO_Satellite_ID member of derived type"""
        def __get__(self):
            cdef int i
            get_wmo_satellite_id(<int *>self.ptr.data, &i)
            return i
        def __set__(self,int value):
            set_wmo_satellite_id(<int *>self.ptr.data, &value)
    property WMO_Sensor_ID:
        """get and set WMO_Sensor_ID member of derived type"""
        def __get__(self):
            cdef int i
            get_wmo_sensor_id(<int *>self.ptr.data, &i)
            return i
        def __set__(self,int value):
            set_wmo_sensor_id(<int *>self.ptr.data, &value)
    property Sensor_ID:
        """get and set Sensor_ID member of derived type"""
        def __get__(self):
            cdef char name[CRTM_STRLEN+1] # null char will be added
            get_sensor_id(<int *>self.ptr.data, name)
            return name
        def __set__(self,char *value):
            set_sensor_id(<int *>self.ptr.data, value)
    property Sensor_Index:
        """get and set Sensor_Index member of derived type"""
        def __get__(self):
            cdef int i
            get_sensor_index(<int *>self.ptr.data, &i)
            return i
        def __set__(self,int value):
            set_sensor_index(<int *>self.ptr.data, &value)
    property Sensor_Channel:
        """get and set Sensor_Channel member of derived type"""
        def __get__(self):
            cdef ndarray iarr = np.empty(self.nchanl,np.intc)
            get_sensor_channel(<int *>self.ptr.data, <int *>iarr.data, &self.nchanl)
            return iarr
        def __set__(self,ndarray value):
            value = value.astype(np.intc)
            if value.size != self.nchanl:
                raise ValueError('cannot change the size of Sensor_Channel member')
            set_sensor_channel(<int *>self.ptr.data, <int *>value.data, &self.nchanl)
    property Process_Channel:
        """get and set Process_Channel member of derived type"""
        def __get__(self):
            cdef ndarray iarr = np.empty(self.nchanl,np.intc)
            get_process_channel(<int *>self.ptr.data, <int *>iarr.data, &self.nchanl)
            return iarr.astype(np.bool)
        def __set__(self,ndarray value):
            value = value.astype(np.intc)
            if value.size != self.nchanl:
                raise ValueError('cannot change the size of Process_Channel member')
            set_process_channel(<int *>self.ptr.data, <int *>value.data, &self.nchanl)
    property Channel_Index:
        """get and set Channel_Index member of derived type"""
        def __get__(self):
            cdef ndarray iarr = np.empty(self.nchanl,np.intc)
            get_channel_index(<int *>self.ptr.data, <int *>iarr.data, &self.nchanl)
            return iarr
        def __set__(self,ndarray value):
            value = value.astype(np.intc)
            if value.size != self.nchanl:
                raise ValueError('cannot change the size of Channel_Index member')
            set_channel_index(<int *>self.ptr.data, <int *>value.data, &self.nchanl)
    def __dealloc__(self):
        destroy_channelinfo(<int *>self.ptr.data)
