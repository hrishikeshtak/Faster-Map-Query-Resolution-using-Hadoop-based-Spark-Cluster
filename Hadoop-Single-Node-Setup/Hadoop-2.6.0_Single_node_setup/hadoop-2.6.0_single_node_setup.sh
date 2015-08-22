#!/bin/bash

if [ -f $HOME/check_tarball.sh ]
then
	. $HOME/check_tarball.sh
else
	echo "check_tarball.sh File does not exist";
	exit
fi

clear
echo "\t\tHadoop 2.6.0 SingleNode Cluster Setup\n"
sudo apt-get purge openjdk* -y > /dev/null
cd $HOME
####################################################################################################

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
sudo cp -r  $HOME/hadoop /usr/local/

####################################################################################################
sudo sed -i '$aJAVA_HOME=/usr/local/java/'$JAVA_FILE' \nPATH=$PATH:$HOME/bin:/usr/local/java/'$JAVA_FILE'/bin \nexport JAVA_HOME\nexport PATH' /etc/profile
sudo update-alternatives --install "/usr/bin/java" "java" "/usr/local/java/$JAVA_FILE/jre/bin/java" 1
sudo update-alternatives --install "/usr/bin/javac" "javac" "/usr/local/java/$JAVA_FILE/bin/javac" 1 
sudo update-alternatives --set java /usr/local/java/$JAVA_FILE/jre/bin/java
sudo update-alternatives --set javac /usr/local/java/$JAVA_FILE/bin/javac
## Reload your system wide PATH /etc/profile by typing the following command:
. /etc/profile
clear
echo "Setup for Java\n"
java -version
javac -version
echo "Java Installed Successfully !!!"
sleep 2
clear 

####################################################################################################
## Adding dedicated Hadoop system user.
echo "\t\tHadoop 2.6.0 SingleNode Cluster Setup\n"
echo "Adding dedicated Hadoop User\n"
sudo addgroup hadoop
echo -e "hadoop\nhadoop\n" | sudo adduser -ingroup hadoop hduser
echo "hduser:hadoop" | sudo chpasswd 
sudo adduser hduser sudo
sleep 1
clear
echo "\t\tHadoop 2.6.0 SingleNode Cluster Setup\n"
echo "Hadoop Setup\n"
sudo chown -R hduser:hadoop $HADOOP_HOME
ls -l /usr/local
sleep 1
clear
####################################################################################################

echo "\t\tHadoop 2.6.0 SingleNode Cluster Setup\n"
echo "Configuration of Hadoop files\n"

sudo -u hduser sed -i '$a# Set Hadoop-related environment variables\nexport HADOOP_PREFIX=/usr/local/hadoop\nexport HADOOP_HOME=/usr/local/hadoop\nexport HADOOP_MAPRED_HOME=${HADOOP_HOME}\nexport HADOOP_COMMON_HOME=${HADOOP_HOME}\nexport HADOOP_HDFS_HOME=${HADOOP_HOME}\nexport YARN_HOME=${HADOOP_HOME}\nexport HADOOP_CONF_DIR=${HADOOP_HOME}/etc/hadoop\nexport YARN_CONF_DIR=$HADOOP_HOME/etc/hadoop\n# Native Path\nexport HADOOP_COMMON_LIB_NATIVE_DIR=${HADOOP_PREFIX}/lib/native\nexport HADOOP_OPTS="-Djava.library.path=$HADOOP_PREFIX/lib"\n#Java path\nexport JAVA_HOME=/usr/local/java/'$JAVA_FILE'\n# Add Hadoop bin/ directory to PATH\nexport PATH=$PATH:$HADOOP_HOME/bin:/usr/local/java/bin:$HADOOP_HOME/sbin' /home/hduser/.bashrc
sudo -u hduser sed -i '$a# PATH For JPS\nPATH=$PATH:/usr/local/java/'$JAVA_FILE'/bin\nexport PATH' /home/hduser/.bashrc
sudo -u hduser sed -i '$aexport JAVA_HOME=/usr/local/java/'$JAVA_FILE'' /usr/local/hadoop/etc/hadoop/hadoop-env.sh
clear

