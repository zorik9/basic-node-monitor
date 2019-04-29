#!/bin/bash
scriptPath=$(dirname $0)
source $scriptPath/action-verifier.bash

echo "Restarting docker-compose"
sudo docker-compose restart
verify_action "$?" "restart" "docker-compose"
