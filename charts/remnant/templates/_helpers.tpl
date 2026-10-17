{{- define "remnant.name" -}}
{{- .Chart.Name }}
{{- end }}

{{- define "remnant.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{- define "remnant.labels" -}}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
app.kubernetes.io/name: {{ include "remnant.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "remnant.selectorLabels" -}}
app.kubernetes.io/name: {{ include "remnant.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Host headers allowed on /mcp: mcp.allowedHosts, or by default the in-cluster service
(fullname:service.port) plus the Gateway API host.
*/}}
{{- define "remnant.mcpAllowedHosts" -}}
{{- if .Values.mcp.allowedHosts -}}
{{- join "," .Values.mcp.allowedHosts -}}
{{- else -}}
{{- $hosts := list (printf "%s:%v" (include "remnant.fullname" .) .Values.service.port) -}}
{{- if and .Values.gatewayApi.enabled .Values.gatewayApi.host -}}
{{- $hosts = append $hosts .Values.gatewayApi.host -}}
{{- end -}}
{{- join "," $hosts -}}
{{- end -}}
{{- end }}
