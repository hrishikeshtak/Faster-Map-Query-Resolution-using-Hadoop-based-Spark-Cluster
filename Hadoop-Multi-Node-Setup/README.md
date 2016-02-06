### Hadoop Multi node setup
To check the OS is 32 bit or 64 bit , run the command **"file /sbin/init"**

First download 

1. hadoop Tarball 
2. jdk Tarball ( as per bit instructions )

#### How to use script
**NOTE** : First setup successfully all **slaves** node and then setup **master** node.           

#####1 On All Slaves :                
> To **setup** hadoop slave node :            
>>**bash hadoop_multi_node_setup.sh 192.168.1.91 setup slave ~/hadoop-2.7.2.tar.gz ~/jdk-8u72-linux-x64.tar.gz**              
        
where LOCAL_IPADDR - IP Address , that you want to assign to your system.    
                  (Please give IP Address from the 192.168.1.0 subnet)         

#####2 On Master :
> To **setup** hadoop master node :        
>>**bash hadoop_multi_node_setup.sh 192.168.1.91 setup master ~/hadoop-2.7.2.tar.gz ~/jdk-8u72-linux-x64.tar.gz**          
       
where LOCAL_IPADDR - IP Address , that you want to assign to your system.    
                  (Please give IP Address from the 192.168.1.0 subnet)         
**NOTE** : It will ask the Ip addresses of all slaves and then Password of slaves.         
     

> To **start** hadoop daemons (run only on master node):
>> **bash hadoop_multi_node_setup.sh LOCAL_IPADDR start**   

> To **stop** hadoop daemons (run only on master node):
>> **bash hadoop_multi_node_setup.sh LOCAL_IPADDR stop**   

Done

