Scenario: "Manhattan": can't write data into database.

Level: Medium

Type: Fix

Tags: disk volumes   postgres   systemd  

Access: Public

Description: Your objective is to be able to insert a row in an existing Postgres database. The issue is not specific to Postgres and you don't need to know details about it (although it may help).

Helpful Postgres information: it's a service that listens to a port (:5432) and writes to disk in a data directory, the location of which is defined in the data_directory parameter of the configuration file /etc/postgresql/14/main/postgresql.conf. In our case Postgres is managed by systemd as a unit with name postgresql.

Root (sudo) Access: True

Test: (from default admin user) sudo -u postgres psql -c "insert into persons(name) values ('jane smith');" -d dt

Should return:INSERT 0 1

Time to Solve: 20 minutes.
'




cat /etc/postgresql/14/main/postgresql.conf

#data_directory = '/var/lib/postgresql/14/main'         # use data in another directory
data_directory = '/opt/pgdata/main'             # use data in another directory


● postgresql@14-main.service                           loaded failed failed    PostgreSQL Cluster 14-mai



PG_VERSION  pg_commit_ts  pg_multixact  pg_serial     pg_stat_tmp  pg_twophase  postgresql.auto.conf
base        pg_dynshmem   pg_notify     pg_snapshots  pg_subtrans  pg_wal       postmaster.opts
global      pg_logical    pg_replslot   pg_stat       pg_tblspc    pg_xact
root@ip-10-1-13-69:/opt/pgdata/main# cat pg_s

root@ip-10-1-13-69:/opt/pgdata/main# cat postmaster.opts 
/usr/lib/postgresql/14/bin/postgres "-D" "/opt/pgdata/main" "-c" "config_file=/etc/postgresql/14/main/postgresql.conf"


 postgresql.service                                                       loaded active exited    PostgreSQL RDBMS                                  
● postgresql@14-main.service                                               loaded failed failed    PostgreSQL Cluster 14-main     

● postgresql@14-main.service - PostgreSQL Cluster 14-main
   Loaded: loaded (/lib/systemd/system/postgresql@.service; enabled-runtime; vendor preset: enabled)
   Active: failed (Result: protocol) since Wed 2026-09-16 20:57:23 UTC; 15min ago

Sep 16 20:57:23 ip-10-1-13-69 systemd[1]: Starting PostgreSQL Cluster 14-main...
Sep 16 20:57:23 ip-10-1-13-69 postgresql@14-main[576]: Error: /usr/lib/postgresql/14/bin/pg_ctl /usr/lib/postgresql/14/bin/pg_ctl start -D /opt/pgdata
Sep 16 20:57:23 ip-10-1-13-69 systemd[1]: postgresql@14-main.service: Can't open PID file /run/postgresql/14-main.pid (yet?) after start: No such file
Sep 16 20:57:23 ip-10-1-13-69 systemd[1]: postgresql@14-main.service: Failed with result 'protocol'.
Sep 16 20:57:23 ip-10-1-13-69 systemd[1]: Failed to start PostgreSQL Cluster 14-main.
'

root@ip-10-1-13-69:/run/postgresql/14-main.pg_stat_tmp# systemctl restart  postgresql@14-main.service  
Job for postgresql@14-main.service failed because the service did not take the steps required by its unit configuration.
See "systemctl status postgresql@14-main.service" and "journalctl -xe" for details.


● postgresql@14-main.service - PostgreSQL Cluster 14-main
   Loaded: loaded (/lib/systemd/system/postgresql@.service; enabled-runtime; vendor preset: enabled)
   Active: failed (Result: protocol) since Wed 2026-09-16 21:15:07 UTC; 1min 8s ago
  Process: 958 ExecStart=/usr/bin/pg_ctlcluster --skip-systemctl-redirect 14-main start (code=exited, status=1/FAILURE)

Sep 16 21:15:07 ip-10-1-13-69 systemd[1]: Starting PostgreSQL Cluster 14-main...
Sep 16 21:15:07 ip-10-1-13-69 postgresql@14-main[958]: Error: /usr/lib/postgresql/14/bin/pg_ctl /usr/lib/postgresql/14/bin/pg_ctl start -D /opt/pgdata
Sep 16 21:15:07 ip-10-1-13-69 postgresql@14-main[958]: 2026-09-16 21:15:07.139 UTC [963] FATAL:  could not create lock file "postmaster.pid": No space
Sep 16 21:15:07 ip-10-1-13-69 postgresql@14-main[958]: pg_ctl: could not start server
Sep 16 21:15:07 ip-10-1-13-69 postgresql@14-main[958]: Examine the log output.
Sep 16 21:15:07 ip-10-1-13-69 systemd[1]: postgresql@14-main.service: Failed to parse PID from file /run/postgresql/14-main.pid: Invalid argument
Sep 16 21:15:07 ip-10-1-13-69 systemd[1]: postgresql@14-main.service: Failed with result 'protocol'.
Sep 16 21:15:07 ip-10-1-13-69 systemd[1]: Failed to start PostgreSQL Cluster 14-main.
lines 1-13/13 (END)

Usa /usr/bin/pg_ctlcluster , pero usa 14-main para arrancar el server

