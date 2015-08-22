Hadoop-2.2.0 single node setup for 32 bit OS

To check the OS is 32 bit or 64 bit , run the command "$file /sbin/init"

First download 

1. hadoop-2.2.0.tar.gz 
2. jdk-8u20-linux-i586.tar.gz 

save it in $HOME directory.

For 64 bit OS install
"sudo apt-get install ia32-libs"

Run the script "hadoop-2.2.0_single_node_setup.sh"

It will create the User "hduser" with the Password "hadoop"
After completion of the script then go to hduser using  

"su - hduser"
and then run the script "hadoop_single_node_start.sh" to start the Hadoop daemons
and to stop the Hadoop daemons run the script "hadoop_single_node_stop.sh".

Done


