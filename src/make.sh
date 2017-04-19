echo "gfortran -O2 -fPIC -c kinds.f90"
gfortran -O2 -fPIC -c kinds.f90
echo "gfortran -O2 -fPIC -c -I${CRTM_INCDIR} pycrtm_interface.f90"
gfortran -O2 -fPIC -c -I${CRTM_INCDIR} pycrtm_interface.f90
ar -ruv libpycrtm_interface.a pycrtm_interface.o kinds.o
/bin/rm -f *.o
