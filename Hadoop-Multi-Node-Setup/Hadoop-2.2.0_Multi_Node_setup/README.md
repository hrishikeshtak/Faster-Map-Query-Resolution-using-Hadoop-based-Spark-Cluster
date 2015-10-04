#### Hadoop-2.2.0 Multi node setup for 32 bit OS

To check the OS is 32 bit or 64 bit , run the command **"$file /sbin/init"**

First download 

1. hadoop-2.2.0.tar.gz 
2. jdk-8u20-linux-i586.tar.gz 

save it in $HOME directory.

For 64 bit OS install
"sudo apt-get install ia32-libs"

#### How to use script
**NOTE** : First setup successfully all **slaves** node and then setup **master** node.           

#####1 On All Slaves :                
  > To **setup** hadoop slave node :            
  >>**./hadoop-2.2.0_multi_node_setup.sh LOCAL_IPADDR  setup slave**           
where LOCAL_IPADDR - IP Address , that you want to assign to your system.    
                  (Please give IP Address from the 192.168.1.0 subnet)         

#####2 On Master :
  > To **setup** hadoop master node :        
  >>**./hadoop-2.2.0_multi_node_setup.sh LOCAL_IPADDR  setup master**           
where LOCAL_IPADDR - IP Address , that you want to assign to your system.    
                  (Please give IP Address from the 192.168.1.0 subnet)         
**NOTE** : It will ask the Ip addressess of all slaves and then Password of slaves.        

  > To **start** hadoop daemons :
  >> **./hadoop-2.2.0_multi_node_setup.sh LOCAL_IPADDR start**   

  > To **stop** hadoop daemons :
  >> **./hadoop-2.2.0_multi_node_setup.sh LOCAL_IPADDR stop**   

Done


