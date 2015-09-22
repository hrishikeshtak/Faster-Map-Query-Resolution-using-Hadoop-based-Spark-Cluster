#!/bin/bash

clear
echo -e "\t\tHadoop 2.2.0 MultiNode Cluster Setup\n"
cd $HOME
####################################################################################################
# Variables used in script 
COUNT_PARAM=$#;
SCRIPT_NAME=$0;
HADOOP_PARAM=$2;
LOCAL_IPADDR=$1;
JDK_TAR_FILE=jdk-8u20-linux-i586.tar.gz;
HADOOP_TAR_FILE=hadoop-2.2.0.tar.gz;
JAVA_HOME=/usr/local/java;
HADOOP_HOME=/usr/local/hadoop;
JAVA_FILE=jdk1.8.0_20;
HADOOP_FILE=hadoop-2.2.0;
HADOOP_CONF_DIR=/usr/local/hadoop/etc/hadoop;
####################################################################################################
if [ $EUID -eq 0 ]
then
		echo -e "switch to normal user";
		exit 0;
fi

if [ ! -f $HOME/$JDK_TAR_FILE ] 
then 
# 		sudo  wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie"  http://download.oracle.com/otn-pub/java/jdk/8u60-b27/jdk-8u60-linux-x64.tar.gz;
		echo -e "Copy $JDK_TAR_FILE To $HOME then run the script "; 
		exit 0;
fi

if [ ! -f $HOME/$HADOOP_TAR_FILE ] 
then 
		echo -e "Copy $HADOOP_TAR_FILE To $HOME then run the script "; 
		exit 0;
fi
####################################################################################################
error_check() {
		echo -e "\nERROR: $SCRIPT_NAME: at Line $2 : $1";
		exit 0;
}

print_usage () {
		echo -e "\nUsage: $0 <LOCAL_IPADDR> <HADOOP_PARAM>"
		echo -e "    LOCAL_IPADDR - IP Address , that you want to assign to your system. "
		echo -e "    HADOOP_PARAM - Paramaeter that specify following options "
		echo -e "                   1. Hadoop Setup , press setup or SETUP    \n"
		echo -e "                   2. Hadoop Daemons Start , press start or START    \n"
		echo -e "                   3. Hadoop Daemons Stop  , press stop or STOP   \n"

}
validate_args() {
		if [ $COUNT_PARAM -eq 0 ]
		then
				echo -e "\nERROR: LOCAL_IPADDR is missing";
				print_usage;
				exit 0;
		else
				if [[ $HADOOP_PARAM == "setup" || $HADOOP_PARAM == "SETUP" ]]
				then
						install_JAVA;
						hadoop_user;
						hadoop_configuration;
						hadoop_format;
						exit 0;
				fi
				if [[ $HADOOP_PARAM == "start" || $HADOOP_PARAM == "START" ]]
				then
						start_hadoop;
						exit 0;
		
				fi
				if [[ $HADOOP_PARAM == "stop" || $HADOOP_PARAM == "STOP" ]]
				then
						stop_hadoop;
						exit 0;
				else
						echo -e "\nWrong input";
						print_usage;
						exit 0;
				fi

		fi
}
####################################################################################################
install_JAVA() {
		sudo apt-get -y purge openjdk* &> /dev/null || { error_check error ${LINENO}; };
		sudo chmod -R 755 $HOME/$JDK_TAR_FILE;
		sudo chmod -R 755 $HOME/$HADOOP_TAR_FILE;
		sudo mkdir -p $JAVA_HOME;
		sudo cp -r $HOME/$JDK_TAR_FILE $JAVA_HOME;
		sudo tar -xvf $JAVA_HOME/$JDK_TAR_FILE -C $JAVA_HOME || { error_check error ${LINENO}; };
		tar -xvf $HOME/$HADOOP_TAR_FILE -C $HOME || { error_check error ${LINENO}; };
		cd $HOME;
		cp -r $HOME/hadoop-2.2.0 $HOME/hadoop;
		sudo cp -r  $HOME/hadoop /usr/local/;
		
		# If already present JAVA configuration , comment it 
		sudo sed -i -e "/JAVA/ s/^#*/#/" /etc/profile || { error_check error ${LINENO}; };		
		sudo sed -i -e "/java/ s/^#*/#/" /etc/profile || { error_check error ${LINENO}; };		
		sudo sed -i -e "/export/ s/^#*/#/" /etc/profile || { error_check error ${LINENO}; };		
		sudo sed -i -e '$aJAVA_HOME='$JAVA_HOME'/'$JAVA_FILE'\
				PATH=$PATH:$HOME/bin:'$JAVA_HOME'/'$JAVA_FILE'/bin \
				export JAVA_HOME \
				export PATH' /etc/profile || { error_check error ${LINENO}; };
		sudo update-alternatives --install "/usr/bin/java" "java" "$JAVA_HOME/$JAVA_FILE/jre/bin/java" 1;
		sudo update-alternatives --install "/usr/bin/javac" "javac" "$JAVA_HOME/$JAVA_FILE/bin/javac" 1 ;
		sudo update-alternatives --set java $JAVA_HOME/$JAVA_FILE/jre/bin/java;
		sudo update-alternatives --set javac $JAVA_HOME/$JAVA_FILE/bin/javac;
		## Reload your system wide PATH /etc/profile by typing the following command:;
		. /etc/profile;
		clear;
		java -version;
		javac -version;
		echo -e "Java Installed Successfully !!!";
		sudo rm -rf $HOME/hadoop-2.2.0 $HOME/hadoop;
		sleep 2;
		clear ;
}
####################################################################################################
echo -e "\t\tHadoop 2.2.0 MultiNode Cluster Setup\n"
echo -e "Setup for wired network\n"
sudo sed -ie '$a#Wired network interface setup\nauto eth0\niface eth0 inet static\naddress 192.168.1.90\ngateway 192.168.1.1\nnetmask 255.255.255.0' /etc/network/interfaces

