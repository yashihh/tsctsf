#!/bin/bash

SCRIPT_DIR="$(
    cd -- "$(dirname "$0")" >/dev/null 2>&1
    pwd -P
)"
TEMPLATE_DIR=$SCRIPT_DIR/template
DEFAULT_PARAM=$SCRIPT_DIR/parameter/default
ADMIN_RC=$DEFAULT_PARAM
ADMIN_RC_TMP=$SCRIPT_DIR/.adminrc.tmp
VARIABLES_FILE=""
DEST_DIR=$SCRIPT_DIR
USAGE_MSG="Usage: \n\
           Default:\t${0} [-p|--parameter <parameter_file_path>] [-o|--output <output_dir>] \n\
           Landslide:\t${0} -landslide \n\
           \t\t${0} -landslide -newip \n\
           \t\t${0} -landslide -n3iwf \n\
           \t\t${0} -landslide -n3iwf -newip \n\
           \t\t${0} -landslide -free5gc_iupf \n\
           \t\t${0} -landslide -free5gc_iupf -dnai \n\
           Compose:\t${0} -compose [-o|--output <output_dir>]"

TEMPLATE_FILES=""
TEMPLATE_FILES+=" amfcfg.template.yaml"
TEMPLATE_FILES+=" ausfcfg.template.yaml"
#TEMPLATE_FILES+=" cmscfg.template.yaml"
TEMPLATE_FILES+=" nrfcfg.template.yaml"
TEMPLATE_FILES+=" nssfcfg.template.yaml"
TEMPLATE_FILES+=" pcfcfg.template.yaml"
TEMPLATE_FILES+=" udmcfg.template.yaml"
TEMPLATE_FILES+=" udrcfg.template.yaml"
TEMPLATE_FILES+=" uerouting.template.yaml"
TEMPLATE_FILES+=" n3iwfcfg.template.yaml"
TEMPLATE_FILES+=" smfcfg.template.yaml"   # Compose[AWS, go-gtpu(TBD)], Landslide
#TEMPLATE_FILES+=" goupfcfg.template.yaml"
#TEMPLATE_FILES+=" goupfcfg.gtpu.template.yaml"
#TEMPLATE_FILES+=" gtpucfg.template.yaml"
#TEMPLATE_FILES+=" nat.template.json"
TEMPLATE_FILES+=" webuicfg.template.yaml"

if [ -f $ADMIN_RC_TMP ]; then
    rm $ADMIN_RC_TMP
fi
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
                F5GC_IUPF=true
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
                ;;
        esac
        shift
    done
fi


PARA_FILE=''
# MODE order: landslide, n3iwf, newip, iupf, psaupf, dnai
[ "$COMPOSE"   = true ] && PARA_FILE="compose.template"
[ "$LANDSLIDE" = true ] && PARA_FILE="${PARA_FILE}landslide"
[ "$N3IWF"     = true ] && PARA_FILE="${PARA_FILE}_n3iwf"
[ "$NEWIP"     = true ] && PARA_FILE="${PARA_FILE}_newip"
[ "$F5GC_IUPF" = true ] && PARA_FILE="${PARA_FILE}_iupf"
[ "$PSAUPF"    = true ] && PARA_FILE="${PARA_FILE}_psaupf"
[ "$DNAI"      = true ] && PARA_FILE="${PARA_FILE}_dnai"

override_default_param() {
        CUSTOM_FILE=$1
        sed -i '/^#/d' $CUSTOM_FILE
        sed -i '/^$/d' $CUSTOM_FILE
        CUSTOM_VARS=(`awk -F = '{print $1}' $CUSTOM_FILE |awk NF`)

        for i in "${!CUSTOM_VARS[@]}"
        do
                #echo "{CUSTOM_VARS[$i]}=${CUSTOM_VARS[$i]}"
                # Delete the line of overlapping
                sed -i "/${CUSTOM_VARS[$i]}/d"  $ADMIN_RC_TMP
        done
        cat $CUSTOM_FILE >> $ADMIN_RC_TMP
}

replace_variables() {
        TARGET_FILE=$1
        VAR_FILE=$2
        if [ -f $VAR_FILE ]; then
                TMP_FILE=`mktemp`
                cp  $VAR_FILE  $TMP_FILE
                sed -i '/^#/d' $TMP_FILE
                sed -i '/^$/d' $TMP_FILE
                source $TMP_FILE
                VARS=(`awk -F = '{print $1}' $TMP_FILE |awk NF`)
                for i in "${!VARS[@]}"
                do
                        VALUE=`echo ${VARS[$i]}`
                        sed -i "s|<${VARS[$i]}>|${!VALUE}|g" $TARGET_FILE
                done
                #FIXME
                sed -i "s|<HOST_IP>|$HOST_IP|g" $TARGET_FILE
                rm $TMP_FILE
        fi
}


