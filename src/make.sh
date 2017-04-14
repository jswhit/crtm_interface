echo "ifort -O2 -fPIC -c kinds.f90"
ifort -O2 -fPIC -c kinds.f90
echo "ifort -O2 -fPIC -c -I${CRTM_INCDIR} pycrtm_interface.f90"
ifort -O2 -fPIC -c -I${CRTM_INCDIR} pycrtm_interface.f90
ar -ruv libpycrtm_interface.a pycrtm_interface.o kinds.o
/bin/rm -f *.o
