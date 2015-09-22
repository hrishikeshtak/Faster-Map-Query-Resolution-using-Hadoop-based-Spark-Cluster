#!/bin/bash
clear;
echo -e "Running Hadoop Wordcount Example ... "
####################################################################################################
INPUT_FILE=$1;
print_usage() {
		echo -e "\nUsage: $0 <INPUT_FILE>"
		echo -e "    INPUT_FILE - Specify Input File Name "
}
if [ $# -eq 0 ]
then
		print_usage;
		exit 0;
fi
####################################################################################################
sudo -u hduser /usr/local/hadoop/bin/hdfs dfs -ls /;
sudo -u hduser /usr/local/hadoop/bin/hdfs dfs -copyFromLocal $INPUT_FILE /file;
sudo -u hduser /usr/local/hadoop/bin/yarn jar /usr/local/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.2.0.jar wordcount /file /out;
####################################################################################################
clear;
echo -e "\n\nOutput of Wordcount : \n";
sudo -u hduser /usr/local/hadoop/bin/hdfs dfs -cat /out/part*
####################################################################################################
