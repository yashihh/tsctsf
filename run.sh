#!/usr/bin/env bash

LOG_PATH="./log/"
LOG_NAME="free5gc.log"
TODAY=$(date +"%Y%m%d_%H%M%S")
PCAP_MODE=0

PID_LIST=()

if [ $# -ne 0 ]; then
    while [ $# -gt 0 ]; do
        case $1 in
            -p)
                shift
                case $1 in
                    -*)
                        continue ;;
                    *)
                        if [ "$1" != "" ];
                        then
                            LOG_PATH=$1
                        fi
                esac ;;
            -cp)
                shift
                case $1 in
                    -dp)
                        PCAP_MODE=3 ;;
                    *)
                        PCAP_MODE=1
                esac ;;
            -dp)
                shift
                case $1 in
                    -cp)
                        PCAP_MODE=3 ;;
                    *)
                        PCAP_MODE=2
                esac ;;
        esac
        shift
    done
fi

LOG_PATH=${LOG_PATH%/}"/"${TODAY}"/"
echo "log path: $LOG_PATH"

if [ ! -d ${LOG_PATH} ]; then
    mkdir -p ${LOG_PATH}
fi

if [ $PCAP_MODE -ne 0 ]; then
    PCAP=${LOG_PATH}free5gc.pcap
    case $PCAP_MODE in
        1)  # -cp
            sudo tcpdump -i any 'sctp port 38412 || tcp port 8000 || udp port 8805' -w ${PCAP} & ;;
        2)  # -dp
            sudo tcpdump -i any 'udp port 2152' -w ${PCAP} & ;;
        3)  # -cp -dp or -dp -cp
            sudo tcpdump -i any 'sctp port 38412 || tcp port 8000 || udp port 8805 || udp port 2152' -w ${PCAP} &
    esac

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
