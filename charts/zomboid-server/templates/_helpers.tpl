{{/*
Expand the name of the chart.
*/}}
{{- define "zomboid-server.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "zomboid-server.fullname" -}}
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

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "zomboid-server.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "zomboid-server.labels" -}}
helm.sh/chart: {{ include "zomboid-server.chart" . }}
{{ include "zomboid-server.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "zomboid-server.selectorLabels" -}}
app.kubernetes.io/name: {{ include "zomboid-server.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Name of the secret containing passwords.
Returns the existingSecret name if set, otherwise the chart-created secret name.
*/}}
{{- define "zomboid-server.secretName" -}}
{{- if .Values.zomboid.existingSecret }}
{{- .Values.zomboid.existingSecret }}
{{- else }}
{{- include "zomboid-server.fullname" . }}
{{- end }}
{{- end }}

{{/*
Resolve the effective StorageClass for a given persistence section.
Uses the per-PVC storageClass if set, otherwise falls back to persistence.storageClass.
*/}}
{{- define "zomboid-server.storageClass" -}}
{{- $sc := .local.storageClass | default .global -}}
{{- if $sc -}}
{{- if eq $sc "-" -}}
storageClassName: ""
{{- else -}}
storageClassName: {{ $sc | quote }}
{{- end -}}
{{- end -}}
{{- end }}
