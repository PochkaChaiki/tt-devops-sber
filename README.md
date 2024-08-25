


## Install jenkins.
### 1. Install Jenkins repo:
```
helm repo add jenkins https://charts.jenkins.io
helm repo update
```


### 2. Get values to deploy Jenkins:

Use ready **jenkins-values.yaml** from this repository

<!-- Run this command:
```
wget https://raw.githubusercontent.com/jenkinsci/helm-charts/main/charts/jenkins/values.yaml
```
Add this lines to values.yaml:
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
Rename values.yaml to jenkins-values.yaml -->

### 3. Install Jenkins helm chart and deploy jenkins:
```
helm install jenkins jenkins/jenkins --create-namespace -n jenkins -f jenkins-values.yaml
```

<!-- helm upgrade --install jenkins jenkins/jenkins --create-namespace -n jenkins --set controller.image.repository="pochkachaiki/jenkins-k8s-helm" --set controller.image.tag="latest" --set controller.image.tagLabel="" -f values.yaml -->

### 4. Configure service account for Jenkins:
Use ready yaml file:
```
kubectl apply -f jenkins-sa.yaml"
```

### 5. Get admin password and get the Jenkins URL:
```
# Wait some time before running this commands because containers mignt not be created by your current moment
# you can remove "&& echo" if using windows:
kubectl exec -n jenkins -it svc/jenkins -c jenkins -- /bin/cat /run/secrets/additional/chart-admin-password && echo 
```

Run this to forward a port to enter jenkins admin ui
```
kubectl --namespace jenkins port-forward svc/jenkins 8080:8080
```

### 6. Set kubernetes service account credentials
To run pipeline that deploys nginx in same cluster you should provide jenkins with your Kubernetes Service Account credentials.

Go to "Manage Jenkins" -> "Credentials" -> Click on "(global)" domain -> Click "Add credentials" in top right corner.

In field "Kind" choose "Kubernetes Service Account" and scope keep Global. Click on "Create".
Save credentials ID and move on.

### 7. Add Kubernetes CLI plugin
Go to "Manage Jenkins" -> "Plugins" -> Click "Available plugins" and write "Kubernetes CLI" to search field -> Install plugin.

## Deploy Nginx.
### 1. Create pipeline
Go to Dashboard. Click on "Create a job" or "New Item".
Name it "nginx-job" or whatever you like. Choose "Pipeline" as an item type and click "Ok".

### 2. Define script
Come to the bottom of the page and in textfield "Script" put down this script:
```
pipeline {
    agent {
        kubernetes{
            yaml '''
            apiVersion: "v1"
            kind: "Pod"
            metadata:
                name: "jenkins-inbound-agent"
                namespace: "jenkins"
            spec:
                serviceAccountName: "jenkins"
                containers:
                  - name: "jnlp"
                    image: "pochkachaiki/inbound-agent-helm:latest"
                
            '''
        }
    }
    environment {
        KUBECONFIG = <YOUR KUBERNETES CREDENTIALS>
    }
    stages{
        stage('Get nginx chart'){
            steps{
                sh 'git config --list'
                git branch: 'main', url: 'https://github.com/PochkaChaiki/tt-devops-sber.git'
            }
        }
        stage('Deploy nginx'){
            steps{
                withKubeConfig([credentialsId: env.KUBECONFIG]){
                    sh '''
                        helm upgrade --install nginx ./nginx-chart
                    '''
                }
            }
        }
    }
}
```

### 3. Save it and run pipeline
Save this pipeline by clicking on "Save".
In nginx-job menu click on "Build Now".
After some time the pod nginx-nginx-chart will be deployed.

## Check Nginx
### 1. Forward nginx port to 80
Run this command:
```
kubectl -n jenkins port-forward svc/nginx-nginx-chart 80:80
```

### 2. Check Nginx
Go to localhost:80 and ensure nginx is running.


