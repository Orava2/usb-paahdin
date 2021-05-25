# usb-paahdin

## Asennus Xubuntu-käyttöjärjestelmään

```
sudo apt install pv git python2 python-psutil wget unzip

git clone https://github.com/Orava2/usb-paahdin

cd usb-paahdin

bash allowExecution.sh
```

Poista automount-ominaisuus. Xubuntussa vasemman yläreunan kuvake -> Asetukset (Settings) -> Irrotettavat asemat ja taltiot (Removable Drives and Mesia) -> poista ruksit kaikista kohdassa Irrotettavat tietovälineet (Removable Storage).

Halutessasi voit poistaa myös USB-tikkujen kuvakkeet työpöydältä. Vasemman yläreunan kuvake -> Asetukset (Settings) -> Työpöytä (Desktop) -> Kuvakkeet (Icons) -> Oletuskuvakkeet-kohdasta (Default Icons) poista rasti kohdasta Irrotettavat taltiot (Removable Devices).

Aja skriptit sudo:lla, esimerkiksi `sudo ./scriptStudent.sh`. Jos haluat, että sudo ei kysy salasanaa, avaa terminaali ja kirjoita `sudo visudo`. Lisää tiedoston loppuun rivi ` kayttajatunnuksesi ALL=(ALL) NOPASSWD: ALL`

---- 

Oppilastikkujen kirjoitus: scriptStudent.sh

Palvelintikkujen kirjoitus: scriptServer.sh

Vanhan version kirjoitus: scriptOld.sh

Päivitysten tarkistus: scriptUpdate.sh

USB-paahtimen päivitys: updateScriptFiles.sh

Valikko edellä mainituille toiminnoille: USB-paahdin.sh

Uusimman ladatun oppilastikun ja palvelimen versiot: versionStudent.txt ja versionServer.txt
