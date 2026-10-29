Scenario: "Lisbon": etcd SSL cert troubles

Level: Medium

Type: Fix

Tags: etcd   ssl   systemd  

Access: Email

Description: There's an etcd server running on https://localhost:2379 , get the value for the key "foo", ie etcdctl get foo

Root (sudo) Access: True

Test: etcdctl get foo --print-value-only returns bar. 
'''

etcdctl get foo


{"level":"warn","ts":"2027-09-24T19:08:03.579141Z","logger":"etcd-client","caller":"v3/retry_interceptor.go:63","msg":"retrying of unary invoker failed","target":"etcd-endpoints://0xc000324780/127.0.0.1:2379","attempt":0,"error":"rpc error: code = DeadlineExceeded desc = latest balancer error: last connection error: connection error: desc = \"transport: authentication handshake failed: remote error: tls: no application protocol\""}
Error: context deadline exceeded





ETCDCTL_API=3 etcdctl \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/etcd/pki/ca.crt \
  --cert=/etc/etcd/pki/server.crt \
  --key=/etc/etcd/pki/server.key \
  endpoint health



 {"level":"fatal","ts":"2027-09-24T19:08:27.460190Z","caller":"flags/flag.go:85","msg":"conflicting environment variable is shadowed by corresponding command-line flag (either unset environment variable or disable flag))","environment-variable":"ETCDCTL_ENDPOINTS","stacktrace":"go.etcd.io/etcd/pkg/flags.verifyEnv\n\tgo.etcd.io/etcd/pkg/flags/flag.go:85\ngo.etcd.io/etcd/pkg/flags.SetPflagsFromEnv\n\tgo.etcd.io/etcd/pkg/flags/flag.go:63\ngo.etcd.io/etcd/etcdctl/ctlv3/command.epHealthCommandFunc\n\tgo.etcd.io/etcd/etcdctl/ctlv3/command/ep_command.go:96\ngithub.com/spf13/cobra.(*Command).execute\n\tgithub.com/spf13/cobra/command.go:989\ngithub.com/spf13/cobra.(*Command).ExecuteC\n\tgithub.com/spf13/cobra/command.go:1117\ngithub.com/spf13/cobra.(*Command).Execute\n\tgithub.com/spf13/cobra/command.go:1041\ngo.etcd.io/etcd/etcdctl/ctlv3.Start\n\tgo.etcd.io/etcd/etcdctl/ctlv3/ctl.go:107\ngo.etcd.io/etcd/etcdctl/ctlv3.MustStart\n\tgo.etcd.io/etcd/etcdctl/ctlv3/ctl.go:111\nmain.main\n\tgo.etcd.io/etcd/etcdctl/main.go:59\nruntime.main\n\truntime/proc.go:283"



 ------------

 {"level":"fatal","ts":"2027-09-24T19:12:06.888637Z","caller":"flags/flag.go:85","msg":"conflicting environment variable is shadowed by corresponding command-line flag (either unset environment variable or disable flag))","environment-variable":"ETCDCTL_ENDPOINTS","stacktrace":"go.etcd.io/etcd/pkg/flags.verifyEnv\n\tgo.etcd.io/etcd/pkg/flags/flag.go:85\ngo.etcd.io/etcd/pkg/flags.SetPflagsFromEnv\n\tgo.etcd.io/etcd/pkg/flags/flag.go:63\ngo.etcd.io/etcd/etcdctl/ctlv3/command.clientConfigFromCmd\n\tgo.etcd.io/etcd/etcdctl/ctlv3/command/global.go:129\ngo.etcd.io/etcd/etcdctl/ctlv3/command.mustClientFromCmd\n\tgo.etcd.io/etcd/etcdctl/ctlv3/command/global.go:175\ngo.etcd.io/etcd/etcdctl/ctlv3/command.getCommandFunc\n\tgo.etcd.io/etcd/etcdctl/ctlv3/command/get_command.go:64\ngithub.com/spf13/cobra.(*Command).execute\n\tgithub.com/spf13/cobra/command.go:989\ngithub.com/spf13/cobra.(*Command).ExecuteC\n\tgithub.com/spf13/cobra/command.go:1117\ngithub.com/spf13/cobra.(*Command).Execute\n\tgithub.com/spf13/cobra/command.go:1041\ngo.etcd.io/etcd/etcdctl/ctlv3.Start\n\tgo.etcd.io/etcd/etcdctl/ctlv3/ctl.go:107\ngo.etcd.io/etcd/etcdctl/ctlv3.MustStart\n\tgo.etcd.io/etcd/etcdctl/ctlv3/ctl.go:111\nmain.main\n\tgo.etcd.io/etcd/etcdctl/main.go:59\nruntime.main\n\truntime/proc.go:283"}

 ● etcd.service - etcd - highly-available key value store
      Loaded: loaded (/usr/lib/systemd/system/etcd.service; enabled; preset: enabled)
     Drop-In: /etc/systemd/system/etcd.service.d
              └─lisbon.conf
      Active: active (running) since Fri 2027-09-24 19:07:19 UTC; 11min ago
  Invocation: 67c5d90b8ac145689e1d757f57a33c60
        Docs: https://etcd.io/docs
              man:etcd
    Main PID: 2001 (etcd)
       Tasks: 8 (limit: 501)
      Memory: 46.5M (peak: 48.3M)
         CPU: 3.897s
      CGroup: /system.slice/etcd.service
              └─2001 /usr/bin/etcd
 
 Sep 24 19:07:33 i-0ae66a23fdc0900c0 etcd[2001]: 2027/09/24 19:07:33 WARNING: [core] [Channel #3 SubChannel #4]grpc: addrConn.createTransport failed t



 tcp   LISTEN 0      4096          127.0.0.1:2379      0.0.0.0:*    users:(("etcd",pid=2001,fd=6)) 


 Sep 24 19:07:19 i-0ae66a23fdc0900c0 etcd[2001]: {"level":"info","ts":"2027-09-24T19:07:19.095624Z","caller":"etcdserver/server.go:2140","msg":"published local member to cluster through raft","local-member-id":"8e9e05c52164694d","local-member-attributes":"{Name:lisbon ClientURLs:[https://127.0.0.1:2379]}","request-path":"/0/members/8e9e05c52164694d/attributes","cluster-id":"cdf818194e3a8c32","publish-timeout":"7s"}
 Sep 24 19:07:19 i-0ae66a23fdc0900c0 etcd[2001]: {"level":"info","ts":"2027-09-24T19:07:19.102545Z","caller":"v3rpc/health.go:61","msg":"grpc service status changed","service":"","status":"SERVING"}
 Sep 24 19:07:19 i-0ae66a23fdc0900c0 etcd[2001]: {"level":"info","ts":"2027-09-24T19:07:19.103402Z","caller":"embed/serve.go:251","msg":"serving client traffic securely","traffic":"grpc+http","address":"127.0.0.1:2379"}
 Sep 24 19:07:19 i-0ae66a23fdc0900c0 etcd[2001]: 2027/09/24 19:07:19 WARNING: [core] [Channel #3 SubChannel #4]grpc: addrConn.createTransport failed to connect to {Addr: "127.0.0.1:2379", ServerName: "127.0.0.1:2379", }. Err: connection error: desc = "transport: authentication handshake failed: remote error: tls: no application protocol"


 /etc/rc0.d/K01etcd
 /etc/default/etcd
 /etc/profile.d/lisbon-etcdctl.sh
 /etc/init.d/etcd
 /etc/rc2.d/S01etcd
 /etc/rc6.d/K01etcd
 /etc/rc1.d/K01etcd
 /etc/rc3.d/S01etcd
 /etc/rc5.d/S01etcd
 /etc/systemd/system/etcd2.service
 /etc/systemd/system/etcd.service.d
 /etc/systemd/system/multi-user.target.wants/etcd.service
 /etc/rc4.d/S01etcd



 admin@i-0ae66a23fdc0900c0:/usr/bin$ cat /etc/default/etcd
 ## etcd(1) daemon options — Lisbon scenario (TLS on localhost:2379)
 ETCD_NAME=lisbon
 ETCD_DATA_DIR=/var/lib/etcd/default
 ETCD_LISTEN_CLIENT_URLS=https://127.0.0.1:2379
 ETCD_ADVERTISE_CLIENT_URLS=https://127.0.0.1:2379
 ETCD_CERT_FILE=/etc/ssl/lisbon/localhost.crt
 ETCD_KEY_FILE=/etc/ssl/lisbon/localhost.key
 admin@i-0ae66a23fdc0900c0:/usr/bin$ cat /etc/profile.d/lisbon-etcdctl.sh
 export ETCDCTL_API=3
 export ETCDCTL_ENDPOINTS=https://127.0.0.1:2379
 export ETCDCTL_CACERT=/etc/ssl/lisbon/localhost.crt


 /etc/default/etcd (Configuración del Servidor / Servicio)
 
 Este archivo define cómo systemd arranca el servicio etcd:
 
     ETCD_NAME=lisbon: Nombre del nodo dentro del clúster.
 
     ETCD_LISTEN_CLIENT_URLS=[https://127.0.0.1:2379](https://127.0.0.1:2379): Le indica al servicio etcd que escuche peticiones en HTTPS en el puerto 2379.
 
     ETCD_CERT_FILE=/etc/ssl/lisbon/localhost.crt: El certificado público que presenta etcd.
 
     ETCD_KEY_FILE=/etc/ssl/lisbon/localhost.key: La clave privada que usa etcd para descifrar la comunicación TLS.
 
 /etc/profile.d/lisbon-etcdctl.sh (Variables para el Cliente)
 
 Este script se ejecuta al iniciar sesión para configurar el cliente etcdctl:
 
     ETCDCTL_API=3: Fuerza el uso de la API v3.


# 1. Cargar las variables base del laboratorio
source /etc/profile.d/lisbon-etcdctl.sh

# 2. Agregar la clave y certificado que le faltan al cliente (usando los de Lisbon)
export ETCDCTL_CERT="/etc/ssl/lisbon/localhost.crt"
export ETCDCTL_KEY="/etc/ssl/lisbon/localhost.key"

# 3. Probar la consulta directamente (sin agregar el flag --endpoints)
etcdctl get foo


ETCDCTL_API=3 etcdctl \
  --cacert=/etc/ssl/lisbon/localhost.crt \
  --cert=/etc/ssl/lisbon/localhost.crt \
  --key=/etc/ssl/lisbon/localhost.key \
  --endpoints=https://127.0.0.1:2379 \
  member list


 admin@i-0ae66a23fdc0900c0:~$ openssl s_client -connect 127.0.0.1:2379 \
   -CAfile /etc/ssl/lisbon/localhost.crt \
   -cert /etc/ssl/lisbon/localhost.crt \
   -key /etc/ssl/lisbon/localhost.key \
   -alpn h2
 Connecting to 127.0.0.1
 CONNECTED(00000003)
 4097CF85817F0000:error:0A000460:SSL routines:ssl3_read_bytes:tlsv1 alert no application protocol:../ssl/record/rec_layer_s3.c:918:SSL alert number 120
 ---
 no peer certificate available
 ---
 No client certificate CA names sent
 Negotiated TLS1.3 group: <NULL>
 ---
 SSL handshake has read 7 bytes and written 1542 bytes
 Verification: OK
 ---
 New, (NONE), Cipher is (NONE)
 Protocol: TLSv1.3
 This TLS version forbids renegotiation.
 Compression: NONE
 Expansion: NONE
 No ALPN negotiated
 Early data was not sent
 Verify return code: 0 (ok)
 ---

# Verificar fechas de validez del certificado
openssl x509 -in /etc/ssl/lisbon/localhost.crt -noout -dates

# Comprobar que el certificado y la clave privada correspondan al mismo par
openssl x509 -noout -modulus -in /etc/ssl/lisbon/localhost.crt | openssl md5
openssl rsa -noout -modulus -in /etc/ssl/lisbon/localhost.key | openssl md5

 notBefore=Sep 25 18:48:12 2026 GMT
 notAfter=Oct 25 18:48:12 2026 GMT
 MD5(stdin)= 4bacabe6a535a1cc3f46b5751582bff3
 MD5(stdin)= 4bacabe6a535a1cc3f46b5751582bff3

 curl --cacert /etc/ssl/lisbon/localhost.crt \
   --cert /etc/ssl/lisbon/localhost.crt \
   --key /etc/ssl/lisbon/localhost.key \
   --http2 https://127.0.0.1:2379/version

curl: (60) SSL certificate problem: certificate has expired
More details here: https://curl.se/docs/sslcerts.html

curl failed to verify the legitimacy of the server and therefore could not
establish a secure connection to it. To learn more about this situation and
how to fix it, please visit the webpage mentioned above.


openssl x509 -in /etc/ssl/lisbon/localhost.crt -noout -startdate -enddate

notBefore=Sep 25 18:48:12 2026 GMT
notAfter=Oct 25 18:48:12 2026 GMT

LUEGO DE ACTUALIZAR
admin@i-0ae66a23fdc0900c0:~$ openssl x509 -in /etc/ssl/lisbon/localhost.crt -noout -startdate -enddate
notBefore=Sep 25 19:04:00 2027 GMT
notAfter=Sep 24 19:04:00 2028 GMT


admin@i-0ae66a23fdc0900c0:~$ sudo systemctl status lisbon-bootstrap
● lisbon-bootstrap.service - Lisbon scenario TLS cert refresh and clock skew
     Loaded: loaded (/etc/systemd/system/lisbon-bootstrap.service; enabled; preset: enabled)
     Active: active (exited) since Sat 2027-09-25 18:48:15 UTC; 20min ago
 Invocation: 3970b44a6e2f4706b13fd05659d249a2
       Docs: file:///etc/sadscenario
    Process: 764 ExecStart=/usr/local/bin/lisbon-bootstrap.sh (code=exited, status=0/SUCCESS)
   Main PID: 764 (code=exited, status=0/SUCCESS)
   Mem peak: 7.4M
        CPU: 1.083s

Sep 25 18:48:11 i-0ae66a23fdc0900c0 systemd[1]: Starting lisbon-bootstrap.service - Lisbon scenario TLS cert refresh and clock skew...
Sep 25 18:48:11 i-0ae66a23fdc0900c0 lisbon-bootstrap.sh[783]: .+......+.+..+.+..+.........+....+.....+..........+.....+.......+...+.....+.+........+.>
Sep 25 18:48:12 i-0ae66a23fdc0900c0 lisbon-bootstrap.sh[783]: .+.+......+.....+.......+...+..+...+.......+........+...+......+.+.....+.........+...+.>
Sep 25 18:48:12 i-0ae66a23fdc0900c0 lisbon-bootstrap.sh[783]: -----
Sep 25 18:48:15 i-0ae66a23fdc0900c0 lisbon-bootstrap.sh[1996]: Sat Sep 25 18:48:15 UTC 2027
Sep 25 18:48:15 i-0ae66a23fdc0900c0 systemd[1]: Finished lisbon-bootstrap.service - Lisbon scenario TLS cert refresh and clock skew.


Dice que requiere esto pero como vemos en los logs genera inconsistencias con tlc y clocks a proposito


cat /usr/local/bin/lisbon-bootstrap.sh

#!/bin/bash
# Regenerate a short-lived TLS cert while the clock is still correct, then
# advance the system time by one year so the cert looks expired to clients.
# Do not write the skewed time to the hardware clock (EC2 resets from the
# hypervisor on reboot).
set -euo pipefail

CERT_DIR=/etc/ssl/lisbon
CRT="${CERT_DIR}/localhost.crt"
KEY="${CERT_DIR}/localhost.key"

mkdir -p "${CERT_DIR}"

openssl req -x509 -nodes -newkey rsa:2048 \
  -keyout "${KEY}" \
  -out "${CRT}" \
  -days 30 \
  -subj "/CN=localhost" \
  -addext "subjectAltName = DNS:localhost,IP:127.0.0.1"

chmod 644 "${CRT}" "${KEY}"
chown root:root "${CRT}" "${KEY}"

install -m 0644 "${CRT}" /usr/local/share/ca-certificates/lisbon-localhost.crt
update-ca-certificates >/dev/null 2>&1 || true

# Prevent NTP from correcting the intentional clock skew.
timedatectl set-ntp false 2>/dev/null || true
for unit in systemd-timesyncd.service chrony.service chronyd.service ntp.service ntpsec.service; do
  systemctl stop "${unit}" 2>/dev/null || true
  systemctl disable "${unit}" 2>/dev/null || true
  systemctl mask "${unit}" 2>/dev/null || true
done

date -s "next year"

admin@i-0ae66a23fdc0900c0:~$ etcdctl get foo --print-value-only
{"level":"warn","ts":"2026-10-01T19:37:26.890844Z","logger":"etcd-client","caller":"v3/retry_interceptor.go:63","msg":"retrying of unary invoker failed","target":"etcd-endpoints://0xc00037e1e0/127.0.0.1:2379","attempt":0,"error":"rpc error: code = DeadlineExceeded desc = latest balancer error: last connection error: connection error: desc = \"error reading server preface: http2: frame too large\""}
Error: context deadline exceeded
admin@i-0ae66a23fdc0900c0:~$ 





