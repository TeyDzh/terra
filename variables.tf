variables "region" {
  default = "eu-central-1"
  type    = string
}

variables "enable_route_53" {
  type    = bool
  default = false
}
