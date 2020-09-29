#!/bin/bash

# CRLF
git config --global core.autocrlf input
# Git Message template
cp ./gitmessage ~/.gitmessage
git config --global commit.templage ~/.gitmessage

# pre-commit hook
cp ./pre-commit ../.git/hooks/pre-commit

# go get with ssh
go env -w GOPRIVATE=bitbucket.org/free5gc-team/*
git config --global url."git@bitbucket.org:free5gc-team/".insteadOf https://bitbucket.org/free5gc-team/
