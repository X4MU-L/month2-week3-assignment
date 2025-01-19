
# uninstall.sh
#!/bin/bash

# Get project name from argument or use default
PROJECT_NAME=${1:-"system-monitor"}
SERVICE_NAME="${PROJECT_NAME}.service"
TIMER_NAME="${PROJECT_NAME}.timer"
LOG_CONF_NAME="${PROJECT_NAME}-journal.conf"

# Stop and disable timer and service
sudo systemctl stop "$TIMER_NAME" 2>/dev/null || true
sudo systemctl disable "$TIMER_NAME" 2>/dev/null || true
sudo systemctl stop "$SERVICE_NAME" 2>/dev/null || true
sudo systemctl disable "$SERVICE_NAME" 2>/dev/null || true

# Remove service and timer files
sudo rm -f "/etc/systemd/system/$SERVICE_NAME"
sudo rm -f "/etc/systemd/system/$TIMER_NAME"

# Remove logrotate configuration
sudo rm -f "/etc/logrotate.d/$PROJECT_NAME"

# Remove journal configuration
sudo rm -f "/etc/systemd/journald.conf.d/$LOG_CONF_NAME"

# Remove program files
sudo rm -rf "/usr/local/bin/$PROJECT_NAME"
sudo rm -f "/usr/local/bin/$PROJECT_NAME"

# remove environmental variables
sudo rm -f /etc/profile.d/monitor-script.sh

# remove logs
sudo rm -rf "/var/log/${PROJECT_NAME}"

sudo systemctl daemon-reload

echo "Uninstallation of $PROJECT_NAME complete"