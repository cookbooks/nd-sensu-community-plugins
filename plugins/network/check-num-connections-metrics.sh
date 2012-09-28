#!/bin/bash

PORT=$1
HOSTNAME=$(hostname -s)
DATE=$(date +%s)
METRICS=$(netstat -a | grep "$PORT" | wc -l)

echo -e "stats.$HOSTNAME.connections_to_$PORT $METRICS $DATE"