#!/bin/bash

# Script for stopping hadoop daemons
clear
echo "Stopping Hadoop Daemons\n"
hadoop-daemon.sh stop namenode
hadoop-daemon.sh stop datanode
hadoop-daemon.sh stop secondarynamenode

yarn-daemon.sh stop resourcemanager
yarn-daemon.sh stop nodemanager
mr-jobhistory-daemon.sh stop historyserver

jps

exit 0
