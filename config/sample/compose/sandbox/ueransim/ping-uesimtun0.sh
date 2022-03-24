#!/usr/bin/env bash                                                                       
CODE=1
for num in {1..10}; do
	if ip link | grep -oP 'uesimtun0'; then
		ping -w 1 -c 1 -I uesimtun0 8.8.8.8;
	        CODE=$?
		break
	else
		echo "uesimtun0 not up, will try again in 0.5 second";
		sleep 0.5
	fi
done

echo CODE = $CODE
exit $CODE 
