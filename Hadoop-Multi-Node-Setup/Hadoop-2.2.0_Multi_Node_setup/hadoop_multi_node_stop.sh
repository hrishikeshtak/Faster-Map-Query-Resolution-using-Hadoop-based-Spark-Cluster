#!/bin/bash

sudo -u hduser /usr/local/hadoop/sbin/hadoop-daemon.sh stop namenode
sudo -u hduser /usr/local/hadoop/sbin/hadoop-daemons.sh stop datanode
sudo -u hduser /usr/local/hadoop/sbin/hadoop-daemon.sh stop secondarynamenode
sudo -u hduser /usr/local/hadoop/sbin/yarn-daemon.sh stop resourcemanager
sudo -u hduser /usr/local/hadoop/sbin/yarn-daemons.sh stop nodemanager
sudo -u hduser /usr/local/hadoop/sbin/mr-jobhistory-daemon.sh stop historyserver


exit 0
