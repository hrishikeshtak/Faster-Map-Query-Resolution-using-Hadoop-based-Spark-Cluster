#!/bin/bash
## Shell Script For Client
## For creating Ad-hoc Wireless network

clear
echo "Script For Wireless Ad-hoc network"
sudo apt-get install ssh -y
sudo sed -ie '$a#Wireless Ad-hoc network Setup' /etc/network/interfaces
sudo sed -ie '$aauto wlan0' /etc/network/interfaces
sudo sed -ie '$aiface wlan0 inet static' /etc/network/interfaces
sudo sed -ie '$aaddress 192.168.1.91' /etc/network/interfaces
sudo sed -ie '$anetmask 255.255.255.0' /etc/network/interfaces
sudo sed -ie '$awireless-channel 1' /etc/network/interfaces
sudo sed -ie '$awireless-essid MYNETWORK' /etc/network/interfaces
sudo sed -ie '$awireless-mode ad-hoc' /etc/network/interfaces

sudo service network-manager restart	
sudo ifdown wlan0
sudo ifup wlan0

echo "Done !!! "

exit 0
