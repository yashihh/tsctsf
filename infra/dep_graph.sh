#!/bin/bash

# You must get packet first:
# go get github.com/poloxue/modv
# sudo apt install graphviz

export PATH=$PATH:`go env GOPATH`/bin
graph_path=`pwd`/graph
root_path=`pwd`

rm all.txt
mkdir -p ${graph_path}

for nf_path in ../NFs/*
do
    nf=${nf_path##*/}
    echo "Generating ${nf^^}'s depency graph."
    cd ${root_path}/${nf_path}
    go mod graph | grep bitbucket.org | grep -v testify | grep -v yaml | grep -v logrus | grep -v net | grep -v github | grep -v golang |  modv | dot -Tpng -o ${graph_path}/${nf}.png
    #go mod graph | grep bitbucket.org | grep -v CommonConsumerTestData | sed "s/@.*\ /\ /" | sed "s/@.*//g" | awk '$0 ~ /bitbucket.*\ bitbucket/{print}' | sed "s/bitbucket.org\/free5gc-team\///g" >> ${root_path}/all.txt
done

