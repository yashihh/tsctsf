#!/usr/bin/env bash                                                                       

IT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && cd ../.. && pwd )"
UERANSIM_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && cd ../../../../UERANSIM && pwd )"

echo cp $IT_DIR/dev/ueransim/Dockerfile.sandbox $UERANSIM_DIR
cp $IT_DIR/dev/ueransim/Dockerfile.sandbox $UERANSIM_DIR

cd $UERANSIM_DIR
echo "(In $(pwd))"
echo make
make
echo mkdir -p $IT_DIR/dev/ueransim/build
mkdir -p $IT_DIR/dev/ueransim/build
echo cp build/* $IT_DIR/dev/ueransim/build
cp build/* $IT_DIR/dev/ueransim/build
