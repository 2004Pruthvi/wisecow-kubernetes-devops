#!/bin/bash

# ==========================================
# Application Health Checker
# Purpose: Check application availability using HTTP
# ==========================================

# Default timeout in seconds
TIMEOUT=10

# Log file
LOG_FILE="$HOME/application-health.log"

# Validate input URL
if [ -z "$1" ]; then
    echo "Usage: $0 <application-url>"
    exit 1
fi

URL="$1"

# Evaluate application status
CURL_EXIT_CODE=0

HTTP_STATUS=$(curl -L -sS -o /dev/null \
    -w "%{http_code}" \
    --connect-timeout "$TIMEOUT" \
    --max-time "$TIMEOUT" \
    "$URL") || CURL_EXIT_CODE=$?

if [ "$CURL_EXIT_CODE" -eq 0 ] && [[ "$HTTP_STATUS" =~ ^2[0-9][0-9]$ ]]; then
    STATUS="UP"
    MESSAGE="Application is responding successfully (HTTP $HTTP_STATUS)"
    EXIT_CODE=0
else
    STATUS="DOWN"

    if [ "$HTTP_STATUS" = "000" ]; then
        MESSAGE="Application is unreachable or request timed out"
    else
        MESSAGE="Application returned HTTP $HTTP_STATUS"
    fi

    EXIT_CODE=1
fi

# Function to log messages with timestamps
log_message() {
    local MESSAGE="$1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $MESSAGE" | tee -a "$LOG_FILE"
}

# Display and record the health-check result
echo "Application URL: $URL"
echo "Application Status: $STATUS"

log_message "$MESSAGE"

exit "$EXIT_CODE"
