#!/bin/bash

redBk='\e[41m'
end='\e[0m'
 
versionStudents='versionStudent.txt'
versionServer='versionServer.txt'
 
function menu {
clear
echo -ne "\e[1m\e[7m  ABITTI-tikkuohjelma aka USB-paahdin  \e[0m
Valitse toiminto
 1) Kirjoita opiskelijan tikuiksi $(versionStudents)
 2) Kirjoita palvelintikuiksi $(versionServer)
 3) Kirjoita vanha versio
 4) Tarkista levykuvien päivitykset
 5) Tyhjennä tikut FAT32-muotoon
 9) Tarkista USB-paahtimen päivitykset
 0) Lopeta\n"
echo -n "#? "
        read a
        case $a in
                1) ./scriptStudent.sh ; menu ;;
                2) ./scriptServer.sh ; menu ;;
                3) ./scriptOld.sh  ; menu ;;
                4) ./scriptUpdate.sh ; menu ;;
				5) ./restoreSticks.sh ; menu ;;
                9) ./updateScriptFiles.sh ;;
                        0) exit 0 ;;
                        *) echo -e ${redBk}"Virheellinen valinta!"${end};sleep 1; menu;;
        esac
}


menu

