#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "./for-ueransim.sh <IP>"
    exit 1
fi

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
SRC_DIR=$SCRIPT_DIR/ueransim
DEST_DIR=$SCRIPT_DIR/..
IP=$1

echo From $SRC_DIR
echo Copy $( ls $SRC_DIR )
echo To $DEST_DIR
echo Using IP $IP

cp $SRC_DIR/* $DEST_DIR

sed -i "s/<AMF_NGAP_IP>/$IP/g" $DEST_DIR/amfcfg.yaml
sed -i "s/<UPF_N3>/$IP/g" $DEST_DIR/smfcfg.yaml
sed -i "s/<UPF_N3>/$IP/g" $DEST_DIR/upfcfg.yaml

echo Done



