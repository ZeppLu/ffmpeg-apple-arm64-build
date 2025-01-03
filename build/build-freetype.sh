#!/bin/sh
# $1 = script directory
# $2 = working directory
# $3 = tool directory
# $4 = CPUs
# $5 = vorbis version - unised get heads from git

# load functions
. $1/functions.sh

SOFTWARE=freetype

make_directories() {

  # start in working directory
  cd "$2"
  checkStatus $? "change directory failed"
  mkdir ${SOFTWARE}
  checkStatus $? "create directory failed"
  cd ${SOFTWARE}
  checkStatus $? "change directory failed"

}

download_code () {

  cd "$2/${SOFTWARE}"
  checkStatus $? "change directory failed"
  # download source
#  git clone https://gitlab.freedesktop.org/freetype/freetype.git --branch $5
  git clone -b VER-2-13-3 --depth 1 https://gitlab.freedesktop.org/freetype/freetype.git
  checkStatus $? "download of ${SOFTWARE} failed"

}

configure_build () {

  cd "$2/${SOFTWARE}/"
  checkStatus $? "change directory failed"
  mkdir build_${SOFTWARE}
  checkStatus $? "creating build  directory failed"
  cd "build_${SOFTWARE}/" 
  checkStatus $? "change directory failed"

  # prepare build
  cmake -DCMAKE_INSTALL_PREFIX:PATH=$3 \
        -DFT_DISABLE_HARFBUZZ=ON \
        -DFT_REQUIRE_BZIP2=ON \
        -DBUILD_SHARED_LIBS=OFF \
        -DCMAKE_BUILD_TYPE=Release ../$SOFTWARE
  checkStatus $? "configuration of ${SOFTWARE} failed"

}

make_clean() {

  cd "$2/${SOFTWARE}/build_${SOFTWARE}/"
  checkStatus $? "change directory failed"
  make clean

}

make_compile () {

  cd "$2/${SOFTWARE}/build_${SOFTWARE}/"
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
