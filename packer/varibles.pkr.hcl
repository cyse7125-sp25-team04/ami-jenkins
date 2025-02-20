variable region {
  type    = string
  default = "us-east-1"
}
variable ami_users {
  type    = list(string)
  default = ["418295703729"] // root user Account Id
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
variable inital_jenkins_setup_path {
  type    = string
  default = "../jenkins_scripts/setup/initial-setup.groovy"
}

variable jenkins_admin_id {
  type    = string
  default = "admin"
}

variable jenkins_admin_password {
  type    = string
  default = "admin"
}

variable infra_status_check_path {
  type    = string
  default = "../jenkins_scripts/jobs/infra-status-check.groovy"
}

variable static_site_image_path {
  type    = string
  default = "../jenkins_scripts/jobs/static-site-image.groovy"
}

variable pr_validation_check_file_path {
  type    = string
  default = "../jenkins_scripts/jobs/pr-commit-validation-check.groovy"
}

variable github_username {
  type    = string
  default = "sri-vijay-kalki"
}

variable github_password {
  type = string
}

variable docker_username {
  type    = string
  default = "csye712504"
}

variable docker_password {
  type = string
}