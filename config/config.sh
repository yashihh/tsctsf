#!/bin/bash

SCRIPT_DIR="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
TEMPLATE_DIR=$SCRIPT_DIR/template
ADMIN_RC=$SCRIPT_DIR/parameter/default
DEST_DIR=$SCRIPT_DIR
USAGE_MSG="Usage: \n\
           Default:\t${0} [-p|--parameter <parameter_file_path>] [-o|--output <output_dir>] \n\
           Landslide:\t${0} -landslide \n\
           \t\t${0} -landslide -newip \n\
           \t\t${0} -landslide -n3iwf \n\
           \t\t${0} -landslide -n3iwf -newip \n\
           \t\t${0} -landslide -free5gc_iupf \n\
           \t\t${0} -landslide -free5gc_iupf -dnai \n\
           \t\t${0} -landslide -psaupf \n\
           Compose:\t${0} -compose"

# echo -e $USAGE_MSG

if [ $# -ne 0 ]; then
    while [ $# -gt 0 ]; do
        case $1 in
            -landslide)
                LANDSLIDE=true
                ;;
            -n3iwf)
                N3IWF=true
                ;;
            -newip)
                NEWIP=true
                ;;
            -free5gc_iupf)
                IUPF=true
                ;;
            -psaupf)
                PSAUPF=true
                ;;
            -dnai)
                DNAI=true
                ;;
            -compose)
                COMPOSE=true
                ;;
            -p | --parameter)
                P_MODE=true
                ADMIN_RC=$2
                shift
                ;;
            -o | --output)
                DEST_DIR=$2
                shift
                ;;
            *)
                echo -e $USAGE_MSG
                exit 1
        esac
        shift
    done
fi

PARA_FILE=''
# MODE order: landslide n3iwf newip iupf psaupf dnai 
[ "$COMPOSE" = true ] && PARA_FILE="compose"
[ "$LANDSLIDE" = true ] && PARA_FILE="${PARA_FILE}landslide"
[ "$N3IWF" = true ] && PARA_FILE="${PARA_FILE}_n3iwf"
[ "$NEWIP" = true ] && PARA_FILE="${PARA_FILE}_newip"
[ "$IUPF" = true ] && PARA_FILE="${PARA_FILE}_iupf"
[ "$PSAUPF" = true ] && PARA_FILE="${PARA_FILE}_psaupf"
[ "$DNAI" = true ] && PARA_FILE="${PARA_FILE}_dnai"

if [[ -n $PARA_FILE ]];then
    if [ "$P_MODE" = true ]; then
        echo "Do not indicate parameter file when using flag mode"
        exit 1
    fi
    if [ "$LANDSLIDE" = true ]; then
        ADMIN_RC=$SCRIPT_DIR/parameter/landslide/$PARA_FILE
    elif [ "$COMPOSE" = true ]; then
        ADMIN_RC=$SCRIPT_DIR/.adminrc
    else
        ADMIN_RC=$SCRIPT_DIR/parameter/$PARA_FILE
    fi
fi

if [ ! -f "$ADMIN_RC" ]; then
    echo "Parameter file($ADMIN_RC) does not exist."
    echo -e $USAGE_MSG
    exit 1
fi

source $ADMIN_RC
echo "Parameter file: $ADMIN_RC"
echo "Output directory: $DEST_DIR"
echo "Mode: $MODE"

