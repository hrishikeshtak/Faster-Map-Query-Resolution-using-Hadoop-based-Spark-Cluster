#!/bin/bash

cd $HOME
if [ ! -f $HOME/spark-1.1.0-bin-hadoop2.3.tgz ]
then
		echo -e "\nERROR: $HOME/spark-1.1.0-bin-hadoop2.3.tgz not exists";
		exit 0;
fi

sudo cp -r $HOME/spark-1.1.0-bin-hadoop2.3.tgz /home/hduser/
sudo chown -R hduser:hadoop /home/hduser/spark-1.1.0-bin-hadoop2.3.tgz
sudo tar -xvf /home/hduser/spark-1.1.0-bin-hadoop2.3.tgz -C /home/hduser
sudo cp /home/hduser/spark-1.1.0-bin-hadoop2.3/conf/spark-env.sh.template /home/hduser/spark-1.1.0-bin-hadoop2.3/conf/spark-env.sh

sudo sed -ie '$a export SPARK_WORKER_INSTANCES=1 \
export SPARK_WORKER_DIR=/home/hduser/spark-1.1.0-bin-hadoop2.3/sparkdata \
export SPARK_MASTER_IP=127.0.0.1 \
export SPARK_MASTER_PORT=7077' /home/hduser/spark-1.1.0-bin-hadoop2.3/conf/spark-env.sh

sudo chown -R hduser:hadoop /home/hduser/spark-1.1.0-bin-hadoop2.3
clear
echo "Spark Setup successfully"
sleep 1

