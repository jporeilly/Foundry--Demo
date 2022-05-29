## <font color='red'>Visualize and Monitoring your Mesh</font>  

The following services are exposed in the Foundry Platform. 
* Kiali
* Prometheus
* Grafana
* Elasticsearch & Kibana
* Jaeger
* Zipkin
* Swagger

These following tools will help troubleshoot and monitor k8s deployment.

* Kubernetes Dashboard
* Portainer

> For a list of useful Kubernetes tools: https://collabnix.github.io/kubetools/

To display a list of exposed services in the istio-system:

``list of istio services (Ansible Controller):``
```
kgsvc -n istio-system
```
Note the ports.

---

#### <font color='red'>Kiali</font>  

Kiali is an observability console for Istio with service mesh configuration and validation capabilities. It helps you understand the structure and health of your service mesh by monitoring traffic flow to infer the topology and report errors. Kiali provides detailed metrics and a basic Grafana integration, which can be used for advanced queries. Distributed tracing is provided by integration with Jaeger.

``check Kiali service:``
```
kubectl get svc kiali -n istio-system 
```
Note: its exposed on the default port: 20001  

``using kubectl to port-forward:``
```
kubectl port-forward svc/kiali 20001:20001 -n istio-system
```
> browse to: https://localhost:20001/ 

User: admin  
Password: admin

Please note that this method exposes Kiali only to the local machine, no external users. You must have the necessary privileges to perform port forwarding.

You could patch and externally expose the service.  Only do this if you know what you're doing.. :)
```
kubectl patch svc kiali -n istio-system -p '{"spec": {"type": "NodePort"}}'
```

* You can visualize the services and their connections in a given namespace by clicking on the “Go To Graph” button.

> For further details: https://kiali.io/docs/

---

#### <font color='red'>Prometheus</font>  

Prometheus is an open-source systems monitoring and alerting toolkit. Prometheus collects and stores its metrics as time series data, i.e. metrics information is stored with the timestamp at which it was recorded, alongside optional key-value pairs called labels.

``check Prometheus service:``
````
kubectl get svc prometheus -n istio-system 
````
``using kubectl to port-forward:``
```
kubectl port-forward -n istio-system  svc/prometheus 9090:9090 
```
> browse to: https://localhost:9090

* navigate to: Status --> Targets

> For further details: https://prometheus.io/

---

#### <font color='red'>Grafana</font>  

Grafana is an open source solution for running data analytics, pulling up metrics that make sense of the massive amount of data & to monitor our apps with customizable dashboards.  
Grafana connects with every possible data source, commonly referred to as databases such as Graphite, Prometheus, Influx DB, ElasticSearch, MySQL, PostgreSQL etc.

``check Grafana service:``
```
kubectl get svc -n hitachi-solutions 
```
Note: look for anything grafana

> browse to: https://pentaho-server-1.skytap.example/hitachi-solutions/metrics-addon-solution/metrics-addon-solution-grafana/login

User: admin
Password: mypassword

``to retrieve the password:``
```
kubectl get secret -n hitachi-solutions metrics-addon-solution-grafana -o jsonpath="{.data.admin-password}" | base64 --decode
```

> For further details: https://grafana.com/

---

#### <font color='red'>Elasticsearch & Kibana</font>

Elasticsearch is the distributed search and analytics engine at the heart of the Elastic Stack. Logstash and Beats facilitate collecting, aggregating, and enriching your data and storing it in Elasticsearch. Kibana enables you to interactively explore, visualize, and share insights into your data and manage and monitor the stack. Elasticsearch is where the indexing, search, and analysis happens.

Kibana is a visual interface tool that allows you to explore, visualize, and build a dashboard over the log data massed in Elasticsearch Clusters.

``check Kibana service:``
```
kubectl get svc -n hitachi-solutions 
```
Note: look for anything kibana

> browse to: https://pentaho-server-1.skytap.example/hitachi-solutions/hscp-hitachi-solutions/kibana/app/kibana

You will need to 'Discover' your data and enter an 'Index pattern': ``hitachi-solutions.*`` 

> For further details: https://www.elastic.co/kibana/

---

#### <font color='red'>Jaeger</font>  

Jaeger tracing system for microservices, and it supports the OpenTracing standard.
``check Jaeger service:``
```
kubectl get svc jaeger-query -n istio-system 
```
Note: its exposed on the default port: 16686  

