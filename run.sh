#!/usr/bin/env bash

LOG_PATH="./log/"
LOG_NAME="free5gc.log"
PCAP_NAME=""
TODAY=$(date +"%Y%m%d_%H%M%S")

PID_LIST=()

if [ $# -ne 0 ]; then
    while [ $# -gt 0 ]; do
        case $1 in
            -p)
                shift
                LOG_PATH=$1 ;;
            -w)
                shift
                if [ "$1" != "" ];
                then
                    PCAP_NAME=$1
                else
                    PCAP_NAME=free5gc.pcap
                fi
        esac
        shift
    done
fi

LOG_PATH=${LOG_PATH%/}"/"${TODAY}"/"
echo "log path: $LOG_PATH"

if [ ! -d ${LOG_PATH} ]; then
    mkdir -p ${LOG_PATH}
fi

if [ "${PCAP_NAME}" != "" ]; then
    echo "tcpdump name: $PCAP_NAME"
    sudo tcpdump -i any -w ${LOG_PATH}${PCAP_NAME} &
    PID_LIST+=($!)
    sleep 0.1
fi

cd NFs/upf/build
sudo -E ./bin/free5gc-upfd &
PID_LIST+=($!)

sleep 1

cd ../../..

NF_LIST="nrf amf smf udr pcf udm nssf ausf"

export GIN_MODE=release

for NF in ${NF_LIST}; do
    ./bin/${NF} -l ${LOG_PATH}${NF}.log -lc ${LOG_PATH}${LOG_NAME} &
    PID_LIST+=($!)
    sleep 0.1
done

sudo ./bin/n3iwf -l ${LOG_PATH}n3iwf.log -lc ${LOG_PATH}${LOG_NAME} &
SUDO_N3IWF_PID=$!
sleep 1
N3IWF_PID=$(pgrep -P $SUDO_N3IWF_PID)
PID_LIST+=($SUDO_N3IWF_PID $N3IWF_PID)

function terminate()
{
    sudo kill -SIGTERM ${PID_LIST[${#PID_LIST[@]}-2]} ${PID_LIST[${#PID_LIST[@]}-1]}
    sleep 2
}

trap terminate SIGINT
wait ${PID_LIST}
