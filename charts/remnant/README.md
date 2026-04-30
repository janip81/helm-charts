# claude-memory

![Version: 0.1.4](https://img.shields.io/badge/Version-0.1.4-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.1.0](https://img.shields.io/badge/AppVersion-0.1.0-informational?style=flat-square)

MCP memory server — mem0 + pgvector + Ollama embeddings

**Homepage:** <https://github.com/janip81/helm-charts/tree/main/charts/claude-memory>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| janip81 | <jani@techmonkeys.se> | <https://github.com/janip81> |

## Source Code

* <https://github.com/janip81/helm-charts/tree/main/charts/claude-memory/>
* <https://github.com/janip81/claude-memory>

# Overview

Helm chart for deploying [claude-memory](https://github.com/janip81/claude-memory) — a self-hosted MCP memory server built on [mem0](https://github.com/mem0ai/mem0), pgvector (via CNPG), and Ollama embeddings.

Gives Claude Code persistent semantic memory across sessions. Facts are stored directly in pgvector and retrieved via semantic search — no LLM API calls required.

## Adding this helm repository

```bash
helm repo add janip81 https://janip81.github.io/helm-charts/
helm search repo claude-memory
```

## Prerequisites

- **Ollama** running and reachable with `nomic-embed-text` pulled:
  ```bash
  ollama pull nomic-embed-text
  ```
- **CNPG operator** installed in the cluster (for the managed PostgreSQL cluster)
- A Kubernetes Secret with `BEARER_TOKEN` key (pre-created or via AVP):
  ```bash
  kubectl -n claude-memory create secret generic claude-memory-auth \
    --from-literal=BEARER_TOKEN='your-token'
  ```

## TL;DR

```bash
helm repo add janip81 https://janip81.github.io/helm-charts/
helm install claude-memory janip81/claude-memory \
  --namespace claude-memory \
  --create-namespace \
  --set gatewayApi.host=mem0-mcp.your-domain.com \
  --set ollama.baseUrl=http://your-ollama-host:11434 \
  --set cnpg.storage.storageClass=your-storage-class
```

## Connecting Claude Code

After deployment:

```bash
claude mcp add --transport http --scope user mem0-mcp https://mem0-mcp.your-domain.com/mcp
```

Enter the bearer token when prompted.

## Gateway API (HTTPRoute)

```yaml
gatewayApi:
  enabled: true
  host: mem0-mcp.your-domain.com
  parentRefs:
    - name: internal-shared
      namespace: kube-system
```

## CNPG Backup (Barman S3)

```yaml
cnpg:
  backup:
    enabled: true
    destinationPath: s3://my-bucket/claude-memory
    endpointURL: https://s3.example.com
    s3CredentialsSecret: cnpg-barman-s3-creds
    retentionPolicy: "30d"
```

The `s3CredentialsSecret` must contain keys: `access-key-id`, `secret-access-key`, `region`.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| auth.secretName | string | `"claude-memory-auth"` | Name of the Secret containing BEARER_TOKEN (pre-created or rendered by AVP) |
| cnpg.backup.destinationPath | string | `"s3://my-bucket/claude-memory"` | S3 destination path |
| cnpg.backup.enabled | bool | `false` | Enable Barman S3 backup |
| cnpg.backup.endpointURL | string | `"https://s3.example.com"` | S3 endpoint URL |
| cnpg.backup.retentionPolicy | string | `"30d"` | Backup retention policy |
| cnpg.backup.s3CredentialsSecret | string | `"cnpg-barman-s3-creds"` | Name of the Secret containing S3 credentials (keys: access-key-id, secret-access-key, region) |
| cnpg.enabled | bool | `true` | Enable CNPG PostgreSQL cluster |
| cnpg.instances | int | `1` | Number of CNPG instances |
| cnpg.storage.size | string | `"5Gi"` | Storage size for the CNPG cluster |
| cnpg.storage.storageClass | string | `""` | Storage class for the CNPG cluster |
| gatewayApi.enabled | bool | `true` | Enable Gateway API HTTPRoute |
| gatewayApi.host | string | `"mem0-mcp.prod.example.com"` | Hostname for the MCP HTTPRoute |
| gatewayApi.parentRefs | list | `[{"name":"internal-shared","namespace":"kube-system"}]` | Gateway parentRefs |
| image.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| image.repository | string | `"ghcr.io/janip81/claude-memory"` | Image repository |
| image.tag | string | `"latest"` | Image tag |
| imagePullSecrets | list | `[]` | Image pull secrets for private registries (e.g. ghcr.io) |
| mem0.userId | string | `"default"` | User ID namespace for stored memories |
| ollama.baseUrl | string | `"http://ollama:11434"` | Ollama server URL |
| ollama.embedModel | string | `"nomic-embed-text"` | Embedding model (must be pulled in Ollama) |
| ollama.model | string | `"qwen2.5:7b"` | Chat model for LLM operations |
| replicaCount | int | `1` | Number of replicas |
| resources.limits.cpu | string | `"500m"` | CPU limit |
| resources.limits.memory | string | `"512Mi"` | Memory limit |
| resources.requests.cpu | string | `"100m"` | CPU request |
| resources.requests.memory | string | `"256Mi"` | Memory request |
| service.port | int | `8080` | Service port |
| service.type | string | `"ClusterIP"` | Service type |
| ui.enabled | bool | `true` | Enable the memory browser UI (separate pod, same image) |
| ui.host | string | `""` | Hostname for the UI HTTPRoute (leave empty to share MCP hostname with path routing) |
| ui.port | int | `8081` | Port the UI listens on inside the container |
| ui.resources.limits.cpu | string | `"200m"` |  |
| ui.resources.limits.memory | string | `"128Mi"` |  |
| ui.resources.requests.cpu | string | `"50m"` |  |
| ui.resources.requests.memory | string | `"64Mi"` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
