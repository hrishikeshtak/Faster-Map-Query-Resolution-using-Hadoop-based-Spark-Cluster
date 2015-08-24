#!/bin/bash

if [ -f $HOME/check_tarball.sh ]
then
	. $HOME/check_tarball.sh
else
	echo "$HOME/check_tarball.sh File does not exist";
	exit
fi

clear
echo "\t\tHadoop 2.6.0 MultiNode Cluster Setup\n"
sudo apt-get purge openjdk* -y > /dev/null
cd $HOME

####################################################################################################
# Path 
JDK_TAR_FILE=jdk-8u20-linux-i586.tar.gz
HADOOP_TAR_FILE=hadoop-2.6.0.tar.gz
JAVA_HOME=/usr/local/java
HADOOP_HOME=/usr/local/hadoop
JAVA_FILE=jdk1.8.0_20 
HADOOP_FILE=hadoop-2.6.0
####################################################################################################

sudo chmod -R 755 $HOME/$JDK_TAR_FILE 
sudo chmod -R 755 $HOME/$HADOOP_TAR_FILE
sudo mkdir -p /usr/local/java 
sudo cp -r $HOME/$JDK_TAR_FILE /usr/local/java
sudo tar -xf /usr/local/java/$JDK_TAR_FILE -C /usr/local/java
tar -xf $HOME/$HADOOP_TAR_FILE
cd $HOME
cp -r $HOME/hadoop-2.6.0 $HOME/hadoop
sudo cp -r $HOME/hadoop /usr/local/

####################################################################################################

sudo sed -i '$aJAVA_HOME=/usr/local/java/'$JAVA_FILE' \nPATH=$PATH:$HOME/bin:'$JAVA_HOME'/bin \nexport JAVA_HOME\nexport PATH' /etc/profile


sudo update-alternatives --install "/usr/bin/java" "java" "/usr/local/java/$JAVA_FILE/jre/bin/java" 1
sudo update-alternatives --install "/usr/bin/javac" "javac" "/usr/local/java/$JAVA_FILE/bin/javac" 1 
sudo update-alternatives --set java /usr/local/java/$JAVA_FILE/jre/bin/java
sudo update-alternatives --set javac /usr/local/java/$JAVA_FILE/bin/javac

## Reload your system wide PATH /etc/profile by typing the following command:
. /etc/profile
java -version
javac -version
echo "Java Installed Successfully !!!"
sleep 2
clear

####################################################################################################
echo "\t\tHadoop 2.6.0 MultiNode Cluster Setup\n"
echo "Setup for wired network\n"
sudo sed -ie '$a#Wired network interface setup\nauto eth0\niface eth0 inet static\naddress 192.168.1.90\ngateway 192.168.1.1\nnetmask 255.255.255.0' /etc/network/interfaces

sudo ifdown eth0
sudo ifup eth0
sudo ifdown eth0
sudo ifup eth0
sudo service network-manager restart 
sudo service network-manager restart 
ip addr
echo "Setup for wired network Successfully"
sleep 2
clear 
####################################################################################################
## Adding dedicated Hadoop system user.
echo "\t\tHadoop 2.6.0 MultiNode Cluster Setup\n"
echo "Adding dedicated Hadoop User\n"
sudo addgroup hadoop
echo -e "hadoop\nhadoop\n" | sudo adduser -ingroup hadoop hduser
echo "hduser:hadoop" | sudo chpasswd 
sudo adduser hduser sudo
sleep 1
clear
echo "\t\tHadoop 2.6.0 MultiNode Cluster Setup\n"
echo "Hadoop Setup\n"
sudo chown -R hduser:hadoop $HADOOP_HOME
ls -l /usr/local
sleep 1
clear
####################################################################################################

cd $HOME
echo "\t\tHadoop 2.6.0 MultiNode Cluster Setup\n"
echo "Configuring SSH\n"
sudo apt-get install ssh -y > /dev/null
clear

