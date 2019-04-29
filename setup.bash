#!/bin/bash

scriptPath=$(dirname $0)
source $scriptPath/action-verifier.bash

# Installation configurations
docker_compose_file_path=/usr/local/bin/docker-compose
docker_compose_repo_url=https://github.com/docker/compose/releases/download/1.24.0/docker-compose-`uname -s`-`uname -m`
github_fingerprint=nThbg6kXUpJWGl7E1IGOCspRomTxdCARLviKw6E5SY8

# Installation failure policy
exit_if_cannot_fetch_current_user=0
exit_if_failed_to_add_users_to_sudoers=0
exit_if_failed_to_grant_sudo_permissions_to_current_user=0

echo "Fetching the current user"
current_user=`whoami`
if [ $? -eq 0 ]
then
	echo "current user is: $current_user."
else
	echo "Failed to get the current user." >&2
	if [ $exit_if_cannot_fetch_current_user -eq 1 ]
	then
		exit 1
	else
		echo "Continue installation..."
	fi
  exit 1
fi

echo "Checking if $current_user is a member of sudoers"
getent group sudo | grep $current_user
if [ $? -eq 0 ]
then
	echo "$current_user is already a member of sudoers."
	echo "Continue installation..."
else
	echo "$current_user is not a member of sudoers."
	echo "$Adding $current_user to sudoers."
	sudo adduser $current_user sudo
	if [ $? -eq 0 ]
	then
		echo "$current_user has been successfully added to sudoers."
	else
		echo "Failed to add $current_user to sudoers." >&2
		if [ $exit_if_failed_to_add_users_to_sudoers -eq 1 ]
		then
			exit 1
		else
			echo "Continue installation with password confirmation"
		fi
	fi
fi

sudo sh -c "echo '$current_user ALL=NOPASSWD: ALL' >> /etc/sudoers"
if [ $? -eq 0 ]
then
	echo "$current_user has been granted a permission to run commands without typing passwords."
else
	echo "Failed to grant pemissions for $current_user, to run commands without typing passwords." >&2
	if [ $exit_if_failed_to_grant_sudo_permissions_to_current_user -eq 1 ]
	then
		exit 1
	else
		echo "Continue installation with password confirmation"
	fi
fi


echo "updating the package lists for upgrades"
sudo apt-get update -y
verify_action "$?" "update" "package lists for upgrades" "1"

echo "Check if docker is installed"
docker -v
if [ $? -ne 0 ]
then
	echo "docker is not installed"
	echo "installing docker"
	sudo apt-get install docker.io -y
	verify_action "$?" "install" "docker"
else
	echo "docker is already installed"
fi

echo "Check if curl is installed"
curl --version
if [ $? -ne 0 ]
then
	echo "installing curl"
	sudo apt install curl -y
	verify_action "$?" "install" "curl"
else
	echo "curl is already installed"
fi

echo "Check if docker-compose is installed"
docker-compose -v
if [ $? -ne 0 ]
then
	echo "downloading docker-compose"
	sudo curl -L $docker_compose_repo_url -o $docker_compose_file_path
	verify_action "$?" "download" "docker-compose"

	echo "Setting docker-compose permissions to executable"
	sudo chmod a+rx $docker_compose_file_path>>!#:2
	verify_action "$?" "set" "permissions of $docker_compose_file_path"
else
	echo "docker-compose is already installed"
fi

echo "adding $current_user to docker group"
sudo usermod -aG docker $current_user
verify_action "$?" "add" "user group"

echo
echo "===================================="
echo "Setup has been successfully finished"
echo "===================================="
