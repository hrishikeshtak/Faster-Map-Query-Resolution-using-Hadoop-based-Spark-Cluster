#!/bin/bash
clear;
echo -e "\nHadoop 2.6.0 SingleNode Setup";
cd $HOME;
####################################################################################################;
# Variables used in script 
COUNT_PARAM=$#;
SCRIPT_NAME=$0;
HADOOP_PARAM=$1;
JDK_TAR_FILE=jdk-8u20-linux-i586.tar.gz;
HADOOP_TAR_FILE=hadoop-2.6.0.tar.gz;
JAVA_HOME=/usr/local/java;
HADOOP_HOME=/usr/local/hadoop;
JAVA_FILE=jdk1.8.0_20;
HADOOP_FILE=hadoop-2.6.0;
HADOOP_CONF_DIR=/usr/local/hadoop/etc/hadoop;
####################################################################################################;
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
####################################################################################################;
error_check() {
		echo -e "\nERROR: $SCRIPT_NAME: at Line $2 : $1";
		exit 0;
}
####################################################################################################;
print_usage () {
		echo -e "\nUsage: $0 <HADOOP_PARAM>"
		echo -e "    HADOOP_PARAM - Paramaeter that specify following options "
		echo -e "                   1. Hadoop Setup , press setup or SETUP    \n"
		echo -e "                   2. Hadoop Daemons Start , press start or START    \n"
		echo -e "                   3. Hadoop Daemons Stop  , press stop or STOP   \n"

}
####################################################################################################;
validate_args() {
		if [ $COUNT_PARAM -eq 0 ]
		then
				echo -e "\nERROR: HADOOP_PARAM is missing";
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
		cp -r $HOME/hadoop-2.6.0 $HOME/hadoop;
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
		sudo rm -rf $HOME/hadoop-2.6.0 $HOME/hadoop;
		sleep 2;
		clear ;
}
####################################################################################################;
# Function to create Hadoop user
hadoop_user() {
		## Adding dedicated Hadoop system user.;
		echo -e "Hadoop 2.6.0 SingleNode Setup";
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
####################################################################################################;
# Function to configure Hadoop
hadoop_configuration() {

		echo -e "Hadoop 2.6.0 SingleNode Setup";
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
		clear;
		echo -e "Hadoop 2.6.0 SingleNode Setup\n";
		echo -e "core-site.xml";
		sudo -u hduser mkdir -p $HADOOP_HOME/tmp;
		sudo -u hduser sed -i "/<configuration>/a<property> \
				\n<name>fs.default.name</name> \
				\n<value>hdfs://localhost:9000</value> \
				\n</property> \
				\n<property> \
				\n<name>hadoop.tmp.dir</name> \
				\n<value>$HADOOP_HOME/tmp</value> \
				\n</property>" $HADOOP_CONF_DIR/core-site.xml || { error_check error ${LINENO}; };
		echo -e "core-site.xml Done !!!";
		sleep 1;
		clear;
		echo -e "Hadoop 2.6.0 SingleNode Setup\n";
		echo -e "hdfs-site.xml";
		sudo -u hduser mkdir -p $HADOOP_HOME/yarn_data/hdfs/namenode;
		sudo -u hduser mkdir -p $HADOOP_HOME/yarn_data/hdfs/datanode;
		sudo -u hduser sed -i "/<configuration>/a<property> \
				\n<name>dfs.replication</name> \
				\n<value>1</value> \
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
		echo -e "Hadoop 2.6.0 SingleNode Setup\n";
		echo -e "mapred-site.xml";
		sudo -u hduser cp $HADOOP_CONF_DIR/mapred-site.xml.template $HADOOP_CONF_DIR/mapred-site.xml;
		sudo -u hduser sed -i "/<configuration>/a<property> \
				\n<name>mapreduce.framework.name</name> \
				\n<value>yarn</value> \
				\n</property>" $HADOOP_CONF_DIR/mapred-site.xml || { error_check error ${LINENO}; };
		echo -e "mapred-site.xml Done !!!";
		sleep 1;
		clear;
		echo -e "Hadoop 2.6.0 SingleNode Setup\n";
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
				\n<value>localhost:8025</value> \
				\n</property> \
				\n<property> \
				\n<name>yarn.resourcemanager.scheduler.address</name> \
				\n<value>localhost:8030</value> \
				\n</property> \
				\n<property> \
				\n<name>yarn.resourcemanager.address</name> \
				\n<value>localhost:8040</value> \
				\n</property> \
				\n<property> \
				\n<name>yarn.nodemanager.localizer.address</name> \
				\n<value>localhost:8060</value> \
				\n</property>" $HADOOP_CONF_DIR/yarn-site.xml || { error_check error ${LINENO}; };
		echo -e "yarn-site.xml Done !!!";
		sleep 1;
		clear;
}
####################################################################################################
# Function to Format Hadoop DFS
hadoop_format() {
		echo -e "Hadoop 2.6.0 SingleNode Setup\n";
		echo -e "Formating Hadoop Namenode\n";
		sudo -u hduser $HADOOP_HOME/bin/hdfs namenode -format || { error_check error ${LINENO}; };
		sleep 1;
		clear;
		echo -e "Hadoop 2.6.0 SingleNode Setup\n";
		echo -e "\nhduser created with the password \"hadoop\"\n";
		echo -e "Done Setting up Hadoop SingleNode Cluster\n";
		cd $HOME;
}
####################################################################################################
# Function to Start Hadoop Daemons
start_hadoop() {
		clear;
		echo -e "Starting Hadoop daemons\n";
		sudo -u hduser /usr/local/hadoop/sbin/hadoop-daemon.sh start namenode || { error_check namenode-not-started ${LINENO};};
		sudo -u hduser /usr/local/hadoop/sbin/hadoop-daemon.sh start datanode || { error_check datanode-not-started ${LINENO};};
		sudo -u hduser /usr/local/hadoop/sbin/hadoop-daemon.sh start secondarynamenode || { error_check secondarynamenode-not-started ${LINENO};};
		sudo -u hduser /usr/local/hadoop/sbin/yarn-daemon.sh start resourcemanager || { error_check resourcemanager-not-started ${LINENO};};
		sudo -u hduser /usr/local/hadoop/sbin/yarn-daemon.sh start nodemanager || { error_check nodemanager-not-started ${LINENO};};
		sudo -u hduser /usr/local/hadoop/sbin/mr-jobhistory-daemon.sh start historyserver || { error_check historyserver-not-started ${LINENO};};

		sudo -u hduser /usr/local/java/jdk1.8.0_20/bin/jps;
}
####################################################################################################
# Function to Stop Hadoop Daemons
stop_hadoop() {
		clear;
		echo "Stopping Hadoop daemons\n";
		sudo -u hduser /usr/local/hadoop/sbin/hadoop-daemon.sh stop namenode || { error_check namenode-not-stoped ${LINENO};};
		sudo -u hduser /usr/local/hadoop/sbin/hadoop-daemon.sh stop datanode || { error_check datanode-not-stoped ${LINENO};};
		sudo -u hduser /usr/local/hadoop/sbin/hadoop-daemon.sh stop secondarynamenode || { error_check secondarynamenode-not-stoped ${LINENO};};
		sudo -u hduser /usr/local/hadoop/sbin/yarn-daemon.sh stop resourcemanager || { error_check resourcemanager-not-stoped ${LINENO};};
		sudo -u hduser /usr/local/hadoop/sbin/yarn-daemon.sh stop nodemanager || { error_check nodemanager-not-stoped ${LINENO};};
		sudo -u hduser /usr/local/hadoop/sbin/mr-jobhistory-daemon.sh stop historyserver || { error_check historyserver-not-stoped ${LINENO};};

		sudo -u hduser /usr/local/java/jdk1.8.0_20/bin/jps;
}
####################################################################################################
validate_args;
