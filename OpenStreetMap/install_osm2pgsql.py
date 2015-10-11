#!/usr/bin/env python
import sys
import subprocess

USERNAME="gisuser"
DATABASE_NAME="gis"
POSTGIS_CONF_DIR="/usr/share/postgresql/9.1/contrib/postgis-1.5"
POSTGRESQL_CONF_DIR="/etc/postgresql/9.1/main"
OSM_FILE=" "
####################################################################################################
def validate_args():
		global OSM_FILE
		if len(sys.argv) < 2:
				sys.exit("Please pass .osm file as parameter");
		else:
				OSM_FILE=sys.argv[1]
				print OSM_FILE;
####################################################################################################
def execute_command(command,error_message):
		return_value = subprocess.call(command,shell=True);
		if return_value != 0:
				sys.exit(error_message);
####################################################################################################
def install_osm2pgsql():
		command = "sudo apt-get -y install postgresql postgresql-contrib postgis"
		execute_command(command,"postgresql not installed");
		command = "sudo apt-get -y install osm2pgsql"
		execute_command(command,"osm2pgsql not installed");
####################################################################################################
def configure_osm2pgsql():
		global OSM_FILE
		command = "sudo -u postgres createuser %s"%USERNAME
		execute_command(command,"postgres user not created");
		command = "sudo -u postgres createdb --encoding=UTF8 --owner=%s %s"%(USERNAME,DATABASE_NAME)
		execute_command(command,"postgres db not created");
		command = "psql -d %s -f %s/postgis.sql" %(DATABASE_NAME,POSTGIS_CONF_DIR)
		execute_command(command,"postgis.sql file not found");
		command = "psql -d %s -f 900913.sql" %DATABASE_NAME
		execute_command(command,"900913.sql file not found");
		command = "osm2pgsql -U postgres -s -S default.style %s" %(OSM_FILE)
		execute_command(command,"OSM_FILE file not found");
		command = "sudo sed -i -e 's/local   all             postgres                                md5/local   all             postgres                                trust/' /etc/postgresql/9.1/main/pg_hba.confsudo sed -e 's/local   all             postgres                                md5/local   all             postgres                                trust/' %s/pg_hba.conf" %POSTGRESQL_CONF_DIR
		execute_command(command,"pg_hba.conf file not found");
####################################################################################################
validate_args();
execute_command("clear",None);
install_osm2pgsql();
configure_osm2pgsql();
