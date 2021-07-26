#!/bin/bash

# https://stackoverflow.com/questions/59895/how-can-i-get-the-source-directory-of-a-bash-script-from-within-the-script-itsel

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
SRC_DIR=$SCRIPT_DIR/landslide
DEST_DIR=$SCRIPT_DIR/..

echo From $SRC_DIR
echo Copy $( ls $SRC_DIR )
echo To $DEST_DIR

cp $SRC_DIR/* $DEST_DIR

echo Done



