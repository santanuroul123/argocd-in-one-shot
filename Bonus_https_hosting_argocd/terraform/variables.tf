variable "aws_region" {
  description = "AWS region for EKS cluster deployment"
  type        = string
  default     = "eu-west-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "demo"
  
  validation {
    condition     = contains(["dev", "staging", "production", "demo"], var.environment)
    error_message = "Environment must be dev, staging, production, or demo."
  }
}