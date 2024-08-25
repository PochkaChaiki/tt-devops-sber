FROM jenkins/jenkins:lts    

USER root

# Install Docker, kubectl and helm
RUN apt-get -qq update && \
    apt-get -qq -y install curl && \
    jenkins-plugin-cli --plugin kubernetes-cli:1.12.1 \
    curl -sSL https://get.docker.com/ | sh && \
    curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && \
    chmod +x ./kubectl && \
    mv ./kubectl /usr/local/bin/kubectl && \
    curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get | bash