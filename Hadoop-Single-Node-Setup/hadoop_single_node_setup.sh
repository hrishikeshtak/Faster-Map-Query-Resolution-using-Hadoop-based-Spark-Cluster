#!/bin/bash

echo -e "\nHadoop SingleNode Setup"

# Variables used in script 
COUNT_PARAM=$#
SCRIPT_NAME=$0
HADOOP_PARAM=$1
HADOOP_TAR=$2
JAVA_TAR=$3
JAVA_HOME_PATH=/usr/local/java
HADOOP_HOME_PATH=/usr/local/hadoop
HADOOP_CONF_PATH=/usr/local/hadoop/etc/hadoop
JAVA_DIR_NAME=jdk
HADOOP_DIR_NAME=hadoop

error_check() {
    echo -e "\nERROR: $SCRIPT_NAME: at Line $2 : $1"
    exit 0
}

print_usage() {
    echo -e "\nUsage: $0 <HADOOP-PARAM> <HADOOP-TAR> <JAVA-TAR>"
    echo -e "    HADOOP-PARAM - Paramaeter that specify following options "
    echo -e "                   1. Hadoop Setup, press setup or SETUP    \n"
    echo -e "                   2. Hadoop Daemons Start, press start or START    \n"
    echo -e "                   3. Hadoop Daemons Stop, press stop or STOP   \n"

}

validate_args() {
    if [ $EUID -eq 0 ]
    then
        echo -e "switch to normal user"
        exit 0
    elif [ $COUNT_PARAM -eq 0 ]
    then
        echo -e "\nERROR: HADOOP_PARAM is missing"
        print_usage
        exit 0
    else
        if [[ $HADOOP_PARAM == "setup" || $HADOOP_PARAM == "SETUP" ]]
        then
            if [ $COUNT_PARAM -eq 1 ]
            then
                echo -e "\nERROR: HADOOP-TAR is missing"
                exit 0
            elif [ $COUNT_PARAM -eq 2 ]
            then
                echo -e "\nERROR: JAVA-TAR is missing"
                exit 0
            elif [ ! -f $HADOOP_TAR ]
            then
                echo -e "\nERROR: $HADOOP_TAR is not TARBALL"
                exit 0
            elif [ ! -f $JAVA_TAR ]
            then
                echo -e "\nERROR: $JAVA_TAR is not TARBALL"
                exit 0
            fi
        install_JAVA
        hadoop_user
        hadoop_configuration
        hadoop_format
        exit 0
        elif [[ $HADOOP_PARAM == "start" || $HADOOP_PARAM == "START" ]]
        then
            start_hadoop
            exit 0
        elif [[ $HADOOP_PARAM == "stop" || $HADOOP_PARAM == "STOP" ]]
        then
            stop_hadoop
            exit 0
        else
            echo -e "\nWrong input"
            print_usage
            exit 0
        fi
    fi
}

