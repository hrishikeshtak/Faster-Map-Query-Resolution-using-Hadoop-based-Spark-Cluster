#!/usr/bin/env python
import sys
import subprocess
####################################################################################################
SPARK_CONF_DIR="/home/hduser/spark-1.1.0-bin-hadoop2.3"

####################################################################################################
def validate_args():
		if(len(sys.argv) < 2):
				print "Enter input File Name"
				sys.exit(0)
		elif(len(sys.argv) < 3):
				print "Enter epsilon value ( epsilon > 0 and (int or float))"
				sys.exit(0)
###################################################################################################
def execute_command(string,error_message):
		return_value = subprocess.call(string,shell=True);
		if return_value != 0 :
				sys.exit(error_message)
###################################################################################################
validate_args();
command = "%s/bin/pyspark  Ramer_Douglas_Peucker.py " %SPARK_CONF_DIR +sys.argv[1]+ " " +sys.argv[2];
execute_command(command,"check spark is running or not");


