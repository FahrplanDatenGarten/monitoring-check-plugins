#!/usr/bin/env bash

## Inspired by https://margau.net/posts/2018-12-17-borgbackup/
while getopts d:h: opts; do
   case ${opts} in
      d) FILE_PATH=${OPTARG} ;;
      h) HOURS=${OPTARG} ;;
   esac
done

last_timestamp_file=$(cat "$FILE_PATH")

# Calculate timestamp from string
last_timestamp=$(date --date="$last_timestamp_file" +"%s")
now_timestamp=$(date +"%s")

# Calculate allowed difference in seconds
sec=$(( HOURS * 3600 ))

# Calculate compare timestamp
compare=$(( last_timestamp + sec))
timestamp_diff_hours=$(((now_timestamp - last_timestamp) / 3600))

# Compare current timestamp with compare timestamp
if [ $compare -gt $now_timestamp ]
then
	echo "OK: Last run finished: $last_timestamp_file, max $HOURS h (is $timestamp_diff_hours h)"
	exit 0
fi

echo "CRITICAL: Last run finished: $last_timestamp_file, max $HOURS h (is $timestamp_diff_hours h)"
exit 2
