#!/bin/bash

echo -e "\t\tHadoop MultiNode Cluster Setup\n"

# Variables used in script 
COUNT_PARAM=$#;
SCRIPT_NAME=$0;
LOCAL_IPADDR=$1;
HADOOP_PARAMETER=$2;
NODE_NAME=$3;
HADOOP_TAR=$4
JAVA_TAR=$5
JAVA_HOME_PATH=/usr/local/java;
HADOOP_HOME_PATH=/usr/local/hadoop;
JAVA_DIR_NAME=jdk;
HADOOP_DIR_NAME=hadoop;
HADOOP_CONF_PATH=/usr/local/hadoop/etc/hadoop;
INTERFACE_CONF_PATH=/etc/network;

error_check() {
    echo -e "\nERROR: $SCRIPT_NAME: at Line $2 : $1";
    exit 0;
}

print_usage () {
    echo -e "\nUsage: $0 <LOCAL_IPADDR> <HADOOP_PARAMETER> <NODE_NAME> <HADOOP-TAR> <JAVA-TAR>\n"
    echo -e "    LOCAL_IPADDR - IP Address, that you want to assign to your system. "
    echo -e "                  (Please give IP Address from the 192.168.1.0 subnet)\n"
    echo -e "    HADOOP_PARAMETER - Paramaeter that specify following options "
    echo -e "                   1. Hadoop Setup, press setup or SETUP    \n"
    echo -e "                   2. Hadoop Daemons Start, press start or START    \n"
    echo -e "                   3. Hadoop Daemons Stop, press stop or STOP   \n"
    echo -e "    NODE_NAME - Paramaeter that specify on which node you have to installed Hadoop"
    echo -e "                   on master, press master\n"
    echo -e "                   on slave, press slave\n"

}

