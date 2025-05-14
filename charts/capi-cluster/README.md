# capi-cluster

![Version: 0.0.42](https://img.shields.io/badge/Version-0.0.42-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.0.8](https://img.shields.io/badge/AppVersion-0.0.8-informational?style=flat-square)

An unofficial Helm chart to deploy workload cluster with Cluster API

**Homepage:** <https://github.com/janip81/helm-charts/tree/main/charts/capi-cluster>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Jani Pesonen | <jani@techmonkeys.se> | <https://github.com/janip81> |

## Source Code

* <https://github.com/janip81/helm-charts/tree/main/charts/capi-cluster>
* <https://github.com/kubernetes-sigs/cluster-api-provider-vsphere>
* <https://github.com/kubernetes-sigs/cluster-api>

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| addons.metricsServer.chart.name | string | `"metrics-server"` |  |
| addons.metricsServer.chart.repo | string | `"https://kubernetes-sigs.github.io/metrics-server"` |  |
| addons.metricsServer.chart.version | string | `"3.8.3"` |  |
| addons.metricsServer.enabled | bool | `false` |  |
| addons.metricsServer.name | string | `"metrics-server"` |  |
| addons.metricsServer.release.namespace | string | `"kube-system"` |  |
| addons.metricsServer.release.values.image.pullPolicy | string | `"IfNotPresent"` |  |
| addons.metricsServer.release.values.image.repository | string | `"registry.k8s.io/metrics-server/metrics-server"` |  |
| addons.metricsServer.release.values.image.tag | string | `""` |  |
| addons.vsphereCPI.chart.name | string | `nil` |  |
| addons.vsphereCPI.chart.repo | string | `nil` |  |
| addons.vsphereCPI.chart.version | string | `nil` |  |
| addons.vsphereCPI.enabled | bool | `false` |  |
| addons.vsphereCPI.name | string | `"vsphere-cpi"` |  |
| addons.vsphereCPI.release.namespace | string | `nil` |  |
| addons.vsphereCPI.release.values | object | `{}` |  |
| cluster.bgpPolicyVlan | string | `"vlan201"` |  |
| cluster.cidrBlocks | string | `"10.245.0.0/16"` |  |
| cluster.controlPlaneEndpoint | string | `"host.domain.com"` |  |
| cluster.name | string | `"clustername"` |  |
| cluster.skipKubeProxy | bool | `true` |  |
| controlPlaneNodes.k8sVersion | string | `"1.33.0"` |  |
| controlPlaneNodes.replicas | int | `3` |  |
| controlPlaneNodes.vspehereMachineTemplate | string | `"ubnt2204-2cpu-4g-128"` |  |
| healthChecks.controlplane.maxUnhealthy | string | `"100%"` |  |
| healthChecks.controlplane.name | string | `"cp-unhealthy-5m"` |  |
| healthChecks.controlplane.nodeStartupTimeout | string | `"10m0s"` |  |
| healthChecks.controlplane.unhealthyTimeoutFalse | string | `"5m0s"` |  |
| healthChecks.controlplane.unhealthyTimeoutUnknown | string | `"5m0s"` |  |
| healthChecks.workernodes.maxUnhealthy | string | `"40%"` |  |
| healthChecks.workernodes.name | string | `"worker-unhealthy-5m"` |  |
| healthChecks.workernodes.nodeStartupTimeout | string | `"10m0s"` |  |
| healthChecks.workernodes.unhealthyTimeoutFalse | string | `"5m0s"` |  |
| healthChecks.workernodes.unhealthyTimeoutUnknown | string | `"5m0s"` |  |
| kubeVIP.image.pullPolicy | string | `"IfNotPresent"` |  |
| kubeVIP.image.repository | string | `"ghcr.io/kube-vip/kube-vip"` |  |
| kubeVIP.image.tag | string | `"v0.8.9"` |  |
| machineDeployments[0].k8sVersion | string | `"1.33.0"` |  |
| machineDeployments[0].machideDeploymentAnnotations | string | `nil` |  |
| machineDeployments[0].name | string | `"md-0"` |  |
| machineDeployments[0].nodeAnnotations | string | `nil` |  |
| machineDeployments[0].nodeLabels."node-role.kubernetes.io/worker" | string | `"true"` |  |
| machineDeployments[0].replicas | int | `2` |  |
| machineDeployments[0].vspehereMachineTemplate | string | `"ubnt2204-4cpu-8g-128"` |  |
| machineDeployments[1].k8sVersion | string | `"1.33.0"` |  |
| machineDeployments[1].machideDeploymentAnnotations."cluster.x-k8s.io/cluster-api-autoscaler-node-group-max-size" | string | `"5"` |  |
| machineDeployments[1].machideDeploymentAnnotations."cluster.x-k8s.io/cluster-api-autoscaler-node-group-min-size" | string | `"0"` |  |
| machineDeployments[1].name | string | `"md-1"` |  |
| machineDeployments[1].nodeAnnotations | string | `nil` |  |
| machineDeployments[1].nodeLabels."node-role.kubernetes.io/worker" | string | `"true"` |  |
| machineDeployments[1].replicas | int | `3` |  |
| machineDeployments[1].vspehereMachineTemplate | string | `"ubnt2204-4cpu-8g-133"` |  |
| machineTemplates[0].cloneMode | string | `"FullClone"` |  |
| machineTemplates[0].cpu | int | `2` |  |
| machineTemplates[0].diskSize | int | `25` |  |
| machineTemplates[0].isoTemplate | string | `"ubuntu-2404-kube-v1.33.0"` |  |
| machineTemplates[0].memory | int | `4096` |  |
| machineTemplates[0].name | string | `"ubnt2204-2cpu-4g-133"` |  |
| machineTemplates[0].network | string | `"vcenterNetwork"` |  |
| machineTemplates[0].storagePolicyName | string | `""` |  |
| machineTemplates[0].vcenterDatastore | string | `"SSD01"` |  |
| machineTemplates[0].vcenterFolder | string | `nil` |  |
| machineTemplates[1].cloneMode | string | `"FullClone"` |  |
| machineTemplates[1].cpu | int | `4` |  |
| machineTemplates[1].diskSize | int | `35` |  |
| machineTemplates[1].isoTemplate | string | `"ubuntu-2404-kube-v1.33.0"` |  |
| machineTemplates[1].memory | int | `8192` |  |
| machineTemplates[1].name | string | `"ubnt2204-4cpu-8g-133"` |  |
| machineTemplates[1].network | string | `"vcenterNetwork"` |  |
| machineTemplates[1].storagePolicyName | string | `""` |  |
| machineTemplates[1].vcenterDatastore | string | `"SSD01"` |  |
| machineTemplates[1].vcenterFolder | string | `nil` |  |
| network.gateway | string | `"192.168.1.1"` |  |
| network.nameserver | string | `"192.168.1.1"` |  |
| network.poolEnd | string | `"192.168.1.254"` |  |
| network.poolStart | string | `"192.168.1.2"` |  |
| network.prefix | string | `"24"` |  |
| node.datastore | string | `"SSD01"` |  |
| node.sshAuthorizedKeys | string | `"PublicKey"` |  |
| node.template | string | `"ubuntu-2404-kube-v1.33.0"` |  |
| podSecurityStandard.audit | string | `"restricted"` |  |
| podSecurityStandard.enabled | bool | `false` |  |
| podSecurityStandard.enforce | string | `"baseline"` |  |
| podSecurityStandard.exemptions.namespaces[0] | string | `"kube-system"` |  |
| podSecurityStandard.warn | string | `"restricted"` |  |
| vsphere.datacenter | string | `"Datacenter"` |  |
| vsphere.insecureFlag | bool | `true` |  |
| vsphere.labels.region | string | `"region"` |  |
| vsphere.labels.zone | string | `"zone"` |  |
| vsphere.password | string | `"password"` |  |
| vsphere.resourcePool | string | `"kubernetes"` |  |
| vsphere.server | string | `"vcenter.domain.com"` |  |
| vsphere.serverIP | string | `"1.2.3.4"` |  |
| vsphere.thumbprint | string | `"thumbprint"` |  |
| vsphere.username | string | `"username"` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
