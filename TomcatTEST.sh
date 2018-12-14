#!/bin/bash

## For TEST Environment
## Script for starting, stopping, restarting, and checking the current status of Tomcat
## ONLY TO BE RUN AS TOMCAT USER ON APPLICATION SERVER

## The EUID/UID for tomcat is 1536. This script is designed to allow only this user to run the script.

## This script can be run as follows: ./TomcatTEST.sh <start/stop/status>


# Tomcat Directory
CATALINA_HOME=/u01/app/tomcat/TEST/tomcat

# Tomcat User
TOMCAT_USER="tomcat"

# Shutdown Port Number
SHUTDOWN_PORT="8005"

# Tomcat JPDA Port Number
JPDA_PORT="8000"

# Return Value
RETVAL=0

# Listen Label
LISTEN_LABEL="LISTEN"
SHUTDOWN_STATUS=`netstat -vatn | grep $LISTEN_LABEL | grep $SHUTDOWN_PORT | wc -l`
JPDA_STATUS=`netstat -vatn | grep $LISTEN_LABEL | grep $JPDA_PORT | wc -l`

# Check Current User
check_user()
{
	if [ $EUID != 1536 ];
		then
			printf "\n\n"
			echo "You must be $TOMCAT_USER to run this script."
			printf "\n\n"
		exit -1
	fi
}


# Starting Tomcat
start_tomcat()
{
	printf "\n\n"
	printf "Preparing to start Tomcat..."
	printf "\n\n"

	sleep 10

	if [ $SHUTDOWN_STATUS -ne 0 ];
		then
			printf "\n\n"
			echo "Tomcat is currently running."
			printf "\n\n"

		else
			printf "\n\n"
			echo "Starting Tomcat..."
			printf "\n\n"
			if [ $EUID = 1536 ];
				then
					$CATALINA_HOME'/bin/startup.sh'
			else
				su -l $TOMCAT_USER -c $CATALINA_HOME'/bin/startup.sh'
			fi

		while [ $SHUTDOWN_STATUS -ne 0 ]; 
			do
				sleep 1
		done

		RETVAL=$?

		printf "\n\n"
		echo "Tomcat has been started."
		printf "\n\n"
	fi
}


# Stopping Tomcat
stop_tomcat()
{
	printf "\n\n"
	printf "Preparing to stop Tomcat..."
	printf "\n\n"

	sleep 10

	if [ $SHUTDOWN_STATUS -eq 0 ];
		then
			/bin/sh $TOMCAT_HOME/shutdown.sh

			sleep 30

			printf "\n\n"
			echo "Tomcat has already been stopped."
			printf "\n\n"

		else
			printf "\n\n"
			echo "Stopping Tomcat...."
			printf "\n\n"

			if [ $EUID = 1536 ];
				then
					$CATALINA_HOME'/bin/shutdown.sh'
			else
				su -l $TOMCAT_USER -c $CATALINA_HOME'/bin/shutdown.sh'
			fi

		while [ $SHUTDOWN_STATUS -eq 0 ];
			do
				sleep 1
		done

		printf "\n\n"
		echo "Tomcat has already been stopped."
		printf "\n\n"

	fi
}

# Restart Tomcat

##
##
## /*/TO BE SCRIPTED/*/
##
##

# Check Tomcat Status
status_tomcat()
{
	printf "\n\n"
	printf "Checking Tomcat status..."
	printf "\n\n"

	sleep 10

	if [ $SHUTDOWN_STATUS -eq 0 ];
		then
			printf "\n\n"
			echo "Tomcat is currently stopped"
			printf "\n\n"

		else
			MODE="normal"

			if [ $JPDA_STATUS -ne 0 ];
				then
					MODE="debug"
			fi

		printf "\n\n"
		echo "Tomcat is running in $MODE mode."
		printf "\n\n"
	fi
}

# Case Statement (Switch)
case "$1" in
	start)
		start_tomcat
	;;

	stop)
		stop_tomcat
	;;

	status)
		status_tomcat
	;;

	*)
		"Usage: $0 {start|stop|status}"
		exit 1
esac

exit $RETVAL
