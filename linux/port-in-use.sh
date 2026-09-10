#!/bin/bash

Scenario: "Bergen": Port already in use

Level: Easy

Type: Fix

Tags: systemd   nginx  

Access: Email

Description: There's an application at /home/admin/standalone that needs to run successfully but currently it fails.

Fix the environment so the binary can run without errors, without changing the binary itself, and without breaking the web app served on port :80.

Root (sudo) Access: True

Test: Running /home/admin/standalone prints OK and curl http://localhost:80 returns hello SadServers.


The "Check My Solution" button runs the script /home/admin/agent/check.sh, which you can see and execute.

Time to Solve: 20 minutes.
'

Miraria a ver si hay alguna info en standalone

Seguramnte este corriendo o intentando correr el puerto 80 http

ss -tulpn

curl -v http://127.0.0.1:9178/

admin@i-07691e4a45b3cd971:~/django_app/hellosad$ cat settings.py 
SECRET_KEY = "bergen-sadservers-dev-only-not-secret"
DEBUG = True
ALLOWED_HOSTS = ["*"]

INSTALLED_APPS = [
    "django.contrib.contenttypes",
    "django.contrib.staticfiles",
]

MIDDLEWARE = [
    "django.middleware.common.CommonMiddleware",
]

ROOT_URLCONF = "hellosad.urls"

TEMPLATES = []

WSGI_APPLICATION = "hellosad.wsgi.application"

DATABASES = {
    "default": {
        "ENGINE": "django.db.backends.sqlite3",
        "NAME": "/home/admin/django_app/db.sqlite3",
    }
}

USE_TZ = True
STATIC_URL = "static/"


tcp   LISTEN 0      4096       127.0.0.53%lo:53          0.0.0.0:*                                       
tcp   LISTEN 0      511              0.0.0.0:80          0.0.0.0:*                                       
tcp   LISTEN 0      10               0.0.0.0:8000        0.0.0.0:*     users:(("python3",pid=922,fd=4))  
tcp   LISTEN 0      4096                   *:8080              *:*     users:(("gotty",pid=748,fd=6)) 


curl :80 -> 200 html ngnix