####################################################################################################

echo "\t\tHadoop 2.6.0 SingleNode Cluster Setup\n"
echo "core-site.xml"
sudo -u hduser mkdir -p /usr/local/hadoop/tmp
sudo -u hduser sed -i '/<configuration>/a<property>\n<name>fs.default.name</name>\n<value>hdfs://localhost:9000</value>\n</property>\n<property>\n<name>hadoop.tmp.dir</name>\n<value>/usr/local/hadoop/tmp</value>\n</property>' /usr/local/hadoop/etc/hadoop/core-site.xml
echo "core-site.xml Done !!!"

sleep 1
clear
echo "\t\tHadoop 2.6.0 SingleNode Cluster Setup\n"
echo "hdfs-site.xml"
sudo -u hduser mkdir -p /usr/local/hadoop/yarn_data/hdfs/namenode
sudo -u hduser mkdir -p /usr/local/hadoop/yarn_data/hdfs/datanode
sudo -u hduser sed -i '/<configuration>/a<property>\n<name>dfs.replication</name>\n<value>1</value>\n</property>\n<property>\n<name>dfs.permissions </name>\n<value>false </value>\n</property>\n<property>\n<name>dfs.namenode.name.dir</name>\n<value>file:/usr/local/hadoop/yarn_data/hdfs/namenode</value>\n</property>\n<property>\n<name>dfs.datanode.name.dir</name>\n<value>file:/usr/local/hadoop/yarn_data/hdfs/datanode</value>\n</property>' /usr/local/hadoop/etc/hadoop/hdfs-site.xml
echo "hdfs-site.xml Done !!!"
sleep 1

clear
echo "\t\tHadoop 2.6.0 SingleNode Cluster Setup\n"
echo "mapred-site.xml"
sudo -u hduser cp /usr/local/hadoop/etc/hadoop/mapred-site.xml.template /usr/local/hadoop/etc/hadoop/mapred-site.xml
sudo -u hduser sed -i '/<configuration>/a<property>\n<name>mapreduce.framework.name</name>\n<value>yarn</value>\n</property>' /usr/local/hadoop/etc/hadoop/mapred-site.xml
echo "mapred-site.xml Done !!!"
sleep 1

clear
echo "\t\tHadoop 2.6.0 SingleNode Cluster Setup\n"
echo "yarn-site.xml"
sudo -u hduser sed -i '/<configuration>/a<property>\n<name>yarn.nodemanager.aux-services</name>\n<value>mapreduce_shuffle</value>\n</property>\n<property>\n<name>yarn.nodemanager.aux-services.mapreduce_shuffle.class</name>\n<value>org.apache.hadoop.mapred.ShuffleHandler</value> \n</property>\n<property>\n<name>yarn.resourcemanager.resource-tracker.address</name>\n<value>localhost:8025</value>\n</property>\n<property>\n<name>yarn.resourcemanager.scheduler.address</name>\n<value>localhost:8030</value>\n</property>\n<property>\n<name>yarn.resourcemanager.address</name>\n<value>localhost:8040</value>\n</property>\n<property>\n<name>yarn.nodemanager.localizer.address</name>\n<value>localhost:8060</value>\n</property>' /usr/local/hadoop/etc/hadoop/yarn-site.xml
echo "yarn-site.xml Done !!!"
sleep 1

clear
echo "\t\tHadoop 2.6.0 SingleNode Cluster Setup\n"
echo "Formating Hadoop Namenode\n"
sudo -u hduser /usr/local/hadoop/bin/hdfs namenode -format
sudo -u hduser sleep 1
clear
echo "\t\tHadoop 2.6.0 SingleNode Cluster Setup\n"
echo "\nhduser created with the password \"hadoop\"\n"
echo "Done Setting up Hadoop SingleNode Cluster\n"
cd $HOME
sudo rm -r hadoop hadoop-2.6.0
