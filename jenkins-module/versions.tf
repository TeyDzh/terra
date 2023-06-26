provider "aws" {
  region  = var.region
  profile = "main"
}

# terraform {
#   required_version = "1.4.6"
#   backend "s3" {
#     bucket  = "main-tf-state-file"
#     key     = "terraform.tfstate"
#     region  = "eu-central-1"
#     profile = "main"
#   }
# }
