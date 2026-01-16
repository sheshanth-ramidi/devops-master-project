apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig
 
metadata:
  name: ${cluster_name}
  region: ${region}
 
nodeGroups:
  - name: ng-1
    instanceType: ${instance_type}
    desiredCapacity: ${desired_nodes}
    minSize: 1
    maxSize: 3
