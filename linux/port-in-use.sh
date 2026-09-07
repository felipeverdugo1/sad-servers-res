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

