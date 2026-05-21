# holidayhub

![Version: 0.1.6](https://img.shields.io/badge/Version-0.1.6-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.1.0](https://img.shields.io/badge/AppVersion-0.1.0-informational?style=flat-square)

Private vacation and travel management dashboard

**Homepage:** <https://github.com/janip81/helm-charts/tree/main/charts/holidayhub>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| janip81 | <jani@techmonkeys.se> | <https://github.com/janip81> |

## Source Code

* <https://github.com/janip81/helm-charts/tree/main/charts/holidayhub/>
* <https://github.com/janip81/holidayhub>

# Overview

Helm chart for deploying [HolidayHub](https://github.com/janip81/holidayhub) — a self-hosted private family travel planning dashboard.

Built with Next.js 14, TypeScript, Material UI, Prisma ORM, and PostgreSQL (via CNPG). Supports multi-user trip sharing with role-based access (OWNER / EDITOR / VIEWER).

## Adding this helm repository

```bash
helm repo add janip81 https://janip81.github.io/helm-charts/
helm search repo holidayhub
```

## Prerequisites

- **CNPG operator** installed in the cluster (for the managed PostgreSQL cluster, if `cnpg.enabled: true`)
- A Kubernetes Secret with `NEXTAUTH_SECRET` key (pre-created or via AVP):
  ```bash
  kubectl -n holidayhub create secret generic holidayhub-secret \
    --from-literal=NEXTAUTH_SECRET='$(openssl rand -base64 32)'
  ```

## TL;DR

```bash
helm repo add janip81 https://janip81.github.io/helm-charts/
helm install holidayhub janip81/holidayhub \
  --namespace holidayhub \
  --create-namespace \
  --set gatewayApi.host=holidayhub.example.com \
  --set env.NEXTAUTH_URL=https://holidayhub.example.com \
  --set cnpg.storage.storageClass=your-storage-class
```

## Gateway API (HTTPRoute)

```yaml
gatewayApi:
  enabled: true
  host: holidayhub.your-domain.com
  parentRefs:
    - name: internal-shared
      namespace: kube-system
```

## Prisma Migrations

Enable the pre-upgrade migration Job to run `prisma migrate deploy` before each rollout:

```yaml
migrations:
  enabled: true
```

The Job uses the same container image as the app, so it picks up the current schema automatically.

## Secret Management (ArgoCD Vault Plugin)

Set `secret.create: false` to let AVP manage the secret:

```yaml
secret:
  create: false
```

Then provide a secret via your cluster-config path:

```yaml
# cluster-config/holidayhub/secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: holidayhub-secret
  namespace: holidayhub
  annotations:
    avp.kubernetes.io/path: "kubernetes/data/prod-k8s/holidayhub"
type: Opaque
stringData:
  NEXTAUTH_SECRET: <path:kubernetes/data/prod-k8s/holidayhub#nextauth-secret>
```

## CNPG Backup (Barman S3)

```yaml
cnpg:
  backup:
    enabled: true
    destinationPath: s3://my-bucket/holidayhub
    endpointURL: https://s3.example.com
    s3CredentialsSecret: cnpg-barman-s3-creds
    retentionPolicy: "30d"
```

The `s3CredentialsSecret` must contain keys: `access-key-id`, `secret-access-key`, `region`.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| cnpg.backup.destinationPath | string | `"s3://my-bucket/holidayhub"` | S3 destination path |
| cnpg.backup.enabled | bool | `false` | Enable Barman S3 backup |
| cnpg.backup.endpointURL | string | `"https://s3.example.com"` | S3 endpoint URL |
| cnpg.backup.retentionPolicy | string | `"30d"` | Backup retention policy |
| cnpg.backup.s3CredentialsSecret | string | `"cnpg-barman-s3-creds"` | Secret with S3 credentials (keys: access-key-id, secret-access-key, region) |
| cnpg.database | string | `"holidayhub"` | PostgreSQL database name |
| cnpg.enabled | bool | `false` | Enable a dedicated CloudNativePG cluster for this app. Leave false to use an external/shared database and provide DATABASE_URL via secret. |
| cnpg.instances | int | `1` | Number of CNPG instances |
| cnpg.owner | string | `"holidayhub"` | PostgreSQL owner role |
| cnpg.storage.size | string | `"5Gi"` | PVC size |
| cnpg.storage.storageClass | string | `""` | StorageClass (leave empty to use cluster default) |
| env | object | `{"NEXTAUTH_URL":"https://holidayhub.threshold.se","NEXT_TELEMETRY_DISABLED":"1","NODE_ENV":"production"}` | Non-secret environment variables injected via ConfigMap |
| env.NEXTAUTH_URL | string | `"https://holidayhub.threshold.se"` | Public URL of the app — must match the Gateway hostname |
| gatewayApi.enabled | bool | `true` | Enable Gateway API HTTPRoute |
| gatewayApi.host | string | `"holidayhub.threshold.se"` | Hostname for the HTTPRoute |
| gatewayApi.parentRefs | list | `[{"group":"gateway.networking.k8s.io","kind":"Gateway","name":"external-shared","namespace":"kube-system"}]` | Gateway parentRefs |
| hpa.enabled | bool | `false` | Enable HorizontalPodAutoscaler |
| hpa.maxReplicas | int | `3` | Maximum replicas |
| hpa.minReplicas | int | `1` | Minimum replicas |
| hpa.targetCPUUtilizationPercentage | int | `80` | CPU utilisation target |
| image.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| image.repository | string | `"ghcr.io/janip81/holidayhub"` | Image repository |
| image.tag | string | `"latest"` | Image tag (pin to a SHA in GitOps) |
| imagePullSecrets | list | `[]` | Image pull secrets for private registries (e.g. ghcr.io) |
| migrations | object | `{"enabled":false,"resources":{"limits":{"cpu":"500m","memory":"256Mi"},"requests":{"cpu":"100m","memory":"128Mi"}}}` | Prisma migrate Job (pre-install/pre-upgrade hook). Runs: prisma migrate deploy |
| migrations.enabled | bool | `false` | Enable the migration Job |
| nodeSelector | object | `{}` |  |
| persistence.accessMode | string | `"ReadWriteOnce"` | Access mode — use ReadWriteOnce for single-replica deployments |
| persistence.enabled | bool | `false` | Enable a PersistentVolumeClaim for document uploads. Required in production. |
| persistence.size | string | `"5Gi"` | PVC size |
| persistence.storageClass | string | `""` | StorageClass (leave empty to use cluster default) |
| podAnnotations | object | `{}` |  |
| podLabels | object | `{}` |  |
| replicaCount | int | `1` | Number of replicas (keep at 1 — NextAuth.js sessions are node-local by default) |
| resources.limits.cpu | string | `"500m"` | CPU limit |
| resources.limits.memory | string | `"512Mi"` | Memory limit |
| resources.requests.cpu | string | `"100m"` | CPU request |
| resources.requests.memory | string | `"256Mi"` | Memory request |
| s3.bucket | string | `""` |  |
| s3.endpoint | string | `""` | Leave endpoint empty to use local disk (persistence.enabled must be true in that case). |
| s3.region | string | `"garage"` |  |
| secret | object | `{"create":true}` | Secret management. Set create: false when the secret is managed externally (e.g. AVP via cluster-config) |
| secret.create | bool | `true` | Create the secret from secretEnv values. Set false when AVP manages it. |
| secretEnv | object | `{"DATABASE_URL":"postgresql://holidayhub:changeme@localhost:5432/holidayhub","NEXTAUTH_SECRET":"changeme","REDIS_URL":"","SPOTIFY_CLIENT_ID":"","SPOTIFY_CLIENT_SECRET":""}` | Secret env vars. Used when secret.create: true. Override with AVP refs via cluster-config when secret.create: false. |
| secretEnv.DATABASE_URL | string | `"postgresql://holidayhub:changeme@localhost:5432/holidayhub"` | Full Prisma DATABASE_URL (used when cnpg.enabled: false) |
| secretEnv.NEXTAUTH_SECRET | string | `"changeme"` | NextAuth.js signing/encryption secret. Generate with: openssl rand -base64 32 |
| secretEnv.REDIS_URL | string | `""` | Redis URL for multi-replica-safe rate limiting. Leave empty to use in-memory fallback. |
| secretEnv.SPOTIFY_CLIENT_ID | string | `""` | Register at https://developer.spotify.com/dashboard |
| service.port | int | `3000` | Service port (Next.js listens on 3000) |
| service.type | string | `"ClusterIP"` | Service type |
| serviceMonitor.bearerTokenSecret | object | `{"key":"","name":""}` | Secret containing METRICS_BEARER_TOKEN for Prometheus scraping |
| serviceMonitor.clusterLabel | string | `""` | Value for k8s_cluster relabel (defaults to Release.Namespace if empty) |
| serviceMonitor.enabled | bool | `false` | Enable Prometheus ServiceMonitor |
| serviceMonitor.interval | string | `"30s"` | Scrape interval |
| serviceMonitor.labels | object | `{}` | Additional labels to match your Prometheus operator selector |
| serviceMonitor.path | string | `"/api/metrics"` | Metrics path |
| serviceMonitor.scrapeTimeout | string | `"10s"` | Scrape timeout |
| tolerations | list | `[]` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
