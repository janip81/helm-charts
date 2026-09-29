# apartment-search

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.1.0](https://img.shields.io/badge/AppVersion-0.1.0-informational?style=flat-square)

Self-hosted aggregator for Swedish rental apartment listings (Next.js + PostgreSQL)

**Homepage:** <https://github.com/janip81/helm-charts/tree/main/charts/apartment-search>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| janip81 | <jani@techmonkeys.se> | <https://github.com/janip81> |

## Source Code

* <https://github.com/janip81/helm-charts/tree/main/charts/apartment-search/>
* <https://github.com/janip81/apartment-search>

# Overview

Helm chart for deploying [apartment-search](https://github.com/janip81/apartment-search) — a self-hosted aggregator for Swedish rental apartment listings.

One image serves three roles:

| Resource | Purpose |
|---|---|
| Deployment `<release>` | Next.js web app (UI, API, `/health`, `/ready`) |
| CronJob `<release>-collector` | Collector tick — runs every source that is due (per-source interval lives in the DB) |
| Job `<release>-migrate` | `prisma migrate deploy`, once per deploy |
| ConfigMap `<release>-config` | Non-secret env (`env:` values) |
| Secret `<release>-secret` | Only when `secret.create: true`; normally provided externally with key `DATABASE_URL` |
| HTTPRoute / Ingress | Gateway API (default) or classic Ingress |
| CNPG Cluster `<release>-pg` | Only when `cnpg.enabled: true` (dedicated PostgreSQL with a PVC) |

## Adding this helm repository

```bash
helm repo add janip81 https://janip81.github.io/helm-charts/
helm search repo apartment-search
```

## Migrations

Migrations never run per replica. A single Job runs `prisma migrate deploy`:

- **Argo CD:** Sync hook at wave 1 — after Secrets/ConfigMaps (wave 0), before the Deployment and CronJob (wave 2).
- **Plain Helm:** `pre-install,pre-upgrade` hook — the database Secret must already exist.

## Secret Management (ArgoCD Vault Plugin)

```yaml
secret:
  create: false
  name: apartment-search-secret
```

```yaml
# cluster-config/apartment-search/secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: apartment-search-secret
  namespace: apartment-search
  annotations:
    avp.kubernetes.io/path: "kubernetes/data/prod-k8s/apartment-search"
type: Opaque
stringData:
  DATABASE_URL: <path:kubernetes/data/prod-k8s/apartment-search#database-url>
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| cnpg | object | `{"database":"apartment_search","enabled":false,"imageName":"ghcr.io/cloudnative-pg/postgresql:16","instances":1,"owner":"apartment_search","storage":{"size":"5Gi","storageClass":""}}` | Dedicated CloudNativePG cluster for this app. Leave disabled to use a shared cluster (DATABASE_URL in the Secret). |
| cnpg.storage.size | string | `"5Gi"` | PVC size — this is where listing data persists |
| cnpg.storage.storageClass | string | `""` | StorageClass (empty = cluster default) |
| collector | object | `{"activeDeadlineSeconds":900,"concurrencyPolicy":"Forbid","enabled":true,"env":{},"failedJobsHistoryLimit":5,"resources":{"limits":{"memory":"384Mi"},"requests":{"cpu":"50m","memory":"128Mi"}},"schedule":"*/5 * * * *","startingDeadlineSeconds":120,"successfulJobsHistoryLimit":3,"suspend":false,"timeZone":"Europe/Stockholm"}` | Source collection. One CronJob "tick" runs every source that is due according to its own interval stored in the database — no per-source CronJobs. |
| collector.env | object | `{}` | Extra env for the collector only (e.g. MOCK_UNSTABLE_MODE) |
| collector.schedule | string | `"*/5 * * * *"` | Tick frequency (the finest per-source interval that can be honoured) |
| env | object | `{"DEFAULT_USER_EMAIL":"owner@localhost","HTTP_USER_AGENT":"apartment-search/0.1 (personal rental aggregator)","LOG_LEVEL":"info","NEXT_TELEMETRY_DISABLED":"1","NODE_ENV":"production","SOURCE_LEASE_MINUTES":"10"}` | Non-secret configuration, rendered into a ConfigMap and injected as env vars |
| env.DEFAULT_USER_EMAIL | string | `"owner@localhost"` | Implicit single user until real authentication exists |
| env.HTTP_USER_AGENT | string | `"apartment-search/0.1 (personal rental aggregator)"` | User-Agent sent to apartment sources — identify yourself honestly |
| env.SOURCE_LEASE_MINUTES | string | `"10"` | Minutes a source execution lease is held before it is considered abandoned |
| fullnameOverride | string | `""` |  |
| gatewayApi.enabled | bool | `true` | Expose via Gateway API HTTPRoute |
| gatewayApi.host | string | `"apartments.example.com"` |  |
| gatewayApi.parentRefs[0].group | string | `"gateway.networking.k8s.io"` |  |
| gatewayApi.parentRefs[0].kind | string | `"Gateway"` |  |
| gatewayApi.parentRefs[0].name | string | `"internal-shared"` |  |
| gatewayApi.parentRefs[0].namespace | string | `"kube-system"` |  |
| image.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| image.repository | string | `"ghcr.io/janip81/apartment-search"` | Image repository (one image serves web, collector and migrations) |
| image.tag | string | `"main"` | Image tag (pin to a git SHA in GitOps) |
| imagePullSecrets | list | `[]` | Image pull secrets for private registries (e.g. ghcr.io) |
| ingress.annotations | object | `{}` |  |
| ingress.className | string | `""` |  |
| ingress.enabled | bool | `false` | Classic Ingress alternative to gatewayApi |
| ingress.host | string | `"apartments.example.com"` |  |
| ingress.tls | list | `[]` |  |
| migrations | object | `{"activeDeadlineSeconds":600,"backoffLimit":2,"enabled":true,"resources":{"limits":{"memory":"384Mi"},"requests":{"cpu":"50m","memory":"128Mi"}}}` | Prisma migrations run ONCE per deploy in a Job (never per replica). Argo CD: Sync hook at wave 1, after Secrets/ConfigMaps and before the Deployment/CronJob (wave 2). Plain Helm: pre-install/pre-upgrade hook (the DB Secret must already exist). |
| nameOverride | string | `""` |  |
| nodeSelector | object | `{}` |  |
| podAnnotations | object | `{}` |  |
| podLabels | object | `{}` |  |
| podSecurityContext.fsGroup | int | `1001` |  |
| podSecurityContext.runAsGroup | int | `1001` |  |
| podSecurityContext.runAsNonRoot | bool | `true` |  |
| podSecurityContext.runAsUser | int | `1001` |  |
| podSecurityContext.seccompProfile.type | string | `"RuntimeDefault"` |  |
| probes.liveness.failureThreshold | int | `3` |  |
| probes.liveness.initialDelaySeconds | int | `10` |  |
| probes.liveness.path | string | `"/health"` |  |
| probes.liveness.periodSeconds | int | `20` |  |
| probes.liveness.timeoutSeconds | int | `5` |  |
| probes.readiness.failureThreshold | int | `3` |  |
| probes.readiness.initialDelaySeconds | int | `5` |  |
| probes.readiness.path | string | `"/ready"` |  |
| probes.readiness.periodSeconds | int | `10` |  |
| probes.readiness.timeoutSeconds | int | `5` |  |
| replicaCount | int | `1` | Web replicas. Safe to scale: migrations run in a single Job and source runs use a DB lease. |
| resources.limits.memory | string | `"512Mi"` |  |
| resources.requests.cpu | string | `"100m"` |  |
| resources.requests.memory | string | `"192Mi"` |  |
| secret | object | `{"create":false,"name":""}` | Secret holding DATABASE_URL (and any future secrets). Never put real credentials in values. |
| secret.create | bool | `false` | Create the Secret from secretEnv. Keep false when it is managed externally (AVP/Vault via cluster-config). |
| secret.name | string | `""` | Name of the Secret (created or existing). Defaults to <fullname>-secret. |
| secretEnv | object | `{"DATABASE_URL":""}` | Used only when secret.create is true (local/test installs) |
| securityContext.allowPrivilegeEscalation | bool | `false` |  |
| securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| securityContext.readOnlyRootFilesystem | bool | `true` |  |
| service.port | int | `3000` | Service port (Next.js listens on 3000) |
| service.type | string | `"ClusterIP"` | Service type |
| tolerations | list | `[]` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
