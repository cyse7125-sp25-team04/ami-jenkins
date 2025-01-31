# Packer Configuration for Jenkins AMI

This repository contains a **Packer** configuration to build an **Amazon Machine Image (AMI)** with **Jenkins** and **Nginx** pre-installed. The setup provisions an EC2 instance, installs the required software, configures Jenkins plugins, and sets up a reverse proxy using Nginx.

## Prerequisites
Before running the Packer build, ensure you have the following installed:

- [Packer](https://developer.hashicorp.com/packer/)
- AWS CLI configured with appropriate credentials
- A valid AWS account with permissions to create AMIs
- SSH access to the instance

## Packer Commands
Run the following commands in the **packer** directory:

```sh
cd packer
```

1. **Initialize Packer plugins:**
   ```sh
   packer init .
   ```
2. **Validate the Packer template:**
   ```sh
   packer validate .
   ```
3. **Build the AMI using Packer:**
   ```sh
   packer build .
   ```

## Packer Configuration Overview

### `packer.pkr.hcl`
This file defines the Packer configuration for creating the Jenkins AMI using the **Amazon EBS** builder.

#### Plugins
Packer requires the **Amazon plugin** to build the AMI:
```hcl
packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1"
    }
  }
}
```

#### AMI Build Configuration
Defines the **source AMI**, **instance type**, **region**, and other parameters:
```hcl
source "amazon-ebs" "ami-nginx-jenkins" {
  region          = "${var.region}"
  ami_name        = "jenkins-ami-${formatdate("YYYY-MM-DD-hh-mm-ss", timestamp())}"
  ami_description = "AMI for Jenkins instance"
  ami_users       = "${var.ami_users}"
  instance_type   = "${var.instance_type}"
  source_ami      = "${var.source_ami}"
  profile         = "csye7125-root"
  ssh_username    = "${var.ssh_username}"
}
```

#### Provisioners
Provisioners install software and configure Jenkins with plugins:
```hcl
provisioner "file" {
  source      = "${var.nginx_config_path}"
  destination = "/tmp/jenkins.conf"
}

provisioner "file" {
  source      = "jenkins_plugins.txt"
  destination = "jenkins_plugins.txt"
}

provisioner "shell" {
  script = "./scripts/setup-jenkins-ngnix.sh"
}
```
## `jenkins.conf` File
This file contains the Nginx configuration for the Jenkins instance.
- Replace jenkins.csye7125.xyz with your domain configuration

## `setup-jenkins-nginx.sh` Script
This script:
- Installs **Nginx**, **Java**, and **Jenkins**
- Configures **Jenkins plugins**
- Sets up **Let's Encrypt Certbot** for SSL
- Configures **Nginx** as a reverse proxy
- Starts **Jenkins** and **Nginx**

## Variables (`variables.pkr.hcl`)
Define required parameters for Packer:
```hcl
variable region {
  type    = string
  default = "us-east-1"
}
variable ami_users {
  type    = list(string)
  default = ["418295703729"]
}
variable instance_type {
  type    = string
  default = "t2.micro"
}
variable source_ami {
  type    = string
  default = "ami-04b4f1a9cf54c11d0"
}
variable ssh_username {
  type    = string
  default = "ubuntu"
}
variable nginx_config_path {
  type    = string
  default = "../nginx/jenkins.conf"
}
```

## Running the AMI
Once the Packer build is complete, the new AMI can be used to launch EC2 instances with Jenkins and Nginx pre-configured.
