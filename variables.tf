variable "aws_region" {
  description = "AWS region"
  default     = "eu-west-2"
}

variable "app_name" {
  description = "Application name"
  default     = "image-resizer"
}

variable "environment" {
  description = "Environment name"
  default     = "production"
}

variable "container_port" {
  description = "Container port"
  default     = 80
}

variable "cpu" {
  description = "CPU units for the task"
  default     = "256"
}

variable "memory" {
  description = "Memory for the task"
  default     = "512"
}
