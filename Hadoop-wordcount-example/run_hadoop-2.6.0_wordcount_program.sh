#!/bin/bash

clear;
echo "Running Hadoop Wordcount Example ... "
if [ $# -eq 0 ]
then
		echo "\n\nEnter input File name : ";
		exit 1;
fi
####################################################################################################
sudo -u hduser /usr/local/hadoop/bin/hdfs dfs -ls /;
sudo -u hduser /usr/local/hadoop/bin/hdfs dfs -copyFromLocal $1 /file;
sudo -u hduser /usr/local/hadoop/bin/yarn jar /usr/local/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.6.0.jar wordcount /file /out;
####################################################################################################
clear;
echo "\n\nOutput of Wordcount : \n";
sudo -u hduser /usr/local/hadoop/bin/hdfs dfs -cat /out/part*
####################################################################################################
