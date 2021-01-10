#!/bin/bash

#find ./free5gc/NFs -type f -name go.mod -exec cat {} + | sed -E '/^(require|go|module|\)|replace)/d' | awk '{ print "https://"$1 }'| sort -u | grep bitbucket | xargs -l1 git clone

NF_PATH=./NFs
OUTPUT_FOLDER=./packages

[[ "$PWD" =~ "infra" ]] && NF_PATH=../NFs
[[ "$PWD" =~ "infra" ]] && OUTPUT_FOLDER=../packages

pkg_all=""
for d in ${NF_PATH}/*; do cd $d ; pkg=$(go list -m all | grep free5gc | awk 'NR>2 {print "https://"$1}') ; pkg_all="${pkg} ${pkg_all}" ; cd ~-; done

rm -r ${OUTPUT_FOLDER}
mkdir -p ${OUTPUT_FOLDER} && cd ${OUTPUT_FOLDER}
echo $pkg_all | tr " " "\n" | sort -u | xargs -l1 git clone
echo "All packages clone to ${PWD} done."

