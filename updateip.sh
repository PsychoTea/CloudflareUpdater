#!/bin/bash

# CHANGE THESE
auth_email="bensparkes8@gmail.com" # Your login email
auth_key="" # API Auth Key
zone_name="sparkes.tech" #Top level domain to update
declare -A records=( ["sparkes.tech"]=true ["www.sparkes.tech"]=true ["ben.sparkes.tech"]=false ) # Hash table of (sub-)domains. true/false to use cloudflare proxy

#Grab IP and zone_id
ip=$(curl -s http://ipv4.icanhazip.com)
zone_identifier=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=$zone_name" -H "X-Auth-Email: $auth_email" -H "X-Auth-Key: $auth_key" -H "Content-Type: application/json" | grep -Po '(?<="id":")[^"]*' | head -1 )

for domain in "${!records[@]}"; do

	record_identifier=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$zone_identifier/dns_records?name=$domain&type=A" \
				    -H "X-Auth-Email: $auth_email" \
				    -H "X-Auth-Key: $auth_key" \
				    -H "Content-Type: application/json" \
					| grep -Po '(?<="id":")[^"]*')

	update=$(curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$zone_identifier/dns_records/$record_identifier" \
			 -H "X-Auth-Email: $auth_email" \
			 -H "X-Auth-Key: $auth_key" \
	 	 	 -H "Content-Type: application/json" \
	  	 	 --data "{\"type\":\"A\",\"name\":\"$domain\",\"content\":\"$ip\",\"proxied\":${records[$domain]}}")

	if [[ $update == *"\"success\":false"* ]]; then
		message="API UPDATE FAILED. DUMPING RESULTS:\n$update"
    		echo -e "$message"
	else
    		echo "IP for \"$domain\" changed to: $ip"
	fi

done
