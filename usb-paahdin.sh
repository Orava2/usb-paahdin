#!/bin/bash
 
function menu {
clear
echo -ne "\e[1m\e[7m  ABITTI-tikkuohjelma aka USB-paahdin  \e[0m
Valitse toiminto!
1) Kirjoita opiskelijan tikuiksi
2) Kirjoita palvelintikuiksi
3) Kirjoita vanha versio
4) Tarkista levykuvien päivitykset
5) Tarkista USB-paahtimen päivitykset
0) Lopeta\n"
echo -n "#? "
        read a
        case $a in
                1) ./scriptStudent.sh ;;
                2) ./scriptServer.sh ;;
                3) ./scriptOld.sh  ;;
                4) ./scriptUpdate.sh ; menu ;;
                5) ./updateScriptFiles.sh ;;
                        0) exit 0 ;;
                        *) echo -e $red"Väärä valinta!"$clear;sleep 1; menu;;
        esac
}

if (( $EUID != 0 )); then
    echo "Käynnistä skripti: sudo ./usb-paahdin.sh"
    exit
fi


menu

