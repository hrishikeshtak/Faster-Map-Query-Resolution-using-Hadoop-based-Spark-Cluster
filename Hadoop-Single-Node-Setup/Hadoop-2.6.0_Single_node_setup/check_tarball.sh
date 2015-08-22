#!/bin/bash

JDK_TAR_FILE=jdk-8u20-linux-i586.tar.gz
HADOOP_TAR_FILE=hadoop-2.6.0.tar.gz

if [ -f $HOME/$JDK_TAR_FILE ] 
then 
	echo "$JDK_TAR_FILE Found"; 
else 
	echo "Copy $JDK_TAR_FILE To $HOME Path then run the script "; 
	exit
fi

if [ -f $HOME/$HADOOP_TAR_FILE ] 
then 
	echo "$HADOOP_TAR_FILE Found"; 
else 
	echo "Copy $HADOOP_TAR_FILE To $HOME Path then run the script "; 
	exit
fi
