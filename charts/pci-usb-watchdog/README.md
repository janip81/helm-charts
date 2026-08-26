# pci-usb-watchdog

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.1.0](https://img.shields.io/badge/AppVersion-0.1.0-informational?style=flat-square)

Detects PCI-passthrough USB device failures (e.g. Coral Edge TPU, Zigbee dongles) across one or more Kubernetes clusters and alerts via Prometheus + MQTT

**Homepage:** <https://github.com/janip81/helm-charts/tree/main/charts/pci-usb-watchdog>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| janip81 | <jani@techmonkeys.se> | <https://github.com/janip81> |

## Source Code

* <https://github.com/janip81/helm-charts/tree/main/charts/pci-usb-watchdog>

# Overview
Helm chart for deploying pci-usb-watchdog: a small poller that watches Kubernetes
workloads whose containers depend on a PCI-passthrough USB device (e.g. a Coral
Edge TPU used by Frigate, a Zigbee/Zwave USB dongle) and alerts via Prometheus
metrics and MQTT when the device's workload goes unhealthy -- catching the class
of failure where the passthrough USB controller dies on the hypervisor side and
the container just crash-loops with no clear signal until someone notices.

Each entry in `clusters` needs exactly one of `kubeconfigSecret` (mount an
existing kubeconfig Secret already living in this release's namespace -- e.g. a
CAPI-generated `<cluster>-kubeconfig` Secret) or `inCluster: true` (use this
pod's own ServiceAccount, requires `rbac.create: true`).

## Adding this helm repository

To add the helm repository, run the following commands:

```bash
helm repo add janip81 https://janip81.github.io/helm-charts/
helm search repo pci-usb-watchdog
```

`values.yaml` files for the charts can be found in the `charts/[chartname]` directories.

## TL;DR

```bash
helm repo add janip81 https://janip81.github.io/helm-charts/
helm install my-app-name janip81/pci-usb-watchdog -f YOUR-OWN-VALUES.yaml
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

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| clusters | list | `[{"kubeconfigSecret":{"key":"value","name":"prod-k8s-kubeconfig"},"name":"prod-k8s","node":"prod-k8s-pci-node-6xx5v-krjsp"}]` | Clusters this watchdog can watch. Each cluster needs exactly one of `kubeconfigSecret` (mount an existing kubeconfig Secret, e.g. a CAPI-generated `<cluster>-kubeconfig` Secret already living in this release's namespace) or `inCluster: true` (use this pod's own ServiceAccount -- requires rbac.create: true). |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"ghcr.io/janip81/pci-usb-watchdog"` |  |
| image.tag | string | `"latest"` |  |
| metrics.port | int | `8000` |  |
| mqtt.createSecret | bool | `false` | If true, render a Secret from mqtt.username / mqtt.password below |
| mqtt.existingSecret | string | `""` | Name of an existing Secret with MQTT_USER / MQTT_PASSWORD keys. Takes precedence over createSecret. |
| mqtt.host | string | `"mosquitto.mqtt.svc.cluster.local"` |  |
| mqtt.password | string | `""` |  |
| mqtt.port | int | `1883` |  |
| mqtt.topicPrefix | string | `"homelab/pci-watchdog"` |  |
| mqtt.username | string | `""` |  |
| nodeSelector | object | `{}` |  |
| podAnnotations | object | `{}` |  |
| pollIntervalSeconds | int | `60` | Seconds between poll cycles |
| rbac.create | bool | `false` | Only needed if any entry in `clusters` sets `inCluster: true` |
| replicaCount | int | `1` |  |
| resources.limits.memory | string | `"128Mi"` |  |
| resources.requests.cpu | string | `"25m"` |  |
| resources.requests.memory | string | `"64Mi"` |  |
| service.enabled | bool | `true` |  |
| service.port | int | `8000` |  |
| serviceMonitor.enabled | bool | `false` |  |
| serviceMonitor.interval | string | `"30s"` |  |
| serviceMonitor.labels.release | string | `"prometheus"` |  |
| serviceMonitor.namespace | string | `""` |  |
| serviceMonitor.scrapeTimeout | string | `"10s"` |  |
| targets | list | `[{"cluster":"prod-k8s","device":"Coral Edge TPU","namespace":"frigate","signatures":["No EdgeTPU was detected","HC died"],"workloadKind":"Deployment","workloadName":"frigate"},{"cluster":"prod-k8s","device":"Sonoff Zigbee Dongle","namespace":"zigbee2mqtt","signatures":[],"workloadKind":"StatefulSet","workloadName":"zigbee2mqtt"}]` | Workloads to watch for PCI-passthrough USB device failures. `signatures` is a list of case-sensitive substrings matched against container logs; an empty list means "watch for crashes/restarts but there's no known log signature to confirm the root cause yet" (still alerts, with reason=unknown). |
| tolerations | list | `[]` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
