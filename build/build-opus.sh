#!/bin/sh
# $1 = script directory
# $2 = working directory
# $3 = tool directory
# $4 = CPUs
# $5 = opus version

# load functions
. $1/functions.sh

SOFTWARE=opus

make_directories() {
set -x

  # start in working directory
  cd "$2"
  checkStatus $? "change directory failed"
  mkdir ${SOFTWARE}
  checkStatus $? "create directory failed"
  cd ${SOFTWARE}
  checkStatus $? "change directory failed"

  mkdir build-${SOFTWARE}
  checkStatus $? "create directory failed"
  cd build-${SOFTWARE}
  checkStatus $? "change directory failed"


}

download_code () {

  cd "$2/${SOFTWARE}"
  checkStatus $? "change directory failed"

  # download source
  git clone -b v1.5.2 --depth 1 https://gitlab.xiph.org/xiph/opus.git
  checkStatus $? "download of ${SOFTWARE} failed"

  cd ${SOFTWARE}
  checkStatus $? "change directory failed"

}

configure_build () {

  cd "$2/${SOFTWARE}/build-${SOFTWARE}/"
  checkStatus $? "change directory failed"

  
  #cmake -DCMAKE_INSTALL_PREFIX:PATH=$3 -DOPUS_ARM_ASM=TRUE -DOPUS_MAY_HAVE_NEON=FALSE -DOPUS_PRESUME_NEON=TRUE -DCOMPILER_SUPPORT_NEON=TRUE -DBUILD_SHARED_LIBS=OFF ../${SOFTWARE}
  cmake -DCMAKE_INSTALL_PREFIX:PATH=$3 -DBUILD_SHARED_LIBS=OFF ../${SOFTWARE}
  checkStatus $? "configuration of ${SOFTWARE} failed"

}


make_clean() {

  cd "$2/${SOFTWARE}/build-${SOFTWARE}/"
  checkStatus $? "change directory failed"
  make clean
  checkStatus $? "make clean for $SOFTWARE failed"


}

make_compile () {

  cd "$2/${SOFTWARE}/build-${SOFTWARE}/"
  checkStatus $? "change directory failed"

  # build
  make -j $4
  checkStatus $? "build of ${SOFTWARE} failed"

  # install
  make install
  checkStatus $? "installation of ${SOFTWARE} failed"

}

build_main () {
set -x

  if [[ -d "$2/${SOFTWARE}" && "${ACTION}" == "skip" ]]
  then
      return 0
  elif [[ -d "$2/${SOFTWARE}" && -z "${ACTION}" ]]
  then
      echo "${SOFTWARE} build directory already exists but no action set. Exiting script"
      exit 0
  fi


  if [[ ! -d "$2/${SOFTWARE}" ]]
  then
    make_directories $@
    download_code $@
    configure_build $@
  fi

  make_clean $@
  make_compile $@

}

build_main $@
