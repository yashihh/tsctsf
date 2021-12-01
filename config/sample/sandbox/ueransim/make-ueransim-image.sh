#!/usr/bin/env bash                                                                       

IT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && cd ../.. && pwd )"

cd $IT_DIR/dev/ueransim
echo "(In $(pwd))"
echo docker build -f Dockerfile.sandbox --build-arg DEBUG_TOOLS=true -t localhost:12345/ueransim .
docker build -f Dockerfile.sandbox --build-arg DEBUG_TOOLS=true -t localhost:12345/ueransim .
