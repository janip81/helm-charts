# n8n

![Version: 0.1.0-dev](https://img.shields.io/badge/Version-0.1.0--dev-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.0.0](https://img.shields.io/badge/AppVersion-1.0.0-informational?style=flat-square)

n8n workflow automation

**Homepage:** <https://github.com/janip81/helm-charts/tree/main/charts/n8n>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| janip81 | <jani@techmonkeys.se> | <https://github.com/janip81> |

## Source Code

* <https://github.com/janip81/helm-charts/tree/main/charts/n8n/>

# Overview
Helm-chart for deploying n8n - Workflow Automation Tool

## Adding this helm repository

To add the helm repository, run the following commands:

```bash
helm repo add janip81 https://janip81.github.io/helm-charts/
helm search repo n8n
```

`values.yaml` files for the charts can be found in the `charts/[chartname]` directories.

## Pre-requisites

If you want to use the postgres bootstrap job, you need to create a secret with the name `<release-name>-n8n-postgres-bootstrap` in the namespace where you want to install n8n. The secret must contain the following

```bash
kubectl -n <ns> create secret generic postgres-admin \
  --from-literal=username=postgres \
  --from-literal=password='<ADMIN_PASS>'
```

Or you can create db,user and password manually and disable bootstrap job

```sql
-- connect as an admin/superuser via psql
-- 1) role
CREATE ROLE n8n LOGIN PASSWORD 'REPLACE_WITH_STRONG_PASSWORD';

-- 2) database owned by that role
CREATE DATABASE n8n OWNER n8n ENCODING 'UTF8';

-- 3) lock down defaults
REVOKE ALL ON DATABASE n8n FROM PUBLIC;
GRANT CONNECT, TEMPORARY ON DATABASE n8n TO n8n;

-- 4) inside the new DB, ensure the schema is owned by n8n
\c n8n
ALTER SCHEMA public OWNER TO n8n;
REVOKE ALL ON SCHEMA public FROM PUBLIC;
GRANT USAGE, CREATE ON SCHEMA public TO n8n;
```

## TL;DR

```bash
helm repo add janip81 https://janip81.github.io/helm-charts/
helm install my-app-name janip81/n8n -f YOU-OWN-VALUES.yaml
```

[Helm](https://helm.sh) must be installed to use the charts.  Please refer to
Helm's [documentation](https://helm.sh/docs) to get started.

If you had already added this repo earlier, run `helm repo update` to retrieve
the latest versions of the packages.  You can then run `helm search repo
<alias>` to see the charts.

To install the <chart-name> chart:

    helm install my-<chart-name> <alias>/<chart-name>

To uninstall the chart:

    helm delete my-<chart-name>

## Prerequisites

- [Kubernetes](https://kubernetes.io/)
- [Helm 3.1.0](https://helm.sh)
- PV provisioner support in the underlying infrastructure (for persistent storage)
- LoadBalancer support or an Ingress controller

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| env.GENERIC_TIMEZONE | string | `"Europe/Stockholm"` |  |
| env.N8N_DIAGNOSTICS_ENABLED | string | `"false"` |  |
| env.N8N_HOST | string | `"n8n.example.com"` |  |
| env.N8N_METRICS | string | `"true"` |  |
| env.N8N_PORT | string | `"5678"` |  |
| env.N8N_PROTOCOL | string | `"https"` |  |
| env.WEBHOOK_URL | string | `""` |  |
| fullnameOverride | string | `""` |  |
| gatewayApi.enabled | bool | `false` |  |
| gatewayApi.host | string | `"n8n.example.com"` |  |
| gatewayApi.parentRefs[0].name | string | `"cilium-gateway"` |  |
| gatewayApi.parentRefs[0].namespace | string | `""` |  |
| gatewayApi.tls.enabled | bool | `false` |  |
| gatewayApi.tls.secretName | string | `""` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"n8nio/n8n"` |  |
| image.tag | string | `"latest"` |  |
| ingress.annotations | object | `{}` |  |
| ingress.className | string | `""` |  |
| ingress.enabled | bool | `false` |  |
| ingress.hosts[0].host | string | `"n8n.example.com"` |  |
| ingress.hosts[0].paths[0].path | string | `"/"` |  |
| ingress.hosts[0].paths[0].pathType | string | `"Prefix"` |  |
| ingress.tls | list | `[]` |  |
| metrics.enabled | bool | `false` |  |
| metrics.serviceMonitor.enabled | bool | `false` |  |
| metrics.serviceMonitor.interval | string | `"30s"` |  |
| metrics.serviceMonitor.labels | object | `{}` |  |
| metrics.serviceMonitor.namespace | string | `""` |  |
| metrics.serviceMonitor.path | string | `"/metrics"` |  |
| metrics.serviceMonitor.portName | string | `"http"` |  |
| metrics.serviceMonitor.scheme | string | `"http"` |  |
| metrics.serviceMonitor.scrapeTimeout | string | `"10s"` |  |
| metrics.serviceMonitor.tlsConfig | object | `{}` |  |
| nameOverride | string | `""` |  |
| nodeSelector | object | `{}` |  |
| persistence.accessModes[0] | string | `"ReadWriteOnce"` |  |
| persistence.enabled | bool | `false` |  |
| persistence.size | string | `"5Gi"` |  |
| persistence.storageClass | string | `""` |  |
| podAnnotations | object | `{}` |  |
| podSecurityContext | object | `{}` |  |
| postgres.bootstrap.admin.host | string | `""` |  |
| postgres.bootstrap.admin.port | int | `5432` |  |
| postgres.bootstrap.admin.userSecret.keyPassword | string | `"password"` |  |
| postgres.bootstrap.admin.userSecret.keyUser | string | `"username"` |  |
| postgres.bootstrap.admin.userSecret.name | string | `"postgres-admin"` |  |
| postgres.bootstrap.annotations | object | `{}` |  |
| postgres.bootstrap.backoffLimit | int | `2` |  |
| postgres.bootstrap.enabled | bool | `false` |  |
| postgres.bootstrap.image | string | `"bitnami/postgresql:16"` |  |
| postgres.database | string | `"n8n"` |  |
| postgres.host | string | `"postgres.postgres.svc.cluster.local"` |  |
| postgres.passwordSecret.key | string | `"password"` |  |
| postgres.passwordSecret.name | string | `"n8n-db"` |  |
| postgres.port | int | `5432` |  |
| postgres.schema | string | `"public"` |  |
| postgres.ssl.caSecretName | string | `""` |  |
| postgres.ssl.enabled | bool | `false` |  |
| postgres.ssl.rejectUnauthorized | string | `"true"` |  |
| postgres.type | string | `"postgresdb"` |  |
| postgres.user | string | `"n8n"` |  |
| replicaCount | int | `1` |  |
| resources | object | `{}` |  |
| secrets.create | bool | `true` |  |
| secrets.database.annotations | object | `{}` |  |
| secrets.database.key | string | `"password"` |  |
| secrets.database.name | string | `"n8n-db"` |  |
| secrets.database.value | string | `""` |  |
| secrets.encryption.annotations | object | `{}` |  |
| secrets.encryption.key | string | `"encryptionKey"` |  |
| secrets.encryption.name | string | `"n8n-encryption"` |  |
| secrets.encryption.value | string | `""` |  |
| secrets.extra | list | `[]` |  |
| secrets.useStringData | bool | `true` |  |
| securityContext | object | `{}` |  |
| service.annotations | object | `{}` |  |
| service.port | int | `5678` |  |
| service.type | string | `"ClusterIP"` |  |
| tolerations | list | `[]` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)