#!/bin/bash
PIPE_PATH="/home/felipe/sad-servers/linux/tokamachi/namedpipe"
LOG_PATH="/home/felipe/sad-servers/linux/tokamachi/reader.log"

echo "Proceso lector iniciado..."
while read -r line; do
    echo "$(date '+%H:%M:%S') - Recibido: $line" >> "$LOG_PATH"
    sleep 0.2
done < "$PIPE_PATH"
