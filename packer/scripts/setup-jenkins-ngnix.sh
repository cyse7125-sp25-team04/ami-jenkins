#!/bin/bash
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

# Setup jenkins plugins
wget https://github.com/jenkinsci/plugin-installation-manager-tool/releases/download/2.12.13/jenkins-plugin-manager-2.12.13.jar

cat << 'EOF' > jenkins_plugins.sh
#!/bin/bash
while IFS= read -r plugin
do
    echo "Installing plugin: $plugin..."
    sudo java -jar jenkins-plugin-manager-2.12.13.jar --war /usr/share/java/jenkins.war --plugin-download-directory /var/lib/jenkins/plugins --plugins "$plugin"
done < /home/ubuntu/jenkins_plugins.txt
EOF

chmod +x jenkins_plugins.sh

sudo ./jenkins_plugins.sh

# Install  Let's Encrypt certbot
# sudo apt install certbot python3-certbot-nginx -y
sudo snap install --classic certbot
sudo ln -s /snap/bin/certbot /usr/bin/certbot

# Start Jenkins
sudo systemctl enable jenkins
sudo systemctl start jenkins
sudo systemctl status jenkins

# Change nginx config and restart nginx to setup reverse proxy for jenkins
sudo mv /tmp/jenkins.conf /etc/nginx/conf.d/jenkins.conf
sudo systemctl daemon-reload
sudo systemctl restart nginx
sudo systemctl status nginx

# Restart Nginx to apply changes
sudo systemctl restart nginx

echo "Jenkins Nginx configuration has been applied successfully."

