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


Esa línea **busca y elimina todos los archivos `.log` ubicados en el directorio actual que fueron modificados en los últimos 7 días**.

### Desglose comando por comando:

* **`find .`**: Inicia la búsqueda a partir del directorio actual (`.`).
* **`-maxdepth 1`**: Limita la búsqueda **únicamente al directorio actual**, sin ingresar en ninguna subcarpeta.
* **`-name "*.log"`**: Filtra los archivos cuyo nombre termine en la extensión `.log`.
* **`-type f`**: Se asegura de buscar **solo archivos regulares** (ignora directorios o enlaces simbólicos).
* **`-mtime -7`**: Filtra los archivos cuyo contenido fue modificado hace **menos de 7 días** (`-7` significa $N < 7$ días).
* **`-print`**: Muestra en la pantalla el nombre/ruta de cada archivo encontrado que cumple las condiciones.
* **`-delete`**: **Elimina directamente** los archivos encontrados.

### /etc/systemd/system/log-cleaner.service
# [Unit]
# Description=Daily Log Cleaner
# 
# [Service]
# Type=oneshot
# ExecStart=/bin/bash /opt/scripts/log-cleaner.sh
# WorkingDirectory=/root

Para borrar los archivos modificados hace **más de 7 días**, la única diferencia está en cambiar el signo del parámetro `-mtime`:

Usa **`+7`** en lugar de `-7`.

```bash
find . -maxdepth 1 -name "*.log" -type f -mtime +7 -print -delete

```

### La regla de los signos en `-mtime`:

* **`+7`**: Modificados hace **más** de 7 días ($> 7$ días, es decir, de 8 días atrás en adelante — los más viejos).
* **`-7`**: Modificados hace **menos** de 7 días ($< 7$ días, es decir, del día 0 al 6 — los más recientes).
* **`7`**: Modificados **exactamente** hace 7 días (entre 168 y 192 horas atrás).

---

> ⚠️ **Recomendación previa:** Antes de borrar, ejecutá el comando sin `-delete` para listar exactamente qué archivos se van a eliminar:
> ```bash
> find . -maxdepth 1 -name "*.log" -type f -mtime +7 -print
> 
> ```
> 
>

Comando final 

# Configuration
LOG_DIR="/var/log/app"
DAYS=7

echo "Starting Cleanup..."

find "$LOG_DIR" -maxdepth 1 -name "*.log" -type f -mtime +"$DAYS" -print -delete


El script de limpieza de logs quedó configurado para parametrizar la ruta mediante LOG_DIR y la antigüedad de retención con DAYS. La corrección principal sobre la versión original fue ajustar el flag de tiempo a +"$DAYS", asegurando que la herramienta find filtre y elimine únicamente los archivos .log con más de 7 días de antigüedad (los más viejos), protegiendo la información reciente y evitando borrados accidentales en la carpeta /var/log/app.

Al envolver las variables entre comillas dobles ("$LOG_DIR" y +"$DAYS"), el comando previene fallos de sintaxis en el intérprete de comandos ante posibles espacios en las rutas. Esta automatización permite mantener un control de almacenamiento predecible y libre de archivos obsoletos, optimizando el espacio en disco del servidor mediante una tarea limpia y segura para ejecutar de forma periódica.

