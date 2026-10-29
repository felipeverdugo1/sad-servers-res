

Scenario: "Oaxaca": Close an Open File

Level: Medium

Type: Fix

Tags: bash   unusual-tricky  

Access: Email

Description: The file /home/admin/somefile is open for writing by some process. Close this file without killing the process.

Root (sudo) Access: False

Test: lsof /home/admin/somefile returns nothing.

Time to Solve: 15 minutes.


===================================================================

 IDENTIFICAR EL PID DEL PROCESO QUE ESTÁ ESCRIBIENDO EN UN ARCHIVO

===================================================================



[1] Método 1: Usar lsof para filtrar directamente procesos que escriben

-------------------------------------------------------------------

Muestra únicamente la línea del proceso que tiene el archivo abierto 

en modo Escritura ('w'), Lectura/Escritura ('u') o Anexar ('a').



Comando:

lsof /ruta/al/archivo.log | grep -E ' [0-9]+[wua]'



Respuesta obtenida / PID:









-------------------------------------------------------------------



[2] Método 2: Extraer SOLO el PID del proceso que escribe (Para scripts)

-------------------------------------------------------------------

Si necesitas únicamente el número del PID para usarlo en otro comando

(por ejemplo, para monitorearlo o finalizarlo).



Comando:

lsof /ruta/al/archivo.log | grep -E ' [0-9]+[wua]' | awk '{print $2}'



Respuesta obtenida / PID:









-------------------------------------------------------------------



[3] Método 3: Usar fuser con detalle de proceso

-------------------------------------------------------------------

Muestra los PIDs que acceden al archivo y sus modos de uso 

(la letra 'f' indica descriptor abierto para lectura/escritura).



Comando:

fuser -v /ruta/al/archivo.log



Respuesta obtenida / PID:









-------------------------------------------------------------------



[4] Método 4: Auditoría de Kernel con auditd (Para escrituras rápidas)

-------------------------------------------------------------------

Útil si el proceso escribe y cierra el archivo en milisegundos.



Paso 1: Activar el rastreo de escrituras (w) y cambios de atributos (a)

sudo auditctl -w /ruta/al/archivo.log -p wa -k rastreo_escritura



Paso 2: Consultar el registro para ver qué PID ejecutó la escritura

sudo ausearch -k rastreo_escritura -i | grep -E 'pid='



Respuesta obtenida / PID:









===================================================================


===================================================================

 GUÍA PARA CERRAR O REDIRIGIR UN DESCRIPTOR DE ARCHIVO POR PID

===================================================================



[PREPARACIÓN] Obtener el número de File Descriptor (FD)

-------------------------------------------------------------------

Antes de aplicar cualquiera de los métodos, debes conocer el número 

de FD exacto (ejemplo: 3, 4, 5) usando lsof o ls:



Comandos de consulta:

lsof -p <PID> | grep /ruta/al/archivo

ls -l /proc/<PID>/fd



Ejemplo de salida de FD: "3w" -> El FD es el número 3.









===================================================================

 MÉTODO 1: Vaciar/Truncar el archivo a 0 bytes (El más seguro)

===================================================================

Descripción: No cierra el FD pero libera de inmediato el espacio en disco

sin afectar el proceso ni requerir utilidades externas.



Comando:

> /proc/<PID>/fd/<FD>



Ejemplo (para PID 1234 y FD 3):

> /proc/1234/fd/3









===================================================================

 MÉTODO 2: Redirigir el FD a /dev/null usando gdb (Recomendado)

===================================================================

Descripción: Redirige las lecturas/escrituras hacia /dev/null sin destruir 

el descriptor. Evita que la aplicación falle por un error EBADF.



Comando ordenado (ejecutar en un solo bloque):

gdb -p <PID> --batch \

  -ex 'call (int) open("/dev/null", 2)' \

  -ex 'call (int) dup2($1, <FD>)' \

  -ex 'call (int) close($1)' \

  -ex 'detach' \

  -ex 'quit'



Ejemplo (para PID 1234 y FD 3):

gdb -p 1234 --batch \

  -ex 'call (int) open("/dev/null", 2)' \

  -ex 'call (int) dup2($1, 3)' \

  -ex 'call (int) close($1)' \

  -ex 'detach' \

  -ex 'quit'









===================================================================

 MÉTODO 3: Cerrar el FD por completo usando gdb

===================================================================

Descripción: Invoca directamente la función close() en la memoria del 

proceso. Usar con cuidado si la aplicación no soporta la pérdida del FD.



Comando en modo consola interactiva de gdb:

1. Conectarse al proceso:

   sudo gdb -p <PID>



2. Dentro del prompt de (gdb), ejecutar:

   p close(<FD>)



3. Desconectarse manteniendo el proceso vivo:

   detach

   quit



O equivalente en una sola línea no interactiva (ejemplo PID 1234 y FD 3):

sudo gdb -p 1234 --batch -ex 'call close(3)' -ex 'detach' -ex 'quit'









===================================================================

 REVISIÓN FINAL / VERIFICACIÓN

===================================================================

Comando para confirmar que el descriptor fue cerrado o redirigido:



ls -l /proc/<PID>/fd/<FD>

===================================================================