variable "region" {
  type = string
  default = "us-east-1"
}
variable "ami_users" {
  type    = list(string)
  default = ["418295703729`"] // root user Account Id
}
variable "instance_type" {
  type = string
  default = "t2.micro"
}
variable "source_ami" {
  type = string
  default = "ami-04b4f1a9cf54c11d0"
}

variable "ssh_username" {
  type = string
  default = "ubuntu"
}
variable "nginx_config_path" {
  type = string
  default = "../nginx/jenkins.conf"
}