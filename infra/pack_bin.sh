#!/bin/bash

ROOT_PARENT=$PWD
SOURCE_FOLDER_NAME="free5gc"
SOURCE_ROOT="${ROOT_PARENT}/${SOURCE_FOLDER_NAME}"
TODAY=$(date +"%Y%m%d")
NF_PATH="${SOURCE_ROOT}/NFs"

if [ "${1}" == "" ]; then
    BIN_FOLDER_NAME="bin_${TODAY}"
    git clone https://bitbucket.org/free5gc-team/free5gc.git ${SOURCE_ROOT}
    cd ${SOURCE_ROOT} && git checkout develop && git submodule sync --recursive && git submodule update --init && git submodule foreach git checkout develop && git submodule foreach git pull
else
    BIN_FOLDER_NAME="bin_${1}"
    git clone --recursive -b ${1} https://bitbucket.org/free5gc-team/free5gc.git ${SOURCE_ROOT}
    cd ${SOURCE_ROOT}
fi

BIN_ROOT="${ROOT_PARENT}/${BIN_FOLDER_NAME}"
TGZ_FILE_NAME="${BIN_FOLDER_NAME}.tgz"

# go vendor
# NF
for NF in ${NF_PATH}/*
do
    cd ${NF}
    go mod vendor
    cd ~-
done

# webconsole
cd ${SOURCE_ROOT}/webconsole
go mod vendor
cd ~-

make all

echo "Pack the binary..."
mkdir -p ${BIN_ROOT}/NFs/upf/build/utlt_logger
mkdir -p ${BIN_ROOT}/NFs/upf/build/updk/src/third_party/libgtp5gnl/lib
mkdir -p ${BIN_ROOT}/webconsole
cp -rf bin ${BIN_ROOT}
cp -rf config ${BIN_ROOT}
cp -rf NFs/upf/build/bin ${BIN_ROOT}/NFs/upf/build
cp -rf NFs/upf/build/config ${BIN_ROOT}/NFs/upf
cp -rf NFs/upf/build/utlt_logger/liblogger.so ${BIN_ROOT}/NFs/upf/build/utlt_logger
cp -rf NFs/upf/build/updk/src/third_party/libgtp5gnl/lib/libgtp5gnl.so* ${BIN_ROOT}/NFs/upf/build/updk/src/third_party/libgtp5gnl/lib
cp -rf webconsole/bin ${BIN_ROOT}/webconsole
cp -rf webconsole/config ${BIN_ROOT}/webconsole
cp -rf webconsole/public ${BIN_ROOT}/webconsole
cp -rf run.sh ${BIN_ROOT}
cp -rf force_kill.sh ${BIN_ROOT}
cd ..
tar zcf ${TGZ_FILE_NAME} ${BIN_FOLDER_NAME}
rm -rf ${SOURCE_FOLDER_NAME}
rm -rf ${BIN_FOLDER_NAME}
echo "Pack done"