cd $HOME
echo "\t\tHadoop 2.6.0 MultiNode Cluster Setup\n"
echo "Disabling IPv6\n"
sudo sed -i '$a#Disable ipv6\nnet.ipv6.conf.all.disable_ipv6 = 1\nnet.ipv6.conf.default.disable_ipv6 = 1\nnet.ipv6.conf.lo.disable_ipv6 = 1' /etc/sysctl.conf
echo "IPv6 Disabled\n"
sleep 1
clear
####################################################################################################

echo "\t\tHadoop 2.6.0 MultiNode Cluster Setup\n"
echo "Add entries in /etc/hosts file\n"

sudo sed -i "1i 192.168.1.90 master HNode1\n192.168.1.91 slave01\n192.168.1.92 slave02\n192.168.1.93 slave03" /etc/hosts
sudo sed -i '5,100s/^/#/' /etc/hosts
sleep 1
clear
####################################################################################################

echo "\t\tHadoop 2.6.0 MultiNode Cluster Setup\n"
echo "Password-less ssh from master to slave\n"
echo "\n" | sudo -u hduser ssh-keygen -t rsa -P ""
sudo -u hduser ssh-copy-id -i /home/hduser/.ssh/id_rsa.pub hduser@master
sudo -u hduser ssh-copy-id -i /home/hduser/.ssh/id_rsa.pub hduser@slave01
sudo -u hduser ssh-copy-id -i /home/hduser/.ssh/id_rsa.pub hduser@slave02
sudo -u hduser ssh-copy-id -i /home/hduser/.ssh/id_rsa.pub hduser@slave03
#sudo -u hduser ssh-copy-id -i /home/hduser/.ssh/id_rsa.pub hduser@slave04
clear
####################################################################################################
echo "\t\tHadoop 2.6.0 MultiNode Cluster Setup\n"
echo "Configuration of Hadoop files\n"

sudo -u hduser sed -i '$a# Set Hadoop-related environment variables\nexport HADOOP_PREFIX=/usr/local/hadoop\nexport HADOOP_HOME=/usr/local/hadoop\nexport HADOOP_MAPRED_HOME=${HADOOP_HOME}\nexport HADOOP_COMMON_HOME=${HADOOP_HOME}\nexport HADOOP_HDFS_HOME=${HADOOP_HOME}\nexport YARN_HOME=${HADOOP_HOME}\nexport HADOOP_CONF_DIR=${HADOOP_HOME}/etc/hadoop\nexport YARN_CONF_DIR=$HADOOP_HOME/etc/hadoop\n# Native Path\nexport HADOOP_COMMON_LIB_NATIVE_DIR=${HADOOP_PREFIX}/lib/native\nexport HADOOP_OPTS="-Djava.library.path=$HADOOP_PREFIX/lib"\n#Java path\nexport JAVA_HOME=/usr/local/java/'$JAVA_FILE'\n# Add Hadoop bin/ directory to PATH\nexport PATH=$PATH:$HADOOP_HOME/bin:'$JAVA_HOME'/bin:$HADOOP_HOME/sbin' /home/hduser/.bashrc
sudo -u hduser sed -i '$a# PATH For JPS\nPATH=$PATH:/usr/local/java/'$JAVA_FILE'/bin\nexport PATH' /home/hduser/.bashrc
sudo -u hduser sed -i '$aexport JAVA_HOME=/usr/local/java/'$JAVA_FILE'' /usr/local/hadoop/etc/hadoop/hadoop-env.sh

clear
echo "\t\tHadoop 2.6.0 MultiNode Cluster Setup\n"
echo "core-site.xml"
sudo -u hduser mkdir -p /usr/local/hadoop/tmp
sudo -u hduser sed -i '/<configuration>/a<property>\n<name>fs.default.name</name>\n<value>hdfs://master:9000</value>\n</property>\n<property>\n<name>hadoop.tmp.dir</name>\n<value>/usr/local/hadoop/tmp</value>\n</property>' /usr/local/hadoop/etc/hadoop/core-site.xml
echo "core-site.xml Done !!!"
sleep 1
clear
echo "\t\tHadoop 2.6.0 MultiNode Cluster Setup\n"

