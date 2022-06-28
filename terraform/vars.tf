variable "aws_region" {
  description = "The AWS region in which all resources will be created"
  type        = string
  default     = "us-west-2"
}

variable "vpc_cidr_block" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr_blocks" {
  description = "Available cidr blocks for public subnets"
  type        = list(string)
  default = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]
}

variable "private_subnet_cidr_blocks" {
  description = "Available cidr blocks for private subnets"
  type        = list(string)
  default = [
    "10.0.101.0/24",
    "10.0.102.0/24"
  ]
}

variable "database_subnet_cidr_blocks" {
  description = "Available cidr blocks for database subnets"
  type        = list(string)
  default = [
    "10.0.201.0/24",
    "10.0.203.0/24"
  ]
}

variable "availability_zones" {
  description = "AWS Availability Zones"
  type        = list(string)
  default = [
    "us-west-2a",
    "us-west-2c"
  ]
}

variable "db_name" {
  description = "The name for the DB user. This MUST be set as the environment variable TF_VAR_db_name so you don't check it into source control."
  type        = string
  sensitive   = true
}

variable "db_username" {
  description = "The username for the master DB user. This MUST to be set as the environment variable TF_VAR_db_username so you don't check it into source control."
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "The password for the master DB user. This MUST be set as the environment variable TF_VAR_db_password so you don't check it into source control."
  type        = string
  sensitive   = true
}
