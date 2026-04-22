# unifi-network-application

![Version: 0.2.0](https://img.shields.io/badge/Version-0.2.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 10.3.55](https://img.shields.io/badge/AppVersion-10.3.55-informational?style=flat-square)

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
- **linuxserver/unifi-network-application** container (actively maintained, tracks latest UniFi releases)
- **Bundled MongoDB 7.0** deployment (no external database required)
- A single **LoadBalancer** service exposing all required ports: HTTPS web UI (8443/TCP), AP device communication (8080/TCP), STUN (3478/UDP), L2 discovery (10001/UDP), speed test (6789/TCP)
- Init container that waits for MongoDB before starting the controller
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
| env.PGID | string | `"1000"` | Group ID the application runs as |
| env.PUID | string | `"1000"` | User ID the application runs as |
| env.TZ | string | `"Europe/Stockholm"` | Timezone |
| fullnameOverride | string | `""` | Override the full name of all resources. Recommended: set to a short name like "unifi" |
| httproute.annotations | object | `{"argocd.argoproj.io/sync-options":"SkipDryRunOnMissingResource=true"}` | Annotations for the HTTPRoute |
| httproute.enabled | bool | `false` | Enable HTTPRoute for the web UI |
| httproute.gatewayName | string | `"internal-shared"` | Gateway name |
| httproute.gatewayNamespace | string | `"kube-system"` | Gateway namespace |
| httproute.hostname | string | `"unifi.mgmt.threshold.se"` | Hostname for the HTTPRoute |
| image.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| image.repository | string | `"lscr.io/linuxserver/unifi-network-application"` | Docker registry/repository to pull the image from |
| image.tag | string | `"10.3.55"` | Image tag |
| mongodb.auth | object | `{"enabled":false,"password":"unifipass","username":"unifi"}` | MongoDB authentication. Disabled by default (internal cluster service only) |
| mongodb.auth.enabled | bool | `false` | Enable MongoDB authentication |
| mongodb.auth.password | string | `"unifipass"` | MongoDB password (only used when auth.enabled is true) |
| mongodb.auth.username | string | `"unifi"` | MongoDB username (only used when auth.enabled is true) |
| mongodb.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| mongodb.image.repository | string | `"mongo"` | MongoDB image repository |
| mongodb.image.tag | string | `"7.0"` | MongoDB image tag. Must be 6.x or 7.x for UniFi 9+ |
| mongodb.persistence.accessMode | string | `"ReadWriteOnce"` | Access mode for the PVC |
| mongodb.persistence.enabled | bool | `true` | Enable persistent storage for MongoDB data |
| mongodb.persistence.size | string | `"2Gi"` | Size of the MongoDB PVC |
| mongodb.persistence.storageClass | string | `""` | Storage class name. Leave empty to use the cluster default |
| mongodb.resources | object | `{"limits":{"cpu":"500m","memory":"512Mi"},"requests":{"cpu":"50m","memory":"256Mi"}}` | MongoDB resource requests and limits |
| nodeSelector | object | `{}` | Node selector for pod scheduling |
| persistence.accessMode | string | `"ReadWriteOnce"` | Access mode for the PVC |
| persistence.enabled | bool | `true` | Enable persistent storage for UniFi config/data |
| persistence.size | string | `"5Gi"` | Size of the PVC |
| persistence.storageClass | string | `""` | Storage class name. Leave empty to use the cluster default |
| podSecurityContext | object | `{}` | Pod security context |
| resources | object | `{"limits":{"cpu":"1000m","memory":"1024Mi"},"requests":{"cpu":"100m","memory":"512Mi"}}` | Resource requests and limits for the UniFi container |
| securityContext | object | `{"allowPrivilegeEscalation":false,"readOnlyRootFilesystem":false,"runAsNonRoot":false}` | Container security context |
| service.annotations | object | `{}` | Annotations for the service (e.g. for Cilium IP pool selection) |
| service.ports | list | `[{"name":"http","port":8443,"protocol":"TCP"},{"name":"controller","port":8080,"protocol":"TCP"},{"name":"stun","port":3478,"protocol":"UDP"},{"name":"discovery","port":10001,"protocol":"UDP"},{"name":"speedtest","port":6789,"protocol":"TCP"}]` | Ports exposed by the service. 8443/TCP: HTTPS web UI 8080/TCP: AP device communication (inform) 3478/UDP: STUN (required for AP tunnelling and provisioning) 10001/UDP: L2 device discovery (works only on same broadcast domain) 6789/TCP: UniFi mobile speed test (optional) |
| service.type | string | `"LoadBalancer"` | Service type. LoadBalancer exposes all ports (UI + AP device communication) |
| tolerations | list | `[]` | Tolerations for pod scheduling |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
