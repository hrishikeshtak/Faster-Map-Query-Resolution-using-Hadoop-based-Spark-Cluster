### Hadoop single node setup


To check the OS is 32 bit or 64 bit , run the command **"file /sbin/init"**       
and then download jdk tarball as per bit instruction

First download 

1 **hadoop Tarball**               
2 **jdk Tarball** 


#### How To Run Script

1 To Configure Hadoop Single Node             

>**bash hadoop_single_node_setup.sh setup ~/hadoop-2.7.2.tar.gz ~/jdk-8u72-linux-x64.tar.gz**

2 To Start Hadoop Daemons           

>**bash hadoop_single_node_setup.sh start**

3 To Stop Hadoop Daemons            

>**bash hadoop_single_node_setup.sh stop**


It will create the User **"hduser"** with the Password **"hadoop"**           
After Success of script, open browser and type **http://localhost:50070/**


