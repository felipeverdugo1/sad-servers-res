Scenario: "Tokyo": can't serve web file

Level: Medium

Type: Fix

Tags: apache  

Access: Email

Description: There's a web server serving a file /var/www/html/index.html with content "hello sadserver" but when we try to check it locally with an HTTP client like curl 127.0.0.1:80, nothing is returned. This scenario is not about the particular web server configuration and you only need to have general knowledge about how web servers work.

Root (sudo) Access: True

Test: curl 127.0.0.1:80 should return: hello sadserver

Time to Solve: 15 minutes.

Apache es un servidor de contenido web: escucha peticiones en los puertos HTTP (80) y HTTPS (443) y entrega páginas web, imágenes o actúa como intermediario para ejecutar código en lenguajes como PHP, Python o Node.js.

Ya que el problema requiere saber sobre web servers, arme un todo de lo que tendriamos que chequear

Paso 1: Comprobar el estado del servicio y puertos

Lo primero es verificar si el programa está corriendo y escuchando en la red.
Bash

# 1. Verificar si el servicio está activo
sudo systemctl status apache2   # (o nginx, httpd, etc.)

# 2. Verificar si está escuchando en los puertos 80/443
sudo ss -tulpn | grep -E ':80|:443'

    Si no está corriendo: El problema está en la configuración de arranque o en la falta de recursos (memoria/puerto ocupado por otro proceso).

Paso 2: Consultar los archivos de Log (La herramienta principal)

Los web servers guardan dos tipos de logs esenciales:

    Error Log (error.log): Muestra fallas de sintaxis, falta de permisos, errores de código backend, fallas al conectar a bases de datos o módulos caídos.

    Access Log (access.log): Registra cada petición entrante con el IP de origen, la ruta consultada y el código HTTP retornado.

Bash

# Ver los últimos errores en tiempo real
sudo tail -f /var/log/apache2/error.log
# (En Nginx suele ser /var/log/nginx/error.log)

# Ver el registro de accesos y códigos de respuesta
sudo tail -f /var/log/apache2/access.log

Paso 3: Validar la sintaxis de configuración

Un error muy común es modificar un archivo de configuración (un VirtualHost, una redirección) y reiniciar el servicio sin probar si la sintaxis es válida.
Bash

# Para Apache:
sudo apachectl configtest

# Para Nginx:
sudo nginx -t

Si hay un error en los archivos .conf, la herramienta indicará exactamente la línea y el archivo fallido.
Paso 4: Probar la conectividad local vs. externa

Aislamos si la falla es interna del servidor o de red/firewall.
Bash

# Hacer una petición HTTP desde la propia máquina
curl -I http://localhost

# Si responde localmente pero no desde afuera:
# Probar el estado del Firewall de Linux
sudo ufw status
# O revisar reglas de IPTables / Security Groups de la nube (AWS, GCP).

Paso 5: Interpretar el código de estado HTTP

El código que devuelve el servidor orienta de inmediato la investigación:
Código HTTP	Significado	Dónde buscar el problema
403 Forbidden	Permisos denegados	Permisos de carpetas (chmod/chown) o directivas Allow/Deny.
404 Not Found	Ruta o archivo inexistente	Reglas de reescritura (.htaccess, try_files) o ruta mal configurada.
500 Internal Error	Error interno	Revisa el error.log o logs del backend (PHP, Python, Node).
502 / 504 Gateway	Proxy / Timeout	El web server no puede comunicarse con el backend o la BD tardó demasiado.

----------------

● apache2.service - The Apache HTTP Server
     Loaded: loaded (/usr/lib/systemd/system/apache2.service; enabled; preset: enabled)
     Active: active (running) since Wed 2026-09-23 15:15:50 UTC; 15s ago
 Invocation: b366016e9bee4d0784cafdc919e954b3
       Docs: https://httpd.apache.org/docs/2.4/
    Process: 762 ExecStart=/usr/sbin/apachectl start (code=exited, status=0/SUCCESS)
   Main PID: 847 (apache2)
      Tasks: 55 (limit: 501)
     Memory: 7.8M (peak: 8M)
        CPU: 55ms
     CGroup: /system.slice/apache2.service
             ├─847 /usr/sbin/apache2 -k start
             ├─851 /usr/sbin/apache2 -k start
             └─852 /usr/sbin/apache2 -k start