Error: /usr/lib/postgresql/14/bin/pg_ctl /usr/lib/postgresql/14/bin/pg_ctl start -D /opt/pgdata

Lo que indica ahi es que va usar esa config de arranque, y va a usar ese lugar de dir /opt/pgdata

postgresql@14-main[958]: 2026-09-16 21:15:07.139 UTC [963] FATAL:  could not create lock file "postmaster.pid": No space

Ya lo toma como un error fatal, dice que no hay espacio para crear el archivo de lock, tendriamos que chequear esa carpeta opt/data
Sep 16 21:15:07 ip-10-1-13-69 postgresql@14-main[958]: pg_ctl: could not start server
Sep 16 21:15:07 ip-10-1-13-69 postgresql@14-main[958]: Examine the log output.
Sep 16 21:15:07 ip-10-1-13-69 systemd[1]: postgresql@14-main.service: Failed to parse PID from file /run/postgresql/14-main.pid: Invalid argument

Por lo cual no puede prender el server, y dice que esta mal parseado el PID del archivo /run/postgresql/14-main.pid, tendriamos que chequearlo, y se trata de un problema con los argumentos

A simple vista veo que que en el data directory es /main y en los start no esta ese /main

drwx------ 19 postgres postgres       4096 May 21  2022 main


root@ip-10-1-13-178:/opt/pgdata/main# cat postmaster.opts 
/usr/lib/postgresql/14/bin/postgres "-D" "/opt/pgdata/main" "-c" "config_file=/etc/postgresql/14/main/postgresql.conf"


Sep 22 12:05:52 ip-10-1-13-178 systemd-fstab-generator[876]: Failed to create unit file /run/systemd/generator/opt-pgdata.mount, as it already exists.
Sep 22 12:05:52 ip-10-1-13-178 systemd[869]: /usr/lib/systemd/system-generators/systemd-fstab-generator failed with exit status 1.
Sep 22 12:05:52 ip-10-1-13-178 systemd-fstab-generator[876]: Failed to create unit file /run/systemd/generator/opt-pgdata.mount, as it already exists.


root@ip-10-1-13-178:/run/systemd/generator/postgresql.service.wants# cat postgresql\@14-main.service 
# systemd service template for PostgreSQL clusters. The actual instances will
# be called "postgresql@version-cluster", e.g. "postgresql@9.3-main". The
# variable %i expands to "version-cluster", %I expands to "version/cluster".
# (%I breaks for cluster names containing dashes.)

[Unit]
Description=PostgreSQL Cluster %i
AssertPathExists=/etc/postgresql/%I/postgresql.conf
RequiresMountsFor=/etc/postgresql/%I /var/lib/postgresql/%I
PartOf=postgresql.service
ReloadPropagatedFrom=postgresql.service
Before=postgresql.service
# stop server before networking goes down on shutdown
After=network.target

[Service]
Type=forking
# -: ignore startup failure (recovery might take arbitrarily long)
# the actual pg_ctl timeout is configured in pg_ctl.conf
ExecStart=-/usr/bin/pg_ctlcluster --skip-systemctl-redirect %i start
# 0 is the same as infinity, but "infinity" needs systemd 229
TimeoutStartSec=0
ExecStop=/usr/bin/pg_ctlcluster --skip-systemctl-redirect -m fast %i stop
TimeoutStopSec=1h
ExecReload=/usr/bin/pg_ctlcluster --skip-systemctl-redirect %i reload
PIDFile=/run/postgresql/%i.pid
SyslogIdentifier=postgresql@%i
# prevent OOM killer from choosing the postmaster (individual backends will
# reset the score to 0)
OOMScoreAdjust=-900
# restarting automatically will prevent "pg_ctlcluster ... stop" from working,
# so we disable it here. Also, the postmaster will restart by itself on most
# problems anyway, so it is questionable if one wants to enable external
# automatic restarts.
#Restart=on-failure
# (This should make pg_ctlcluster stop work, but doesn't:)
#RestartPreventExitStatus=SIGINT SIGTERM

[Install]
WantedBy=multi-user.target


root@ip-10-1-13-178:/run/systemd/generator# cat opt-pgdata.mount 
# Automatically generated by systemd-fstab-generator

[Unit]
SourcePath=/etc/fstab
Documentation=man:fstab(5) man:systemd-fstab-generator(8)

[Mount]
Where=/opt/pgdata
What=/dev/disk/by-uuid/9a2e1bf9-50e8-41a9-9f8c-5dd837869c50
Type=xfs
Options=defaults,nofail

El motor reporta que no tiene espacio para escribir en /opt/pgdata.

    Espacio en disco (Bloques): Revisá el uso del sistema de archivos donde reside /opt/ o /opt/pgdata.

        Comando útil: df -h

    Inodos (Cantidad de archivos): A veces hay espacio libre en megabytes/gigabytes, pero el sistema de archivos se quedó sin inodos (descriptores de archivos disponibles) por exceso de archivos pequeños.

        Comando útil: df -i

    Permisos y Propietario: Asegurate de que el usuario postgres tenga permisos explícitos de escritura (rwx) sobre la carpeta /opt/pgdata y que sea el dueño de la misma.

        Comando útil: ls -ld /opt/pgdata


Habia que enfocarse en el mensaje claro del fatal error