if [[ -n $PARA_FILE ]]; then
    if [ "$P_MODE" = true ]; then
        echo "Do not indicate parameter file when using flag mode"
        exit 1
    fi
    if [ "$LANDSLIDE" = true ]; then
        echo "LANDSLIDE=$LANDSLIDE"
        TMP_LANDSLIDE=`mktemp`
        ADMIN_RC=$SCRIPT_DIR/parameter/landslide/$PARA_FILE
        cp  $ADMIN_RC  $TMP_LANDSLIDE
        # TODO: Check whether we still need the following two lines?
        VARIABLES_FILE=$SCRIPT_DIR/parameter/landslide/defaults
        replace_variables  $TMP_LANDSLIDE  $VARIABLES_FILE

        cp $DEFAULT_PARAM  $ADMIN_RC_TMP
        override_default_param $VARIABLES_FILE
        override_default_param $TMP_LANDSLIDE
        rm $TMP_LANDSLIDE

        TEMPLATE_FILES+=" upfcfg.template.yaml"
        TEMPLATE_FILES+=" smfcfg.iupf_template.yaml"
    elif [ "$COMPOSE" = true ]; then
        echo "COMPOSE=$COMPOSE"
        TMP_COMPOSE=`mktemp`
        if [ "x${SNSSAI_FMT}" == "xSST_ONLY" ]; then
            ADMIN_RC=$SCRIPT_DIR/parameter/compose.sstonly.template
        else
            ADMIN_RC=$SCRIPT_DIR/parameter/compose.template
        fi
        cp  $ADMIN_RC $TMP_COMPOSE
        VARIABLES_FILE=$SCRIPT_DIR/parameter/netprefix.compose
        replace_variables  $TMP_COMPOSE $VARIABLES_FILE
        cp $DEFAULT_PARAM  $ADMIN_RC_TMP
        override_default_param $TMP_COMPOSE
        rm $TMP_COMPOSE

        TEMPLATE_FILES+=" goupf1cfg.template.yaml"
        TEMPLATE_FILES+=" goupf2cfg.template.yaml"
        TEMPLATE_FILES+=" goupf3cfg.template.yaml"
        TEMPLATE_FILES+=" goupf4cfg.template.yaml"
        TEMPLATE_FILES+=" smf1cfg.template.yaml"
        TEMPLATE_FILES+=" smf2cfg.template.yaml"
        TEMPLATE_FILES+=" smfcfg.compose_template.yaml"
        echo "COMPOSE end"
    fi
else
    echo "LANDSLIDE=$LANDSLIDE"
    echo "COMPOSE=$COMPOSE"
    echo "P_MODE=$P_MODE"
    echo "ADMIN_RC=$ADMIN_RC"
    TEMPLATE_FILES+=" upfcfg.template.yaml"
    cp  $ADMIN_RC $ADMIN_RC_TMP
fi


if [ ! -f "$ADMIN_RC_TMP" ]; then
    echo "Parameter file( $ADMIN_RC_TMP ) does not exist."
    echo -e $USAGE_MSG
    exit 1
fi



source $ADMIN_RC_TMP
# WARNING: After sourcing $ADMIN_RC_TMP, be careful that variables may be overridden!
echo "Parameter file: $ADMIN_RC_TMP (from $ADMIN_RC)"
echo "Output directory: $DEST_DIR"
echo "Mode: $MODE."

handle_DNN_lists() {
    if [ $DNN_1 = $DNN_2 ]; then
        DNN_LIST=$DNN_1
    else
        DNN_LIST="${DNN_1},${DNN_2}"
    fi
    echo -e "\nDNN_LIST=$DNN_LIST" >> $ADMIN_RC_TMP
    
    if [ "x$MEC_DNN_1" != "x" ]; then
        MEC_DNN_1_ITEM="- dnn: $MEC_DNN_1"
        MEC_DNN_LIST="$MEC_DNN_1,"
    fi
    
    if [ "x$MEC_DNN_2" != "x" ]; then
        MEC_DNN_2_ITEM="- dnn: $MEC_DNN_2"
        if [ "x$MEC_DNN_2" != "x$MEC_DNN_1" ]; then
            MEC_DNN_LIST="$MEC_DNN_LIST$MEC_DNN_2,"
        fi
    fi
    echo "MEC_DNN_1_ITEM=\"$MEC_DNN_1_ITEM\"" >> $ADMIN_RC_TMP
    echo "MEC_DNN_2_ITEM=\"$MEC_DNN_2_ITEM\"" >> $ADMIN_RC_TMP
    echo "MEC_DNN_LIST=$MEC_DNN_LIST" >> $ADMIN_RC_TMP
}


collect_cfg_template_files() {
    mkdir -p $DEST_DIR
    rm -f $DEST_DIR/*.yaml
    for FILE in $TEMPLATE_FILES ; do
        cp $TEMPLATE_DIR/$FILE  $DEST_DIR
    done
    
    cd $SCRIPT_DIR
    for template_file in $(ls $DEST_DIR/ | grep -E 'template.yaml|template.json'); do
        newfile=$(echo $DEST_DIR/$template_file | sed 's/.template//g')
        mv $DEST_DIR/$template_file $newfile
    done
    
    if [ "$F5GC_IUPF" = true ]; then
        mv $DEST_DIR/smfcfg.iupf.yaml ${DEST_DIR}/smfcfg.yaml
    elif [ "$LANDSLIDE" = true ]; then
        rm $DEST_DIR/smfcfg.iupf.yaml
    elif [ "$COMPOSE" = true ]; then # COMPOSE
        cp $TEMPLATE_DIR/smfcfg.compose_template.yaml ${DEST_DIR}/smfcfg.yaml
    fi
}

replace_template_variables() {
    sed -i '/^#/d' $ADMIN_RC_TMP
    sed -i '/^$/d' $ADMIN_RC_TMP
    source $ADMIN_RC_TMP
    VARS=(`cut -d = -f1 $ADMIN_RC_TMP | awk NF`)
    
    #DBG_VARS=true
    for yaml_file in $(ls ${DEST_DIR}/ | grep -E '.yaml|.json'); do
        yaml_file=$DEST_DIR/$yaml_file

        for i in "${!VARS[@]}"
        do
                VALUE=`echo ${VARS[$i]}`
                if [ "x$DBG_VARS" == "xtrue" ]; then
                        echo "printenv ${VARS[i]} = `echo  ${!VALUE}`"
                fi
                sed -i "s|<${VARS[$i]}>|${!VALUE}|g" $yaml_file
        done
        DBG_VARS=false
    done
}

handle_DNN_lists
collect_cfg_template_files
replace_template_variables
echo Done
