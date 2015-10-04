#!/bin/bash

clear
echo -e "\t\tHadoop 2.2.0 MultiNode Cluster Setup\n"
cd $HOME
####################################################################################################
# Variables used in script 
COUNT_PARAM=$#;
SCRIPT_NAME=$0;
LOCAL_IPADDR=$1;
HADOOP_PARAMETER=$2;
NODE_NAME=$3;
JDK_TAR_FILE=jdk-8u20-linux-i586.tar.gz;
HADOOP_TAR_FILE=hadoop-2.2.0.tar.gz;
JAVA_HOME=/usr/local/java;
HADOOP_HOME=/usr/local/hadoop;
JAVA_FILE=jdk1.8.0_20;
HADOOP_FILE=hadoop-2.2.0;
HADOOP_CONF_DIR=/usr/local/hadoop/etc/hadoop;
INTERFACE_CONF_DIR=/etc/network;
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
####################################################################################################
print_usage () {
		echo -e "\nUsage: $0 <LOCAL_IPADDR> <HADOOP_PARAMETER> <NODE_NAME>\n"
		echo -e "    LOCAL_IPADDR - IP Address , that you want to assign to your system. "
		echo -e "                  (Please give IP Address from the 192.168.1.0 subnet)\n"
		echo -e "    HADOOP_PARAMETER - Paramaeter that specify following options "
		echo -e "                   1. Hadoop Setup , press setup or SETUP    \n"
		echo -e "                   2. Hadoop Daemons Start , press start or START    \n"
		echo -e "                   3. Hadoop Daemons Stop  , press stop or STOP   \n"
		echo -e "    NODE_NAME - Paramaeter that specify on which node you have to installed Hadoop"
		echo -e "                   on master , press master\n"
		echo -e "                   on slave , press slave\n"

}
####################################################################################################
validate_args() {
		if [ $COUNT_PARAM -eq 0 ]
		then
				echo -e "\nERROR: LOCAL_IPADDR is missing";
				print_usage;
				exit 0;
		fi
		if validate_IP $LOCAL_IPADDR 
		then
				echo -e "\nLOCAL_IPADDR $LOCAL_IPADDR is valid";
		else 
				echo -e "\nERROR: LOCAL_IPADDR $LOCAL_IPADDR is invalid";
				exit 0;
		fi	
		if [ $COUNT_PARAM -eq 1 ]
		then
				echo -e "\nERROR: HADOOP_PARAMETER is missing";
				print_usage;
				exit 0;
		fi
		if [[ $HADOOP_PARAMETER == "setup" || $HADOOP_PARAMETER == "SETUP" ]]
		then
				if [ $COUNT_PARAM -eq 2 ]
				then
						echo -e "\nERROR: NODE_NAME is missing";
						print_usage;
						exit 0;
				fi
				if [[ $NODE_NAME == "master" || $NODE_NAME == "MASTER" ]]
				then
						install_JAVA;
						assign_IP;
						hadoop_user;
						configure_SSH;
						configure_SSH_MASTER;
						hadoop_configuration;
						hadoop_configuration_MASTER;
						hadoop_format;
				elif [[ $NODE_NAME == "slave" || $NODE_NAME == "SLAVE" ]]
				then
						install_JAVA;
						assign_IP;
						hadoop_user;
						configure_SSH;
						hadoop_configuration;
						hadoop_configuration_SLAVE;
						hadoop_format;
				else
						echo -e "Please Enter appropriate NODE_NAME (master or slave)";
						exit 0;
				fi

		elif [[ $HADOOP_PARAMETER == "start" || $HADOOP_PARAMETER == "START" ]]
		then
				start_hadoop;
				exit 0;

		elif [[ $HADOOP_PARAMETER == "stop" || $HADOOP_PARAMETER == "STOP" ]]
		then
				stop_hadoop;
				exit 0;
		else
				echo -e "\nWrong input";
				print_usage;
				exit 0;
		fi
}
####################################################################################################
validate_IP() {
		local  ip=$1;
		local  stat=1;

		if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
				OIFS=$IFS
				IFS='.'
				ip=($ip)
				IFS=$OIFS
				[[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
						&& ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
				stat=$?;
		fi
		return $stat

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
assign_IP() {
		echo -e "\t\tHadoop 2.2.0 MultiNode Cluster Setup\n";
		echo -e "Setup for wired network\n";
		sudo sed -ie '$a#Wired network interface setup \
				auto eth0 \
				iface eth0 inet static \
				address '$LOCAL_IPADDR' \
				gateway 192.168.1.1 \
				netmask 255.255.255.0' $INTERFACE_CONF_DIR/interfaces || { error_check error ${LINENO}; };
		sudo ifdown eth0;
		sudo ifup eth0;
		sudo ifdown eth0;
		sudo ifup eth0;
		sudo service network-manager restart;
		ip addr;
		echo -e "Setup for wired network Successfully";
		sleep 2;
		clear;
}
####################################################################################################
# Function to create Hadoop user
hadoop_user() {
		## Adding dedicated Hadoop system user.;
		echo -e "Hadoop 2.2.0 MultiNode Setup";
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
configure_SSH() {
		cd $HOME;
		echo -e "\t\tHadoop 2.2.0 MultiNode Cluster Setup\n";
		echo -e "Configuring SSH\n";
		sudo apt-get install ssh -y &> /dev/null || { error_check error ${LINENO}; };
		clear;
		echo -e "Disabling IPv6\n"
		sudo sed -i -e "/ipv6/ s/^#*/#/" /etc/sysctl.conf;
		sudo sed -i '$a#Disable ipv6 \
				net.ipv6.conf.all.disable_ipv6 = 1 \
				net.ipv6.conf.default.disable_ipv6 = 1 \
				net.ipv6.conf.lo.disable_ipv6 = 1' /etc/sysctl.conf || { error_check error ${LINENO}; };
		echo -e "IPv6 Disabled\n";
		sleep 1;
		clear;
}
####################################################################################################
configure_SSH_MASTER() {
		echo -e "Add entries in /etc/hosts file\n";
		sudo sed -i -e "1i $LOCAL_IPADDR master" /etc/hosts;
		echo -e "Password-less ssh from master to slave";
		echo -e "\n" | sudo -u hduser ssh-keygen -t rsa -P "";
		sudo -u hduser ssh-copy-id -i /home/hduser/.ssh/id_rsa.pub hduser@master;
		echo -e "Enter number of slaves\n";
		read COUNT_SLAVES; 
		for i in `seq 1 $COUNT_SLAVES`;
		do
				echo -e "Enter IP Address of slave0$i";
				read IP_ADDR;
				if validate_IP $IP_ADDR
				then
						echo -e "\nIP_ADDR $IP_ADDR is valid";
				else 
						echo -e "\nERROR: IP_ADDR $IP_ADDR is invalid";
						exit 0;
				fi
				sudo sed -i -e "2i $IP_ADDR slave0$i" /etc/hosts;
				sudo -u hduser ssh-copy-id -i /home/hduser/.ssh/id_rsa.pub hduser@slave0$i;
		done;
		sudo sed -i -e "/ip6/ s/^#*/#/" /etc/hosts;

}
####################################################################################################
# Function to configure Hadoop
hadoop_configuration() {
		echo -e "Hadoop 2.2.0 MultiNode Setup";
		echo -e "Configuration of Hadoop files";
		sudo -u hduser sed -i '$a# Set Hadoop-related environment variables \
				\nexport HADOOP_PREFIX='$HADOOP_HOME' \
				\nexport HADOOP_HOME='$HADOOP_HOME' \
				\nexport HADOOP_MAPRED_HOME=${HADOOP_HOME} \
				\nexport HADOOP_COMMON_HOME=${HADOOP_HOME} \
				\nexport HADOOP_HDFS_HOME=${HADOOP_HOME} \
				\nexport YARN_HOME=${HADOOP_HOME} \
				\nexport HADOOP_CONF_DIR=${HADOOP_HOME}/etc/hadoop \
				\nexport YARN_CONF_DIR='$HADOOP_HOME'/etc/hadoop \
				\n# Native Path \
				\nexport HADOOP_COMMON_LIB_NATIVE_DIR=${HADOOP_PREFIX}/lib/native \
				\nexport HADOOP_OPTS="-Djava.library.path=$HADOOP_PREFIX/lib" \
				\n#Java path \
				\nexport JAVA_HOME='$JAVA_HOME' \
				\n# Add Hadoop bin/ directory to PATH \
				\nexport PATH=$PATH:'$HADOOP_HOME'/bin:'$JAVA_HOME'/bin:'$HADOOP_HOME'/sbin' /home/hduser/.bashrc || { error_check error ${LINENO}; };
		sudo -u hduser sed -i '$a# PATH For JPS \
		PATH=$PATH:'$JAVA_HOME'/bin\
		export PATH' /home/hduser/.bashrc || { error_check error ${LINENO}; };
		sudo -u hduser sed -i '$aexport JAVA_HOME='$JAVA_HOME'' $HADOOP_CONF_DIR/hadoop-env.sh || { error_check error ${LINENO}; };
		echo -e "Hadoop 2.2.0 MultiNode Setup\n";
		echo -e "core-site.xml";
		sudo -u hduser mkdir -p $HADOOP_HOME/tmp;
		sudo -u hduser sed -i "/<configuration>/a<property> \
				\n<name>fs.default.name</name> \
				\n<value>hdfs://master:9000</value> \
				\n</property> \
				\n<property> \
				\n<name>hadoop.tmp.dir</name> \
				\n<value>$HADOOP_HOME/tmp</value> \
				\n</property>" $HADOOP_CONF_DIR/core-site.xml || { error_check error ${LINENO}; };
		echo -e "core-site.xml Done !!!";
		sleep 1;
		clear;
		echo -e "Hadoop 2.2.0 MultiNode Setup\n";
		echo -e "hdfs-site.xml";
		sudo -u hduser mkdir -p $HADOOP_HOME/yarn_data/hdfs/namenode;
		sudo -u hduser mkdir -p $HADOOP_HOME/yarn_data/hdfs/datanode;
		sudo -u hduser sed -i "/<configuration>/a<property> \
				\n<name>dfs.replication</name> \
				\n<value>3</value> \
				\n</property> \
				\n<property> \
				\n<name>dfs.permissions </name> \
				\n<value>false </value> \
				\n</property> \
				\n<property> \
				\n<name>dfs.namenode.name.dir</name> \
				\n<value>file:$HADOOP_HOME/yarn_data/hdfs/namenode</value> \
				\n</property> \
				\n<property> \
				\n<name>dfs.datanode.name.dir</name> \
				\n<value>file:$HADOOP_HOME/yarn_data/hdfs/datanode</value> \
				\n</property>" $HADOOP_CONF_DIR/hdfs-site.xml || { error_check error ${LINENO}; };
		echo -e "hdfs-site.xml Done !!!";
		sleep 1;
		clear;
		echo -e "Hadoop 2.2.0 MultiNode Setup\n";
		echo -e "mapred-site.xml";
		sudo -u hduser cp $HADOOP_CONF_DIR/mapred-site.xml.template $HADOOP_CONF_DIR/mapred-site.xml;
		sudo -u hduser sed -i "/<configuration>/a<property> \
				\n<name>mapreduce.framework.name</name> \
				\n<value>yarn</value> \
				\n</property>" $HADOOP_CONF_DIR/mapred-site.xml || { error_check error ${LINENO}; };
		echo -e "mapred-site.xml Done !!!";
		sleep 1;
		clear;
		echo -e "Hadoop 2.2.0 MultiNode Setup\n";
		echo -e "yarn-site.xml";
		sudo -u hduser sed -i "/<configuration>/a<property> \
				\n<name>yarn.nodemanager.aux-services</name> \
				\n<value>mapreduce_shuffle</value> \
				\n</property> \
				\n<property> \
				\n<name>yarn.nodemanager.aux-services.mapreduce_shuffle.class</name> \
				\n<value>org.apache.hadoop.mapred.ShuffleHandler</value> \
				\n</property> \
				\n<property> \
				\n<name>yarn.resourcemanager.resource-tracker.address</name> \
				\n<value>master:8025</value> \
				\n</property> \
				\n<property> \
				\n<name>yarn.resourcemanager.scheduler.address</name> \
				\n<value>master:8030</value> \
				\n</property> \
				\n<property> \
				\n<name>yarn.resourcemanager.address</name> \
				\n<value>master:8040</value> \
				\n</property> \
				\n<property> \
				\n<name>yarn.nodemanager.localizer.address</name> \
				\n<value>master:8060</value> \
				\n</property>" $HADOOP_CONF_DIR/yarn-site.xml || { error_check error ${LINENO}; };
		echo -e "yarn-site.xml Done !!!";
		sleep 1;
		clear;
}
####################################################################################################
hadoop_configuration_MASTER() {
		echo -e "Add entries in slaves file";
		sudo -u hduser sed -i 's/localhost/ /' $HADOOP_CONF_DIR/slaves;
		sudo -u hduser sed -i '1imaster' $HADOOP_CONF_DIR/slaves;
		for i in `seq 1 $COUNT_SLAVES`;
		do
				sudo -u hduser sed -i '2i slave0'$i'' $HADOOP_CONF_DIR/slaves;
		done;
}
####################################################################################################
hadoop_configuration_SLAVE() {
		echo -e "Add entries in slaves file";
		sudo -u hduser sed -i 's/localhost/ /' $HADOOP_CONF_DIR/slaves;
		sudo -u hduser sed -i '1i'$LOCAL_IPADDR'' $HADOOP_CONF_DIR/slaves;
}
####################################################################################################
# Function to Format Hadoop DFS
hadoop_format() {
		echo -e "Hadoop 2.2.0 MultiNode Setup\n";
		echo -e "Formating Hadoop Namenode\n";
		sudo -u hduser $HADOOP_HOME/bin/hdfs namenode -format || { error_check error ${LINENO}; };
		sleep 1;
		clear;
		echo -e "Hadoop 2.2.0 MultiNode Setup\n";
		echo -e "\nhduser created with the password \"hadoop\"\n";
		echo -e "Done Setting up Hadoop MultiNode Cluster\n";
		cd $HOME;
}
####################################################################################################
# Function to Start Hadoop Daemons
start_hadoop() {
		clear;
		echo -e "Starting Hadoop daemons\n";
		sudo -u hduser /usr/local/hadoop/sbin/hadoop-daemon.sh start namenode || { error_check namenode-not-started ${LINENO};};
		sudo -u hduser /usr/local/hadoop/sbin/hadoop-daemons.sh start datanode || { error_check datanode-not-started ${LINENO};};
		sudo -u hduser /usr/local/hadoop/sbin/hadoop-daemon.sh start secondarynamenode || { error_check secondarynamenode-not-started ${LINENO};};
		sudo -u hduser /usr/local/hadoop/sbin/yarn-daemon.sh start resourcemanager || { error_check resourcemanager-not-started ${LINENO};};
		sudo -u hduser /usr/local/hadoop/sbin/yarn-daemons.sh start nodemanager || { error_check nodemanager-not-started ${LINENO};};
		sudo -u hduser /usr/local/hadoop/sbin/mr-jobhistory-daemon.sh start historyserver || { error_check historyserver-not-started ${LINENO};};

		sudo -u hduser /usr/local/java/jdk1.8.0_20/bin/jps;
}
####################################################################################################
# Function to Stop Hadoop Daemons
stop_hadoop() {
		clear;
		echo "Stopping Hadoop daemons\n";
		sudo -u hduser /usr/local/hadoop/sbin/hadoop-daemon.sh stop namenode || { error_check namenode-not-stoped ${LINENO};};
		sudo -u hduser /usr/local/hadoop/sbin/hadoop-daemons.sh stop datanode || { error_check datanode-not-stoped ${LINENO};};
		sudo -u hduser /usr/local/hadoop/sbin/hadoop-daemon.sh stop secondarynamenode || { error_check secondarynamenode-not-stoped ${LINENO};};
		sudo -u hduser /usr/local/hadoop/sbin/yarn-daemon.sh stop resourcemanager || { error_check resourcemanager-not-stoped ${LINENO};};
		sudo -u hduser /usr/local/hadoop/sbin/yarn-daemons.sh stop nodemanager || { error_check nodemanager-not-stoped ${LINENO};};
		sudo -u hduser /usr/local/hadoop/sbin/mr-jobhistory-daemon.sh stop historyserver || { error_check historyserver-not-stoped ${LINENO};};

		sudo -u hduser /usr/local/java/jdk1.8.0_20/bin/jps;
}
####################################################################################################
validate_args;
