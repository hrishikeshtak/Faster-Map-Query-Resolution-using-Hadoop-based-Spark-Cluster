#!/bin/bash

clear; 
echo -e "\nConfigure wired network";
####################################################################################################
COUNT_PARAM=$#;
SCRIPT_NAME=$0;
LOCAL_IPADDR=$1;
NODE_NAME=$2;
GATEWAY=192.168.1.1;
INTERFACES_CONF_FILE=/etc/network/interfaces;
####################################################################################################

print_usage() {
		echo -e "\nUsage: $0 <LOCAL_IPADDR> <NODE_NAME> ";
		echo -e "    LOCAL_IPADDR - Static IP address that you want to assign";
		echo -e "    NODE_NAME -  Node Name of machine";
		echo -e "                         (ex. MASTER OR SLAVE)\n";
}

error_check() {
		echo -e "\nERROR: $SCRIPT_NAME: at Line $2 : $1";
		exit 0;
}

validate_args() {
		if [ $COUNT_PARAM -eq 0 ]
		then
				echo -e "\nERROR: LOCAL_IPADDR missing";
				print_usage;
				exit 0;
		else
				if validate_IP $LOCAL_IPADDR; 
				then 
						echo -e "\nLOCAL_IPADDR $LOCAL_IPADDR is valid";
				else
						echo -e "\nLOCAL_IPADDR $LOCAL_IPADDR is invalid";
						exit 0;

				fi	
		fi
		if [ $COUNT_PARAM -eq 1 ]
		then
				echo -e "\nERROR: NODE_NAME missing";
				print_usage;
				exit 0;
		else
				if [[ $NODE_NAME == "MASTER" || $NODE_NAME == "master" || $NODE_NAME == "slave" || $NODE_NAME == "SLAVE" ]]
				then
						configure_wired_network ;
				else
						echo -e "\nERROR: NODE_NAME is not correct";
						echo -e "ex. MASTER OR SLAVE";
						exit 0;
				fi
		fi
}

validate_IP() {
		local  ip=$1;
		local  stat=1;

		if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
				OIFS=$IFS
				IFS="."
				ip=($ip);
				IFS=$OIFS
				[[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
						&& ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
				stat=$?;
		fi
		return $stat

}

####################################################################################################
configure_wired_network() {
		# If config present already comment it
		sudo sed -i -e '/auto eth0/ s/^#*/#/' $INTERFACES_CONF_FILE;
		sudo sed -i -e '/iface eth0 inet static/ s/^#*/#/' $INTERFACES_CONF_FILE;
		sudo sed -i -e '/address '$LOCAL_IPADDR'/ s/^#*/#/' $INTERFACES_CONF_FILE;
		sudo sed -i -e '/gateway '$GATEWAY'/ s/^#*/#/' $INTERFACES_CONF_FILE;
		sudo sed -i -e '/netmask 255.255.255.0/ s/^#*/#/' $INTERFACES_CONF_FILE;

		sudo apt-get -y install ssh || { error_check SSH-not-installed ${LINENO}; };
		sudo sed -ie '$a auto eth0' $INTERFACES_CONF_FILE; 
		sudo sed -ie '$a iface eth0 inet static' $INTERFACES_CONF_FILE; 
		sudo sed -ie '$a address '$LOCAL_IPADDR'' $INTERFACES_CONF_FILE; 
		sudo sed -ie '$a gateway '$GATEWAY'' $INTERFACES_CONF_FILE; 
		sudo sed -ie '$a netmask 255.255.255.0' $INTERFACES_CONF_FILE; 
		sudo service network-manager restart || { error_check network-manager-not-restarted ${LINENO}; }; 
		sudo ifdown eth0 || { error_check check-interfaces ${LINENO} ; };
		sudo ifup eth0 || { error_check check-interfaces ${LINENO} ; };
}
####################################################################################################
validate_args;

