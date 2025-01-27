#!/bin/bash -ev

# debian dependencies + python libs

TELEMAC_MAJOR_VER=$(echo $TELEMAC_MASCARET_VER | cut -c 1-2)
if [[ $TELEMAC_MAJOR_VER == "v7"  ]]; then
    PYTHON_PKGS="nano python python-pip"
    PIP_PKGS="numpy matplotlib==2.0.2 scipy jupyter"
    export PYTHON="python"

    sed -i 's/<partel.par>/PARTEL.PAR/' ${TELEMAC_ROOT}/systel.cfg
else
    PYTHON_PKGS="nano python3 python3-pip"
    PIP_PKGS="numpy matplotlib scipy jupyter mpi4py pandas"
    export PYTHON="python3"
    export PYTHON_VERSION=3
fi

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get -o Dpkg::Options::="--force-confold" upgrade --no-install-suggests -q -y
apt-get -o Dpkg::Options::="--force-confold" install --no-install-suggests -q -y \
    libopenmpi-dev openmpi-bin gfortran subversion less \
    cmake swig vim curl zlib1g-dev ${PYTHON_PKGS}
rm -rf /var/lib/apt/lists/*

${PYTHON} -m pip --no-cache-dir install ${PIP_PKGS}

# vendor libs

echo "Compiling vendor libs..."

cd /tmp

VENDOR_HOME="${TELEMAC_ROOT}/vendor"

METISHOME=${VENDOR_HOME}/metis
METIS_REL=metis-5.1.0

HDF5HOME=${VENDOR_HOME}/hdf5
HDF_REL=hdf5-1.10.6

MEDHOME=${VENDOR_HOME}/med
MED_REL=med-4.0.0

SCOTCHHOME=${VENDOR_HOME}/scotch
SCOTCH_REL=scotch_6.1.1

# METIS
curl -Ls http://glaros.dtc.umn.edu/gkhome/fetch/sw/metis/${METIS_REL}.tar.gz | tar xvz
cd ${METIS_REL}
make config prefix=${METISHOME} openmp=set
make
make install
cd ..
rm -rf ${METIS_REL}

# HDF5 (current MED requires >= 1.10.2 and < 1.11)
HDF_MIN_REL=$(echo ${HDF_REL} | sed 's/\.[^.]*$//')

curl -Ls https://support.hdfgroup.org/ftp/HDF5/releases/${HDF_MIN_REL}/${HDF_REL}/src/${HDF_REL}.tar.gz | tar xvz
cd ${HDF_REL}
./configure --prefix=${HDF5HOME} --enable-build-mode=production --enable-fortran --disable-tests \
            --disable-static --enable-optimization=high --enable-parallel
make
make install
cd ..
rm -rf ${HDF_REL}

# MED
curl -Ls http://files.salome-platform.org/Salome/other/${MED_REL}.tar.gz | tar xvz
cd ${MED_REL}
./configure --prefix=${MEDHOME} --disable-static --with-hdf5=${HDF5HOME} --with-swig=yes
make
make install
cd ..
rm -rf ${MED_REL}

# SCOTCH
curl -Ls https://gforge.inria.fr/frs/download.php/file/38443/${SCOTCH_REL}.tar.gz | tar xvz
cd ${SCOTCH_REL}/src && ln -s Make.inc/Makefile.inc.x86-64_pc_linux2 Makefile.inc
make
make prefix=${SCOTCHHOME} install
cd /tmp && rm -rf ${SCOTCH_REL}

# FIXME
# AED latest?
# GOTM

echo "Finished $0"
