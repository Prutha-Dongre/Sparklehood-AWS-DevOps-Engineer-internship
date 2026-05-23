variable "aws_region" {
  description = "AWS region to deploy resources into"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Deployment environment (e.g. staging, production)"
  type        = string
  default     = "staging"
}

variable "project" {
  description = "Project name used for tagging and naming"
  type        = string
  default     = "NimbusKart"
}

variable "owner" {
  description = "Team or individual responsible for these resources"
  type        = string
  default     = "platform-team"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.20.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets (one per AZ)"
  type        = list(string)
  default     = ["10.20.1.0/24", "10.20.2.0/24"]
}

variable "availability_zones" {
  description = "List of AZs to deploy subnets into"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

# DEVIATION: Default changed from 0.0.0.0/0 to a restricted CIDR.
# 0.0.0.0/0 on port 22 is a critical security risk and would be flagged
# by any compliance scanner. Reviewers must explicitly set this to a
# known bastion or VPN CIDR in production.
variable "ssh_allowed_cidr" {
  description = "CIDR block allowed to reach port 22. MUST be restricted before production use — do NOT leave as 0.0.0.0/0."
  type        = string
  default     = "10.0.0.0/8"
}

variable "instance_type" {
  description = "EC2 instance type for web tier nodes"
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "AMI ID to use for EC2 instances (LocalStack accepts any value)"
  type        = string
  default     = "ami-0c55b159cbfafe1f0"
}

variable "web_instance_count" {
  description = "Number of web tier EC2 instances to create"
  type        = number
  default     = 2
}

variable "log_bucket_name" {
  description = "Name for the S3 application log bucket (must be globally unique in real AWS)"
  type        = string
  default     = "nimbuskart-app-logs-staging"
}

variable "noncurrent_version_expiry_days" {
  description = "Days after which non-current S3 object versions are expired"
  type        = number
  default     = 30
}

variable "localstack_endpoint" {
  description = "LocalStack endpoint URL. Set automatically by tflocal; leave empty for real AWS."
  type        = string
  default     = ""
}

variable "orphan_ebs_size_gb" {
  description = "Size in GB of the intentionally-orphaned EBS volume used for Part B testing"
  type        = number
  default     = 20
}
