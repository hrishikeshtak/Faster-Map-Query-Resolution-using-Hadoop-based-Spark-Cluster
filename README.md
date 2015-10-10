# Faster-Map-Query-Resolution-using-Hadoop-based-Spark-Cluster

This is my M-Tech Project , this project contains the Map query resolutions using Spark cluster .

## Getting Started

### 1. Creation of Network

####a) Wireless Ad-Hoc network :                           
First read the PDF                               
[Creation-of-wireless-ad-hoc-network](Creation-of-Ad-Hoc-Network/Creation-of-wireless-ad-hoc-network.pdf) and then run script                       
[ad_hoc_client.sh](Creation-of-Ad-Hoc-Network/Creation-of-wireless-ad-hc-network/ad_hoc_client.sh) on one machine and run script               
[ad_hoc_server.sh](Creation-of-Ad-Hoc-Network/Creation-of-wireless-ad-hc-network/ad_hoc_server.sh) on another machine .

####b) Wired network :        
For creation of wired network , it required the machines are connected    
through LAN cable or Router or Switch .

### 2. Proxy Server or Network Address Translator (NAT) :   
First read the [Nat-or-proxy-server.pdf](NAT-or-Proxy-server-Setup/Nat-or-proxy-server.pdf)                 


### 3. Hadoop Single Node :
Hadoop is an open-source framework that allows to store and process   
big   data in a distributed environment across clusters of computers using  
simple programming models.To setup Hadoop single node on your linux    
based machine , check the **Hadoop-Single-Node-Setup**
        
       
### 4. Hadoop Multi Node Cluster :              
To setup Hadoop multi node cluster , we required at least two machines    
( one is master and one is slave ) , and they need to be in same network.   
To create our own subnet first see  **Creation-of-Ad-Hoc-Network** , then   
check **Hadoop-Multi-Node-Setup**

### 5. Hadoop Wordcount Example : 
To check that our Hadoop cluster is successful or not , try to run the     
hadoop wordcount example . Go to Hadoop-wordcount-example repo     
and then run the script  **run_hadoop-2.2.0_wordcount_program.sh .**
        
### 6. Spark Setup :
Setup spark single node or spark multi node setup .
  
### 7. OpenStreetMap :            
 OpenStreetMap (OSM) is a collaborative project to create a free editable map of the world. OpenStreetMap, the project that creates and distributes free geographic data for the world.
