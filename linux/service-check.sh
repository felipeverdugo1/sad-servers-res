#!/bin/bash
# Description: Automated health check requiring ONLY the service name
# Usage: ./service-check.sh <service_name>
# With erros
#./service-check.sh mysql > file.txt 2>&1
# Append to file.txt and display on screen simultaneously:
#./service-check.sh nginx 2>&1 | tee -a file.txt
# Example: ./service-check.sh nginx

chmod +x service-check.sh

SERVICE_NAME="${1:?Error: Please provide a service name (e.g. ./health_check.sh nginx)}"

echo "=========================================="
echo " Starting Health Check for: ${SERVICE_NAME}"
echo " Date: $(date)"
echo "=========================================="

# --------------------------------------------------
# 1. Check Service & Systemd Status
# --------------------------------------------------
echo -e "\n[1/4] Checking Systemd Service Status..."
if systemctl is-active --quiet "${SERVICE_NAME}"; then
    echo "✔ Service '${SERVICE_NAME}' is ACTIVE"
else
    echo "✖ Service '${SERVICE_NAME}' is NOT active!"
    systemctl status "${SERVICE_NAME}" --no-pager -l
fi

# --------------------------------------------------
# 2. Auto-Detect Active Port & Check Listener State
# --------------------------------------------------
echo -e "\n[2/4] Auto-Detecting Listening Ports..."

# Get main PID
PID=$(pgrep -f "${SERVICE_NAME}" | head -n 1)

if [ -n "${PID}" ]; then
    # Extract listening port numbers associated with the detected PID
    DETECTED_PORTS=$(ss -tulpn | grep "pid=${PID}," | awk '{print $5}' | awk -F':' '{print $NF}' | sort -u | tr '\n' ' ')
    
    if [ -n "${DETECTED_PORTS}" ]; then
        echo "✔ Service '${SERVICE_NAME}' (PID ${PID}) is listening on port(s): ${DETECTED_PORTS}"
    else
        echo "⚠ Service is running (PID ${PID}), but no active listening ports were found."
    fi
else
    echo "✖ Could not auto-detect port: Service process is not running."
fi

# --------------------------------------------------
# 3. Check Resource Usage (CPU, Memory, PID)
# --------------------------------------------------
echo -e "\n[3/4] Checking Resource Usage..."
if [ -n "${PID}" ]; then
    echo "✔ Main PID: ${PID}"
    ps aux | awk -v pid="${PID}" '$2 == pid {print "   CPU Usage: " $3 "% | Memory Usage: " $4 "%"}'
else
    echo "✖ Skipping resource check: Process PID not found."
fi

# --------------------------------------------------
# 4. Check Recent System Logs for Errors
# --------------------------------------------------
echo -e "\n[4/4] Fetching Recent Logs (Last 5 Error Entries)..."
journalctl -u "${SERVICE_NAME}" -p err..emerg -n 5 --no-pager

echo -e "\n=========================================="
echo " Health Check Complete"
echo "=========================================="
