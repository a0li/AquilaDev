#!/bin/bash

TMP_FOLDER=$(mktemp -d)
COIN_DAEMON='aqad'
COIN_CLI='aqa-cli'
OLDCLI='/usr/local/bin/aqa-cli'
OLDDAEMON='/usr/local/bin/aqad'
COIN_PATH='/usr/local/bin/'
COIN_TGZ='https://github.com/aquilacoin/Aquila/releases/download/1.1.0/Aqa-1.1-linux.tar.gz'
COIN_ZIP=$(echo $COIN_TGZ | awk -F'/' '{print $NF}')
COIN_NAME='aqa'


RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

function download_node() {
  systemctl stop aqa 
  echo -e "Preparing to upgrade ${GREEN}$COIN_NAME${NC}."
  cd $TMP_FOLDER >/dev/null 2>&1
  rm $COIN_ZIP >/dev/null 2>&1
  wget -q $COIN_TGZ
  compile_error
  tar xvzf $COIN_ZIP >/dev/null 2>&1
  chmod +x $COIN_DAEMON $COIN_CLI
  compile_error
  rm $OLDCLI
  rm $OLDDAEMON
  cp $COIN_DAEMON $COIN_CLI $COIN_PATH
  cd - >/dev/null 2>&1
  rm -rf $TMP_FOLDER >/dev/null 2>&1
  clear
}

function compile_error() {
if [ "$?" -gt "0" ];
 then
  echo -e "${RED}Failed to compile $COIN_NAME. Please investigate.${NC}"
  exit 1
fi
}

function configure_systemd() {
  systemctl daemon-reload
  sleep 3
  systemctl start $COIN_NAME.service
}

function finishedsetup() {
  echo -e "Finished! Masternode started. Please confirm status"
}

function setup_node() {
  configure_systemd
  finishedsetup
}


##### Main #####
clear

download_node
setup_node
