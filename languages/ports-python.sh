Type: Do

Tags: python  

Access: Email

Description: A Python app serving simulated bank data runs as root and listens on port 20280. The app is managed by supervisor and cannot be stopped or reconfigured to use a different port.

An internal legacy monitoring system expects the service to be available on port 80, but the app is hardcoded to 20280 for security and legacy reasons. Your task is to make the service accessible on port 80 locally.

Root (sudo) Access: True

Test: curl localhost:80/accounts returns [{"id":1,"name":"Alice","type":"Checking"},{"id":2,"name":"Bob","type":"Savings"},{"id":3,"name":"Charlie","type":"Business"}]

The "Check My Solution" button runs the script /home/admin/agent/check.sh, which you can see and execute.

Time to Solve: 10 minutes.


sudo supervisorctl status

bank_app                         RUNNING   pid 1018, uptime 0:02:28



sudo iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-ports 20280
sudo iptables -t nat -A OUTPUT -p tcp -o lo --dport 80 -j REDIRECT --to-ports 20280

Retorte: Al tener la app de python el puerto harcodeado, lo que hicimos fue hacer un proxy inverso como mi fuera nginx y todo lo que entra por el puerto 80 lo mandamos al 20280