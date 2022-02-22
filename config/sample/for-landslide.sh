#!/bin/bash

# https://stackoverflow.com/questions/59895/how-can-i-get-the-source-directory-of-a-bash-script-from-within-the-script-itsel

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
SRC_DIR=$SCRIPT_DIR/landslide
DEST_DIR=$SCRIPT_DIR/..
USAGE_MSG="Usage ${0} [-n3iwf] [-newip] [-free5gc_iupf|-psaupf]"
N3IWF_ENABLE=0
NEWIP_ENABLE=0
FREE5GC_IUPF_ENABLE=0
PSAUPF_ENABLE=0
AMF_N2_IP=172.16.2.100
UPF_N3_IP=172.16.3.100
UPF_N6_IP=172.16.6.100
SMF_N4_IP=127.0.0.7
UPF_N4_IP=127.0.0.8
IUPF_N9_IP=172.16.9.100
PSAUPF_N4_IP=172.16.4.101
PSAUPF_N9_IP=172.16.9.101
IKE_BIND_IP=172.16.2.99

if [ $# -ne 0 ]; then
    while [ $# -gt 0 ]; do
        case $1 in
            -n3iwf)
                N3IWF_ENABLE=1
                ;;
            -newip)
                NEWIP_ENABLE=1
                ;;
            -free5gc_iupf)
                if [ $PSAUPF_ENABLE -eq 1 ]; then
                    echo $USAGE_MSG
                    exit 1
                fi
                FREE5GC_IUPF_ENABLE=1
                ;;
            -psaupf)
                if [ $FREE5GC_IUPF_ENABLE -eq 1 ]; then
                    echo $USAGE_MSG
                    exit 1
                fi
                PSAUPF_ENABLE=1
                ;;
            *)
                echo $USAGE_MSG
                exit 1
        esac
        shift
    done
fi

echo From $SRC_DIR
echo Copy $( ls $SRC_DIR )
echo To $DEST_DIR

cp $SRC_DIR/*.yaml $DEST_DIR

if [ $NEWIP_ENABLE -eq 1 ]; then
    AMF_N2_IP=172.22.255.100
    UPF_N3_IP=172.23.255.100
fi

if [ $N3IWF_ENABLE -eq 1 ]; then
    if [ $NEWIP_ENABLE -eq 1 ]; then
        IKE_BIND_IP=172.22.255.99
    else
        IKE_BIND_IP=172.16.2.99
    fi
fi

if [ $PSAUPF_ENABLE -eq 1 ]; then
    SMF_N4_IP=172.16.4.99
    UPF_N4_IP=$PSAUPF_N4_IP
    UPF_N3_IP=$PSAUPF_N9_IP
fi

if [ $FREE5GC_IUPF_ENABLE -eq 1 ]; then
    SMF_N4_IP=172.16.4.99
    UPF_N4_IP=172.16.4.100
    UPF_N6_IP=$IUPF_N9_IP
    cp $SRC_DIR/free5gc_iUPF/*.yaml $DEST_DIR
fi

sed -i "s/<AMF_NGAP_IP>/$AMF_N2_IP/g" $DEST_DIR/amfcfg.yaml
sed -i "s/<AMF_NGAP_IP>/$AMF_N2_IP/g" $DEST_DIR/n3iwfcfg.yaml
sed -i "s/<IKE_BIND_IP>/$IKE_BIND_IP/g" $DEST_DIR/n3iwfcfg.yaml

sed -i "s/<SMF_N4>/$SMF_N4_IP/g" $DEST_DIR/smfcfg.yaml

sed -i "s/<UPF_N3>/$UPF_N3_IP/g" $DEST_DIR/smfcfg.yaml
sed -i "s/<UPF_N3>/$UPF_N3_IP/g" $DEST_DIR/upfcfg.yaml
sed -i "s/<UPF_N4>/$UPF_N4_IP/g" $DEST_DIR/smfcfg.yaml
sed -i "s/<UPF_N4>/$UPF_N4_IP/g" $DEST_DIR/upfcfg.yaml
sed -i "s/<UPF_N6>/$UPF_N6_IP/g" $DEST_DIR/smfcfg.yaml

sed -i "s/<PSAUPF_N4>/$PSAUPF_N4_IP/g" $DEST_DIR/smfcfg.yaml
sed -i "s/<PSAUPF_N9>/$PSAUPF_N9_IP/g" $DEST_DIR/smfcfg.yaml

echo Done
