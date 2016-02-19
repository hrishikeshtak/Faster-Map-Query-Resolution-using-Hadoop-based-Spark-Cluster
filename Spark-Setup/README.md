### Spark Setup
First download the 
spark-1.1.0-bin-hadoop2.3.tgz and copy it to $HOME dir

####1 spark single node : 

First setup Hadoop-Single-Node-Setup or Hadoop-Multi-Node-Setup 

#####How to run script :
			
i. To **setup** spark:		

>bash spark_single_node_setup.sh setup


ii. To **start** spark daemons:
         
>bash spark_single_node_setup.sh start

iii. To **stop** spark daemons :
		
>bash spark_single_node_setup.sh stop         

After successfully starting spark daemons log in to user hduser and run **jps** command:    
>> hduser@NVSD:~$ jps         
10097 ResourceManager              
9841 DataNode              
9777 NameNode             
10227 JobHistoryServer              
9989 SecondaryNameNode                
11079 Jps              
10889 Worker            
10158 NodeManager              
10702 Master             

 And then open browser with [http://localhost:8081/](http://localhost:8081/)

####2 spark_multi_node.sh : 

First setup Hadoop-Single-Node-Setup or Hadoop-Multi-Node-Setup 

**NOTE** :     
a) First add ip addresses  of master and all slaves in **/etc/hosts**
file and give names according to slave01 , slave02 ...      
If you have more slaves then add entries in $SPARK_CONF_DIR/slaves
file , and make changes as per in script.


b) Only on **MASTER** node : start the spark daemons.
#####How to run script :
			
i. To **setup** spark:		

>bash spark_multi_node_setup.sh setup <IP Address of Master>

ii. To **start** spark daemons:
         
>bash spark_multi_node_setup.sh start

iii. To **stop** spark daemons :
		
>bash spark_multi_node_setup.sh stop
      
