aws_region         = "ap-south-1"
vpc_cidr           = "10.0.0.0/16"
public_subnet_cidr = "10.0.1.0/24"
instance_type      = "t3.small"
key_name           = "devops-key"
eks_cluster_name        = "devops-eks-cluster"
eks_node_instance_type = "t3.small"
eks_desired_nodes      = 2
