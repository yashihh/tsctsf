#!/bin/bash

ROOT_PARENT=$PWD
SOURCE_FOLDER_NAME="free5gc"
SOURCE_ROOT="${ROOT_PARENT}/${SOURCE_FOLDER_NAME}"
ZIP_FILE_NAME="free5gc.zip"
NF_PATH="${SOURCE_ROOT}/NFs"

git clone https://bitbucket.org/free5gc-team/free5gc.git ${SOURCE_ROOT}

cd ${SOURCE_ROOT} && git checkout develop && git submodule sync --recursive && git submodule update --init && git submodule foreach git checkout develop && git submodule foreach git pull
rm -rf infra release .golangci.yml bitbucket-pipelines.yml

# go vendor
# NF
for NF in ${NF_PATH}/*
do
    cd ${NF}
    go mod vendor
    rm -rf .git
    cd ~-
done

# webconsole
cd ${SOURCE_ROOT}/webconsole
go mod vendor
rm -rf .git
cd ~-

cd ${ROOT_PARENT}
rm -f ${ZIP_FILE_NAME}
zip -r ${ZIP_FILE_NAME} ${SOURCE_FOLDER_NAME}
rm -rf ${SOURCE_ROOT}

echo "ZIP file locate at ${ROOT_PARENT}/${ZIP_FILE_NAME} done."

