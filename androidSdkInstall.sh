#!/bin/bash
################################################################################
# Android SDK Intall script                                                    #
# 	author : Francois B. (Makotosan / Shakasan)                                #
#	  website : https://sirenacorp.be/                                         #
#	  email : shakasan [at] sirenacorp.be                                      #
#	  licence : GPLv3                                                          #
#	  howto use :                                                              #
#     - just modify the idVendor parameter regarding your own hardware         #
################################################################################

idVendor="18d1"
NORMAL="\\033[0;39m"
JAUNE="\\033[1;33m"
myHomedir=$(whoami)

printf "$JAUNE""> On se place dans le répertoire de Téléchargements\n""$NORMAL"
cd /home/$myHomedir/Téléchargements

printf "$JAUNE""> Création des répertoires  et  pour le SDK Android, et les apps via umake plus tard\n""$NORMAL"
mkdir /home/$myHomedir/tools
mkdir /home/$myHomedir/tools/Android

printf "$JAUNE""> Téléchargement du SDK\n""$NORMAL"
for a_sdk in $( wget -qO- http://developer.android.com/sdk/index.html | egrep -o "http://dl.google.com[^\"']*linux.tgz" ); do
  wget $a_sdk
done

printf "$JAUNE""> Installation du SDK\n""$NORMAL"
tar --wildcards --no-anchored -xvzf android-sdk_*-linux.tgz
mv android-sdk-linux /home/$myHomedir/tools/Android/Sdk

printf "$JAUNE""> PATH dans .bashrc : Création fichier SN\n""$NORMAL"
touch /home/$myHomedir/.bashrc

printf "$JAUNE""> PATH dans .bashrc : Ajout dans le fichier\n""$NORMAL"
sh -c "echo '\n\nexport PATH=${PATH}:/home/'$myHomedir'/tools/Android/Sdk/tools:/home/'$myHomedir'/tools/Android/Sdk/platform-tools' >> /home/$myHomedir/.bashrc"

printf "$JAUNE""> Ajout règles UDEV\n""$NORMAL"
sudo sh -c "echo 'SUBSYSTEM==\"usb\", ATTR{idVendor}==\""$idVendor"\", MODE=\"0666\", OWNER=\""$myHomedir"\" # Google Nexus' > /etc/udev/rules.d/99-android.rules"

printf "$JAUNE""> On redémarre udev\n""$NORMAL"
sudo service udev restart

printf "$JAUNE""> On supprime l'archive après installation\n""$NORMAL"
rm android-sdk_*-linux.tgz
