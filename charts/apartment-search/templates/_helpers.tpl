{{- define "apartment-search.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "apartment-search.fullname" -}}
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

{{- define "apartment-search.labels" -}}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{ include "apartment-search.selectorLabels" . }}
app.kubernetes.io/version: {{ .Values.image.tag | default .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "apartment-search.selectorLabels" -}}
app.kubernetes.io/name: {{ include "apartment-search.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "apartment-search.image" -}}
{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}
{{- end }}

{{- define "apartment-search.secretName" -}}
{{- default (printf "%s-secret" (include "apartment-search.fullname" .)) .Values.secret.name }}
{{- end }}

{{/*
DATABASE_URL: from the app Secret, or built from the CNPG-generated app secret when cnpg.enabled.
*/}}
{{- define "apartment-search.databaseEnv" -}}
{{- if .Values.cnpg.enabled }}
- name: DB_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "apartment-search.fullname" . }}-pg-app
      key: password
- name: DATABASE_URL
  value: "postgresql://{{ .Values.cnpg.owner }}:$(DB_PASSWORD)@{{ include "apartment-search.fullname" . }}-pg-rw:5432/{{ .Values.cnpg.database }}"
{{- else }}
- name: DATABASE_URL
  valueFrom:
    secretKeyRef:
      name: {{ include "apartment-search.secretName" . }}
      key: DATABASE_URL
{{- end }}
{{- end }}

{{/* Shared pod-level settings for Deployment, CronJob and migrate Job */}}
{{- define "apartment-search.podCommon" -}}
securityContext:
  {{- toYaml .Values.podSecurityContext | nindent 2 }}
{{- with .Values.imagePullSecrets }}
imagePullSecrets:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- with .Values.nodeSelector }}
nodeSelector:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- with .Values.affinity }}
affinity:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- with .Values.tolerations }}
tolerations:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- end }}