install_JAVA() {
    sudo apt-get -y purge openjdk* &> /dev/null || { error_check error ${LINENO}; }
    sudo chmod -R 755 $JAVA_TAR
    sudo chmod -R 755 $HADOOP_TAR
    sudo mkdir -p $JAVA_HOME_PATH
    mkdir -p $HOME/$JAVA_DIR_NAME
    mkdir -p $HOME/$HADOOP_DIR_NAME
    tar -xvf $JAVA_TAR -C $HOME/$JAVA_DIR_NAME --strip-components=1 || { error_check error ${LINENO}; }
    tar -xvf $HADOOP_TAR -C $HOME/$HADOOP_DIR_NAME --strip-components=1 || { error_check error ${LINENO}; }
    sudo cp -r  $HOME/$HADOOP_DIR_NAME /usr/local/
    sudo cp -r $HOME/$JAVA_DIR_NAME $JAVA_HOME_PATH
    # If already present JAVA configuration , comment it 
    sudo sed -i -e "/JAVA/ s/^#*/#/" /etc/profile || { error_check error ${LINENO}; }		
    sudo sed -i -e "/java/ s/^#*/#/" /etc/profile || { error_check error ${LINENO}; }		
    sudo sed -i -e "/export/ s/^#*/#/" /etc/profile || { error_check error ${LINENO}; }		
    sudo sed -i -e '$aJAVA_HOME_PATH='$JAVA_HOME_PATH'/'$JAVA_DIR_NAME'\
PATH=$PATH:$HOME/bin:'$JAVA_HOME_PATH'/'$JAVA_DIR_NAME'/bin \
export JAVA_HOME_PATH \
export PATH' /etc/profile || { error_check error ${LINENO}; }
    sudo update-alternatives --install "/usr/bin/java" "java" "$JAVA_HOME_PATH/$JAVA_DIR_NAME/jre/bin/java" 1
    sudo update-alternatives --install "/usr/bin/javac" "javac" "$JAVA_HOME_PATH/$JAVA_DIR_NAME/bin/javac" 1 
    sudo update-alternatives --set java $JAVA_HOME_PATH/$JAVA_DIR_NAME/jre/bin/java
    sudo update-alternatives --set javac $JAVA_HOME_PATH/$JAVA_DIR_NAME/bin/javac
    ## Reload your system wide PATH /etc/profile by typing the following command:
    . /etc/profile
    java -version
    javac -version
    echo -e "Java Installed Successfully !!!"
    sudo rm -rf $HOME/$JAVA_DIR_NAME $HOME/$HADOOP_DIR_NAME
    sleep 2
}

## Function to create Hadoop user
hadoop_user() {
    ## Adding dedicated Hadoop system user.
    echo -e "Adding dedicated Hadoop User"
    sudo addgroup hadoop
    echo -e "hadoop\nhadoop\n" | sudo adduser -ingroup hadoop hduser
    echo -e "hduser:hadoop" | sudo chpasswd 
    sudo adduser hduser sudo
    sudo chown -R hduser:hadoop $HADOOP_HOME_PATH
    ls -l /usr/local
    sleep 1
}

# Function to configure Hadoop
hadoop_configuration() {
    echo -e "Hadoop SingleNode Setup"
    echo -e "Configuration of Hadoop files"
    sudo -u hduser sed -i '$a# Set Hadoop-related environment variables \
            \nexport HADOOP_PREFIX='$HADOOP_HOME_PATH' \
            \nexport HADOOP_HOME_PATH='$HADOOP_HOME_PATH' \
            \nexport HADOOP_MAPRED_HOME=${HADOOP_HOME_PATH} \
            \nexport HADOOP_COMMON_HOME=${HADOOP_HOME_PATH} \
            \nexport HADOOP_HDFS_HOME=${HADOOP_HOME_PATH} \
            \nexport YARN_HOME=${HADOOP_HOME_PATH} \
            \nexport HADOOP_CONF_PATH=${HADOOP_HOME_PATH}/etc/hadoop \
            \nexport YARN_CONF_DIR='$HADOOP_HOME_PATH'/etc/hadoop \
            \n# Native Path \
            \nexport HADOOP_COMMON_LIB_NATIVE_DIR=${HADOOP_PREFIX}/lib/native \
            \nexport HADOOP_OPTS="-Djava.library.path=$HADOOP_PREFIX/lib" \
            \n#Java path \
            \nexport JAVA_HOME_PATH='$JAVA_HOME_PATH' \
            \n# Add Hadoop bin/ directory to PATH \
            \nexport PATH=$PATH:'$HADOOP_HOME_PATH'/bin:'$JAVA_HOME_PATH'/bin:'$HADOOP_HOME_PATH'/sbin' /home/hduser/.bashrc || { error_check error ${LINENO}; }

    sudo -u hduser sed -i '$a# PATH For JPS \
PATH=$PATH:'$JAVA_HOME_PATH'/bin\
export PATH' /home/hduser/.bashrc || { error_check error ${LINENO}; }

    sudo -u hduser sed -i '$aexport JAVA_HOME='$JAVA_HOME_PATH'' $HADOOP_CONF_PATH/hadoop-env.sh || { error_check error ${LINENO}; }
    echo -e "core-site.xml"
    sudo -u hduser mkdir -p $HADOOP_HOME_PATH/tmp
    sudo -u hduser sed -i "/<configuration>/a<property> \
            \n<name>fs.default.name</name> \
            \n<value>hdfs://localhost:9000</value> \
            \n</property> \
            \n<property> \
            \n<name>hadoop.tmp.dir</name> \
            \n<value>$HADOOP_HOME_PATH/tmp</value> \
            \n</property>" $HADOOP_CONF_PATH/core-site.xml || { error_check error ${LINENO}; }
    echo -e "core-site.xml Done !!!"
    echo -e "hdfs-site.xml"
    sudo -u hduser mkdir -p $HADOOP_HOME_PATH/yarn_data/hdfs/namenode
    sudo -u hduser mkdir -p $HADOOP_HOME_PATH/yarn_data/hdfs/datanode
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
            \n<value>file:$HADOOP_HOME_PATH/yarn_data/hdfs/namenode</value> \
            \n</property> \
            \n<property> \
            \n<name>dfs.datanode.name.dir</name> \
            \n<value>file:$HADOOP_HOME_PATH/yarn_data/hdfs/datanode</value> \
            \n</property>" $HADOOP_CONF_PATH/hdfs-site.xml || { error_check error ${LINENO}; }
    echo -e "hdfs-site.xml Done !!!"
    echo -e "mapred-site.xml"
    sudo -u hduser cp $HADOOP_CONF_PATH/mapred-site.xml.template $HADOOP_CONF_PATH/mapred-site.xml
    sudo -u hduser sed -i "/<configuration>/a<property> \
            \n<name>mapreduce.framework.name</name> \
            \n<value>yarn</value> \
            \n</property>" $HADOOP_CONF_PATH/mapred-site.xml || { error_check error ${LINENO}; }
    echo -e "mapred-site.xml Done !!!"
    echo -e "yarn-site.xml"
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
            \n</property>" $HADOOP_CONF_PATH/yarn-site.xml || { error_check error ${LINENO}; }
    echo -e "yarn-site.xml Done !!!"
}

