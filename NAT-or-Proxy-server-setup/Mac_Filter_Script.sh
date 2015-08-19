#!/bin/bash

clear 
echo "Mac Filter Squid"

sudo sed -ie '$a#Mac Filtering' /etc/squid/squid.conf
sudo sed -ie '$aacl macaddress1 arp a0:48:1c:04:29:17' /etc/squid/squid.conf
sudo sed -ie '$aacl macaddress2 arp a0:1d:48:70:cb:c5' /etc/squid/squid.conf

sudo sed -ie '$ahttp_access allow macaddress1' /etc/squid/squid.conf
sudo sed -ie '$ahttp_access allow macaddress2' /etc/squid/squid.conf
sudo sed -ie '$ahttp_access deny all' /etc/squid/squid.conf


echo "Mac Filter Squid Done!!!"
clear
