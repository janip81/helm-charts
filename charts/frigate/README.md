# frigate

![Version: 7.8.0](https://img.shields.io/badge/Version-7.8.0-informational?style=flat-square) ![AppVersion: 0.14.1](https://img.shields.io/badge/AppVersion-0.14.1-informational?style=flat-square)

NVR With Realtime Object Detection for IP Cameras

This Helm Chart installs [Frigate](https://frigate.video/) on to Kubernetes.

**Homepage:** <https://github.com/blakeblackshear/blakeshome-charts/tree/master/charts/frigate>

## DISCLAIMER

This is my modifed fork of the [blakeblackshear/frigate](https://github.com/blakeblackshear/blakeshome-charts/tree/master/charts/frigate) chart. I have made some changes to the values.yaml, configmap.yaml template file and the README.md file to better suit my needs.

## Install

Using [Helm](https://helm.sh), you can easily install and test Frigate in a
Kubernetes cluster by running the following:

#### Add Helm repo

First, add the repo if you haven't already done so:
```bash
helm repo add janip81 https://janip81.github.io/helm-charts/
```

#### Minimum Config

## ONLY NEEDED IF YOU DO NOT MANUALLY CREATE THE CONFIGMAP!!!!

At minimum, you'll need to define the following Frigate configuration properties. For information, see the [Docs](https://docs.frigate.video/configuration/index).

```yaml
# values.yaml
config: |
  mqtt:
    host: "mqtt.example.com"
    port: 1883
    user: admin
    password: "<your_mqtt_password>"
  cameras:
    # Define at least one camera
    back:
      ffmpeg:
        inputs:
          - path: rtsp://viewer:{FRIGATE_RTSP_PASSWORD}@10.0.10.10:554/cam/realmonitor?channel=1&subtype=2
            roles:
              - detect
              - rtmp
      detect:
        width: 1280
        height: 720
```

#### Install Chart

Now install the chart:
```bash
helm upgrade --install \
  my-release \
  janip81/frigate \
  -f values.yaml
```

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| blakeblackshear | <blakeb@blakeshome.com> |  |
| billimek | <jeff@billimek.com> |  |

## Source Code

* <https://github.com/blakeblackshear/frigate>

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Set Pod affinity rules |
| coral.enabled | bool | `false` | enables the use of a Coral device |
| coral.hostPath | string | `"/dev/bus/usb"` | path on the host to which to mount the Coral device |
| env | object | `{}` | additional ENV variables to set. Prefix with FRIGATE_ to target Frigate configuration values |
| envFromSecrets | list | `[]` | set environment variables from Secret(s) |
| extraInitContainers | list | `[]` | Define extra init containers |
| extraVolumeMounts | list | `[]` | declare additional volume mounts |
| extraVolumes | list | `[]` | declare extra volumes to use for Frigate |
| fullnameOverride | string | `""` | Overrides the Full Name of resources |
| gpu.nvidia.enabled | bool | `false` | Enables NVIDIA GPU compatibility. Must also use the "amd64nvidia" tagged image |
| gpu.nvidia.runtimeClassName | string | `nil` | Overrides the default runtimeClassName |
| image.pullPolicy | string | `"IfNotPresent"` | Docker image pull policy |
| image.repository | string | `"ghcr.io/blakeblackshear/frigate"` | Docker registry/repository to pull the image from |
| image.tag | string | `nil` | Overrides the default tag (appVersion) used in Chart.yaml ([Docker Hub](https://hub.docker.com/r/blakeblackshear/frigate/tags?page=1)) |
| imagePullSecrets | list | `[]` | Docker image pull policy |
| ingress.annotations | object | `{}` | annotations to configure your Ingress. See your Ingress Controller's Docs for more info. |
| ingress.enabled | bool | `false` | Enables the use of an Ingress Controller to front the Service and can provide HTTPS |
| ingress.hosts | list | `[{"host":"chart.example.local","paths":[{"path":"/","portName":"http-auth"}]}]` | alternatively use `http` if anonymous auth is allowed |
| ingress.ingressClassName | string | `nil` | ingressClassName for using on clusters with multiple ingresses, default is null |
| ingress.tls | list | `[]` | list of TLS configurations |
| nameOverride | string | `""` | Overrides the name of resources |
| nodeSelector | object | `{}` | Node Selector configuration |
| persistence.config.accessMode | string | `"ReadWriteOnce"` | [access mode](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#access-modes) to use for the PVC |
| persistence.config.enabled | bool | `false` | Enables persistence for the config directory |
| persistence.config.ephemeralWritableConfigYaml | bool | `true` |  |
| persistence.config.size | string | `"100Mi"` | size/capacity of the PVC |
| persistence.config.skipuninstall | bool | `false` | Do not delete the pvc upon helm uninstall |
| persistence.data.accessMode | string | `"ReadWriteOnce"` |  |
| persistence.data.enabled | bool | `false` |  |
| persistence.data.size | string | `"10Gi"` |  |
| persistence.data.skipuninstall | bool | `false` |  |
| persistence.media.accessMode | string | `"ReadWriteOnce"` | [access mode](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#access-modes) to use for the PVC |
| persistence.media.enabled | bool | `false` | Enables persistence for the media directory |
| persistence.media.size | string | `"10Gi"` | size/capacity of the PVC |
| persistence.media.skipuninstall | bool | `false` | Do not delete the pvc upon helm uninstall |
| podAnnotations | object | `{}` | Set additonal pod Annotations |
| podSecurityContext | object | `{}` | will override it for frigate container |
| probes.liveness.enabled | bool | `true` |  |
| probes.liveness.failureThreshold | int | `5` |  |
| probes.liveness.initialDelaySeconds | int | `30` |  |
| probes.liveness.timeoutSeconds | int | `10` |  |
| probes.readiness.enabled | bool | `true` |  |
| probes.readiness.failureThreshold | int | `5` |  |
| probes.readiness.initialDelaySeconds | int | `30` |  |
| probes.readiness.timeoutSeconds | int | `10` |  |
| probes.startup.enabled | bool | `false` |  |
| probes.startup.failureThreshold | int | `30` |  |
| probes.startup.periodSeconds | int | `10` |  |
| resources | object | `{}` | Set resource limits/requests for the Pod(s) |
| securityContext | object | `{}` | Set Frigate Container Security Context |
| service.annotations | object | `{}` |  |
| service.ipFamilies | list | `[]` |  |
| service.ipFamilyPolicy | string | `"SingleStack"` |  |
| service.labels | object | `{}` |  |
| service.loadBalancerIP | string | `nil` | Set specific IP address for LoadBalancer. `service.type` must be set to `LoadBalancer` |
| service.port | int | `5000` | Port the Service should communicate on |
| service.type | string | `"ClusterIP"` | Type of Service to use |
| shmSize | string | `"1Gi"` | amount of shared memory to use for caching |
| strategyType | string | `"Recreate"` | upgrade strategy type (e.g. Recreate or RollingUpdate) |
| tmpfs | object | `{"enabled":true,"sizeLimit":"1Gi"}` | use memory for tmpfs (mounted to /tmp) |
| tolerations | list | `[]` | Node toleration configuration |