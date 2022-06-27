provider "aws" {
  region = "us-west-2"
}

terraform {
  backend "s3" {
    bucket = "terraform-s0715c"
    key    = "dev/scalable_logging"
    region = "us-west-2"
  }
}
