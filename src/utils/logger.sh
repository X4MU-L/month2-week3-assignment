# Configuration file for logging
LOG_DIR=${WEEK2_LOG_DIR_ENV:-"/var/log/system-monitor"}
LOG_FILE="${LOG_DIR}/system-status.log"

# Log to file and journald
log_info() {
    local message=$1
    echo "$MONITOR_SCRIPT_LOG_FILE file"
    echo -e  "\t$(get_current_time) - $message" >> "${MONITOR_SCRIPT_LOG_FILE:-LOG_FILE}"
    echo "$message" | systemd-cat -p info -t system-monitor
}