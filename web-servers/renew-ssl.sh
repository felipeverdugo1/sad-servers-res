Scenario: "Geneva": Renew an SSL Certificate

Level: Easy

Type: Fix

Tags: ssl  

Access: Email

Description: There's an Nginx web server running on this machine, configured to serve a simple "Hello, World!" page over HTTPS. However, the SSL certificate is expired.

Create a new SSL certificate for the Nginx web server with the same Issuer and Subject (same domain and company information).

Root (sudo) Access: True

Test: Certificate should not be expired: echo | openssl s_client -connect localhost:443 2>/dev/null | openssl x509 -noout -dates and the subject of the certificate should be the same as the original one: echo | openssl s_client -connect localhost:443 2>/dev/null | openssl x509 -noout -subject
'
Cuando generas un certificado con openssl o certbot, se crean dos archivos principales:

    Clave Privada (.key o privkey.pem): Es el secreto del servidor. Nunca debe salir de ahí.

    Certificado Público (.crt, .pem o fullchain.pem): Es lo que el servidor le entrega a los usuarios.

Por convención en Linux, estos archivos suelen guardarse en rutas del sistema como:

    /etc/ssl/certs/ y /etc/ssl/private/

    /etc/letsencrypt/live/[tu-dominio.com/](https://tu-dominio.com/)

En el archivo de configuración de Nginx (ej. /etc/nginx/sites-available/default), indicas las rutas con ssl_certificate y ssl_certificate_key:
Nginx

server {
    listen 443 ssl;
    server_name tu-dominio.com;

    # AQUÍ DICES EN QUÉ RUTA ESTÁ CADA ARCHIVO:
    ssl_certificate     /etc/ssl/certs/mi_sitio.crt;
    ssl_certificate_key /etc/ssl/private/mi_sitio.key;
}


Primero chequamos el servicio nginx

sudo systemctl status nginx.service

Probarariamos con curl:

curl localhost:443

Ver isser y subject viejo:
openssl x509 -in /ruta/al/certificado.crt -noout -subject -issuer

Hagamos un cat

cat /etc/nginx/sites-available/default

# to sites-enabled/ to enable it.
#
#server {
#       listen 80;
#       listen [::]:80;
#
#       server_name example.com;
#
#       root /var/www/example.com;
#       index index.html;
#
#       location / {
#               try_files $uri $uri/ =404;
#       }
#}
# BEGIN ANSIBLE MANAGED BLOCK
server {
    listen 443 ssl;
    server_name localhost;

    ssl_certificate /etc/nginx/ssl/nginx.crt;
    ssl_certificate_key /etc/nginx/ssl/nginx.key;

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers off;

    location / {
        root /var/www/html;
        index index.html index.htm;
    }
}
# END ANSIBLE MANAGED BLOCK



admin@ip-10-1-13-96:~$ openssl x509 -in /etc/nginx/ssl/nginx.crt -noout -subject -issuer
subject=CN = localhost, O = Acme, OU = IT Department, L = Geneva, ST = Geneva, C = CH
issuer=CN = localhost, O = Acme, OU = IT Department, L = Geneva, ST = Geneva, C = CH



openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/nginx/ssl/nginx.key \
  -out /etc/nginx/ssl/nginx.crt \
  -subj "/C=CH/ST=Geneva/L=Geneva/O=Acme/OU=IT Department/CN=localhost"


  Process: 746 ExecReload=/usr/sbin/nginx -g daemon on; master_process on; -s reload (code=exited, sta>
   Main PID: 644 (nginx)
    Tasks: 3 (limit: 520)
   Memory: 12.9M
      CPU: 72ms
   CGroup: /system.slice/nginx.service
           ├─644 nginx: master process /usr/sbin/nginx -g daemon on; master_process on;
           ├─645 nginx: worker process
           └─646 nginx: worker process

Sep 10 13:14:01 ip-10-1-13-96 systemd[1]: nginx.service: Failed to parse PID from file /run/nginx.pid: Invalid argument
Sep 10 13:14:01 ip-10-1-13-96 systemd[1]: Started A high performance web server and a reverse proxy server.
Sep 10 13:22:20 ip-10-1-13-96 systemd[1]: Reloading A high performance web server and a reverse proxy server.
Sep 10 13:22:20 ip-10-1-13-96 nginx[714]: nginx: [emerg] SSL_CTX_use_PrivateKey("/etc/nginx/ssl/nginx.key") failed (SSL: error:0B080074:x509 certific>
Sep 10 13:22:20 ip-10-1-13-96 systemd[1]: nginx.service: Control process exited, code=exited, status=1/FAILURE
Sep 10 13:22:20 ip-10-1-13-96 systemd[1]: Reload failed for A high performance web server and a reverse proxy server.
Sep 10 13:22:50 ip-10-1-13-96 systemd[1]: Reloading A high performance web server and a reverse proxy server.
Sep 10 13:22:50 ip-10-1-13-96 nginx[746]: nginx: [emerg] SSL_CTX_use_PrivateKey("/etc/nginx/ssl/nginx.key") failed (SSL: error:0B080074:x509 certific>
Sep 10 13:22:50 ip-10-1-13-96 systemd[1]: nginx.service: Control process exited, code=exited, status=1/FAILURE
Sep 10 13:22:50 ip-10-1-13-96 systemd[1]: Reload failed for A high performance web server and a reverse proxy server.


Paso que me falto actualizar la ruta de ssl key,


sudo systemctl reload nginx


Reporte: Tuvimos que renovar el certificado ssl mediante comandos, primero chequeamos el archivo de configuracion de nginx el cual nos muestra la ruta absoluta de donde se encuentran las 2 claves, luego como nos pidieron que no cambiemos el issuer y el subject usamos un comando que nos muestra ambos para combinar todo en en un comando, que sirve para renovarlo, esta no es la mejor manera pero es la forma manual de hacerlo


