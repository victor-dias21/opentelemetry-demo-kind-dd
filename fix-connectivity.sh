#!/bin/bash

echo "🔧 Solucionando problema de conectividade Docker Registry"

# Deletar recursos existentes
kubectl delete namespace otel-demo --ignore-not-found=true

# Recriar cluster com DNS configurado
kind delete cluster --name otel-demo
kind create cluster --name otel-demo --config kubernetes/kind-config.yaml

# Aplicar manifesto básico primeiro
kubectl apply -f kubernetes/namespace.yaml

echo "✅ Cluster recriado. Teste a conectividade:"
echo "docker pull busybox:1.35"
