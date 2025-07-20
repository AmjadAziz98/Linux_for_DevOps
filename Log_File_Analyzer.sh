#!/bin/bash

# Check if a file path is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <log_file_path>"
    exit 1
fi

LOGFILE="$1"

# Check if the file exists
if [ ! -f "$LOGFILE" ]; then
    echo "Error: File '$LOGFILE' does not exist."
    exit 1
fi

# Collect general info
ANALYSIS_TIME=$(date "+%a %b %d %T %Z %Y")
FILE_SIZE_BYTES=$(stat -c%s "$LOGFILE")
FILE_SIZE_HUMAN=$(du -h "$LOGFILE" | cut -f1)

# Count ERROR, WARNING, and INFO messages
ERROR_COUNT=$(grep -c "ERROR" "$LOGFILE")
WARNING_COUNT=$(grep -c "WARNING" "$LOGFILE")
INFO_COUNT=$(grep -c "INFO" "$LOGFILE")

# Top 5 error messages
TOP_ERRORS=$(grep "ERROR" "$LOGFILE" | awk -F 'ERROR ' '{print $2}' | sort | uniq -c | sort -rn | head -n 5)

# First and last error with timestamp
FIRST_ERROR=$(grep "ERROR" "$LOGFILE" | head -n 1)
LAST_ERROR=$(grep "ERROR" "$LOGFILE" | tail -n 1)

# Error frequency by hour buckets
declare -A BUCKETS
for hour in {00..23}; do BUCKETS[$hour]=0; done

while read -r line; do
    timestamp=$(echo "$line" | grep -oP '\[\K[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}')
    hour=${timestamp:11:2}
    ((BUCKETS[$hour]++))
done < <(grep "ERROR" "$LOGFILE")

# Output report to terminal and file
REPORT_FILE="log_analysis_$(date +%Y%m%d_%H%M%S).txt"

{
echo "===== LOG FILE ANALYSIS REPORT ====="
echo "File: $LOGFILE"
echo "Analyzed on: $ANALYSIS_TIME"
echo "Size: $FILE_SIZE_HUMAN ($FILE_SIZE_BYTES bytes)"
echo
echo "MESSAGE COUNTS:"
echo "ERROR: $ERROR_COUNT messages"
echo "WARNING: $WARNING_COUNT messages"
echo "INFO: $INFO_COUNT messages"
echo
echo "TOP 5 ERROR MESSAGES:"
echo "$TOP_ERRORS"
echo
echo "ERROR TIMELINE:"
echo "First error: $FIRST_ERROR"
echo "Last error:  $LAST_ERROR"
echo
echo "Error frequency by hour:"
for range in 00 04 08 12 16 20; do
    from=$range
    to=$(printf "%02d" $((10#$range + 4)))
    count=0
    for h in $(seq -w $from $(printf "%02d" $((10#$to - 1)))); do
        ((count+=BUCKETS[$h]))
    done
    bars=$(printf '█%.0s' $(seq 1 $((count / 5 + 1))))
    echo "$from-$to: $bars ($count)"
done
echo
echo "Report saved to: $REPORT_FILE"
} | tee "$REPORT_FILE"
