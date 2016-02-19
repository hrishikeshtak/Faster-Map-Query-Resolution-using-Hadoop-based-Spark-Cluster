#!/bin/bash

echo -e "\nSpark SingleNode Setup"

# Variables used in script 
COUNT_PARAM=$#
SCRIPT_NAME=$0
SPARK_PARAM=$1
SPARK_TAR=$2
SPARK_DIR_NAME=spark
JDK_DIR_NAME=jdk
SPARK_CONF_PATH=/home/hduser/$SPARK_DIR_NAME/conf
SPARK_WORKER_PATH=/home/hduser/$SPARK_DIR_NAME/sparkdata

error_check() {
    echo -e "\nERROR: $SCRIPT_NAME: at Line $2 : $1"
    exit 0
}

print_usage () {
    echo -e "\nUsage: $0 <SPARK_PARAM>"
    echo -e "    SPARK_PARAM - Paramaeter that specify following options "
    echo -e "                   1. Spark Setup , press setup or SETUP    \n"
    echo -e "                   2. Spark Daemons Start , press start or START    \n"
    echo -e "                   3. Spark Daemons Stop  , press stop or STOP   \n"

}

validate_args() {
    if [ $EUID -eq 0 ]
    then
        echo -e "switch to normal user"
        exit 0
    elif [ $COUNT_PARAM -eq 0 ]
    then
        echo -e "\nERROR: SPARK_PARAM is missing"
        print_usage
        exit 0
    else
        if [[ $SPARK_PARAM == "setup" || $SPARK_PARAM == "SETUP" ]]
        then
            if [ $COUNT_PARAM -eq 1 ]
            then
                echo -e "\nERROR: SPARK_TAR is missing"
                exit 0
            elif [ ! -f $SPARK_TAR ]
            then
                echo -e "\nERROR: $SPARK_TAR not exists"
                exit 0
            fi
            start_hadoop
            spark_configure
            exit 0
        elif [[ $SPARK_PARAM == "start" || $SPARK_PARAM == "START" ]]
        then
            start_spark
            exit 0

        elif [[ $SPARK_PARAM == "stop" || $SPARK_PARAM == "STOP" ]]
        then
            stop_spark
            stop_hadoop
            exit 0
        else
            echo -e "\nWrong input"
            print_usage
            exit 0
        fi
    fi
}

spark_configure() {
    sudo mkdir -p $HOME/$SPARK_DIR_NAME
    sudo tar -xvf $SPARK_TAR -C $HOME/$SPARK_DIR_NAME --strip-components=1
    sudo cp -r $HOME/$SPARK_DIR_NAME /home/hduser/
    sudo cp $SPARK_CONF_PATH/spark-env.sh.template $SPARK_CONF_PATH/spark-env.sh
    sudo sed -i '$a export SPARK_WORKER_INSTANCES=1 \
export SPARK_WORKER_DIR='$SPARK_WORKER_PATH' \
export SPARK_MASTER_IP=127.0.0.1 \
export SPARK_MASTER_PORT=7077' $SPARK_CONF_PATH/spark-env.sh
    sudo chown -R hduser:hadoop /home/hduser/$SPARK_DIR_NAME
    echo "Spark Setup successfully"
}

start_spark() {
    sudo -u hduser /home/hduser/$SPARK_DIR_NAME/sbin/start-all.sh || { error_check spark-not-setup-properly ${LINENO}; }
}

stop_spark() {
    sudo -u hduser /home/hduser/$SPARK_DIR_NAME/sbin/stop-all.sh || { error_check spark-not-setup-properly ${LINENO}; }
}

# Function to Start Hadoop Daemons
start_hadoop() {
    echo -e "Starting Hadoop daemons\n"
    sudo -u hduser /usr/local/hadoop/sbin/hadoop-daemon.sh start namenode || { error_check namenode-not-started ${LINENO};}
    sudo -u hduser /usr/local/hadoop/sbin/hadoop-daemon.sh start datanode || { error_check datanode-not-started ${LINENO};}
    sudo -u hduser /usr/local/hadoop/sbin/hadoop-daemon.sh start secondarynamenode || { error_check secondarynamenode-not-started ${LINENO};}
    sudo -u hduser /usr/local/hadoop/sbin/yarn-daemon.sh start resourcemanager || { error_check resourcemanager-not-started ${LINENO};}
    sudo -u hduser /usr/local/hadoop/sbin/yarn-daemon.sh start nodemanager || { error_check nodemanager-not-started ${LINENO};}
    sudo -u hduser /usr/local/hadoop/sbin/mr-jobhistory-daemon.sh start historyserver || { error_check historyserver-not-started ${LINENO};}

    sudo -u hduser /usr/local/java/$JDK_DIR_NAME/bin/jps
}

stop_hadoop() {
    echo -e "Starting Hadoop daemons\n"
    sudo -u hduser /usr/local/hadoop/sbin/hadoop-daemon.sh stop namenode || { error_check namenode-not-stoped ${LINENO};}
    sudo -u hduser /usr/local/hadoop/sbin/hadoop-daemon.sh stop datanode || { error_check datanode-not-stoped ${LINENO};}
    sudo -u hduser /usr/local/hadoop/sbin/hadoop-daemon.sh stop secondarynamenode || { error_check secondarynamenode-not-stoped ${LINENO};}
    sudo -u hduser /usr/local/hadoop/sbin/yarn-daemon.sh stop resourcemanager || { error_check resourcemanager-not-stoped ${LINENO};}
    sudo -u hduser /usr/local/hadoop/sbin/yarn-daemon.sh stop nodemanager || { error_check nodemanager-not-stoped ${LINENO};}
    sudo -u hduser /usr/local/hadoop/sbin/mr-jobhistory-daemon.sh stop historyserver || { error_check historyserver-not-stoped ${LINENO};}

    sudo -u hduser /usr/local/java/$JDK_DIR_NAME/bin/jps
}

validate_args