Sep 23 15:15:50 i-0fc157fbad9745c3e systemd[1]: Starting apache2.service - The Apache HTTP Server...
Sep 23 15:15:50 i-0fc157fbad9745c3e apachectl[811]: AH00558: apache2: Could not reliably determine the s>
Sep 23 15:15:50 i-0fc157fbad9745c3e systemd[1]: Started apache2.service - The Apache HTTP Server.

admin@i-0fc157fbad9745c3e:~$ sudo ss -tulpn | grep -E ':80|:443'
tcp   LISTEN 0      511                  *:80              *:*    users:(("apache2",pid=852,fd=4),("apache2",pid=851,fd=4),("apache2",pid=847,fd=4))
tcp   LISTEN 0      4096                 *:8080            *:*    users:(("gotty",pid=760,fd=6))                                                    

admin@i-0fc157fbad9745c3e:~$ sudo tail -f /var/log/apache2/error.log
[Fri Sep 04 15:07:14.560683 2026] [mpm_event:notice] [pid 1601:tid 1601] AH00489: Apache/2.4.68 (Debian) configured -- resuming normal operations
[Fri Sep 04 15:07:14.560795 2026] [core:notice] [pid 1601:tid 1601] AH00094: Command line: '/usr/sbin/apache2'
[Fri Sep 04 15:08:07.408538 2026] [mpm_event:notice] [pid 1601:tid 1601] AH00492: caught SIGWINCH, shutting down gracefully
[Wed Sep 23 15:15:50.892581 2026] [mpm_event:notice] [pid 847:tid 847] AH00489: Apache/2.4.68 (Debian) configured -- resuming normal operations
[Wed Sep 23 15:15:50.937201 2026] [core:notice] [pid 847:tid 847] AH00094: Command line: '/usr/sbin/apache2'


* connect to 127.0.0.1 port 80 from 127.0.0.1 port 55398 failed: Connection timed out
* Failed to connect to 127.0.0.1 port 80 after 135096 ms: Could not connect to server
* closing connection #0
curl: (28) Failed to connect to 127.0.0.1 port 80 after 135096 ms: Could not connect to server

sudo iptables -L INPUT -v -n

Chain INPUT (policy ACCEPT 686 packets, 49616 bytes)
 pkts bytes target     prot opt in     out     source               destination         
   57  3420 DROP       tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            tcp dpt:80



 admin@i-0fc157fbad9745c3e:~$ curl -I http://127.0.0.1:80
 HTTP/1.1 403 Forbidden
 Date: Wed, 23 Sep 2026 15:32:11 GMT
 Server: Apache/2.4.68 (Debian)
 Content-Type: text/html; charset=iso-8859-1

 [Wed Sep 23 15:44:55.835209 2026] [core:error] [pid 868:tid 879] (13)Permission denied: [client 127.0.0.1:42790] AH00132: file permissions deny server access: /var/www/html/index.html

[Wed Sep 23 15:44:55.835209 2026] [core:error] [pid 868:tid 879] (13)Permission denied: [client 127.0.0.1:42790] AH00132: file permissions deny server access: /var/www/html/index.html

admin@i-0fc157fbad9745c3e:/var/www/html$ ls -la
total 12
drwxr-xr-x 2 root root 4096 Sep  4 15:07 .
drwxr-xr-x 3 root root 4096 Sep  4 15:07 ..
-rw------- 1 root root   15 Sep  4 15:07 index.html

admin@i-0fc157fbad9745c3e:/var/www/html$ ls -ld /var/www/html
drwxr-xr-x 2 root root 4096 Sep  4 15:07 /var/www/html


Primero de manera recursiva hacemos dueño de los archivos al usuario no privilegiado, luego para que quede consistente lo que hacemos es ponerle los permisos por defecto que tendria que tener un archivo html

sudo chown -R www-data:www-data /var/www/html

sudo chmod 644 /var/www/html/index.html

Reporte:

Nos dieron un server donde cuando haciamos un curl se quedaba colgado, pero los servicios de apache estaban running y escuchando el puerto 80, lo cual procedimos a revisar el firewall, encontramos que tenia tanto de entrada del def gat como de salida dropeaba todos los paquetes, procedimos a cambias esta regla aunque sea para lo(localhost)  y ponerle accept, guardamos las caracteristicas para cuando el server se reinciie siga estando esto. Luego realizamos el curl pero nos dio el error 403, revisando los logs, era (13)Permission denied con lo cual procedimos a chequear el directiorio donde se aloca los archivos estaticos, y si pertenecian a root y el index.html tenia los permisos limitados lo cual procedimos a fixearlo