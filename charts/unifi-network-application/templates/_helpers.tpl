{{/* vim: set filetype=mustache: */}}

{{- define "unifi-network-application.name" -}}
{{- .Chart.Name -}}
{{- end }}

{{- define "unifi-network-application.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{- define "unifi-network-application.labels" -}}
app.kubernetes.io/name: {{ include "unifi-network-application.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "unifi-network-application.selectorLabels" -}}
app.kubernetes.io/name: {{ include "unifi-network-application.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
