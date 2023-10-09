{{/* helpers.tpl */}}

{{- define "worker.replicas" -}}
{{- $replicas := index .Values.cluster.name -}}
{{- with $replicas -}}
{{- . }}
{{- else -}}
{{ .replicas }}
{{- end }}
{{- end }}
