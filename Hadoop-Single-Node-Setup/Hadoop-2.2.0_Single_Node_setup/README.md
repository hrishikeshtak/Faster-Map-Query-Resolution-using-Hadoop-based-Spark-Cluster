#### Hadoop-2.2.0 single node setup for 32 bit OS


To check the OS is 32 bit or 64 bit , run the command **"$file /sbin/init"**

First download 

1. hadoop-2.2.0.tar.gz 
2. jdk-8u20-linux-i586.tar.gz 

save it in $HOME directory.

For 64 bit OS install
"sudo apt-get install ia32-libs"

#### How To Run Script

1. To Configure Hadoop Single Node
		./hadoop-2.2.0_single_node_setup.sh setup

2. To Start Hadoop Daemons
		./hadoop-2.2.0_single_node_setup.sh start

2. To Stop Hadoop Daemons
		./hadoop-2.2.0_single_node_setup.sh stop


It will create the User **"hduser"** with the Password **"hadoop"**


Done