echo "hdfs-site.xml"
sudo -u hduser mkdir -p /usr/local/hadoop/yarn_data/hdfs/namenode
sudo -u hduser mkdir -p /usr/local/hadoop/yarn_data/hdfs/datanode
sudo -u hduser sed -i '/<configuration>/a<property>\n<name>dfs.replication</name>\n<value>3</value>\n</property>\n<property>\n<name>dfs.permissions </name>\n<value>false </value>\n</property>\n<property>\n<name>dfs.namenode.name.dir</name>\n<value>file:/usr/local/hadoop/yarn_data/hdfs/namenode</value>\n</property>\n<property>\n<name>dfs.datanode.name.dir</name>\n<value>file:/usr/local/hadoop/yarn_data/hdfs/datanode</value>\n</property>' /usr/local/hadoop/etc/hadoop/hdfs-site.xml
echo "hdfs-site.xml Done !!!"
sleep 1
clear
echo "\t\tHadoop 2.6.0 MultiNode Cluster Setup\n"

echo "mapred-site.xml"
sudo -u hduser cp /usr/local/hadoop/etc/hadoop/mapred-site.xml.template /usr/local/hadoop/etc/hadoop/mapred-site.xml
sudo -u hduser sed -i '/<configuration>/a<property>\n<name>mapreduce.framework.name</name>\n<value>yarn</value>\n</property>' /usr/local/hadoop/etc/hadoop/mapred-site.xml
echo "mapred-site.xml Done !!!"
sleep 1
clear
echo "\t\tHadoop 2.6.0 MultiNode Cluster Setup\n"

echo "yarn-site.xml"
sudo -u hduser sed -i '/<configuration>/a<property>\n<name>yarn.nodemanager.aux-services</name>\n<value>mapreduce_shuffle</value>\n</property>\n<property>\n<name>yarn.nodemanager.aux-services.mapreduce_shuffle.class</name>\n<value>org.apache.hadoop.mapred.ShuffleHandler</value> \n</property>\n<property>\n<name>yarn.resourcemanager.resource-tracker.address</name>\n<value>master:8025</value>\n</property>\n<property>\n<name>yarn.resourcemanager.scheduler.address</name>\n<value>master:8030</value>\n</property>\n<property>\n<name>yarn.resourcemanager.address</name>\n<value>master:8040</value>\n</property>\n<property>\n<name>yarn.nodemanager.localizer.address</name>\n<value>master:8060</value>\n</property>' /usr/local/hadoop/etc/hadoop/yarn-site.xml
echo "yarn-site.xml Done !!!"
sleep 1
clear
####################################################################################################
echo "\t\tHadoop 2.6.0 MultiNode Cluster Setup\n"

echo "Add entries in slaves file"
sudo -u hduser sed -i 's/localhost/ /' /usr/local/hadoop/etc/hadoop/slaves
sudo -u hduser sed -i '1imaster\nslave01\nslave02\nslave03' /usr/local/hadoop/etc/hadoop/slaves

clear
echo "\t\tHadoop 2.6.0 MultiNode Cluster Setup\n"
echo "Formating Hadoop Namenode\n"
sudo -u hduser /usr/local/hadoop/bin/hdfs namenode -format
sudo -u hduser sleep 1
clear
clear
echo "\t\tHadoop 2.6.0 MultiNode Cluster Setup\n"
echo "\nhduser created with the password \"hadoop\"\n"
#python $HOME/New_Script_For_Hadoop_cluster/spark_setup.py
cd $HOME
sudo rm -r $HADOOP_FILE hadoop
echo "Done Setting up Hadoop MultiNode Cluster\n"
sleep 2
