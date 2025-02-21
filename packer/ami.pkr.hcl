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
    source      = "../jenkins/configuration/JCasC.yaml"
    destination = "/tmp/JCasC.yaml"
  }

  provisioner "file" {
    source      = "jenkins_plugins.txt"
    destination = "jenkins_plugins.txt"
  }

  provisioner "file" {
    source      = "${var.inital_jenkins_setup_path}"
    destination = "/tmp/initial-setup.groovy"
  }

  provisioner "file" {
    source      = "${var.infra_status_check_path}"
    destination = "/tmp/infra-status-check.groovy"
  }

  provisioner "file" {
    source      = "${var.static_site_image_path}"
    destination = "/tmp/static-site-image.groovy"
  }

  provisioner "file" {
    source      = "${var.pr_check_file_path}"
    destination = "/tmp/pr-validation-status-check.groovy"
  }
  provisioner "file" {
    source      = "${var.build_go_application_image_path}"
    destination = "/tmp/build-go-application-image.groovy"
  }
  provisioner "file" {
    source      = "${var.build_flyway_processor_image_path}"
    destination = "/tmp/build-flyway-processor-image.groovy"
  }

  provisioner "shell" {
    inline = [
      "echo 'ADMIN_ID=${var.jenkins_admin_id}' | sudo tee /etc/jenkins.env",
      "echo 'ADMIN_PASSWORD=${var.jenkins_admin_password}' | sudo tee -a /etc/jenkins.env",
      "echo '${var.github_username}' | sudo tee /tmp/github_username",
      "echo '${var.github_password}' | sudo tee /tmp/github_password",
      "echo '${var.docker_username}' | sudo tee /tmp/docker_username",
      "echo '${var.docker_password}' | sudo tee /tmp/docker_password"
    ]
  }
  provisioner "shell" {
    script = "./scripts/setup-jenkins-ngnix.sh"
  }
}