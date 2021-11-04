#!/bin/bash

# Versio 1.4

# Otetaan talteen se hakemistopolku, jossa ajossa oleva skripti sijaitsee. Esim. /home/user/usb-paahdin
# Lisätään merkki /, koska  polun oletetaan olevan skriptissä muodossa /home/user/usb-paahdin/ 
path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )""/"

clear
red='\e[31m'
invert='\e[7m'

redBk='\e[41m'
end='\e[0m'

echo -e "\e[1m\e[7m  ABITTI-tikkuohjelma aka USB-paahdin  \e[0m"

cd $path

# getURL
# fetches ZIP file URL for specified version & image type
# variables:
# $1 - student or server
# $2 - version number
function getURL {
	if [ $1 == "student" ]
	then
		echo "http://static.abitti.fi/etcher-usb/koe-etcher.zip"
	else
		echo "http://static.abitti.fi/etcher-usb/ktp-etcher.zip"
	fi
}

# startWriting
# starts write_dd.py script provided by YTL
# $1 - version number
# $2 - file name to write (usually koe.img or ktp.img)
function startWriting {
	# Confirm that user really wants to write server stick
	if [[ $2 == *"ktp"* ]]; then
		echo -e "${redBk}\nTikut tyhjennetään ja kirjoitetaan palvelimen tikuiksi.\nKOESUORITUKSIA EI VOI PALAUTTAA TYHJENNYKSEN JÄLKEEN.\nOlethan siis varmasti siirtänyt koesuoritukset Abitti.fi'hin?${end}"
			
			select yn in "Kyllä" "Ei"; do
				case $yn in
					"Kyllä")
						echo					
						break
						;;
					"Ei")
						exit
						break
						;;
				esac
			done
	fi
		
	cd "${path}usb-monster/dd-curses"
	./write_dd.py "${path}images/${1}/${2}"
}	

# writeSticksOld
# writes a specified image using write_dd.py 
# no parameters
function writeSticksOld {
	echo -e "${redBk}\nHUOM! OLET KIRJOITTAMASSA VANHAA VERSIOTA ABITISTA.\nTätä toimintoa ei ole yleensä tarpeen käyttää.${end}"

	read -p "Haluatko jatkaa? Paina y jos haluat jatkaa, tai n jos et halua jatkaa. " -n 1 -r
	echo    # (optional) move to a new line
	if [[ $REPLY =~ ^[Yy]$ ]]
	then
		cd "${path}images"
    		printf "Valitse haluamasi versio kirjoittamalla kansion numero ja painamalla enter:\n"
		select d in */; do test -n "$d" && break; echo ">>> Valinta ei kelpaa, yritä uudelleen"; done
			# Tähän mahdollisuus valita "Peruuta".
		cd "${path}"

		if [[ $d == *"ABITTI"* ]]; then
			fileToWrite='koe.img'
		fi
		
		if [[ $d == *"SERVER"* ]]; then
			fileToWrite='ktp.img'
		fi
		
		# Tarkistetaan onko kirjoitettava image olemassa.
		if [ ! -f "${path}images/${d}/${fileToWrite}" ]; then
			echo -e "${redBk}Virhe:${end} tiedostoa ${path}images/${d}${fileToWrite} ei löydy."
			echo -e "\nSulje ikkuna painamalla ENTER-näppäintä."
			read
			exit
		else
			# Aloita kirjoitus
			startWriting $d $fileToWrite
		fi
	fi
}

