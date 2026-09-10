Description: Common directory-listing tools on this host are missing or refuse to run. A document named shosoin.tag was misplaced somewhere under /home/admin/records.

Write its full absolute path (one line) to /home/admin/solution.txt, for example: echo "/home/admin/records/some/dir/shosoin.tag" > /home/admin/solution.txt

NOTE: There are at least 9 different ways to find the solution in this server (shown in the clues).

Root (sudo) Access: True

Test: md5sum /home/admin/solution.txt returns 8d3b739ebccb41c7c39e608d7a3e0bd6 (the solution without the trailing newline is also accepted).


find . -name "shosoin.tag"

find /home/admin/records -name "shosoin.tag"

Guardar la ruta absoluta de un archivo específico:
Bash

find $PWD -name "settings.py" > lista_archivos.txt

-> find no anda en este sistema

#!/usr/bin/env python3
import os
import sys

def buscar_archivos(directorio_base, termino_busqueda, archivo_salida="solution.txt"):
    """
    Busca de forma recursiva archivos que contengan 'termino_busqueda' en su nombre
    y guarda la ruta absoluta (full path) de cada coincidencia en 'archivo_salida'.
    """
    directorio_base = os.path.abspath(directorio_base)
    rutas_encontradas = []

    print(f"Buscando '{termino_busqueda}' en: {directorio_base} ...")

    # Recorrido recursivo de carpetas
    for raiz, _, archivos in os.walk(directorio_base):
        for archivo in archivos:
            # Comprueba si el término está en el nombre del archivo
            # Se puede usar, archivo == termino_busqueda ,para que busque exactamente el nombre del archivo
            if termino_busqueda.lower() in archivo.lower():
                ruta_completa = os.path.join(raiz, archivo)
                rutas_encontradas.append(ruta_completa)

    # Guardar en el archivo de texto
    with open(archivo_salida, "w", encoding="utf-8") as f:
        for ruta in rutas_encontradas:
            f.write(ruta + "\n")

    print(f"¡Listo! Se encontraron {len(rutas_encontradas)} resultado(s).")
    print(f"Rutas guardadas en: {os.path.abspath(archivo_salida)}")

if __name__ == "__main__":
    # Parámetros por consola opcionales:
    # Uso: python3 buscar.py [termino] [directorio]
    termino = sys.argv[1] if len(sys.argv) > 1 else "shosoin.tag"
    directorio = sys.argv[2] if len(sys.argv) > 2 else "/home/admin/records"

    buscar_archivos(directorio, termino)


Reporte:
Basicamente otra forma que tenemos de buscar archivo como alternativa a find, es usando python que es bastante amigable, por lo que vimos este script nos sirve para buscar archivos de forma recursiva indicando el archivo y el nombre del directorio donde pondemos empezar la busqueda 