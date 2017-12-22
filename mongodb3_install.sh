#!/bin/bash

################################################################################
# MongoDB 3 Community Edition install script for Ubuntu 16.0.4 x86_64          #
# 	Author : Francois B. (Makotosan)                                           #
#   Website : https://sirenacorp.be/                                           #
#   Email : shakasan [at] sirenacorp.be                                        #
#   Licence : GPLv3                                                            #
################################################################################

#
# remove the default MongoDB v2.x installed from ubuntu repository
# and delete all log and databases (DB from v2 and v3 are not compatible)
# !!!! so...do a backup before !!!!
#
sudo systemctl stop mongodb \
  && sudo rm -rf /var/log/mongodb \
  && sudo rm -rf /var/lib/mongodb \
  && sudo apt remove --purge mongodb \

  #
# install MongoDB Community Edition 3.x
#
&& sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2930ADAE8CAF5059EE73BB4B58712A2291FA4AD5 \
  && echo "deb [ arch=amd64,arm64 ] http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/testing multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.6.list \
  && sudo apt update \
  && sudo apt install -y mongodb-org \

  #
# systemd fix
#
&& sudo systemctl unmask mongodb.service \
  && sudo systemctl enable mongodb \
  && sudo systemctl start mongodb
