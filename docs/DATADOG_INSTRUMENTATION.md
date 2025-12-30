# Instrumentação com Datadog

Este guia mostra como instrumentar o OpenTelemetry Demo com Datadog APM.

## Pré-requisitos

- Cluster kind rodando com OpenTelemetry Demo
- Conta Datadog (trial de 14 dias disponível)
- API Key do Datadog

## Estrutura de arquivos

```
├── datadog/
│   └── otel-collector-datadog.yaml    # ConfigMap do OTel Collector
├── helm-values/
│   └── datadog-values.yaml            # Valores do Helm para Datadog Agent
├── scripts/
│   └── install-datadog.sh             # Script de instalação automatizada
└── docs/
    └── DATADOG_INSTRUMENTATION.md     # Esta documentação
```

## Instalação rápida

1. **Obter API Key do Datadog:**
   - Acesse: https://app.datadoghq.com/organization-settings/api-keys
   - Copie sua API key

2. **Executar script de instalação:**
   ```bash
   export DD_API_KEY="your-api-key-here"
   ./scripts/install-datadog.sh
   ```

## Instalação manual

### 1. Instalar Datadog Agent

```bash
# Adicionar repositório
helm repo add datadog https://helm.datadoghq.com
helm repo update

# Editar API key no arquivo
vim helm-values/datadog-values.yaml

# Instalar
helm install datadog-agent datadog/datadog \
  --namespace datadog \
  --create-namespace \
  --values helm-values/datadog-values.yaml
```

### 2. Configurar OpenTelemetry Collector

```bash
# Editar API key no arquivo
vim datadog/otel-collector-datadog.yaml

# Aplicar configuração
kubectl apply -f datadog/otel-collector-datadog.yaml

# Reiniciar collector
kubectl rollout restart deployment/otel-collector -n otel-demo
```

## Verificação

### 1. Verificar pods do Datadog
```bash
kubectl get pods -n datadog
```

### 2. Gerar tráfego
```bash
curl http://localhost:8080/api/products
curl http://localhost:8080/
```

### 3. Verificar traces no Datadog
- Acesse: https://app.datadoghq.com/apm/traces
- Procure por serviços: `frontend`, `checkout`, `payment`

## Dashboards disponíveis

Após alguns minutos, você verá no Datadog:

- **APM**: Traces distribuídos e service map
- **Infrastructure**: Métricas do Kubernetes
- **Logs**: Logs dos containers
- **Service Catalog**: Inventário de serviços

## Troubleshooting

### Logs do Datadog Agent
```bash
kubectl logs -f daemonset/datadog-agent -n datadog
```

### Logs do OTel Collector
```bash
kubectl logs -f deployment/otel-collector -n otel-demo
```

### Verificar conectividade
```bash
kubectl exec -it deployment/otel-collector -n otel-demo -- wget -qO- http://datadog-agent.datadog:8126/info
```
