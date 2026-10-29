

Scenario: "Venice": Am I in a container?

Level: Medium

Type: Do

Tags: docker   unusual-tricky  

Access: Email

Description: Try and figure out if you are inside a container (like a Docker one for example) or inside a Virtual Machine (like in the other scenarios).

Root (sudo) Access: False

Test: This scenario doesnt have a test (hence also no "Check My Solution" either).

Time to Solve: 15 minutes.


===================================================================

 GUÍA DE COMANDOS PARA VERIFICAR SI ESTÁS DENTRO DE UN CONTENEDOR

===================================================================



[1] Comprobar existencia del archivo .dockerenv

-------------------------------------------------------------------

Comando:

test -f /.dockerenv && echo "Dentro de Docker" || echo "En el Host"


Respuesta obtenida:

En el Host


-------------------------------------------------------------------



[2] Inspeccionar cgroups del proceso 1 (PID 1)

-------------------------------------------------------------------

Comando:

cat /proc/1/cgroup



Respuesta obtenida:

0::/init.scope








-------------------------------------------------------------------



[3] Verificar puntos de montaje del sistema

-------------------------------------------------------------------

Comando:

grep -E 'docker|overlay' /proc/1/mountinfo



Respuesta obtenida:

root@ip-10-1-13-210:/# grep -E 'docker|overlay' /proc/1/mountinfo
250 214 0:35 / / rw,relatime - overlay overlay rw,lowerdir=/var/lib/containers/storage/overlay/l/4UGO27476EXYY2UQSGBWL6EZC4:/var/lib/containers/storage/overlay/l/3JZQV4UY3FCO3W7SL3ERYENEZN:/var/lib/containers/storage/overlay/l/SCP4AZOKFN5HY4R5CQ5UVOYS7K:/var/lib/containers/storage/overlay/l/LPA46WOYFQ5ZHRJPEGNEEUCN36:/var/lib/containers/storage/overlay/l/WYTOBRCWJIZJALTLB3T5GBAQAB,upperdir=/var/lib/containers/storage/overlay/90325170206a4e10aee30b8aeadab30716415bf1ce67e1d3216bb15d45520be8/diff,workdir=/var/lib/containers/storage/overlay/90325170206a4e10aee30b8aeadab30716415bf1ce67e1d3216bb15d45520be8/work
256 250 0:22 /containers/storage/overlay-containers/5e1f2f8aec6776c3b1a47d74471dcec059029c9920a796f7826656ae5a2c5bd2/userdata/hosts /etc/hosts rw,nosuid,nodev,noexec,relatime - tmpfs tmpfs rw,size=46428k,mode=755
257 250 0:22 /containers/storage/overlay-containers/5e1f2f8aec6776c3b1a47d74471dcec059029c9920a796f7826656ae5a2c5bd2/userdata/resolv.conf /etc/resolv.conf rw,nosuid,nodev,noexec,relatime - tmpfs tmpfs rw,size=46428k,mode=755
258 254 0:22 /containers/storage/overlay-containers/5e1f2f8aec6776c3b1a47d74471dcec059029c9920a796f7826656ae5a2c5bd2/userdata/.containerenv /run/.containerenv rw,nosuid,nodev,noexec,relatime - tmpfs tmpfs rw,size=46428k,mode=755
260 250 0:22 /containers/storage/overlay-containers/5e1f2f8aec6776c3b1a47d74471dcec059029c9920a796f7826656ae5a2c5bd2/userdata/hostname /etc/hostname rw,nosuid,nodev,noexec,relatime - tmpfs tmpfs rw,size=46428k,mode=755










-------------------------------------------------------------------



[4] Utilidad de detección de virtualización (Systemd)

-------------------------------------------------------------------

Comando:

systemd-detect-virt



Respuesta obtenida:

root@ip-10-1-13-210:/# systemd-detect-virt
container-other

-------------------------------------------------------------------



[5] Revisar el Nombre de Host (Hostname)

-------------------------------------------------------------------

Comando:

hostname



Respuesta obtenida:

ip-10-1-13-210

===================================================================

Sí, estamos dentro de un contenedor, pero no es Docker clásico, sino Podman (u otro motor OCI basado en containers/storage).
Diagnóstico clave de tus resultados

    Puntos de montaje (mountinfo): Muestra el archivo /run/.containerenv y la ruta /var/lib/containers/storage/overlay/. Esta es la huella digital inconfundible de Podman o CRI-O.

    Virtualización (systemd-detect-virt): Devuelve container-other, confirmando que el entorno está contenedorizado.

    Prueba .dockerenv fallida: dio "En el Host" precisamente porque este archivo solo lo crea Docker; Podman utiliza /.containerenv.

    Cgroups v2 (0::/init.scope): Indica que el sistema utiliza cgroups v2 con un manejador de procesos moderno.

Conclusión

Estamos ejecutando comandos dentro de un contenedor gestionado por Podman (muy común en entornos Kubernetes, Red Hat o configuraciones rootless).

