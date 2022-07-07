#!/bin/bash 
HOST_IP="127.0.0.1"
SBI_PREFIX=${SBI_PREFIX:-"10.100.200"}
N3_NETWORK_PREFIX=${N3_NETWORK_PREFIX:-"172.16.3"}
N6_NETWORK_PREFIX=${N6_NETWORK_PREFIX:-"172.16.6"}
N9_NETWORK_PREFIX=${N9_NETWORK_PREFIX:-"172.16.9"}
IKE_NETWORK_PREFIX=${IKE_NETWORK_PREFIX:-"172.16.2"}
ADMIN_RC_FILE=${PWD}/.adminrc
COMPOSE_RC=${PWD}/.compose
SANDBOX=${PWD}/sandbox
COMPOSE_ENV_TEMPLATE=${SANDBOX}/.env.template
COMPOSE_ENV=${SANDBOX}/.env
if [ -f ${SANDBOX}/host ]; then 
   HOST_IP=$( cat ${SANDBOX}/host )
fi

if [ ! -f config.sh ];then
   ./prepare.sh
fi  


cp parameter/compose.template $ADMIN_RC_FILE
source $COMPOSE_RC

sed -i "s/<HOST_IP>/$HOST_IP/g" $ADMIN_RC_FILE
sed -i "s/<SBI_PREFIX>/$SBI_PREFIX/g" $ADMIN_RC_FILE
sed -i "s/<N3_NETWORK_PREFIX>/$N3_NETWORK_PREFIX/g" $ADMIN_RC_FILE
sed -i "s/<N6_NETWORK_PREFIX>/$N6_NETWORK_PREFIX/g" $ADMIN_RC_FILE
sed -i "s/<N9_NETWORK_PREFIX>/$N9_NETWORK_PREFIX/g" $ADMIN_RC_FILE
sed -i "s/<IKE_NETWORK_PREFIX>/$IKE_NETWORK_PREFIX/g" $ADMIN_RC_FILE

./config.sh -compose -o out
mv out/*.yaml sandbox
rm -rf out

cp ${COMPOSE_ENV_TEMPLATE} ${COMPOSE_ENV}

sed -i "s/<HOST_IP>/$HOST_IP/g"  ${COMPOSE_ENV}
sed -i "s/<SBI_PREFIX>/$SBI_PREFIX/g"  ${COMPOSE_ENV}
target_sed=$(echo $SANDBOX |sed -e 's/\//\\\//g')
sed -i "s/<SANDBOX>/'$target_sed'/g"  ${COMPOSE_ENV}