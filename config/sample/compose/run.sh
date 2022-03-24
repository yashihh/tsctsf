#!/bin/bash
ACTION=${1}
WORK_DIR=${2-"/opt/free5gc/sandbox"}
HOST_IP_FILE="${WORK_DIR}/host"
SMF_CONFIG_DIR="${WORK_DIR}/smfs/smf1/config"
GO_UPF_CONFIG_DIR="${WORK_DIR}/goupfs/"
GO_GTPU_CONFIG_DIR="${WORK_DIR}/gogtpus/"
FCLI_DIR=${WORK_DIR}/../

MODEL=${3:-"cupf"}
ENV=${4:-"product"}
N3_IP=${5}
N6_IP=${6}
N9_IP=${7}

usage () {
  echo "Usage: $0 <start|stop|restart> <WORK_DIR> <cupf|goupf|gogtpu> <drone|product> <N3_IP> <N6_IP> <N9_IP>" 
}

get_host_ip () {
    HOST_IP=$(ip route get 8.8.8.8 | grep -v cache | awk '{print $7}')
    if [ ! -f "${HOST_IP_FILE}" ];then
       touch ${HOST_IP_FILE}
       echo ${HOST_IP} > ${HOST_IP_FILE}
    fi
}

setup_config_file () { 
    HOST_IP=$(cat ${HOST_IP_FILE})
    if [ "x${MODEL}" == "xcupf"  ];then  
       cd ${SMF_CONFIG_DIR}
       sed -e "s|{{HOST_IP}}|$HOST_IP|g" smfcfg.yaml.template > smfcfg.yaml
    elif  [ "x${MODEL}" == "xgoupf"  ];then 
       cd ${SMF_CONFIG_DIR}
       sed -e "s|{{HOST_IP}}|$HOST_IP|g" smfcfg.goupf.yaml.template > smfcfg.goupf.yaml     
    elif  [ "x${MODEL}" == "xgogtpu"  ];then 
       cd ${SMF_CONFIG_DIR}
       sed -e "s|{{N3_IP}}|$N3_IP|g" \
           -e "s|{{N6_IP}}|$N6_IP|g" \
           -e "s|{{N9_IP}}|$N9_IP|g" \
       smfcfg.gtpu.yaml.template > smfcfg.gtpu.yaml  
       cd ${GO_GTPU_CONFIG_DIR}
       sed -e "s|{{N3_IP}}|$N3_IP|g" \
           -e "s|{{N6_IP}}|$N6_IP|g" \
           -e "s|{{N9_IP}}|$N9_IP|g" \
       gtpucfg.yaml.template > gtpucfg.yaml 
       cd ${GO_UPF_CONFIG_DIR}
       sed -e "s|{{N3_IP}}|$N3_IP|g" \
           -e "s|{{N6_IP}}|$N6_IP|g" \
           -e "s|{{N9_IP}}|$N9_IP|g" \
       goupfcfg.gtpu.yaml.template > goupfcfg.gtpu.yaml           
    fi
}


do_start() {
 do_stop
 cd ${WORK_DIR}
 get_host_ip
 setup_config_file
 cd ${WORK_DIR}
 if [ "x${MODEL}" == "xcupf" ]; then
     docker-compose -f docker-compose-drone.yaml up -d
 elif [ "x${MODEL}" == "xgoupf" ];then
     docker-compose -f docker-compose-goupf.yaml up  -d
 elif [ "x${MODEL}" == "xgogtpu" ];then
     docker-compose -f docker-compose-gtpu.yaml up  -d
 fi
 if [ "x${ENV}" != "xdrone" ];then
 cd $FCLI_DIR
./dump-server &
 docker-compose --MODEL-file ${WORK_DIR}/.MODEL -f docker-compose-fcli.yaml up  -d
 date "+%s" 2>&1 > ${FCLI_DIR}/start_time
 fi
}

do_stop() {
 if [ "x${ENV}" != "xdrone" ];then
    cd $FCLI_DIR
    docker-compose -f docker-compose-fcli.yaml down  --remove-orphans
 fi
 cd ${WORK_DIR}
 if [ "x${MODEL}" == "xcupf" ];then
     docker-compose -f docker-compose-drone.yaml down  --remove-orphans
 elif [ "x${MODEL}" == "xgoupf" ];then
     docker-compose -f docker-compose-goupf.yaml down  --remove-orphans
 elif [ "x${MODEL}" == "xgogtpu" ];then
     docker-compose -f docker-compose-gtpu.yaml down  --remove-orphans
 fi
}

#vaildate
if [ "x${MODEL}" != "xgoupf" ] && [ "x${MODEL}" != "xcupf" ] && [ "x${MODEL}" != "xgogtpu" ]  ;then
     echo "WARN: MODELiroment should be cupf or gogtpu"
     usage
     exit 1
fi 
if [[ ${ACTION} == "start" ]] ;then
  if [[ "x${MODEL}" == "xgogtpu" ]] && [[ "x${N3_IP}" == "x"  || "x${N6_IP}" == "x"  ||  "x${N9_IP}" == "x" ]]; then
      echo "WARN: gogtpu mode should assign N3, N6 and N9 IP for dpdk"
      usage
      exit 1
  fi 
fi
echo "System Information: "
echo "*****************************"
echo "MODEL:${MODEL}"
echo "ACTION:" ${ACTION}
echo "N3_IP:" ${N3_IP} 
echo "N6_IP:" ${N6_IP}
echo "N9_IP:" ${N9_IP}
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
  *)
    usage
esac
