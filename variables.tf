variable "region" {
  default = "eu-central-1"
  type    = string
}

variable "enable_route_53" {
  type    = bool
  default = false
}
