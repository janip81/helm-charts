# unifi-network-application

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: stable](https://img.shields.io/badge/AppVersion-stable-informational?style=flat-square)

Helm chart for the UniFi Network Application (WiFi controller)

**Homepage:** <https://github.com/janip81/helm-charts/tree/main/charts/unifi-network-application>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| janip81 | <jani@techmonkeys.se> | <https://github.com/janip81> |

## Source Code

* <https://github.com/janip81/helm-charts/tree/main/charts/unifi-network-application/>
* <https://github.com/jacobalberty/unifi-docker>

# Overview
Helm chart for the UniFi Network Application (WiFi controller) using the `jacobalberty/unifi` image,
which bundles MongoDB and the controller in a single container.

Includes:
- A single **LoadBalancer** service exposing all required ports: HTTPS web UI (8443/TCP), AP device communication (8080/TCP), STUN (3478/UDP), L2 discovery (10001/UDP), speed test (6789/TCP)
- Optional **HTTPRoute** for Cilium Gateway API (disabled by default — requires BackendTLSPolicy for HTTPS backend)

## Adding this helm repository

To add the helm repository, run the following commands:

```bash
helm repo add janip81 https://janip81.github.io/helm-charts/
helm search repo unifi-network-application
```

`values.yaml` files for the charts can be found in the `charts/[chartname]` directories.

## TL;DR

```bash
helm repo add janip81 https://janip81.github.io/helm-charts/
helm install my-unifi janip81/unifi-network-application -f YOUR-OWN-VALUES.yaml
```

[Helm](https://helm.sh) must be installed to use the charts. Please refer to
Helm's [documentation](https://helm.sh/docs) to get started.

## Prerequisites

- [Kubernetes](https://kubernetes.io/)
- [Helm 3.1.0](https://helm.sh)
- PV provisioner support in the underlying infrastructure (for persistent storage)
- LoadBalancer support in the underlying infrastructure (for device communication)

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Affinity rules for pod scheduling |
| env.JVM_MAX_HEAP_SIZE | string | `"1024M"` | JVM maximum heap size. Increase for larger installations |
| env.RUNAS_UID0 | string | `"false"` | Run as root (set to "true" only if required) |
| env.TZ | string | `"Europe/Stockholm"` | Timezone for the controller |
| env.UNIFI_GID | string | `"999"` | GID the application runs as |
| env.UNIFI_UID | string | `"999"` | UID the application runs as |
| httproute.annotations | object | `{"argocd.argoproj.io/sync-options":"SkipDryRunOnMissingResource=true"}` | Annotations for the HTTPRoute |
| httproute.enabled | bool | `false` | Enable HTTPRoute for the web UI |
| httproute.gatewayName | string | `"internal-shared"` | Gateway name to attach the HTTPRoute to |
| httproute.gatewayNamespace | string | `"kube-system"` | Namespace of the gateway |
| httproute.hostname | string | `"unifi.mgmt.threshold.se"` | Hostname for the HTTPRoute |
| image.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| image.repository | string | `"jacobalberty/unifi"` | Docker registry/repository to pull the image from |
| image.tag | string | `"stable"` | Image tag. Uses `stable` by default; pin to a specific version (e.g. `v9.0.108`) for production |
| nodeSelector | object | `{}` | Node selector for pod scheduling |
| persistence.accessMode | string | `"ReadWriteOnce"` | Access mode for the PVC |
| persistence.enabled | bool | `true` | Enable persistent storage for UniFi data |
| persistence.size | string | `"5Gi"` | Size of the PVC |
| persistence.storageClass | string | `""` | Storage class name. Leave empty to use the cluster default |
| podSecurityContext | object | `{"fsGroup":999}` | Pod security context |
| resources | object | `{"limits":{"cpu":"1000m","memory":"1024Mi"},"requests":{"cpu":"100m","memory":"512Mi"}}` | Resource requests and limits |
| securityContext | object | `{"allowPrivilegeEscalation":false,"readOnlyRootFilesystem":false,"runAsGroup":999,"runAsNonRoot":true,"runAsUser":999}` | Container security context |
| service.annotations | object | `{}` | Annotations for the service (e.g. for Cilium IP pool selection) |
| service.ports | list | `[{"name":"http","port":8443,"protocol":"TCP"},{"name":"controller","port":8080,"protocol":"TCP"},{"name":"stun","port":3478,"protocol":"UDP"},{"name":"discovery","port":10001,"protocol":"UDP"},{"name":"speedtest","port":6789,"protocol":"TCP"}]` | Ports exposed by the service. All ports required for full UniFi AP management are included by default. 8443/TCP: HTTPS web UI 8080/TCP: AP device communication (inform) 3478/UDP: STUN (required for AP tunnelling and provisioning) 10001/UDP: L2 device discovery (works only on same broadcast domain) 6789/TCP: UniFi mobile speed test (optional) |
| service.type | string | `"LoadBalancer"` | Service type. LoadBalancer is required so both the web UI and AP device communication ports are reachable from outside the cluster. |
| tolerations | list | `[]` | Tolerations for pod scheduling |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
