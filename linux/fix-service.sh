Scenario: "Valladolid": Cleaner not cleaning

Level: Easy

Type: Fix

Tags: systemd  

Access: Email

Description: The systemd service log-cleaner.service is supposed to be run manually (not a timer or cron job) and delete log files older than 7 days in the /var/log/app directory.

The service runs successfully (exit code 0), but no logs are ever deleted.

Fix the service and/or the script so that old_data.log (older than 7 days) is deleted, but recent_data.log is preserved.

If you accidentally delete the wrong files while debugging, run ~/reset_logs.sh to restore them.

Root (sudo) Access: True

Test: Running sudo systemctl restart log-cleaner deletes the file /var/log/app/old_data.log but not /var/log/app/recent_data.log

The "Check My Solution" button runs the script /home/admin/agent/check.sh, which you can see and execute.


Hay que analizar el script
[Unit]
Description=Daily Log Cleaner

[Service]
Type=oneshot
ExecStart=/bin/bash /opt/scripts/log-cleaner.sh
WorkingDirectory=/root


-rw-r--r-- 1 root root  132 Apr 14 17:55

cat /etc/systemd/system/log-cleaner.service

#!/bin/bash

# Configuration
LOG_DIR="/var/log/app"
DAYS=7

echo "Starting Cleanup..."

find . -maxdepth 1 -name "*.log" -type f -mtime -7 -print -delete

echo "Cleanup finished."


#!/bin/bash

# Configuration
LOG_DIR="/var/log/app"
DAYS=7

echo "Starting Cleanup..."

find ${LOG_DIR}  -maxdepth 1 -name "*.log" -type f -mtime +${DAYS} -print -delete

echo "Cleanup finished."


Si hacemos cambios

sudo systemctl daemon-reload
sudo systemctl restart 

Hay que ver si borra los scripts 

ls /var/log/app directory 

Lo borra pero si lo ejecuto de admin, no me deja, auque el enunciado dice que lo hace root, corri el test y me dio ok