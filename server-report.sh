#!/bin/bash
# --------------------------------------------------
# COMO EJECUTAR ESTE SCRIPT:
# 1. Guardar como: nano reporte.sh
# 2. Dar permisos: chmod +x reporte.sh
# 3. Ejecutar:     ./reporte.sh
# 4. Ver reporte:  less server_report.txt
# --------------------------------------------------

LOGFILE="server_report.txt"

{
    echo "=========================================="
    echo " CHEQUEO DE RECURSOS (CPU, RAM, DISCO)"
    echo "=========================================="

    echo -e "\n--- Uptime y Carga del Sistema ---"
    uptime

    echo -e "\n--- Uso de Memoria RAM ---"
    free -h

    echo -e "\n--- Espacio en Disco ---"
    df -h

    echo -e "\n--- Procesos con mayor uso de CPU ---"
    ps aux --sort=-%cpu | head -n 10

    echo -e "\n--- Procesos con mayor uso de Memoria ---"
    ps aux --sort=-%mem | head -n 10

    echo "=========================================="
    echo " ESTADO DE SERVICIOS Y PROCESOS"
    echo "=========================================="

    echo -e "\n--- Servicios de Systemd Fallidos ---"
    systemctl list-units --failed --no-pager

    echo "=========================================="
    echo " RED, PUERTOS Y CONECTIVIDAD"
    echo "=========================================="

    echo -e "\n--- Puertos Abiertos y Procesos Escuchando ---"
    ss -tulpn

    echo -e "\n--- Interfaces de Red y IPs ---"
    ip a

    echo -e "\n--- Prueba de Conectividad Externa ---"
    ping -c 4 8.8.8.8

    echo -e "\n--- Prueba de Conexión HTTP Local ---"
    curl -Iv http://localhost 2>&1

    echo "=========================================="
    echo " LOGS DEL SISTEMA Y ERRORES RECENTES"
    echo "=========================================="

    echo -e "\n--- Logs Recientes de Errores Críticos (Journalctl) ---"
    journalctl -xe -p err..emerg -n 50 --no-pager

    echo -e "\n--- Mensajes del Kernel Recientes (dmesg) ---"
    dmesg -T | tail -n 30

    echo -e "\n--- Últimas líneas de /var/log/syslog ---"
    tail -n 30 /var/log/syslog 2>/dev/null || tail -n 30 /var/log/messages 2>/dev/null

    echo "=========================================="
    echo " ARCHIVOS Y ALMACENAMIENTO"
    echo "=========================================="

    echo -e "\n--- Directorios de Mayor Tamaño en Root ---"
    du -sh /* 2>/dev/null | sort -h | tail -n 10

} > "$LOGFILE" 2>&1

echo "Reporte generado exitosamente en: $LOGFILE"