# ghost

![Version: 0.1.1](https://img.shields.io/badge/Version-0.1.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 6.32.0](https://img.shields.io/badge/AppVersion-6.32.0-informational?style=flat-square)

Ghost blogging platform with external MySQL/MariaDB

**Homepage:** <https://github.com/janip81/helm-charts/tree/main/charts/ghost>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| janip81 | <jani@techmonkeys.se> | <https://github.com/janip81> |

## Source Code

* <https://github.com/janip81/helm-charts/tree/main/charts/ghost/>
* <https://hub.docker.com/_/ghost>

# Overview

Helm chart for deploying [Ghost](https://ghost.org/) — an open-source blogging and publishing platform.

This chart deploys Ghost against an **external MySQL/MariaDB** database. It does not bundle a database; pair it with a MariaDB deployment (e.g. `groundhog2k/mariadb`) or any MySQL-compatible instance.

## Adding this helm repository

```bash
helm repo add janip81 https://janip81.github.io/helm-charts/
helm search repo ghost
```

## Pre-requisites

- A running MySQL 8.x or MariaDB 10.3+ instance reachable from the cluster
- A Kubernetes Secret containing the database password, e.g.:

```bash
kubectl -n ghost create secret generic ghost-db \
  --from-literal=MARIADB_PASSWORD='<db-password>'
```

Or via ArgoCD Vault Plugin (AVP):

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: ghost-db
  namespace: ghost
  annotations:
    avp.kubernetes.io/path: "kubernetes/data/prod-k8s/ghost"
type: Opaque
stringData:
  MARIADB_ROOT_PASSWORD: <path:kubernetes/data/prod-k8s/ghost#mariadb-root-password>
  MARIADB_DATABASE: ghost
  MARIADB_USER: ghost
  MARIADB_PASSWORD: <path:kubernetes/data/prod-k8s/ghost#mariadb-password>
```

## TL;DR

```bash
helm repo add janip81 https://janip81.github.io/helm-charts/
helm install ghost janip81/ghost \
  --set settings.url=https://blog.example.com \
  --set database.host=my-mariadb.ghost.svc.cluster.local \
  --set database.passwordSecret.name=ghost-db \
  --set persistence.enabled=true \
  --set persistence.storageClass=my-storage-class
```

## First-run setup

After Ghost starts, visit `<settings.url>/ghost` to complete the admin account wizard.

## Gateway API (HTTPRoute)

Enable the built-in HTTPRoute for Gateway API:

```yaml
gatewayApi:
  enabled: true
  host: blog.example.com
  parentRefs:
    - name: my-gateway
      namespace: kube-system
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| database.client | string | `"mysql"` |  |
| database.host | string | `""` |  |
| database.name | string | `"ghost"` |  |
| database.passwordSecret.key | string | `"MARIADB_PASSWORD"` |  |
| database.passwordSecret.name | string | `""` |  |
| database.port | int | `3306` |  |
| database.user | string | `"ghost"` |  |
| fullnameOverride | string | `""` |  |
| gatewayApi.enabled | bool | `false` |  |
| gatewayApi.host | string | `""` |  |
| gatewayApi.parentRefs[0].name | string | `"internal-shared"` |  |
| gatewayApi.parentRefs[0].namespace | string | `"kube-system"` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"ghost"` |  |
| image.tag | string | `""` |  |
| livenessProbe.failureThreshold | int | `3` |  |
| livenessProbe.periodSeconds | int | `30` |  |
| livenessProbe.timeoutSeconds | int | `5` |  |
| mail.enabled | bool | `false` |  |
| mail.from | string | `""` |  |
| mail.host | string | `""` |  |
| mail.passwordSecret.key | string | `""` |  |
| mail.passwordSecret.name | string | `""` |  |
| mail.port | int | `587` |  |
| mail.secure | bool | `false` |  |
| mail.transport | string | `"SMTP"` |  |
| mail.user | string | `""` |  |
| nameOverride | string | `""` |  |
| nodeSelector | object | `{}` |  |
| persistence.accessModes[0] | string | `"ReadWriteOnce"` |  |
| persistence.enabled | bool | `false` |  |
| persistence.size | string | `"5Gi"` |  |
| persistence.storageClass | string | `""` |  |
| podAnnotations | object | `{}` |  |
| podSecurityContext.fsGroup | int | `1000` |  |
| readinessProbe.failureThreshold | int | `3` |  |
| readinessProbe.periodSeconds | int | `10` |  |
| readinessProbe.timeoutSeconds | int | `5` |  |
| replicaCount | int | `1` |  |
| resources | object | `{}` |  |
| securityContext.allowPrivilegeEscalation | bool | `false` |  |
| securityContext.runAsGroup | int | `1000` |  |
| securityContext.runAsNonRoot | bool | `true` |  |
| securityContext.runAsUser | int | `1000` |  |
| service.port | int | `80` |  |
| service.type | string | `"ClusterIP"` |  |
| settings.url | string | `"http://localhost"` |  |
| startupProbe.failureThreshold | int | `30` |  |
| startupProbe.initialDelaySeconds | int | `30` |  |
| startupProbe.periodSeconds | int | `10` |  |
| startupProbe.timeoutSeconds | int | `5` |  |
| tolerations | list | `[]` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
