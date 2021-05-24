#!/bin/bash
clear
# Otetaan talteen se hakemistopolku, jossa ajossa oleva skripti sijaitsee. Esim. /home/user/usb-paahdin
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo -e "\e[1m\e[7m  ABITTI-tikkuohjelma aka USB-paahdin  \e[0m"
echo "Kumpi levykuva päivitetään?"
select yn in "Opiskelijan tikut" "Palvelimen tikut"; do
	case $yn in
		"Opiskelijan tikut")
			action='updateStudent'
			. ${DIR}/script.sh
			break
			;;
		"Palvelimen tikut")
			action='updateServer'
			. ${DIR}/script.sh
			break
			;;
	esac
done