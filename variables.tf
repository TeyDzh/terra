variables "region" {
  default = "eu-central-1"
  type    = string
}

variables "cidr_block" {
  default = "10.0.0.0/16"
  type    = string
}

variable "public_cidr" {
  default = "10.0.1.0/24"
  type    = string
}
