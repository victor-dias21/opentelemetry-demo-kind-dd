#!/bin/bash

# Script para instrumentar OpenTelemetry Demo com Datadog

set -e

# Verificar se API key foi fornecida
if [ -z "$DD_API_KEY" ]; then
    echo "❌ Erro: Defina a variável DD_API_KEY"
    echo "export DD_API_KEY='your-api-key-here'"
    exit 1
fi

echo "🚀 Instrumentando OpenTelemetry Demo com Datadog..."

# 1. Adicionar repositório Datadog
echo "📦 Adicionando repositório Helm do Datadog..."
helm repo add datadog https://helm.datadoghq.com
helm repo update

# 2. Substituir API key no arquivo de valores
echo "🔧 Configurando API key..."
if [ ! -f helm-values/datadog-values.yaml ]; then
    cp helm-values/datadog-values.yaml.example helm-values/datadog-values.yaml
fi
sed "s/YOUR_DD_API_KEY_HERE/$DD_API_KEY/g" helm-values/datadog-values.yaml.example > /tmp/datadog-values.yaml

# 3. Instalar Datadog Agent
echo "🐕 Instalando Datadog Agent..."
helm install datadog-agent datadog/datadog \
  --namespace datadog \
  --create-namespace \
  --values /tmp/datadog-values.yaml

# 4. Configurar OTel Collector para Datadog
echo "🔄 Configurando OpenTelemetry Collector..."
sed "s/YOUR_DD_API_KEY_HERE/$DD_API_KEY/g" datadog/otel-collector-datadog.yaml | kubectl apply -f -

# 5. Reiniciar OTel Collector
echo "♻️  Reiniciando OpenTelemetry Collector..."
kubectl rollout restart deployment/otel-collector -n otel-demo

echo "✅ Instrumentação concluída!"
echo ""
echo "🔗 Acesse o Datadog APM: https://app.datadoghq.com/apm/traces"
echo "🔗 Aplicação: http://localhost:8080"
echo ""
echo "⏳ Aguarde alguns minutos para os dados aparecerem no Datadog"
