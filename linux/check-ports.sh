Scenario: "Porto": Port audit without net tools

Level: Easy

Type: Do

Tags: bash  

Access: Email

Description: The security team removed common network recon utilities from this host. Your job is to determine which TCP ports on localhost (127.0.0.1) are accepting connections.

The ports to check are listed in /home/admin/ports-to-scan.txt (one port per line).

Write your results to /home/admin/port-audit.txt with one line per port, sorted by port number (ascending), using this format:

PORT STATUS

where STATUS is exactly open or closed (lowercase).

A template file /home/admin/port-audit.txt is available with values per port "open|closed", delete the separator and the incorrect value per port or re-create the file.

The following are not available on this system (removed or restricted): ss, netstat, nmap, nc, telnet, curl, wget, lsof, tcpdump, openssl, fuser.

NOTE: you don't have root (superuser) access.

Root (sudo) Access: False

Test: The file /home/admin/port-audit.txt exists and correctly reports whether each port in /home/admin/ports-to-scan.txt is open or closed on 127.0.0.1.

The "Check My Solution" button runs the script /home/admin/agent/check.sh, which you can see and execute.

Time to Solve: 15 minutes.

'

Detectar que puertos tiene localhost para conexiones tpc

Hay que armar una archivo el cual las conexiones a detectar son las que estan en este archivo

cat /home/admin/ports-to-scan.txt

22 open|closed
2222 open|closed
3000 open|closed
4444 open|closed
8081 open|closed
9999 open|closed


Y hay que generar un archivo que audite lo que nos consultan

Ej:
import socket
ip = "127.0.0.1"
for port in range(1, 1024):
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.settimeout(0.1)
    if s.connect_ex((ip, port)) == 0:
        print(f"Puerto local {port} ABIERTO")
    s.close()


Hay que crear un archivo con la estructura que nos piden
vim /home/admin/port-audit.txt

#cat /home/admin/port-audit.txt | cut -d ' ' -f1
import sys, socket

# IP objetivo (puedes cambiarla o pasarla como parámetro)
ip = "127.0.0.1"
print("PORT STATUS")
for line in sys.stdin:
    line = line.strip()
    if line.isdigit():
        port = int(line)
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.settimeout(1.0)
        res = s.connect_ex((ip, port))
        if res == 0:
            print(f"{port} open")
        else:
            print(f"{port} closed")
        s.close()



cat /home/admin/ports-to-scan | sort -n | python3 escaneo.py | column -t  > /home/admin/port-audit.txt 


PORT  STATUS
22    OPEN
2222  OPEN
3000  OPEN
4444  CLOSED
8081  OPEN
9999  CLOSED


while read port; do 
  if timeout 1 bash -c "</dev/tcp/127.0.0.1/$port" 2>/dev/null; then 
    echo "$port open"
  else 
    echo "$port closed"
  fi
done < <(sort -n /home/admin/ports-to-scan.txt) > /home/admin/port-audit.txt




3. Bash can open TCP connections when compiled with net redirections enabled (default on Debian bash). Test a port with a one-liner:

(echo >/dev/tcp/127.0.0.1/PORT) 2>/dev/null && echo open || echo closed

Replace PORT with the number you are testing. 

while read port; do
   (echo >/dev/tcp/127.0.0.1/$port)
   2>/dev/null && echo "$port open"
   || echo "$port closed";
 done < <(sort -n /home/admin/ports-to-scan.txt) > /home/admin/port-audit.txt

python3 -c 
import socket
with open("/home/admin/ports-to-scan.txt") as f:
    ports = sorted([int(line.strip()) for line in f if line.strip().isdigit()])
with open("/home/admin/port-audit.txt", "w") as out:
    for port in ports:
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.settimeout(0.5)
        status = "open" if s.connect_ex(("127.0.0.1", port)) == 0 else "closed"
        s.close()
        out.write(f"{port} {status}\n")



 2. RESOLUCIÓN DE AUDITORÍA DE PUERTOS (ESCENARIO PORTO)

-------------------------------------------------------------------

DESAFÍO:

Detectar qué puertos TCP de localhost (127.0.0.1) estaban abiertos 

o cerrados utilizando exclusivamente herramientas nativas de Bash 

o Python, debido a la restricción/eliminación de herramientas de 

red (ss, netstat, nmap, nc, lsof, etc.).



MOTIVO POR EL CUAL FALLABAN LOS INTENTOS PREVIOS:

1. Las respuestas del estado devolvían "OPEN/CLOSED" en mayúsculas,

   violando la regla estricta del test ("open/closed" en minúsculas).

2. El archivo de entrada contenía texto adicional ("22 open|closed")

   que rompía los scripts al no limpiar los números de puerto.



SOLUCIÓN EJECUTADA:

Se utilizó un bucle de Bash procesando los puertos de entrada mediante

la redirección nativa de sockets de red de Bash (`/dev/tcp`):



Comando ejecutado:

while read port; do 

  (echo >/dev/tcp/127.0.0.1/$port) 2>/dev/null && echo "$port open" || echo "$port closed"

done < <(sort -n /home/admin/ports-to-scan.txt) > /home/admin/port-audit.txt



RESULTADO:

El archivo `/home/admin/port-audit.txt` se generó correctamente con el

formato exacto pedido ("PUERTO STATUS" en minúsculas y ordenado).

