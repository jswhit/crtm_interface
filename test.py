import crtm_interface
isis='amsua_n15'
crtm_coeffs_path = '/scratch3/BMC/gsienkf/whitaker/gsi/EXP-enkflinhx/fix/crtm-2.2.3/'
nchanl = 15
iload_cloudcoeffs=1
iload_aerosolcoeffs=1
channel_info = crtm_interface.crtm_initialize(nchanl,isis,iload_cloudcoeffs,iload_aerosolcoeffs,crtm_coeffs_path)
print 'sensor_id:',channel_info.Sensor_ID
print 'sensor_type,wmo_satid,wmo_sensor_id=',channel_info.Sensor_Type,channel_info.WMO_Satellite_ID,channel_info.WMO_Sensor_ID
print 'process_channel=',channel_info.Process_Channel
print 'sensor_channel=',channel_info.Sensor_Channel
print 'channel_index=',channel_info.Channel_Index
print 'crtm strlen=',crtm_interface.crtm_strlen()
