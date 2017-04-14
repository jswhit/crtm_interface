from distutils.core import setup
from distutils.extension import Extension
from Cython.Distutils import build_ext
import os, sys, subprocess

# get paths to CRTM stuff.
CRTM_incdir = os.environ.get('CRTM_INCDIR')
if CRTM_incdir is None:
    raise ValueError('CRTM_INCDIR env var not specified')
CRTM_libdir = os.environ.get('CRTM_LIBDIR')
if CRTM_libdir is None:
        raise ValueError('CRTM_LIBDIR env var not specified')

# build iso_c_binding fortran wrapper using shell script.
strg = 'cd src; sh make.sh'
sys.stdout.write('executing "%s"\n' % strg)
subprocess.call(strg,env=os.environ,shell=True)

os.remove('crtm_interface.c') # trigger a rebuild

# build c extension that calls fortran.
libs = ['pycrtm_interface','imf','ifcore','crtm']

ext_modules = [Extension('crtm_interface',                       # module name
                        ['crtm_interface.pyx'],                  # cython source file
                        libraries     = libs,
                        include_dirs  = ['src',CRTM_incdir],
                        library_dirs  = ['src',CRTM_libdir])]

setup(name = 'crtm_interface',
      cmdclass = {'build_ext': build_ext},
      ext_modules  = ext_modules)
