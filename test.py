import crtm_interface
isis='amsua_n15'
obstype='amsua'
crtm_coeffs_path = '/scratch3/BMC/gsienkf/whitaker/gsi/EXP-enkflinhx/fix/crtm-2.2.3/'
crtm_interface.crtm_initialize(1,2,3,7,isis,obstype,crtm_coeffs_path)
