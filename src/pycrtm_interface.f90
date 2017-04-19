module pycrtm_interface

use iso_c_binding, only: c_double, c_int, c_char, c_bool, c_null_char
use kinds, only: r_kind, i_kind
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
  integer(i_kind) :: error_status
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

subroutine print_channelinfo(ichannel_info) bind(c)
  integer(c_int), intent(in), dimension(12) :: ichannel_info
  type (crtm_channelinfo_type_pointer) :: channel_infop
  channel_infop = transfer(ichannel_info, channel_infop)
  call crtm_channelinfo_inspect( channel_infop % ptr )
end subroutine print_channelinfo

! set crtm_channel_info derived type member n_Channels
subroutine set_nchannels(ichannel_info, n_Channels) bind(c)
   integer(c_int), intent(out), dimension(12) :: ichannel_info
   integer(c_int), intent(in) :: n_Channels
   type (crtm_channelinfo_type_pointer) :: channel_infop
   channel_infop = transfer(ichannel_info, channel_infop)
   channel_infop % ptr % n_Channels = n_Channels
   ichannel_info = transfer(channel_infop, ichannel_info)
end subroutine set_nchannels

! get crtm_channel_info derived type member n_Channels
subroutine get_nchannels(ichannel_info, n_Channels) bind(c)
   integer(c_int), intent(in), dimension(12) :: ichannel_info
   integer(c_int), intent(out) :: n_Channels
   type (crtm_channelinfo_type_pointer) :: channel_infop
   channel_infop = transfer(ichannel_info, channel_infop)
   n_Channels = channel_infop % ptr % n_Channels 
end subroutine get_nchannels

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
