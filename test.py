import crtm_interface
import numpy as np
isis='amsua_n15'
#crtm_coeffs_path = '/scratch3/BMC/gsienkf/whitaker/gsi/EXP-enkflinhx/fix/crtm-2.2.3/'
crtm_coeffs_path = '/Users/jswhit/python/crtm_interface/crtm_coefficients/'
nchanl = 15
iload_cloudcoeffs=1
iload_aerosolcoeffs=1
channel_info = crtm_interface.Channel_Info(nchanl,isis,iload_cloudcoeffs,iload_aerosolcoeffs,crtm_coeffs_path)
print 
channel_info.show() # fortran side
print
print channel_info # python side
