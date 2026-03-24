# worklog

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.1.0](https://img.shields.io/badge/AppVersion-0.1.0-informational?style=flat-square)

Helm chart for the Worklog salary tracker — Go API + React frontend.

**Homepage:** <https://github.com/janip81/helm-charts/tree/main/charts/worklog>

## Maintainers

| Name | Email | Url |
|------|-------|-----|
| janip81 | jani@techmonkeys.se | <https://github.com/janip81> |

## Prerequisites

- CNPG `Database` CRD applied to create the `worklog` database on `pg-main`
- A Secret named `worklog-api-secret` with keys: `DATABASE_URL`, `KEYCLOAK_URL`, `KEYCLOAK_REALM`, `FRONTEND_ORIGIN`
- Gateway API installed (Cilium)

## Values

| Key | Default | Description |
|-----|---------|-------------|
| api.image.repo | `ghcr.io/janip81/worklog-api` | API image |
| api.image.tag | `latest` | API image tag |
| api.secretName | `worklog-api-secret` | Secret with DATABASE_URL, KEYCLOAK_URL, KEYCLOAK_REALM |
| frontend.image.repo | `ghcr.io/janip81/worklog-frontend` | Frontend image |
| frontend.image.tag | `latest` | Frontend image tag |
| gateway.name | `internal-shared` | Gateway name |
| gateway.namespace | `kube-system` | Gateway namespace |
| gateway.frontendHostname | `worklog.prod.threshold.se` | Frontend hostname |
| gateway.apiHostname | `worklog-api.prod.threshold.se` | API hostname |
