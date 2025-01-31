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

# Remove default Nginx configuration
# sudo rm /etc/nginx/sites-enabled/default


# # Create the Nginx site configuration for Jenkins
# echo "server {
#     listen 80;
#     server_name jenkins.csye7125.xyz;

#     location / {
#         proxy_pass http://127.0.0.1:8080;
#         proxy_set_header Host \$host;
#         proxy_set_header X-Real-IP \$remote_addr;
#         proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
#         proxy_set_header X-Forwarded-Proto \$scheme;
#         proxy_redirect off;
#     }
# }" > /etc/nginx/sites-available/jenkins

# # Enable the site by creating a symbolic link
# sudo ln -s /etc/nginx/sites-available/jenkins /etc/nginx/sites-enabled/

# Restart Nginx to apply changes
sudo systemctl restart nginx

echo "Jenkins Nginx configuration has been applied successfully."

