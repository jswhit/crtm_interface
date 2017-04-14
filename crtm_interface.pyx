cimport numpy as cnp
import numpy as np

cdef extern from "src/pycrtm_interface.h":
    void init_crtm(int *init_pass, int *mype_diaghdr, int *mype, int *nchanl, char *isis, int *nchar_isis, char *obstype, int *nchar_obstype, char *crtm_coeffs_path, int *nchar_path)

#  When interfacing between Fortran and C, you will have to pass pointers to all
#  the variables you send to the Fortran function as arguments. Passing a variable
#  directly will probably crash Python.

def crtm_initialize(int init_pass, int mype_diaghdr, int mype, int nchanl, char *isis, char *obstype, char *crtm_coeffs_path):
    cdef int nchar_isis, nchar_obstype, nchar_path
    print 'in c'
    print init_pass,mype_diaghdr,mype,nchanl
    print isis
    print obstype
    nchar_isis = len(isis)
    nchar_obstype = len(obstype)
    nchar_path = len(crtm_coeffs_path)
    print nchar_isis, nchar_obstype, nchar_path
    init_crtm(&init_pass, &mype_diaghdr, &mype, &nchanl, isis, &nchar_isis, obstype, &nchar_obstype, crtm_coeffs_path, &nchar_path)
