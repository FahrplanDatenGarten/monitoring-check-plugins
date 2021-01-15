#!/usr/bin/env bash

## Inspired by https://margau.net/posts/2018-12-17-borgbackup/
while getopts d:h: opts; do
   case ${opts} in
      d) FILE_PATH=${OPTARG} ;;
      h) MAX_HOURS=${OPTARG} ;;
   esac
done

last_backup_date_string=$(cat "$FILE_PATH")

# Calculate timestamp from string
last_timestamp_date=$(date --date="$last_backup_date_string" +"%s")
now_timestamp_date=$(date +"%s")

# Calculate allowed difference in seconds
seconds=$(( MAX_HOURS * 3600 ))

# Calculate compare timestamp
compare=$(( last_timestamp_date + seconds))
timestamp_diff_hours=$(( (now_timestamp_date - last_timestamp_date) / 3600 ))

# Compare current timestamp with compare timestamp
if [ $compare -gt $now_timestamp_date ]
then
	echo "OK: Last run finished: $last_backup_date_string, max $MAX_HOURS h (is $timestamp_diff_hours h)"
	exit 0
fi

echo "CRITICAL: Last run finished: $last_backup_date_string, max $MAX_HOURS h (is $timestamp_diff_hours h)"
exit 2