# checkUpdates
# checks if updated version is available
# and downloads it. $1 "student" or "server"
function checkUpdates {

	local imageRedownload

	if [ $1 == "student" ]; then
		versionFile='versionStudent.txt'
		fileName='koe-etcher.zip'
		fileNameDD='koe.img'

		# Fetch latest version number.
		latestVersion=$(wget http://static.abitti.fi/etcher-usb/koe-etcher.ver -q -O -)
	else
		versionFile='versionServer.txt'
		fileName='koe-etcher.zip'
		fileNameDD='ktp.img'

		# Fetch latest version number.
		latestVersion=$(wget http://static.abitti.fi/etcher-usb/ktp-etcher.ver -q -O -)
	fi		

	# Check if version file exists, otherwise it'll be created
	if [ ! -f ${versionFile} ]; then
		# Not found, create
		echo "0" > $versionFile
	fi

	# Fetch current version as variable
	currentVersion="`cat ${versionFile}`"

	# Poistetaan viimeinen satunnainen merkki versiosta kuten ABITTI2106S ja SERVER21066.
	currentVersionNumbers=${currentVersion::-1}
	# Poistetaan kaikki merkit, jotka eivät ole numeroita.
	currentVersionNumbers=${currentVersionNumbers//[!0-9]/}

	latestVersionNumbers=${latestVersion::-1}
	latestVersionNumbers=${latestVersionNumbers//[!0-9]/}

	# Jos tyhjä.
	if [ -z "$currentVersionNumbers" ]
	then
		currentVersionNumbers=0
	fi


	# 
	if ! [[ "${currentVersionNumbers}" =~ ^[0-9]+$ ]]
	then
		currentVersion=0
		currentVersionNumbers=0
		echo "0" > $versionFile
		echo "Versiotiedosto ${versionFile} oli virheellinen. Tiedosto on nyt korjattu."
		echo ""
	fi	


	# Check if downloading version info succeeded.
	if [ $? -eq 0 ]; then
		# -p prevents errors if directory already exists (it shouldn't usually)
		mkdir -p "${path}images/${latestVersion}"
		cd "${path}images/${latestVersion}"

		# Koodiin on lisätty tilapäinen muutos, joka tarkistaa löytyykö levyltä aikaisemmin ladattu image.
		# Jos ei löydy, ladataan image uudellleen. Tämä tarkistus toimii vain, jos ladatusta versiosta uudempaa versiota ei ole saatavilla.
		imageRedownload=0	# Oletuksena image ei tarvitse ladata uudelleen.

		if [ $currentVersionNumbers == $latestVersionNumbers ]; then
			# Tarkistetaan onko kirjoitettava image olemassa.
			if [ ! -f "${path}images/"${currentVersion}"/${fileNameDD}" ]; then
				echo -e "${redBk}Virhe:${end} tiedostoa ${path}images/${currentVersion}/${fileNameDD} ei löydy."
				imageRedownload=1
			else
				imageRedownload=0
			fi
		fi

		#	echo "currentVersion: ${currentVersion}"
		#	echo "lastestVersion: ${latestVersion}"
		#	echo "${path}images/"${currentVersion}"/${fileNameDD}"
		#	echo "if: $currentVersion \< $latestVersion -o $imageRedownload -eq 1 "

		# Ladataan uusin versio, jos palvelimelta löytyi uudempia versio tai jo ladattua uusinta versiota ei enää löydy levyltä (imageRedownload=1).
		if [ $currentVersionNumbers -lt $latestVersionNumbers -o $imageRedownload -eq 1 ]; then
			
			if [ $imageRedownload -eq 1 ]; then
				echo "Tietokoneelle on jo aikaisemmin ladattu uusin version ${currentVersion},"
				echo "mutta versiota ei enää löydy."
				echo "Haluatko korjata ongelman laatamalle tarvittavat tiedostot uudelleen?"

			else		
				echo -e "Tietokoneessa on versio ${currentVersion}, mutta uusin on ${latestVersion}."
				echo -e "Haluatko ladata uusimman version?"
			fi

			select yn in "Kyllä" "Ei"; do
				case $yn in
					"Kyllä")
						echo					
						break
						;;
					"Ei")
						exit
						break
						;;
				esac
			done

			echo -e "Ladataan uusin versio. ${invert}\nTässä saattaa kestää hetki, odota rauhassa.${end}\n\n"
			
			# Loudaan levykuvan latauslinkki. %1 on esim. "student" tai "server".
			fileURL=$(getURL $1 $latestVersion)

			# -O = output to specified path 
			# -q = quiet operation
			echo Komento: wget $fileURL -O $fileName 
			wget $fileURL -O $fileName 

			sleep 1

			#echo wget $fileURL -O $fileName && wget "${fileURL}.md5" -q -O "${fileName}.md5"
			#sleep 10

			# Check if download succeeded
			if [ $? -eq 0 ]; then
				# Succeeded, check MD5 sum
				# echo "Tarkistetaan ladattua tiedostoa."		
				# md5-tiedostoa ei ole enää saatavilla, joten tarkistus ohitetaan. Ei enää käytössä.
				# if md5sum -c "${fileName}.md5"; then
				if [ true ]; then
					# Clear terminal so user can easily read (wget printed a lot stuff)
					clear
					echo -e "Tiedosto ladattiin. Puretaan ja tarkistetaan tiedostoa...\nTässä saattaa kestää hetki, odota rauhassa."

					# -o  = force overwriting
					# -qq = very quiet operation
					# Purun jälkeen poistetaan zip-tiedosto. Tulostukset myöhemmin mahdollisesti logiin.
					unzip -j -o -qq $fileName "ytl/$fileNameDD"
					unzip -j -o -qq $fileName "ytl/${fileNameDD}.sha256"
					rm -fv $fileName >/dev/null 2>&1
					sha256sum -c "${fileNameDD}.sha256"
					if [ $? -eq 0 ]; then
						echo "Tiedoston purkaminen onnistui. Päivitys suoritettu onnistuneesti."
						cd $path
						echo $latestVersion > $versionFile
					else
						echo -e "${redBk}Tiedoston purkaminen epäonnistui.\nYritä uudelleen.${end}"
					fi
				else
					echo -e "${redBk}Tiedosto ladattiin, mutta siitä löytyi virhe tarkistettaessa.\nYritä uudelleen.${end}"
				fi
			else
				echo -e "${redBk}Yritettiin ladata, mutta ei onnistunut. Yritä uudelleen.${end}"
			fi

		else
			# We already have the latest version, so let's start writing.
			echo "Uusia päivityksiä ei ole saatavilla."
			# echo currentVersionNumbers: $currentVersionNumbers
			# echo latestVersionNumbers: $latestVersionNumbers
		fi
	else
		echo -e "${redBk}Virhe! Abitti-palvelimeen ei saatu yhteyttä.\nTarkista, että internetyhteys on toiminnassa.${end}"
	fi
}


# writeSticks
# inits writing process
# - version file creation
# - download, check MD5 & unzip image file
# - call startWriting function
# $1 - stick type to write, student or server
function writeSticks {
	echo -e "${redBk}\n1) Jos koneessa on nyt kiinni oma muistitikkusi, irrota se nyt.${end}\n"
	echo -e "2) Liitä kirjoitettavat palvelin- /opiskelijatikut.\n"
	echo -e "Paina enter kun olet tehnyt vaiheet 1 ja 2."

	read

	clear	
 
	usbnames="`ls -l /dev/disk/by-label 2>/dev/null`"; #End mutes errors
	#if [ $? -eq 0 ]; then
	#	echo "jatketaan"
	#else
	#	echo "EI tikkuja kiinni!"
	#	read
	#	exit 
	#fi		

	if [ $1 == "student" ]
	then
		versionFile='versionStudent.txt'
		fileName='koe-etcher.zip'
		fileToWrite='koe.img'

		# Check if user inserted sticks hat have been previously written as server sticks
		if [[ $usbnames == *"SERVER"* ]]; then
			echo -e "${redBk}\nVAROITUS! Yhdistit tikkuja, jotka ovat palvelimen tikkuja,\nmutta valitsit opiskelijan tikkujen kirjoittamisen.\nHaluatko todella kirjoittaa opiskelijan tikuiksi?${end}"
			
			select yn in "Kyllä" "Ei"; do
				case $yn in
					"Kyllä")
						echo					
						break
						;;
					"Ei")
						exit
						break
						;;
				esac
			done
		fi
	else
		versionFile='versionServer.txt'
		fileName='ktp-etcher.zip'
		fileToWrite='ktp.img'

		# Check if user inserted sticks that have been previously written as student sticks
		if [[ $usbnames == *"ABITTI"* ]]; then
			echo -e "${redBk}\nVAROITUS! Yhdistit tikkuja, jotka ovat opiskelijan tikkuja,"
			echo -e "mutta valitsit palvelimen tikkujen kirjoittamisen."
			echo -e "Haluatko todella kirjoittaa palvelimen tikuiksi?${end}"
			
			select yn in "Kyllä" "Ei"; do
				case $yn in
					"Kyllä")
						echo					
						break
						;;
					"Ei")
						exit
						break
						;;
				esac
			done
		fi
	fi

	# Check if version file exists, otherwise terminate
	if [ ! -f ${versionFile} ]; then
		echo "Päivitykset on tarkistettava ennen ensimmäistä käyttökertaa."
		echo -e "\nSulje ikkuna painamalla ENTER-näppäintä."
		read
		exit
	fi

	# Fetch current version as variable
	currentVersion="`cat ${versionFile}`"
	# Poistetaan viimeinen satunnainen merkki versiota kuten ABITTI2106S ja SERVER21066.
	currentVersionNumbers=${currentVersion::-1}
	# Poistetaan kaikki merkit, jotka eivät ole numeroita.
	currentVersionNumbers=${currentVersionNumbers//[!0-9]/}

	# Tarkistetaan onko currentVersion kokonaisluku. Jos ei ole (esim. tekstiä tai tyhjä), ilmoitetaan käyttäjälle virheestä.
	if ! [[ "$currentVersionNumbers" =~ ^[0-9]+$ ]]
	then
		echo -e "${redBk}Virhe:${end} versiotiedosto ${path}${versionFile} on virheellinen."
		echo "Aja päivitysten tarkistus."
		echo -e "\nSulje ikkuna painamalla ENTER-näppäintä."
		read
		exit
	fi


	# Tarkistetaan onko kirjoitettava image olemassa.
	if [ ! -f "${path}images/${currentVersion}/${fileToWrite}" ]; then
		echo -e "${redBk}Virhe:${end} levykuvaa ${path}images/${currentVersion}/${fileToWrite} ei löydy."
		echo "Aja päivitysten tarkistus."
		echo -e "\nSulje ikkuna painamalla ENTER-näppäintä."
		read
		exit
	fi

	cd "${path}images/${currentVersion}"
	startWriting $currentVersion $fileToWrite
		
}

case $action in
	"writeStudent")
		writeSticks student
		;;

	"writeServer")
		writeSticks server
		;;

	"writeOld")
		writeSticksOld
		;;

	"updateStudent")
		checkUpdates student
		;;

	"updateServer")
		checkUpdates server
		;;
esac


echo -e "\nSulje USB-paahdin painamalla ENTER-näppäintä."
read



