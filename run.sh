#!/usr/bin/env bash

LOG_PATH="./log/"
LOG_NAME="free5gc.log"
PCAP_NAME=""
TODAY=$(date +"%Y%m%d%H%M%S")

PID_LIST=()

if [ $# -ne 0 ]; then
    while [ $# -gt 0 ]; do
        case $1 in
            -logpath)
                shift
                LOG_PATH=$1 ;;
            -logname)
                shift
                LOG_NAME=$1 ;;
            -pcapname)
                shift
                PCAP_NAME=$1 ;;
        esac
        shift
    done
fi

LOG_PATH=${LOG_PATH}${TODAY}"/"

if [ ! -d ${LOG_PATH} ]; then
    mkdir -p ${LOG_PATH}
fi

cd NFs/upf/build
sudo -E ./bin/free5gc-upfd &
PID_LIST+=($!)

sleep 1

cd ../../..

NF_LIST="nrf amf smf udr pcf udm nssf ausf"

export GIN_MODE=release

for NF in ${NF_LIST}; do
    ./bin/${NF} &
    PID_LIST+=($!)
    sleep 0.1
done

sudo ./bin/n3iwf &
SUDO_N3IWF_PID=$!
sleep 1
N3IWF_PID=$(pgrep -P $SUDO_N3IWF_PID)
PID_LIST+=($SUDO_N3IWF_PID $N3IWF_PID)

if [ "${PCAP_NAME}" != "" ]; then
    sudo tcpdump -i any -w ${LOG_PATH}${PCAP_NAME} &
    PID_LIST+=($!)
fi

function terminate()
{
    sudo kill -SIGTERM ${PID_LIST[${#PID_LIST[@]}-2]} ${PID_LIST[${#PID_LIST[@]}-1]}
    sleep 2
}

trap terminate SIGINT
wait ${PID_LIST}
