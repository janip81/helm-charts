# home-assistant

![Version: 0.0.1](https://img.shields.io/badge/Version-0.0.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.0.1](https://img.shields.io/badge/AppVersion-0.0.1-informational?style=flat-square)

An unofficial Helm chart to deploy Home Assistant

**Homepage:** <https://github.com/janip81/helm-charts/tree/main/charts/home-assistant>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Jani Pesonen | <jani@techmonkeys.se> | <https://github.com/janip81> |

## Source Code

* <https://github.com/janip81/helm-charts/tree/main/charts/home-assistant/>

# Overview
Helm-chart for deploying Home Assistant

## Adding this helm repository

To add the helm repository, run the following commands:

```bash
helm repo add janip81 https://janip81.github.io/helm-charts/
helm search repo home-assistant
```

`values.yaml` files for the charts can be found in the `charts/[chartname]` directories.

## TL;DR

```bash
helm repo add janip81 https://janip81.github.io/helm-charts/
helm install my-cluster-name janip81/home-assistant -f YOU-OWN-VALUES.yaml
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
| addons.codeserver.args[0] | string | `"--auth"` |  |
| addons.codeserver.args[1] | string | `"none"` |  |
| addons.codeserver.args[2] | string | `"--user-data-dir"` |  |
| addons.codeserver.args[3] | string | `"/config/.vscode"` |  |
| addons.codeserver.args[4] | string | `"--extensions-dir"` |  |
| addons.codeserver.args[5] | string | `"/config/.vscode"` |  |
| addons.codeserver.args[6] | string | `"--port"` |  |
| addons.codeserver.args[7] | string | `"12321"` |  |
| addons.codeserver.args[8] | string | `"/config"` |  |
| addons.codeserver.enabled | bool | `true` |  |
| addons.codeserver.httpRoute.enabled | bool | `true` |  |
| addons.codeserver.httpRoute.gateway | string | `"internal-shared"` |  |
| addons.codeserver.httpRoute.hostname | string | `"vshass.domain.com"` |  |
| addons.codeserver.image.imagePullPolicy | string | `"IfNotPresent"` |  |
| addons.codeserver.image.repository | string | `"codercom/code-server"` |  |
| addons.codeserver.image.tag | string | `"4.7.1"` |  |
| addons.codeserver.ingress.annotations."kubernetes.io/ingress.class" | string | `"haproxy"` |  |
| addons.codeserver.ingress.enabled | bool | `false` |  |
| addons.codeserver.ingress.ingressClassName | string | `"nginx-example"` |  |
| addons.codeserver.ingress.rules[0].host | string | `"hass.domain.com"` |  |
| addons.codeserver.ingress.rules[0].http.paths[0].backend.service.name | string | `"test"` |  |
| addons.codeserver.ingress.rules[0].http.paths[0].backend.service.port.number | int | `12321` |  |
| addons.codeserver.ingress.rules[0].http.paths[0].path | string | `"/"` |  |
| addons.codeserver.ingress.rules[0].http.paths[0].pathType | string | `"Prefix"` |  |
| addons.codeserver.ingress.tls | list | `[]` |  |
| addons.codeserver.resources | object | `{}` |  |
| addons.codeserver.securityContext.capabilities.drop[0] | string | `"all"` |  |
| addons.codeserver.securityContext.readOnlyRootFilesystem | bool | `true` |  |
| addons.codeserver.service.port | int | `12321` |  |
| addons.codeserver.service.type | string | `"ClusterIP"` |  |
| addons.codeserver.volumeMounts[0].mountPath | string | `"/config"` |  |
| addons.codeserver.volumeMounts[0].name | string | `"config"` |  |
| addons.codeserver.workingDir | string | `"/config"` |  |
| httpRoute.enabled | bool | `false` |  |
| httpRoute.externalGateway | string | `""` |  |
| httpRoute.hostname | string | `"hass.domain.com"` |  |
| httpRoute.internalGateway | string | `""` |  |
| image.imagePullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"ghcr.io/home-assistant/home-assistant"` |  |
| image.tag | string | `"2023.10.1"` |  |
| ingress.annotations."haproxy.org/forwarded-for" | string | `"true"` |  |
| ingress.annotations."kubernetes.io/ingress.class" | string | `"haproxy"` |  |
| ingress.annotations."nginx.ingress.kubernetes.io/rewrite-target" | string | `"/"` |  |
| ingress.enabled | bool | `false` |  |
| ingress.hosts.backend.service.name | string | `"test"` |  |
| ingress.hosts.backend.service.portnumber | int | `8123` |  |
| ingress.hosts.name | string | `"hass.domain.com"` |  |
| ingress.hosts.path | string | `"/"` |  |
| ingress.hosts.pathType | string | `"Prefix"` |  |
| ingress.ingressClassName | string | `"nginx-example"` |  |
| ingress.tls | list | `[]` |  |
| metrics.serviceMonitor.bearerTokenFile | string | `nil` |  |
| metrics.serviceMonitor.bearerTokenSecret.key | string | `"azt2FBZ5GBshXpYYZ7_Vku6qSwhZeRP8iyQWBNfWaIU"` |  |
| metrics.serviceMonitor.bearerTokenSecret.name | string | `"prometheus"` |  |
| metrics.serviceMonitor.enabled | bool | `true` |  |
| metrics.serviceMonitor.interval | string | `"1m"` |  |
| metrics.serviceMonitor.labels | object | `{}` |  |
| metrics.serviceMonitor.scrapeTimeout | string | `nil` |  |
| persistence.config.accessMode | string | `"ReadWriteOnce"` |  |
| persistence.config.size | string | `"10Gi"` |  |
| persistence.config.storageClass | string | `"storageclass"` |  |
| persistence.enabled | bool | `true` |  |
| podSecurityContext | string | `nil` |  |
| probes.liveness.failureThreshold | int | `3` |  |
| probes.liveness.periodSeconds | int | `10` |  |
| probes.liveness.tcpSocket.port | int | `8123` |  |
| probes.liveness.timeoutSeconds | int | `1` |  |
| probes.readiness.failureThreshold | int | `3` |  |
| probes.readiness.periodSeconds | int | `10` |  |
| probes.readiness.tcpSocket.port | int | `8123` |  |
| probes.readiness.timeoutSeconds | int | `1` |  |
| probes.startup.failureThreshold | int | `30` |  |
| probes.startup.periodSeconds | int | `5` |  |
| probes.startup.tcpSocket.port | int | `8123` |  |
| probes.startup.timeoutSeconds | int | `1` |  |
| resources.limits.cpu | string | `"500m"` |  |
| resources.limits.memory | string | `"1024Mi"` |  |
| resources.requests.cpu | string | `"20m"` |  |
| resources.requests.memory | string | `"512Mi"` |  |
| securityContext.capabilities | string | `nil` |  |
| securityContext.readOnlyRootFilesystem | bool | `false` |  |
| service.port | int | `8123` |  |
| service.type | string | `"ClusterIP"` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)