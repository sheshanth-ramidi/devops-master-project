variable "eks_cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "devops-eks-cluster"
}
 
variable "eks_node_instance_type" {
  description = "EKS node instance type"
  type        = string
  default     = "t3.small"
}
 
variable "eks_desired_nodes" {
  description = "Desired worker nodes"
  type        = number
  default     = 2
}
