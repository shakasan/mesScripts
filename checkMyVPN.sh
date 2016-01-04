#!/bin/bash
################################################################################
# CheckMyVPN                                                                   #
# 	Author : Francois B. (Makotosan / Shakasan)                                #
#	  Website : https://sirenacorp.be/                                           #
#	  Email : shakasan [at] sirenacorp.be                                        #
#	  Licence : GPLv3                                                            #
#   Features of this script :                                                  #
#     - check if the OpenVPN connexion is UP and restart it if necessary       #
#     - Stop/Start TransmissionBT/SabNZBd/JDownloader regarding the VPN status #
#     - add iptables rules for the OpenVPN when (re)start                      #
#	  Howto use : see https://sirenacorp.be/vpn-sur-et-efficace-pour-son-nas/    #
################################################################################
#
# A ajouter dans /etc/logrotate.d/
#/var/log/mycheck.log
#{
#    rotate 4
#    weekly
#    size 20M
#    missingok
#    notifempty
#    compress
#    delaycompress
#    sharedscripts
#    postrotate
#        invoke-rc.d rsyslog restart > /dev/null
#    endscript
#}

heure=$(date +%H:%M)
jour=$(date +%d-%m-%Y)

# chemin vers le binaire d'iptables
iptables="/sbin/iptables"
# interface réseau du VPN
interface="tun0"
# service Transmission
service1="transmission-daemon"
process1="transmission-daemon"
# service JDownloader
service2="jdownloader"
process2="JDownloader.jar"
# service SabNZBd
service3="sabnzbd"
process3="sabnzbd"
# port ouvert chez le provider du VPN pour Transmission
portTransmissionBT="24152"
# chemin vers le fichier de log
logfile="/var/log/mycheck.log"

# le VPN est UP à nouveau et on redémarre les services (Transmission, SabNZBd, JDownloader)
# soit le VPN était déjà UP, mais un service s'est arrêté et sera redémarré
function reStartService () {
 if (( $(ps -ef | grep -v grep | grep $2 | wc -l) > 0 ))
 then
 # déjà UP, on log le status
 echo "> Service : "$1" : UP" >> $logfile
 else
 # DOWN, on doit les démarrer !!!!
 echo "> Service : "$1" : (re)démarrage" >> $logfile
 service $1 start >> $logfile
 fi
}

# si le VPN est Down, on doit stopper les services (Transmission, SabNZBd, JDownloader)
function stopService () {
        if (( $(ps -ef | grep -v grep | grep $2 | wc -l) > 0 ))
        then
 # on doit le stopper !!!!
 echo "> OpenVPN : DOWN !!  >>>  On stop "$1" !!" >> $logfile
 service $1 stop >> $logfile
 else
 # déjà DOWN, on log le status
 echo "> Service : "$1" : DOWN" >> $logfile
 fi
}

echo "--- "$jour" - "$heure" -----------------------------------------------" >> $logfile

if [ -n "$(ifconfig | grep "$interface")" ]; then # -----------------------------------------------------------------

 # le VPN est UP, on log le status
 echo "> OpenVPN : UP ("$interface")" >> $logfile

 # on vérifie s'il y a des régles iptables pour le VPN
 if [ -z "$($iptables -L -v | grep "$interface")" ]; then

 # on ouvre des ports pour TransmissionBT
 echo "> Iptable : Add rules : Begin" >> $logfile
 echo "> Iptable : Add rules : TransmissionBT : port "$portTransmissionBT >> $logfile
 $iptables -A INPUT -i $interface -p tcp --destination-port  $portTransmissionBT  -j ACCEPT >> $logfile
 $iptables -A INPUT -i $interface -p udp --destination-port  $portTransmissionBT  -j ACCEPT >> $logfile

 echo "> Iptables : Add rules : Other" >> $logfile
 $iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT >> $logfile
 #if none of the rules were matched DROP
 $iptables -A INPUT -i $interface -p tcp -j DROP >> $logfile
 $iptables -A INPUT -i $interface -p udp -j DROP >> $logfile
 $iptables -A INPUT -i $interface -p icmp -j DROP >> $logfile
 echo "> Iptables : Add Rules : End" >> $logfile
 else
 # si les règles sont OK, on log le status
 echo "> Iptable : rules OK" >> $logfile
 fi # --------------------------------------------------------------

 # on (re)démarre les services (Transmission, SabNZBd, JDownloader)
 reStartService $service1 $process1
 reStartService $service2 $process2
 reStartService $service3 $process3

else #---------------------------------------------------------------------------------------------------------------

 # le VPN est DOWN, on log le status
 echo "> OpenVPN : DOWN !! ("$interface")" >> $logfile

 # on arrête les serices (Transmission, SabNZBd, JDownloader)
 stopService $service1 $process1
 stopService $service2 $process2
 stopService $service3 $process3

 # on redémarre le VPN !!!!
 echo "> OpenVPN : démarrage" >> $logfile
 service openvpn start >> $logfile

fi # ----------------------------------------------------------------------------------------------------------------

#echo "-----------------------------------" >> $logfile

exit 0;
