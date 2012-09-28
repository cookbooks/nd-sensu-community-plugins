#!/bin/bash

#
# Nagios check to get current number of connections on particular port
#
# Example: ./check-conns.sh 27017 -w 20 -c 30
#

# Exit codes
STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3
PORT=$1
HOSTNAME=$(hostname -s)
DATE=$(date +%s)

#Check arguments
if [ $# -lt 1 ]; then
	echo "Usage: $0 <port> [-w|--warning <warn>] [-c|--critical <crit>]"
	exit $STATE_UNKNOWN
fi


# Get arguments
while test -n "$1"; do
	case "$1" in
		--help)
			echo "Use: $0 <port> [-w | --warning <warn>] [-c | --critical <crit>]"
			exit $STATE_OK
			;;
		-h)
			echo "Use: $0 <port> [-w | --warning <warn>] [-c | --critical <crit>]"
			exit $STATE_OK
			;;
		--metrics)
			METRICS=$(netstat -a | grep "$PORT" | wc -l)
			echo "stats.$HOSTNAME.connections_to_$PORT" "$METRICS" "$DATE"
			exit
			;;
		--warning)
			conn_warn=$2
			shift
			;;
		-w)
			conn_warn=$2
			shift
			;;
		--critical)
			conn_crit=$2
			shift
			;;
		-c)
			conn_crit=$2
			shift
			;;
	esac
   shift
done



# Execute command to find number of connections
conn_total=$(netstat -a | grep "$PORT" | wc -l)

if (( "$conn_total" < "$conn_warn" )); then
	OUTPUT="OK - Connections on port $PORT = $conn_total"
	exitstatus=$STATE_OK
fi

if (( "$conn_total" >= "$conn_warn" )); then
	OUTPUT="Warning - Connections on port $PORT = $conn_total"
	exitstatus=$STATE_WARNING
fi

if (( "$conn_total" >= "$conn_crit" )); then
	OUTPUT="Critical - Connections on port $PORT = $conn_total"
	exitstatus=$STATE_CRITICAL
fi

echo $OUTPUT
exit $exitstatus


