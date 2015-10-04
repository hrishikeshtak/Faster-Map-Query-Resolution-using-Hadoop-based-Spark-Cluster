### Spark Setup
First download the 
spark-1.1.0-bin-hadoop2.3.tgz and copy it to $HOME dir

####1 spark single node : 

First setup Hadoop-Single-Node-Setup or Hadoop-Multi-Node-Setup 

#####How to run script :
			
i. To **setup** spark:		

		./spark_single_node_setup.sh setup


ii. To **start** spark daemons:
         
		./spark_single_node_setup.sh start

iii. To **stop** spark daemons :
		
		./spark_single_node_setup.sh stop

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

		./spark_multi_node_setup.sh setup <IP Address of Master>

ii. To **start** spark daemons:
         
		./spark_multi_node_setup.sh start

iii. To **stop** spark daemons :
		
		./spark_multi_node_setup.sh stop
      
