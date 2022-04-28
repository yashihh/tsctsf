#!/bin/bash

NF_LIST="nrf amf smf udr pcf udm nssf ausf n3iwf free5gc-upfd"

for NF in ${NF_LIST}; do
    sudo killall -9 ${NF}
done

sudo killall tcpdump
sudo ip link del upfgtp
sudo ip link del ipsec0
XFRMI_LIST=($(ip link | grep xfrmi | awk -F'[:,@]' '{print $2}'))
for XFRMI_IF in "${XFRMI_LIST[@]}"
do
    sudo ip link del $XFRMI_IF
done
sudo rm /dev/mqueue/*

