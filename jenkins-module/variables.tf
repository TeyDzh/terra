variable "region" {
  default = "eu-central-1"
  type    = string
}
############
# VPC VARS #
############

variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr_block" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidr_block" {
  type    = list(string)
  default = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

variable "az" {
  type    = list(string)
  default = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
}


############
# ALB VARS #
############

variable "app_name" {
  type    = string
  default = "jenkins"
}

variable "alb_internal" {
  description = "Flag to indicate if the ALB is internal (true/false)"
  type        = bool
  default     = false
}

variable "target_group_port" {
  description = "Port number for the target group"
  type        = number
  default     = 80
}

variable "target_group_protocol" {
  description = "Protocol for the target group"
  type        = string
  default     = "HTTP"
}

variable "target_type" {
  description = "Target type of target group"
  type        = string
  default     = "ip"
}

variable "target_group_health_check_healthy_threshold" {
  description = "Number of consecutive successful health checks required to consider a target healthy"
  type        = number
  default     = 3
}

variable "target_group_health_check_interval" {
  description = "Interval between health checks for the target group"
  type        = number
  default     = 300
}

variable "target_group_health_check_protocol" {
  description = "Protocol for the target group health check"
  type        = string
  default     = "HTTP"
}

variable "target_group_health_check_timeout" {
  description = "Amount of time to wait for a target to respond to a health check request"
  type        = number
  default     = 3
}

variable "target_group_health_check_path" {
  description = "Path for the target group health check"
  type        = string
  default     = "/v1/status"
}

variable "target_group_health_check_unhealthy_threshold" {
  description = "Number of consecutive failed health checks required to consider a target unhealthy"
  type        = number
  default     = 2
}

############
# ECS VARS #
############

variable "task_cpu" {
  description = "The CPU units for the ECS task"
  type        = number
  default     = 256
}

variable "task_memory" {
  description = "The memory limit (in MiB) for the ECS task"
  type        = number
  default     = 512
}

variable "container_port" {
  description = "The container port for the Jenkins application"
  type        = number
  default     = 8080
}

variable "count" {
  description = "The desired count of the ECS service"
  type        = number
  default     = 1
}




#################
# ROUTE 53 VARS #
#################

variable "enable_route_53" {
  description = "value"
  type        = bool
  default     = false
}

