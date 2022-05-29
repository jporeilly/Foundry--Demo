## <font color='red'>Deploy Hitachi Vantara Foundry Platform 2.3</font>

Hitachi Foundry is a framework for the rapid development, curation, and management of service-oriented software solutions.
Foundry makes it easy for developers to build and share custom capabilities, and simple for customers to flexibly deploy and manage them.

* Hitachi Vantara Employees:
Download the [Hitachi Vantara Foundry Platform 2.3](https://repo.wal.eng.hitachivantara.com/ui/native/foundry-generic-release/2.3.0) images and Charts.  


* Deploy OpenEBS storageclass
* Local Docker Registry

* Deploy Cluster Services
* Deploy Custom Resource Definitions
* Deploy Solution Control Plane 

---


<em>Deploy OpenEBS Storage Class</em>

OpenEBS is a cloud native storage project originally created by MayaData that build on a Kubernetes cluster and allows Stateful applications to access Dynamic Local PVs and/or replicated PVs. OpenEBS runs on any Kubernetes platform and uses any Cloud storage solution including AWS s3, GKE and AKS.  
Its is not recommended for production environments.

``check default storage class:``
```
kubectl get sc
```
Note: the default is set to 'local-path'.

``add helm openEBS chart:``
```
helm repo add openebs https://openebs.github.io/charts
helm repo update
```
``create openebs namespace:``
```
kubectl create ns openebs
```
``deploy openEBS:``
```
helm install --namespace openebs openebs openebs/openebs
```
``check the status:``
```
kubectl get pods -n openebs
```
``patch storageclass to set as default:``
```
kubectl patch storageclass openebs-hostpath -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
```
Note: Only have storageclass set as default.
``patch 'local-path' storageclass:``
```
kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
```
``verify class set as default:``
```
kubectl get sc | grep default
```
Note: the openebs-hostpath is set as default.

---

<em>Docker Registry</em>

An OCI-compatible container image registry with an SSL certificate is required. Authentication credentials are also recommended.
When deploying both cluster services and the control plane, the fully qualified domain name of this registry must be specified, either using the -r argument or the installer config file. The value you specify needs to include both the host and port for your registry. For example:

``-r myregistry.example.com:5000``

``login into the Registry:``
```
docker login foundry.skytap.example:5000
Username: admin
Password: password
```

---

<em>Deploy Cluster Services</em>

Hitachi Vantara Foundry Platform Control plane expects that the Kubernetes cluster is running with, Istio, cert-manager and has a default StorageClass defined. 

Foundry install directory has to be at least two directories deep in file system.

``create a Foundry-2.3 & Logs directory:``
```
cd
sudo mkdir Foundry-2.3
mkdir Foundry-2.3/Logs
```

``untar Foundry-2.3 directory:``
```
cd /data
tar -C ~/Foundry-2.3 -xzvf  /data/Packages/Foundry-Control-Plane-2.3.0.tgz
```

Foundry's Control plane expects that the Kubernetes cluster is running with, Istio, cert-manager and has a default StorageClass defined 

```
cd ~/Foundry-2.3
./bin/install-cluster-services.sh -I -r foundry.skytap.example:5000 -u admin -p password -D true 2>&1 | tee -a ~/Foundry-2.3/Logs/install-cluster-services-2.3.log
```

---

<em>Deploy Custom Resource Definitions</em>

From version 2.2.0 onwards, Foundry manages Custom Resource Definitions (CRDs) for the Solution Control Plane, Addons and Solutions in Helm charts, to facilitate re-use between multiple control planes.

``deploy custom-resource-definitions:``
```
cd ~/Foundry-2.3
./bin/apply-crds.sh --insecure -e -r foundry.skytap.example:5000 -u admin -p password -D true 2>&1 | tee -a ~/Foundry-2.3/Logs/apply-crds-2.3.log
```

---

<em>Deploy Solution Control-Plane</em>

``deploy solution control-plane:``
```
cd ~/Foundry-2.3
./bin/install-control-plane.sh -I -r foundry.skytap.example:5000 -u admin -p password -D true 2>&1 | tee -a ~/Foundry-2.3/Logs/install-control-plane-2.3.log
```

``log into the Control-Plane:``

  > navigate to: https://iiot-core.skytap.example:30443/hitachi-solutions/hscp-hitachi-solutions/solution-control-plane/ 


echo $(kubectl get keycloakusers -n hitachi-solutions keycloak-user -o jsonpath='{.spec.user.credentials[0].value}')


https://iiot-core.skytap.example:30443/hitachi-solutions/hscp-hitachi-solutions/solution-control-plane/ 

The default username is `keycloak` and password is `start123`