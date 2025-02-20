#!/bin/bash
set -ex # Exit on any command failure
sudo apt-get upgrade -y
sudo apt-get update -y

# Install nginx
sudo apt-get install nginx -y
sudo systemctl status nginx

# Install Java
sudo apt install fontconfig openjdk-17-jre -y

# Install Jenkins
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key

echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt-get update -y
sudo apt-get install jenkins -y

# Set up Jenkins service
sudo systemctl start jenkins
sudo systemctl enable jenkins
sudo systemctl status jenkins

# Change nginx config and restart nginx to setup reverse proxy for jenkins
sudo mv /tmp/jenkins.conf /etc/nginx/conf.d/jenkins.conf
sudo systemctl daemon-reload
sudo systemctl restart nginx
sudo systemctl status nginx

# Install Terraform 
wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform -y

# # Setup jenkins plugins
# wget https://github.com/jenkinsci/plugin-installation-manager-tool/releases/download/2.12.13/jenkins-plugin-manager-2.12.13.jar

# cat << 'EOF' > jenkins_plugins.sh
# #!/bin/bash
# while IFS= read -r plugin
# do
#     echo "Installing plugin: $plugin..."
#     sudo java -jar jenkins-plugin-manager-2.12.13.jar --war /usr/share/java/jenkins.war --plugin-download-directory /var/lib/jenkins/plugins --plugins "$plugin"
# done < /home/ubuntu/jenkins_plugins.txt
# EOF

# chmod +x jenkins_plugins.sh

# sudo ./jenkins_plugins.sh

# setup jenkins scripts
sudo mkdir -p /var/lib/jenkins/init.groovy.d/
sudo mv /tmp/initial-setup.groovy /var/lib/jenkins/init.groovy.d/

# Copy secrets
sudo mkdir -p /var/lib/jenkins/secrets/
sudo mv /tmp/github_username /var/lib/jenkins/secrets/
sudo mv /tmp/github_password /var/lib/jenkins/secrets/
sudo mv /tmp/docker_username /var/lib/jenkins/secrets/
sudo mv /tmp/docker_password /var/lib/jenkins/secrets/

#copy job scripts
sudo mkdir -p /var/lib/jenkins/jobs/
sudo mv /tmp/infra-status-check.groovy /var/lib/jenkins/jobs/
sudo mv /tmp/static-site-image.groovy /var/lib/jenkins/jobs/
# sudo mv /tmp/pr-commit-validation-check.groovy /var/lib/jenkins/jobs/

# Update JCasC.yaml
sudo mkdir -p /var/lib/jenkins/casc_configs
sudo mv /tmp/JCasC.yaml /var/lib/jenkins/casc_configs/
sudo chown -R jenkins:jenkins /var/lib/jenkins/

# update the default jenkins config file path
echo 'CASC_JENKINS_CONFIG=/var/lib/jenkins/casc_configs/JCasC.yaml' | sudo tee -a /etc/environment
source /etc/environment

sudo sed -i 's/\(JAVA_OPTS=-Djava\.awt\.headless=true\)/\1 -Djenkins.install.runSetupWizard=false/' /lib/systemd/system/jenkins.service
sudo sed -i '/Environment="JAVA_OPTS=-Djava.awt.headless=true -Djenkins.install.runSetupWizard=false"/a Environment="CASC_JENKINS_CONFIG=/var/lib/jenkins/casc_configs/JCasC.yaml"' /lib/systemd/system/jenkins.service

# Restart Jenkins
sudo systemctl daemon-reload
sudo systemctl restart jenkins
sudo journalctl -u jenkins --no-pager | tail -n 100
# sudo systemctl restart jenkins

# Install  Let's Encrypt certbot
# sudo apt install certbot python3-certbot-nginx -y
sudo snap install --classic certbot
sudo ln -s /snap/bin/certbot /usr/bin/certbot

# Install Docker
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
sudo systemctl enable docker
sudo systemctl start docker

#Add the Jenkins user to docker group. this will allow jenkins to run docker commands without sudo
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins


echo "Jenkins Nginx configuration has been applied successfully."

