module pycrtm_interface

use iso_c_binding, only: c_char, c_int, c_null_char
use crtm_module, only: crtm_init, crtm_destroy, crtm_channelinfo_type, success, strlen, crtm_channelinfo_inspect
implicit none 

! container that has pointer to crtm_channelinfo_type derived type
type :: crtm_channelinfo_type_pointer
  type(crtm_channelinfo_type), pointer :: ptr
end type crtm_channelinfo_type_pointer

contains

subroutine get_strlen(lenstr) bind(c)
  integer(c_int), intent(out) :: lenstr
  lenstr = strlen
end subroutine get_strlen

subroutine init_crtm(nchanl,isis,iload_cloudcoeff,iload_aerosolcoeff,&
                     crtm_coeffs_path,ichannel_info) bind(c)
!   input argument list:
!     nchanl - (int) number of channels 
!     isis   - (char*strlen) instrument/sensor character string 
!     iload_cloudcoeff - (int) 1 to load cloud coeffs
!     iload_aerosolcoeff - (int) 1 to load aerosol coeffs
!     crtm_coeffs_path - (char*256) path to CRTM coeffs files
!   output:
!     ichannel_info - (int, dimension(12) integer array containing pointer to channel_info type
! input variables.
  integer(c_int),intent(in) :: nchanl,iload_cloudcoeff,iload_aerosolcoeff
  character(c_char), intent(in) :: isis(strlen)
  character(c_char), intent(in) :: crtm_coeffs_path(256)
! output variables
  integer(c_int),intent(out), dimension(12) :: ichannel_info
! local variables.
  character(len=strlen) :: isis_f
  integer :: error_status
  logical :: ice,Load_AerosolCoeff,Load_CloudCoeff
  type(crtm_channelinfo_type_pointer) :: channel_infop
  character(len=256) :: crtm_coeffs_path_f
! local parameters
  character(len=*), parameter :: myname_='pycrtm_interface*init_crtm'

  Load_CloudCoeff=iload_cloudcoeff
  Load_AerosolCoeff=iload_aerosolcoeff
  call copy_string_ctof(isis,isis_f)
  call copy_string_ctof(crtm_coeffs_path,crtm_coeffs_path_f)
  allocate(channel_infop % ptr)

! Initialize radiative transfer
  write(6,*)myname_,': crtm_init() on path "'//trim(crtm_coeffs_path_f)//'"'
  error_status = crtm_init_wrap(isis_f,channel_infop % ptr,&
     Load_CloudCoeff=Load_CloudCoeff,Load_AerosolCoeff=Load_AerosolCoeff, &
     File_Path = crtm_coeffs_path_f )
  if (error_status /= success) then
     print *,myname_,':  ***ERROR*** crtm_init error_status=',error_status,&
        '   TERMINATE PROGRAM EXECUTION'
     stop
  endif
  ichannel_info = transfer(channel_infop, ichannel_info)
end subroutine init_crtm

! wrapper that accepts scalar derived type instead of array of derived types
FUNCTION crtm_init_wrap( &
  Sensor_ID         , &  ! Input
  ChannelInfo       , &  ! Output
  File_Path         , &  ! Optional input
  Load_CloudCoeff   , &  ! Optional input
  Load_AerosolCoeff ) &  ! Optional input
RESULT( error_status )
  ! Arguments
  CHARACTER(*)               , INTENT(IN)  :: Sensor_ID
  TYPE(CRTM_ChannelInfo_type), INTENT(OUT) :: ChannelInfo
  CHARACTER(*),      OPTIONAL, INTENT(IN)  :: File_Path
  LOGICAL     ,      OPTIONAL, INTENT(IN)  :: Load_CloudCoeff
  LOGICAL     ,      OPTIONAL, INTENT(IN)  :: Load_AerosolCoeff
  ! Function result
  INTEGER :: error_status
  ! local variables.
  type(crtm_channelinfo_type), dimension(1) :: channelinfo_array
  character(len=len(Sensor_ID)), dimension(1) :: sensor_id_array
  sensor_id_array(1) = sensor_id
  error_status = crtm_init(sensor_id_array,channelinfo_array,&
     Load_CloudCoeff=Load_CloudCoeff,Load_AerosolCoeff=Load_AerosolCoeff, &
     File_Path = file_path )
  channelinfo = channelinfo_array(1)
END FUNCTION crtm_init_wrap

FUNCTION crtm_destroy_wrap( &
  ChannelInfo       ) &  ! Input/Output
RESULT( error_status )
  ! Arguments
  TYPE(CRTM_ChannelInfo_type), INTENT(INOUT) :: ChannelInfo
  ! Function result
  INTEGER :: error_status
  ! local variables.
  type(crtm_channelinfo_type), dimension(1) :: channelinfo_array
  channelinfo_array(1) = ChannelInfo
  error_status = crtm_destroy(channelinfo_array)
END FUNCTION crtm_destroy_wrap

subroutine print_channelinfo(ichannel_info) bind(c)
  integer(c_int), intent(in), dimension(12) :: ichannel_info
  type (crtm_channelinfo_type_pointer) :: channel_infop
  channel_infop = transfer(ichannel_info, channel_infop)
  call crtm_channelinfo_inspect( channel_infop % ptr )
end subroutine print_channelinfo

! set crtm_channel_info derived type member n_Channels
subroutine set_n_channels(ichannel_info, n_Channels) bind(c)
   integer(c_int), intent(out), dimension(12) :: ichannel_info
   integer(c_int), intent(in) :: n_Channels
   type (crtm_channelinfo_type_pointer) :: channel_infop
   channel_infop = transfer(ichannel_info, channel_infop)
   channel_infop % ptr % n_Channels = n_Channels
   ichannel_info = transfer(channel_infop, ichannel_info)
end subroutine set_n_channels

! get crtm_channel_info derived type member n_Channels
subroutine get_n_channels(ichannel_info, n_Channels) bind(c)
   integer(c_int), intent(in), dimension(12) :: ichannel_info
   integer(c_int), intent(out) :: n_Channels
   type (crtm_channelinfo_type_pointer) :: channel_infop
   channel_infop = transfer(ichannel_info, channel_infop)
   n_Channels = channel_infop % ptr % n_Channels 
end subroutine get_n_channels

! set crtm_channel_info derived type member Sensor_Type
subroutine set_sensor_type(ichannel_info, Sensor_Type) bind(c)
   integer(c_int), intent(out), dimension(12) :: ichannel_info
   integer(c_int), intent(in) :: Sensor_Type
   type (crtm_channelinfo_type_pointer) :: channel_infop
   channel_infop = transfer(ichannel_info, channel_infop)
   channel_infop % ptr % Sensor_Type = Sensor_Type
   ichannel_info = transfer(channel_infop, ichannel_info)
end subroutine set_sensor_type

! get crtm_channel_info derived type member Sensor_Type
subroutine get_sensor_type(ichannel_info, Sensor_Type) bind(c)
   integer(c_int), intent(in), dimension(12) :: ichannel_info
   integer(c_int), intent(out) :: Sensor_Type
   type (crtm_channelinfo_type_pointer) :: channel_infop
   channel_infop = transfer(ichannel_info, channel_infop)
   Sensor_Type = channel_infop % ptr % Sensor_Type 
end subroutine get_sensor_type

! set crtm_channel_info derived type member Sensor_Index
subroutine set_sensor_index(ichannel_info, Sensor_Index) bind(c)
   integer(c_int), intent(out), dimension(12) :: ichannel_info
   integer(c_int), intent(in) :: Sensor_Index
   type (crtm_channelinfo_type_pointer) :: channel_infop
   channel_infop = transfer(ichannel_info, channel_infop)
   channel_infop % ptr % Sensor_Index = Sensor_Index
   ichannel_info = transfer(channel_infop, ichannel_info)
end subroutine set_sensor_index

! get crtm_channel_info derived type member Sensor_Index
subroutine get_sensor_index(ichannel_info, Sensor_Index) bind(c)
   integer(c_int), intent(in), dimension(12) :: ichannel_info
   integer(c_int), intent(out) :: Sensor_Index
   type (crtm_channelinfo_type_pointer) :: channel_infop
   channel_infop = transfer(ichannel_info, channel_infop)
   Sensor_Index = channel_infop % ptr % Sensor_Index 
end subroutine get_sensor_index

! set crtm_channel_info derived type member WMO_Satellite_ID
subroutine set_wmo_satellite_id(ichannel_info, WMO_Satellite_ID) bind(c)
   integer(c_int), intent(out), dimension(12) :: ichannel_info
   integer(c_int), intent(in) :: WMO_Satellite_ID
   type (crtm_channelinfo_type_pointer) :: channel_infop
   channel_infop = transfer(ichannel_info, channel_infop)
   channel_infop % ptr % WMO_Satellite_ID = WMO_Satellite_ID
   ichannel_info = transfer(channel_infop, ichannel_info)
end subroutine set_wmo_satellite_id

! get crtm_channel_info derived type member WMO_Satellite_ID
subroutine get_wmo_satellite_id(ichannel_info, WMO_Satellite_ID) bind(c)
   integer(c_int), intent(in), dimension(12) :: ichannel_info
   integer(c_int), intent(out) :: WMO_Satellite_ID
   type (crtm_channelinfo_type_pointer) :: channel_infop
   channel_infop = transfer(ichannel_info, channel_infop)
   WMO_Satellite_ID = channel_infop % ptr % WMO_Satellite_ID 
end subroutine get_wmo_satellite_id

! get derived type member name
subroutine get_sensor_id(ichannel_info,name) bind (c)
   integer(c_int), intent(in), dimension(12) :: ichannel_info
   character(c_char), intent(out) :: name(strlen+1)
   type (crtm_channelinfo_type_pointer) :: channel_infop
   channel_infop = transfer(ichannel_info, channel_infop)
   call copy_string_ftoc(channel_infop%ptr%Sensor_ID,name)
end subroutine get_sensor_id

! set crtm_channel_info derived type member WMO_Sensor_ID
subroutine set_wmo_sensor_id(ichannel_info, WMO_Sensor_ID) bind(c)
   integer(c_int), intent(out), dimension(12) :: ichannel_info
   integer(c_int), intent(in) :: WMO_Sensor_ID
   type (crtm_channelinfo_type_pointer) :: channel_infop
   channel_infop = transfer(ichannel_info, channel_infop)
   channel_infop % ptr % WMO_Sensor_ID = WMO_Sensor_ID
   ichannel_info = transfer(channel_infop, ichannel_info)
end subroutine set_wmo_sensor_id

! get crtm_channel_info derived type member WMO_Sensor_ID
subroutine get_wmo_sensor_id(ichannel_info, WMO_Sensor_ID) bind(c)
   integer(c_int), intent(in), dimension(12) :: ichannel_info
   integer(c_int), intent(out) :: WMO_Sensor_ID
   type (crtm_channelinfo_type_pointer) :: channel_infop
   channel_infop = transfer(ichannel_info, channel_infop)
   WMO_Sensor_ID = channel_infop % ptr % WMO_Sensor_ID 
end subroutine get_wmo_sensor_id

! set derived type member name
subroutine set_sensor_id(ichannel_info, name) bind(c)
   integer(c_int), intent(inout), dimension(12) :: ichannel_info
   character(c_char), intent(in) :: name(strlen+1)
   type (crtm_channelinfo_type_pointer) :: channel_infop
   channel_infop = transfer(ichannel_info, channel_infop)
   call copy_string_ctof(name,channel_infop%ptr%Sensor_ID)
   ichannel_info = transfer(channel_infop, ichannel_info)
end subroutine set_sensor_id

! set derived type member Sensor_Channel
subroutine set_sensor_channel(ichannel_info, sensor_channel, n) bind(c)
   integer(c_int), intent(in) :: n
   integer(c_int), intent(inout), dimension(12) :: ichannel_info
   integer(c_int), intent(in), dimension(n) :: sensor_channel
   type (crtm_channelinfo_type_pointer) :: channel_infop
   channel_infop = transfer(ichannel_info, channel_infop)
   channel_infop % ptr % Sensor_Channel = sensor_channel
   ichannel_info = transfer(channel_infop, ichannel_info)
end subroutine set_sensor_channel

! get derived type member Sensor_Channel
subroutine get_sensor_channel(ichannel_info,sensor_channel, n) bind (c)
   integer(c_int), intent(in) :: n
   integer(c_int), intent(in), dimension(12) :: ichannel_info
   integer(c_int), intent(out), dimension(n) :: sensor_channel
   type (crtm_channelinfo_type_pointer) :: channel_infop
   channel_infop = transfer(ichannel_info, channel_infop)
   sensor_channel = channel_infop % ptr % Sensor_Channel
end subroutine get_sensor_channel

! set derived type member Channel_Index
subroutine set_channel_index(ichannel_info, channel_index, n) bind(c)
   integer(c_int), intent(in) :: n
   integer(c_int), intent(inout), dimension(12) :: ichannel_info
   integer(c_int), intent(in), dimension(n) :: channel_index
   type (crtm_channelinfo_type_pointer) :: channel_infop
   channel_infop = transfer(ichannel_info, channel_infop)
   channel_infop % ptr % Channel_Index = channel_index
   ichannel_info = transfer(channel_infop, ichannel_info)
end subroutine set_channel_index

! get derived type member Channel_Index
subroutine get_channel_index(ichannel_info,channel_index, n) bind (c)
   integer(c_int), intent(in) :: n
   integer(c_int), intent(in), dimension(12) :: ichannel_info
   integer(c_int), intent(out), dimension(n) :: channel_index
   type (crtm_channelinfo_type_pointer) :: channel_infop
   channel_infop = transfer(ichannel_info, channel_infop)
   channel_index = channel_infop % ptr % Channel_Index
end subroutine get_channel_index

! set derived type member Process_Channel
subroutine set_process_channel(ichannel_info, process_channel, n) bind(c)
   integer(c_int), intent(in) :: n
   integer(c_int), intent(inout), dimension(12) :: ichannel_info
   integer(c_int), intent(in), dimension(n) :: process_channel
   type (crtm_channelinfo_type_pointer) :: channel_infop
   channel_infop = transfer(ichannel_info, channel_infop)
   channel_infop % ptr % Process_Channel = process_channel
   ichannel_info = transfer(channel_infop, ichannel_info)
end subroutine set_process_channel

! get derived type member Process_Channel
subroutine get_process_channel(ichannel_info,process_channel, n) bind (c)
   integer(c_int), intent(in) :: n
   integer(c_int), intent(in), dimension(12) :: ichannel_info
   integer(c_int), intent(out), dimension(n) :: process_channel
   type (crtm_channelinfo_type_pointer) :: channel_infop
   channel_infop = transfer(ichannel_info, channel_infop)
   process_channel = channel_infop % ptr % Process_Channel
end subroutine get_process_channel

! deallocate crtm_channelinfo_type
subroutine destroy_channelinfo(ichannel_info) bind(c)
   integer(c_int), intent(in), dimension(12) :: ichannel_info
   integer error_status
   type (crtm_channelinfo_type_pointer) :: channel_infop
   channel_infop = transfer(ichannel_info, channel_infop)
   error_status = crtm_destroy_wrap(channel_infop % ptr)
   if (error_status /= success) then
      write(6,*) ' ***ERROR*** crtm_destroy,error_status=',error_status
     stop
   endif
   deallocate(channel_infop % ptr)
end subroutine destroy_channelinfo

subroutine copy_string_ctof(stringc,stringf)
  ! utility function to convert c string to fortran string
  character(len=*), intent(out) :: stringf
  character(c_char), intent(in) :: stringc(:)
  integer j
  stringf = ''
  char_loop: do j=1,min(size(stringc),len(stringf))
     if (stringc(j)==c_null_char) exit char_loop
     stringf(j:j) = stringc(j)
  end do char_loop
end subroutine copy_string_ctof

subroutine copy_string_ftoc(stringf,stringc)
  ! utility function to convert c string to fortran string
  character(len=*), intent(in) :: stringf
  character(c_char), intent(out) :: stringc(strlen+1)
  integer j,n
  n = len_trim(stringf)   
  do j=1,n    
    stringc(j) = stringf(j:j)   
  end do
  stringc(n+1) = c_null_char
end subroutine copy_string_ftoc

end module pycrtm_interface
