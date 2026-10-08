# alertmanager-mqtt-bridge

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.1.0](https://img.shields.io/badge/AppVersion-0.1.0-informational?style=flat-square)

Bridges Prometheus Alertmanager to MQTT so Home Assistant sees homelab alerts (MQTT discovery sensors, push events, dead-man's-switch heartbeat)

**Homepage:** <https://github.com/janip81/helm-charts/tree/main/charts/alertmanager-mqtt-bridge>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| janip81 | <jani@techmonkeys.se> | <https://github.com/janip81> |

## Source Code

* <https://github.com/janip81/helm-charts/tree/main/charts/alertmanager-mqtt-bridge>

# Overview
Bridges Prometheus Alertmanager to MQTT so Home Assistant shows homelab
alerts. It polls the Alertmanager API for the current state (retained
`<prefix>/active`, plus a `<prefix>/heartbeat` from the always-firing
Watchdog alert), and turns Alertmanager webhooks (`POST /alertmanager`)
into deduplicated firing/resolved events on `<prefix>/event`. Home Assistant
entities are created via MQTT discovery.

Point an Alertmanager webhook receiver at
`http://<release service>.<namespace>.svc:8000/alertmanager`.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Affinity |
| alertmanagerUrl | string | `"http://alertmanager-operated.prometheus.svc:9093"` | Alertmanager base URL the bridge polls (GET /api/v2/alerts) |
| image.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| image.repository | string | `"ghcr.io/janip81/alertmanager-mqtt-bridge"` | Image repository |
| image.tag | string | `"latest"` | Image tag |
| imagePullSecrets | list | `[]` | Image pull secrets (the image is private) |
| mqtt.createSecret | bool | `false` | Create a Secret from user/password below instead (test/CI only) |
| mqtt.existingSecret | string | `""` | Existing Secret with keys MQTT_USER and MQTT_PASSWORD (recommended) |
| mqtt.host | string | `"mosquitto.mqtt.svc.cluster.local"` | MQTT broker host |
| mqtt.password | string | `""` | MQTT password when createSecret is true |
| mqtt.port | int | `1883` | MQTT broker port |
| mqtt.topicPrefix | string | `"homelab/alerts"` | Topic prefix (active, event, heartbeat, availability live under it) |
| mqtt.user | string | `""` | MQTT user when createSecret is true |
| nodeSelector | object | `{}` | Node selector |
| podAnnotations | object | `{}` | Pod annotations |
| pollIntervalSeconds | int | `60` | Seconds between Alertmanager API polls (also the heartbeat cadence) |
| replicaCount | int | `1` | Replicas. Keep 1: two bridges would publish duplicate events. |
| resources | object | `{"limits":{"cpu":"200m","memory":"128Mi"},"requests":{"cpu":"10m","memory":"48Mi"}}` | Resource requests/limits |
| service.port | int | `8000` | Service port (webhook POST /alertmanager, GET /metrics, GET /healthz) |
| serviceMonitor.enabled | bool | `false` | Create a Prometheus Operator ServiceMonitor |
| serviceMonitor.interval | string | `"60s"` | Scrape interval |
| serviceMonitor.labels | object | `{}` | Extra labels so your Prometheus selects it (e.g. release: <prometheus>) |
| serviceMonitor.scrapeTimeout | string | `"10s"` | Scrape timeout |
| tolerations | list | `[]` | Tolerations |
