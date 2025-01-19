# Get current time
get_current_time() {
    date "+%Y-%m-%d %H:%M:%S"
}
# Ensure required commands are available
check_command() {
    local cmd=$1
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "Command $cmd not found. Attempting to install..."
        if command -v apk >/dev/null 2>&1; then
            apk add --no-cache "$cmd"
        elif command -v apt >/dev/null 2>&1; then
            apt update && apt install -y "$cmd"
        else
            echo "Neither apk nor apt package manager found. Please install $cmd manually."
            exit 1
        fi
    fi
    return 0
}

# Get physical and logical CPU core count
get_cpu_cores() {
    local physical_cores
    local logical_cores
    
    # Get physical cores (excluding Hyper-Threading)
    physical_cores=$(lscpu | grep "^Core(s) per socket:" | awk '{print $4}')
    
    # Get total logical cores
    logical_cores=$(nproc)
    
    echo "${physical_cores},${logical_cores}"
}


# Get disk usage
get_cpu_usage() {
    local cores_info=$(get_cpu_cores)
    # Get the first value before the comma
    # emaple of cores_info return value: 4,8
    local physical_cores=${cores_info%,*}
    local load_1min
    local load_5min
    local load_15min
    local max_load
    local usage_percentage

    # Get load averages
    read load_1min load_5min load_15min other < /proc/loadavg
    # Find the highest load average
    max_load=$(printf "%s\n" "$load_1min" "$load_5min" "$load_15min" | sort -nr | head -n1)
    
    # Calculate percentage based on physical cores
    usage_percentage=$(awk -v max_load="$max_load" -v cores="$physical_cores" \
        'BEGIN {printf "%.1f", (max_load/cores) * 100}')
    # Return both raw values and percentage
    printf "%s%% (Load: %s, %s, %s)\n" \
           "$usage_percentage" "$load_1min" "$load_5min" "$load_15min"
}

# Get disk usage with better formatting
get_disk_usage() {
    local filesystem
    local used
    local available
    local use_percent
    local mountpoint
    
    # Get disk statistics
    eval $(df -h / | awk 'NR==2 {printf "filesystem=%s;used=%s;available=%s;use_percent=%d;mountpoint=%s", \
        $1, $3, $4, substr($5, 1, length($5)-1), $6}')

    printf "Filesystem: %s, Used: %s, Free: %s, Mount: %s (%d%%)\n" \
           "$filesystem" "$used" "$available" "$mountpoint" "$use_percent"
}


# Get memory usage with detailed information
get_memory_usage() {
    local total
    local used
    local free
    local percentage
    
    # Get memory statistics in megabytes
    eval $(free -m | awk 'NR==2 {printf "total=%d;used=%d;free=%d", $2, $3, $4}')
    
    # Calculate percentage
    percentage=$(awk -v used="$used" -v total="$total" 'BEGIN {printf "%.1f", (used/total) * 100}')
    
    #echo "Total: $total MB, Used: $used MB, Free: $free MB ($percentage%)"
    printf "Total: %sMB, Used: %sMB, Free: %sMB (%s%%)\n" \
           "$total" "$used" "$free" "$percentage"
}


# Comprehensive system health check
check_system_health() {
    # Get CPU information
    # exmaple of creturn format :  0.0% (Load 0.0 0.0 0.0)
    local cpu_info=$(get_cpu_usage)
    # use the awk command to get the percentage value - feild %
    local cpu_percentage=$(echo "$cpu_info" | awk -F'[%]' '{print $1}' | xargs)

    # Get memory information
    # example of mem_info return value: Total: 15934MB, Used: 1234MB, Free: 14699MB (7.7%)
    local mem_info=$(get_memory_usage)
    # use the awk command to get the percentage value - feild (%
    local mem_percentage=$(echo "$mem_info" | awk -F'[(%]' '{print $(NF-1)}')
    
    # Get disk information
    # example of disk_info return value: Filesystem: /dev/sda1, Used: 8.8G, Free: 1.2G, Mount: / (88%)
    local disk_info=$(get_disk_usage)
    # use the awk command to get the percentage value - feild (%)
    local disk_percentage=$(echo "$disk_info" | awk -F'[(%]' '{print $(NF-1)}')
    
    # Evaluate system health with weighted factors
    # if cpu_percentage is greater than 85 or mem_percentage is greater than 90
    # or disk_percentage is greater than 90
    if [ "${cpu_percentage%.*}" -gt 85 ] || \
       [ "${mem_percentage%.*}" -gt 90 ] || \
       [ "${disk_percentage%.*}" -gt 90 ]; then
        echo "overload"
    # else if cpu_percentage is greater than 70 or mem_percentage is greater than 80
    elif [ "${cpu_percentage%.*}" -gt 70 ] || \
         [ "${mem_percentage%.*}" -gt 80 ] || \
         [ "${disk_percentage%.*}" -gt 80 ]; then
        echo "not-ok"
    else
        echo "healthy"
    fi
}

# Run monitoring if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "Script $(basename $0) cannot be executed directly"
    exit 1
fi