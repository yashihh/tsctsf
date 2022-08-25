#!/bin/bash
ACTION=${1}
WORKING_DIR=${2-"/opt/free5gc/sandbox"}
HOST_IP_FILE="${WORKING_DIR}/host"
FCLI_DIR=${WORKING_DIR}/../
ENV_FILE=${WORKING_DIR}/../.adminrc

usage() {
    echo "Usage: $0 <start|stop|restart> <WORKING_DIR>"
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
    dcf="docker-compose-goupf-multi-DNN.yaml"
    sleep 1
    docker-compose --env-file ${WORKING_DIR}/dockerComposeEnv -f $dcf up -d

    echo "End of do_start()"
}

do_stop() {
    echo "Entering do_stop()"
    cd ${WORKING_DIR}
    dcf="docker-compose-goupf-multi-DNN.yaml"
    docker-compose -f $dcf down --remove-orphans
    cd -
    echo "End of do_stop()"
}

echo "System Information: "
echo "*****************************"
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
