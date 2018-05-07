#!/bin/bash

files=(/sys/class/net/*)
pos=$(( ${#files[*]} - 1 ))
last=${files[$pos]}

json_output="{"

	basename="eth0"

	# find the number of bytes transfered for this interface
	out1=$(cat /sys/class/net/"$basename"/statistics/tx_bytes)

	# wait a second
	sleep 30

	# check same interface again
	out2=$(cat /sys/class/net/"$basename"/statistics/tx_bytes)

	# get the difference (transfer rate)
	out_bytes=$((out2 - out1))

	# convert transfer rate to KB
	out_kbytes=$(((out_bytes / 1024 / 30) * 8))

	# convert transfer rate to KB
	json_output="$json_output \"$basename\": $out_kbytes"

# close the JSON object & print to screen
echo "$json_output}" > /usr/local/nginx/html/status.json
