{{/*
Expand the name of the chart.
*/}}
{{- define "vsphere-cns-volume-monitor.name" -}}
vsphere-cns-volume-monitor
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "vsphere-cns-volume-monitor.fullname" -}}
{{ include "vsphere-cns-volume-monitor.name" . }}-{{ .Release.Name }}
{{- end }}

{{- define "vsphere-cns-volume-monitor.labels" -}}
app.kubernetes.io/name: {{ include "vsphere-cns-volume-monitor.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
