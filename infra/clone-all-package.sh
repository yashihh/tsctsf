#!/bin/bash

find ./free5gc/NFs -type f -name go.mod -exec cat {} + | sed -E '/^(require|go|module|\)|replace)/d' | awk '{ print "https://"$1 }'| sort -u | grep bitbucket | xargs -l1 git clone

