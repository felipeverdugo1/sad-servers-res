Type: Fix

Tags: postgres  

Access: Email

Description: A web application relies on the PostgreSQL 13 database present on this server. However, the connection to the database is not working. Your task is to identify and resolve the issue causing this connection failure. The application connects to a database named app1 with the user app1user and the password app1user.

Credit PykPyky

Root (sudo) Access: True

Test: Running 

PGPASSWORD=app1user psql -h 127.0.0.1 -d app1 -U app1user -c '\q' 

Mirar los servicios y las conexiones


ss -tulp

tcp     LISTEN    0         244                                127.0.0.1:postgresql               0.0.0.0:*                                           
tcp     LISTEN    0         4096                                       *:6767                           *:*       users:(("sadagent",pid=601,fd=7))   
tcp     LISTEN    0         4096                                       *:http-alt                       *:*       users:(("gotty",pid=600,fd=6))      
tcp     LISTEN    0         128                                     [::]:ssh                         [::]:*                                      


psql: error: FATAL:  pg_hba.conf rejects connection for host "127.0.0.1", user "app1user", database "app1", SSL on
FATAL:  pg_hba.conf rejects connection for host "127.0.0.1", user "app1user", database "app1", SSL off

sudo -u postgres psql -c "SHOW hba_file;"

Resumen: Lo que paso fue que nosotros teniamos una base de datos con usuario y contraseña en posgress pero no funcionaba la coneccion, por lo cual primero chequeamos si el servicio estaba caido lo cual no, y luego intetamos conectarnos y nos tiro pg_hba.conf, que es la configuracion de host-based-auth que son las reglas tipo firewall, para las conecciones, vimos que en la primera linea estaba el type rejected lo cual denegaba todo tipo de coneccion, pero si agregamos nuestra conexion en la primera linea, pasara y nos vamos a poder conectar