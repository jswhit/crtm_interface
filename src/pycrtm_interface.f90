module pycrtm_interface

use iso_c_binding, only: c_double, c_int, c_char, c_bool
use kinds, only: r_kind, i_kind
use crtm_module, only: crtm_init, crtm_destroy, crtm_channelinfo_type, success, strlen
implicit none 

contains

subroutine get_strlen(lenstr) bind(c)
  integer(c_int), intent(out) :: lenstr
  lenstr = strlen
end subroutine get_strlen

subroutine init_crtm(nchanl,isis,nchar_isis,iload_cloudcoeff,iload_aerosolcoeff,crtm_coeffs_path,nchar_path,sensor_type,wmo_sat_id,wmo_sensor_id,process_channel,sensor_channel,channel_index) bind(c)
!   input argument list:
!     nchanl - (int) number of channels 
!     isis   - (char*strlen) instrument/sensor character string 
!     iload_cloudcoeff - (int) 1 to load cloud coeffs
!     iload_aerosolcoeff - (int) 1 to load aerosol coeffs
!     crtm_coeffs_path - (char*256) path to CRTM coeffs files
!   output:
!     sensor_type  - (int)
!     wmo_sat_id - (int)
!     wmo_sensor_id - (int)
!     process_channel - (int, dimension(nchanl))
!     sensor_channel - (int, dimension(nchanl))
!     channel_index - (int, dimension(nchanl)) 
! input variables.
  integer(c_int),intent(in) :: &
  nchanl,nchar_isis,nchar_path,&
  iload_cloudcoeff,iload_aerosolcoeff 
  character(c_char), intent(in) :: isis(strlen)
  character(c_char), intent(in) :: crtm_coeffs_path(256)
! output variables
  integer(c_int),intent(out) :: &
  sensor_type,wmo_sat_id,wmo_sensor_id
  integer(c_int),intent(out),dimension(nchanl) :: &
  sensor_channel,channel_index
  integer(c_bool),intent(out),dimension(nchanl) :: process_channel
! local variables.
  character(len=strlen) :: isis_f
  integer(i_kind) :: error_status, n_channels, j
  logical :: ice,Load_AerosolCoeff,Load_CloudCoeff
  character(len=strlen),dimension(1) :: sensorlist
  type(crtm_channelinfo_type),dimension(1) :: channelinfo
  character(len=256) :: crtm_coeffs_path_f
! local parameters
  character(len=*), parameter :: myname_='pycrtm_interface*init_crtm'

  print *,'in fortran'
  Load_CloudCoeff=iload_cloudcoeff
  Load_AerosolCoeff=iload_aerosolcoeff
  print *,Load_CloudCoeff,Load_AerosolCoeff
  print *,iload_cloudcoeff,iload_aerosolcoeff
  call copy_string_ctof(isis,nchar_isis,isis_f)
  call copy_string_ctof(crtm_coeffs_path,nchar_path,crtm_coeffs_path_f)
  print *,trim(isis_f)
  print *,nchar_isis,len(trim(isis_f))
  print *,trim(crtm_coeffs_path_f)
  print *,nchar_path,len(trim(crtm_coeffs_path_f))


! Initialize radiative transfer
  sensorlist(1)=isis_f
  write(6,*)myname_,': crtm_init() on path "'//trim(crtm_coeffs_path_f)//'"'
  error_status = crtm_init(sensorlist,channelinfo,&
     Load_CloudCoeff=Load_CloudCoeff,Load_AerosolCoeff=Load_AerosolCoeff, &
     File_Path = crtm_coeffs_path_f )
  if (error_status /= success) then
     print *,myname_,':  ***ERROR*** crtm_init error_status=',error_status,&
        '   TERMINATE PROGRAM EXECUTION'
     stop
  endif
  print *,'done call crtm_init'
  print *,'n_channels',channelinfo(1)%n_Channels
  n_channels = channelinfo(1)%n_Channels
  if (nchanl /= n_channels) then
     write(6,*)myname_,':  ***WARNING*** mismatch between nchanl=',&
        nchanl,' and n_channels=',n_channels,&
        ' --> CAN NOT PROCESS isis=',isis_f,'   TERMINATE PROGRAM EXECUTION'
     stop
  endif
  print *,'is_allocated',channelinfo(1)%is_Allocated
  if (channelinfo(1)%Sensor_Id .ne. isis_f) then
     write(6,*)myname_,':  ***WARNING*** mismatch between isis= ',&
        ' and sensor_id= ',trim(channelinfo(1)%Sensor_Id),&
        ' --> CAN NOT PROCESS isis=',isis_f,'   TERMINATE PROGRAM EXECUTION'
     stop
  endif
  print *,'sensor_type',channelinfo(1)%Sensor_Type
  sensor_type = channelinfo(1)%Sensor_Type
  print *,'wmo_sat_id',channelinfo(1)%WMO_Satellite_Id
  wmo_sat_id = channelinfo(1)%WMO_Satellite_Id
  print *,'wmo_sensor_id',channelinfo(1)%WMO_Sensor_Id
  wmo_sensor_id = channelinfo(1)%WMO_Sensor_Id
  print *,'process_channel',channelinfo(1)%Process_Channel,size(channelinfo(1)%Process_Channel)
  do j=1,nchanl
   process_channel(j) = channelinfo(1)%Process_Channel(j)
  enddo
  print *,'sensor_channel',channelinfo(1)%Sensor_Channel
  sensor_channel = channelinfo(1)%Sensor_Channel(:)
  print *,'channel_index',channelinfo(1)%Channel_Index
  channel_index = channelinfo(1)%Channel_Index(:)
  error_status = crtm_destroy(channelinfo)
  if (error_status /= success) then
     write(6,*)myname_,':  ***ERROR*** crtm_destroy,error_status=',error_status
  endif
end subroutine init_crtm

subroutine copy_string_ctof(stringc,nstringc,stringf)
  ! utility function to convert c string to fortran string
  character(len=*), intent(inout) :: stringf
  integer(c_int), intent(in) :: nstringc
  character(c_char), intent(in) :: stringc(nstringc)
  integer(i_kind) j
  do j=1,nstringc
     stringf(j:j) = stringc(j)
  end do
  do j=nstringc+1,len(stringf)
     stringf(j:j) = ' '
  enddo
end subroutine copy_string_ctof

subroutine copy_string_ftoc(stringf,nstringc,stringc)
  ! utility function to convert c string to fortran string
  character(len=*), intent(in) :: stringf
  integer(c_int), intent(in) :: nstringc
  character(c_char), intent(inout) :: stringc(nstringc)
  integer(i_kind) j
  do j=1,nstringc
     stringc(j) = stringf(j:j)
  end do
  do j=nstringc+1,len(stringf)
     stringc(j) = ' '
  enddo
end subroutine copy_string_ftoc

end module pycrtm_interface
