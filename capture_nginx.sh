#!/bin/bash

# Check if nginx is installed and install
if ! command -v "nginx" >/dev/null 2>&1; then
    echo "Command nginx not found. Attempting to install..."
    if command -v apt >/dev/null 2>&1; then
        sudo apt update && sudo apt install -y nginx
    else
        echo "Neither apk nor apt package manager found. Please install nginx manually."
        exit 1
    fi
fi

sudo tee "/var/www/html/index.html" > /dev/null  << 'EOF'
    <html>
        <head><title>Welcome</title></head>
        <body><h1>My Custom Nginx Server</h1></body>
    </html>
EOF

# check if configuration is okay
sudo nginx -t 2>/dev/null

# check if exit code is 0
if [ $? -ne 0 ]; then
    echo "Nginx configuration test failed. Exiting..."
    exit 1
fi
# restart nginx
sudo systemctl restart nginx
