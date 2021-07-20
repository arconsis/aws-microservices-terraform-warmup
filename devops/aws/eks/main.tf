provider "aws" {
  shared_credentials_file = "$HOME/.aws/credentials"
  profile                 = "default"
  region                  = var.aws_region
}

locals {
  cluster_name = "my-cluster"
}

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
  load_config_file       = false
  version                = "~> 1.9"
}

module "networking" {
  source               = "../modules/network"
  create_vpc           = var.create_vpc
  create_igw           = var.create_igw
  single_nat_gateway   = var.single_nat_gateway
  enable_nat_gateway   = var.enable_nat_gateway
  region               = var.aws_region
  vpc_name             = var.vpc_name
  cidr_block           = var.cidr_block
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  cluster_name    = "${local.cluster_name}"
  cluster_version = "1.17"

  subnets         = module.networking.private_subnet_ids
  vpc_id          = module.networking.vpc_id

  # node_groups are aws eks managed nodes whereas worker_groups are self managed nodes. Among many one advantage of worker_groups is that you can use your custom AMI for the nodes.
  # https://github.com/terraform-aws-modules/terraform-aws-eks/issues/895
  worker_groups = [
    {
      name                  = "worker-group-1"
      instance_type         = "t2.micro"
      asg_desired_capacity  = 2
      asg_max_size          = 5
    }
  ]
  # node_groups = {
  #   first = {
  #     desired_capacity = 4
  #     max_capacity     = 10
  #     min_capacity     = 4

  #     instance_type = "t2.micro"
  #   }
  # }

  write_kubeconfig   = true
  config_output_path = "./"

  workers_additional_policies = [aws_iam_policy.worker_policy.arn]
  cluster_enabled_log_types   = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]
}


resource "aws_iam_policy" "worker_policy" {
  name        = "worker-policy"
  description = "Worker policy for the ALB Ingress"

  policy = file("../common/templates/eks/iam-policy.json")
}

# provider "helm" {
#   version = "1.3.1"
#   kubernetes {
#     host                   = data.aws_eks_cluster.cluster.endpoint
#     cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
#     token                  = data.aws_eks_cluster_auth.cluster.token
#     load_config_file       = false
#   }
# }

# resource "helm_release" "ingress" {
#   name       = "ingress"
#   chart      = "aws-alb-ingress-controller"
#   # repository = "http://storage.googleapis.com/kubernetes-charts-incubator"
#   version    = "1.0.2"

#   set {
#     name  = "autoDiscoverAwsRegion"
#     value = "true"
#   }
#   set {
#     name  = "autoDiscoverAwsVpcID"
#     value = "true"
#   }
#   set {
#     name  = "clusterName"
#     value = local.cluster_name
#   }
# }
