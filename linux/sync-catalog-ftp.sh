

Scenario: "Edinburgh": FTP catalog sync failure

Level: Easy

Description: The warehouse API on this host should answer on http://127.0.0.1:9178/ with a body containing OK.

It depends on a catalog file pulled from the internal FTP mirror at 127.0.0.1.

The sync job at /home/admin/edinburgh-sync.sh is failing; edinburgh-sync is in a failed state and the API never comes up healthy.

Fix the sync so the catalog is downloaded and the API works again.

Test: /var/lib/edinburgh/catalog.txt exists with the correct inventory data, the service edinburgh-api is active, and curl http://127.0.0.1:9178/ returns a response whose body contains OK.

The "Check My Solution" button runs the script /home/admin/agent/check.sh, which you can see and execute.

Time to Solve: 10 minutes.

OS: Debian 13

Root (sudo) Access: Yes


admin@i-03837a9a2cb983d45:~$ cat edinburgh-sync.sh 
#!/bin/bash
# Sync inventory catalog from the internal FTP mirror.
set -euo pipefail

HOST="127.0.0.1"
USER="edinburgh"
PASS="edinburgh-catalog"
REMOTE="catalog.txt"
DEST="/var/lib/edinburgh/catalog.txt"
TMP="${DEST}.tmp"

rm -f "${TMP}"

ftp -inv "$HOST" <<EOF
user ${USER} ${PASS}
binary
passive off
get ${REMOTE} ${TMP}
bye
EOF

mv -f "${TMP}" "${DEST}"
chmod 0644 "${DEST}"

curl: (7) Failed to connect to 127.0.0.1 port 9178 after 0 ms: Could not connect to server


Connected to 127.0.0.1.
220 Edinburgh FTP mirror (passive only)
331 Password required
230 Login successful
Remote system type is UNIX.
Using binary mode to transfer files.
200 Type set to I
Passive mode: off; fallback to active mode: off.
local: /var/lib/edinburgh/catalog.txt.tmp remote: catalog.txt
500 PORT/EPRT not allowed; use PASV
ftp: Can't bind for data connection: Address already in use
221 Goodbye
mv: cannot stat '/var/lib/edinburgh/catalog.txt.tmp': No such file or directory
'


admin@i-03837a9a2cb983d45:/var/lib/edinburgh$ python3 test.py 
Puerto local 21 ABIERTO
Puerto local 22 ABIERTO
Puerto local 5355 ABIERTO
Puerto local 6767 ABIERTO
Puerto local 8080 ABIERTO


Cambiar a fpt pasivo

ftp -inv "$HOST" <<EOF
user ${USER} ${PASS}
binary
passive on
get ${REMOTE} ${TMP}
bye
EOF


cat al catalog.txt

EDINBURGH_CATALOG_VERSION=2026-05-18
sku=WH-42 qty=12
sku=BK-17 qty=3


admin@i-03837a9a2cb983d45:~$ systemctl status edinburgh-sync.service 
● edinburgh-sync.service - Edinburgh catalog FTP sync
     Loaded: loaded (/etc/systemd/system/edinburgh-sync.service; enabled; preset: enabled)
     Active: active (exited) since Mon 2026-09-07 15:23:57 UTC; 48s ago
 Invocation: 66d519ed9e0b4315889cf4418d209c7b
    Process: 1001 ExecStart=/home/admin/edinburgh-sync.sh (code=exited, status=0/SUCCESS)
   Main PID: 1001 (code=exited, status=0/SUCCESS)
   Mem peak: 1.8M



 ○ edinburgh-api.service - Edinburgh warehouse API
      Loaded: loaded (/etc/systemd/system/edinburgh-api.service; enabled; preset: enabled)
      Active: inactive (dead)
 
 Sep 07 15:21:32 i-03837a9a2cb983d45 systemd[1]: Dependency failed for edinburgh-api.service - Edinburgh >
 Sep 07 15:21:32 i-03837a9a2cb983d45 systemd[1]: edinburgh-api.service: Job edinburgh-api.service/start f>



 sudo systemctl restart edinburgh-api.service 


Resumen: se nos planteo un problema donde teniamos una api escuchando en localhost en el puerto 9178 donde utiliza para trasferencia de datos ftp, y tiene un script de sync-ftp en el homedir donde define varios parametros, uno de ellos es el modo en el que ftp maneja los datos, el modo pasivo y el modo activo, justamente ftp esta configurado en modo pasivo pero en el script habia que cambiarlo, passive on, Luego ejecutamos de nuevo el script lo cual paso y creo el archivo catalog, pero la api seguia sin funcionar po lo tanto lo que tenemos que hacer es reinicar los servicios mediante systemctl
 