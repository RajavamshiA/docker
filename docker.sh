#!/bin/bash

growpart /dev/nvme0n1 4
lvextend -l +50%FREE /dev/RootVG/rootVol
lvextend -l +50%FREE /dev/RootVG/varVol
xfs_growfs /
xfs_growfs /var

dnf -y install dnf-plugins-core
dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
systemctl start docker
systemctl enable docker
usermod -aG docker ec2-user

#Bash script for the waiter
# Define the EKS cluster name
CLUSTER_NAME="cluster-1"

# Wait for the EKS cluster to become active
echo "Waiting for EKS cluster '$CLUSTER_NAME' to become active..."
aws eks wait cluster-active --name "$CLUSTER_NAME" --max-attempts 60

# Check if the command was successful
if [ $? -eq 0 ]; then
    echo "EKS cluster '$CLUSTER_NAME' is now active!"
else
    echo "Failed: Waiter state transitioned to Failure."
    exit 1
fi