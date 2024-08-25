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
        KUBECONFIG = 'f2c5bce3-a853-4e69-a7f6-952dc2b09144'
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