#!/bin/bash
scriptPath=$(dirname $0)
source $scriptPath/action-verifier.bash

api_key_file_name=api_key.txt
api_key_file=$scriptPath/$api_key_file_name

if [ -f "$api_key_file" ]
then
	echo "Removing old api key"
    sudo rm $api_key_file
	verify_action "$?" "remove" "old api key"
fi

echo "Stopping docker-compose"
sudo docker-compose down
verify_action "$?" "stop" "docker-compose"


running_containers=`sudo docker ps -aq -f status=running`
if [ -z "$running_containers" ]
then
	echo "No running docker containers"
else
	echo "Killing all of the running docker containers"
	sudo docker kill $(sudo docker ps -a -q)
	verify_action "$?" "kill" "all of docker containers" "1"
fi

registered_images=`sudo docker ps -aq --no-trunc`
if [ -z "$registered_images" ]
then
	echo "No registered images"
else
	echo "Remove all images"
	sudo docker rm $(sudo docker ps -a -q)
	verify_action "$?" "remove" "all of docker images" "1"
fi

echo "Starting docker-compose"
sudo docker-compose up
if [ ! $? -eq 0 ]
then
	echo "Failed to start docker-compose" >&2
	exit 1
fi
