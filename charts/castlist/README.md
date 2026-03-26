# castlist

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.1.0](https://img.shields.io/badge/AppVersion-0.1.0-informational?style=flat-square)

Chromecast video queue player — self-hosted, mobile-friendly, Keycloak-authenticated

**Homepage:** <https://github.com/janip81/castlist>

## Overview

castlist is a self-hosted Chromecast queue manager. Paste video URLs (YouTube, Vimeo, and 1000+ other sites via yt-dlp) into named playlists, cast them to your Chromecast one after another, and control playback from any mobile browser. Protected by Keycloak OIDC.

## Prerequisites

- A Keycloak instance with a `castlist` client configured
- A Chromecast device with a static LAN IP (DHCP reservation on your router)
- Container images built and pushed to a registry

## Install

Add the repo:
```bash
helm repo add janip81 https://janip81.github.io/helm-charts/
helm repo update
```

Install with a values override (never commit secrets):
```bash
helm upgrade --install castlist janip81/castlist \
  --set config.keycloakUrl=https://auth.example.com \
  --set config.keycloakRealm=my-realm \
  --set secrets.keycloakClientSecret=your-secret \
  --set secrets.chromecastIp=192.168.1.x \
  --set api.image.repository=ghcr.io/janip81/castlist-api \
  --set frontend.image.repository=ghcr.io/janip81/castlist-frontend \
  --set ingress.host=castlist.example.com
```

## Keycloak setup

1. Create a client named `castlist` (or matching `config.keycloakClientId`)
2. Set **Access Type** to `confidential`
3. Add your castlist URL to **Valid Redirect URIs** (e.g. `https://castlist.example.com/*`)
4. Copy the client secret → `secrets.keycloakClientSecret`

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| janip81 |  |  |

## Source Code

* <https://github.com/janip81/castlist>

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| api.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| api.image.repository | string | `""` | API container image repository |
| api.image.tag | string | `"latest"` | Image tag |
| api.port | int | `8000` | API container port |
| api.replicas | int | `1` | Number of API replicas |
| api.resources | object | `{"limits":{"cpu":"500m","memory":"512Mi"},"requests":{"cpu":"100m","memory":"256Mi"}}` | Resource requests and limits for the API container |
| config.chromecastFriendlyName | string | `"Bedroom TV"` | Chromecast device friendly name (display only) |
| config.keycloakClientId | string | `"castlist"` | Keycloak client ID |
| config.keycloakRealm | string | `""` | Keycloak realm name |
| config.keycloakUrl | string | `""` | Keycloak base URL (e.g. `https://auth.example.com`) |
| config.queueBackend | string | `"memory"` | Queue backend (`memory` or `redis`) |
| frontend.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| frontend.image.repository | string | `""` | Frontend container image repository |
| frontend.image.tag | string | `"latest"` | Image tag |
| frontend.port | int | `80` | Frontend container port |
| frontend.replicas | int | `1` | Number of frontend replicas |
| frontend.resources | object | `{"limits":{"cpu":"100m","memory":"128Mi"},"requests":{"cpu":"50m","memory":"64Mi"}}` | Resource requests and limits for the frontend container |
| imagePullSecrets | list | `[]` | Image pull secrets for private registries (e.g. ghcr.io) imagePullSecrets:   - name: ghcr-credentials |
| ingress.className | string | `""` | Ingress class name (e.g. `nginx`) |
| ingress.enabled | bool | `true` | Enable Ingress |
| ingress.host | string | `"castlist.local"` | Hostname to expose castlist on |
| ingress.tls | list | `[]` | TLS configuration |
| namespace | string | `"castlist"` | Kubernetes namespace to deploy into |
| registry.create | bool | `false` | Create a ghcr.io image pull secret automatically |
| registry.password | string | `""` | GitHub personal access token with read:packages scope |
| registry.username | string | `""` | GitHub username |
| secrets.chromecastIp | string | `""` | Static LAN IP of the Chromecast device (set via DHCP reservation on router) |
| secrets.keycloakClientSecret | string | `""` | Keycloak client secret — set via `--set` or a values override file, never commit |