``using kubectl to port-forward:``
```
kubectl port-forward -n istio-system svc/jaeger-query 16686:16686
```

> browse to: http://localhost:16686/jaeger/search

> For further details: https://www.jaegertracing.io/

---

#### <font color='red'>Zipkin</font>  

Zipkin is a distributed tracing system. It helps gather timing data needed to troubleshoot latency problems in service architectures.
``check Zipkin service:``
```
kubectl get svc zipkin -n istio-system
```
Note: its exposed on the default port: 9411  

``using kubectl to port-forward:``
```
kubectl port-forward -n istio-system svc/zipkin 9411:9411
```

> browse to: https://localhost:9411/jaeger/search

> For further details: https://www.jaegertracing.io/

---

#### <font color='red'>Swagger</font>  

The Swagger Editor is an open source editor to design, define and document RESTful APIs in the Swagger Specification. The source code for the Swagger Editor can be found in GitHub.

> browse to: https://pentaho-server-1.skytap.example/hitachi-solutions/hscp-hitachi-solutions/swagger-ui/ui/doc/

> For further details: https://github.com/swagger-api/swagger-editor

---

#### <font color='red'>Kubernetes Dashboard</font>  

Dashboard is a web-based Kubernetes user interface. You can use Dashboard to deploy containerized applications to a Kubernetes cluster, troubleshoot your containerized application, and manage the cluster resources. You can use Dashboard to get an overview of applications running on your cluster, as well as for creating or modifying individual Kubernetes resources (such as Deployments, Jobs, DaemonSets, etc).  

``access dashboard:``
```
kubectl proxy
```
Note: Kubectl proxy is the recommended way of accessing the Kubernetes REST API. It uses http for the connection between localhost and the proxy server and https for the connection between the proxy and apiserver.  

> browse to: http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/

* select Token method of authentication.

The token authentication method requires a service account for the Kubernetes dashboard. 
* bind this service account to the cluster-admin role to gain access.
* retrieve the secret for the role.
* use the bearer token for the service account to log in to the dashboard.

``create a service account:``
```
kubectl create serviceaccount dashboard-admin-sa
```
``bind the dashboard-admin-service-account service account to the cluster-admin role:``
```
kubectl create clusterrolebinding dashboard-admin-sa --clusterrole=cluster-admin --serviceaccount=default:dashboard-admin-sa
```
``retrieve the secret for the service account:``
```
kubectl get secrets (alias: kgsec)
```
Note: the secret will be in the format: dashboard-admin-sa-token-xxxx  

``describe the token:``
```
kubectl describe secret dashboard-admin-sa-token-xxxx
```
* copy the token over to the login page.

> For further details: https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/

---

#### <font color='red'>Portainer</font>

Portainer is a lightweight UI manager for docker which can be used to manage different docker environments such as docker hosts or docker swarm clusters. 


<em>Helm</em>

``check default StorageClass:`
```
kubectl get sc
```
``install repository:``
```
helm repo add portainer https://portainer.github.io/k8s/
helm repo update
```
``install portainer:``
```
helm install --create-namespace -n portainer portainer portainer/portainer
```
``run the 3 commands:``
```
export NODE_PORT=$(kubectl get --namespace portainer -o jsonpath="{.spec.ports[1].nodePort}" services portainer)
export NODE_IP=$(kubectl get nodes --namespace portainer -o jsonpath="{.items[0].status.addresses[0].address}")
echo https://$NODE_IP:$NODE_PORT
```
Note: Copy and paste the URL into your browser.

> browse to: https://$NODE_IP:30779

``create initial administrator account:``
* Username: portainer       
* Password: lumada2022

Note: By default, Portainer generates and uses a self-signed SSL certificate to secure port 30779 or http on 30777. 


---

<em>Add a Docker endpoint</em>

This will enable you to manage your local docker deployment.

``configure portainer_agent:``
```
sudo docker run -d -p 9001:9001 --name=portainer_agent --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v /var/lib/docker/volumes:/var/lib/docker/volumes portainer/agent
```
* in Portainer UI --> Endpoints --> Agent
* name: DockerOnly
* URL: 10.x.x.x.
* Add Endpoint

You can now manage both Kubernetes and local Docker instance.

---