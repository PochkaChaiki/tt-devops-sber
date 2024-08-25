


## Install jenkins.
1. Install Jenkins repo:
```
helm repo add jenkins https://charts.jenkins.io
helm repo update
```

2. Configure serviceAccount field in jenkins:
```
wget https://raw.githubusercontent.com/jenkinsci/helm-charts/main/charts/jenkins/values.yaml
```
Add next lines to values.yaml:
```
serviceType: NodePort
nodePort: 32000
```
```
serviceAccount:
  create: false
name: jenkins
annotations: {}
```

3. Install jenkins helm chart and deploy jenkins:
```
helm upgrade --install jenkins jenkins/jenkins --create-namespace -n jenkins --set controller.image.repository="pochkachaiki/jenkins-k8s-helm" --set controller.image.tag="latest" --set controller.image.tagLabel="" -f values.yaml
helm install jenkins jenkins/jenkins --create-namespace -n jenkins -f values.yaml 
```

4. Configure permissions:
```
wget https://raw.githubusercontent.com/jenkins-infra/jenkins.io/master/content/doc/tutorials/kubernetes/installing-jenkins-on-kubernetes/jenkins-sa.yaml

kubectl apply -f jenkins-sa.yaml
```

5. Get admin password and get the Jenkins URL:
```
# Wait some time before running this commands because containers mignt not be created by your current moment
# you can remove "&& echo" if using windows:
kubectl exec -n jenkins -it svc/jenkins -c jenkins -- /bin/cat /run/secrets/additional/chart-admin-password && echo 
```

Run this to port forward to enter jenkins admin ui
```
kubectl --namespace jenkins port-forward svc/jenkins 8080:8080
```
6. Set kubernetes service account credentials
To run pipeline that deploys nginx in same cluster you should provide jenkins with your Kubernetes Service Account credentials.
Go to "Manage Jenkins" -> "Credentials" -> Click on "(global)" domain -> Click "Add credentials" in top right corner
In field "Kind" choose "Kubernetes Service Account" and scope keep Global. Click on "Create".
Save credentials ID and move on.

7. Add Kubernetes CLI plugin
Go to "Manage Jenkins" -> "Plugins" -> Click "Available plugins" and write "Kubernetes CLI" to search field -> Install plugin.


8. Create pipeline
Go to Dashboard. Click on "Create a job" or "New Item".
Name it "nginx-job" or whatever you like. Choose "Pipeline" as an item type and click "Ok".


6. Run this commands to copy kube config file to jenkins pod so that jenkins could deploy nginx chart on present minikube cluster
```
kubectl exec -n jenkins -it svc/jenkins -- mkdir -p /var/jenkins_home/.kube
kubectp cp -n jenkins *<kube config file path>* *<jenkins pod name>*:/var/jenkins_home/.kube
```


EkQY6fZtTX5wiUHytBb190


83cce988-6d65-48d2-8ceb-e165acca127e