# backup-operator

![Version: 0.4.1](https://img.shields.io/badge/Version-0.4.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.4.0](https://img.shields.io/badge/AppVersion-0.4.0-informational?style=flat-square)

Kubernetes operator that backs up PersistentVolume data as versioned, encrypted restic snapshots, with plugins that choose what to keep

**Homepage:** <https://github.com/janip81/helm-charts/tree/main/charts/backup-operator>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| janip81 |  | <https://github.com/janip81> |

## Source Code

* <https://github.com/janip81/helm-charts/tree/main/charts/backup-operator/>
* <https://github.com/janip81/backup-operator>

# Overview

Installs [backup-operator](https://github.com/janip81/backup-operator): CRDs (`BackupSchedule`,
`BackupRequest`, `Backup`), a least-privilege ClusterRole, the controller, and optionally a
ServiceMonitor, alert rules and a Grafana dashboard.

Each run snapshots a PersistentVolume, mounts a read-only copy in a short-lived worker Job, and a
plugin (`files`, `archives`, `sqlite` or `custom`) decides what is stored as a versioned, encrypted
restic snapshot in S3, a REST server or over SFTP.

## Adding this helm repository

```bash
helm repo add janip81 https://janip81.github.io/helm-charts/
helm install backup-operator janip81/backup-operator -n backup-operator --create-namespace
```

## Notes

- **CRDs** are rendered from templates (`crds.enabled`), so `helm upgrade` and Argo CD's Helm plugins
  upgrade them too. They carry `helm.sh/resource-policy: keep` (`crds.keep`): an uninstall never
  deletes them, because that would delete every Backup record and schedule.
- **One replica only** (`replicaCount` 0 or 1). Use 0 to pause the operator.
- **Private images:** set `imagePullSecrets` for the controller and `worker.imagePullSecret` to a
  pull secret that exists in every namespace with backups.
- **Worker pods** run as root with only `DAC_READ_SEARCH` by default, which needs Pod Security
  "privileged" in the app's namespace (or run non-root per schedule, see the operator README).
- Upgrading from v0.3: [docs/upgrade-0.4.md](https://github.com/janip81/backup-operator/blob/main/docs/upgrade-0.4.md).
- CRDs, rules and dashboard are copied from the operator repo with `hack/sync.sh <ref>`.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| config | object | `{}` | Controller settings as environment variables, e.g. MAX_CONCURRENT_RUNS, MAX_SNAPSHOTS_PER_PVC, DEFAULT_MAX_ATTEMPTS, DEFAULT_STORAGE_CLASS, JOB_TIMEOUT_SECONDS. Unset means the operator default; see the backup-operator README. |
| crds.enabled | bool | `true` | Install and upgrade the CRDs with the chart (rendered from templates, so `helm upgrade` and Argo CD's Helm plugins update them too) |
| crds.keep | bool | `true` | Keep the CRDs on uninstall; deleting them would delete every Backup record and schedule |
| dashboard.annotations | object | `{}` |  |
| dashboard.enabled | bool | `false` | Create the Grafana dashboard as a ConfigMap for the Grafana sidecar |
| dashboard.labels.grafana_dashboard | string | `"1"` |  |
| dashboard.namespace | string | `""` | Namespace for the dashboard ConfigMap (defaults to the release namespace) |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"ghcr.io/janip81/backup-operator-controller"` | Controller image |
| image.tag | string | `""` | Image tag; defaults to the chart's appVersion. Pin a release or `sha-<commit>` tag. |
| imagePullSecrets | list | `[]` | Pull secrets for the controller pod (in the release namespace) |
| nodeSelector | object | `{}` |  |
| podAnnotations | object | `{}` |  |
| prometheusRule.enabled | bool | `false` | Create the alert rules (stale or failed backups, runaway snapshots/requests, operator health) |
| prometheusRule.labels | object | `{}` | Labels your Prometheus selects rules by |
| replicaCount | int | `1` | Number of controller replicas: 1, or 0 to pause the operator. Never more than one: admission control is in-process. |
| resources.limits.memory | string | `"256Mi"` |  |
| resources.requests.cpu | string | `"50m"` |  |
| resources.requests.memory | string | `"128Mi"` |  |
| serviceMonitor.clusterLabel | string | `""` | If set, add a `k8s_cluster` label with this value to every scraped series |
| serviceMonitor.enabled | bool | `false` | Create a ServiceMonitor (Prometheus Operator) |
| serviceMonitor.interval | string | `"30s"` |  |
| serviceMonitor.labels | object | `{}` | Labels your Prometheus selects ServiceMonitors by |
| tolerations | list | `[]` |  |
| worker.image.repository | string | `"ghcr.io/janip81/backup-operator-worker"` | Worker image (restic and the plugins), run as a Job in the backed-up app's namespace |
| worker.image.tag | string | `""` | Worker image tag; defaults to the chart's appVersion |
| worker.imagePullSecret | string | `""` | Name of a pull secret that must exist in every namespace with backups (worker Jobs use it) |
