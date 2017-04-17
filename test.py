import crtm_interface
isis='amsua_n15'
crtm_coeffs_path = '/scratch3/BMC/gsienkf/whitaker/gsi/EXP-enkflinhx/fix/crtm-2.2.3/'
nchanl = 15
iload_cloudcoeffs=1
iload_aerosolcoeffs=1
sensor_type,wmo_satid,wmo_sensor_id,process_channel,sensor_channel,channel_index = crtm_interface.crtm_initialize(nchanl,isis,iload_cloudcoeffs,iload_aerosolcoeffs,crtm_coeffs_path)
print 'sensor_type,wmo_satid,wmo_sensor_id',sensor_type,wmo_satid,wmo_sensor_id
print 'process_channel',process_channel
print 'sensor_channel',sensor_channel
print 'channel_index',channel_index
print 'crtm strlen:',crtm_interface.crtm_strlen()