sudo ifdown eth0
sudo ifup eth0
sudo ifdown eth0
sudo ifup eth0
sudo service network-manager restart 
ip addr
echo -e "Setup for wired network Successfully"
sleep 2
clear 
####################################################################################################
# Function to create Hadoop user
hadoop_user() {
		## Adding dedicated Hadoop system user.;
		echo -e "Hadoop 2.2.0 SingleNode Setup";
		echo -e "Adding dedicated Hadoop User";
		sudo addgroup hadoop;
		echo -e "hadoop\nhadoop\n" | sudo adduser -ingroup hadoop hduser;
		echo -e "hduser:hadoop" | sudo chpasswd ;
		sudo adduser hduser sudo;
		sudo chown -R hduser:hadoop $HADOOP_HOME;
		ls -l /usr/local;
		sleep 1;
		clear;
}
####################################################################################################

cd $HOME
echo -e "\t\tHadoop 2.2.0 MultiNode Cluster Setup\n"
echo -e "Configuring SSH\n"
sudo apt-get install ssh -y > /dev/null
clear

cd $HOME
echo -e "\t\tHadoop 2.2.0 MultiNode Cluster Setup\n"
echo -e "Disabling IPv6\n"
sudo sed -i '$a#Disable ipv6\nnet.ipv6.conf.all.disable_ipv6 = 1\nnet.ipv6.conf.default.disable_ipv6 = 1\nnet.ipv6.conf.lo.disable_ipv6 = 1' /etc/sysctl.conf
echo -e "IPv6 Disabled\n"
sleep 1
clear
####################################################################################################

echo -e "\t\tHadoop 2.2.0 MultiNode Cluster Setup\n"
echo -e "Add entries in /etc/hosts file\n"

sudo sed -i "1i 192.168.1.90 master \n192.168.1.91 slave01\n192.168.1.92 slave02\n192.168.1.93 slave03" /etc/hosts
sudo sed -i '5,100s/^/#/' /etc/hosts
sleep 1
clear
####################################################################################################

echo -e "\t\tHadoop 2.2.0 MultiNode Cluster Setup\n"
echo -e "Password-less ssh from master to slave\n"
echo -e "\n" | sudo -u hduser ssh-keygen -t rsa -P ""
sudo -u hduser ssh-copy-id -i /home/hduser/.ssh/id_rsa.pub hduser@master
# sudo -u hduser ssh-copy-id -i /home/hduser/.ssh/id_rsa.pub hduser@slave01
#sudo -u hduser ssh-copy-id -i /home/hduser/.ssh/id_rsa.pub hduser@slave02
#sudo -u hduser ssh-copy-id -i /home/hduser/.ssh/id_rsa.pub hduser@slave03
#sudo -u hduser ssh-copy-id -i /home/hduser/.ssh/id_rsa.pub hduser@slave04
clear
####################################################################################################
echo -e "\t\tHadoop 2.2.0 MultiNode Cluster Setup\n"
echo -e "Configuration of Hadoop files\n"

sudo -u hduser sed -i '$a# Set Hadoop-related environment variables\nexport HADOOP_PREFIX=/usr/local/hadoop\nexport HADOOP_HOME=/usr/local/hadoop\nexport HADOOP_MAPRED_HOME=${HADOOP_HOME}\nexport HADOOP_COMMON_HOME=${HADOOP_HOME}\nexport HADOOP_HDFS_HOME=${HADOOP_HOME}\nexport YARN_HOME=${HADOOP_HOME}\nexport HADOOP_CONF_DIR=${HADOOP_HOME}/etc/hadoop\nexport YARN_CONF_DIR=$HADOOP_HOME/etc/hadoop\n# Native Path\nexport HADOOP_COMMON_LIB_NATIVE_DIR=${HADOOP_PREFIX}/lib/native\nexport HADOOP_OPTS="-Djava.library.path=$HADOOP_PREFIX/lib"\n#Java path\nexport JAVA_HOME=/usr/local/java/'$JAVA_FILE'\n# Add Hadoop bin/ directory to PATH\nexport PATH=$PATH:$HADOOP_HOME/bin:'$JAVA_HOME'/bin:$HADOOP_HOME/sbin' /home/hduser/.bashrc
sudo -u hduser sed -i '$a# PATH For JPS\nPATH=$PATH:/usr/local/java/'$JAVA_FILE'/bin\nexport PATH' /home/hduser/.bashrc
sudo -u hduser sed -i '$aexport JAVA_HOME=/usr/local/java/'$JAVA_FILE'' /usr/local/hadoop/etc/hadoop/hadoop-env.sh

