#!/usr/bin/env bash

GITHUB_ROOT="$HOME/github/free5gc"
BITBUCKET_ROOT='.'

#OLDIFS="$IFS"

#IFS=$'\n'
#modules=`git config --file .gitmodules --get-regexp '\.path' | awk '{ print $2 }'`

#find ${GITHUB_ROOT} -type f -not -name '.git' -not -name '.gitmodules' -delete
# delete all files in GitHub except .git
#rsync -a --delete --exclude '.git' --exclude '.gitmodules' ./ ${GITHUB_ROOT}/

# Copy all files
rsync -atvz --delete \
--exclude '.git' \
--exclude '.gitmodules' \
--exclude '*.log' \
--exclude 'bitbucket-pipelines.yml' \
--exclude 'infra' \
--exclude 'log' \
--exclude 'release' \
--exclude 'bin' \
--exclude 'src/upf/build' \
--exclude 'webconsole/frontend/build' \
--exclude 'webconsole/frontend/node_modules' \
--exclude 'test_debug.sh' \
--exclude 'upf_release.sh' \
${BITBUCKET_ROOT}/ ${GITHUB_ROOT}/

# Delete *_test.go.old
find ${GITHUB_ROOT} -name *_test.go.old -type f -delete
#rsync -atvz --exclude .git/ --exclude .gitmodules ${BITBUCKET_ROOT}/ ${GITHUB_ROOT}/

#for module in ${modules};
#do
#	GITHUB_PATH="${GITHUB_ROOT}/${module}"
#	echo "==== Start ${GITHUB_PATH} ===="
#	mkdir -p ${GITHUB_PATH}
#	rm -rf ${GITHUB_PATH}/.[!.][!.git]* ${GITHUB_PATH}/*
#	rsync --exclude '.git' -rtv ${BITBUCKET_ROOT}/${module}/* ${GITHUB_PATH}
#	echo "==== end ===="
#done

#IFS=$OLDIFS
