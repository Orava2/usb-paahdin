#!/bin/bash

function menu {
clear
echo -ne "\e[1m\e[7m  ABITTI-tikkuohjelma aka USB-paahdin  \e[0m
Valitse toiminto!
1) Kirjoita opiskelijan tikuiksi
2) Kirjoita palvelintikuiksi
3) Kirjoita vanha versio
4) Tarkista levykuvien p�ivitykset
5) Tarkista USB-paahtimen p�ivitykset
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
                        *) echo -e $red"V��r� valinta!"$clear;sleep 1; menu;;
        esac
}


menu
