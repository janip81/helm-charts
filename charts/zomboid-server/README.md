# zomboid-server

![Version: 0.1.2](https://img.shields.io/badge/Version-0.1.2-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 41.78.19](https://img.shields.io/badge/AppVersion-41.78.19-informational?style=flat-square)

A Helm chart for deploying a Project Zomboid dedicated server on Kubernetes

**Homepage:** <https://projectzomboid.com>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| janip81 | <jani@techmonkeys.se> |  |

## Source Code

* <https://github.com/Danixu/project-zomboid-server-docker>
* <https://github.com/fpsacha/zomboid-control-panel>
* <https://github.com/janip81/helm-charts/tree/main/charts/zomboid-server>

## Overview

This Helm chart deploys a [Project Zomboid](https://projectzomboid.com) dedicated server on Kubernetes as a single-replica StatefulSet.

**Server image:** [`danixu86/project-zomboid-dedicated-server`](https://hub.docker.com/r/danixu86/project-zomboid-dedicated-server) — full RCON, Workshop, Build 41/42 multi-branch support.

**Web panel:** [`ghcr.io/fpsacha/zomboid-panel`](https://github.com/fpsacha/zomboid-control-panel) (Zomboid Control Panel v1.0.66) — a purpose-built PZ admin dashboard with RCON console, live world map, mod manager, player management, backups, and scheduler. Runs as a sidecar with no Docker socket.

## Prerequisites

- Kubernetes 1.29+
- Helm 3.16+
- Cilium with Gateway API support (for panel HTTPRoute)
- Cilium LoadBalancer IP pool (for game traffic)
- vSphere CSI or another `ReadWriteOnce`-capable StorageClass
- ArgoCD (optional, for GitOps deployment)

## TL;DR

```bash
helm repo add janip81 https://janip81.github.io/helm-charts/
helm install zomboid janip81/zomboid-server -n games --create-namespace \
  --set zomboid.adminPassword=changeme \
  --set zomboid.rconPassword=changeme-rcon
```

## Installation

### Required Secrets

**Never put passwords in Git.** Create the Kubernetes Secret before deploying:

```bash
kubectl create secret generic zomboid-secrets -n games \
  --from-literal=admin-password='<strong-admin-password>' \
  --from-literal=rcon-password='<strong-rcon-password>' \
  --from-literal=server-password=''
```

Then reference it in values:

```yaml
zomboid:
  existingSecret: "zomboid-secrets"
  secretKeys:
    adminPassword: "admin-password"
    rconPassword: "rcon-password"
    serverPassword: "server-password"
```

The RCON password is automatically shared with the panel sidecar — no separate panel secret is needed. The panel creates its own admin account on first run via the setup wizard.

### Install with values file

```bash
helm upgrade --install zomboid janip81/zomboid-server \
  -n games --create-namespace \
  -f examples/values-prod.yaml
```

## Server Container Security Context

The `danixu86` entrypoint requires root at startup. It performs operations roughly equivalent to:

```bash
chown -R 1000:1000 /home/steam/pz-dedicated/steamapps/workshop /home/steam/Zomboid
chmod 755 /home/steam/Zomboid
su - steam -c "... ./start-server.sh ..."
```

These steps are incompatible with a restricted container security context:

| Restriction | Effect |
|-------------|--------|
| `runAsUser: 1000` | Entrypoint runs as steam; cannot chown files owned by root (PVC first-mount) |
| `runAsNonRoot: true` | Prevents entrypoint from starting as root |
| `capabilities.drop: [ALL]` | Removes `CAP_CHOWN`, breaking the chown step |

**The server container security context is therefore left empty (`{}`) by default.** The entrypoint drops to the steam user on its own after initialization.

Do not add `runAsUser`, `runAsNonRoot`, or `capabilities.drop` to the server security context unless you have tested the exact danixu86 image and confirmed the entrypoint completes successfully with those restrictions.

The **panel sidecar** does not run an entrypoint that requires root and uses the more restrictive defaults:

```yaml
securityContext:
  panel:
    runAsUser: 1000
    runAsGroup: 1000
    runAsNonRoot: true
    allowPrivilegeEscalation: false
    capabilities:
      drop: [ALL]
```

## Build 41 vs Build 42

The server image bakes the branch **at image-build time**. Select the build by choosing the image tag — there is no runtime environment variable for this.

| Build | Tag | Status |
|-------|-----|--------|
| Build 41 (stable) | `41.78.19-release` | Recommended for production |
| Build 42 (early access) | `42.19.0-unstable` | May have breaking changes |

```yaml
# Build 41 stable (default)
image:
  tag: "41.78.19-release"

# Build 42 early access
image:
  tag: "42.19.0-unstable"
```

> **Warning:** Never switch branches while a world is running. Take a VolumeSnapshot before any branch change.
> Local and dedicated server branches must match exactly for clients to connect.

## Admin Password Bootstrap

The `danixu86` image passes `ADMINPASSWORD` as a command-line argument. The server logs the full argument list on every startup, exposing the password in plain text.

The chart uses a bootstrap pattern to limit this exposure:

```yaml
zomboid:
  adminPasswordBootstrap:
    enabled: true  # required for first run; set false afterwards
```

**Workflow:**

1. Deploy with `adminPasswordBootstrap.enabled: true`. The admin account is created.
2. Log into the server or panel and verify the admin account works.
3. Set `adminPasswordBootstrap.enabled: false` in values.
4. Upgrade the chart and delete the pod to apply:
   ```bash
   kubectl delete pod -n games zomboid-0
   ```
5. From this point forward, `ADMINPASSWORD` is not injected into the process and will not appear in logs.

The RCON password is always injected from the Secret regardless of this setting.

## Workshop Mod Configuration

```yaml
zomboid:
  selfManagedMods: false
  mods:
    workshopIds:
      - "2392709985"
      - "2458631365"
    modIds:
      - "MyMod"
      - "AnotherMod"
```

> **Critical:** When `selfManagedMods: false` and both lists are empty, the entrypoint sets `SELF_MANAGED_MODS=true` automatically to protect existing INI mod config. If you explicitly set mods in values, `WORKSHOP_IDS` and `MOD_IDS` are passed to the entrypoint, which writes them into the server INI. Switching between these modes on a live server will override the INI on the next restart.

The environment variable the chart sets is `SELF_MANAGED_MODS` (with underscore). This is the correct spelling accepted by the `danixu86` entrypoint.

### Handing mod management to the panel

After your mod list is stable:

```yaml
zomboid:
  selfManagedMods: true
```

This prevents the entrypoint from overwriting the INI mod entries, so panel-managed changes survive restarts.

## Web Panel

The Zomboid Control Panel (`ghcr.io/fpsacha/zomboid-panel`) runs as a sidecar at port 3001. It connects to the game server via RCON at `127.0.0.1:27015` (internal to the pod). RCON is never exposed as a Kubernetes Service.

### RCON_SKIP_SERVER_CHECK

The panel expects to detect the PZ server process before accepting RCON connections. In a Kubernetes sidecar deployment, the panel cannot see the server container's process list — they run in separate container namespaces despite sharing the pod network. The panel would therefore always report the server as offline and refuse RCON commands.

`RCON_SKIP_SERVER_CHECK=true` is set by default to bypass this check. RCON connections and all RCON commands function normally regardless of the process-detection status.

```yaml
panel:
  rcon:
    host: "127.0.0.1"   # always 127.0.0.1 in the sidecar pod
    port: 27015          # must match zomboid.rcon.port
    skipServerCheck: true  # required for sidecar deployment
```

### Panel mounts

The panel reads PZ paths from two shared volume mounts:

| Volume | Server path | Panel path | Access |
|--------|------------|------------|--------|
| `data` PVC | `/home/steam/Zomboid` | `/zomboid` | Writable (PanelBridge IPC) |
| `serverFiles` PVC | `/home/steam/pz-dedicated` | `/pz-server` | Read-only by default |

### Accessing the panel

With Gateway API:
```yaml
gateway:
  enabled: true
  hostname: "zomboid.example.com"
  parentRefs:
    - name: main-gateway
      namespace: gateway
panel:
  corsOrigins: "https://zomboid.example.com"
  https: true
```

Via port-forward (no gateway):
```bash
kubectl port-forward -n games sts/zomboid-0 3001:3001
# Open http://localhost:3001
```

### What the panel can and cannot do

The panel's **Start**, **Stop**, and **Restart** server buttons cannot control the Kubernetes pod. Do not confuse the panel's **Stop** button with issuing the RCON `quit` command from the panel's RCON console — they are different things.

The panel **can** do the following via its RCON console: `save`, `quit`, `players`, `kick`, `ban`, `unban`, `broadcast`, `adduser`, `setaccesslevel`, weather and event commands, and all other PZ RCON commands.

The panel **cannot**:
- Start or stop the PZ process (Kubernetes owns the container lifecycle)
- Restart the server on crash (Kubernetes StatefulSet controller handles that)
- Auto-update the PZ server binary (managed by image tag + pod replacement)
- Access the Docker socket (not mounted; not needed)
- Accurately report server process status (status indicator will show offline — this is expected)

### Panel backup storage

The panel stores backups created through its UI inside `/app/data` — the same directory as its database, JWT secret, and configuration.

**Risk with the default 2Gi `panelData` PVC:** frequent large world backups via the panel will fill this volume. Once full, the panel process may fail to write its database.

Recommended approaches:
1. **Chart CronJob** (enabled via `backup.enabled: true`) — writes to the `backups` PVC (30Gi), not `panelData`
2. **CSI VolumeSnapshot** after a confirmed RCON save — storage-level snapshot
3. **Send save via RCON console, then trigger CronJob manually:**
   ```bash
   # 1. Issue `save` in the panel RCON console and wait for the save to complete in logs
   # 2. Trigger the backup job immediately:
   kubectl create job \
     --from=cronjob/zomboid-backup \
     zomboid-backup-manual-$(date +%s) \
     -n games
   ```
4. **Increase `panelData` size** before enabling frequent panel backups:
   ```yaml
   persistence:
     panelData:
       size: 10Gi
   ```

The `backups` PVC (mounted at `/backups` in the server container) is used **only** by the chart CronJob — the panel does **not** write into it.

### PanelBridge (optional, disabled by default)

PanelBridge is a server-side Lua mod that enables features beyond RCON: teleport, heal, weather control at granular level, character export/import, inventory editing.

**Requirements:**

1. Make `/pz-server` writable in the panel (needed to install the Lua file):
   ```yaml
   panel:
     panelBridge:
       enabled: true
     serverFilesReadOnly: false
   ```

2. `DoLuaChecksum=false` in the server INI. Set this via the panel's Settings → Server Config editor. This cannot be set via a Helm value — it must be changed in the INI directly.

3. Enable PanelBridge in **Settings → PanelBridge** in the panel UI and restart the PZ server.

Verify the actual path in your running container before enabling PanelBridge:

```bash
kubectl exec -n games <pod-name> -c server -- \
  find /home/steam/pz-dedicated -path "*/Install/media/lua/server" -type d
```

PanelBridge communicates via JSON files in `/zomboid/Lua/panelbridge/<serverName>/` — on the `data` PVC, already writable for the panel at `/zomboid`.

## Planned Maintenance: Safe Shutdown Procedure

> **Important:** The current upstream image (`danixu86/project-zomboid-dedicated-server`) does not install a verified Kubernetes-aware SIGTERM handler. A plain pod deletion or `kubectl scale --replicas=0` may terminate the Java process without flushing a final world save. Do not rely on Kubernetes pod termination alone to produce an application-consistent save.

Use this procedure before any planned maintenance: pod deletion, chart upgrade, scale-down, or VolumeSnapshot.

**Steps:**

1. Open the Zomboid panel and navigate to the RCON console.

2. Issue the save command:
   ```
   save
   ```
   Wait until the server logs confirm the save completed. Watch the logs:
   ```bash
   kubectl logs -n games <pod-name> -c server --tail=100 -f
   ```

3. Issue the quit command:
   ```
   quit
   ```
   The game process will exit. The panel RCON console will lose connectivity — this is expected.

4. Confirm from the server logs that the game process has exited before proceeding.

5. Now delete the pod or scale to zero:
   ```bash
   # For pod replacement (e.g., applying a chart upgrade):
   kubectl delete pod -n games zomboid-0

   # For full stop:
   kubectl scale statefulset -n games zomboid --replicas=0
   ```

> **Note:** After `quit` is issued through RCON, Kubernetes will detect that the container exited and will recreate it (StatefulSet controller). If you do not want an immediate restart, scale to zero before issuing `quit`, or delete the pod immediately after the process exits.

## Graceful Shutdown Configuration

```yaml
shutdown:
  graceful:
    enabled: false
    method: "none"
```

`shutdown.graceful.enabled: false` is the only correct default. There is currently no verified RCON client inside the `danixu86` image container, so no preStop hook is rendered.

A future release may support `method: "rcon"` once a client binary is confirmed present in the image and the full save-then-quit flow is tested end-to-end. Until then, follow the manual maintenance procedure above.

**The chart does not provide a preStop hook.** Kubernetes sends SIGTERM to all containers after the pod is marked for deletion. The pod will be SIGKILL'd after `terminationGracePeriodSeconds` (90 s) regardless of whether the game has saved. This is why the manual save-before-delete procedure is necessary.

## Upgrades

### Chart upgrade procedure

The StatefulSet uses `updateStrategy: OnDelete`. This means:
- Template changes do **not** automatically restart the running pod.
- The pod **will** be recreated automatically by Kubernetes on crash, node failure, or eviction.

To apply a chart upgrade:

1. Follow the safe shutdown procedure above to save the world first.

2. Take a VolumeSnapshot before any significant upgrade:
   ```bash
   helm upgrade zomboid janip81/zomboid-server -n games -f values.yaml \
     --set volumeSnapshot.enabled=true
   helm upgrade zomboid janip81/zomboid-server -n games -f values.yaml \
     --set volumeSnapshot.enabled=false
   ```

3. Upgrade the chart:
   ```bash
   helm upgrade zomboid janip81/zomboid-server -n games -f values.yaml
   ```

4. Delete the pod to apply the updated StatefulSet template:
   ```bash
   kubectl delete pod -n games zomboid-0
   ```
   The StatefulSet controller immediately recreates it using the updated spec.

5. Watch logs to confirm startup:
   ```bash
   kubectl logs -f -n games zomboid-0 -c server
   ```

## Save Migration from Windows

### Pre-migration checklist

- [ ] Stop the Windows server cleanly before copying files
- [ ] Branches must match (both B41 or both B42)
- [ ] Mod list and load order must be identical
- [ ] Take a VolumeSnapshot before the first dedicated-server startup with migrated saves

### Source paths (Windows)

```
C:\Users\<username>\Zomboid\
  Saves\Multiplayer\<serverName>\
  Server\<serverName>.ini
  Server\<serverName>_SandboxVars.lua
  Server\<serverName>_spawnpoints.lua
  Server\<serverName>_spawnregions.lua
  db\
```

### Migration procedure

1. Stop the Windows server cleanly.

2. Scale the StatefulSet to zero:
   ```bash
   kubectl scale sts zomboid -n games --replicas=0
   ```

3. Enable the migration helper pod:
   ```yaml
   migration:
     enabled: true
   ```
   ```bash
   helm upgrade zomboid janip81/zomboid-server -n games -f values.yaml
   kubectl wait --for=condition=Ready pod/zomboid-migration -n games
   ```

4. Copy saves:
   ```bash
   kubectl cp "C:/Users/<user>/Zomboid/Saves/Multiplayer/<serverName>" \
     games/zomboid-migration:/home/steam/Zomboid/Saves/Multiplayer/<serverName>
   kubectl cp "C:/Users/<user>/Zomboid/Server" \
     games/zomboid-migration:/home/steam/Zomboid/Server
   kubectl cp "C:/Users/<user>/Zomboid/db" \
     games/zomboid-migration:/home/steam/Zomboid/db
   ```

5. Fix ownership:
   ```bash
   kubectl exec -it -n games zomboid-migration -- \
     chown -R 1000:1000 /home/steam/Zomboid
   ```

6. Disable migration and restart:
   ```yaml
   migration:
     enabled: false
   ```
   ```bash
   helm upgrade zomboid janip81/zomboid-server -n games -f values.yaml
   kubectl scale sts zomboid -n games --replicas=1
   ```

7. Watch logs and confirm world + character load correctly.

Keep the same `serverName` as on Windows. Changing it creates a new world.

## Backups

### CronJob (crash-consistent)

The built-in CronJob reads live files from the data PVC without coordinating a save with the running server. **Backups are crash-consistent, not application-consistent.** Files copied while the server is mid-write may be incomplete.

```yaml
backup:
  enabled: true
  schedule: "0 4 * * *"
  retentionDays: 7
```

Archives are written to the `backups` PVC at `/backups/<serverName>-YYYYMMDD-HHMMSS.tar.gz`.

Trigger a manual run immediately after an RCON save:
```bash
kubectl create job \
  --from=cronjob/zomboid-backup \
  zomboid-backup-manual-$(date +%s) \
  -n games
```

### CSI VolumeSnapshots

A CSI snapshot taken without a prior RCON save is still crash-consistent. For improved consistency, issue `save` through the RCON console first and wait for confirmation — then take the snapshot immediately:

```bash
# After confirmed RCON save:
helm upgrade zomboid janip81/zomboid-server -n games -f values.yaml \
  --set volumeSnapshot.enabled=true
helm upgrade zomboid janip81/zomboid-server -n games -f values.yaml \
  --set volumeSnapshot.enabled=false
```

For the safest pre-maintenance snapshot:
1. Issue `save` via RCON console.
2. Issue `quit` via RCON console.
3. Confirm the server has stopped (logs show exit).
4. Take the VolumeSnapshot.
5. Restart or delete/recreate the pod.

Take snapshots before:
- Server version upgrade
- Branch switch (B41 ↔ B42)
- Large mod list changes
- World migration from another host
- Panel upgrades

## First-Deployment Shutdown Test

Before committing a world to production, verify shutdown behavior with this test (use a disposable test world):

1. Start the server and enter the game.
2. Place or move a recognizable object.
3. Send `save` through the panel RCON console:
   ```bash
   kubectl logs -n games zomboid-0 -c server --tail=100 -f
   ```
   Wait until logs confirm the save completed.
4. Send `quit` through the RCON console.
5. Confirm a clean exit in the logs.
6. Delete/recreate the pod:
   ```bash
   kubectl delete pod -n games zomboid-0
   ```
7. Re-enter the game and verify the object placement survived.

**Separately** (on a disposable world only), test a plain pod deletion without a prior RCON quit:
```bash
kubectl delete pod -n games zomboid-0
```
Check whether the last auto-save survived. Do **not** rely on this for production worlds until the behavior is confirmed repeatable. Do not update chart documentation to claim graceful SIGTERM handling unless this test passes consistently.

## Cilium LoadBalancer Configuration

```yaml
service:
  game:
    type: LoadBalancer
    loadBalancerIP: "192.168.101.50"
    externalTrafficPolicy: Local
    ports:
      game: 16261
      direct: 16262
    steamPorts:
      enabled: false   # enable for Steam client discovery (ports 8766, 8767 UDP)
```

`externalTrafficPolicy: Local` is recommended for a single-replica StatefulSet.

Steam discovery ports (8766/8767 UDP) are disabled by default. Enable them if players use the Steam server browser rather than direct connect.

## Troubleshooting

### Volume ownership errors

```bash
kubectl exec -it zomboid-0 -n games -c server -- ls -la /home/steam/Zomboid
```

All files should be owned `1000:1000`. If not, fix with the migration pod:
```bash
kubectl exec -it -n games zomboid-migration -- chown -R 1000:1000 /home/steam/Zomboid
```

### Workshop downloads failing

Mods install on the **second** server start. If they fail repeatedly:
- Check logs for Steam auth errors.
- Add `FORCESTEAMCLIENTSOUPDATE=true` via `zomboid.extraEnv` for one restart.
- Verify the server node can reach Steam (8766/8767 UDP outbound).

### Panel RCON shows server offline

This is expected. The panel cannot detect the PZ process in the server container namespace. `RCON_SKIP_SERVER_CHECK=true` is set automatically — RCON commands work regardless.

### Missing player after migration

- The `db/` directory must have been copied completely.
- The `serverName` must match exactly (case-sensitive).
- Check logs for `LoadPlayerData`.

### Panel data PVC full

```bash
kubectl exec -it zomboid-0 -n games -c panel -- df -h /app/data
```

If full from panel-created backups:
```bash
kubectl exec -it zomboid-0 -n games -c panel -- \
  find /app/data/backups -name "*.zip" -mtime +7 -delete
```
Then increase `persistence.panelData.size` before re-enabling panel backups.

### Why replicas must remain at 1

PZ saves are single-file-per-world. Two replicas writing to the same PVC would corrupt the save. The chart hardcodes `replicas: 1`.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Affinity rules for pod scheduling |
| backup.enabled | bool | `false` | Enable the backup CronJob |
| backup.image.pullPolicy | string | `"IfNotPresent"` |  |
| backup.image.repository | string | `"alpine"` | Image used for backup scripts (needs tar, find, date) |
| backup.image.tag | string | `"3.19"` |  |
| backup.retentionDays | int | `7` | Number of days to retain backup archives |
| backup.schedule | string | `"0 4 * * *"` | Cron schedule for backups |
| fullnameOverride | string | `""` | Provide a full name override for chart resources |
| gateway.annotations | object | `{}` | Annotations on the HTTPRoute resource |
| gateway.enabled | bool | `false` | Enable the HTTPRoute for the panel |
| gateway.hostname | string | `"zomboid.example.com"` | Hostname the panel should be reachable on |
| gateway.parentRefs | list | `[{"name":"main-gateway","namespace":"gateway"}]` | Parent gateway references |
| image | object | `{"pullPolicy":"IfNotPresent","repository":"danixu86/project-zomboid-dedicated-server","tag":"41.78.19-release"}` | Docker image for the Project Zomboid dedicated server. Build 41 vs Build 42 is determined by the image tag — STEAMAPPBRANCH is baked at build time. Build 41 (stable):       danixu86/project-zomboid-dedicated-server:41.78.19-release Build 42 (early access): danixu86/project-zomboid-dedicated-server:42.19.0-unstable |
| image.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| image.repository | string | `"danixu86/project-zomboid-dedicated-server"` | Docker repository for the server image |
| image.tag | string | 41.78.19-release (Build 41 stable) | Image tag. Pin to a specific version; floating tags are discouraged in production. |
| livenessProbe.enabled | bool | `false` | Enable liveness probe |
| livenessProbe.failureThreshold | int | `6` |  |
| livenessProbe.initialDelaySeconds | int | `300` |  |
| livenessProbe.periodSeconds | int | `30` |  |
| livenessProbe.timeoutSeconds | int | `5` |  |
| migration.enabled | bool | `false` | Enable the migration helper pod |
| migration.image.pullPolicy | string | `"IfNotPresent"` |  |
| migration.image.repository | string | `"busybox"` | Image used by the migration pod |
| migration.image.tag | string | `"1.36"` |  |
| nameOverride | string | `""` | Provide a name override for chart resources |
| nodeSelector | object | `{}` | Node selector for pod scheduling |
| panel.corsOrigins | string | `""` | CORS allowed origins. Required when the panel is behind a reverse proxy. Set to the full URL the panel is accessed from, e.g. "https://zomboid.example.com". Leave empty for LAN/localhost access (private IPs are allowed automatically). |
| panel.enabled | bool | `true` | Enable the Zomboid Control Panel sidecar |
| panel.extraEnv | list | `[]` | Extra environment variables for the panel container |
| panel.https | bool | `true` | Set true when the panel is served over HTTPS by a reverse proxy (Gateway API). Enables HSTS and upgrade-insecure-requests security headers. |
| panel.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| panel.image.repository | string | `"ghcr.io/fpsacha/zomboid-panel"` | Panel image repository |
| panel.image.tag | string | `"v1.0.66"` | Panel image tag (pin to a specific release in production) |
| panel.logLevel | string | `"info"` | Winston log level for the panel process (error, warn, info, debug) |
| panel.panelBridge.enabled | bool | `false` | Enable PanelBridge integration (requires DoLuaChecksum=false and write access to /pz-server) |
| panel.port | int | `3001` | Panel HTTP port |
| panel.rcon.host | string | `"127.0.0.1"` | Hostname the panel uses to reach the game server RCON |
| panel.rcon.port | int | `27015` | RCON port the panel connects to (must match zomboid.rcon.port) |
| panel.rcon.skipServerCheck | bool | `true` | Allow RCON even when the panel cannot detect the PZ process. Must be true in Kubernetes: the panel sidecar runs in a separate container and cannot inspect the server container's process list. RCON commands still work. |
| panel.serverFilesReadOnly | bool | `true` | Mount the PZ server install (/pz-server) as read-only in the panel container. Must be set to false when panelBridge.enabled is true, because PanelBridge needs to write PanelBridge.lua into /pz-server/Install/media/lua/server/. |
| panel.steamApiKey | string | `""` | Optional Steam Web API key for richer mod metadata from the Workshop. See https://steamcommunity.com/dev/apikey |
| persistence.backups.accessModes | list | `["ReadWriteOnce"]` | Access modes |
| persistence.backups.enabled | bool | `true` | Enable the backups PVC |
| persistence.backups.existingClaim | string | `""` | Use an existing PVC instead of creating one |
| persistence.backups.size | string | `"30Gi"` | Size of the backups PVC |
| persistence.backups.storageClass | string | `""` | Per-PVC StorageClass override |
| persistence.data.accessModes | list | `["ReadWriteOnce"]` | Access modes |
| persistence.data.enabled | bool | `true` | Enable the game data PVC |
| persistence.data.existingClaim | string | `""` | Use an existing PVC instead of creating one |
| persistence.data.size | string | `"20Gi"` | Size of the game data PVC |
| persistence.data.storageClass | string | `""` | Per-PVC StorageClass override |
| persistence.panelData.accessModes | list | `["ReadWriteOnce"]` | Access modes |
| persistence.panelData.enabled | bool | `true` | Enable the panel data PVC |
| persistence.panelData.existingClaim | string | `""` | Use an existing PVC instead of creating one |
| persistence.panelData.size | string | `"2Gi"` | Size of the panel data PVC. Increase if you intend to use the panel backup feature frequently. |
| persistence.panelData.storageClass | string | `""` | Per-PVC StorageClass override |
| persistence.panelLogs.accessModes | list | `["ReadWriteOnce"]` | Access modes |
| persistence.panelLogs.enabled | bool | `false` | Enable a PVC for panel logs (disabled = emptyDir) |
| persistence.panelLogs.existingClaim | string | `""` | Use an existing PVC instead of creating one |
| persistence.panelLogs.size | string | `"2Gi"` | Size of the panel logs PVC |
| persistence.panelLogs.storageClass | string | `""` | Per-PVC StorageClass override |
| persistence.serverFiles.accessModes | list | `["ReadWriteOnce"]` | Access modes |
| persistence.serverFiles.enabled | bool | `true` | Enable the server files PVC |
| persistence.serverFiles.existingClaim | string | `""` | Use an existing PVC instead of creating one |
| persistence.serverFiles.size | string | `"30Gi"` | Size of the server files PVC (PZ server binary ~2 GB + workshop mods can be large) |
| persistence.serverFiles.storageClass | string | `""` | Per-PVC StorageClass override |
| persistence.storageClass | string | `""` | Default StorageClass for all PVCs (overridable per PVC). Leave "" for cluster default. |
| podSecurityContext | object | `{"fsGroup":1000}` | Pod-level security context fsGroup 1000 matches the steam/node user GID so mounted PVCs are writable by both containers. |
| readinessProbe.enabled | bool | `true` | Enable readiness probe |
| readinessProbe.failureThreshold | int | `10` |  |
| readinessProbe.initialDelaySeconds | int | `30` |  |
| readinessProbe.periodSeconds | int | `15` |  |
| readinessProbe.timeoutSeconds | int | `5` |  |
| resources.panel | object | `{"limits":{"cpu":"500m","memory":"512Mi"},"requests":{"cpu":"100m","memory":"256Mi"}}` | Resources for the Zomboid Control Panel sidecar |
| resources.server | object | `{"limits":{"cpu":"4000m","memory":"8Gi"},"requests":{"cpu":"1000m","memory":"4Gi"}}` | Resources for the game server container |
| securityContext.panel | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"runAsGroup":1000,"runAsNonRoot":true,"runAsUser":1000}` | Security context for the Zomboid Control Panel sidecar The panel image is built with UID/GID 1000 (matching the compose default build-arg). Adjust runAsUser if you see permission errors on /app/data or /zomboid. |
| securityContext.server | object | `{}` | Security context for the game server container.  Left empty intentionally. The danixu86 entrypoint requires root at startup: it runs chown -R 1000:1000 on the mounted PVC directories (requires CAP_CHOWN) then uses `su - steam` to drop to the steam user before launching the server.  These entrypoint operations are INCOMPATIBLE with:   runAsUser: 1000     — entrypoint must start as root   runAsNonRoot: true  — same reason   capabilities.drop: [ALL] — removes CAP_CHOWN, breaking the chown step  Do not set these values unless a real container startup test with the exact danixu86 image confirms that the entrypoint completes successfully. |
| service.game.annotations | object | `{}` | Annotations for the game service (e.g. Cilium LB pool selector) |
| service.game.externalTrafficPolicy | string | `"Local"` | externalTrafficPolicy for the game service. Local preserves client source IPs and avoids the double-NAT hop. Correct for a single-replica StatefulSet (traffic only goes to the one pod). |
| service.game.loadBalancerIP | string | `""` | Static IP from your Cilium LB pool (leave empty for automatic assignment) |
| service.game.ports | object | `{"direct":16262,"game":16261}` | Required game ports (always exposed) |
| service.game.ports.direct | int | `16262` | Direct-connect UDP port |
| service.game.ports.game | int | `16261` | Main game UDP port |
| service.game.steamPorts.enabled | bool | `false` | Enable Steam discovery ports in the game Service |
| service.game.steamPorts.port1 | int | `8766` | Steam port 1 |
| service.game.steamPorts.port2 | int | `8767` | Steam port 2 |
| service.game.type | string | `"LoadBalancer"` | Game service type. LoadBalancer is required for direct UDP game traffic. |
| service.panel.port | int | `3001` | Panel service port |
| service.panel.type | string | `"ClusterIP"` | Panel service type (ClusterIP; exposed externally only via Gateway API) |
| shutdown.graceful.enabled | bool | `false` | Enable graceful shutdown (no verified method is currently implemented) |
| shutdown.graceful.method | string | `"none"` | Shutdown method. Currently only "none" is supported. "rcon" may be added in a future release once a client binary is verified to exist inside the danixu86 image and tested end-to-end. |
| startupProbe.enabled | bool | `true` | Enable startup probe |
| startupProbe.failureThreshold | int | `40` | How many consecutive failures before the pod is killed (60s + 40*15s = 10 min total) |
| startupProbe.initialDelaySeconds | int | `60` | Seconds before the first probe fires |
| startupProbe.periodSeconds | int | `15` | How often to probe |
| startupProbe.timeoutSeconds | int | `5` | Probe timeout |
| terminationGracePeriodSeconds | int | `90` | Seconds Kubernetes waits for the pod to shut down cleanly before SIGKILL. The Danixu entrypoint does not install a verified SIGTERM handler that saves the world. A plain pod deletion or scale-to-zero may terminate the server without an explicit save. Before planned maintenance, issue `save` then `quit` via the panel RCON console first. |
| tolerations | list | `[]` | Tolerations for pod scheduling |
| volumeSnapshot.data | object | `{"enabled":true}` | Snapshot the game data PVC |
| volumeSnapshot.enabled | bool | `false` | Enable snapshot creation (requires a CSI driver that supports VolumeSnapshots) |
| volumeSnapshot.serverFiles | object | `{"enabled":true}` | Snapshot the server files PVC |
| volumeSnapshot.snapshotClassName | string | `""` | VolumeSnapshotClass name (leave "" for cluster default) |
| zomboid.adminPassword | string | `""` | Admin password (only used for initial account creation; see adminPasswordBootstrap) |
| zomboid.adminPasswordBootstrap.enabled | bool | `true` | Inject ADMINPASSWORD from the Secret on startup. Set false after the admin account has been created on first run. |
| zomboid.adminUsername | string | `"admin"` | Admin username |
| zomboid.displayName | string | `""` | Display name in the server browser (kept from INI if left empty) |
| zomboid.existingSecret | string | `""` | Reference an existing Kubernetes Secret instead of creating one. The secret must contain the keys defined in secretKeys. Set to "" to have the chart create a secret from the inline password values below. |
| zomboid.extraEnv | list | `[]` | Additional environment variables passed to the server container |
| zomboid.maxMemory | string | `"4096m"` | Maximum JVM heap allocation (e.g. 4096m). Must be below the container memory limit. |
| zomboid.maxPlayers | int | `16` | Maximum player slots |
| zomboid.minMemory | string | `"2048m"` | Minimum JVM heap allocation (e.g. 2048m). Falls back to MEMORY if unset. |
| zomboid.mods.modFolders | string | `"workshop,steam,mods"` | Mod source folders (comma-separated, order matters for load priority) |
| zomboid.mods.modIds | list | `[]` | Mod IDs to load (list of strings; prefix each with \\ for Build 42) |
| zomboid.mods.workshopIds | list | `[]` | Steam Workshop item IDs (list of strings, e.g. ["2392709985","2458631365"]) |
| zomboid.noSteam | bool | `false` | Allow non-Steam clients to connect |
| zomboid.public | bool | `false` | Show server in the in-game server browser |
| zomboid.rcon.port | int | `27015` | RCON port (internal only; never exposed outside the pod) |
| zomboid.rconPassword | string | `""` | RCON password |
| zomboid.secretKeys | object | `{"adminPassword":"admin-password","rconPassword":"rcon-password","serverPassword":"server-password"}` | Keys within the secret that hold each password |
| zomboid.secretKeys.adminPassword | string | `"admin-password"` | Key holding the admin password |
| zomboid.secretKeys.rconPassword | string | `"rcon-password"` | Key holding the RCON password |
| zomboid.secretKeys.serverPassword | string | `"server-password"` | Key holding the server join password |
| zomboid.selfManagedMods | bool | `false` | When true, the entrypoint will NOT modify Mods/WorkshopItems in the server INI. Use this after initial mod setup or when managing mods via the web panel. WARNING: when false and workshopIds/modIds are both empty, the entrypoint will CLEAR existing mod config in the INI file on every restart. |
| zomboid.serverName | string | `"zomboid"` | Server name identifier (no spaces or special characters — admin login will fail) |
| zomboid.serverPassword | string | `""` | Server join password (leave empty for no password) |
| zomboid.serverPreset | string | `"Survivor"` | Difficulty preset for a new server Options: Apocalypse, Beginner, Builder, FirstWeek, SixMonthsLater, Survivor |
| zomboid.serverPresetReplace | bool | `false` | Replace the preset on every container start. Set true only during initial setup; set false afterwards to protect custom INI edits. |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
