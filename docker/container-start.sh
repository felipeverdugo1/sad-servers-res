


admin@i-0297da63670e8f081:~/app$ cat Dockerfile 
# documentation https://nodejs.org/en/docs/guides/nodejs-docker-webapp/

# most recent node (security patches) and alpine (minimal, adds to security, possible libc issues)
FROM node:15.7-alpine

# Create app directory & copy app files
WORKDIR /usr/src/app

# we copy first package.json only, so we take advantage of cached Docker layers
COPY ./package*.json ./

# RUN npm ci --only=production
RUN npm install

# Copy app source
COPY ./* ./

# port used by this app
EXPOSE 8880

# command to run
CMD [ "node", "serve.js" ]


admin@i-0297da63670e8f081:~/app$ docker run -d -p 8888:8880 --name mi-node-app  node:15.7-alpine
ba8f7e7263d4b8de9c2a640ac0f8f43cd904e789c2bf5e31043746a6a8de25e6
docker: Error response from daemon: failed to set up container networking: driver failed programming external connectivity on endpoint mi-node-app (61eb533c41fbb035da66b49cde5ccd9c80c663127efb6c5dd240df237c37a96a): failed to bind host port 0.0.0.0:8888/tcp: address already in use


sudo lsof -i :8888 

importante el sudo 

nginx   819     root 5u  IPv4   5961      0t0  TCP *:8888 (LISTEN)
nginx   819     root 6u  IPv6   5962      0t0  TCP *:8888 (LISTEN)
nginx   823 www-data 5u  IPv4   5961      0t0  TCP *:8888 (LISTEN)
nginx   823 www-data 6u  IPv6   5962      0t0  TCP *:8888 (LISTEN)
nginx   824 www-data 5u  IPv4   5961      0t0  TCP *:8888 (LISTEN)
nginx   824 www-data 6u  IPv6   5962      0t0  TCP *:8888 (LISTEN)

docker build -t mi-app-node .

Cambiamos el expose al puerto que nos pedian, para que quede actualizado

docker rm -f mi-node-app
docker run -d -p 8888:8888 --name mi-node-app mi-app-node


Reporte: Nos dieron una app web con node que estaba dockertizada y nos pedian levantarla con un container y hacerle un curl a 8888
lo primero fue berificar los puertos y en ese estaba nginx pero no lo necesitamos a si que lo bajamos, luego hicimos correcciones en el dockerfile con el puerto y una falta en el archivo que lo pudimos ver gracias al log docker logs mi-node-app, y luego ejecutamos el contenedor con la imagen antes buildeada


