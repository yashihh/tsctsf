#!/bin/bash
COMPOSE_RC=${PWD}/netprefix.compose
source $COMPOSE_RC
HOST_IP="127.0.0.1"
SBI_PREFIX=${SBI_PREFIX:-"10.100.200"}
N6_NETWORK_PREFIX=${N6_NETWORK_PREFIX:-"172.16.6"}

ADMIN_RC_FILE=${PWD}/.adminrc
SANDBOX=${PWD}/sandbox
COMPOSE_ENV_TEMPLATE=${SANDBOX}/dockerComposeEnv.template
COMPOSE_ENV=${SANDBOX}/dockerComposeEnv

if [ -f ${SANDBOX}/host ]; then
    HOST_IP=$(cat ${SANDBOX}/host)
fi

if [ ! -f config.sh ]; then
    ./prepare.sh
fi


if [ "x${SNSSAI_FMT}" == "xSST_ONLY" ]; then
    cp parameter/compose.sstonly.template $ADMIN_RC_FILE
else
    cp parameter/compose.template $ADMIN_RC_FILE
fi

sed -i "s/<HOST_IP>/$HOST_IP/g" $ADMIN_RC_FILE
sed -i "s/<SBI_PREFIX>/$SBI_PREFIX/g" $ADMIN_RC_FILE

sed -i "s/<N3_NET1_PREFIX>/$N3_NET1_PREFIX/g" $ADMIN_RC_FILE
sed -i "s/<N3_NET2_PREFIX>/$N3_NET2_PREFIX/g" $ADMIN_RC_FILE
sed -i "s/<N3_NET3_PREFIX>/$N3_NET3_PREFIX/g" $ADMIN_RC_FILE

sed -i "s/<N4_NET1_PREFIX>/$N4_NET1_PREFIX/g" $ADMIN_RC_FILE
sed -i "s/<N4_NET2_PREFIX>/$N4_NET2_PREFIX/g" $ADMIN_RC_FILE
sed -i "s/<N4_NET3_PREFIX>/$N4_NET3_PREFIX/g" $ADMIN_RC_FILE

sed -i "s/<N6_NETWORK_PREFIX>/$N6_NETWORK_PREFIX/g" $ADMIN_RC_FILE
sed -i "s/<N6_NET1_PREFIX>/$N6_NET1_PREFIX/g" $ADMIN_RC_FILE
sed -i "s/<N6_NET2_PREFIX>/$N6_NET2_PREFIX/g" $ADMIN_RC_FILE
sed -i "s/<N6_NET3_PREFIX>/$N6_NET3_PREFIX/g" $ADMIN_RC_FILE
sed -i "s/<N6_NET4_PREFIX>/$N6_NET4_PREFIX/g" $ADMIN_RC_FILE
sed -i "s/<N6_NET5_PREFIX>/$N6_NET5_PREFIX/g" $ADMIN_RC_FILE

sed -i "s/<N9_NET1_PREFIX>/$N9_NET1_PREFIX/g" $ADMIN_RC_FILE

sed -i "s/<IKE_NET_PREFIX>/$IKE_NET_PREFIX/g" $ADMIN_RC_FILE
sed -i "s/<N3IWF_IKE_BIND_IP>/$N3IWF_IKE_BIND_IP/g" $ADMIN_RC_FILE
sed -i "s/<N3IWF_N3_IP>/$N3IWF_N3_IP/g" $ADMIN_RC_FILE

./config.sh -compose -o out
mv out/*.yaml sandbox
rm -rf out

cp ${COMPOSE_ENV_TEMPLATE} ${COMPOSE_ENV}

sed -i "s/<HOST_IP>/$HOST_IP/g" ${COMPOSE_ENV}
sed -i "s/<SBI_PREFIX>/$SBI_PREFIX/g" ${COMPOSE_ENV}

sed -i "s/<N3_NET1_PREFIX>/$N3_NET1_PREFIX/g" ${COMPOSE_ENV}
sed -i "s/<N3_NET2_PREFIX>/$N3_NET2_PREFIX/g" ${COMPOSE_ENV}
sed -i "s/<N3_NET3_PREFIX>/$N3_NET3_PREFIX/g" ${COMPOSE_ENV}

sed -i "s/<N4_NET1_PREFIX>/$N4_NET1_PREFIX/g" ${COMPOSE_ENV}
sed -i "s/<N4_NET2_PREFIX>/$N4_NET2_PREFIX/g" ${COMPOSE_ENV}
sed -i "s/<N4_NET3_PREFIX>/$N4_NET3_PREFIX/g" ${COMPOSE_ENV}

sed -i "s/<N6_NETWORK_PREFIX>/$N6_NETWORK_PREFIX/g" ${COMPOSE_ENV}
sed -i "s/<N6_NET1_PREFIX>/$N6_NET1_PREFIX/g" ${COMPOSE_ENV}
sed -i "s/<N6_NET2_PREFIX>/$N6_NET2_PREFIX/g" ${COMPOSE_ENV}
sed -i "s/<N6_NET3_PREFIX>/$N6_NET3_PREFIX/g" ${COMPOSE_ENV}
sed -i "s/<N6_NET4_PREFIX>/$N6_NET4_PREFIX/g" ${COMPOSE_ENV}
sed -i "s/<N6_NET5_PREFIX>/$N6_NET5_PREFIX/g" ${COMPOSE_ENV}

sed -i "s/<N9_NET1_PREFIX>/$N9_NET1_PREFIX/g" ${COMPOSE_ENV}

sed -i "s/<IKE_NET_PREFIX>/$IKE_NET_PREFIX/g" ${COMPOSE_ENV}
sed -i "s/<N3IWF_IKE_BIND_IP>/$N3IWF_IKE_BIND_IP/g" ${COMPOSE_ENV}
sed -i "s/<N3IWF_N3_IP>/$N3IWF_N3_IP/g" ${COMPOSE_ENV}

target_sed=$(echo $SANDBOX | sed -e 's/\//\\\//g')
sed -i "s/<SANDBOX>/$target_sed/g" ${COMPOSE_ENV}