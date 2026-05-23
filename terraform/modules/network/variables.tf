variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
}

variable "availability_zones" {
  description = "AZs to place subnets in"
  type        = list(string)
}

variable "ssh_allowed_cidr" {
  description = "CIDR permitted inbound on port 22"
  type        = string
}

variable "tags" {
  description = "Common tags to apply to all resources in this module"
  type        = map(string)
}
