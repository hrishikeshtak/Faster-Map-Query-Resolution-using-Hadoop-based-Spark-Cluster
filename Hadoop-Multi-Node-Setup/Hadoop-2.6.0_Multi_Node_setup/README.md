#### Hadoop-2.6.0 Multi node setup for 32 bit OS

To check the OS is 32 bit or 64 bit , run the command **"$file /sbin/init"**

First download 

1. hadoop-2.6.0.tar.gz 
2. jdk-8u20-linux-i586.tar.gz 

save it in $HOME directory.

For 64 bit OS install
"sudo apt-get install ia32-libs"

On Master : 
	Run the script **"hadoop-2.6.0_multi_node_setup_master.sh"**
It will create the User **"hduser"** with the Password **"hadoop"** and it will assign the IP 
address 192.168.1.90 to master.
Check the connectivity with slave "ping -c2 192.168.1.91"
After success of the script and the slave on another machine , run the following command to communicate 
via ssh without password to the slave machine 
"sudo -u hduser ssh-copy-id -i /home/hduser/.ssh/id_rsa.pub hduser@slave01"

Then login to hduser with the command
**"su - hduser"**
and then run the script : 
To start the Hadoop daemons **"hadoop_multi_node_start.sh"**
To stop the Hadoop daemons  **"hadoop_multi_node_stop.sh"**.



On Slave :
	Run the script **"hadoop-2.6.0_multi_node_setup_slave.sh"**
It will create the User **"hduser"** with the Password **"hadoop"** and it will assign the IP 
address 192.168.1.91 to slave.
Check the connectivity with master "ping -c2 192.168.1.90"


Done


