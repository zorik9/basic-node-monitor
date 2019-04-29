#!/usr/bin/env bash

scriptPath=$(dirname $0)
source $scriptPath/action-verifier.bash

api_key_file_name=api_key.txt
api_key_file=$scriptPath/$api_key_file_name

if [ -f "$api_key_file" ]
then
	echo "Reading new api key"
	api_key=$(cat $api_key_file)
	verify_action "$?" "read" "new api key"
else
	
	org_id=1
	echo "Switching the org context for the admin user"
	curl -X POST http://admin:admin@localhost:3000/api/user/using/$org_id
	
	echo "Creating new api key"
	str_api_key=`curl -X POST -H "Content-Type: application/json" -d '{"name":"apikeycurl", "role": "Admin"}' http://admin:admin@localhost:3000/api/auth/keys`
	
	echo "Extracting api key"
	api_key=`echo $str_api_key|awk -F'":"' '{print $3}' | head -c -3`
	
	if [[ -z "$api_key" ]];
	then
        echo "Failed to extract api key"
	    exit 1
	fi
	
	echo "Storing new api key"
	echo "$api_key" > "$api_key_file"
	verify_action "$?" "store" "new api key"
	
	if [ ! -s $api_key_file ]
	then
        echo "An empty api key has been stored in $api_key_file"
        echo "Failed to get api key"
	else
        echo "Api key has been successfully stored."
	fi
fi


# get handle of the default dashboard (in order to remove it)
unwanted_dashboard_title="mydashboard"
unwanted_dashboard_details=`curl -X GET --insecure -H "Authorization: Bearer $api_key" http://localhost:3000/api/search?query=$unwanted_dashboard_title 2>&1`
unwanted_dashboard_uid=`echo $unwanted_dashboard_details| awk -F":" '{ print $15}'|awk -F"," '{ print $1}'| cut -d "\"" -f 2`

# Delete default dashboard, if it's already exist
if [ ! -z "$unwanted_dashboard_uid" ]
then
	curl -X DELETE --insecure -H "Authorization: Bearer $api_key" http://localhost:3000/api/dashboards/uid/$unwanted_dashboard_uid
fi

# get dashboard uid
dashboard_title="Basic%20Monitor%20Overview"
dashboard_details=`curl -X GET --insecure -H "Authorization: Bearer $api_key" http://localhost:3000/api/search?query=$dashboard_title 2>&1`
dashboard_uid=`echo $dashboard_details| awk -F":" '{ print $15}'|awk -F"," '{ print $1}'| cut -d "\"" -f 2`

# Delete dashboard, if it's already exist
if [ ! -z "$dashboard_uid" ]
then
	curl -X DELETE --insecure -H "Authorization: Bearer $api_key" http://localhost:3000/api/dashboards/uid/$dashboard_uid
fi

# Create dashboard
curl -X POST --insecure -H "Authorization: Bearer $api_key" -H "Content-Type: application/json" -d '@./grafana/dashboards/dashboard.txt' http://localhost:3000/api/dashboards/db
echo
