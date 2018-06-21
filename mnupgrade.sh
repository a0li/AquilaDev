#!/bin/bash

TMP_FOLDER=$(mktemp -d)
CONFIG_FILE='/root/.aqa/aqa.conf'
MNCONFIG_FILE='/root/.aqa/masternode.conf'
BKUP_FOLDER='/root/aqabkup'
CONFIGFOLDER='/root/.aqa'
COIN_DAEMON='aqad'
COIN_CLI='aqa-cli'
COIN_PATH='/usr/local/bin/'
OLDCLI='/usr/local/bin/aqa-cli'
OLDDAEMON='/usr/local/bin/aqad'
COIN_TGZ='https://github.com/aquilacoin/Aquila/releases/download/1.1.0/Aqa-1.1-linux.tar.gz'
COIN_ZIP=$(echo $COIN_TGZ | awk -F'/' '{print $NF}')
COIN_NAME='aqa'


NODEIP=$(curl -s4 icanhazip.com)


RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

function download_node() {
  systemctl stop aqa 
  echo -e "Preparing to download ${GREEN}$COIN_NAME${NC}."
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

function downloadconf() {
  cd . 
  mkdir aqabkup
  cp $CONFIG_FILE $BKUP_FOLDER
  cp $MNCONFIG_FILE $BKUP_FOLDER
  cp -r '/root/.aqa/blocks' $BKUP_FOLDER
  rm -r $CONFIGFOLDER
  mkdir $CONFIGFOLDER
  cp '/root/aqabkup/masternode.conf' $CONFIGFOLDER
  cp '/root/aqabkup/aqa.conf' $CONFIGFOLDER
  cp -r '/root/.aqa/blocks' $CONFIGFOLDER
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

function setup_node() {
  configure_systemd
}


##### Main #####
clear

download_node
downloadconf
setup_node
