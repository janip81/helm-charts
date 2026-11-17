#!/usr/bin/env bash
# Refresh the files this chart copies from janip81/backup-operator at a given ref (tag or commit):
# CRDs, alert rules and the Grafana dashboard. Review the ClusterRole and Deployment templates by hand
# against k8s/base when the operator changes them.
#   charts/backup-operator/hack/sync.sh v0.4.0
set -euo pipefail
ref=${1:?usage: sync.sh <backup-operator ref>}
chart="$(cd "$(dirname "$0")/.." && pwd)"
src="$(mktemp -d)"
trap 'rm -rf -- "$src"' EXIT
git clone -q https://github.com/janip81/backup-operator.git "$src"
git -C "$src" checkout -q "$ref"
cp "$src"/k8s/base/crds/*.yaml "$chart/files/crds/"
cp "$src/k8s/monitoring/grafana/backup-operator.json" "$chart/files/dashboard.json"
python3 - "$src/k8s/monitoring/prometheusrule.yaml" "$chart/files/prometheus-rules.yaml" <<'PY'
import sys, yaml
lines = open(sys.argv[1]).read().splitlines()
i = lines.index("  groups:")
body = [l[4:] if l.startswith("    ") else l.strip() for l in lines[i + 1:]]
out = "# spec.groups of backup-operator k8s/monitoring/prometheusrule.yaml, verbatim (hack/sync.sh).\n" + "\n".join(body) + "\n"
assert yaml.safe_load(out) == yaml.safe_load(open(sys.argv[1]))["spec"]["groups"]
open(sys.argv[2], "w").write(out)
PY
diff <(python3 -c 'import sys,yaml; print(yaml.safe_dump([r for d in yaml.safe_load_all(open(sys.argv[1])) if d and d["kind"]=="ClusterRole" for r in d["rules"]]))' "$src/k8s/base/rbac.yaml") \
     <(helm template x "$chart" | python3 -c 'import sys,yaml; print(yaml.safe_dump([r for d in yaml.safe_load_all(sys.stdin) if d and d["kind"]=="ClusterRole" for r in d["rules"]]))') \
  && echo "ClusterRole matches $ref" || echo "ClusterRole differs from $ref: update templates/rbac.yaml"
echo "Synced from backup-operator $(git -C "$src" rev-parse --short HEAD); bump Chart.yaml version/appVersion."
