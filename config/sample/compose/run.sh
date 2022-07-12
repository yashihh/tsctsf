#!/bin/bash
ACTION=${1}
WORKING_DIR=${2-"/opt/free5gc/sandbox"}
HOST_IP_FILE="${WORKING_DIR}/host"
FCLI_DIR=${WORKING_DIR}/../
ENV_FILE=${WORKING_DIR}/../.adminrc

MODEL=${3:-"cupf"}
ENV=${4:-"product"}

usage() {
    echo "Usage: $0 <start|stop|restart> <WORKING_DIR> <cupf|goupf|gogtpu> <drone|product>"
}

get_host_ip() {
    HOST_IP=$(ip route get 8.8.8.8 | grep -v cache | awk '{print $7}')
    if [ ! -f "${HOST_IP_FILE}" ]; then
        touch ${HOST_IP_FILE}
        echo ${HOST_IP} >${HOST_IP_FILE}
    fi
}

setup_config_files() {
    echo "setup_config_files()"
    ./gen_resource.sh
}

do_start() {
    echo "Entering do_start()"
    do_stop
    get_host_ip
    setup_config_files
    cd ${WORKING_DIR}
    dcf=""
    if [ "x${MODEL}" == "xcupf" ]; then
        docker-compose up -d
    elif [ "x${MODEL}" == "xgoupf" ]; then
        dcf="docker-compose-goupf-multi-DNN.yaml"

        # AWS
        if [ "x${ENV}" != "xdrone" ]; then
            dcf="docker-compose-goupf.yaml"
        fi

        sleep 1
        docker-compose --env-file ${WORKING_DIR}/dockerComposeEnv -f $dcf up -d
    elif [ "x${MODEL}" == "xgogtpu" ]; then
        dcf="docker-compose-gtpu.yaml"
        docker-compose --env-file ${ENV_FILE} -f $dcf up -d
    fi

    # AWS
    if [ "x${ENV}" != "xdrone" ]; then
        cd $FCLI_DIR
        ./dump-server &
        docker-compose --env-file ${WORKING_DIR}/dockerComposeEnv -f docker-compose-management.yaml up -d
        date "+%s" 2>&1 >${FCLI_DIR}/start_time
    fi
    echo "End of do_start()"
}

do_stop() {
    echo "Entering do_stop()"
    if [ "x${ENV}" != "xdrone" ]; then
        cd $FCLI_DIR
        docker-compose -f docker-compose-management.yaml down --remove-orphans
    fi
    cd ${WORKING_DIR}
    if [ "x${MODEL}" == "xcupf" ]; then
        docker-compose down --remove-orphans
    elif [ "x${MODEL}" == "xgoupf" ]; then
        dcf="docker-compose-goupf-multi-DNN.yaml"

        # AWS
        if [ "x${ENV}" != "xdrone" ]; then
            dcf="docker-compose-goupf.yaml"
        fi

        docker-compose -f $dcf down --remove-orphans
    elif [ "x${MODEL}" == "xgogtpu" ]; then
        docker-compose -f docker-compose-gtpu.yaml down --remove-orphans
    fi
    cd -
    echo "End of do_stop()"
}

#vaildate
if [ "x${MODEL}" != "xgoupf" ] && [ "x${MODEL}" != "xcupf" ] && [ "x${MODEL}" != "xgogtpu" ]; then
    echo "WARN: MODELiroment should be cupf or gogtpu"
    usage
    exit 1
fi
if [[ ${ACTION} == "start" ]]; then
    if [[ "x${MODEL}" == "xgogtpu" ]] && [[ "x${N3_IP}" == "x" || "x${N6_IP}" == "x" || "x${N9_IP}" == "x" ]]; then
        echo "WARN: gogtpu mode should assign N3, N6 and N9 IP for dpdk"
        usage
        exit 1
    fi
fi
echo "System Information: "
echo "*****************************"
echo "MODEL:${MODEL}"
echo "ACTION:" ${ACTION}
echo "*****************************"

case "$ACTION" in
    start)
        do_start
        ;;
    stop)
        do_stop
        ;;
    restart)
        do_start
        ;;
    setup)
        setup_config_files
        ;;
    *)
        usage
        ;;
esac