clear
echo -e "\t\tHadoop 2.2.0 MultiNode Cluster Setup\n"
echo -e "core-site.xml"
sudo -u hduser mkdir -p /usr/local/hadoop/tmp
sudo -u hduser sed -i '/<configuration>/a<property>\n<name>fs.default.name</name>\n<value>hdfs://master:9000</value>\n</property>\n<property>\n<name>hadoop.tmp.dir</name>\n<value>/usr/local/hadoop/tmp</value>\n</property>' /usr/local/hadoop/etc/hadoop/core-site.xml
echo -e "core-site.xml Done !!!"
sleep 1
clear
echo -e "\t\tHadoop 2.2.0 MultiNode Cluster Setup\n"

echo -e "hdfs-site.xml"
sudo -u hduser mkdir -p /usr/local/hadoop/yarn_data/hdfs/namenode
sudo -u hduser mkdir -p /usr/local/hadoop/yarn_data/hdfs/datanode
sudo -u hduser sed -i '/<configuration>/a<property>\n<name>dfs.replication</name>\n<value>3</value>\n</property>\n<property>\n<name>dfs.permissions </name>\n<value>false </value>\n</property>\n<property>\n<name>dfs.namenode.name.dir</name>\n<value>file:/usr/local/hadoop/yarn_data/hdfs/namenode</value>\n</property>\n<property>\n<name>dfs.datanode.name.dir</name>\n<value>file:/usr/local/hadoop/yarn_data/hdfs/datanode</value>\n</property>' /usr/local/hadoop/etc/hadoop/hdfs-site.xml
echo -e "hdfs-site.xml Done !!!"
sleep 1
clear
echo -e "\t\tHadoop 2.2.0 MultiNode Cluster Setup\n"

echo -e "mapred-site.xml"
sudo -u hduser cp /usr/local/hadoop/etc/hadoop/mapred-site.xml.template /usr/local/hadoop/etc/hadoop/mapred-site.xml
sudo -u hduser sed -i '/<configuration>/a<property>\n<name>mapreduce.framework.name</name>\n<value>yarn</value>\n</property>' /usr/local/hadoop/etc/hadoop/mapred-site.xml
echo -e "mapred-site.xml Done !!!"
sleep 1
clear
echo -e "\t\tHadoop 2.2.0 MultiNode Cluster Setup\n"

echo -e "yarn-site.xml"
sudo -u hduser sed -i '/<configuration>/a<property>\n<name>yarn.nodemanager.aux-services</name>\n<value>mapreduce_shuffle</value>\n</property>\n<property>\n<name>yarn.nodemanager.aux-services.mapreduce_shuffle.class</name>\n<value>org.apache.hadoop.mapred.ShuffleHandler</value> \n</property>\n<property>\n<name>yarn.resourcemanager.resource-tracker.address</name>\n<value>master:8025</value>\n</property>\n<property>\n<name>yarn.resourcemanager.scheduler.address</name>\n<value>master:8030</value>\n</property>\n<property>\n<name>yarn.resourcemanager.address</name>\n<value>master:8040</value>\n</property>\n<property>\n<name>yarn.nodemanager.localizer.address</name>\n<value>master:8060</value>\n</property>' /usr/local/hadoop/etc/hadoop/yarn-site.xml
echo -e "yarn-site.xml Done !!!"
sleep 1
clear
####################################################################################################
echo -e "\t\tHadoop 2.2.0 MultiNode Cluster Setup\n"

echo -e "Add entries in slaves file"
sudo -u hduser sed -i 's/localhost/ /' /usr/local/hadoop/etc/hadoop/slaves
sudo -u hduser sed -i '1imaster\nslave01\nslave02\nslave03' /usr/local/hadoop/etc/hadoop/slaves

clear
echo -e "\t\tHadoop 2.2.0 MultiNode Cluster Setup\n"
echo -e "Formating Hadoop Namenode\n"
sudo -u hduser /usr/local/hadoop/bin/hdfs namenode -format
sudo -u hduser sleep 1
clear
clear
echo -e "\t\tHadoop 2.2.0 MultiNode Cluster Setup\n"
echo -e "\nhduser created with the password \"hadoop\"\n"
#python $HOME/New_Script_For_Hadoop_cluster/spark_setup.py
cd $HOME
sudo rm -r $HADOOP_FILE $JAVA_FILE
echo -e "Done Setting up Hadoop MultiNode Cluster\n"
sleep 2

####################################################################################################
validate_args;
