#!/bin/bash

# Exit immediately if any command fails
set -e

echo "Starting Bastion Host bootstrapping process..."

# ---------------------------------------------------
# Update OS & unzip is required for AWS CLI
# ----------------------------------------------------
sudo apt-get update -y
sudo apt-get install -y unzip curl tar

# --------------------------
# 2. Install AWS CLI v2
# --------------------------
echo "Installing AWS CLI v2..."
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -q awscliv2.zip
sudo ./aws/install
# Clean up artifacts
rm -rf aws awscliv2.zip

# ----------------------
# 3. Install kubectl 
# ----------------------
echo "Installing kubectl..."
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
# Clean up artifacts
rm kubectl

# ---------------------
# 4. Install Helm 
# ---------------------
echo "Installing Helm..."
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
# Clean up artifacts
rm get_helm.sh

# -------------------
# 5. Install eksctl 
# -------------------
echo "Installing eksctl..."
# Note: eksctl recently migrated to the eksctl-io GitHub organization
curl --silent --location "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_Linux_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin

echo "Bastion Host bootstrapping successfully completed"