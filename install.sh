#!/bin/bash

# Get project name from argument or use default
PROJECT_NAME=${1:-"system-monitor"}
# installation directory
INSTALL_DIR="/usr/local/lib/${PROJECT_NAME}"
# the name of the service
SERVICE_NAME="${PROJECT_NAME}.service"
# the name of the timer
TIMER_NAME="${PROJECT_NAME}.timer"
# log configurations
LOG_CONF_NAME="${PROJECT_NAME}-journal.conf"
LOG_DIR="/var/log/${PROJECT_NAME}"
LOG_FILE="$LOG_DIR/${PROJECT_NAME}.log"
ERROR_LOG_FILE="$LOG_DIR/${PROJECT_NAME}.error.log"




# Create installation directory
sudo mkdir -p "$INSTALL_DIR"

# Copy all source files
sudo cp -r src/* "$INSTALL_DIR/"

# Ensure no directory exists where the wrapper script should be
if [ -d "/usr/local/bin/$PROJECT_NAME" ]; then
  echo "Error: A directory named '$PROJECT_NAME' exists in /usr/local/bin. Please remove it."
  exit 1
fi

# Create wrapper script
sudo tee "/usr/local/bin/$PROJECT_NAME" > /dev/null  << EOF
#!/bin/bash
$INSTALL_DIR/main.sh "\$@"
EOF

# Make main script executable
sudo chmod +x "$INSTALL_DIR/main.sh"
# Make wrapper script executable
sudo chmod +x "/usr/local/bin/$PROJECT_NAME"

# Create and install systemd service
sudo tee "/etc/systemd/system/$SERVICE_NAME" > /dev/null  << EOF
[Unit]
Description=$PROJECT_NAME Service
After=network.target

[Service]
ExecStart=/usr/local/bin/$PROJECT_NAME
Restart=no
User=root

# Configure logging
StandardOutput=append:$LOG_FILE
StandardError=append:$ERROR_LOG_FILE

# Create log directory if it doesn't exist
ExecStartPre=/bin/mkdir -p $LOG_DIR

[Install]
WantedBy=multi-user.target
EOF

# Create and install systemd timer
sudo tee "/etc/systemd/system/$TIMER_NAME" > /dev/null  << EOF
[Unit]
Description=$PROJECT_NAME Timer that runs every 1 minute

[Timer]
# run the program every minute
OnBootSec=1min
OnUnitActiveSec=1min
# service name
Unit=$PROJECT_NAME.service

[Install]
WantedBy=timers.target
EOF

# Create logrotate configuration
sudo mkdir -p /etc/logrotate.d
sudo tee "/etc/logrotate.d/$PROJECT_NAME" > /dev/null  << EOF
/var/log/${PROJECT_NAME}/*.log {
    daily
    rotate 7
    compress
    delaycompress
    missingok
    notifempty
    create 0640 root root
    postrotate
        /usr/bin/systemctl kill -s HUP $SERVICE_NAME
    endscript
}
EOF

# Create journal configuration for this service
sudo mkdir -p /etc/systemd/journald.conf.d
sudo tee "/etc/systemd/journald.conf.d/$LOG_CONF_NAME" > /dev/null  << EOF
[Journal]
# Maximum size for this service's journal
SystemMaxUse=100M
# Maximum age for this service's journal entries
MaxRetentionSec=1week
# Compress journals older than 2 days
Compress=yes
EOF


# Create log directory
sudo mkdir -p "$LOG_DIR"

# Set proper permissions
sudo chmod 755 "$LOG_DIR"

# In install.sh, add this environment setup
sudo tee "/etc/profile.d/monitor-script.sh" > /dev/null  << EOF
export MONITOR_SCRIPT_LOG_FILE="$LOG_FILE"
export MONITOR_SCRIPT_ERROR_LOG="$ERROR_LOG_FILE"
EOF

# Reload systemd to recognize new service and timer
sudo systemctl daemon-reload

# Start and enable the timer (not the service directly)
sudo systemctl enable "$TIMER_NAME"
sudo systemctl start "$TIMER_NAME"

echo "Installation complete!"
echo "The service will run every 1 min using timer"
echo "Timer status: sudo systemctl status $TIMER_NAME"
echo "Next run time: sudo systemctl list-timers"
echo "View logs: sudo journalctl -u $SERVICE_NAME"
echo "Log files are in: $LOG_DIR"
