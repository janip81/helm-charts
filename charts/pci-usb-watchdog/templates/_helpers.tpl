{{/*
Expand the name of the chart.
*/}}
{{- define "pci-usb-watchdog.name" -}}
pci-usb-watchdog
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "pci-usb-watchdog.fullname" -}}
{{ include "pci-usb-watchdog.name" . }}-{{ .Release.Name }}
{{- end }}

{{- define "pci-usb-watchdog.labels" -}}
app.kubernetes.io/name: {{ include "pci-usb-watchdog.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Deterministic in-container path for a given cluster's mounted kubeconfig.
Shared between deployment.yaml (volumeMounts) and configmap.yaml
(kubeconfig_path) so the two can never drift apart.
*/}}
{{- define "pci-usb-watchdog.kubeconfigPath" -}}
/etc/pci-usb-watchdog/kubeconfigs/{{ .name }}.yaml
{{- end }}
