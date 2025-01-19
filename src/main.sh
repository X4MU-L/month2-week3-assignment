#!/bin/bash

# Get the directory where the script is located
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

# source environmental files
source /etc/profile.d/monitor-script.sh
# Source utility functions
source "$SCRIPT_DIR/utils/logger.sh"
source "$SCRIPT_DIR/utils/utils.sh"
source "$SCRIPT_DIR/utils/notify_team_service.sh"

# Check required commands
required_commands=("df" "free" "top" "curl" "logger" "systemd-cat" "awk" "sort" "head" "nproc" "lscpu")
for cmd in "${required_commands[@]}"; do
    # check if command exits
    check_command "$cmd"
done

# Update the monitor_system function to pass individual parameters
monitor_system() {
    local current_time=$(get_current_time)
    local disk_usage=$(get_disk_usage)
    local memory_usage=$(get_memory_usage)
    local cpu_usage=$(get_cpu_usage)
    local system_health=$(check_system_health)

    # Log information
    local message="System Status Report
    Time: $current_time
    Health: $system_health
    Disk Usage: $disk_usage
    Memory Usage: $memory_usage
    CPU Usage: $cpu_usage"

    # log to file and journald
    log_info "$message"

    # Send to Teams with individual parameters
    notify_teams "$current_time" "$system_health" "$cpu_usage" "$disk_usage" "$memory_usage"
}

# Run monitoring if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    monitor_system
fi