import crtm_interface
import numpy as np
isis='amsua_n15'
#crtm_coeffs_path = '/scratch3/BMC/gsienkf/whitaker/gsi/EXP-enkflinhx/fix/crtm-2.2.3/'
crtm_coeffs_path = '/Users/jswhit/python/crtm_interface/crtm_coefficients/'
nchanl = 15
iload_cloudcoeffs=1
iload_aerosolcoeffs=1
channel_info = crtm_interface.Channel_Info(nchanl,isis,iload_cloudcoeffs,iload_aerosolcoeffs,crtm_coeffs_path)
channel_info.show()
print ' ChannelInfo OBJECT (python)'
print '   n_Channels       :',channel_info.n_Channels
print '   Sensor_ID        :',channel_info.Sensor_ID
print '   Senssor_Type     :',channel_info.Sensor_Type
print '   WMO_Satellite_ID :',channel_info.WMO_Satellite_ID
print '   WMO_Sensor_ID    :',channel_info.WMO_Sensor_ID
print '   Sensor_Index     :',channel_info.Sensor_Index
print '   Channel#     Index     Process?'
for n in range(channel_info.n_Channels):
    print '        %s           %s        %s' % (channel_info.Sensor_Channel[n],\
    channel_info.Channel_Index[n],channel_info.Process_Channel[n])
