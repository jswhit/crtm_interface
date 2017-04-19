from distutils.core import setup
from distutils.extension import Extension
from Cython.Distutils import build_ext
import os, sys, subprocess, numpy

# get paths to CRTM stuff.
CRTM_incdir = os.environ.get('CRTM_INCDIR')
if CRTM_incdir is None:
    CRTM_incdir='CRTM_REL-2.2.3/libsrc'
    os.environ['CRTM_INCDIR']="../"+CRTM_incdir # needed by make.sh
CRTM_libdir = os.environ.get('CRTM_LIBDIR')
if CRTM_libdir is None:
    CRTM_libdir='CRTM_REL-2.2.3/libsrc'

# build iso_c_binding fortran wrapper using shell script.
strg = 'cd src; sh make.sh'
sys.stdout.write('executing "%s"\n' % strg)
subprocess.call(strg,env=os.environ,shell=True)

if os.path.exists('crtm_interface.c'): os.remove('crtm_interface.c') # trigger a rebuild

# build c extension that calls fortran.
libs = ['pycrtm_interface','crtm','gfortran']
inc_dirs = ['src',CRTM_incdir]
inc_dirs.append(numpy.get_include())
lib_dirs = ['src',CRTM_libdir,'/opt/local/lib/gcc6']
ext_modules = [Extension('crtm_interface',                       # module name
                        ['crtm_interface.pyx'],                  # cython source file
                        libraries     = libs,
                        include_dirs  = inc_dirs,
                        library_dirs  = lib_dirs)]

setup(name = 'crtm_interface',
      cmdclass = {'build_ext': build_ext},
      ext_modules  = ext_modules)
