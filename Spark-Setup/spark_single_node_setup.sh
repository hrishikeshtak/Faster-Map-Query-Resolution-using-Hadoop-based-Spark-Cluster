#!/bin/bash
clear;
echo -e "\nSpark SingleNode Setup";
cd $HOME;
####################################################################################################
# Variables used in script 
COUNT_PARAM=$#;
SCRIPT_NAME=$0;
SPARK_PARAM=$1;
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
		echo -e "\nUsage: $0 <SPARK_PARAM>"
		echo -e "    SPARK_PARAM - Paramaeter that specify following options "
		echo -e "                   1. Spark Setup , press setup or SETUP    \n"
		echo -e "                   2. Spark Daemons Start , press start or START    \n"
		echo -e "                   3. Spark Daemons Stop  , press stop or STOP   \n"

}
####################################################################################################;
validate_args() {
		if [ $COUNT_PARAM -eq 0 ]
		then
				echo -e "\nERROR: SPARK_PARAM is missing";
				print_usage;
				exit 0;
		else
				if [[ $SPARK_PARAM == "setup" || $SPARK_PARAM == "SETUP" ]]
				then
						start_hadoop || { error_check Hadoop-Not-install-properly ${LINENO};};
						spark_configure;
						exit 0;
				fi
				if [[ $SPARK_PARAM == "start" || $SPARK_PARAM == "START" ]]
				then
						start_spark;
						exit 0;
		
				fi
				if [[ $SPARK_PARAM == "stop" || $SPARK_PARAM == "STOP" ]]
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
spark_configure() {
		sudo cp -r $HOME/$SPARK_TAR_FILE /home/hduser/;
		sudo chown -R hduser:hadoop /home/hduser/$SPARK_TAR_FILE;
		sudo tar -xvf /home/hduser/$SPARK_TAR_FILE -C /home/hduser;
		sudo cp $SPARK_CONF_DIR/spark-env.sh.template $SPARK_CONF_DIR/spark-env.sh;

		sudo sed -i -e '$a export SPARK_WORKER_INSTANCES=1 \
				export SPARK_WORKER_DIR='$SPARK_WORKER_DIR' \
				export SPARK_MASTER_IP=127.0.0.1 \
				export SPARK_MASTER_PORT=7077' $SPARK_CONF_DIR/spark-env.sh;

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
