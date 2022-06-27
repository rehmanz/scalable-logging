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

variable "availability_zones" {
  description = "AWS Availability Zones"
  type        = list(string)
  default = [
    "us-west-2a",
    "us-west-2c"
  ]
}

variable "master_username" {
  description = "The username for the master user. This MUST to be set as the environment variable TF_VAR_master_username so you don't check it into source control."
  type        = string
}

variable "master_password" {
  description = "The password for the master user. This MUST be set as the environment variable TF_VAR_master_password so you don't check it into source control."
  type        = string
}

variable "postgres_engine_version" {
  description = "The Postgres engine version to use."
  type        = string
  default     = "11"
}

variable "enabled_cloudwatch_logs_exports" {
  description = "List of log types to enable for exporting to CloudWatch logs. If omitted, no logs will be exported. Valid values are: postgresql and upgrade."
  type        = list(string)
  default     = []
}

variable "iam_database_authentication_enabled" {
  description = "Specifies whether IAM database authentication is enabled. This option is only available for MySQL and PostgreSQL engines."
  type        = bool
  default     = true
}
