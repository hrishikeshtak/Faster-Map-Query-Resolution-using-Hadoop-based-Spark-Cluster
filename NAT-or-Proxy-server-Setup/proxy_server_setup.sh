#!/bin/bash

if [ $EUID -ne 0 ]
then
	echo -e "The user must be root\n";
	exit 0;
fi

#  IPTABLES  PROXY  script for the Linux 2.4 kernel.
#  This script is a derivitive of the script presented in
#  the IP Masquerade HOWTO page at:
#  www.tldp.org/HOWTO/IP-Masquerade-HOWTO/firewall-examples.html
#  It was simplified to coincide with the configuration of
#  the sample system presented in the Guides section of
#  www.aboutdebian.com
#
#  This script is presented as an example for testing ONLY
#  and should not be used on a production proxy server.
#
#    PLEASE SET THE USER VARIABLES
#    IN SECTIONS A AND B OR C

echo -e "\n\nSETTING UP IPTABLES PROXY..."


# === SECTION A
# -----------   FOR EVERYONE 

# SET THE INTERFACE DESIGNATION FOR THE NIC CONNECTED TO YOUR INTERNAL NETWORK
#   The default value below is for "eth0".  This value 
#   could also be "eth1" if you have TWO NICs in your system.
#   You can use the ifconfig command to list the interfaces
#   on your system.  The internal interface will likely have
#   have an address that is in one of the private IP address
#   ranges.
#       Note that this is an interface DESIGNATION - not
#       the IP address of the interface.
#   Enter the internal interface's designation for the
#   INTIF variable:

INTIF="eth0"


# SET THE INTERFACE DESIGNATION FOR YOUR "EXTERNAL" (INTERNET) CONNECTION
#   The default value below is "ppp0" which is appropriate 
#   for a MODEM connection.
#   If you have two NICs in your system change this value
#   to "eth0" or "eth1" (whichever is opposite of the value
#   set for INTIF above).  This would be the NIC connected
#   to your cable or DSL modem (WITHOUT a cable/DSL router).
#       Note that this is an interface DESIGNATION - not
#       the IP address of the interface.
#   Enter the external interface's designation for the
#   EXTIF variable:

EXTIF="wlan0"


# ! ! ! ! !  Use ONLY Section B  *OR*  Section C depending on
#  ! ! ! !   the type of Internet connection you have.


# === SECTION B
# -----------   FOR THOSE WITH STATIC PUBLIC IP ADDRESSES

   # SET YOUR EXTERNAL IP ADDRESS
   #   If you specified a NIC (i.e. "eth0" or "eth1" for
   #   the external interface (EXTIF) variable above,
   #   AND if that external NIC is configured with a
   #   static, public IP address (assigned by your ISP),
   #   UNCOMMENT the following EXTIP line and enter the
   #   IP address for the EXTIP variable:

#EXTIP="your.static.IP.address"



# === SECTION C
# ----------   DIAL-UP MODEM, AND RESIDENTIAL CABLE-MODEM/DSL (Dynamic IP) USERS


# SET YOUR EXTERNAL INTERFACE FOR DYNAMIC IP ADDRESSING
#   If you get your IP address dynamically from SLIP, PPP,
#   BOOTP, or DHCP, UNCOMMENT the command below.
#   (No values have to be entered.)
#         Note that if you are uncommenting these lines then
#         the EXTIP line in Section B must be commented out.

EXTIP="`/sbin/ifconfig wlan0 | grep 'inet addr' | awk '{print $2}' | sed -e 's/.*://'`"


# --------  No more variable setting beyond this point  --------


echo "Loading required stateful/NAT kernel modules..."

/sbin/depmod -a
/sbin/modprobe ip_tables
/sbin/modprobe ip_conntrack
/sbin/modprobe ip_conntrack_ftp
/sbin/modprobe ip_conntrack_irc
/sbin/modprobe iptable_nat
/sbin/modprobe ip_nat_ftp
/sbin/modprobe ip_nat_irc

echo "    Enabling IP forwarding..."
echo "1" > /proc/sys/net/ipv4/ip_forward
echo "1" > /proc/sys/net/ipv4/ip_dynaddr

echo "    External interface: $EXTIF"
echo "       External interface IP address is: $EXTIP"

echo "    Loading proxy server rules..."

# Clearing any existing rules and setting default policy
iptables -P INPUT ACCEPT
iptables -F INPUT 
iptables -P OUTPUT ACCEPT
iptables -F OUTPUT 
iptables -P FORWARD DROP
iptables -F FORWARD 
iptables -t nat -F

# FWD: Allow all connections OUT and only existing and related ones IN
iptables -A FORWARD -i $EXTIF -o $INTIF -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -i $INTIF -o $EXTIF -j ACCEPT

# Enabling SNAT (MASQUERADE) functionality on $EXTIF
iptables -t nat -A POSTROUTING -o $EXTIF -j MASQUERADE

echo -e "       Proxy server rule loading complete\n\n"
