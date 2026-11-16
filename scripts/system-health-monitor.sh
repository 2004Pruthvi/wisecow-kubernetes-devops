#!/bin/bash

# ==========================================
# System Health Monitoring Script
# Purpose: Monitor CPU, Memory, Disk and Processes
# ==========================================

# Alert thresholds
CPU_THRESHOLD=80
MEMORY_THRESHOLD=80
DISK_THRESHOLD=80
PROCESS_THRESHOLD=300

# Log file
LOG_FILE="$HOME/system-health.log"

# Function to log messages with timestamps
log_message() {
    local MESSAGE="$1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $MESSAGE" | tee -a "$LOG_FILE"
}

# Function to check CPU usage
check_cpu() {
    CPU_IDLE=$(top -bn2 | grep "Cpu(s)" | tail -1 | awk -F',' '{print $4}' | awk '{print $1}')

    CPU_USAGE=$(awk -v idle="$CPU_IDLE" 'BEGIN {printf "%.1f", 100-idle}')

    echo "CPU Usage: ${CPU_USAGE}%"

    if awk -v usage="$CPU_USAGE" -v threshold="$CPU_THRESHOLD" 'BEGIN {exit !(usage > threshold)}'
    then
        log_message "ALERT: High CPU usage: ${CPU_USAGE}%"
    else
        log_message "CPU usage is normal: ${CPU_USAGE}%"
    fi
}

# Function to check memory usage
check_memory() {
    read -r TOTAL USED AVAILABLE < <(free -m | awk '/^Mem:/ {print $2, $3, $7}')

    MEMORY_USAGE=$(awk -v total="$TOTAL" -v available="$AVAILABLE" \
        'BEGIN {printf "%.1f", ((total-available)/total)*100}')

    echo "Memory Usage: ${MEMORY_USAGE}%"

    if awk -v usage="$MEMORY_USAGE" -v threshold="$MEMORY_THRESHOLD" \
        'BEGIN {exit !(usage > threshold)}'
    then
        log_message "ALERT: High memory usage: ${MEMORY_USAGE}%"
    else
        log_message "Memory usage is normal: ${MEMORY_USAGE}%"
    fi
}

# Function to check disk usage
check_disk() {
    DISK_USAGE=$(df -P / | awk 'NR==2 {gsub("%","",$5); print $5}')

    echo "Disk Usage: ${DISK_USAGE}%"

    if [ "$DISK_USAGE" -gt "$DISK_THRESHOLD" ]; then
        log_message "ALERT: High disk usage: ${DISK_USAGE}%"
    else
        log_message "Disk usage is normal: ${DISK_USAGE}%"
    fi
}

# Function to check running processes
check_processes() {
    PROCESS_COUNT=$(ps -e --no-headers | wc -l)

    echo "Running Processes: ${PROCESS_COUNT}"

    if [ "$PROCESS_COUNT" -gt "$PROCESS_THRESHOLD" ]; then
        log_message "ALERT: High process count: ${PROCESS_COUNT}"
    else
        log_message "Process count is normal: ${PROCESS_COUNT}"
    fi
}

# Main execution
main() {
    log_message "========== SYSTEM HEALTH CHECK STARTED =========="

    check_cpu
    check_memory
    check_disk
    check_processes

    log_message "========== SYSTEM HEALTH CHECK COMPLETED =========="
}

main

