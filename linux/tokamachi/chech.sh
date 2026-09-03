#!/bin/bash
LOG="/home/felipe/sad-servers/linux/tokamachi/reader.log"

if [ ! -f "$LOG" ]; then
    echo "Fallo: No existe reader.log"
    exit 1
fi

COUNT1=$(wc -l < "$LOG")
sleep 2
COUNT2=$(wc -l < "$LOG")

if [ "$COUNT2" -gt "$COUNT1" ]; then
    echo "¡Éxito! El lector sigue recibiendo mensajes de forma fluida."
else
    echo "Fallo: El lector se detuvo o no está recibiendo mensajes a tiempo."
fi

#Res
#/bin/bash -c 'while true; do echo "this is a test message being sent to the pipe" > /home/felipe/sad-servers/linux/tokamachi/namedpipe; sleep 0.5; done' &