MCC=${MCC:-"208"}
MNC=${MNC:-"93"}
TAC=${TAC:-"000001"}
S_NSSAI_SST_1=${S_NSSAI_SST_1:-"1"}
S_NSSAI_SD_1=${S_NSSAI_SD_1:-"010203"}
DNN_1=${DNN_1:-"internet"}
MEC_DNN_1=${MEC_DNN_1:-"mec"}
MEC_DNN_CMT_1=${MEC_DNN_CMT_1-""}
DNAI_LIST_1=${DNAI_LIST_1:-"DNAI_MEC"}
DNAI_LIST_CMT_1=${DNAI_LIST_CMT_1-"# "}
IP_POOLS_1=${IP_POOLS_1:-"10.60.0.0/15"}
STATIC_IP_POOLS_1=${STATIC_IP_POOLS_1:-"10.60.100.0/24"}
S_NSSAI_SST_2=${S_NSSAI_SST_2:-"1"}
S_NSSAI_SD_2=${S_NSSAI_SD_2:-"112233"}
DNN_2=${DNN_2:-"internet1"}
MEC_DNN_2=${MEC_DNN_2:-"mec"}
MEC_DNN_CMT_2=${MEC_DNN_CMT_2-""}
DNAI_LIST_2=${DNAI_LIST_2:-"DNAI_MEC"}
DNAI_LIST_CMT_2=${DNAI_LIST_CMT_2-"# "}
IP_POOLS_2=${IP_POOLS_2:-"10.62.0.0/15"}
STATIC_IP_POOLS_2=${STATIC_IP_POOLS_2:-"10.62.100.0/24"}
NIA_LIST=${NIA_LIST:-"NIA2"}
NEA_LIST=${NEA_LIST:-"NEA0"}

SBI_PREFIX=${SBI_PREFIX-""}
NRF_CMT=${NRF_CMT-""}
AMF_N2_IP=${AMF_N2_IP:-127.0.0.18}
UPF_N3_IP=${UPF_N3_IP:-127.0.0.8}
UPF_N4_IP=${UPF_N4_IP:-127.0.0.8}
SMF_N4_IP=${SMF_N4_IP:-127.0.0.7}
IUPF_N3_IP=${IUPF_N3_IP:-172.16.3.110}
IUPF_N9_IP=${IUPF_N9_IP:-172.16.9.110}
PSAUPF_N4_IP=${PSAUPF_N4_IP:-172.16.4.111}
PSAUPF_N9_IP=${PSAUPF_N9_IP:-172.16.9.111}
IKE_BIND_IP=${IKE_BIND_IP:-172.16.2.110}
HOST_IP=${HOST_IP:-""}
MONGO_DB=${MONGO_DB:-"localhost"}

if [ $DNN_1 = $DNN_2 ]; then
    DNN_LIST=$DNN_1
else
    DNN_LIST="[${DNN_1},${DNN_2}]"
fi

if [ $MEC_DNN_1 = $MEC_DNN_2 ]; then
    MEC_DNN_LIST="${MEC_DNN_CMT_1}- ${MEC_DNN_1}"
else
    MEC_DNN_LIST="${MEC_DNN_CMT_1}- ${MEC_DNN_1}\n              ${MEC_DNN_CMT_2}- ${MEC_DNN_2}"
fi

# echo $USAGE_MSG

