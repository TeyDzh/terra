provider "aws" {
  region  = var.region
  profile = "main"
}

module "vpc" {
  source = "./vpc"
}

module "ecs" {
  source = "./ecs"
}

module "alb" {
  source = "./alb"
}

module "route_53" {
  source = "./route_53"
}
