#!/bin/bash
set -e

echo "Installing kubectl..."
curl -LO "https://dl.k8s.io/release/$(curl -Ls https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
kubectl version --client

echo "Installing kind..."
curl -Lo ./kind "https://kind.sigs.k8s.io/dl/$(curl -s https://api.github.com/repos/kubernetes-sigs/kind/releases/latest | grep tag_name | cut -d '"' -f 4)/kind-linux-amd64"
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
kind --version

echo "Creating kind cluster..."
kind create cluster

echo "Installing Argo CD..."
kubectl create namespace argocd || true
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "Waiting for Argo CD pods to be ready (this may take a few minutes)..."
kubectl -n argocd wait --for=condition=Ready pod --all --timeout=300s

echo "Port-forwarding Argo CD API server to localhost:8080..."
kubectl port-forward svc/argocd-server -n argocd 8080:443 > /dev/null 2>&1 &

echo "Setup complete!"
echo "To log in to Argo CD UI, open https://localhost:8080 in your browser."
echo "To get the initial admin password, run:"
echo "  kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath=\"{.data.password}\" | base64 -d && echo"




