mkdir -p $DEST_DIR
rm -f $DEST_DIR/*.yaml
cp $TEMPLATE_DIR/*.template.yaml $DEST_DIR
cd $SCRIPT_DIR

for template_file in `ls $DEST_DIR/| grep template.yaml`
do
    newfile=`echo  $DEST_DIR/$template_file | sed 's/.template//g'`
    mv $DEST_DIR/$template_file $newfile
done

if [ "$IUPF" = true ]; then  # iUPF
    cp $TEMPLATE_DIR/smfcfg.iupf_template.yaml ${DEST_DIR}/smfcfg.yaml
fi

if [ "$COMPSE" = true ]; then  # COMPOSE
    cp $TEMPLATE_DIR/smfcfg.compose_template.yaml ${DEST_DIR}/smfcfg.yaml
fi

for yaml_file in `ls ${DEST_DIR}/ | grep .yaml`
do
    yaml_file=$DEST_DIR/$yaml_file
        sed -i "s/<MCC>/$MCC/g" $yaml_file
        sed -i "s/<MNC>/$MNC/g" $yaml_file
        sed -i "s/<TAC>/$TAC/g" $yaml_file
        sed -i "s/<S_NSSAI_SST_1>/$S_NSSAI_SST_1/g" $yaml_file
        sed -i "s/<S_NSSAI_SD_1>/$S_NSSAI_SD_1/g" $yaml_file
        sed -i "s/<DNN_1>/$DNN_1/g" $yaml_file
        sed -i "s/<MEC_DNN_1>/$MEC_DNN_1/g" $yaml_file
        sed -i "s/<MEC_DNN_CMT_1>/$MEC_DNN_CMT_1/g" $yaml_file
        sed -i "s/<DNAI_LIST_1>/$DNAI_LIST_1/g" $yaml_file
        sed -i "s/<DNAI_LIST_CMT_1>/$DNAI_LIST_CMT_1/g" $yaml_file
        sed -i "s,<IP_POOLS_1>,$IP_POOLS_1,g" $yaml_file
        sed -i "s,<STATIC_IP_POOLS_1>,$STATIC_IP_POOLS_1,g" $yaml_file
        sed -i "s/<S_NSSAI_SST_2>/$S_NSSAI_SST_2/g" $yaml_file
        sed -i "s/<S_NSSAI_SD_2>/$S_NSSAI_SD_2/g" $yaml_file
        sed -i "s/<DNN_2>/$DNN_2/g" $yaml_file
        sed -i "s/<MEC_DNN_2>/$MEC_DNN_2/g" $yaml_file
        sed -i "s/<MEC_DNN_CMT_2>/$MEC_DNN_CMT_2/g" $yaml_file
        sed -i "s/<DNAI_LIST_2>/$DNAI_LIST_2/g" $yaml_file
        sed -i "s/<DNAI_LIST_CMT_2>/$DNAI_LIST_CMT_2/g" $yaml_file
        sed -i "s,<IP_POOLS_2>,$IP_POOLS_2,g" $yaml_file
        sed -i "s,<STATIC_IP_POOLS_2>,$STATIC_IP_POOLS_2,g" $yaml_file
        sed -i "s/<DNN_LIST>/$DNN_LIST/g" $yaml_file
        sed -i "s/<MEC_DNN_LIST>/$MEC_DNN_LIST/g" $yaml_file
        sed -i "s/<NIA_LIST>/$NIA_LIST/g" $yaml_file
        sed -i "s/<NEA_LIST>/$NEA_LIST/g" $yaml_file

        sed -i "s/<NRF_CMT>/$NRF_CMT/g" $yaml_file
        sed -i "s/<MONGO_DB>/$MONGO_DB/g" $yaml_file

        sed -i "s/<SBI_PREFIX>/$SBI_PREFIX/g" $yaml_file
        sed -i "s/<HOST_IP>/$HOST_IP/g" $yaml_file
        sed -i "s/<AMF_N2_IP>/$AMF_N2_IP/g" $yaml_file
        sed -i "s/<UPF_N3_IP>/$UPF_N3_IP/g" $yaml_file
        sed -i "s/<UPF_N4_IP>/$UPF_N4_IP/g" $yaml_file
        sed -i "s/<IUPF_N3_IP>/$IUPF_N3_IP/g" $yaml_file
        sed -i "s/<IUPF_N9_IP>/$IUPF_N9_IP/g" $yaml_file
        sed -i "s/<PSAUPF_N4_IP>/$PSAUPF_N4_IP/g" $yaml_file
        sed -i "s/<PSAUPF_N9_IP>/$PSAUPF_N9_IP/g" $yaml_file
        sed -i "s/<MEC_DNN>/$MEC_DNN/g" $yaml_file
        sed -i "s/<SMF_N4_IP>/$SMF_N4_IP/g" $yaml_file
        sed -i "s/<IKE_BIND_IP>/$IKE_BIND_IP/g" $yaml_file
done

echo Done
