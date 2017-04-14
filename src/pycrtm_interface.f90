module pycrtm_interface

use iso_c_binding, only: c_double, c_int, c_char
use kinds, only: r_kind, i_kind
use crtm_module, only: crtm_init, crtm_channelinfo_type, success
implicit none

contains

subroutine init_crtm(init_pass,mype_diaghdr,mype,nchanl,isis,nchar_isis,obstype,nchar_obstype,crtm_coeffs_path,nchar_path) bind(c)
!   input argument list:
!     init_pass    - state of "setup" processing
!     mype_diaghdr - processor to produce output from crtm
!     mype         - current processor        
!     nchanl       - number of channels    
!     isis         - instrument/sensor character string 
!     nchar_isis   - number of characters in isis
!     obstype      - observation type
!     nchar_obstype - number of characters in observation type
!     crtm_coeffs_path - path to CRTM coeffs files
!     nchar_path - number of characters in crtm_coeffs_path
! input variables.
  integer(c_int),intent(in) :: &
  init_pass,nchanl,mype_diaghdr,mype,nchar_isis,nchar_obstype,nchar_path
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
  type(crtm_channelinfo_type),save,dimension(1)  :: channelinfo
  character(len=256) :: crtm_coeffs_path_f
! local parameters
  character(len=*), parameter :: myname_='pycrtm_interface*init_crtm'

  print *,'in fortran'
  init = init_pass
  print *,init
  print *,init_pass,mype_diaghdr,mype,nchanl
  call copy_string(isis,nchar_isis,isis_f)
  call copy_string(obstype,nchar_obstype,obstype_f)
  call copy_string(crtm_coeffs_path,nchar_path,crtm_coeffs_path_f)
  print *,trim(isis_f)
  print *,nchar_isis,len(trim(isis_f))
  print *,trim(obstype_f)
  print *,nchar_obstype,len(trim(obstype_f))
  print *,trim(crtm_coeffs_path_f)
  print *,nchar_path,len(trim(crtm_coeffs_path_f))

  ! these should be input args.
  Load_CloudCoeff=.true.
  Load_AerosolCoeff=.true.

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
