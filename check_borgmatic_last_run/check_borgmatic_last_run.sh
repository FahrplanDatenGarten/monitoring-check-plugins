#!/usr/bin/env bash
while getopts h: opts; do
   case ${opts} in
      h) MAX_HOURS=${OPTARG} ;;
   esac
done

last_backup_date_string=$(sudo borgmatic list --successful --last 1 --json | jq ".[0].archives[0].time" -r)

# Calculate timestamp from string
last_timestamp_date=$(date --date="$last_backup_date_string" +"%s")
now_timestamp_date=$(date +"%s")

# Calculate allowed difference in seconds
seconds=$(( MAX_HOURS * 3600 ))

# Calculate compare timestamp
compare=$(( last_timestamp_date + seconds ))
timestamp_diff_hours=$(( (now_timestamp_date - last_timestamp_date) / 3600 ))

# Compare current timestamp with compare timestamp
if [ $compare -gt $now_timestamp_date ]
then
	echo "OK: Last backup run finished: $last_backup_date_string, max $MAX_HOURS h (is $timestamp_diff_hours h)"
	exit 0
fi

echo "CRITICAL: Last backup run finished: $last_backup_date_string, max $MAX_HOURS h (is $timestamp_diff_hours h)"
exit 2
