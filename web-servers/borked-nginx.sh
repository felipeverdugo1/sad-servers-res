

Scenario: "Cape Town": Borked Nginx

Level: Medium

Type: Fix

Tags: nginx   systemd  

Access: Email

Description: There's an Nginx web server installed and managed by systemd. Running curl -I 127.0.0.1:80 returns curl: (7) Failed to connect to localhost port 80: Connection refused , fix it so when you curl you get the default Nginx page.

Root (sudo) Access: True

Test: curl -Is 127.0.0.1:80|head -1 returns HTTP/1.1 200 OK

Time to Solve: 15 minutes.
'''




sudo systemctl status nginx

    Verificación: Si el estado es inactive o failed, revívelo con sudo systemctl start nginx. Si falla al iniciar, ejecuta sudo nginx -t para revisar errores de sintaxis en la configuración.


sudo tail -f /var/log/nginx/error.log

#directory index of "/var/www/html/" is forbidden
#permission denied (13: Permission denied)
#connect() failed (111: Connection refused) while connecting to upstream


ps aux | grep nginx

#Si esta mal el user
# Ajustar propietario
sudo chown -R www-data:www-data /usr/share/nginx/html  # o /var/www/html

# Aplicar permisos lectura/ejecución
sudo find /var/www/html -type d -exec chmod 755 {} \;
sudo find /var/www/html -type f -exec chmod 644 {} \;



cat /etc/nginx/sites-enabled/default o /etc/nginx/conf.d/default.conf):


sudo nginx -t

-------------------------------------------------------------

curl -Is 127.0.0.1:80|head -1



admin@ip-10-1-13-176:/$ sudo systemctl status nginx
● nginx.service - The NGINX HTTP and reverse proxy server
     Loaded: loaded (/etc/systemd/system/nginx.service; enabled; vendor preset: enabled)
     Active: failed (Result: exit-code) since Wed 2026-09-23 17:09:15 UTC; 1min 15s ago
    Process: 569 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=1/FAILURE)
        CPU: 28ms

Sep 23 17:09:15 ip-10-1-13-176 systemd[1]: Starting The NGINX HTTP and reverse proxy server...
Sep 23 17:09:15 ip-10-1-13-176 nginx[569]: nginx: [emerg] unexpected ";" in /etc/nginx/sites-enabled/def>
Sep 23 17:09:15 ip-10-1-13-176 nginx[569]: nginx: configuration file /etc/nginx/nginx.conf test failed
Sep 23 17:09:15 ip-10-1-13-176 systemd[1]: nginx.service: Control process exited, code=exited, status=1/>
Sep 23 17:09:15 ip-10-1-13-176 systemd[1]: nginx.service: Failed with result 'exit-code'.
Sep 23 17:09:15 ip-10-1-13-176 systemd[1]: Failed to start The NGINX HTTP and reverse proxy server.



2026/09/23 17:15:21 [alert] 863#863: socketpair() failed while spawning "worker process" (24: Too many open files)
2026/09/23 17:15:21 [emerg] 864#864: eventfd() failed (24: Too many open files)
2026/09/23 17:15:21 [alert] 864#864: socketpair() failed (24: Too many open files)
2026/09/23 17:15:34 [crit] 864#864: *1 open() "/var/www/html/index.nginx-debian.html" failed (24: Too many open files), client: 127.0.0.1, server: _, request: "HEAD / HTTP/1.1", host: "127.0.0.1"


admin@ip-10-1-13-182:/$ ps aux | grep nginx
admin        834  0.0  0.1   5204   656 pts/0    S<+  17:36   0:00 grep nginx

Configuración Nginx: Error de Sintaxis (Último log)

Síntoma: Nginx no arranca o no recarga la configuración (nginx: [emerg] unexpected ";" in /etc/nginx/sites-enabled/default...).

Causa: Hay un punto y coma ; mal puesto, duplicado o fuera de lugar dentro del archivo de configuración del sitio (/etc/nginx/sites-enabled/default).

 Solución inmediata:

        Ejecuta sudo nginx -t para ver la línea exacta del error.

        Corrige el archivo con sudo nano /etc/nginx/sites-enabled/default.

        Aplica los cambios con sudo systemctl reload nginx.


Sistema Operativo: Límite de archivos abiertos (Error 500 / Too many open files)

    Síntoma: Nginx fallaba con open() failed (24: Too many open files).

    Causa: El límite predeterminado del sistema (ulimit -n 1024) era insuficiente para la cantidad de archivos/sockets que Nginx intentaba manejar.

    Solución: Aumentar el límite a 65535 en /etc/nginx/nginx.conf (worker_rlimit_nofile 65535) y en el servicio de systemd (LimitNOFILE=65535).

