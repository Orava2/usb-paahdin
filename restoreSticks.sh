#!/bin/bash


function enum_usbs () {
	USBS=""
	for USBDISK in /sys/block/sd*; do
		USBDISK_READLINK=`readlink -f ${USBDISK}/device`

		if [[ $USBDISK_READLINK == *"usb"* ]]; then
			# This is USB drive
			DEV_USBDISK=`basename ${USBDISK}`
			DEV_USBDISK="/dev/${DEV_USBDISK}"
			if grep -qs "${DEV_USBDISK}" /proc/mounts; then
				echo "Ohitetaan mountattu USB-levy ${DEV_USBDISK}"
				NOP=1
			else
				USBS="${USBS} ${DEV_USBDISK}"
			fi
		fi
	done
	USBS_COUNT=`echo "${USBS}" | wc -w`
}


# https://github.com/mplattu/abitti-scripts/blob/master/mkfat.sh
function mkfat () {

	DEV=$1
	FATNAME="USB-TIKKU"
	FAIL=0

	if [ "$DEV" = "" ]; then
		echo "usage: $1 devicename"
		FAIL=1
	fi
	
	if [ ! -b "$DEV" ]; then
		echo "Device $DEV does not exist"
		FAIL=1
	fi

	MOUNT_RESULT=`mount | grep -P "^${DEV}"`

	if [ "$MOUNT_RESULT" != "" ]; then
		echo "$DEV contains mounted filesystems, exiting"
		FAIL=1	
	fi

	if [ "$FAIL" -ne "1" ]; then
		parted -s ${DEV} mklabel msdos
		parted -s ${DEV} mkpart primary fat32 0 100%
		sync
		mkfs.vfat -n "${FATNAME}" ${DEV}1
	fi
}


CONFIRM=none

# Haetaan USB-tikkujen määrä, jotka ovat kirjoitettavissa.
enum_usbs

# While on niin kauan tosi, kun käyttäjä ei ole painanut w-näppäintä ja/tai löytyneiden USB-tikkujen määrä on 0.
# Valinnalla c silmukan saa keskeytettyä.
while [ "${CONFIRM}" != "w" -o "${USBS_COUNT}" -le 0 ]; do
	clear

	#echo "-o ${USBS_COUNT} -le 0"

	# Päivitetäään USB-tikkujen määrä.
	enum_usbs

	echo "USB-tikut ${USBS} (${USBS_COUNT} kpl)"

	if [ "${USBS_COUNT}" == "0" ]; then
		echo ""
		echo "Kirjoitettavia USB-tikkuja ei löytynyt"

	fi

	# Ask for user input
	echo ""
	echo "    Enter: Lue USB-tikut uudelleen"
	echo "C + Enter: Peruuta"
	echo "W + Enter: Aloita tikkujen tyhjennys"
	echo ""

	echo -n "Aloitetaanko tikkujen palauttaminen? "
	read CONFIRM
	
	# Make lowercase
	CONFIRM=`echo "$CONFIRM" | tr '[:upper:]' '[:lower:]'`
	
	if [ "${CONFIRM}" == "c" ]; then
		# Cancel pressed
		echo "Poistutaan"
		exit
	fi

	# Jos käyttäjä yrittää kirjoitusta, mutta kirjoitettavia USB-tikkuja ei löydy.
	if [ "${CONFIRM}" = "w" -a "${USBS_COUNT}" -le 0 ]; then
		echo ""
		echo "Palautettavia tikkuja ei löytynyt. Palautusta ei voida aloittaa."
		echo "Paina enter jatkaaksesi."
		read
		
	fi
done



echo "Aloitetaan tyhjennys "
UCOUNT=0
for THIS_USB in ${USBS}; do
	echo -n "${THIS_USB} "
	if [ -b ${THIS_USB} ]; then
		echo tyhjennys
		mkfat ${THIS_USB}
		echo ""
	else
		echo "Varoitus: ${THIS_USB} ei ole block-laite - USB-tikku kadonnut"
	fi
	let "UCOUNT = UCOUNT + 1"
done
echo "(${UCOUNT})"

echo "Tikkujen palautus on päättynyt!"
echo "Paina enter jatkaaksesi."
read











