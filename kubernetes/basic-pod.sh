Scenario: "Bilbao": Basic Kubernetes Problems

Level: Easy

Type: Fix

Tags: kubernetes  

Access: Email

Description: There's a Kubernetes Deployment with an Nginx pod and a Load Balancer declared in the manifest.yml file. The pod is not coming up. Fix it so that you can access the Nginx container through the Load Balancer.

There's no "sudo" (root) access.

TIP: You can use k as an alias for kubectl, and it has autocomplete enabled.

Root (sudo) Access: False

Test: Running curl 10.43.216.196 returns the default Nginx Welcome page.

The "Check My Solution" button runs the script /home/admin/agent/check.sh, which you can see and execute.

Time to Solve: 10 minutes	



kubectl get pods -> Muestra la lista de Pods en ejecución y su estado.

kubectl get services -> Muestra los servicios y sus puertos abiertos.

kubectl logs <nombre-del-pod> -> Muestra los logs de error de un Pod (clave para solucionar fallos).

#Muestra información detallada de qué le está pasando a un Pod (si está fallando, bajando la imagen, etc.).	
kubectl describe pod <nombre-del-pod> ->

kubectl get endpoints <nombre-del-servicio>

kubectl describe svc <nombre-del-servicio>

admin@i-0a6917d9518c39d51:~$ kubectl get pods
NAME                                READY   STATUS    RESTARTS   AGE
nginx-deployment-7c4b9dc968-m8d29   0/1     Pending   0          4d

admin@i-0a6917d9518c39d51:~$ kubectl get service
NAME            TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
kubernetes      ClusterIP      10.43.0.1       <none>        443/TCP        106d
nginx-service   LoadBalancer   10.43.216.196   10.0.0.93     80:30422/TCP   4d



------------------


apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: docker.io/library/nginx:1.27.3
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 80
        resources:
          limits:
            memory: 2000Mi
            cpu: 100m
          requests:
            cpu: 100m
            memory: 2000Mi
      nodeSelector:
        disk: ssd

---
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  selector:
    app: nginx
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
  clusterIP: 10.43.216.196
  type: LoadBalancer


  ----------------------

  Name:             nginx-deployment-7c4b9dc968-m8d29
  Namespace:        default
  Priority:         0
  Service Account:  default
  Node:             <none>
  Labels:           app=nginx
                    pod-template-hash=7c4b9dc968
  Annotations:      <none>
  Status:           Pending
  IP:               
  IPs:              <none>
  Controlled By:    ReplicaSet/nginx-deployment-7c4b9dc968
  Containers:
    nginx:
      Image:      docker.io/library/nginx:1.27.3
      Port:       80/TCP
      Host Port:  0/TCP
      Limits:
        cpu:     100m
        memory:  2000Mi
      Requests:
        cpu:        100m
        memory:     2000Mi
      Environment:  <none>
      Mounts:
        /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-8jpsr (ro)
  Conditions:
    Type           Status
    PodScheduled   False 
  Volumes:
    kube-api-access-8jpsr:
      Type:                    Projected (a volume that contains injected data from multiple sources)
      TokenExpirationSeconds:  3607
      ConfigMapName:           kube-root-ca.crt
      ConfigMapOptional:       <nil>
      DownwardAPI:             true
  QoS Class:                   Guaranteed
  Node-Selectors:              disk=ssd
  Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                               node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
  Events:
    Type     Reason            Age                  From               Message
    ----     ------            ----                 ----               -------
    Warning  FailedScheduling  4d                   default-scheduler  0/1 nodes are available: 1 node(s) didn't match Pod's node affinity/selector. preemption: 0/1 nodes are available: 1 Preemption is not helpful for scheduling.
    Warning  FailedScheduling  34s (x2 over 5m34s)  default-scheduler  0/1 nodes are available: 1 node(s) didn't match Pod's node affinity/selector. preemption: 0/1 nodes are available: 1 Preemption is not helpful for scheduling.


#Para resetar la config
kubectl apply -f tu_archivo.yaml

Reporte: Tuvimos que modificar el archivo manifest.yml ya que requeria que el pod este bajo ssd y 2gb de ram, por lo cual comentando la parte del ssd y cambiando a 256mb, y aplicando los cambios ya el pod estaba running

  