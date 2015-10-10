#!/usr/bin/env python
import sys
import subprocess

subprocess.call("clear",shell=True)

if(len(sys.argv) < 2):
	print "Enter input File Name"
	sys.exit(0)

if(len(sys.argv) < 3):
	print "Enter epsilon value"
	sys.exit(0)

command = "/home/hduser/spark-1.1.0-bin-hadoop2.3/bin/pyspark  Ramer_Douglas_Peucker.py "+sys.argv[1]+ " " +sys.argv[2];
#print command
subprocess.call(command,shell=True)
name = subprocess.check_output("date | cut --delimiter=\" \" -f4",shell=True)
name = name[:-1]
command = "echo \"Madhrishi\" | sudo -S cp /home/hrishi/Final_presentation/Output_Polygon.png /var/www/project.com/public_html/downloads/Output_Polygon_"+name+".png"
#print command
subprocess.call(command,shell=True)


