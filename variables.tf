variable "region" {
  description = "AWS region."
  default     = "ap-southeast-2"
}

variable "ami" {
  description = "AMI image used to create an EC2 instance."
  default     = "ami-07620139298af599e"
}

variable "server_type" {
  description = "EC2 instance type to be created."
  default     = "t3.micro"
}

variable "db_type" {
  description = "RDS instance type to be created."
  default     = "db.t3.micro"
}

variable "app_prefix" {
  description = "Application name prefix."
  default     = "poc-test"
}

variable "db_storage" {
  description = "Database storage size."
  default     = 20
}

variable "cidr_prefix" {
  description = "CIDR prefix."
  default     = "11"
}

variable "remote_ip" {
  description = "A list of CIDR range that allow to SSH into the server."
  default     = ["0.0.0.0/0"]
}