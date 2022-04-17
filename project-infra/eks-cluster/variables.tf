
variable "region" {
  default     = "us-east-1"
  description = "AWS region"
}

variable "cluster_name" {
  description = "The name for the EKS cluster"
  type        = string
}

variable "env_name" {
  description = "The environment for the EKS cluster"
  default     = "dev"
  type        = string
}

variable "network" {
  description = "The VPC network created to host the cluster in"
  default     = "eks-network"
}

variable "vpc_cidr" {

  default = "10.0.0.0/16"
}

variable "machine_type" {
  description = "EKS machine type"
  default     = "t2.micro"
  type        = string
}