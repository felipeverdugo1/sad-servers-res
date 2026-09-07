Access: Email

Description: This small VM runs sad-api (a lightweight health endpoint on port 9090) and sad-batch (a nightly ETL-style job that allocates a lot of RAM).

After a recent deploy, starting sad-batch caused memory use to spike and sad-api was killed by the OOM killer. On-call stopped the batch service before handing you the host.

A legacy cgroup v2 launcher under /opt/sad/ is supposed to enforce a 128M hard limit on cgroup sad-batch, but the cap never applies.

sad-batch is intentionally stopped and disabled when you log in. Read /home/admin/incident-notes.txt for context. Fix the cgroup configuration so /sys/fs/cgroup/sad-batch/memory.max is 134217728 before you start the batch job again.

Do not change sad-api; it should keep running on 127.0.0.1:9090.

Root (sudo) Access: True

Test: sad-api is active and curl http://127.0.0.1:9090/ returns SadServers - API OK.

The cgroup v2 hard limit is in place: cat /sys/fs/cgroup/sad-batch/memory.max prints 134217728 (128 MiB).

The "Check My Solution" button runs the script /home/admin/agent/check.sh, which you can see and execute.

cat incident-notes.txt

Incident: 2026-06-10 — nightly batch run took down the API

After the batch job was redeployed, sad-batch started allocating hundreds of
megabytes during its run. sad-api (port 9090) was killed by the OOM killer and
stayed down until someone restarted it manually.

This host does NOT use systemd resource limits for the batch job. Memory control
is handled by a legacy cgroup v2 launcher under /opt/sad/ (see setup-cgroup.sh
and run-batch.sh). On-call disabled sad-batch before handing the VM to you.

Reproduce (careful on this small VM):
  systemctl status sad-api sad-cgroup-setup sad-batch
  curl -s http://127.0.0.1:9090/
  cat /sys/fs/cgroup/sad-batch/memory.max
  cat /sys/fs/cgroup/sad-batch/memory.high
  sudo systemctl start sad-batch

Ops ticket excerpt:
  "We set a 128M cap in setup-cgroup.sh — why is memory.max still max?"

Legacy wiki snippet (2023, cgroup v1 — do not trust blindly):
  echo 134217728 > /sys/fs/cgroup/memory/sad-batch/memory.limit_in_bytes

cat /sys/fs/cgroup/sad-batch/memory.max prints 134217728 (128 MiB).

max

systemd-cgls

journalctl -u sad-batch.service -n 50 --no-pager

mirar el servicio, como esta configurado segun el cgroup sad-batch

### /etc/systemd/system/sad-batch.service
# [Unit]
# Description=SadServers batch ETL worker
# After=network.target sad-cgroup-setup.service
# Requires=sad-cgroup-setup.service
# 
# [Service]
# Type=simple
# ExecStart=/opt/sad/run-batch.sh
# Restart=on-failure
# RestartSec=5
# 
# [Install]
# WantedBy=multi-user.target



#!/usr/bin/env bash
# Memory-heavy batch worker; must stay inside its cgroup budget.
exec python3 - <<'PY'
import time

chunks = []
	for _ in range(256):
    chunks.append(bytearray(1024 * 1024))
    time.sleep(0.05)
PY



#!/usr/bin/env bash
# Ensure the sad-batch cgroup exists with the intended memory budget.
set -euo pipefail

CGROUP=/sys/fs/cgroup/sad-batch

mkdir -p "$CGROUP"
echo 134217728 > "$CGROUP/memory.high"


#!/usr/bin/env bash
# Launch the batch worker inside the sad-batch cgroup.
set -euo pipefail

/opt/sad/setup-cgroup.sh
echo $$ > /sys/fs/cgroup/sad-batch/cgroup.procs
exec /opt/sad/sad-batch.sh

admin@i-0285bb94fbc615e56:/sys/fs/cgroup/sad-batch$ cat memory.high 
134217728

● sad-api.service - SadServers API health endpoint
     Loaded: loaded (/etc/systemd/system/sad-api.service; enabled; preset: enabled)
     Active: active (running) since Mon 2026-09-07 17:08:13 UTC; 7min ago
 Invocation: af887c3727374cad9380d626aa090e48
   Main PID: 768 (python3)
      Tasks: 1 (limit: 501)
     Memory: 8.6M (max: 48M, available: 39.3M, peak: 8.8M)
        CPU: 144ms
     CGroup: /system.slice/sad-api.service
             └─768 python3 /opt/sad/sad-api.sh

Sep 07 17:08:13 i-0285bb94fbc615e56 systemd[1]: Started sad-api.service - SadServers API health endpoint.

● sad-cgroup-setup.service - Create sad-batch cgroup at boot
     Loaded: loaded (/etc/systemd/system/sad-cgroup-setup.service; enabled; preset: enabled)
     Active: active (exited) since Mon 2026-09-07 17:07:59 UTC; 8min ago
 Invocation: cd6d4b0dbc0540bca05109dc150c2292
   Main PID: 269 (code=exited, status=0/SUCCESS)
   Mem peak: 2.4M
        CPU: 34ms

Notice: journal has been rotated since unit was started, output may be incomplete.

○ sad-batch.service - SadServers batch ETL worker
     Loaded: loaded (/etc/systemd/system/sad-batch.service; disabled; preset: enabled)
     Active: inactive (dead)

Editamos el servicio 

sudo systemctl edit sad-batch.ser


● sad-batch.service - SadServers batch ETL worker
     Loaded: loaded (/etc/systemd/system/sad-batch.service; disabled; preset: enabled)
    Drop-In: /etc/systemd/system/sad-batch.service.d
             └─override.conf
     Active: active (running) since Mon 2026-09-07 17:21:58 UTC; 11s ago
 Invocation: 0729952b240d4473ad20ea10f3323fc9
   Main PID: 1146 (python3)
      Tasks: 0 (limit: 501)
     Memory: 16K (peak: 1.7M)
        CPU: 17ms
     CGroup: /system.slice/sad-batch.service
             ‣ 1146 python3 -


Resumen: el ejercicio nos plantea que tenemos una api donde escucha local host y un puerto , y tambien tenemos un archivo bach que es bastante pesado a amivel de memoria, que se ejecuta nocturno, lo que pasa con esto es que tiene una version vieja de cgruops lo cual no es manejada por systemctl sino que se maneja mediante scripts, al revisar el servicio del bach no pertenecia a ninguno, y se comia toda la mem, por lo que tuvimos que hacer fue ejecutar el set up, y setear tambien el mememory.max ya que retornaba "max" y le establecimos el mismo que tenia high ya que no estaba docuementeado otro tipo de memoria, una vez ejecutado el script por las dudas restarteamos la cache y el service y arranco. Esta documentado la otra forma de hacerlo que seria por systemctl y editando el archvivo service
 