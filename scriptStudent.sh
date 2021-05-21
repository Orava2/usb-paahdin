#!/bin/bash
# Otetaan talteen se hakemistopolku, jossa ajossa oleva skripti sijaitsee. Esim. /home/user/usb-paahdin
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

action='writeStudent'
. ${DIR}/script.sh