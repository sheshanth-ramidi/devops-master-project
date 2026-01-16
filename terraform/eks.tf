resource "local_file" "eksctl_config" {
  filename = "${path.module}/eksctl.yaml"
 
  content = templatefile("${path.module}/eksctl.yaml.tpl", {
    cluster_name  = var.eks_cluster_name
    region        = var.aws_region
    instance_type = var.eks_node_instance_type
    desired_nodes = var.eks_desired_nodes
  })
}
 
resource "null_resource" "create_eks_cluster" {
  depends_on = [local_file.eksctl_config]
 
  provisioner "local-exec" {
    command = "eksctl create cluster -f eksctl.yaml"
  }
}
