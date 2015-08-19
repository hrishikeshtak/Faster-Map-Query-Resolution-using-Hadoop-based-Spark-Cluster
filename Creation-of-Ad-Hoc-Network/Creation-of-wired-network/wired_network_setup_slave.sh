#!/bin/bash

clear 

sudo apt-get install ssh -y 

echo 'Setting for wired network ' 
sudo sed -ie '$a#Wired network interface setup' /etc/network/interfaces 
sudo sed -ie '$aauto eth0' /etc/network/interfaces 
sudo sed -ie '$aiface eth0 inet static' /etc/network/interfaces 
sudo sed -ie '$aaddress 192.168.1.91 ' /etc/network/interfaces 
sudo sed -ie '$agateway 192.168.1.1' /etc/network/interfaces 
sudo sed -ie '$anetmask 255.255.255.0' /etc/network/interfaces 

sudo service network-manager restart 
sudo ifdown eth0
sudo ifup eth0


exit 0
