variable "instance_type" {
  description = "The type of instance to create"
  type        = string
  default     = "t3.micro"
}

variable "region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "eu-west-2"
}

variable "ami_id" {
  description = "The AMI ID to use for the EC2 instance"
  type        = string
  default     = "ami-0f34a23ccc1ac13d3"
}

variable "cidr_block" {
  description = "The CIDR block for the public subnet"
  type        = string
  default     = "172.31.100.0/24"
}

variable "availability_zone" {
  description = "The availability zone for the public subnet"
  type        = string
  default     = "eu-west-2a"
}


variable "subnet_name" {
  description = "The name of the public subnet"
  type        = string
  default     = "PUBLIC_SUBNET"
}

variable "instance_name" {
  description = "The name of the EC2 instance"
  type        = string
  default     = "Wordpress_Instance"
}

variable "iam_role_name" {
  description = "The name of the IAM role"
  type        = string
  default     = "wordpress_iam_role"
}

variable "security_group_name" {
  description = "The name of the security group"
  type        = string
  default     = "wordpress_sg"
}




variable "map_public_ip_on_launch" {
  description = "Whether to map public IP on launch for the subnet"
  type        = bool
  default     = true
}

variable "db_name" {
  description = "The name of the database"
  type        = string
  default     = "wordpress_db"
}

variable "db_username" {
  description = "Database user username"
  type        = string
  default     = "abdiwelia45"
}

variable "db_password" {
  description = "Database user password"
  type        = string
  sensitive   = true
}
