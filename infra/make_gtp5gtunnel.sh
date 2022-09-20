#!/bin/bash
CMD_FILE="gtp5g-tunnel"

[[ -d "go-gtp5gnl" ]] && rm -fr "go-gtp5gnl"
[[ -f "${CMD_FILE}" ]] && rm -f "${CMD_FILE}"

git clone https://github.com/free5gc/go-gtp5gnl.git "go-gtp5gnl"

mkdir "go-gtp5gnl/bin"
cd "go-gtp5gnl/cmd/gogtp5g-tunnel" &&  go build -o "../../bin/${CMD_FILE}" .
