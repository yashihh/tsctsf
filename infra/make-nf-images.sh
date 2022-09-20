#!/usr/bin/env bash                                                                       
F5GC_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null  && pwd )/../"
echo "$F5GC_DIR"

NFs=$( ls ${F5GC_DIR}/NFs )
REGISTRY_URL="10.10.0.50"
REGISTRY_PORT="5000"
DOCKER_PW=$1

export GOPRIVATE="bitbucket.org/free5gc-team/*,bitbucket.org/free5GC/*"

docker login -u free5gc -p $DOCKER_PW 10.10.0.50:5000

# build binaries
cd $F5GC_DIR
for d in $NFs; do
  if [ -f $F5GC_DIR/NFs/$d/Makefile ]; then
     cd $F5GC_DIR/NFs/$d
     echo "(In $(pwd))"
     make clean
     make || exit 1
  fi 
done

# build images
echo "REGISTRY_PORT: $REGISTRY_PORT"

cd $F5GC_DIR/NFs
for d in $NFs; do (
  if [ -d $d ];then
    cd $d
    echo "(In $(pwd))"
    echo docker build  --build-arg DEBUG_TOOLS=true -t ${REGISTRY_URL}:${REGISTRY_PORT}/free5gc-$d .
    docker build  --build-arg DEBUG_TOOLS=true -t ${REGISTRY_URL}:${REGISTRY_PORT}/free5gc-$d .
    docker push  ${REGISTRY_URL}:${REGISTRY_PORT}/free5gc-$d 
    cd - 
  fi 
); done