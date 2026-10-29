===================================================================

 CHEAT SHEET: COMANDOS BÁSICOS ANTE CAÍDA DE UN SERVIDOR LINUX

===================================================================



-------------------------------------------------------------------

 1. RECURSOS Y RENDIMIENTO DEL SISTEMA (CPU, MEMORIA, DISCO)

-------------------------------------------------------------------



top

# Muestra los procesos en tiempo real, uso de CPU y memoria RAM.



htop

# Visor interactivo y visual del rendimiento de CPU, memoria y procesos.



free -h

# Muestra el uso actual, disponible y libre de memoria RAM y SWAP.



df -h

# Muestra el espacio en disco usado y disponible en todos los puntos de montaje.



uptime

# Indica cuánto tiempo lleva encendido el equipo, usuarios y la carga promedio (load average).



-------------------------------------------------------------------

 2. ESTADO DE SERVICIOS Y PROCESOS

-------------------------------------------------------------------



systemctl list-units --failed

# Lista todos los servicios o unidades de systemd que han fallado.



systemctl status <nombre_servicio> -l --no-pager

# Muestra el estado actual (activo/inactivo) y últimos registros de un servicio específico.



journalctl -u <nombre_servicio> -e -n 50 --no-pager

# Muestra las últimas 50 líneas de registro (logs) de un servicio en particular.



ps aux --sort=-%cpu | head -n 10

# Lista los 10 procesos que más CPU están consumiendo en el sistema.



ps aux --sort=-%mem | head -n 10

# Lista los 10 procesos que más memoria RAM están consumiendo.



-------------------------------------------------------------------

 3. RED, PUERTOS Y CONECTIVIDAD

-------------------------------------------------------------------



ss -tulpn

# Muestra todos los puertos TCP/UDP abiertos y qué proceso/PID escucha en ellos.



netstat -tulpn

# Alternativa clásica para ver puertos en escucha y procesos asociados.



ip a

# Lista las interfaces de red del servidor y sus direcciones IP configuradas.



ping -c 4 8.8.8.8

# Prueba la conectividad básica hacia internet o un destino externo.



curl -Iv http://localhost

# Envía una petición HTTP local probando si la web/servicio responde adecuadamente.



-------------------------------------------------------------------

 4. REVISIÓN DE LOGS Y ERRORES DEL SISTEMA

-------------------------------------------------------------------



journalctl -xe -p err..emerg -n 50 --no-pager

# Muestra los últimos 50 eventos críticos o errores del kernel y sistema.



dmesg -T | tail -n 30

# Muestra los últimos 30 mensajes del kernel con fecha y hora (útil para fallos de hardware/disco/OOM Killer).



tail -f /var/log/syslog

# Monitorea en tiempo real el registro general del sistema (en Debian/Ubuntu).



tail -f /var/log/messages

# Monitorea en tiempo real el registro general del sistema (en RHEL/CentOS/Rocky).



-------------------------------------------------------------------

 5. DIAGNÓSTICO DE ARCHIVOS Y ESPACIO

-------------------------------------------------------------------



lsof -i :<puerto>

# Identifica con precisión qué proceso está utilizando un puerto específico.



du -sh /* 2>/dev/null | sort -h

# Calcula el peso de cada carpeta en la raíz para detectar dónde se llena el disco.



fuser -v /var/log

# Muestra los procesos que están manteniendo abiertos o bloqueando archivos en un directorio.