# Function to Format Hadoop DFS
hadoop_format() {
    echo -e "Formating Hadoop Namenode\n"
    sudo -u hduser $HADOOP_HOME_PATH/bin/hdfs namenode -format || { error_check error ${LINENO}; }
    echo -e "\nhduser created with the password \"hadoop\"\n"
    echo -e "Done Setting up Hadoop SingleNode Cluster\n"
    sudo -u hduser /usr/local/hadoop/bin/hadoop version
}

# Function to Start Hadoop Daemons
start_hadoop() {
    echo -e "Starting Hadoop daemons\n"
    sudo -u hduser /usr/local/hadoop/sbin/hadoop-daemon.sh start namenode
    sudo -u hduser /usr/local/hadoop/sbin/hadoop-daemon.sh start datanode
    sudo -u hduser /usr/local/hadoop/sbin/hadoop-daemon.sh start secondarynamenode
    sudo -u hduser /usr/local/hadoop/sbin/yarn-daemon.sh start resourcemanager
    sudo -u hduser /usr/local/hadoop/sbin/yarn-daemon.sh start nodemanager
    sudo -u hduser /usr/local/hadoop/sbin/mr-jobhistory-daemon.sh start historyserver
    sudo -u hduser /usr/local/java/$JAVA_DIR_NAME/bin/jps
}

# Function to Stop Hadoop Daemons
stop_hadoop() {
    echo -e "Stopping Hadoop daemons\n"
    sudo -u hduser /usr/local/hadoop/sbin/hadoop-daemon.sh stop namenode
    sudo -u hduser /usr/local/hadoop/sbin/hadoop-daemon.sh stop datanode
    sudo -u hduser /usr/local/hadoop/sbin/hadoop-daemon.sh stop secondarynamenode
    sudo -u hduser /usr/local/hadoop/sbin/yarn-daemon.sh stop resourcemanager
    sudo -u hduser /usr/local/hadoop/sbin/yarn-daemon.sh stop nodemanager
    sudo -u hduser /usr/local/hadoop/sbin/mr-jobhistory-daemon.sh stop historyserver
    sudo -u hduser /usr/local/java/$JAVA_DIR_NAME/bin/jps
}

validate_args