admin@i-07691e4a45b3cd971:~$ curl -v http://127.0.0.1:9178/
*   Trying 127.0.0.1:9178...
* Connected to 127.0.0.1 (127.0.0.1) port 9178
* using HTTP/1.x
> GET / HTTP/1.1
> Host: 127.0.0.1:9178
> User-Agent: curl/8.14.1
> Accept: */*
> 
* Request completely sent off
< HTTP/1.1 200 OK
< Date: Thu, 10 Sep 2026 11:32:15 GMT
< Server: WSGIServer/0.2 CPython/3.13.5
< Content-Type: text/html; charset=utf-8
< Content-Length: 16
< 
* Connection #0 to host 127.0.0.1 left intact



-------------------------------

curl :8080 -> 200 html server goty el que hostea la vm

<!doctype html>
<html>

<head>
  <title>bash@i-07691e4a45b3cd971</title>
  <link rel="manifest" href="manifest.json" crossorigin="use-credentials">
  <link rel="icon" href="favicon.ico">
  <link rel="icon" href="icon.svg" type="image/svg+xml">
  <link rel="stylesheet" href="./css/index.css" />
  <link rel="stylesheet" href="./css/xterm.css" />
  <link rel="stylesheet" href="./css/xterm_customize.css" />
  <meta name="viewport" content="width=device-width, initial-scale=1">
</head>

<body>
  <div id="terminal"></div>
  <script src="./auth_token.js"></script>
  <script src="./config.js"></script>
  <script src="./js/gotty.js"></script>
</body>


admin@i-07691e4a45b3cd971:~$ systemctl status django.service 
● django.service - Django Hello SadServers (dev runserver)
     Loaded: loaded (/etc/systemd/system/django.service; enabled; preset: enabled)
     Active: active (running) since Mon 2026-09-07 18:46:23 UTC; 5min ago
 Invocation: 39dc6680a678446c97e7b13678b00ed0
   Main PID: 750 (python3)
      Tasks: 3 (limit: 501)
     Memory: 67.4M (peak: 67.6M)
        CPU: 1.813s
     CGroup: /system.slice/django.service
             ├─750 /usr/bin/python3 manage.py runserver 0.0.0.0:8000
             └─919 /usr/bin/python3 manage.py runserver 0.0.0.0:8000

[Service]
ExecStart=
ExecStart=/usr/bin/python3 /home/admin/django_app/manage.py runserver 0.0.0.0:9178

En el override del service ya que estaba corriendo en el mismo que el standalone

sudo systemctl daemon-reload
sudo systemctl restart django.service

● django.service - Django Hello SadServers (dev runserver)
     Loaded: loaded (/etc/systemd/system/django.service; enabled; preset: enabled)
    Drop-In: /etc/systemd/system/django.service.d
             └─override.conf
     Active: active (running) since Thu 2026-09-10 11:30:49 UTC; 26s ago
 Invocation: 8a34dcc9faff48c88b5f5eec7b606189
   Main PID: 1366 (python3)
      Tasks: 3 (limit: 501)
     Memory: 57.8M (peak: 58M)
        CPU: 738ms
     CGroup: /system.slice/django.service
             ├─1366 /usr/bin/python3 manage.py runserver 0.0.0.0:9178
             └─1367 /usr/bin/python3 manage.py runserver 0.0.0.0:9178

Sep 10 11:30:49 i-07691e4a45b3cd971 systemd[1]: Started django.service - Django Hello SadServers (dev ru>
Sep 10 11:30:50 i-07691e4a45b3cd971 python3[1367]: Watching for file changes with StatReloader
Sep 10 11:30:50 i-07691e4a45b3cd971 python3[1367]: Performing system checks...
Sep 10 11:30:50 i-07691e4a45b3cd971 python3[1367]: System check identified no issues (0 silenced).
Sep 10 11:30:50 i-07691e4a45b3cd971 python3[1367]: You have 2 unapplied migration(s). Your project may n>
Sep 10 11:30:50 i-07691e4a45b3cd971 python3[1367]: Run 'python manage.py migrate' to apply them.
Sep 10 11:30:50 i-07691e4a45b3cd971 python3[1367]: September 10, 2026 - 06:30:50
Sep 10 11:30:50 i-07691e4a45b3cd971 python3[1367]: Django version 4.2.28, using settings 'hellosad.setti>
Sep 10 11:30:50 i-07691e4a45b3cd971 python3[1367]: Starting development server at http://0.0.0.0:9178/
'

curl :80 -> bad gatway

 ● nginx.service - A high performance web server and a reverse proxy server
      Loaded: loaded (/usr/lib/systemd/system/nginx.service; enabled; preset: enabled)
      Active: active (running) since Thu 2026-09-10 11:22:51 UTC; 12min ago
  Invocation: 140679c520bf42949fa46763293f9d4a
        Docs: man:nginx(8)
    Main PID: 804 (nginx)
       Tasks: 3 (limit: 501)
      Memory: 4.2M (peak: 4.7M)
         CPU: 42ms
      CGroup: /system.slice/nginx.service
              ├─804 "nginx: master process /usr/sbin/nginx -g daemon on; master_process on;"
              ├─814 "nginx: worker process"
              └─815 "nginx: worker process"
 
 Sep 10 11:22:50 i-07691e4a45b3cd971 systemd[1]: Starting nginx.service - A high performance web server and a reverse proxy server...
 Sep 10 11:22:51 i-07691e4a45b3cd971 systemd[1]: Started nginx.service - A high performance web server and a reverse proxy server.

 tcp   LISTEN 0       511               0.0.0.0:80          0.0.0.0:*     users:(("nginx",pid=815,fd=5),("nginx",pid=814,fd=5),("nginx",pid=804,fd=5)) 
 tcp   LISTEN 0       10                0.0.0.0:9178        0.0.0.0:*     users:(("python3",pid=1367,fd=4))                                            
 tcp   LISTEN 0       4096        127.0.0.53%lo:53          0.0.0.0:*     users:(("systemd-resolve",pid=313,fd=19))                                    
 tcp   LISTEN 0       4096              0.0.0.0:5355        0.0.0.0:*     users:(("systemd-resolve",pid=313,fd=12))                                    
 tcp   LISTEN 0       128                  [::]:22             [::]:*     users:(("sshd",pid=796,fd=7))                                                
 tcp   LISTEN 0       511                  [::]:80             [::]:*     users:(("nginx",pid=815,fd=6),("nginx",pid=814,fd=6),("nginx",pid=804,fd=6))


 2026/08/12 19:32:20 [notice] 1380#1380: using inherited sockets from "5;6;"
 2026/09/10 11:33:13 [error] 814#814: *1 connect() failed (111: Connection refused) while connecting to upstream, client: 127.0.0.1, server: _, request: "GET / HTTP/1.1", upstream: "http://127.0.0.1:8000/", host: "127.0.0.1"
 2026/09/10 11:40:36 [error] 1493#1493: *1 connect() failed (111: Connection refused) while connecting to upstream, client: 127.0.0.1, server: _, request: "GET / HTTP/1.1", upstream: "http://127.0.0.1:8000/", host: "127.0.0.1"


admin@i-07691e4a45b3cd971:/etc/nginx/sites-enabled$ cat bergen 
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name _;

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }


Reporte: 

El problema era que el archivo binario corria en el puerto 8000 al igual que el django.service, lo que hicismos ya que django esta manejado bajo systemctl, fue cambiarle el puerto editanto el servicio. Todo funcionaria bien pero tenemos escuchando un nginx al puerto 8000 donde estaba la app de django por lo cual nos retornaba bad gatway cuando haciamos un curl a :80, entonces lo que hicimos fue editar la configuracion de ngnix y cambiar al puerto que cambiamos la app de django, ambos cambios que realizamos de los servicios se recomienda resetearlos.

