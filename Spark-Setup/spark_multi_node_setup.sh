#!/bin/bash
clear;
echo -e "\nSpark Multi-Node Setup";
cd $HOME;
####################################################################################################
# Variables used in script 
COUNT_PARAMETER=$#;
SCRIPT_NAME=$0;
SPARK_PARAMETER=$1;
MASTER_IP_ADDR=$2;
SPARK_TAR_FILE=spark-1.1.0-bin-hadoop2.3.tgz;
SPARK_FILE=spark-1.1.0-bin-hadoop2.3;
SPARK_CONF_DIR=/home/hduser/spark-1.1.0-bin-hadoop2.3/conf;
SPARK_WORKER_DIR=/home/hduser/spark-1.1.0-bin-hadoop2.3/sparkdata;
####################################################################################################
if [ $EUID -eq 0 ]
then
		echo -e "switch to normal user";
		exit 0;
fi

if [ ! -f $HOME/$SPARK_TAR_FILE ]
then
		echo -e "\nERROR: $HOME/$SPARK_TAR_FILE not exists";
		exit 0;
fi
####################################################################################################;
error_check() {
		echo -e "\nERROR: $SCRIPT_NAME: at Line $2 : $1";
		exit 0;
}
####################################################################################################;
print_usage () {
		echo -e "\nUsage: $0 <SPARK_PARAMETER> <MASTER_IP_ADDR>"
		echo -e "    SPARK_PARAMETER - Paramaeter that specify following options "
		echo -e "                   1. Spark Setup , press setup or SETUP    \n"
		echo -e "                   2. Spark Daemons Start , press start or START    \n"
		echo -e "                   3. Spark Daemons Stop  , press stop or STOP   \n"
		echo -e "    MASTER_IP_ADDR - IP Address of master node where master of Hadoop is running "

}
####################################################################################################;
validate_args() {
		if [ $COUNT_PARAMETER -eq 0 ]
		then
				echo -e "\nERROR: SPARK_PARAMETER is missing";
				print_usage;
				exit 0;
		else
				if [[ $SPARK_PARAMETER == "setup" || $SPARK_PARAMETER == "SETUP" ]]
				then
						if [ $COUNT_PARAMETER -eq 1 ]
						then
								echo -e "\nERROR: MASTER_IP_ADDR is missing";
								print_usage;
								exit 0;
						else
								if validate_IP $MASTER_IP_ADDR; 
								then 
										echo -e "\nMASTER_IP_ADDR $MASTER_IP_ADDR is reachable";
								else 
										echo -e "\nERROR: MASTER_IP_ADDR $MASTER_IP_ADDR is unreachable";
										exit 0;
								fi	
						fi
						start_hadoop || { error_check Hadoop-Not-install-properly ${LINENO};};
						spark_configure;
						exit 0;
				fi
				if [[ $SPARK_PARAMETER == "start" || $SPARK_PARAMETER == "START" ]]
				then
						start_spark;
						exit 0;
		
				fi
				if [[ $SPARK_PARAMETER == "stop" || $SPARK_PARAMETER == "STOP" ]]
				then
						stop_spark;
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
		if [ $stat -eq 0 ]
		then			
				ping -c1 $1 &> /dev/null;
				if [ $? -eq 0 ]; 
				then 
						stat=$?;
				else 
						stat=$?;
				fi
		else
				echo -e "\n$1 is not valid IP ADDRESS";
				exit 0;
		fi

		return $stat

}
####################################################################################################
spark_configure() {
		sudo cp -r $HOME/$SPARK_TAR_FILE /home/hduser/;
		sudo chown -R hduser:hadoop /home/hduser/$SPARK_TAR_FILE;
		sudo tar -xvf /home/hduser/$SPARK_TAR_FILE -C /home/hduser;
		sudo cp $SPARK_CONF_DIR/spark-env.sh.template $SPARK_CONF_DIR/spark-env.sh;
		sudo sed -i -e '$a export SPARK_WORKER_INSTANCES=1 \
				export SPARK_WORKER_DIR='$SPARK_WORKER_DIR' \
				export SPARK_MASTER_IP='$MASTER_IP_ADDR' \
				export SPARK_MASTER_PORT=7077' $SPARK_CONF_DIR/spark-env.sh;
		sudo sed -i -e 's/localhost/master\nslave01\n/' $SPARK_CONF_DIR/slaves;
		sudo chown -R hduser:hadoop /home/hduser/$SPARK_FILE;
		clear;
		echo "Spark Setup successfully";
		sleep 1;
}
####################################################################################################
start_spark() {
		sudo -u hduser /home/hduser/$SPARK_FILE/sbin/start-all.sh || { error_check spark-not-setup-properly ${LINENO}; };
}
####################################################################################################
stop_spark() {
		sudo -u hduser /home/hduser/$SPARK_FILE/sbin/stop-all.sh || { error_check spark-not-setup-properly ${LINENO}; };
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
stop_hadoop() {
		clear;
		echo -e "Starting Hadoop daemons\n";
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
