terraform {
  required_version = ">= v1.1.7"
}

provider "aws" {
  region = var.aws_region
}

terraform {
  backend "s3" {
    bucket = "terraform-s0715c"
    key    = "dev/scalable_logging"
    region = "us-west-2"
  }
}
