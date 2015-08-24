#!/bin/bash

sudo -u hduser /usr/local/hadoop/sbin/hadoop-daemon.sh start namenode
sudo -u hduser /usr/local/hadoop/sbin/hadoop-daemons.sh start datanode
sudo -u hduser /usr/local/hadoop/sbin/hadoop-daemon.sh start secondarynamenode
sudo -u hduser /usr/local/hadoop/sbin/yarn-daemon.sh start resourcemanager
sudo -u hduser /usr/local/hadoop/sbin/yarn-daemons.sh start nodemanager
sudo -u hduser /usr/local/hadoop/sbin/mr-jobhistory-daemon.sh start historyserver


#sudo -u hduser sh /home/hduser/spark-1.1.0-bin-hadoop2.3/sbin/start-all.sh


exit 0
