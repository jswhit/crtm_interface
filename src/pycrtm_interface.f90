module pycrtm_interface

use iso_c_binding, only: c_double, c_int, c_char
use kinds, only: r_kind, i_kind
use crtm_module, only: crtm_init, crtm_channelinfo_type, success
implicit none

contains

subroutine init_crtm(init_pass,mype_diaghdr,mype,nchanl,isis,nchar_isis,obstype,nchar_obstype,iload_cloudcoeff,iload_aerosolcoeff,crtm_coeffs_path,nchar_path) bind(c)
!   input argument list:
!     init_pass    - (int) state of "setup" processing
!     mype_diaghdr - (int) processor to produce output from crtm
!     mype         - (int) current processor        
!     nchanl       - (int) number of channels    
!     isis         - (char*10) instrument/sensor character string 
!     obstype      - (char*20) observation type
!     iload_cloudcoeff - (int) 1 to load cloud coeffs
!     iload_aerosolcoeff - (int) 1 to load aerosol coeffs
!     crtm_coeffs_path - (char*256) path to CRTM coeffs files
!   output:
!     n_channels - (int)
!     sensor_id  - (char*)
!     sensor_type  - (int)
!     wmo_sat_id - (int)
!     wmo_sensor_id - (int)
!     process_channel - (int, dimension(n_channels))
!     sensor_channel - (int, dimension(n_channels))
!     channel_index - (int, dimension(n_channels)) 
! input variables.
  integer(c_int),intent(in) :: &
  init_pass,nchanl,mype_diaghdr,mype,nchar_isis,nchar_obstype,nchar_path,&
  iload_cloudcoeff,iload_aerosolcoeff 
  character(c_char), intent(in) :: isis(10)
  character(c_char), intent(in) :: obstype(20)
  character(c_char), intent(in) :: crtm_coeffs_path(256)
! local variables.
  character(len=20) :: isis_f
  character(len=10) :: obstype_f
  logical :: init
  integer(i_kind) :: error_status
  logical :: ice,Load_AerosolCoeff,Load_CloudCoeff
  character(len=20),dimension(1) :: sensorlist
  type(crtm_channelinfo_type),dimension(1) :: channelinfo
  character(len=256) :: crtm_coeffs_path_f
! local parameters
  character(len=*), parameter :: myname_='pycrtm_interface*init_crtm'

  print *,'in fortran'
  init = init_pass
  Load_CloudCoeff=iload_cloudcoeff
  Load_AerosolCoeff=iload_aerosolcoeff
  print *,init,Load_CloudCoeff,Load_AerosolCoeff
  print *,init_pass,mype_diaghdr,mype,nchanl,iload_cloudcoeff,iload_aerosolcoeff
  call copy_string(isis,nchar_isis,isis_f)
  call copy_string(obstype,nchar_obstype,obstype_f)
  call copy_string(crtm_coeffs_path,nchar_path,crtm_coeffs_path_f)
  print *,trim(isis_f)
  print *,nchar_isis,len(trim(isis_f))
  print *,trim(obstype_f)
  print *,nchar_obstype,len(trim(obstype_f))
  print *,trim(crtm_coeffs_path_f)
  print *,nchar_path,len(trim(crtm_coeffs_path_f))


! Initialize radiative transfer
  sensorlist(1)=isis_f
  if( crtm_coeffs_path_f /= "" ) then
     if(init_pass .and. mype==mype_diaghdr) write(6,*)myname_,': crtm_init() on path "'//trim(crtm_coeffs_path_f)//'"'
     error_status = crtm_init(sensorlist,channelinfo,&
        Process_ID=mype,Output_Process_ID=mype_diaghdr, &
        Load_CloudCoeff=Load_CloudCoeff,Load_AerosolCoeff=Load_AerosolCoeff, &
        File_Path = crtm_coeffs_path_f )
  else
     error_status = crtm_init(sensorlist,channelinfo,&
        Process_ID=mype,Output_Process_ID=mype_diaghdr, &
        Load_CloudCoeff=Load_CloudCoeff,Load_AerosolCoeff=Load_AerosolCoeff)
  endif
  if (error_status /= success) then
     print *,myname_,':  ***ERROR*** crtm_init error_status=',error_status,&
        '   TERMINATE PROGRAM EXECUTION'
     stop
  endif
  print *,'done call crtm_init'
  print *,'n_channels',channelinfo(1)%n_Channels
  print *,'is_allocated',channelinfo(1)%is_Allocated
  print *,'sensor_id ',trim(channelinfo(1)%Sensor_Id),len(channelinfo(1)%Sensor_Id)
  print *,'sensor_type',channelinfo(1)%Sensor_Type
  print *,'wmo_sat_id',channelinfo(1)%WMO_Satellite_Id
  print *,'wmo_sensor_id',channelinfo(1)%WMO_Sensor_Id
  print *,'process_channel',channelinfo(1)%Process_Channel,size(channelinfo(1)%Process_Channel)
  print *,'sensor_channel',channelinfo(1)%Sensor_Channel
  print *,'channel_index',channelinfo(1)%Channel_Index
end subroutine init_crtm

subroutine copy_string(stringc,nstringc,stringf)
  ! utility function to convert c string to fortran string
  character(len=*), intent(inout) :: stringf
  integer(c_int), intent(in) :: nstringc
  character(c_char), intent(in) :: stringc(nstringc)
  integer(i_kind) j
  do j=1, nstringc
     stringf(j:j) = stringc(j)
  end do
  do j=nstringc+1,len(stringf)
     stringf(j:j) = ' '
  enddo
end subroutine copy_string

end module pycrtm_interface