validate_args() {
    if [ $EUID -eq 0 ]
    then
        echo -e "switch to normal user";
        exit 0;
    elif [ $COUNT_PARAM -eq 0 ]
    then
        echo -e "\nERROR: LOCAL_IPADDR is missing";
        print_usage;
        exit 0;
    elif validate_IP $LOCAL_IPADDR 
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
    elif [[ $HADOOP_PARAMETER == "setup" || $HADOOP_PARAMETER == "SETUP" ]]
    then
        if [ $COUNT_PARAM -eq 2 ]
        then
            echo -e "\nERROR: NODE_NAME is missing";
            print_usage;
            exit 0;
        elif [ $COUNT_PARAM -eq 3 ]
        then
            echo -e "\nERROR: HADOOP-TAR is missing"
            exit 0
        elif [ $COUNT_PARAM -eq 4 ]
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
        elif [[ $NODE_NAME == "master" || $NODE_NAME == "MASTER" ]]
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
    sudo sed -i "/JAVA/ s/^#*/#/" /etc/profile || { error_check error ${LINENO}; }		
    sudo sed -i "/java/ s/^#*/#/" /etc/profile || { error_check error ${LINENO}; }		
    sudo sed -i "/export/ s/^#*/#/" /etc/profile || { error_check error ${LINENO}; }		
    sudo sed -i '$aJAVA_HOME_PATH='$JAVA_HOME_PATH'/'$JAVA_DIR_NAME'\
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

assign_IP() {
    echo -e "Setup for wired network\n";
    sudo sed -i '$a#Wired network interface setup \
auto eth0 \
iface eth0 inet static \
address '$LOCAL_IPADDR' \
gateway 192.168.1.1 \
netmask 255.255.255.0' $INTERFACE_CONF_PATH/interfaces || { error_check error ${LINENO}; };
    sudo ifdown eth0;
    sudo ifup eth0;
    sudo ifdown eth0;
    sudo ifup eth0;
    sudo service network-manager restart;
    ip addr;
    echo -e "Setup for wired network Successfully";
}

# Function to create Hadoop user
hadoop_user() {
    ## Adding dedicated Hadoop system user.
    echo -e "Adding dedicated Hadoop User"
    sudo addgroup hadoop
    echo -e "hadoop\nhadoop\n" | sudo adduser -ingroup hadoop hduser
    echo -e "hduser:hadoop" | sudo chpasswd
    sudo adduser hduser sudo
    sudo chown -R hduser:hadoop $HADOOP_HOME_PATH
    ls -l /usr/local
}

configure_SSH() {
    echo -e "Configuring SSH\n";
    sudo apt-get install ssh -y &> /dev/null || { error_check error ${LINENO}; };
    echo -e "Disabling IPv6\n"
    sudo sed -i "/ipv6/ s/^#*/#/" /etc/sysctl.conf;
    sudo sed -i '$a#Disable ipv6 \
net.ipv6.conf.all.disable_ipv6 = 1 \
net.ipv6.conf.default.disable_ipv6 = 1 \
net.ipv6.conf.lo.disable_ipv6 = 1' /etc/sysctl.conf || { error_check error ${LINENO}; };
    echo -e "IPv6 Disabled\n";
}

configure_SSH_MASTER() {
    echo -e "Add entries in /etc/hosts file\n";
    sudo sed -i "/master/ s/^#*/#/" /etc/hosts		
    sudo sed -i "1i $LOCAL_IPADDR master" /etc/hosts;
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
            sudo sed -i "/slave0$i/ s/^#*/#/" /etc/hosts		
            sudo sed -i "2i $IP_ADDR slave0$i" /etc/hosts;
            sudo -u hduser ssh-copy-id -i /home/hduser/.ssh/id_rsa.pub hduser@slave0$i;
    done;
    sudo sed -i "/ip6/ s/^#*/#/" /etc/hosts;

}

# Function to configure Hadoop
hadoop_configuration() {
    echo -e "Configuration of Hadoop files";
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
\nexport PATH=$PATH:'$HADOOP_HOME_PATH'/bin:'$JAVA_HOME_PATH'/bin:'$HADOOP_HOME_PATH'/sbin' /home/hduser/.bashrc || { error_check error ${LINENO}; };

    sudo -u hduser sed -i '$a# PATH For JPS \
PATH=$PATH:'$JAVA_HOME_PATH'/bin\
export PATH' /home/hduser/.bashrc || { error_check error ${LINENO}; };
    sudo -u hduser sed -i '$aexport JAVA_HOME='$JAVA_HOME_PATH'' $HADOOP_CONF_PATH/hadoop-env.sh || { error_check error ${LINENO}; };
    echo -e "core-site.xml";
    sudo -u hduser mkdir -p $HADOOP_HOME_PATH/tmp;
    sudo -u hduser sed -i "/<configuration>/a<property> \
            \n<name>fs.default.name</name> \
            \n<value>hdfs://master:9000</value> \
            \n</property> \
            \n<property> \
            \n<name>hadoop.tmp.dir</name> \
            \n<value>$HADOOP_HOME_PATH/tmp</value> \
            \n</property>" $HADOOP_CONF_PATH/core-site.xml || { error_check error ${LINENO}; };
    echo -e "core-site.xml Done !!!";
    echo -e "hdfs-site.xml";
    sudo -u hduser mkdir -p $HADOOP_HOME_PATH/yarn_data/hdfs/namenode;
    sudo -u hduser mkdir -p $HADOOP_HOME_PATH/yarn_data/hdfs/datanode;
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
            \n<value>file:$HADOOP_HOME_PATH/yarn_data/hdfs/namenode</value> \
            \n</property> \
            \n<property> \
            \n<name>dfs.datanode.name.dir</name> \
            \n<value>file:$HADOOP_HOME_PATH/yarn_data/hdfs/datanode</value> \
            \n</property>" $HADOOP_CONF_PATH/hdfs-site.xml || { error_check error ${LINENO}; };
    echo -e "hdfs-site.xml Done !!!";
    echo -e "mapred-site.xml";
    sudo -u hduser cp $HADOOP_CONF_PATH/mapred-site.xml.template $HADOOP_CONF_PATH/mapred-site.xml;
    sudo -u hduser sed -i "/<configuration>/a<property> \
            \n<name>mapreduce.framework.name</name> \
            \n<value>yarn</value> \
            \n</property>" $HADOOP_CONF_PATH/mapred-site.xml || { error_check error ${LINENO}; };
    echo -e "mapred-site.xml Done !!!";
}

hadoop_configuration_MASTER() {
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
            \n</property>" $HADOOP_CONF_PATH/yarn-site.xml || { error_check error ${LINENO}; };
    echo -e "yarn-site.xml Done !!!";
    echo -e "Add entries in slaves file";
    sudo -u hduser sed -i 's/localhost/ /' $HADOOP_CONF_PATH/slaves;
    sudo -u hduser sed -i '1imaster' $HADOOP_CONF_PATH/slaves;
    for i in `seq 1 $COUNT_SLAVES`;
    do
            sudo -u hduser sed -i '2i slave0'$i'' $HADOOP_CONF_PATH/slaves;
    done;
}

hadoop_configuration_SLAVE() {
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
            \n</property>" $HADOOP_CONF_PATH/yarn-site.xml || { error_check error ${LINENO}; };
    echo -e "yarn-site.xml Done !!!";
    echo -e "Add entries in slaves file";
    sudo -u hduser sed -i 's/localhost/ /' $HADOOP_CONF_PATH/slaves;
    sudo -u hduser sed -i '1i'$LOCAL_IPADDR'' $HADOOP_CONF_PATH/slaves;
    echo -e "Enter IP Address of master";
    read IP_ADDR;
    if validate_IP $IP_ADDR
    then
            echo -e "\nIP_ADDR $IP_ADDR is valid";
    else 
            echo -e "\nERROR: IP_ADDR $IP_ADDR is invalid";
            exit 0;
    fi
    sudo sed -i "/master/ s/^#*/#/" /etc/hosts		
    sudo sed -i "2i $IP_ADDR master" /etc/hosts;
}

# Function to Format Hadoop DFS
hadoop_format() {
    echo -e "Formating Hadoop Namenode\n";
    sudo -u hduser $HADOOP_HOME_PATH/bin/hdfs namenode -format || { error_check error ${LINENO}; };
    echo -e "\nhduser created with the password \"hadoop\"\n";
    echo -e "Done Setting up Hadoop MultiNode Cluster\n";
    sudo -u hduser /usr/local/hadoop/bin/hadoop version
}

# Function to Start Hadoop Daemons
start_hadoop() {
    echo -e "Starting Hadoop daemons\n";
    sudo -u hduser /usr/local/hadoop/sbin/hadoop-daemon.sh start namenode
    sudo -u hduser /usr/local/hadoop/sbin/hadoop-daemons.sh start datanode
    sudo -u hduser /usr/local/hadoop/sbin/hadoop-daemon.sh start secondarynamenode
    sudo -u hduser /usr/local/hadoop/sbin/yarn-daemon.sh start resourcemanager
    sudo -u hduser /usr/local/hadoop/sbin/yarn-daemons.sh start nodemanager
    sudo -u hduser /usr/local/hadoop/sbin/mr-jobhistory-daemon.sh start historyserver
    sudo -u hduser /usr/local/java/$JAVA_DIR_NAME/bin/jps;
}

# Function to Stop Hadoop Daemons
stop_hadoop() {
    echo -e "Stopping Hadoop daemons\n";
    sudo -u hduser /usr/local/hadoop/sbin/hadoop-daemon.sh stop namenode
    sudo -u hduser /usr/local/hadoop/sbin/hadoop-daemons.sh stop datanode
    sudo -u hduser /usr/local/hadoop/sbin/hadoop-daemon.sh stop secondarynamenode
    sudo -u hduser /usr/local/hadoop/sbin/yarn-daemon.sh stop resourcemanager
    sudo -u hduser /usr/local/hadoop/sbin/yarn-daemons.sh stop nodemanager
    sudo -u hduser /usr/local/hadoop/sbin/mr-jobhistory-daemon.sh stop historyserver
    sudo -u hduser /usr/local/java/$JAVA_DIR_NAME/bin/jps;
}

validate_args;
