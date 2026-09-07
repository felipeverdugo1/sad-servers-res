#Usando sudo en el server
# 1. Crear el grupo compartido y agregar a los cuatro usuarios
groupadd -f projectgroup
usermod -aG projectgroup abe
usermod -aG projectgroup betty
usermod -aG projectgroup carlos
usermod -aG projectgroup debora

# 2. Configurar la carpeta compartida y sus archivos habituales
# Asignamos la carpeta al grupo compartido y damos permisos 750 (rwxr-x---)
chgrp -R projectgroup /home/admin/shared
chmod 750 /home/admin/shared

# Cada usuario mantiene la propiedad de su archivo, permitiendo lectura al grupo (640)
chmod 640 /home/admin/shared/*

# 3. Configurar el archivo 'ALL' para agregar contenido (Append-only)
# Permitimos que el grupo también pueda escribir a nivel de chmod
chmod 660 /home/admin/shared/ALL

# Aplicamos el atributo extendido de solo añadir contenido
chattr +a /home/admin/shared/ALL