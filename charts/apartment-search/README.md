# apartment-search

Self-hosted aggregator for Swedish rental apartment listings (Next.js + PostgreSQL).

Source: https://github.com/janip81/apartment-search

## Adding this helm repository

```bash
helm repo add janip81 https://janip81.github.io/helm-charts/
helm repo update
```

## What gets deployed

| Resource | Purpose |
|---|---|
| Deployment `<release>` | Next.js web app (UI, API, `/health`, `/ready`) |
| CronJob `<release>-collector` | Collector tick — runs every source that is due (per-source interval lives in the DB) |
| Job `<release>-migrate` | `prisma migrate deploy`, once per deploy (Argo CD Sync hook wave 1 / Helm pre-install,pre-upgrade) |
| ConfigMap `<release>-config` | Non-secret env (`env:` values) |
| Secret `<release>-secret` | Only when `secret.create: true`; normally provided externally (Vault/AVP) with key `DATABASE_URL` |
| HTTPRoute / Ingress | Gateway API (default) or classic Ingress |
| CNPG Cluster `<release>-pg` | Only when `cnpg.enabled: true` (dedicated PostgreSQL with a PVC) |

Argo CD ordering: Secret/ConfigMap (wave 0) → migrate Job (Sync hook, wave 1) → Deployment + CronJob (wave 2).

## Minimal values (external database, secret managed outside the chart)

```yaml
imagePullSecrets:
  - name: ghcr-creds
image:
  tag: "<git-sha>"
secret:
  create: false        # Secret <release>-secret with key DATABASE_URL exists already
gatewayApi:
  host: apartments.example.com
```

See [values.yaml](values.yaml) for all options.
