# AWS provider configuration

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.20.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# Kubernetes provider

# The Kubernetes provider is included in this file so the EKS module can complete successfully. Otherwise, it throws an error when creating `kubernetes_config_map.aws_auth`.


data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

data "aws_availability_zones" "available" {
}

locals {
  cluster_name = var.cluster_name
}

# VPC ,Subnets configuration

module "vpc" {
  source               = "terraform-aws-modules/vpc/aws"
  version              = "3.2.0"
  name                 = "${var.network}-${var.env_name}"
  cidr                 = var.vpc_cidr
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets       = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}-${var.env_name}" = "shared"
    "kubernetes.io/role/elb"                                    = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}-${var.env_name}" = "shared"
    "kubernetes.io/role/internal-elb"                           = "1"
  }
}

# EKS CLUSTER CONFIGURATION:

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "17.24.0"

  cluster_name    = "${var.cluster_name}-${var.env_name}"
  cluster_version = "1.20"
  subnets         = module.vpc.private_subnets

  vpc_id = module.vpc.vpc_id

  node_groups = {
    first = {
      desired_capacity              = 1
      max_capacity                  = 10
      min_capacity                  = 1
      additional_security_group_ids = [aws_security_group.eks-cluster.id]
      instance_type                 = var.machine_type
    }
  }

  write_kubeconfig = true
}