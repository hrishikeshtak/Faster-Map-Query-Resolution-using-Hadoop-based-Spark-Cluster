### Hadoop single node setup


To check the OS is 32 bit or 64 bit , run the command **"file /sbin/init"**       
and then download jdk tarball as per bit instruction

First download 

1 **hadoop Tarball**               
2 **jdk Tarball** 


#### How To Run Script

1 To Configure Hadoop Single Node             

>**bash hadoop_single_node_setup.sh setup Hadoop_Tarball JDK_Tarball**

2 To Start Hadoop Daemons           

>**bash hadoop_single_node_setup.sh start**

3 To Stop Hadoop Daemons            

>**bash hadoop_single_node_setup.sh stop**


It will create the User **"hduser"** with the Password **"hadoop"**           
After Successfully starting Hadoop Daemons : 
 
>>hduser@NVSD:~$ jps                 
7056 DataNode               
7393 JobHistoryServer                    
7267 NodeManager                  
7813 Jps                    
6970 NameNode                  
7146 SecondaryNameNode                
7211 ResourceManager                

open browser and go to [http://localhost:50070/](http://localhost:50070/)



