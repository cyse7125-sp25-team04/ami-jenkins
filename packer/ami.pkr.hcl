#Add aws plugin for packer
packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1"
    }
  }
}

source "amazon-ebs" "ami-nginx-jenkins" {
  region          = "${var.region}"
  ami_name        = "jenkins-ami-${formatdate("YYYY-MM-DD-hh-mm-ss", timestamp())}"
  ami_description = "ami for jenkins instance"
  ami_users       = "${var.ami_users}"
  instance_type   = "${var.instance_type}"
  source_ami      = "${var.source_ami}"
  profile         = "csye7125-root"
  ssh_username    = "${var.ssh_username}"
}

build {
  sources = [
    "source.amazon-ebs.ami-nginx-jenkins"
  ]
  provisioner "file" {
    source      = "${var.nginx_config_path}"
    destination = "/tmp/jenkins.conf"
  }

  provisioner "file" {
    source      = "jenkins_plugins.txt"
    destination = "jenkins_plugins.txt"
  }

  provisioner "file" {
    source      = "${var.inital_jenkins_setup_path}"
    destination = "/tmp/initial-setup.groovy"
  }

  provisioner "shell" {
    inline = [
      "echo 'ADMIN_ID=${var.jenkins_admin_id}' | sudo tee /etc/jenkins.env",
      "echo 'ADMIN_PASSWORD=${var.jenkins_admin_password}' | sudo tee -a /etc/jenkins.env"
    ]
  }
  provisioner "shell" {
    script = "./scripts/setup-jenkins-ngnix.sh"
  }
}